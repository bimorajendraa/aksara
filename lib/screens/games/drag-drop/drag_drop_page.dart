import 'dart:math';
import 'package:flutter/material.dart';

// SERVICES
import 'package:aksara/services/user_loader_service.dart';
import 'package:aksara/services/user_session.dart';
import 'package:aksara/services/game_progress_service.dart';
import 'package:aksara/services/level_progress_service.dart';

/// =============================================================
/// MODEL NODE HURUF
/// =============================================================
class LetterNode {
  final String letter;
  final int id;

  LetterNode({required this.letter, required this.id});
}

/// =============================================================
/// MODEL CONNECTION
/// =============================================================
class Connection {
  final int leftIndex;
  final int rightIndex;
  final bool isCorrect;

  Connection({
    required this.leftIndex,
    required this.rightIndex,
    required this.isCorrect,
  });
}

/// =============================================================
/// PAINTER GARIS
/// =============================================================
class LinePainter extends CustomPainter {
  final List<Connection> lines;
  final List<Offset> leftDots;
  final List<Offset> rightDots;
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
      ..strokeWidth = 4;

    final green = Paint()
      ..color = const Color(0xFF3DBE78)
      ..strokeWidth = 5;

    final red = Paint()
      ..color = const Color(0xFFCC4C4C)
      ..strokeWidth = 5;

    // Fixed lines
    for (var c in lines) {
      final start = leftDots[c.leftIndex];
      final end = rightDots[c.rightIndex];
      if (start == Offset.zero || end == Offset.zero) continue;
      canvas.drawLine(start, end, c.isCorrect ? green : red);
    }

    // Drag line
    if (draggingLeft != null && dragPos != null) {
      final start = leftDots[draggingLeft!];
      canvas.drawLine(start, dragPos!, gray);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// =============================================================
/// DRAGDROP PAGE
/// =============================================================
class DragDropPage extends StatefulWidget {
  const DragDropPage({super.key});

  @override
  State<DragDropPage> createState() => _DragDropPageState();
}

class _DragDropPageState extends State<DragDropPage> {
  final rng = Random();

  int hearts = 100;
  int gold = 13;

  List<LetterNode> leftNodes = [];
  List<LetterNode> rightNodes = [];

  List<Offset> leftDots = List.filled(5, Offset.zero);
  List<Offset> rightDots = List.filled(5, Offset.zero);

  List<Connection> lines = [];
  Map<int, int> correctPairs = {};

  int? draggingLeft;
  Offset? dragPos;

  bool showSuccess = false;
  bool showFail = false;
  bool failFromHeart = false;

  static const double hitRadius = 30;

  // =============================================================
  // INIT
  // =============================================================
  @override
  void initState() {
    super.initState();
    _loadUser();
    generatePuzzle();
  }

  Future<void> _loadUser() async {
    await UserLoaderService.instance.loadUserId();
  }

  /// =============================================================
  /// GENERATE PUZZLE
  /// =============================================================
  void generatePuzzle() {
    final alphabet = 'abcdefghijklmnopqrstuvwxyz'.split('');
    final letters =
        List<String>.generate(5, (_) => alphabet[rng.nextInt(26)]);

    leftNodes = List.generate(
      5,
      (i) => LetterNode(letter: letters[i], id: i),
    );

    final shuffled = [...letters]..shuffle();
    rightNodes = List.generate(
      5,
      (i) => LetterNode(letter: shuffled[i], id: i),
    );

    correctPairs.clear();
    for (int i = 0; i < 5; i++) {
      correctPairs[i] = shuffled.indexOf(leftNodes[i].letter);
    }

    lines.clear();
    leftDots = List.filled(5, Offset.zero);
    rightDots = List.filled(5, Offset.zero);

    draggingLeft = null;
    dragPos = null;

    setState(() {});
  }

  /// =============================================================
  /// CHECK ALL CORRECT
  /// =============================================================
  bool isAllCorrect() {
    return lines.length == 5 && lines.every((e) => e.isCorrect);
  }

  /// =============================================================
  /// VALIDATE
  /// =============================================================
  Future<void> validate() async {
    if (isAllCorrect()) {
      setState(() => showSuccess = true);

      final idAkun = UserSession.instance.idAkun;
      if (idAkun != null) {

        // 1. Tambah score aggregated
        await GameProgressService.instance.updateAggregatedProgress(
          idAkun: idAkun,
          gameKey: "dragdrop",
          isCorrect: true,
        );

        // 2. Ambil level sekarang
        final currentLevel =
            await LevelProgressService.instance.getCurrentLevel(idAkun);

        print("🔵 [DragDrop] User current level = $currentLevel");

        // 3. Naikkan level
        final nextLevel =
            await LevelProgressService.instance.incrementLevel(idAkun);

        print("🟢 [DragDrop] Level naik → $currentLevel → $nextLevel");
      }

    } else {
      setState(() {
        showFail = true;
        failFromHeart = false;
      });
    }
  }


  /// =============================================================
  /// POINTER DOWN
  /// =============================================================
  void _onPointerDown(PointerDownEvent e) {
    for (int i = 0; i < leftDots.length; i++) {
      if ((leftDots[i] - e.position).distance <= hitRadius) {
        draggingLeft = i;
        dragPos = e.position;
        setState(() {});
        break;
      }
    }
  }

  /// =============================================================
  /// POINTER MOVE
  /// =============================================================
  void _onPointerMove(PointerMoveEvent e) {
    if (draggingLeft != null) {
      dragPos = e.position;
      setState(() {});
    }
  }

  /// =============================================================
  /// POINTER UP
  /// =============================================================
  void _onPointerUp(PointerUpEvent e) async {
    if (draggingLeft == null) return;

    final leftIndex = draggingLeft!;
    draggingLeft = null;
    dragPos = null;

    int? target;
    double best = hitRadius;

    for (int i = 0; i < rightDots.length; i++) {
      double dist = (rightDots[i] - e.position).distance;
      if (dist < best) {
        best = dist;
        target = i;
      }
    }

    if (target != null) {
      final correct = correctPairs[leftIndex] == target;

      setState(() {
        lines.removeWhere(
          (c) => c.leftIndex == leftIndex || c.rightIndex == target,
        );

        lines.add(Connection(
          leftIndex: leftIndex,
          rightIndex: target!,
          isCorrect: correct,
        ));

        if (!correct) {
          hearts--;
          if (hearts <= 0) {
            showFail = true;
            failFromHeart = true;
          }
        }
      });

      final idAkun = UserSession.instance.idAkun;
      if (idAkun != null) {
        await GameProgressService.instance.updateAggregatedProgress(
          idAkun: idAkun,
          gameKey: "dragdrop",
          isCorrect: correct,
        );
      }
    }

    setState(() {});
  }

  /// =============================================================
  /// BUILD UI (NO UI CHANGES)
  /// =============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        child: Stack(
          children: [
            _buildMain(),

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

            if (showSuccess) _successPopup(),
            if (showFail) _failPopup(),
          ],
        ),
      ),
    );
  }

  /// =============================================================
  /// UI COMPONENTS (UNCHANGED)
  /// =============================================================
  Widget _buildMain() {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 8),
          _header(),
          const SizedBox(height: 10),

          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, _leftRow),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, _rightRow),
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
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _leftRow(int i) {
    final wrong =
        lines.any((c) => c.leftIndex == i && !c.isCorrect);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: wrong ? const Color(0xFFCC4C4C) : const Color(0xFF567C8D),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            leftNodes[i].letter.toUpperCase(),
            style: const TextStyle(
              fontSize: 38,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 14),
        _dot((o) => leftDots[i] = o),
      ],
    );
  }

  Widget _rightRow(int i) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot((o) => rightDots[i] = o),
        const SizedBox(width: 14),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF567C8D),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.volume_up,
              color: Colors.white, size: 32),
        ),
      ],
    );
  }

  Widget _dot(void Function(Offset) save) {
    return Builder(builder: (context) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          save(box.localToGlobal(box.size.center(Offset.zero)));
        }
      });

      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade400,
        ),
      );
    });
  }

  Widget _header() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFC8D9E6),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          ...List.generate(
            5,
            (i) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.favorite,
                color:
                    i < hearts ? const Color(0xFFCC4C4C) : const Color(0xFFD99B9B),
                size: 26,
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.black87),
              const SizedBox(width: 6),
              Text("$gold"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _successPopup() {
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
              const Icon(Icons.check_circle,
                  size: 90, color: Color(0xFF2F4156)),
              const SizedBox(height: 10),
              const Text(
                "YEAY CORRECT!",
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F4156)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);       // tutup popup
                  Navigator.pop(context); 
                },
                child: const Text("Next"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _failPopup() {
    return GestureDetector(
      onTap: () {
        setState(() {
          showFail = false;
          if (failFromHeart) {
            hearts = 5;
            failFromHeart = false;
            generatePuzzle();
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
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close,
                    size: 90, color: Color(0xFFCC4C4C)),
                SizedBox(height: 12),
                Text(
                  "Benarkan Jawaban Kamu!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFCC4C4C),
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
