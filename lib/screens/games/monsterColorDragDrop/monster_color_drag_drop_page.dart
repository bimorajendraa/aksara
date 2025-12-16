import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';

// SERVICES
import 'package:aksara/services/user_loader_service.dart';
import 'package:aksara/services/user_session.dart';
import 'package:aksara/services/game_progress_service.dart';
import 'package:aksara/services/level_progress_service.dart';

/// ===============================================================
/// MODEL
/// ===============================================================
class MonsterNode {
  final String color;
  final String asset;
  MonsterNode({required this.color, required this.asset});
}

class MatchConnection {
  final int leftIndex;
  final int rightIndex;
  final bool isCorrect;

  MatchConnection({
    required this.leftIndex,
    required this.rightIndex,
    required this.isCorrect,
  });
}

/// ===============================================================
/// LINE PAINTER
/// ===============================================================
class MonsterLinePainter extends CustomPainter {
  final List<MatchConnection> lines;
  final List<Offset> leftDots;
  final List<Offset> rightDots;
  final int? draggingLeft;
  final Offset? dragPos;

  MonsterLinePainter({
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

    for (var c in lines) {
      final start = leftDots[c.leftIndex];
      final end = rightDots[c.rightIndex];
      if (start == Offset.zero || end == Offset.zero) continue;

      canvas.drawLine(start, end, c.isCorrect ? paintCorrect : paintWrong);
    }

    if (draggingLeft != null && dragPos != null) {
      final start = leftDots[draggingLeft!];
      canvas.drawLine(start, dragPos!, paintDrag);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// ===============================================================
/// MAIN PAGE
/// ===============================================================
class MonsterColorMatchPage extends StatefulWidget {
  const MonsterColorMatchPage({super.key});

  @override
  State<MonsterColorMatchPage> createState() => _MonsterColorMatchPageState();
}

class _MonsterColorMatchPageState extends State<MonsterColorMatchPage> {
  final AudioPlayer _player = AudioPlayer();

  int hearts = 5;

  List<MonsterNode> leftMonsters = [];
  List<String> rightColors = [];

  List<Offset> leftDots = List.filled(8, Offset.zero);
  List<Offset> rightDots = List.filled(8, Offset.zero);

  List<MatchConnection> lines = [];
  Map<int, int> correctMap = {};

  int? draggingLeft;
  Offset? dragPos;

  bool showSuccess = false;
  bool showFail = false;
  bool failFromHeart = false;

  static const double hitRadius = 32;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _generatePuzzle();
  }

  Future<void> _loadUser() async {
    await UserLoaderService.instance.loadUserId();
    print("🟦 Loaded user id = ${UserSession.instance.idAkun}");
  }

  /// ===============================================================
  /// GENERATE RANDOM PUZZLE
  /// ===============================================================
  void _generatePuzzle() {
    final allColors = [
      "RED",
      "BLUE",
      "PURPLE",
      "BLACK",
      "YELLOW",
      "GREEN",
      "PINK"
    ];

    // ambil 4 warna random unik
    allColors.shuffle();
    final colors = allColors.take(4).toList();

    leftMonsters = colors.map((c) {
      final asset = "assets/images/${c.toLowerCase()}_monster.svg";
      return MonsterNode(color: c, asset: asset);
    }).toList();

    rightColors = [...colors]..shuffle();

    // rebuild mapping
    correctMap.clear();
    for (int i = 0; i < colors.length; i++) {
      correctMap[i] = rightColors.indexOf(leftMonsters[i].color);
    }

    leftMonsters = colors.map((c) {
      final asset = "assets/images/${c.toLowerCase()}_monster.svg";
      return MonsterNode(color: c, asset: asset);
    }).toList();

    rightColors = [...colors]..shuffle();

    correctMap.clear();
    for (int i = 0; i < colors.length; i++) {
      correctMap[i] = rightColors.indexOf(leftMonsters[i].color);
    }

    lines.clear();
    leftDots = List.filled(colors.length, Offset.zero);
    rightDots = List.filled(colors.length, Offset.zero);

    draggingLeft = null;
    dragPos = null;

    setState(() {});
  }

  bool _isAllCorrect() {
    return lines.length == leftMonsters.length &&
        lines.every((e) => e.isCorrect);
  }

  /// ===============================================================
  /// VALIDATE
  /// ===============================================================
  Future<void> _validate() async {
    if (_isAllCorrect()) {
      setState(() => showSuccess = true);

      final id = UserSession.instance.idAkun;
      if (id != null) {
        await GameProgressService.instance.updateAggregatedProgress(
          idAkun: id,
          gameKey: "monster_color_match",
          isCorrect: true,
        );

        final before = await LevelProgressService.instance.getCurrentLevel(id);
        final next = await LevelProgressService.instance.incrementLevel(id);
        print("🟢 LEVEL UP: $before → $next");
      }
    } else {
      setState(() {
        showFail = true;
        failFromHeart = false;
      });
    }
  }

  /// ===============================================================
  /// DRAG HANDLING
  /// ===============================================================
  void _onDown(PointerDownEvent e) {
    for (int i = 0; i < leftDots.length; i++) {
      if ((leftDots[i] - e.position).distance <= hitRadius) {
        draggingLeft = i;
        dragPos = e.position;
        setState(() {});
        break;
      }
    }
  }

  void _onMove(PointerMoveEvent e) {
    if (draggingLeft != null) {
      dragPos = e.position;
      setState(() {});
    }
  }

  void _onUp(PointerUpEvent e) {
    if (draggingLeft == null) return;

    final leftIndex = draggingLeft!;
    draggingLeft = null;

    int? target;
    double best = hitRadius;

    for (int i = 0; i < rightDots.length; i++) {
      final d = (rightDots[i] - e.position).distance;
      if (d < best) {
        best = d;
        target = i;
      }
    }

    if (target != null) {
      final correct = correctMap[leftIndex] == target;

      setState(() {
        lines.removeWhere((c) =>
            c.leftIndex == leftIndex || c.rightIndex == target);

        lines.add(MatchConnection(
          leftIndex: leftIndex,
          rightIndex: target!,
          isCorrect: correct,
        ));

        if (!correct) {
          hearts--;
          if (hearts <= 0) {
            failFromHeart = true;
            showFail = true;
          }
        }
      });
    }

    dragPos = null;
    setState(() {});
  }

  /// ===============================================================
  /// DOT UI
  /// ===============================================================
  Widget _dot(bool left, int i, void Function(Offset) savePos) {
    bool connected = false;
    bool correct = false;

    final matches = left
        ? lines.where((c) => c.leftIndex == i)
        : lines.where((c) => c.rightIndex == i);

    if (matches.isNotEmpty) {
      connected = true;
      correct = matches.first.isCorrect;
    }

    Color base = Colors.grey.shade400;
    if (connected) base = correct ? Colors.green : Colors.red;

    return Builder(builder: (ctx) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final box = ctx.findRenderObject() as RenderBox?;
        if (box != null) {
          savePos(box.localToGlobal(box.size.center(Offset.zero)));
        }
      });

      return SizedBox(
        width: 24,
        height: 24,
        child: Container(
          decoration: BoxDecoration(
            color: base,
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }

  /// ===============================================================
  /// POPUPS
  /// ===============================================================
  Widget _successPopup() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 90),
              const SizedBox(height: 14),
              const Text("Correct!", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
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

  Widget _failPopup() {
    return GestureDetector(
      onTap: () {
        setState(() {
          showFail = false;

          if (failFromHeart) {
            hearts = 5;
            failFromHeart = false;
            _generatePuzzle();
          }
        });
      },
      child: Container(
        color: Colors.black38,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.close, size: 90, color: Colors.red),
                SizedBox(height: 12),
                Text("Try again!", style: TextStyle(fontSize: 22, color: Colors.red, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ===============================================================
  /// UI
  /// ===============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFEA),
      body: Listener(
        onPointerDown: _onDown,
        onPointerMove: _onMove,
        onPointerUp: _onUp,
        child: Stack(
          children: [
            SafeArea(child: _mainUI()),
            IgnorePointer(
              child: CustomPaint(
                painter: MonsterLinePainter(
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

  Widget _mainUI() {
    return Column(
      children: [
        const SizedBox(height: 16),
        _header(),
        const SizedBox(height: 16),

        const Text(
          "What the Monster Color ?",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 20),

        Expanded(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leftMonsters.length,
            itemBuilder: (context, i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _monsterImage(leftMonsters[i]),
                    const SizedBox(width: 18),
                    _dot(true, i, (o) => leftDots[i] = o),
                    const SizedBox(width: 80),
                    _dot(false, i, (o) => rightDots[i] = o),
                    const SizedBox(width: 18),
                    Text(
                      rightColors[i],
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _colorFor(rightColors[i]),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        GestureDetector(
          onTap: _validate,
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
    );
  }

  Widget _monsterImage(MonsterNode m) {
    final isSvg = m.asset.endsWith(".svg");

    return Container(
      width: 120,
      height: 120,
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 120,
          height: 120,
          child: isSvg
              ? SvgPicture.asset(
                  m.asset,
                  fit: BoxFit.contain,
                )
              : Image.asset(
                  m.asset,
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }


  Color _colorFor(String txt) {
    switch (txt) {
      case "RED":
        return Colors.red;
      case "BLUE":
        return Colors.blue;
      case "PURPLE":
        return Colors.purple;
      case "BLACK":
        return Colors.black87;
      case "YELLOW":
        return Colors.amber.shade700;
      case "GREEN":
        return Colors.green.shade700;
      case "PINK":
        return Colors.pink;
      default:
        return Colors.black;
    }
  }

  Widget _header() {
    return Row(
      children: [
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey,
            child: Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
        const Spacer(),
        Row(
          children: List.generate(
            5,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Icon(
                i < hearts
                    ? Icons.favorite
                    : Icons.favorite_border_rounded,
                color: Colors.red,
                size: 26,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}
