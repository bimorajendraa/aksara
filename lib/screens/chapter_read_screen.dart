import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:audioplayers/audioplayers.dart';

class ChapterReadScreen extends StatefulWidget {
  final int idBookDetails; // ambil dari screen sebelumnya

  const ChapterReadScreen({super.key, required this.idBookDetails});

  @override
  State<ChapterReadScreen> createState() => _ChapterReadScreenState();
}

class _ChapterReadScreenState extends State<ChapterReadScreen> {
  final supabase = Supabase.instance.client;
  final audioPlayer = AudioPlayer();

  bool isLoading = true;
  bool hasError = false;

  String chapter = "";
  String content = "";
  String? soundUrl;

  @override
  void initState() {
    super.initState();
    fetchChapterData();
  }

  Future<void> fetchChapterData() async {
    try {
      final response = await supabase
          .from('bookdetails')
          .select()
          .eq('id_bookdetails', widget.idBookDetails)
          .single();

      setState(() {
        chapter = response['chapter'] ?? "Unknown Chapter";
        content = response['content'] ?? "";
        soundUrl = response['sound'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> playAudio() async {
    if (soundUrl != null && soundUrl!.isNotEmpty) {
      await audioPlayer.stop();
      await audioPlayer.play(UrlSource(soundUrl!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EEE9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : hasError
              ? const Center(child: Text("Failed to load chapter data."))
              : Column(
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
                        child: Column(
                          children: [
                            Text(
                              content,
                              style: const TextStyle(fontSize: 20, height: 1.5),
                              textAlign: TextAlign.justify,
                            ),

                            const SizedBox(height: 40),

                            if (soundUrl != null && soundUrl!.trim().isNotEmpty)
                              GestureDetector(
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
                            else
                              const Text(
                                "No audio available for this chapter.",
                                style: TextStyle(color: Colors.grey),
                              ),

                            const SizedBox(height: 40),
                          ],
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
