import 'package:flutter/material.dart';

class SpellBeePage extends StatefulWidget {
  const SpellBeePage({super.key});

  @override
  State<SpellBeePage> createState() => _SpellBeePageState();
}

class _SpellBeePageState extends State<SpellBeePage> {
  final String answer = "CAT";
  List<String?> userAnswer = ["", "", ""];

  void selectLetter(String letter) {
    for (int i = 0; i < userAnswer.length; i++) {
      if (userAnswer[i] == "") {
        setState(() {
          userAnswer[i] = letter;
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2ED),
      body: SafeArea(
        child: Column(
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

            const SizedBox(height: 80),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(userAnswer.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 70,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(30),
                  ),
                );
              }),
            ),

            const SizedBox(height: 50),

            _buildHexGrid(),
          ],
        ),
      ),
    );
  }

  Widget _hexButton(String letter, {double size = 70}) {
    return GestureDetector(
      onTap: () => selectLetter(letter),
      child: ClipPath(
        clipper: _HexClipper(),
        child: Container(
          width: size,
          height: size,
          color: const Color.fromARGB(255, 211, 211, 211),

          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHexGrid() {
    // compute a responsive hex size based on screen width
    final double screenW = MediaQuery.of(context).size.width;
    // Change the multiplier or clamp values to make hexagons larger/smaller
    final double hexSize = 90;
    final double vOffset = -hexSize * 0.48; // base vertical overlap between rows
    final double hGap = hexSize * 0.06; // horizontal gap between hexes
    final double rowSpacing = hexSize * 0.10;
    // additional raises for specific rows/buttons (increase to move buttons up)
    final double secondRowRaise = hexSize * 0.05; // raise for F and O
    final double thirdRowRaise = hexSize * 0.05; // raise for C and A

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
} // end of _SpellBeePageState

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