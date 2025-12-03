import 'package:flutter/material.dart';
import 'start_page4.dart';

class StartPage3 extends StatefulWidget {
  const StartPage3({super.key});

  @override
  State<StartPage3> createState() => _StartPageState();
}

class _TopRightTriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(0, 0);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _StartPageState extends State<StartPage3> {
  bool showTutorial = true;
  int hearts = 5;
  double progress = 0.15;
  int pointerIndex = 0;
  String? selectedLetter;
  int currentPage = 0;

  final letters = List<String>.generate(26, (i) => String.fromCharCode(65 + i));
  final Set<String> clickedLetters = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildMainContent(),

          AnimatedOpacity(
            opacity: showTutorial ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: IgnorePointer(
              ignoring: !showTutorial,
              child: showTutorial ? _buildTutorialPopup() : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  // MAIN CONTENT ======================================================
  Widget _buildMainContent() {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildHealthBar(),
          const SizedBox(height: 5),
          _buildPagination(),
          const SizedBox(height: 20),
          _buildTitle(),
          const SizedBox(height: 60),
          _buildLettersGrid(),
          const SizedBox(height: 120),
          _buildNextButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // TUTORIAL POPUP ====================================================
  Widget _buildTutorialPopup() {
    return GestureDetector(
      onTap: () => setState(() => showTutorial = false),
      child: Stack(
        children: [
          Container(
            color: const Color.fromRGBO(86, 124, 141, 0.5),
          ),

          Positioned(
            top: 460,
            left: 160,
            right: 20,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 55,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(86, 124, 141, 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Click the letter",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Positioned(
                  top: 0,
                  left: -12,
                  child: ClipPath(
                    clipper: _TopRightTriangleClipper(),
                    child: Container(
                      width: 30,
                      height: 40,
                      color: const Color.fromRGBO(86, 124, 141, 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // POPUP HURUF =======================================================
  Widget letterPopup(String letter) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF5F7D8C),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFB3BDC4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 20),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      letter.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 120,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      letter.toLowerCase(),
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 120,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Icon(Icons.refresh, size: 40, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TITLE =============================================================
  Widget _buildTitle() {
    return Column(
      children: [
        // ---- VOCAL ----
        Stack(
          children: [
            Text(
              "VOCAL",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3
                  ..color = Colors.black,
              ),
            ),
            const Text(
              "VOCAL",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
          ],
        ),

        const SizedBox(height: 5), // Jarak antar kata

        // ---- LETTERS ----
        Stack(
          children: [
            Text(
              "LETTERS",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 3
                  ..color = Colors.black,
              ),
            ),
            const Text(
              "LETTERS",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // HEALTH BAR ========================================================
  Widget _buildHealthBar() {
    return Container(
      margin: const EdgeInsets.only(top: 40, left: 30, right: 30),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 186, 216, 255),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Icon(
                  index < hearts
                      ? Icons.favorite
                      : Icons.favorite_border_rounded,
                  color: const Color.fromRGBO(212, 0, 0, 1),
                  size: 26,
                ),
              );
            }),
          ),

          Row(
            children: [
              Image.asset(
                'assets/images/mingcute_coin-2-fill.png',
                width: 26,
                height: 26,
              ),
              const SizedBox(width: 5),
              const Text(
                "13",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // PAGINATION ========================================================
  Widget _buildPagination() {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 30, right: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {},
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey.shade600,
              child: const Icon(Icons.close, size: 30, color: Colors.white),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: currentPage == 0
                    ? const Color.fromRGBO(4, 4, 63, 1)
                    : const Color.fromRGBO(4, 4, 63, 1),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          const SizedBox(width: 5),

          Expanded(
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: currentPage == 1
                    ? const Color.fromRGBO(4, 4, 63, 1)
                    : const Color.fromRGBO(4, 4, 63, 1),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  // GRID LETTERS ======================================================
  Widget _buildLettersGrid() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ===== BARIS 1: A I U =====
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLetterItem("A", 0),
            const SizedBox(width: 40),
            _buildLetterItem("I", 1),
            const SizedBox(width: 40),
            _buildLetterItem("U", 2),
          ],
        ),

        // ===== BARIS 2: E O =====
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 60),        // spacer kiri
            _buildLetterItem("E", 3),
            const SizedBox(width: 20),
            _buildLetterItem("O", 4),
            const SizedBox(width: 40),        // spacer kanan
          ],
        ),
      ],
    );
  }

  final Map<String, Offset> pointerOffsets = {
    "A": const Offset(25, -5),
    "I": const Offset(5, -5),   
    "U": const Offset(25, -5),
    "E": const Offset(20, -5),   
    "O": const Offset(25, -5),
  };

  // ====== WIDGET HURUF + POINTER ======
  Widget _buildLetterItem(String letter, int index) {
    final bool isClicked = clickedLetters.contains(letter);

    return GestureDetector(
      onTap: () {
        if (showTutorial) {
          setState(() => showTutorial = false);
        }

        setState(() {
          selectedLetter = letter;
          clickedLetters.add(letter);
          pointerIndex = index + 1 < 5 ? index + 1 : -1;
        });

        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.transparent,
          pageBuilder: (_, __, ___) {
            return Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const Color.fromRGBO(136, 153, 171, 0.8),
                ),
                Center(child: letterPopup(letter)),
              ],
            );
          },
        );
      },

      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // POINTER
          if (pointerIndex == index && !showTutorial)
            Positioned(
              bottom: pointerOffsets[letter]!.dy,
              left: pointerOffsets[letter]!.dx,
              child: const Icon(
                Icons.pan_tool_alt,
                size: 40,
                color: Color.fromRGBO(252, 209, 156, 1),
              ),
            ),

          // HURUF
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              letter,
              style: TextStyle(
                fontSize: 100,
                fontWeight: FontWeight.w700,
                color: isClicked
                    ? Colors.blue 
                    : Colors.black,            
              ),
            ),
          ),
        ],
      ),
    );
  }

  // NEXT BUTTON =======================================================
  Widget _buildNextButton() {
    bool isActive = selectedLetter != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: GestureDetector(
        onTap: isActive
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StartPage4()),
                );
              }
            : null,
        child: CircleAvatar(
          radius: 40,
          backgroundColor: const Color.fromRGBO(4, 4, 63, 1),
          child: const Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: 68,
          ),
        ),
      ),
    );
  }
}
