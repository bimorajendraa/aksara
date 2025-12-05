import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoryDetailScreen extends StatefulWidget {
  const StoryDetailScreen({super.key});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  bool loading = true;
  bool invalidArgs = false;

  // Data buku
  late int idBook;
  late Map book;

  // Data chapter
  List<dynamic> chapters = [];

  // Progress user
  int progress = 0;
  int lastChapter = 0;

  int? idAkunInt;
  int parseChapter(dynamic chapterField) {
    if (chapterField is int) return chapterField;
    if (chapterField is String) {
      final match = RegExp(r'\d+').firstMatch(chapterField);
      if (match != null) {
        return int.tryParse(match.group(0)!) ?? 1;
      }
    }
    return 1;
  }

  int getFirstChapterNumber() {
    if (chapters.isEmpty) return 1;
    return parseChapter(chapters.first['chapter']);
  }

  Future<int?> fetchAkunId() async {
    final email = Supabase.instance.client.auth.currentUser?.email;
    if (email == null) return null;

    final res = await Supabase.instance.client
        .from('akun')
        .select('id_akun')
        .eq('email', email)
        .maybeSingle();

    return res?['id_akun'];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args == null || args is! Map) {
      invalidArgs = true;
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/story-mode');
      });
      return;
    }

    idBook = args['id_book'];
    book = args['book'];

    initLoad();
  }

  Future<void> initLoad() async {
    idAkunInt = await fetchAkunId();
    await fetchDataFast();
  }

  Future<void> fetchDataFast() async {
    final client = Supabase.instance.client;

    try {
      // Chapters
      final chapterFuture = client
          .from('bookdetails')
          .select()
          .eq('id_book', idBook)
          .order('chapter', ascending: true);

      // Progress
      Future<List<dynamic>>? progressFuture;
      final akunId = idAkunInt;
      if (akunId != null) {
        progressFuture = client
            .from('userbookprogress')
            .select()
            .eq('id_book', idBook)
            .eq('id_akun', akunId)
            .order('last_read_chapter', ascending: false)
            .limit(1);
      }

      chapters = await chapterFuture;

      if (progressFuture != null) {
        final list = await progressFuture;
        if (list.isNotEmpty) {
          final row = list.first as Map<String, dynamic>;
          progress = row['progress_percentage'] ?? 0;
          lastChapter = row['last_read_chapter'] ?? 0;
        } else {
          progress = 0;
          lastChapter = 0;
        }
      } else {
        progress = 0;
        lastChapter = 0;
      }

      if (mounted) setState(() => loading = false);
    } catch (e) {
      print("Error fetchDataFast: $e");
      if (mounted) setState(() => loading = false);
    }
  }

  double chapterProgress(int chapterNumber) {
    if (lastChapter == 0) return 0.0;
    return chapterNumber <= lastChapter ? 1.0 : 0.0;
  }

  // -----------------------------------------------------------
  Future<void> openChapter(int chapterNumber) async {
    if (chapters.isEmpty) return;

    final matches = chapters.where(
      (c) => parseChapter(c['chapter']) == chapterNumber,
    );

    dynamic row;
    if (matches.isNotEmpty) {
      row = matches.first;
    } else {
      row = chapters.first;
    }

    if (row == null) return;

    Navigator.pushNamed(
      context,
      '/chapter',
      arguments: row['id_bookdetails'],
    ).then((_) {
      fetchDataFast();
    });
  }

  // -----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (invalidArgs) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFD3E3EF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 15),

              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 30),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  book["cover_book"],
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                book["name"],
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "$progress %",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  final first = getFirstChapterNumber();
                  final chapterToOpen = lastChapter == 0 ? first : lastChapter;

                  openChapter(chapterToOpen);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Center(
                    child: loading
                        ? const CircularProgressIndicator()
                        : const Text(
                            "Continue Reading",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              if (!loading)
                for (var c in chapters)
                  buildChapterProgress(
                    "Chapter ${parseChapter(c['chapter'])}",
                    chapterProgress(parseChapter(c['chapter'])),
                    () => openChapter(parseChapter(c['chapter'])),
                  ),

              if (loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildChapterProgress(String title, double value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: value,
                      color: const Color(0xFF2F4156),
                      backgroundColor: Colors.white,
                      minHeight: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text("${(value * 100).toInt()}%"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
