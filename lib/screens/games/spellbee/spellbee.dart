import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

// SERVICES
import 'package:aksara/services/user_loader_service.dart';
import 'package:aksara/services/user_session.dart';
import 'package:aksara/services/game_progress_service.dart';
import 'package:aksara/services/level_progress_service.dart';

class SpellBeePage extends StatefulWidget {
  const SpellBeePage({super.key});

  @override
  State<SpellBeePage> createState() => _SpellBeePageState();
}

class _SpellBeePageState extends State<SpellBeePage> {
  final String answer = "CAT";
  String? errorMessage;
  String? highlightedLetter;
  final AudioPlayer _player = AudioPlayer();

  final GlobalKey _inputKey = GlobalKey();
  double errorTop = 300;

  List<String?> userAnswer = ["", "", ""];

  @override
  void initState() {
    super.initState();
    _ensureUserLoaded();
  }

  /// =============================================================
  /// WAJIB: Pastikan idAkun loaded sebelum save progress
  /// =============================================================
  Future<void> _ensureUserLoaded() async {
    if (UserSession.instance.idAkun == null) {
      print("🔵 [SpellBee] Loading user ID…");
      await UserLoaderService.instance.loadUserId();
      print("🟢 [SpellBee] idAkun = ${UserSession.instance.idAkun}");
    }
  }

  Future<void> _playLetterSound(String letter) async {
    await _player.stop();
    await _player.play(
      AssetSource("sounds/alphabet/${letter.toLowerCase()}.mp3"),
    );
  }

  void _calculateErrorPosition() {
    final render =
        _inputKey.currentContext?.findRenderObject() as RenderBox?;
    if (render == null) return;

    final offset = render.localToGlobal(Offset.zero);
    setState(() {
      errorTop = offset.dy + render.size.height + 8;
    });
  }

  void selectLetter(String letter) {
    _playLetterSound(letter);

    int index = userAnswer.indexOf("");
    if (index == -1) return;

    if (letter == answer[index]) {
      setState(() {
        userAnswer[index] = letter;
        highlightedLetter = letter;
        errorMessage = null;
      });

      checkIfCompleted();
    } else {
      showFloatingError();
      highlightedLetter = null;
    }
  }

  /// =============================================================
  /// FINAL COMPLETION LOGIC → SAVE PROGRESS KE SUPABASE
  /// =============================================================
  Future<void> _handleLevelCompleted() async {
    final idAkun = UserSession.instance.idAkun;

    if (idAkun == null) {
      print("❌ [SpellBee] idAkun NULL, tidak bisa simpan progress");
      return;
    }

    print("🏆 [SpellBee] Saving progress...");

    // Tambah score +10
    await GameProgressService.instance.updateAggregatedProgress(
      idAkun: idAkun,
      gameKey: "spellbee",
      isCorrect: true,
    );

    // Ambil current level
    final currentLevel =
        await LevelProgressService.instance.getCurrentLevel(idAkun);

    print("🔵 Current level user = $currentLevel");

    // Naikkan 1 level
    final nextLevel =
        await LevelProgressService.instance.incrementLevel(idAkun);

    print("🟢 User level naik → $currentLevel → $nextLevel");
  }


  Future<void> showCompletionPopup() async {
    // simpan progress sebelum popup close
    await _handleLevelCompleted();

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.white.withOpacity(0.02)),
            ),
            Center(
              child: Image.asset(
                "assets/images/yeay_correct.png",
                width: 700,
                height: 700,
                fit: BoxFit.contain,
              ),
            ),
          ],
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pushReplacementNamed(context, "/home");
    }
  }

  void checkIfCompleted() {
    if (!userAnswer.contains("")) {
      showCompletionPopup();
    }
  }

  void showFloatingError() {
    setState(() => errorMessage = "Wrong letter!");
    _calculateErrorPosition();

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => errorMessage = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F2ED),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: h + 1),
                child: Column(
                  children: [
                    const SizedBox(height: 5),

                    // --------------------------------------------------
                    // HEADER AREA (UI sama persis)
                    // --------------------------------------------------
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey,
                              child: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: List.generate(5, (index) {
                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: index == 0
                                        ? const Color(0xFF2B3A55)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    const Text(
                      "What is this ?",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),

                    SizedBox(
                      height: 300,
                      child: Image.asset(
                        "assets/images/kitty.png",
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      key: _inputKey,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          List.generate(userAnswer.length, (index) {
                        return Column(
                          children: [
                            Text(
                              userAnswer[index] ?? "",
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 2),
                              width: 70,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),

                    const SizedBox(height: 80),

                    _buildHexGrid(),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            // --------------------------------------------------
            // ERROR FLOATING (UI tidak diubah)
            // --------------------------------------------------
            if (errorMessage != null)
              Positioned(
                top: errorTop,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: 1,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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

  // --------------------------------------------------------------------------
  // HEX BUTTON UI (TIDAK DIUBAH)
  // --------------------------------------------------------------------------
  Widget _hexButton(String letter, {double size = 70}) {
    final bool isHighlighted = (letter == highlightedLetter);

    return ClipPath(
      clipper: _HexClipper(),
      child: Material(
        color: isHighlighted
            ? const Color.fromRGBO(130, 222, 228, 1)
            : const Color.fromARGB(255, 211, 211, 211),
        child: InkWell(
          onTap: () => selectLetter(letter),
          splashColor: Colors.black12,
          highlightColor: Colors.transparent,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHexGrid() {
    final double hexSize = 90;
    final double vOffset = -hexSize * 0.48;
    final double hGap = hexSize * 0.06;
    final double rowSpacing = hexSize * 0.10;

    final double secondRowRaise = hexSize * 0.05;
    final double thirdRowRaise = hexSize * 0.05;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [_hexButton("T", size: hexSize)]),

        SizedBox(height: rowSpacing),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset:
                  Offset(hexSize * 0.2, vOffset - secondRowRaise),
              child: _hexButton("F", size: hexSize),
            ),
            SizedBox(width: hGap),
            _hexButton("B", size: hexSize),
            SizedBox(width: hGap),
            Transform.translate(
              offset:
                  Offset(-hexSize * 0.2, vOffset - secondRowRaise),
              child: _hexButton("O", size: hexSize),
            ),
          ],
        ),

        SizedBox(height: rowSpacing),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset:
                  Offset(hexSize * 0.2, vOffset - thirdRowRaise),
              child: _hexButton("C", size: hexSize),
            ),
            SizedBox(width: hGap),
            _hexButton("D", size: hexSize),
            SizedBox(width: hGap),
            Transform.translate(
              offset:
                  Offset(-hexSize * 0.2, vOffset - thirdRowRaise),
              child: _hexButton("A", size: hexSize),
            ),
          ],
        ),
      ],
    );
  }
}

// =======================================================================
// HEXAGON CLIPPER
// =======================================================================
class _HexClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.25, 0)
      ..lineTo(w * 0.75, 0)
      ..lineTo(w, h * 0.5)
      ..lineTo(w * 0.75, h)
      ..lineTo(w * 0.25, h)
      ..lineTo(0, h * 0.5)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(oldClipper) => false;
}
