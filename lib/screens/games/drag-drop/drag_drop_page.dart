import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

/// =============================================================
/// MODEL PASANGAN HURUF A–Z
/// =============================================================
class LetterPair {
  final String upper;
  final String lower;

  LetterPair(this.upper, this.lower);
}

/// Generate 26 pasangan A–Z
final List<LetterPair> allPairs = List.generate(
  26,
  (i) => LetterPair(
    String.fromCharCode(65 + i), // A-Z
    String.fromCharCode(97 + i), // a-z
  ),
);

/// =============================================================
/// GENERATOR LEVEL (VERSION 2)
/// KIRI & KANAN RANDOM TOTAL (sesuai permintaan lo)
/// =============================================================
Map<String, List<String>> generateShuffledLevel(int jumlah) {
  final rand = Random();

  // Ambil N pasangan random dari 26 pair
  List<LetterPair> chosen = List.from(allPairs)..shuffle();
  chosen = chosen.take(jumlah).toList();

  // Generate huruf kiri (acak uppercase/lowercase)
  final left = chosen.map((p) {
    return rand.nextBool() ? p.upper : p.lower;
  }).toList();

  // Generate huruf jawaban (acak uppercase/lowercase)
  final right = chosen.map((p) {
    return rand.nextBool() ? p.upper : p.lower;
  }).toList();

  // Shuffle kanan biar urutan meleset (lebih challenging)
  right.shuffle();

  // Sound tetap berdasarkan lowercase
  final sounds = chosen.map((p) => p.lower).toList();

  return {
    "leftLetters": left,
    "rightAnswers": right,
    "soundKeys": sounds,
  };
}

/// =============================================================
/// PAGE UTAMA DRAG & DROP (VERSION 2)
/// =============================================================
class AksaraRandomDragPage extends StatefulWidget {
  const AksaraRandomDragPage({super.key});

  @override
  State<AksaraRandomDragPage> createState() => _AksaraRandomDragPageState();
}

class _AksaraRandomDragPageState extends State<AksaraRandomDragPage> {
  /// Warna yang dipakai
  final Color grayA = const Color(0xFFA9A9A9);
  final Color white = const Color(0xFFFFFFFF);
  final Color blueTile = const Color(0xFF567C8D);
  final Color navy = const Color(0xFF2F4156);
  final Color redHeart = const Color(0xFFCC4C4C);
  final Color blueLight = const Color(0xFFC8D9E6);
  final Color pinkHeart = const Color(0xFFD99B9B);
  final Color redError = const Color(0xFFCC4C4C);

  /// Game State
  List<String> leftLetters = [];
  List<String> correctAnswer = [];
  List<String> soundKeys = [];
  List<String?> rightSlots = [];

  /// Tile highlight warna
  List<Color?> tileColors = [];

  int hearts = 4;
  final int slotCount = 6;

  final player = AudioPlayer();

  /// =============================================================
  /// INIT: generate level pertama
  /// =============================================================
  @override
  void initState() {
    super.initState();
    generateNewLevel();
  }

  /// =============================================================
  /// GENERATE LEVEL BARU (dipanggil ketika sukses)
  /// =============================================================
  void generateNewLevel() {
    final data = generateShuffledLevel(slotCount);

    leftLetters = data["leftLetters"]!;
    correctAnswer = data["rightAnswers"]!;
    soundKeys = data["soundKeys"]!;

    rightSlots = List.filled(slotCount, null);
    tileColors = List.filled(slotCount, blueTile);

    setState(() {});
  }

  /// =============================================================
  /// HANDLE DROP
  /// =============================================================
  void handleDrop(int index, String letter) {
    setState(() {
      rightSlots[index] = letter;
    });

    if (rightSlots.every((x) => x != null)) checkAnswer();
  }

  /// =============================================================
  /// CEK JAWABAN
  /// =============================================================
  void checkAnswer() {
    bool correct = true;

    for (int i = 0; i < slotCount; i++) {
      if (rightSlots[i] != correctAnswer[i]) {
        correct = false;
        tileColors[i] = redError;
      } else {
        tileColors[i] = blueTile;
      }
    }

    setState(() {});

    if (correct) {
      showCorrectDialog();
    } else {
      hearts--;
      showWrongDialog();
    }
  }

  /// =============================================================
  /// POPUP BENAR → langsung generate level baru setelah close
  /// =============================================================
  void showCorrectDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black12,
      builder: (context) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: navy,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                "YEAY CORRECT!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: navy,
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      generateNewLevel();
    });
  }

  /// =============================================================
  /// POPUP SALAH
  /// =============================================================
  void showWrongDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black26,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 30),
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: redError,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 80, color: Colors.white),
                ),

                const SizedBox(height: 20),

                Text(
                  "Please correct\nyour answer!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: redError,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// =============================================================
  /// PLAY SOUND
  /// =============================================================
  void playSound(String key) {
    player.play(AssetSource("sounds/$key.mp3"));
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final tileSize = width * 0.22;

    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            /// ================= TOP BAR ==================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      for (int i = 0; i < hearts; i++)
                        Icon(Icons.favorite, color: redHeart, size: 32),
                      for (int i = hearts; i < 4; i++)
                        Icon(Icons.favorite, color: pinkHeart, size: 32),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: blueLight,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.monetization_on, size: 20),
                        SizedBox(width: 6),
                        Text("13",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// ================= DRAG AREA ==================
            Expanded(
              child: ListView.builder(
                itemCount: slotCount,
                itemBuilder: (context, i) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        // DRAGGABLE LEFT TILE
                        Draggable<String>(
                          data: leftLetters[i],
                          feedback:
                              buildTile(leftLetters[i], tileSize, Colors.black26),
                          childWhenDragging:
                              buildTile(leftLetters[i], tileSize, grayA),
                          child: buildTile(
                            leftLetters[i],
                            tileSize,
                            tileColors[i]!,
                          ),
                        ),

                        const SizedBox(width: 20),

                        // DROP TARGET
                        DragTarget<String>(
                          onAccept: (value) => handleDrop(i, value),
                          builder: (context, _, __) {
                            return Container(
                              width: tileSize * 0.8,
                              height: tileSize * 0.8,
                              decoration: BoxDecoration(
                                color: rightSlots[i] == null ? grayA : navy,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  rightSlots[i] ?? "",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const Spacer(),

                        // SOUND BUTTON
                        GestureDetector(
                          onTap: () => playSound(soundKeys[i]),
                          child: Container(
                            width: tileSize,
                            height: tileSize,
                            decoration: BoxDecoration(
                              color: blueTile,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.volume_up,
                                size: 34, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  /// =============================================================
  /// TILE BUILDER
  /// =============================================================
  Widget buildTile(String letter, double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 38,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
