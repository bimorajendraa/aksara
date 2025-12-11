import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

// SERVICES
import 'package:aksara/services/user_loader_service.dart';
import 'package:aksara/services/user_session.dart';
import 'package:aksara/services/game_progress_service.dart';
import 'package:aksara/services/level_progress_service.dart';

/// =============================================================
/// MODEL
/// =============================================================
class LetterNode {
  final String letter;
  final int id;
  LetterNode({required this.letter, required this.id});
}

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
/// LINE PAINTER
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
    final paintCorrect = Paint()
      ..color = const Color(0xFF3DBE78)
      ..strokeWidth = 5;

    final paintWrong = Paint()
      ..color = const Color(0xFFCC4C4C)
      ..strokeWidth = 5;

    final paintDrag = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 4;

    // FIXED LINES
    for (var c in lines) {
      final start = leftDots[c.leftIndex];
      final end = rightDots[c.rightIndex];
      if (start == Offset.zero || end == Offset.zero) continue;

      canvas.drawLine(start, end, c.isCorrect ? paintCorrect : paintWrong);
    }

    // DRAG PREVIEW
    if (draggingLeft != null && dragPos != null) {
      final start = leftDots[draggingLeft!];
      canvas.drawLine(start, dragPos!, paintDrag);
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
  final AudioPlayer _player = AudioPlayer();
  final rng = Random();

  int hearts = 5;
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

  @override
  void initState() {
    super.initState();
    _loadUser();
    generatePuzzle();
  }

  Future<void> _loadUser() async {
    await UserLoaderService.instance.loadUserId();
    print("🟦 [UserLoader] ID Loaded: ${UserSession.instance.idAkun}");
  }

  /// =============================================================
  /// GENERATE PUZZLE
  /// =============================================================
  void generatePuzzle() {
    print("=========================================");
    print("🔵 GENERATING NEW DRAGDROP PUZZLE...");
    print("=========================================");

    final alphabet = 'abcdefghijklmnopqrstuvwxyz'.split('');

    // Random unique 5 letters
    final letters = (alphabet..shuffle()).take(5).toList();

    leftNodes = List.generate(5, (i) => LetterNode(letter: letters[i], id: i));

    final shuffled = [...letters]..shuffle();
    rightNodes = List.generate(5, (i) => LetterNode(letter: shuffled[i], id: i));

    correctPairs.clear();
    for (int i = 0; i < 5; i++) {
      correctPairs[i] = shuffled.indexOf(leftNodes[i].letter);
    }

    print("🔤 LEFT  NODES: $letters");
    print("🔤 RIGHT NODES: $shuffled");
    print("🟢 CORRECT MAP: $correctPairs");

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
  /// VALIDATE → UPDATE SCORE & LEVEL
  /// =============================================================
  Future<void> validate() async {
    print("=========================================");
    print("🧪 VALIDATING RESULTS...");
    print("=========================================");

    if (isAllCorrect()) {
      print("🟢 ALL ANSWERS CORRECT → FINISH LEVEL!");

      setState(() => showSuccess = true);

      final id = UserSession.instance.idAkun;
      if (id != null) {
        await GameProgressService.instance.updateAggregatedProgress(
          idAkun: id,
          gameKey: "dragdrop",
          isCorrect: true,
        );

        final before = await LevelProgressService.instance.getCurrentLevel(id);
        final next = await LevelProgressService.instance.incrementLevel(id);

        print("🏆 LEVEL UP: $before → $next");
      }
    } else {
      print("🔴 WRONG — SHOW FAIL POPUP");
      setState(() {
        showFail = true;
        failFromHeart = false;
      });
    }
  }

  /// =============================================================
  /// DRAG LOGIC
  /// =============================================================
  void _onPointerDown(PointerDownEvent e) {
    for (int i = 0; i < leftDots.length; i++) {
      if ((leftDots[i] - e.position).distance <= hitRadius) {
        draggingLeft = i;
        dragPos = e.position;
        print("🟦 DRAG START on LEFT index $i");
        setState(() {});
        break;
      }
    }
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (draggingLeft != null) {
      dragPos = e.position;
      setState(() {});
    }
  }

  void _onPointerUp(PointerUpEvent e) async {
    if (draggingLeft == null) return;

    print("🟨 DRAG END");

    final leftIndex = draggingLeft!;
    draggingLeft = null;
    dragPos = null;

    int? target;
    double best = hitRadius;

    for (int i = 0; i < rightDots.length; i++) {
      final dist = (rightDots[i] - e.position).distance;

      if (dist < best) {
        best = dist;
        target = i;
      }
    }

    if (target != null) {
      final correct = correctPairs[leftIndex] == target;

      print("🔗 CONNECT LEFT $leftIndex → RIGHT $target");
      print("   ✔ CORRECT? $correct");

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
          print("❤️ HEART LOST → $hearts");

          if (hearts <= 0) {
            print("💀 HEART 0 → AUTO FAIL");
            showFail = true;
            failFromHeart = true;
          }
        }
      });
    }

    setState(() {});
  }

  /// =============================================================
  /// DOT WITH COLOR LOGIC
  /// =============================================================
  Widget _dot(bool isLeft, int index, void Function(Offset) save) {
    bool connected = false;
    bool correct = false;

    if (isLeft) {
      final match = lines.where((e) => e.leftIndex == index);
      if (match.isNotEmpty) {
        connected = true;
        correct = match.first.isCorrect;
      }
    } else {
      final match = lines.where((e) => e.rightIndex == index);
      if (match.isNotEmpty) {
        connected = true;
        correct = match.first.isCorrect;
      }
    }

    Color color = Colors.grey.shade400;
    if (connected) color = correct ? const Color(0xFF3DBE78) : const Color(0xFFCC4C4C);

    return Builder(
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final box = context.findRenderObject() as RenderBox?;
          if (box != null) save(box.localToGlobal(box.size.center(Offset.zero)));
        });

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        );
      },
    );
  }

  /// LEFT CELL
  Widget _leftCell(int i) {
    bool wrong = lines.any((c) => c.leftIndex == i && !c.isCorrect);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
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
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 14),
        _dot(true, i, (o) => leftDots[i] = o),
      ],
    );
  }

  /// RIGHT CELL WITH SOUND
  Widget _rightCell(int i) {
    bool wrong = lines.any((c) => c.rightIndex == i && !c.isCorrect);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(false, i, (o) => rightDots[i] = o),
        const SizedBox(width: 14),
        GestureDetector(
          onTap: () async {
            final letter = rightNodes[i].letter.toLowerCase();
            print("🔊 PLAY AUDIO: $letter");

            await _player.stop();
            await _player.play(
              AssetSource("sounds/alphabet/$letter.mp3"),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: wrong ? const Color(0xFFCC4C4C) : const Color(0xFF567C8D),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.volume_up, color: Colors.white, size: 32),
          ),
        ),
      ],
    );
  }

  /// HEADER UI
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
                i < hearts ? Icons.favorite : Icons.favorite_border_rounded,
                color: Colors.red,
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

  /// SUCCESS POPUP
  Widget _successPopup() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 90),
              const SizedBox(height: 10),
              const Text("YEAY CORRECT!", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("Next"),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// FAIL POPUP
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
        color: Colors.black54,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close, size: 90, color: Colors.red),
                SizedBox(height: 12),
                Text(
                  "Benarkan Jawaban Kamu!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// =============================================================
  /// MAIN UI
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
                    children: List.generate(5, _leftCell),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, _rightCell),
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
}
