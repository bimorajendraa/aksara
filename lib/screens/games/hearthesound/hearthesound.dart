import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HearTheSoundPage extends StatefulWidget {
  const HearTheSoundPage({super.key});

  @override
  State<HearTheSoundPage> createState() => _HearTheSoundPageState();
}

class _HearTheSoundPageState extends State<HearTheSoundPage> {
  int _currentIndex = 0;
  final AudioPlayer _player = AudioPlayer();
  final SupabaseClient _supabase = Supabase.instance.client;
  final Map<String, String> _soundUrlMap = {};
  bool _isSoundLoaded = false;

  // Data Soal
  final List<Map<String, dynamic>> _questions = [
    {
      'title': 'What does he say ?',
      'monsterImage': 'assets/images/monsterhear1.png', 
      'correctAnswer': 'Hello',
      'options': ['Hello', 'Hai', 'Bonjour', 'Holla'],
    },
    {
      'title': 'What sound ?',
      'monsterImage': 'assets/images/monsterhear2.png', 
      'correctAnswer': 'Dog',
      'options': ['Dog', 'Cat', 'Monkey', 'Horse'],
    },
  ];

  // Fungsi untuk mengecek jawaban
  void _checkAnswer(String selectedAnswer) {
    String correctAnswer = _questions[_currentIndex]['correctAnswer'];

    if (selectedAnswer == correctAnswer) {
      _showSuccessDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Try again!", textAlign: TextAlign.center),
          duration: Duration(milliseconds: 500),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi Menampilkan Pop Up "Yeay Correct"
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, 
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(4), 
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF1E3A5F), // Warna biru gelap
                  child: Icon(Icons.check, size: 60, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "YEAY CORRECT!",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E3A5F),
                  shadows: [
                    Shadow(offset: Offset(0, 2), color: Colors.black26, blurRadius: 4)
                  ]
                ),
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pop();
        _nextQuestion(); 
      }
    });
  }

  // Fungsi Pindah ke Soal Berikutnya
  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _playSoundByKey(String key) async {
    if (!_isSoundLoaded) return;

    final url = _soundUrlMap[key.toLowerCase()];

    if (url == null) {
      debugPrint('Sound not found for key: $key');
      return;
    }

    await _player.stop();
    await _player.play(UrlSource(url));
  }

  Future<void> _fetchHearSounds() async {
    try {
      final response = await _supabase
          .from('gamesounds')
          .select('description, audio_url');

      for (final item in response) {
        final description = item['description'] as String;

        final key = description.split(' ').last.toLowerCase();
        _soundUrlMap[key] = item['audio_url'];
      }

      setState(() {
        _isSoundLoaded = true;
      });
    } catch (e) {
      debugPrint('Error fetching hear-the-sound audio: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchHearSounds();
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentIndex];

    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND IMAGE FULL SCREEN
          Positioned.fill(
            child: Image.asset(
              'assets/images/bghearthesound.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. KONTEN UTAMA
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // --- PROGRESS BAR (STRIP) ---
                  Row(
                    children: List.generate(_questions.length + 3, (index) {
                      bool isActive = index <= _currentIndex;
                      return Expanded(
                        child: Container(
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isActive 
                                ? Colors.white 
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 40),

                  // --- JUDUL SOAL ---
                  Text(
                    currentQuestion['title'],
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50), 
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(flex: 1),

                  // --- AREA MONSTER & SOUND ---
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        currentQuestion['monsterImage'],
                        height: 220,
                        fit: BoxFit.contain,
                      ),

                      // Tombol Sound
                      Positioned(
                        right: 20,
                        bottom: 40,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Tombol Sound
                            GestureDetector(
                              onTap: () {
                                if (_currentIndex == 0) {
                                  _playSoundByKey('hello');
                                } else if (_currentIndex == 1) {
                                  _playSoundByKey('dog');
                                }
                              },
                              child: Image.asset(
                                'assets/images/soundon.png',
                                width: 60,
                              ),
                            ),
                            // Icon Jari 
                            Positioned(
                              bottom: -20,
                              right: -10,
                              child: Image.asset(
                                'assets/images/jari.png',
                                width: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 2),

                  // --- PILIHAN JAWABAN (GRID / LIST) ---
                  ...List.generate(currentQuestion['options'].length, (index) {
                    String option = currentQuestion['options'][index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () => _checkAnswer(option),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.9),
                            foregroundColor: const Color(0xFF5C7C8A), 
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            option,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}