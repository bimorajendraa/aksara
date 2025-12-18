import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// SERVICES (INI YANG TADI KELEWAT — LU BENER)
import 'package:aksara/services/user_loader_service.dart';
import 'package:aksara/services/user_session.dart';

class HearTheSoundPage extends StatefulWidget {
  const HearTheSoundPage({super.key});

  @override
  State<HearTheSoundPage> createState() => _HearTheSoundPageState();
}

class _HearTheSoundPageState extends State<HearTheSoundPage> {
  int _currentIndex = 0;
  int hearts = 5;

  final AudioPlayer _player = AudioPlayer();
  final SupabaseClient _supabase = Supabase.instance.client;

  final Map<String, String> _soundUrlMap = {};
  bool _isSoundLoaded = false;

  bool showSuccess = false;
  bool showFail = false;
  bool failFromHeart = false;

  /// =============================================================
  /// DATA SOAL
  /// =============================================================
  final List<Map<String, dynamic>> _questions = [
    {
      'title': 'What does he say ?',
      'monsterImage': 'assets/images/monsterhear1.png',
      'correctAnswer': 'Hello',
      'options': ['Hello', 'Hai', 'Bonjour', 'Holla'],
      'soundKey': 'hello',
    },
    {
      'title': 'What sound ?',
      'monsterImage': 'assets/images/monsterhear2.png',
      'correctAnswer': 'Dog',
      'options': ['Dog', 'Cat', 'Monkey', 'Horse'],
      'soundKey': 'dog',
    },
  ];

  /// =============================================================
  /// INIT
  /// =============================================================
  @override
  void initState() {
    super.initState();
    _ensureUserLoaded();
    _fetchHearSounds();
  }

  Future<void> _ensureUserLoaded() async {
    if (UserSession.instance.idAkun == null) {
      await UserLoaderService.instance.loadUserId();
    }
  }

  /// =============================================================
  /// FETCH AUDIO
  /// =============================================================
  Future<void> _fetchHearSounds() async {
    try {
      final response =
          await _supabase.from('gamesounds').select('description, audio_url');

      for (final item in response) {
        final description = item['description'] as String;
        final key = description.split(' ').last.toLowerCase();
        _soundUrlMap[key] = item['audio_url'];
      }

      setState(() => _isSoundLoaded = true);
    } catch (e) {
      debugPrint('Error fetching audio: $e');
    }
  }

  /// =============================================================
  /// PLAY SOUND
  /// =============================================================
  Future<void> _playSoundByKey(String key) async {
    if (!_isSoundLoaded) return;

    final url = _soundUrlMap[key.toLowerCase()];
    if (url == null) return;

    await _player.stop();
    await _player.play(UrlSource(url));
  }

  /// =============================================================
  /// CHECK ANSWER
  /// =============================================================
  void _checkAnswer(String selectedAnswer) {
    final correctAnswer = _questions[_currentIndex]['correctAnswer'];

    if (selectedAnswer == correctAnswer) {
      _nextQuestion();
    } else {
      setState(() {
        hearts--;
        if (hearts <= 0) {
          failFromHeart = true;
          showFail = true;
        }
      });
    }
  }

  /// =============================================================
  /// NEXT / VALIDATE
  /// =============================================================
  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      // SEMUA SOAL SELESAI
      setState(() => showSuccess = true);

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          Navigator.pop(context); // balik ke page sebelumnya
        }
      });
    }
  }



  /// =============================================================
  /// UI
  /// =============================================================
  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bghearthesound.png',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  /// HEADER
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < hearts
                                ? Icons.favorite
                                : Icons.favorite_border_rounded,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Text(
                    q['title'],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),

                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        q['monsterImage'],
                        height: 220,
                        fit: BoxFit.contain,
                      ),
                      Positioned(
                        right: 20,
                        bottom: 40,
                        child: GestureDetector(
                          onTap: () =>
                              _playSoundByKey(q['soundKey']),
                          child: Image.asset(
                            'assets/images/soundon.png',
                            width: 60,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  ...List.generate(q['options'].length, (i) {
                    final opt = q['options'][i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () => _checkAnswer(opt),
                          child: Text(
                            opt,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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

          if (showSuccess)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Icon(Icons.check_circle,
                    size: 120, color: Colors.green),
              ),
            ),

          if (showFail)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Icon(Icons.close,
                    size: 120, color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
