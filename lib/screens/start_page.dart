import 'package:flutter/material.dart';
import 'start_page2.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
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

class _StartPageState extends State<StartPage> {
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
          const SizedBox(height: 20),
          Expanded(child: _buildLettersGrid()),
          const SizedBox(height: 10),
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
            top: 300,
            left: 113,
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
                      fontSize: 28,
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
    return Stack(
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
                    : Colors.grey.shade400,
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
                    : Colors.grey.shade400,
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
      final letters = this.letters;
      final Set<int> skippedIndexes = {24};
      final int gridCount = letters.length + skippedIndexes.length;

      int skippedBefore(int gridIndex) {
        return skippedIndexes.where((s) => s < gridIndex).length;
      }

      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.2,
        ),
        itemCount: gridCount,
        itemBuilder: (context, gridIndex) {
          if (skippedIndexes.contains(gridIndex)) return Container();

          final int letterIndex = gridIndex - skippedBefore(gridIndex);
          final letter = letters[letterIndex];

          // Cek apakah huruf sudah diklik sebelumnya
          final bool isClicked = clickedLetters.contains(letter);

          return GestureDetector(
            onTap: () {
              if (showTutorial) {
                setState(() => showTutorial = false);
              }

              setState(() {
                selectedLetter = letter;
                progress = (letterIndex + 1) / letters.length;

                // Simpan huruf yang sudah diklik
                clickedLetters.add(letter);

                // ==== PINDAHKAN ICON TANGAN KE HURUF BERIKUTNYA ====
                int nextLetterIndex = letterIndex + 1;

                if (nextLetterIndex < letters.length) {
                  // Cari gridIndex sesuai skippedIndexes
                  int nextGridIndex = nextLetterIndex;
                  for (int skip in skippedIndexes) {
                    if (skip <= nextGridIndex) {
                      nextGridIndex++;
                    }
                  }
                  pointerIndex = nextGridIndex;
                } else {
                  // Jika sudah huruf terakhir, sembunyikan tangan
                  pointerIndex = -1;
                }
              });

              showGeneralDialog(
                context: context,
                barrierDismissible: false,
                barrierLabel: "Popup",
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


            child: Container(
              padding: const EdgeInsets.only(top: 20),
              child: Stack(
                alignment: Alignment.topCenter,
                clipBehavior: Clip.none,
                children: [
                  if (pointerIndex == gridIndex && !showTutorial)
                    const Positioned(
                      top: 45,
                      left: 24,
                      child: Icon(
                        Icons.pan_tool_alt,
                        size: 40,
                        color: Color.fromRGBO(252, 209, 156, 1),
                      ),
                    ),

                  Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: isClicked ? Colors.blue : Colors.black,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
                  MaterialPageRoute(builder: (context) => const StartPage2()),
                );
              }
            : null,
        child: CircleAvatar(
          radius: 40,
          backgroundColor: const Color.fromRGBO(4, 4, 63, 1),
          child: const Icon(Icons.arrow_forward, color: Colors.white, size: 68),
        ),
      ),
    );
  }
}
