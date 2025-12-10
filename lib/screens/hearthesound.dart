import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class HearTheSoundPage extends StatefulWidget {
  const HearTheSoundPage({super.key});

  @override
  State<HearTheSoundPage> createState() => _HearTheSoundPageState();
}

class _HearTheSoundPageState extends State<HearTheSoundPage> {
  // Index soal yang sedang aktif (0 = soal pertama)
  int _currentIndex = 0;
  final AudioPlayer _player = AudioPlayer();

  // Data Soal (Bisa ditambah jika punya monster 3 dst)
  final List<Map<String, dynamic>> _questions = [
    {
      'title': 'What does he say ?',
      'monsterImage': 'assets/images/monsterhear1.png', // Monster 1
      'correctAnswer': 'Hello',
      'options': ['Hello', 'Hai', 'Bonjour', 'Holla'],
    },
    {
      'title': 'What sound ?',
      'monsterImage': 'assets/images/monsterhear2.png', // Monster 2
      'correctAnswer': 'Dog',
      'options': ['Dog', 'Cat', 'Monkey', 'Horse'],
    },
  ];

  // Fungsi untuk mengecek jawaban
  void _checkAnswer(String selectedAnswer) {
    String correctAnswer = _questions[_currentIndex]['correctAnswer'];

    if (selectedAnswer == correctAnswer) {
      // Jika Benar, Tampilkan Dialog
      _showSuccessDialog();
    } else {
      // Opsional: Logika jika salah (misal getar atau bunyi error)
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
      barrierDismissible: false, // User tidak bisa tap di luar untuk tutup
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Transparan agar custom shape terlihat
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Centang Besar (Bisa pakai Icon atau Image)
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(4), // Border putih
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF1E3A5F), // Warna biru gelap
                  child: Icon(Icons.check, size: 60, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              // Text Yeay Correct dengan efek stroke/shadow
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

    // Delay 1.5 detik, lalu tutup dialog dan ganti soal
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pop(); // Tutup Dialog
        _nextQuestion(); // Pindah Soal
      }
    });
  }

  // Fungsi Pindah ke Soal Berikutnya
  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      // Masih ada soal berikutnya → lanjut
      setState(() {
        _currentIndex++;
      });
    } else {
      // Soal terakhir sudah dijawab benar → kembali ke halaman sebelumnya (/practice)
      Navigator.pop(context);
      // Kalau kamu MAU pakai named route, bisa pakai ini sebagai alternatif:
      // Navigator.pushNamedAndRemoveUntil(context, '/practice', (route) => false);
    }
  }

  void _playSound(String fileName) async {
    await _player.stop();
    await _player.play(AssetSource('sounds/hearthesound/$fileName'));
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
                      // +3 hanya dummy agar terlihat ada banyak strip (total 5)
                      // Logic: Jika index <= _currentIndex, warnanya terang (aktif)
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
                      color: Color(0xFF2C3E50), // Warna teks gelap
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(flex: 1),

                  // --- AREA MONSTER & SOUND ---
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Gambar Monster
                      Image.asset(
                        currentQuestion['monsterImage'],
                        height: 220,
                        fit: BoxFit.contain,
                      ),

                      // Tombol Sound (Floating di sebelah kanan monster)
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
                                  _playSound('hello.mp3');
                                } else if (_currentIndex == 1) {
                                  _playSound('dog.mp3');
                                }
                              },
                              child: Image.asset(
                                'assets/images/soundon.png',
                                width: 60,
                              ),
                            ),
                            // Icon Jari (Petunjuk klik)
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
                  // Menggunakan Column agar rapi ke bawah
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
                            foregroundColor: const Color(0xFF5C7C8A), // Warna teks
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