import 'dart:math';
import 'package:flutter/material.dart';
<<<<<<< HEAD
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
=======

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
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a

  Connection({
    required this.leftIndex,
    required this.rightIndex,
    required this.isCorrect,
  });
}

<<<<<<< HEAD
/// =============================================================
/// LINE PAINTER
/// =============================================================
=======
/// =========================================================================
/// PAINTER UNTUK SEMUA GARIS (OVERLAY GLOBAL)
/// =========================================================================
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a
class LinePainter extends CustomPainter {
  final List<Connection> lines;
  final List<Offset> leftDots;
  final List<Offset> rightDots;
<<<<<<< HEAD
=======

  /// State garis yang sedang di-drag
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a
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
<<<<<<< HEAD
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
=======
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
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a
    }
  }

  @override
<<<<<<< HEAD
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// =============================================================
/// DRAGDROP PAGE
/// =============================================================
class DragDropPage extends StatefulWidget {
  const DragDropPage({super.key});

=======
  bool shouldRepaint(covariant LinePainter oldDelegate) => true;
}

/// =======================================================================
/// HALAMAN MAIN DRAG & DROP
/// =======================================================================
class DragDropPage extends StatefulWidget {
  const DragDropPage({super.key});
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a
  @override
  State<DragDropPage> createState() => _DragDropPageState();
}

class _DragDropPageState extends State<DragDropPage> {
<<<<<<< HEAD
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
=======
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
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
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

=======
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
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a
    correctPairs.clear();
    for (int i = 0; i < 5; i++) {
      correctPairs[i] = shuffled.indexOf(leftNodes[i].letter);
    }

<<<<<<< HEAD
    print("🔤 LEFT  NODES: $letters");
    print("🔤 RIGHT NODES: $shuffled");
    print("🟢 CORRECT MAP: $correctPairs");

=======
    // Reset garis & posisi dot
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a
    lines.clear();
    leftDots = List.filled(5, Offset.zero);
    rightDots = List.filled(5, Offset.zero);

    draggingLeft = null;
    dragPos = null;

    setState(() {});
  }

<<<<<<< HEAD
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
=======
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
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a
      setState(() {
        showFail = true;
        failFromHeart = false;
      });
    }
  }

<<<<<<< HEAD
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
=======
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
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a
        break;
      }
    }
  }

<<<<<<< HEAD
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
=======
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
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a
            showFail = true;
            failFromHeart = true;
          }
        }
      });
    }

<<<<<<< HEAD
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
=======
    // Reset drag
    setState(() {
      draggingLeft = null;
      dragPos = null;
    });
  }

  /// ======================================================================
  /// BUILD
  /// ======================================================================
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
<<<<<<< HEAD
=======
      // Listener global supaya garis selalu dari dot kiri ke posisi jari
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        child: Stack(
          children: [
            _buildMain(),
<<<<<<< HEAD

=======
            // Overlay semua garis (permanent + drag)
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a
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
<<<<<<< HEAD

            if (showSuccess) _successPopup(),
            if (showFail) _failPopup(),
=======
            if (showSuccess) _buildSuccess(),
            if (showFail) _buildFail(),
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
=======
  /// ======================================================================
  /// UI UTAMA (HEADER + ROW HURUF/SUARA + TOMBOL NEXT)
  /// ======================================================================
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a
  Widget _buildMain() {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 8),
<<<<<<< HEAD
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
=======
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
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a
                  ),
                ),
              ],
            ),
          ),
<<<<<<< HEAD

=======
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a
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
<<<<<<< HEAD
              child: const Icon(Icons.arrow_forward, color: Colors.white),
=======
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 34,
              ),
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a
            ),
          ),
        ],
      ),
    );
  }
<<<<<<< HEAD
=======

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
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a
}
