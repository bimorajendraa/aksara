import 'dart:ui';
import 'package:flutter/material.dart';

class SpellBeePage extends StatefulWidget {
  const SpellBeePage({super.key});

  @override
  State<SpellBeePage> createState() => _SpellBeePageState();
}

class _SpellBeePageState extends State<SpellBeePage> {
  final String answer = "CAT";
  String? errorMessage;
  String? highlightedLetter;
  
  List<String?> userAnswer = ["", "", ""];

  void selectLetter(String letter) {
    int index = userAnswer.indexOf("");

    if (index == -1) return;

    if (letter == answer[index]) {
      setState(() {
        userAnswer[index] = letter;
        if (letter == answer[index]) {
          setState(() {
            userAnswer[index] = letter;
            errorMessage = null;
            highlightedLetter = letter;
          });

          checkIfCompleted(); 
        }
        errorMessage = null;
        highlightedLetter = letter;
      });
    } else {
      showFloatingError();
      setState(() {
        highlightedLetter = null;
      });
    }
  }

  void showCompletionPopup() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors
          .transparent, // ⬅️ Tambahkan ini agar tidak ada warna gelap di belakang dialog
      builder: (context) {
        return Stack(
          children: [
            // Blur background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.white.withOpacity(0.02), 
              ),
            ),

            // Popup image
            Center(
              child: Image.asset(
                "assets/images/yeay_correct.png",
                width: 700,
                height: 700,
                fit: BoxFit.contain,
              ),
            )
          ],
        );
      },
    );

    // TUNGGU 3 DETIK LALU CLOSE POPUP DAN PINDAH PAGE
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

  // 🟥 ERROR MELAYANG (Overlay)
  void showFloatingError() {
    setState(() => errorMessage = "Wrong letter!");

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => errorMessage = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2ED),
      body: SafeArea(
        child: Stack(
          children: [
            // ==========================
            // MAIN PAGE CONTENT
            // ==========================
            Column(
              children: [
                const SizedBox(height: 5),

                // ===== BACK BUTTON + PROGRESS =====
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
                          child: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: List.generate(5, (index) {
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(userAnswer.length, (index) {
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
                          margin: const EdgeInsets.symmetric(horizontal: 2),
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
              ],
            ),

            // ==========================================================
            // 🔥 ERROR MESSAGE MELAYANG (TIDAK NGGESER UI)
            // ==========================================================
            if (errorMessage != null)
              Positioned(
                top: 555,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: errorMessage != null ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

  // ===============================================
  //   HEX BUTTON
  // ===============================================
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

  // =======================
  //     HEX GRID
  // =======================
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
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _hexButton("T", size: hexSize),
        ]),

        SizedBox(height: rowSpacing),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.translate(
              offset: Offset(hexSize * 0.2, vOffset - secondRowRaise),
              child: _hexButton("F", size: hexSize),
            ),
            SizedBox(width: hGap),
            _hexButton("B", size: hexSize),
            SizedBox(width: hGap),
            Transform.translate(
              offset: Offset(-hexSize * 0.2, vOffset - secondRowRaise),
              child: _hexButton("O", size: hexSize),
            ),
          ],
        ),

        SizedBox(height: rowSpacing),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.translate(
              offset: Offset(hexSize * 0.2, vOffset - thirdRowRaise),
              child: _hexButton("C", size: hexSize),
            ),
            SizedBox(width: hGap),
            _hexButton("D", size: hexSize),
            SizedBox(width: hGap),
            Transform.translate(
              offset: Offset(-hexSize * 0.2, vOffset - thirdRowRaise),
              child: _hexButton("A", size: hexSize),
            ),
          ],
        ),
      ],
    );
  }
} // END

// ===================================================
// HEXAGON CLIPPER
// ===================================================
class _HexClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    path.moveTo(w * 0.25, 0);
    path.lineTo(w * 0.75, 0);
    path.lineTo(w, h * 0.5);
    path.lineTo(w * 0.75, h);
    path.lineTo(w * 0.25, h);
    path.lineTo(0, h * 0.5);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
