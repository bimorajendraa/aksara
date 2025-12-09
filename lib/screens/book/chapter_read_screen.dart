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

  List<String> sentences = [];
  int highlightedIndex = -1;

  Duration audioDuration = Duration.zero;
  Duration audioPosition = Duration.zero;

  int? idBook;
  int currentChapterNumber = 1;
  int totalChapters = 1;
  int? nextChapterId;

  int? idAkunInt;
  bool _hasProgressRow = false;
  int _lastSavedProgress = 0;
  double _scrollPercent = 0.0;

  bool get isAtBottom => _scrollPercent >= 0.99;

  /// FIX: jika konten terlalu pendek maka tombol next tetap muncul
  bool get isBottomBecauseShortContent {
    if (!_scrollController.hasClients) return false;
    return _scrollController.position.maxScrollExtent == 0;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Dengarkan perubahan durasi audio
    audioPlayer.onDurationChanged.listen((d) {
      setState(() => audioDuration = d);
    });

    // Dengarkan posisi audio → update highlight
    audioPlayer.onPositionChanged.listen((p) {
      setState(() => audioPosition = p);
      _updateHighlight();
    });

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

      sentences = _splitIntoSentences(content);

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
        }
      }

      idAkunInt ??= await fetchAkunId();

      setState(() {
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  List<String> _splitIntoSentences(String text) {
    return text
        .split(RegExp(r'(?<=[.!?])\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();
  }

  /// ---------------------------------------------------------
  /// HIGHLIGHT CALCULATION (Mode B: Based on ratio audio duration)
  /// ---------------------------------------------------------
  void _updateHighlight() {
    if (audioDuration.inMilliseconds == 0) return;

    final totalChars = sentences.fold<int>(0, (sum, s) => sum + s.length);
    final durationPerChar = audioDuration.inMilliseconds / totalChars;

    int targetMs = audioPosition.inMilliseconds;
    int accumulated = 0;

    for (int i = 0; i < sentences.length; i++) {
      int sentenceMs = (sentences[i].length * durationPerChar).toInt();

      if (targetMs < accumulated + sentenceMs) {
        if (highlightedIndex != i) {
          setState(() => highlightedIndex = i);
          _autoScrollTo(i);
        }
        return;
      }
      accumulated += sentenceMs;
    }

    setState(() => highlightedIndex = sentences.length - 1);
  }

  void _autoScrollTo(int index) {
    if (!_scrollController.hasClients) return;

    const lineHeight = 80.0;

    final targetOffset = index * lineHeight;

    final screenHeight = MediaQuery.of(context).size.height;

    final centeredOffset = targetOffset - (screenHeight / 3);

    _scrollController.animateTo(
      centeredOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  /// ---------------------------------------------------------
  /// SCROLL PROGRESS
  /// ---------------------------------------------------------
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final max = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;

    double percent = max <= 0 ? 1.0 : (offset / max).clamp(0.0, 1.0);
    if (percent > 0.99) percent = 1.0;

    setState(() => _scrollPercent = percent);
  }

  Future<void> playAudio() async {
    if (soundUrl != null && soundUrl!.trim().isNotEmpty) {
      await audioPlayer.stop();
      await audioPlayer.play(UrlSource(soundUrl!));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4EEE9),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (hasError) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4EEE9),
        body: Center(child: Text("Failed to load chapter data.")),
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
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: sentences.length,
                  itemBuilder: (context, i) {
                    final isActive = i == highlightedIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        sentences[i],
                        style: TextStyle(
                          fontSize: 20,
                          height: 1.5,
                          backgroundColor: isActive
                              ? Colors.yellow.withOpacity(0.35)
                              : null,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    );
                  },
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

              if (isAtBottom || isBottomBecauseShortContent)
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
