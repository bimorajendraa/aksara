import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoryDetailScreen extends StatefulWidget {
  const StoryDetailScreen({super.key});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  int progress = 0;
  int lastChapter = 1;
  bool loading = true;

  late Map book;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    book = ModalRoute.of(context)!.settings.arguments as Map;
    fetchProgress();
  }

  // -------------------------------------------------------
  // FETCH PROGRESS USER FROM SUPABASE
  // -------------------------------------------------------
  Future<void> fetchProgress() async {
    final idBook = book["id_book"];
    final idAkun = Supabase.instance.client.auth.currentUser!.id;

    try {
      final response = await Supabase.instance.client
          .from('userbookprogress')
          .select()
          .eq('id_book', idBook)
          .eq('id_akun', idAkun)
          .maybeSingle();

      if (response != null) {
        setState(() {
          progress = response['progress_percentage'] ?? 0;
          lastChapter = response['last_read_chapter'] ?? 1;
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      print("Error fetchProgress(): $e");
      setState(() => loading = false);
    }
  }

  // -------------------------------------------------------
  // FETCH id_bookdetails BERDASARKAN CHAPTER
  // -------------------------------------------------------
  Future<int?> fetchBookDetailsId(int chapter) async {
    try {
      final response = await Supabase.instance.client
          .from('bookdetails')
          .select('id_bookdetails')
          .eq('id_book', book["id_book"])
          .eq('chapter', chapter)
          .maybeSingle();

      return response?['id_bookdetails'];
    } catch (e) {
      print("Error fetchBookDetailsId(): $e");
      return null;
    }
  }

  // -------------------------------------------------------
  double chapterValue(int chapterNumber) {
    if (chapterNumber == 1) return progress / 100;
    return 0.0;
  }
  // -------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD3E3EF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
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

                // BOOK COVER
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

                // TITLE
                Text(
                  book["name"],
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // ---------------------------------------------------
                // CONTINUE READING BUTTON
                // ---------------------------------------------------
                GestureDetector(
                  onTap: () async {
                    final idBookDetails = await fetchBookDetailsId(lastChapter);

                    if (idBookDetails == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Chapter not found.")),
                      );
                      return;
                    }

                    Navigator.pushNamed(
                      context,
                      '/chapter',
                      arguments: idBookDetails,
                    );
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

                // PROGRESS PER CHAPTER
                buildChapterProgress("Chapter One", chapterValue(1)),
                buildChapterProgress("Chapter Two", chapterValue(2)),
                buildChapterProgress("Chapter Three", chapterValue(3)),
                buildChapterProgress("Chapter Four", chapterValue(4)),
                buildChapterProgress("Chapter Five", chapterValue(5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // UI WIDGET: CHAPTER PROGRESS
  // -------------------------------------------------------
  Widget buildChapterProgress(String title, double value) {
    return Padding(
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
              Text("${(value * 100).toInt()} %"),
            ],
          ),
        ],
      ),
    );
  }
}
