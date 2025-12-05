import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

/// ============================================================================
/// LETTER PAIR MODEL (A–Z)
/// ============================================================================
class LetterPair {
  final String upper;
  final String lower;

  const LetterPair(this.upper, this.lower);
}

/// 26 pasangan huruf A–Z (uppercase + lowercase)
final List<LetterPair> allPairs = List.generate(
  26,
  (i) => LetterPair(
    String.fromCharCode(65 + i), // A-Z
    String.fromCharCode(97 + i), // a-z
  ),
);

/// ============================================================================
/// LEVEL GENERATOR VERSION 2
/// - Memilih N pasangan huruf secara acak
/// - Kiri: huruf acak (upper/lower)
/// - Kanan: huruf acak (upper/lower) yang kemudian di-shuffle lagi
/// - Sound key: lowercase (a.mp3, b.mp3, dst)
/// ============================================================================
Map<String, List<String>> generateShuffledLevel(int count) {
  final rand = Random();

  List<LetterPair> chosen = List.from(allPairs)..shuffle();
  chosen = chosen.take(count).toList();

  final leftLetters = chosen
      .map((p) => rand.nextBool() ? p.upper : p.lower)
      .toList(growable: false);

  final right = chosen
      .map((p) => rand.nextBool() ? p.upper : p.lower)
      .toList(growable: false);

  right.shuffle();

  final soundKeys =
      chosen.map((p) => p.lower).toList(growable: false); // a, b, c, ...

  return {
    'leftLetters': leftLetters,
    'rightAnswers': right,
    'soundKeys': soundKeys,
  };
}

/// ============================================================================
/// HALAMAN GAME DRAG & DROP
/// Layout dituning supaya 1:1 dengan desain (hearts bar, dots, dsb.)
/// ============================================================================
class AksaraRandomDragPage extends StatefulWidget {
  const AksaraRandomDragPage({super.key});

  @override
  State<AksaraRandomDragPage> createState() => _AksaraRandomDragPageState();
}

class _AksaraRandomDragPageState extends State<AksaraRandomDragPage> {
  // Palet warna dari Figma
  final Color grayDot = const Color(0xFFA9A9A9);
  final Color white = const Color(0xFFFFFFFF);
  final Color blueTile = const Color(0xFF567C8D);
  final Color navy = const Color(0xFF2F4156);
  final Color redHeart = const Color(0xFFCC4C4C);
  final Color pinkHeart = const Color(0xFFD99B9B);
  final Color blueLight = const Color(0xFFC8D9E6);
  final Color redError = const Color(0xFFCC4C4C);

  final int slotCount = 6;

  late List<String> leftLetters;
  late List<String> correctAnswers;
  late List<String> soundKeys;
  late List<String?> rightSlots;
  late List<Color> tileColors;

  int hearts = 4;

  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _generateNewLevel();
  }

  /// Generate level baru (dipanggil di init & saat jawaban benar)
  void _generateNewLevel() {
    final data = generateShuffledLevel(slotCount);

    leftLetters = data['leftLetters']!;
    correctAnswers = data['rightAnswers']!;
    soundKeys = data['soundKeys']!;

    rightSlots = List<String?>.filled(slotCount, null);
    tileColors = List<Color>.filled(slotCount, blueTile);

    setState(() {});
  }

  /// Saat huruf di-drop ke row tertentu
  void _handleDrop(int rowIndex, String letter) {
    setState(() {
      rightSlots[rowIndex] = letter;
    });

    // Jika semua slot sudah terisi, evaluasi jawaban
    if (rightSlots.every((e) => e != null)) {
      _checkAnswer();
    }
  }

  /// Evaluasi jawaban; salah -> huruf merah; benar -> dialog success
  void _checkAnswer() {
    bool allCorrect = true;

    for (int i = 0; i < slotCount; i++) {
      if (rightSlots[i] != correctAnswers[i]) {
        tileColors[i] = redError;
        allCorrect = false;
      } else {
        tileColors[i] = blueTile;
      }
    }

    setState(() {});

    if (allCorrect) {
      _showCorrectDialog();
    } else {
      hearts = (hearts - 1).clamp(0, 4);
      _showWrongDialog();
    }
  }

  void _showCorrectDialog() {
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
                'YEAY CORRECT!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: navy,
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) => _generateNewLevel());
  }

  void _showWrongDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black26,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 26),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: redError,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close,
                      size: 80, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  'Please correct\nyour answer!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
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

  void _playSound(String key) {
    _player.play(AssetSource('sounds/$key.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final tileSize = size.width * 0.18; // kotak huruf lebih kecil dari versi sebelumnya
    final middleWidth = size.width * 0.22; // area 2 dot + garis

    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ================= HEADER HEARTS DALAM PILL =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: blueLight,
                  borderRadius: BorderRadius.circular(28),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  children: [
                    // hearts
                    for (int i = 0; i < 4; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(Icons.favorite,
                            color: redHeart, size: 24),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(Icons.favorite,
                          color: pinkHeart, size: 24),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.monetization_on,
                              size: 16, color: Colors.black87),
                          SizedBox(width: 4),
                          Text(
                            '13',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ================= ROW BACK + PROGRESS DASH =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: grayDot.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildProgressDash(active: true),
                        _buildProgressDash(active: true),
                        _buildProgressDash(active: true),
                        _buildProgressDash(active: true),
                        _buildProgressDash(active: false),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ================= LIST ROW DRAG & DROP =================
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                itemCount: slotCount,
                itemBuilder: (context, index) {
                  return _buildDragRow(
                    index: index,
                    tileSize: tileSize,
                    middleWidth: middleWidth,
                  );
                },
              ),
            ),

            // ================= NEXT BUTTON (BULAT BIRU GELAP) =================
            const SizedBox(height: 8),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: navy,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget dash progress (navy untuk aktif, abu untuk terakhir)
  Widget _buildProgressDash({required bool active}) {
    return Container(
      width: 40,
      height: 8,
      decoration: BoxDecoration(
        color: active ? navy : grayDot,
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }

  // Satu row: [kotak huruf] [dua dot + garis] [kotak sound]
  Widget _buildDragRow({
    required int index,
    required double tileSize,
    required double middleWidth,
  }) {
    final hasConnection = rightSlots[index] != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // DRAGGABLE HURUF
          Draggable<String>(
            data: leftLetters[index],
            feedback: _buildLetterTile(
              letter: leftLetters[index],
              size: tileSize,
              color: tileColors[index].withOpacity(0.8),
            ),
            childWhenDragging: _buildLetterTile(
              letter: leftLetters[index],
              size: tileSize,
              color: tileColors[index].withOpacity(0.4),
            ),
            child: _buildLetterTile(
              letter: leftLetters[index],
              size: tileSize,
              color: tileColors[index],
            ),
          ),

          const SizedBox(width: 28),

          // AREA 2 DOT KECIL + GARIS (DragTarget)
          SizedBox(
            width: middleWidth,
            height: 40,
            child: DragTarget<String>(
              onAccept: (value) => _handleDrop(index, value),
              builder: (context, candidateData, rejectedData) {
                return CustomPaint(
                  painter: DotLinePainter(
                    dotColor: grayDot,
                    showLine: hasConnection,
                  ),
                );
              },
            ),
          ),

          const Spacer(),

          // TOMBOL SOUND
          GestureDetector(
            onTap: () => _playSound(soundKeys[index]),
            child: Container(
              width: tileSize,
              height: tileSize,
              decoration: BoxDecoration(
                color: blueTile,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.volume_up,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Kotak huruf kiri
  Widget _buildLetterTile({
    required String letter,
    required double size,
    required Color color,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// ============================================================================
/// CustomPainter untuk dua dot kecil + garis horizontal di antaranya.
/// showLine = true -> garis ditampilkan (visualisasi "hasil drag").
/// ============================================================================
class DotLinePainter extends CustomPainter {
  final Color dotColor;
  final bool showLine;

  DotLinePainter({
    required this.dotColor,
    required this.showLine,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintDot = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final paintLine = Paint()
      ..color = dotColor.withOpacity(0.9)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double centerY = size.height / 2;
    final double radius = 6;

    final Offset left = Offset(size.width * 0.25, centerY);
    final Offset right = Offset(size.width * 0.75, centerY);

    if (showLine) {
      canvas.drawLine(left, right, paintLine);
    }

    canvas.drawCircle(left, radius, paintDot);
    canvas.drawCircle(right, radius, paintDot);
  }

  @override
  bool shouldRepaint(covariant DotLinePainter oldDelegate) {
    return oldDelegate.showLine != showLine ||
        oldDelegate.dotColor != dotColor;
  }
}
