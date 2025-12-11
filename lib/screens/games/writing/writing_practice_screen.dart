// lib/screens/writing_practice_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:aksara/screens/home/home_screen.dart';

// SUPABASE SERVICES
import 'package:aksara/services/user_loader_service.dart';
import 'package:aksara/services/user_session.dart';
import 'package:aksara/services/game_progress_service.dart';
import 'package:aksara/services/level_progress_service.dart';

class WritingPracticeScreen extends StatelessWidget {
  const WritingPracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnitListPage();
  }
}

///////////////////////////////////////////////////////////////////////////////
/// PAGEVIEW OF UNITS
///////////////////////////////////////////////////////////////////////////////

class UnitListPage extends StatefulWidget {
  const UnitListPage({super.key});

  @override
  State<UnitListPage> createState() => _UnitListPageState();
}

class _UnitListPageState extends State<UnitListPage> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    if (UserSession.instance.idAkun == null) {
      await UserLoaderService.instance.loadUserId();
    }
    print("🟦 [WritingPractice] Loaded user id = ${UserSession.instance.idAkun}");
  }

  final List<String> _alphabet = [
    'A','a','B','b','C','c','D','d','E','e','F','f','G','g',
    'H','h','I','i','J','j','K','k','L','l','M','m','N','n',
    'O','o','P','p','Q','q','R','r','S','s','T','t','U','u',
    'V','v','W','w','X','x','Y','y','Z','z'
  ];

  List<List<String>> _makeUnits() {
    final out = <List<String>>[];
    for (int i = 0; i < _alphabet.length; i += 6) {
      out.add(_alphabet.sublist(i, min(i + 6, _alphabet.length)));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final units = _makeUnits();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F8),
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- TOP BAR ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                      );
                    },
                    child: const Icon(Icons.arrow_back, size: 30),
                  ),
                  const SizedBox(width: 12),
                  const HeartRow(hearts: 5),
                  const Spacer(),
                  PageIndicatorDots(total: units.length, current: _pageIndex),
                ],
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: units.length,
                onPageChanged: (i) => setState(() => _pageIndex = i),
                itemBuilder: (_, index) {
                  final letters = units[index];
                  final isLastUnit = index == units.length - 1;

                  return UnitPage(
                    key: ValueKey("unit_$index"),
                    letters: letters,
                    isLastUnit: isLastUnit,
                    onFinish: () => _handleFinish(context),
                    onPrevUnit: () {
                      if (index > 0) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    onNextUnit: () {
                      if (index < units.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // FINISH CHECK — Supabase Integration HERE
  // =============================================================
  void _handleFinish(BuildContext context) async {
    bool allDone = LetterCanvasTracker.allCompleted;

    if (!allDone) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Incomplete"),
          content: Text("Please fully fill all letters until they turn yellow."),
        ),
      );
      return;
    }

    // --------------------- SUPABASE INTEGRATION ------------------------
    final idAkun = UserSession.instance.idAkun;

    if (idAkun != null) {
      print("🟦 [WritingPractice] Updating aggregated progress...");

      await GameProgressService.instance.updateAggregatedProgress(
        idAkun: idAkun,
        gameKey: "writing_practice",
        isCorrect: true,
      );

      final before = await LevelProgressService.instance.getCurrentLevel(idAkun);
      final next = await LevelProgressService.instance.incrementLevel(idAkun);

      print("🟢 LEVEL UP → $before → $next");
    } else {
      print("❌ User ID NULL, skipping updates...");
    }

    // --------------------- SUCCESS POPUP ------------------------
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Great Job!"),
        content: const Text("You completed all writing practice!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
            child: const Text("Back to Home"),
          )
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
/// COMPLETION TRACKER — CHECKS if all letters filled
///////////////////////////////////////////////////////////////////////////////

class LetterCanvasTracker {
  static final Map<String, bool> _completion = {};

  static void markFilled(String letter) {
    _completion[letter] = true;
  }

  static void markNotFilled(String letter) {
    _completion[letter] = false;
  }

  static bool get allCompleted =>
      _completion.isNotEmpty && _completion.values.every((v) => v == true);
}

///////////////////////////////////////////////////////////////////////////////
/// SMALL UI COMPONENTS
///////////////////////////////////////////////////////////////////////////////

class HeartRow extends StatelessWidget {
  final int hearts;
  const HeartRow({super.key, required this.hearts});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        hearts,
        (_) => const Padding(
          padding: EdgeInsets.only(right: 4),
          child: Icon(Icons.favorite, size: 18, color: Colors.redAccent),
        ),
      ),
    );
  }
}

class PageIndicatorDots extends StatelessWidget {
  final int total;
  final int current;

  const PageIndicatorDots({
    super.key,
    required this.total,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i == current;
        return Container(
          width: active ? 18 : 12,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: active ? Colors.blueGrey[900] : Colors.grey[300],
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
/// UNIT PAGE + FINISH BUTTON SUPPORT
///////////////////////////////////////////////////////////////////////////////

class UnitPage extends StatefulWidget {
  final List<String> letters;
  final bool isLastUnit;
  final VoidCallback onPrevUnit;
  final VoidCallback onNextUnit;
  final VoidCallback onFinish;

  const UnitPage({
    super.key,
    required this.letters,
    required this.onPrevUnit,
    required this.onNextUnit,
    required this.isLastUnit,
    required this.onFinish,
  });

  @override
  State<UnitPage> createState() => _UnitPageState();
}

class _UnitPageState extends State<UnitPage> {
  static const int rowsPerSection = 3;
  int currentSection = 0;
  final ValueNotifier<bool> pencilMode = ValueNotifier(true);

  late final List<List<String>> rows;
  late final List<LetterRowWidget> rowWidgets;

  @override
  void initState() {
    super.initState();

    rows = [];
    for (int i = 0; i < widget.letters.length; i += 2) {
      final second = (i + 1) < widget.letters.length ? widget.letters[i + 1] : '';
      rows.add([widget.letters[i], second]);
    }

    rowWidgets = rows.map((pair) {
      return LetterRowWidget(
        key: ValueKey("row_${pair[0]}_${pair[1]}"),
        uppercase: pair[0],
        lowercase: pair[1],
        pencilModeNotifier: pencilMode,
      );
    }).toList();
  }

  int get totalSections => (rows.length / rowsPerSection).ceil();

  void _nextSection() {
    if (currentSection < totalSections - 1) {
      setState(() => currentSection++);
    } else {
      widget.onNextUnit();
    }
  }

  void _prevSection() {
    if (currentSection > 0) {
      setState(() => currentSection--);
    } else {
      widget.onPrevUnit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleCount = min(rows.length, (currentSection + 1) * rowsPerSection);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F8),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 8),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 140),
                    children: [
                      for (int i = 0; i < rowWidgets.length; i++)
                        Offstage(
                          offstage: i >= visibleCount,
                          child: rowWidgets[i],
                        ),
                    ],
                  ),
                ),
              ],
            ),

            Positioned(
              right: 10,
              top: 120,
              child: Column(
                children: [
                  ToolButton(
                    icon: Icons.edit,
                    active: true,
                    onTap: () => pencilMode.value = true,
                  ),
                  const SizedBox(height: 10),
                  ToolButton(
                    icon: Icons.backspace,
                    active: true,
                    onTap: () => pencilMode.value = false,
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 26,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _navBtn(Icons.arrow_back, _prevSection),
                  const SizedBox(width: 22),

                  widget.isLastUnit
                      ? _finishBtn()
                      : _navBtn(Icons.arrow_forward, _nextSection),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFF2F3A4A),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 36),
      ),
    );
  }

  Widget _finishBtn() {
    return GestureDetector(
      onTap: widget.onFinish,
      child: Container(
        width: 110,
        height: 72,
        decoration: BoxDecoration(
          color: Colors.green.shade700,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6),
          ],
        ),
        child: const Center(
          child: Text(
            "FINISH",
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
/// TOOL BUTTON
///////////////////////////////////////////////////////////////////////////////

class ToolButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const ToolButton({
    super.key,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (active)
              BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6),
          ],
        ),
        child: Icon(icon, color: Colors.blueGrey[900]),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
/// LETTER ROW
///////////////////////////////////////////////////////////////////////////////

class LetterRowWidget extends StatelessWidget {
  final String uppercase;
  final String lowercase;
  final ValueNotifier<bool> pencilModeNotifier;

  const LetterRowWidget({
    super.key,
    required this.uppercase,
    required this.lowercase,
    required this.pencilModeNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      margin: const EdgeInsets.only(bottom: 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _canvasBox(uppercase)),
              const SizedBox(width: 18),
              Expanded(child: _canvasBox(lowercase)),
            ],
          ),
          const SizedBox(height: 10),
          Container(height: 2, color: Colors.black.withOpacity(0.28)),
        ],
      ),
    );
  }

  Widget _canvasBox(String letter) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4),
        ],
      ),
      child: ClipRect(
        child: LetterCanvas(
          key: ValueKey("canvas_$letter"),
          letter: letter,
          pencilModeNotifier: pencilModeNotifier,
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
/// LETTER CANVAS — REPORTS COMPLETION WHEN "filled == true"
///////////////////////////////////////////////////////////////////////////////

class LetterCanvas extends StatefulWidget {
  final String letter;
  final ValueNotifier<bool> pencilModeNotifier;

  const LetterCanvas({
    super.key,
    required this.letter,
    required this.pencilModeNotifier,
  });

  @override
  State<LetterCanvas> createState() => _LetterCanvasState();
}

class _LetterCanvasState extends State<LetterCanvas>
    with AutomaticKeepAliveClientMixin {
  final List<List<Offset>> strokes = [];
  bool filled = false;

  static const double fillThreshold = 150.0;
  static const double eraseRadius = 22.0;

  @override
  void initState() {
    super.initState();
    widget.pencilModeNotifier.addListener(_toolChanged);

    LetterCanvasTracker.markNotFilled(widget.letter);
  }

  @override
  void dispose() {
    widget.pencilModeNotifier.removeListener(_toolChanged);
    super.dispose();
  }

  void _toolChanged() {
    if (mounted) setState(() {});
  }

  void _updateCompletionFlag() {
    if (filled) {
      LetterCanvasTracker.markFilled(widget.letter);
    } else {
      LetterCanvasTracker.markNotFilled(widget.letter);
    }
  }

  double _strokeLen() {
    double len = 0;
    for (final s in strokes) {
      for (int i = 1; i < s.length; i++) {
        len += (s[i] - s[i - 1]).distance;
      }
    }
    return len;
  }

  void _start(Offset p) {
    strokes.add([p]);
    _updateCompletionFlag();
    setState(() {});
  }

  void _update(Offset p) {
    if (strokes.isEmpty) return;

    final size = context.size;
    final clamped = size == null
        ? p
        : Offset(
            p.dx.clamp(0.0, size.width),
            p.dy.clamp(0.0, size.height),
          );

    strokes.last.add(clamped);

    if (_strokeLen() > fillThreshold) {
      filled = true;
    }

    _updateCompletionFlag();
    setState(() {});
  }

  void _erase(Offset p) {
    final newList = <List<Offset>>[];

    for (final s in strokes) {
      final kept = s.where((pt) => (pt - p).distance > eraseRadius).toList();
      if (kept.isNotEmpty) newList.add(kept);
    }

    strokes
      ..clear()
      ..addAll(newList);

    filled = _strokeLen() > fillThreshold;

    _updateCompletionFlag();
    setState(() {});
  }

  void _clear() {
    strokes.clear();
    filled = false;

    _updateCompletionFlag();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isPencil = widget.pencilModeNotifier.value;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (d) {
        if (isPencil) {
          _start(d.localPosition);
        } else {
          _erase(d.localPosition);
        }
      },
      onPanUpdate: (d) {
        if (isPencil) {
          _update(d.localPosition);
        } else {
          _erase(d.localPosition);
        }
      },
      onDoubleTap: _clear,
      child: CustomPaint(
        painter: _LetterPainter(
          letter: widget.letter,
          strokes: strokes,
          filled: filled,
        ),
        size: Size.infinite,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

///////////////////////////////////////////////////////////////////////////////
/// PAINTER
///////////////////////////////////////////////////////////////////////////////

class _LetterPainter extends CustomPainter {
  final String letter;
  final List<List<Offset>> strokes;
  final bool filled;

  _LetterPainter({
    required this.letter,
    required this.strokes,
    required this.filled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final base = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontSize: 100,
          fontWeight: FontWeight.w700,
          color: Colors.grey.withOpacity(0.28),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    base.layout();
    base.paint(canvas, center - Offset(base.width / 2, base.height / 2));

    final p = Paint()
      ..color = filled ? const Color(0xFFE6B23C) : Colors.blueGrey.shade900
      ..strokeWidth = filled ? 10 : 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final s in strokes) {
      if (s.length < 2) continue;

      final path = Path()..moveTo(s.first.dx, s.first.dy);
      for (int i = 1; i < s.length; i++) {
        path.lineTo(s[i].dx, s[i].dy);
      }
      canvas.drawPath(path, p);
    }

    if (filled) {
      final gold = TextPainter(
        text: TextSpan(
          text: letter,
          style: const TextStyle(
            fontSize: 100,
            fontWeight: FontWeight.w900,
            color: Color(0xFFE6B23C),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      gold.layout();
      gold.paint(canvas, center - Offset(gold.width / 2, gold.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _LetterPainter old) {
    return old.strokes != strokes || old.filled != filled;
  }
}
