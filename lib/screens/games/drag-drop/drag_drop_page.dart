import 'dart:math';
import 'package:flutter/material.dart';

/// =========================================================================
/// MODEL NODE HURUF (KIRI / KANAN)
/// =========================================================================
class LetterNode {
  final String letter;
  final int id;

  LetterNode({required this.letter, required this.id});
}

/// =========================================================================
/// MODEL GARIS PERMANEN (HASIL MATCHING)
/// =========================================================================
class Connection {
  final int leftIndex;   // index node kiri
  final int rightIndex;  // index node kanan
  final bool isCorrect;  // true = hijau, false = merah

  Connection({
    required this.leftIndex,
    required this.rightIndex,
    required this.isCorrect,
  });
}

/// =========================================================================
/// PAINTER UNTUK SEMUA GARIS (OVERLAY GLOBAL)
/// =========================================================================
class LinePainter extends CustomPainter {
  final List<Connection> lines;
  final List<Offset> leftDots;
  final List<Offset> rightDots;

  /// State garis yang sedang di-drag
  final int? draggingLeft;
  final Offset? dragPos;

  LinePainter({
    required this.lines,
    required this.leftDots,
    required this.rightDots,
    this.draggingLeft,
    this.dragPos,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gray = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final green = Paint()
      ..color = const Color(0xFF3DBE78)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final red = Paint()
      ..color = const Color(0xFFCC4C4C)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    // Garis fixed (hasil koneksi)
    for (var c in lines) {
      final start = leftDots[c.leftIndex];
      final end = rightDots[c.rightIndex];

      if (start == Offset.zero || end == Offset.zero) continue;

      final paint = c.isCorrect ? green : red;
      canvas.drawLine(start, end, paint);
      canvas.drawCircle(start, 6, paint);
      canvas.drawCircle(end, 6, paint);
    }

    // Garis saat drag (belum di-drop)
    if (draggingLeft != null && dragPos != null) {
      final start = leftDots[draggingLeft!];
      if (start != Offset.zero) {
        canvas.drawLine(start, dragPos!, gray);
        canvas.drawCircle(start, 6, gray);
        canvas.drawCircle(dragPos!, 6, gray);
      }
    }
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) => true;
}

/// =======================================================================
/// HALAMAN MAIN DRAG & DROP
/// =======================================================================
class DragDropPage extends StatefulWidget {
  const DragDropPage({super.key});
  @override
  State<DragDropPage> createState() => _DragDropPageState();
}

class _DragDropPageState extends State<DragDropPage> {
  final rng = Random();

  // STATE GAME
  int hearts = 5;
  int gold = 13;
  int subLevel = 1; // progress bar (step yang sudah dicapai)

  // NODE KIRI & KANAN
  List<LetterNode> leftNodes = [];
  List<LetterNode> rightNodes = [];

  // POSISI DOT (GLOBAL COORDINATES)
  List<Offset> leftDots = List.filled(5, Offset.zero);
  List<Offset> rightDots = List.filled(5, Offset.zero);

  // GARIS PERMANEN
  List<Connection> lines = [];

  // MAP LEFT INDEX -> RIGHT INDEX YANG BENAR
  Map<int, int> correctPairs = {};

  // STATE DRAGGING
  int? draggingLeft;   // index node kiri yang lagi di-drag
  Offset? dragPos;     // posisi jari saat ini (global)

  // POPUP STATE
  bool showSuccess = false;
  bool showFail = false;

  // ✅ jenis failure (heart habis atau cuma belum semua benar)
  bool failFromHeart = false;

  static const double _hitRadius = 30.0; // radius hit-test drop ke dot kanan

  @override
  void initState() {
    super.initState();
    generateNewPuzzle();
  }

  /// ======================================================================
  /// GENERATE RANDOM PUZZLE (26 huruf, 5 pasang per level)
  /// ======================================================================
  void generateNewPuzzle() {
    final alphabet = 'abcdefghijklmnopqrstuvwxyz'.split('');

    // 5 huruf random
    final letters = List<String>.generate(5, (_) => alphabet[rng.nextInt(26)]);

    leftNodes = List.generate(
      5,
      (i) => LetterNode(letter: letters[i], id: i),
    );

    // Shuffle untuk sisi kanan (urutan audio)
    final shuffled = [...letters]..shuffle();

    rightNodes = List.generate(
      5,
      (i) => LetterNode(letter: shuffled[i], id: i),
    );

    // Mapping jawaban benar: left index -> right index
    correctPairs.clear();
    for (int i = 0; i < 5; i++) {
      correctPairs[i] = shuffled.indexOf(leftNodes[i].letter);
    }

    // Reset garis & posisi dot
    lines.clear();
    leftDots = List.filled(5, Offset.zero);
    rightDots = List.filled(5, Offset.zero);

    draggingLeft = null;
    dragPos = null;

    setState(() {});
  }

  /// ======================================================================
  /// CEK SEMUA JAWABAN SUDAH BENAR BELUM
  /// ======================================================================
  bool isAllCorrect() {
    if (lines.length < 5) return false;
    return lines.every((e) => e.isCorrect);
  }

  void validate() {
    if (isAllCorrect()) {
      setState(() => showSuccess = true);
    } else {
      // gagal karena jawaban belum semua benar (bukan karena heart habis)
      setState(() {
        showFail = true;
        failFromHeart = false;
      });
    }
  }

  /// ======================================================================
  /// HANDLER GLOBAL POINTER (SUPAYA DRAG DARI DOT KIRI KE DOT KANAN)
  /// ======================================================================

  void _onPointerDown(PointerDownEvent event) {
    // Cari apakah jari mulai di dekat salah satu dot kiri
    for (int i = 0; i < leftDots.length; i++) {
      final dot = leftDots[i];
      if (dot == Offset.zero) continue;

      final dist = (dot - event.position).distance;
      if (dist <= _hitRadius) {
        setState(() {
          draggingLeft = i;
          dragPos = event.position;
        });
        break;
      }
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (draggingLeft != null) {
      setState(() {
        dragPos = event.position;
      });
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (draggingLeft == null) return;

    final int leftIndex = draggingLeft!;
    final Offset endPos = event.position;

    // Cari dot kanan yang paling dekat dengan posisi drop
    int? targetRight;
    double bestDist = _hitRadius;

    for (int i = 0; i < rightDots.length; i++) {
      final dot = rightDots[i];
      if (dot == Offset.zero) continue;

      final dist = (dot - endPos).distance;
      if (dist < bestDist) {
        bestDist = dist;
        targetRight = i;
      }
    }

    if (targetRight != null) {
      final bool isCorrect = correctPairs[leftIndex] == targetRight;

      setState(() {
        // Hilangkan koneksi lama dari leftIndex atau ke rightIndex ini
        lines.removeWhere((c) =>
            c.leftIndex == leftIndex || c.rightIndex == targetRight);

        // Tambah koneksi baru
        lines.add(Connection(
          leftIndex: leftIndex,
          rightIndex: targetRight!,
          isCorrect: isCorrect,
        ));

        // Kalau salah, kurangi nyawa (heart) dan clamp 0..5
        if (!isCorrect) {
          hearts = (hearts - 1).clamp(0, 5);

          // ✅ kalau heart habis, tandai gagal dari heart + munculkan popup
          if (hearts == 0) {
            showFail = true;
            failFromHeart = true;
          }
        }
      });
    }

    // Reset drag
    setState(() {
      draggingLeft = null;
      dragPos = null;
    });
  }

  /// ======================================================================
  /// BUILD
  /// ======================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Listener global supaya garis selalu dari dot kiri ke posisi jari
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        child: Stack(
          children: [
            _buildMain(),
            // Overlay semua garis (permanent + drag)
            IgnorePointer(
              child: CustomPaint(
                painter: LinePainter(
                  lines: lines,
                  leftDots: leftDots,
                  rightDots: rightDots,
                  draggingLeft: draggingLeft,
                  dragPos: dragPos,
                ),
                child: const SizedBox.expand(),
              ),
            ),
            if (showSuccess) _buildSuccess(),
            if (showFail) _buildFail(),
          ],
        ),
      ),
    );
  }

  /// ======================================================================
  /// UI UTAMA (HEADER + ROW HURUF/SUARA + TOMBOL NEXT)
  /// ======================================================================
  Widget _buildMain() {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildHeader(),
          const SizedBox(height: 10),
          _buildProgressBar(),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              children: [
                // Kolom kiri (huruf)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, _buildLeftRow),
                  ),
                ),
                // Kolom kanan (dot + sound)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, _buildRightRow),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: validate,
            child: Container(
              margin: const EdgeInsets.only(bottom: 40),
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFF2F4156),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 34,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ======================================================================
  /// ROW KIRI (KOTAK HURUF + DOT START)
  /// ======================================================================
  Widget _buildLeftRow(int i) {
    // Kalau ada connection salah untuk leftIndex ini -> kotak merah
    final wrong = lines.any((c) => c.leftIndex == i && !c.isCorrect);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Letter box
        Container(
          width: 80,
          height: 80,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: wrong ? const Color(0xFFCC4C4C) : const Color(0xFF567C8D),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            leftNodes[i].letter,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 38,
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Dot kiri (start drag) – posisi dicatat untuk LinePainter & hit-test
        _dot((o) => leftDots[i] = o),
      ],
    );
  }

  /// ======================================================================
  /// ROW KANAN (DOT END + TOMBOL SOUND)
  /// ======================================================================
  Widget _buildRightRow(int i) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Dot kanan (target drop) – posisi dicatat
        _dot((o) => rightDots[i] = o),
        const SizedBox(width: 14),
        // Tombol sound (sekarang masih dummy icon)
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF567C8D),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.volume_up,
            color: Colors.white,
            size: 32,
          ),
        ),
      ],
    );
  }

  /// ======================================================================
  /// DOT WIDGET (KIRI / KANAN)
  /// - Hanya menggambar lingkaran abu-abu
  /// - Menyimpan posisi global center lewat callback [onPos]
  /// ======================================================================
  Widget _dot(void Function(Offset) onPos) {
    return Builder(
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final box = context.findRenderObject() as RenderBox?;
          if (box != null) {
            onPos(box.localToGlobal(box.size.center(Offset.zero)));
          }
        });
        return Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  /// ======================================================================
  /// HEADER (HEARTS + GOLD)
  /// ======================================================================
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFC8D9E6),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          // Hearts: penuh merah, heart yang hilang jadi pink
          ...List.generate(
            5,
            (i) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.favorite,
                color: i < hearts
                    ? const Color(0xFFCC4C4C)
                    : const Color(0xFFD99B9B),
                size: 26,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.monetization_on,
                  size: 18,
                  color: Colors.black87,
                ),
                const SizedBox(width: 4),
                Text(
                  gold.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ======================================================================
  /// PROGRESS BAR (6 STEP) – CURRENT PROGRESS = subLevel
  /// ======================================================================
  Widget _buildProgressBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        6,
        (i) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 40,
          height: 8,
          decoration: BoxDecoration(
            color: i < subLevel
                ? const Color(0xFF2F4156)
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  /// ======================================================================
  /// POPUP SUCCESS
  /// ======================================================================
  Widget _buildSuccess() {
    return Container(
      color: Colors.black.withOpacity(0.35),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                size: 90,
                color: Color(0xFF2F4156),
              ),
              const SizedBox(height: 10),
              const Text(
                "YEAY CORRECT!",
                style: TextStyle(
                  fontSize: 26,
                  color: Color(0xFF2F4156),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showSuccess = false;
                    subLevel = (subLevel + 1).clamp(0, 6);
                    generateNewPuzzle();
                  });
                },
                child: const Text("Next"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ======================================================================
  /// POPUP FAIL
  /// ======================================================================
  Widget _buildFail() {
    return GestureDetector(
      onTap: () {
        setState(() {
          showFail = false;

          // Fail and soft reset if health < 1
          if (failFromHeart) {
            hearts = 5;
            generateNewPuzzle();
            failFromHeart = false;
          }
        });
      },
      child: Container(
        color: Colors.black.withOpacity(0.35),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(30),
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.close,
                  size: 90,
                  color: Color(0xFFCC4C4C),
                ),
                SizedBox(height: 12),
                Text(
                  "Benarkan Jawaban Kamu!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    color: Color(0xFFCC4C4C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
