import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:audioplayers/audioplayers.dart';

class ChapterReadScreen extends StatefulWidget {
  final int idBookDetails;

  const ChapterReadScreen({super.key, required this.idBookDetails});

  @override
  State<ChapterReadScreen> createState() => _ChapterReadScreenState();
}

class _ChapterReadScreenState extends State<ChapterReadScreen> {
  final supabase = Supabase.instance.client;
  final audioPlayer = AudioPlayer();
  late ScrollController _scrollController;

  bool isLoading = true;
  bool hasError = false;

  String chapter = "";
  String content = "";
  String? soundUrl;

  int? idBook;
  int currentChapterNumber = 1;
  int totalChapters = 1;
  int? nextChapterId;

  int? idAkunInt;
  bool _hasProgressRow = false;
  int _lastSavedProgress = 0;
  double _scrollPercent = 0.0;

  bool get isAtBottom => _scrollPercent >= 0.99;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    fetchChapterData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

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

  Future<int?> fetchAkunId() async {
    final email = supabase.auth.currentUser?.email;
    if (email == null) return null;

    final res = await supabase
        .from('akun')
        .select('id_akun')
        .eq('email', email)
        .maybeSingle();

    return res?['id_akun'];
  }

  // -----------------------------------------------------------
  // FETCH CHAPTER + METADATA + ROW PROGRESS (jika ada)
  // -----------------------------------------------------------
  Future<void> fetchChapterData() async {
    try {
      final response = await supabase
          .from('bookdetails')
          .select()
          .eq('id_bookdetails', widget.idBookDetails)
          .single();

      idBook = response['id_book'];
      chapter = response['chapter'] ?? "Unknown Chapter";
      content = response['content'] ?? "";
      soundUrl = response['sound'];
      currentChapterNumber = parseChapter(response['chapter']);

      final list = await supabase
          .from('bookdetails')
          .select('id_bookdetails, chapter')
          .eq('id_book', idBook!)
          .order('chapter', ascending: true);

      totalChapters = list.length;

      nextChapterId = null;
      for (int i = 0; i < list.length; i++) {
        if (list[i]['id_bookdetails'] == widget.idBookDetails) {
          if (i + 1 < list.length) {
            nextChapterId = list[i + 1]['id_bookdetails'];
          }
          break;
        }
      }

      idAkunInt ??= await fetchAkunId();
      final akunIdLocal = idAkunInt;
      final bookIdLocal = idBook;

      if (akunIdLocal != null && bookIdLocal != null) {
        final progressList = await supabase
            .from('userbookprogress')
            .select()
            .eq('id_akun', akunIdLocal)
            .eq('id_book', bookIdLocal)
            .order('last_read_chapter', ascending: false)
            .limit(1);

        if (progressList.isNotEmpty) {
          final row = progressList.first as Map<String, dynamic>;
          _hasProgressRow = true;
          _lastSavedProgress = row['progress_percentage'] ?? 0;
        }
      }

      setState(() {
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      print("Error fetchChapterData: $e");
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  // -----------------------------------------------------------
  // SCROLL → UPDATE PERSEN CHAPTER & PROGRESS BUKU
  // -----------------------------------------------------------
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final max = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;

    double percent;
    if (max <= 0) {
      percent = 1.0;
    } else {
      percent = (offset / max).clamp(0.0, 1.0);
    }

    if (percent > 0.99) percent = 1.0;

    _updateProgressByScroll(percent);
  }

  Future<void> _updateProgressByScroll(double percent) async {
    setState(() {
      _scrollPercent = percent;
    });

    final akunIdLocal = idAkunInt;
    final bookIdLocal = idBook;

    if (akunIdLocal == null || bookIdLocal == null || totalChapters <= 0) {
      return;
    }

    final chapterIdx = currentChapterNumber - 1;
    final bookProgressDouble = ((chapterIdx + percent) / totalChapters) * 100.0;
    final finalProgress = bookProgressDouble
        .clamp(0.0, 100.0)
        .round(); // 0..100

    if (finalProgress <= _lastSavedProgress) return;
    _lastSavedProgress = finalProgress;

    try {
      // 1) Coba UPDATE dulu
      final updated = await supabase
          .from('userbookprogress')
          .update({
            'progress_percentage': finalProgress,
            'last_read_chapter': currentChapterNumber,
          })
          .eq('id_akun', akunIdLocal)
          .eq('id_book', bookIdLocal)
          .select();

      if (updated is List && updated.isNotEmpty) {
        _hasProgressRow = true;
        return;
      }

      // 2) Kalau belum ada row sama sekali, baru INSERT SEKALI
      final inserted = await supabase.from('userbookprogress').insert({
        'id_akun': akunIdLocal,
        'id_book': bookIdLocal,
        'progress_percentage': finalProgress,
        'last_read_chapter': currentChapterNumber,
      }).select();

      if (inserted is List && inserted.isNotEmpty) {
        _hasProgressRow = true;
      }
    } catch (e) {
      print("Error update/insert progress: $e");
    }
  }

  // -----------------------------------------------------------
  // AUDIO
  // -----------------------------------------------------------
  Future<void> playAudio() async {
    if (soundUrl != null && soundUrl!.trim().isNotEmpty) {
      await audioPlayer.stop();
      await audioPlayer.play(UrlSource(soundUrl!));
    }
  }

  // -----------------------------------------------------------
  // UI
  // -----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4EEE9),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4EEE9),
        body: const Center(child: Text("Failed to load chapter data.")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4EEE9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, size: 30),
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  chapter,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Text(
                    content,
                    style: const TextStyle(fontSize: 20, height: 1.5),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: soundUrl != null && soundUrl!.trim().isNotEmpty
                    ? GestureDetector(
                        onTap: playAudio,
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 8,
                                color: Colors.black.withOpacity(0.1),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.volume_up,
                            size: 55,
                            color: Colors.black87,
                          ),
                        ),
                      )
                    : const Text(
                        "No audio available for this chapter.",
                        style: TextStyle(color: Colors.grey),
                      ),
              ),

              const SizedBox(height: 16),

              if (isAtBottom)
                GestureDetector(
                  onTap: () {
                    final next = nextChapterId;
                    if (next != null) {
                      Navigator.pushReplacementNamed(
                        context,
                        '/chapter',
                        arguments: next,
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Center(
                      child: Text(
                        nextChapterId != null
                            ? "Next Chapter"
                            : "Back to Story Detail",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
