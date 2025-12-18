// lib/screens/writing_practice_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:aksara/screens/home/home_screen.dart';

// SUPABASE SERVICES
import 'package:aksara/services/user_loader_service.dart';
import 'package:aksara/services/user_session.dart';

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
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    LetterCanvasTracker.reset();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    if (UserSession.instance.idAkun == null) {
      await UserLoaderService.instance.loadUserId();
    }
    debugPrint("🟦 [WritingPractice] user = ${UserSession.instance.idAkun}");
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
            // TOP BAR
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
                  PageIndicatorDots(
                    total: units.length,
                    current: _pageIndex,
                  ),
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
                    letters: letters,
                    isLastUnit: isLastUnit,
                    onPrevUnit: () {
                      if (index > 0) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    onNextUnit: () {
                      if (index < units.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    onFinish: () => _handleFinish(context),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleFinish(BuildContext context) {
    if (_finishing) return;
    _finishing = true;

    if (!LetterCanvasTracker.allCompleted) {
      _finishing = false;
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Incomplete"),
          content: Text("Please fill all letters until they turn yellow."),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Great Job!"),
        content: const Text("You completed all writing practice."),
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
/// COMPLETION TRACKER
///////////////////////////////////////////////////////////////////////////////

class LetterCanvasTracker {
  static final Map<String, bool> _completion = {};

  static void reset() => _completion.clear();

  static void markFilled(String letter) {
    _completion[letter] = true;
  }

  static void markNotFilled(String letter) {
    _completion[letter] = false;
  }

  static bool get allCompleted =>
      _completion.isNotEmpty && _completion.values.every((v) => v);
}

///////////////////////////////////////////////////////////////////////////////
/// SMALL UI
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

  const PageIndicatorDots({super.key, required this.total, required this.current});

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
/// UNIT PAGE
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
    required this.isLastUnit,
    required this.onPrevUnit,
    required this.onNextUnit,
    required this.onFinish,
  });

  @override
  State<UnitPage> createState() => _UnitPageState();
}

class _UnitPageState extends State<UnitPage> {
  static const int rowsPerSection = 3;
  int currentSection = 0;
  bool _canScroll = true;
  final ValueNotifier<bool> pencilMode = ValueNotifier(true);

  late final List<List<String>> rows;

  @override
  void initState() {
    super.initState();
    rows = [];
    for (int i = 0; i < widget.letters.length; i += 2) {
      rows.add([
        widget.letters[i],
        i + 1 < widget.letters.length ? widget.letters[i + 1] : ''
      ]);
    }
  }

  int get totalSections => (rows.length / rowsPerSection).ceil();

  @override
  Widget build(BuildContext context) {
    final visibleCount = min(rows.length, (currentSection + 1) * rowsPerSection);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F8),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              physics: _canScroll
                  ? const BouncingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 140),
              children: [
                for (int i = 0; i < rows.length; i++)
                  Offstage(
                    offstage: i >= visibleCount,
                    child: LetterRowWidget(
                      uppercase: rows[i][0],
                      lowercase: rows[i][1],
                      pencilModeNotifier: pencilMode,
                      onScrollLock: (lock) =>
                          setState(() => _canScroll = !lock),
                    ),
                  )
              ],
            ),

            Positioned(
              bottom: 26,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _navBtn(Icons.arrow_back, widget.onPrevUnit),
                  const SizedBox(width: 22),
                  widget.isLastUnit
                      ? _finishBtn()
                      : _navBtn(Icons.arrow_forward, widget.onNextUnit),
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
        decoration: const BoxDecoration(
          color: Color(0xFF2F3A4A),
          shape: BoxShape.circle,
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
        ),
        child: const Center(
          child: Text(
            "FINISH",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
/// LETTER ROW + CANVAS
///////////////////////////////////////////////////////////////////////////////

class LetterRowWidget extends StatelessWidget {
  final String uppercase;
  final String lowercase;
  final ValueNotifier<bool> pencilModeNotifier;
  final ValueChanged<bool> onScrollLock;

  const LetterRowWidget({
    super.key,
    required this.uppercase,
    required this.lowercase,
    required this.pencilModeNotifier,
    required this.onScrollLock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: _canvasBox(uppercase)),
          const SizedBox(width: 18),
          Expanded(child: _canvasBox(lowercase)),
        ],
      ),
    );
  }

  Widget _canvasBox(String letter) {
    return LetterCanvas(
      letter: letter,
      pencilModeNotifier: pencilModeNotifier,
      onScrollLock: onScrollLock,
    );
  }
}

class LetterCanvas extends StatefulWidget {
  final String letter;
  final ValueNotifier<bool> pencilModeNotifier;
  final ValueChanged<bool> onScrollLock;

  const LetterCanvas({
    super.key,
    required this.letter,
    required this.pencilModeNotifier,
    required this.onScrollLock,
  });

  @override
  State<LetterCanvas> createState() => _LetterCanvasState();
}

class _LetterCanvasState extends State<LetterCanvas> {
  final List<List<Offset>> strokes = [];
  bool filled = false;

  static const double fillThreshold = 150.0;

  @override
  void initState() {
    super.initState();
    LetterCanvasTracker.markNotFilled(widget.letter);
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

  @override
  Widget build(BuildContext context) {
    final isPencil = widget.pencilModeNotifier.value;

    return Listener(
      onPointerDown: (_) => widget.onScrollLock(true),
      onPointerUp: (_) => widget.onScrollLock(false),
      child: GestureDetector(
        onPanStart: (d) => strokes.add([d.localPosition]),
        onPanUpdate: (d) {
          strokes.last.add(d.localPosition);
          filled = _strokeLen() > fillThreshold;
          filled
              ? LetterCanvasTracker.markFilled(widget.letter)
              : LetterCanvasTracker.markNotFilled(widget.letter);
          setState(() {});
        },
        child: CustomPaint(
          painter: _LetterPainter(
            letter: widget.letter,
            strokes: strokes,
            filled: filled,
          ),
        ),
      ),
    );
  }
}

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
    final paint = Paint()
      ..color = filled ? Colors.amber : Colors.blueGrey
      ..strokeWidth = filled ? 10 : 8
      ..style = PaintingStyle.stroke;

    for (final s in strokes) {
      for (int i = 1; i < s.length; i++) {
        canvas.drawLine(s[i - 1], s[i], paint);
      }
    }

    final tp = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontSize: 100,
          color: filled ? Colors.amber : Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _LetterPainter old) => true;
}
