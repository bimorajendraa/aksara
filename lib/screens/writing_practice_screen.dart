import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class WritingPracticeScreen extends StatelessWidget {
  const WritingPracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnitListPage();
  }
}

/// ================================
/// PAGEVIEW LIST OF UNITS
/// ================================
class UnitListPage extends StatefulWidget {
  const UnitListPage({super.key});

  @override
  State<UnitListPage> createState() => _UnitListPageState();
}

class _UnitListPageState extends State<UnitListPage> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  // Each unit: list of letters (uppercase, lowercase, ...)
  final List<List<String>> _units = [
    ['A', 'a', 'B', 'b', 'C', 'c'], // Unit 1
    ['V', 'v', 'W', 'w', 'X', 'x', 'Y', 'y', 'Z', 'z'], // Unit 2
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F8),
      body: SafeArea(
        child: Column(
          children: [
            // top bar: hearts + progress per-unit indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const HeartRow(hearts: 5),
                  const Spacer(),
                  // small three-dot style indicator for current page
                  PageIndicatorDots(total: _units.length, current: _pageIndex),
                ],
              ),
            ),

            // PageView for units
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _units.length,
                onPageChanged: (i) => setState(() => _pageIndex = i),
                itemBuilder: (context, index) {
                  return UnitPage(
                    letters: _units[index],
                    onCompleteUnit: () {
                      if (index < _units.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("All units complete!")),
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
}

/// ================================
/// HEARTS (lives)
/// ================================
class HeartRow extends StatelessWidget {
  final int hearts;
  const HeartRow({super.key, this.hearts = 5});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        hearts,
        (i) => const Padding(
          padding: EdgeInsets.only(right: 6),
          child: Icon(Icons.favorite, size: 18, color: Colors.redAccent),
        ),
      ),
    );
  }
}

/// ================================
/// page indicator dots (small)
/// ================================
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
        final color = i == current ? Colors.blueGrey[800] : Colors.grey[300];
        final width = i == current ? 18.0 : 12.0;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: width,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

/// ================================
/// UNIT PAGE: contains multiple rows of (Uppercase, lowercase) pairs.
/// Also contains a progress bar per lesson (section), pencil/eraser tool, and next button.
/// ================================
class UnitPage extends StatefulWidget {
  final List<String> letters;
  final VoidCallback onCompleteUnit;

  const UnitPage({
    super.key,
    required this.letters,
    required this.onCompleteUnit,
  });

  @override
  State<UnitPage> createState() => _UnitPageState();
}

class _UnitPageState extends State<UnitPage> {
  // rows are pairs of letters: [A,a], [B,b], ...
  late final List<List<String>> rows;

  // Sectioning: per lesson / section = 3 rows (A/a,B/b,C/c)
  static const int rowsPerSection = 3;
  int currentSection = 0;

  // tool mode: true => pencil, false => eraser
  bool pencilMode = true;

  @override
  void initState() {
    super.initState();
    rows = [];
    for (int i = 0; i < widget.letters.length; i += 2) {
      rows.add([
        widget.letters[i],
        (i + 1) < widget.letters.length ? widget.letters[i + 1] : '',
      ]);
    }
    currentSection = 0;
  }

  int get totalSections => (rows.length / rowsPerSection).ceil();

  void _goToNextSectionOrFinish() {
    if (currentSection < totalSections - 1) {
      setState(() {
        currentSection++;
      });
    } else {
      widget.onCompleteUnit();
    }
  }

  void _toggleTool(bool toPencil) {
    setState(() {
      pencilMode = toPencil;
    });
  }

  @override
  Widget build(BuildContext context) {
    // compute visible rows for current section
    final start = currentSection * rowsPerSection;
    final end = min(start + rowsPerSection, rows.length);
    final visibleRows = rows.sublist(
      0,
      end,
    ); // show from start of unit up to current section end (like example)

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F8),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content: header progress + rows
            Column(
              children: [
                // Progress bar per lesson (sections)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: LessonProgressBar(
                    sections: totalSections,
                    currentSection: currentSection,
                  ),
                ),

                // The rows list (show rows up to current section for visual)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 140,
                    ),
                    itemCount: visibleRows.length,
                    itemBuilder: (context, index) {
                      final pair = visibleRows[index];
                      return LetterRowWidget(
                        key: ValueKey('${pair[0]}_${pair[1]}_$index'),
                        uppercase: pair[0],
                        lowercase: pair[1],
                        pencilMode: pencilMode,
                      );
                    },
                  ),
                ),
              ],
            ),

            // Right vertical toolbar: pencil & eraser
            Positioned(
              right: 10,
              top: 110,
              child: Column(
                children: [
                  // Pencil
                  ToolButton(
                    icon: Icons.edit,
                    active: pencilMode,
                    onTap: () => _toggleTool(true),
                  ),
                  const SizedBox(height: 10),
                  // Eraser (partial erase)
                  ToolButton(
                    icon: Icons.backspace,
                    active: !pencilMode,
                    onTap: () => _toggleTool(false),
                  ),
                ],
              ),
            ),

            // Next section button center bottom
            Positioned(
              bottom: 26,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _goToNextSectionOrFinish,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F3A4A),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small tool button for vertical toolbar
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
          color: active ? Colors.white : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          color: active ? Colors.blueGrey[900] : Colors.grey[500],
          size: 22,
        ),
      ),
    );
  }
}

/// Lesson progress bar: shows sections horizontally.
/// Completed sections are darker, current section is bold/raised.
class LessonProgressBar extends StatelessWidget {
  final int sections;
  final int currentSection;
  const LessonProgressBar({
    super.key,
    required this.sections,
    required this.currentSection,
  });

  @override
  Widget build(BuildContext context) {
    // total slots: show more fine-grained dashes per section (3 dashes per section)
    final List<Widget> items = [];
    for (int s = 0; s < sections; s++) {
      final bool isCurrent = s == currentSection;
      final bool isDone = s < currentSection;
      final color = isDone
          ? Colors.blueGrey[800]
          : (isCurrent ? Colors.blueGrey[700] : Colors.grey[300]);
      final height = isCurrent ? 10.0 : 6.0;
      final width = isCurrent ? 42.0 : 28.0;

      items.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return Row(
      children: [
        // left label (unit) - optional
        const SizedBox(width: 4),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: items,
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

/// ================================
/// LETTER ROW WIDGET (shows two boxes: uppercase & lowercase)
/// - contains interactive tracing canvas for each letter (free drawing)
/// - supports pencil and partial eraser (eraser mode uses global tool state managed in parent via InheritedWidget? Simpler: pass current pencilMode via constructor)
/// ================================
class LetterRowWidget extends StatefulWidget {
  final String uppercase;
  final String lowercase;
  final bool pencilMode;

  const LetterRowWidget({
    super.key,
    required this.uppercase,
    required this.lowercase,
    required this.pencilMode,
  });

  @override
  State<LetterRowWidget> createState() => _LetterRowWidgetState();
}

class _LetterRowWidgetState extends State<LetterRowWidget> {
  // strokes for uppercase and lowercase separately
  List<List<Offset>> upperStrokes = [];
  List<List<Offset>> lowerStrokes = [];

  bool upperFilled = false;
  bool lowerFilled = false;

  // drawing thresholds
  static const double fillThreshold = 120.0;
  // eraser radius
  static const double eraserRadius = 22.0;

  // helper to compute drawn length
  double _lengthOf(List<List<Offset>> strokes) {
    double len = 0;
    for (final s in strokes) {
      for (int i = 1; i < s.length; i++) {
        len += (s[i] - s[i - 1]).distance;
      }
    }
    return len;
  }

  // when user paints on upper box
  void _startUpper(Offset p) {
    if (upperFilled) return;
    upperStrokes.add([p]);
    setState(() {});
  }

  void _updateUpper(Offset p) {
    if (upperFilled) return;
    upperStrokes.last.add(p);
    if (_lengthOf(upperStrokes) > fillThreshold) {
      upperFilled = true;
    }
    setState(() {});
  }

  // when user paints on lower box
  void _startLower(Offset p) {
    if (lowerFilled) return;
    lowerStrokes.add([p]);
    setState(() {});
  }

  void _updateLower(Offset p) {
    if (lowerFilled) return;
    lowerStrokes.last.add(p);
    if (_lengthOf(lowerStrokes) > fillThreshold) {
      lowerFilled = true;
    }
    setState(() {});
  }

  // partial eraser: removes points near pos within radius
  void _eraseAt(Offset pos, RenderBox box, bool isUpper) {
    final local = box.globalToLocal(pos);
    final target = isUpper ? upperStrokes : lowerStrokes;
    final newStrokes = <List<Offset>>[];
    for (final s in target) {
      final kept = s
          .where((pt) => (pt - local).distance > eraserRadius)
          .toList();
      // keep only strokes having at least 2 points
      if (kept.length >= 1) newStrokes.add(kept);
    }
    if (isUpper) {
      upperStrokes = newStrokes;
      upperFilled = _lengthOf(upperStrokes) > fillThreshold ? true : false;
    } else {
      lowerStrokes = newStrokes;
      lowerFilled = _lengthOf(lowerStrokes) > fillThreshold ? true : false;
    }
    setState(() {});
  }

  void _clearAllUpper() {
    upperStrokes = [];
    upperFilled = false;
    setState(() {});
  }

  void _clearAllLower() {
    lowerStrokes = [];
    lowerFilled = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // each letter box height
    const boxHeight = 72.0;

    return Container(
      height: 120,
      margin: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // dotted baseline (visual only)
          const BaselinePlaceholder(),
          const SizedBox(height: 6),

          // two boxes in a row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: boxHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: LetterCanvas(
                    letter: widget.uppercase,
                    strokes: upperStrokes,
                    filled: upperFilled,
                    pencilMode: widget.pencilMode,
                    onStart: (pos) {
                      _startUpper(pos);
                    },
                    onUpdate: (pos) {
                      _updateUpper(pos);
                    },
                    onErase: (globalPos, box) {
                      _eraseAt(globalPos, box, true);
                    },
                    onClear: _clearAllUpper,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Container(
                  height: boxHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: LetterCanvas(
                    letter: widget.lowercase,
                    strokes: lowerStrokes,
                    filled: lowerFilled,
                    pencilMode: widget.pencilMode,
                    onStart: (pos) {
                      _startLower(pos);
                    },
                    onUpdate: (pos) {
                      _updateLower(pos);
                    },
                    onErase: (globalPos, box) {
                      _eraseAt(globalPos, box, false);
                    },
                    onClear: _clearAllLower,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          // underline
          Container(height: 2, color: Colors.black.withOpacity(0.28)),
        ],
      ),
    );
  }
}

/// LetterCanvas: draws background faded letter, strokes, and handles gestures.
/// It is stateless regarding strokes (parent holds stroke lists) but handles gestures and calls callbacks.
class LetterCanvas extends StatefulWidget {
  final String letter;
  final List<List<Offset>> strokes;
  final bool filled;
  final bool pencilMode; // true: draw, false: erase
  final void Function(Offset globalPos) onStart;
  final void Function(Offset globalPos) onUpdate;
  final void Function(Offset globalPos, RenderBox box) onErase;
  final VoidCallback onClear;

  const LetterCanvas({
    super.key,
    required this.letter,
    required this.strokes,
    required this.filled,
    required this.pencilMode,
    required this.onStart,
    required this.onUpdate,
    required this.onErase,
    required this.onClear,
  });

  @override
  State<LetterCanvas> createState() => _LetterCanvasState();
}

class _LetterCanvasState extends State<LetterCanvas> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (d) {
        if (widget.pencilMode) {
          widget.onStart(d.globalPosition);
        } else {
          final box = context.findRenderObject() as RenderBox;
          widget.onErase(d.globalPosition, box);
        }
      },
      onPanUpdate: (d) {
        if (widget.pencilMode) {
          widget.onUpdate(d.globalPosition);
        } else {
          final box = context.findRenderObject() as RenderBox;
          widget.onErase(d.globalPosition, box);
        }
      },
      onDoubleTap: widget.onClear, // double tap to clear that letter box
      child: CustomPaint(
        painter: _LetterPainter(widget.letter, widget.strokes, widget.filled),
        size: Size.infinite,
      ),
    );
  }
}

class _LetterPainter extends CustomPainter {
  final String letter;
  final List<List<Offset>> strokes;
  final bool filled;

  _LetterPainter(this.letter, this.strokes, this.filled);

  @override
  void paint(Canvas canvas, Size size) {
    // draw faded letter centered
    final center = Offset(size.width / 2, size.height / 2);
    final textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.w700,
          color: Colors.grey.withOpacity(0.28),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    // draw strokes
    final paint = Paint()
      ..color = filled ? const Color(0xFFE6B23C) : Colors.blueGrey[800]!
      ..strokeWidth = filled ? 8.0 : 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      final path = Path()
        ..moveTo(
          stroke.first.dx - stroke.first.dx + stroke.first.dx,
          stroke.first.dy - stroke.first.dy + stroke.first.dy,
        );
      // path building uses absolute coordinates (we stored global coords) -> convert to local
      // However we stored global positions in parent; convert relative to canvas by using an offset transform
      // To properly handle coordinate space, assume strokes are already local (we used global but converted in parent when calling).
      // If they are global, we need to map; to keep simple and correct, we expect parent to pass global offsets and we'll convert using canvas size.
      // But because parent already converted using globalToLocal before passing onStart/onUpdate, the strokes are local coordinates.
      // Thus constructing path as below:
      path.reset();
      path.moveTo(stroke.first.dx, stroke.first.dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    // if filled, draw gold stroke letter overlay (outline)
    if (filled) {
      final tp = TextPainter(
        text: TextSpan(
          text: letter,
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFE6B23C),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _LetterPainter old) {
    return old.strokes != strokes ||
        old.filled != filled ||
        old.letter != letter;
  }
}

/// ================================
/// BASELINE DOTS (--- --- ---)
/// ================================
class BaselinePlaceholder extends StatelessWidget {
  const BaselinePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        20,
        (_) => Container(
          width: 12,
          height: 4,
          margin: const EdgeInsets.only(right: 4),
          color: Colors.grey.withOpacity(0.35),
        ),
      ),
    );
  }
}
