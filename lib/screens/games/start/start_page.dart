import 'package:flutter/material.dart';
import '../../home/home_screen.dart';
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
  int pointerIndex = 0; // target pertama = index 0 (A)
  String? selectedLetter;
  int currentPage = 0;
  final letters = List<String>.generate(26, (i) => String.fromCharCode(65 + i));
  final Set<String> clickedLetters = {};
  final ScrollController _scrollController = ScrollController();

  // GlobalKeys untuk setiap TEXT (huruf) agar bisa diukur posisinya
  final List<GlobalKey> letterTextKeys = List.generate(26, (_) => GlobalKey());

  // Popup measurement results
  double? popupLeft;
  double? popupTop;
  double popupWidth = 240;
  double popupHeight = 120;

  @override
  void initState() {
    super.initState();

    // tambahkan listener supaya popup ikut bergeser saat user scroll
    _scrollController.addListener(() {
      if (showTutorial) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndPositionPopup());
      }
    });

    // Schedule measurement setelah widget pertama kali build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureAndPositionPopup();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Setelah dependency berubah (mis. orientation), ukur ulang
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureAndPositionPopup();
    });
  }

  // Panggil ini tiap kali pointerIndex berubah atau saat ingin tampilkan popup
  void _measureAndPositionPopup() {
    if (!showTutorial) return;

    // Pastikan index valid
    if (pointerIndex < 0 || pointerIndex >= letterTextKeys.length) return;

    final key = letterTextKeys[pointerIndex];
    final ctx = key.currentContext;

    if (ctx == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndPositionPopup());
      return;
    }

    final render = ctx.findRenderObject() as RenderBox;

    // Ambil posisi huruf (text) secara akurat
    final safePadding = MediaQuery.of(context).padding.top;
    final letterOffset = render.localToGlobal(Offset.zero) - Offset(0, safePadding);

    final size = render.size;
    final screenWidth = MediaQuery.of(context).size.width;

    // ukuran popup berdasarkan ukuran huruf (agar mengikuti cell), batasi supaya tidak terlalu besar
    final double cellBase = size.width * 2.0; // dasar ukuran popup dari lebar huruf
    popupWidth = cellBase.clamp(140.0, 320.0);
    popupHeight = popupWidth * 0.55;

    // posisi berdasarkan huruf (bukan container)
    final double centerOfLetter = letterOffset.dx + render.size.width / 2;
    final double topOfLetter = letterOffset.dy;

    double left = centerOfLetter - popupWidth / 2;
    double top = topOfLetter - popupHeight - 10.0; // jarak 10px rapat

    // koreksi tepi layar
    left = left.clamp(8.0, screenWidth - popupWidth - 8.0);

    // kalau kepentok atas, tampilkan di bawah huruf
    if (top < 8.0) {
      top = topOfLetter + render.size.height + 10.0;
    }

    setState(() {
      popupLeft = left;
      popupTop = top;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.only(bottom: screenHeight * 0.02),
            physics: const BouncingScrollPhysics(),
            child: SafeArea(
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.015),
                  _buildHealthBar(screenWidth),
                  SizedBox(height: screenHeight * 0.005),
                  _buildPagination(screenWidth),
                  SizedBox(height: screenHeight * 0.02),
                  _buildTitle(screenWidth),
                  SizedBox(height: screenHeight * 0.02),
                  _buildLettersGrid(screenWidth, screenHeight), // Grid non-scrollable
                  SizedBox(height: screenHeight * 0.01),
                  _buildNextButton(screenWidth, screenHeight),
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ),

          // Tutorial overlay (gunakan measured popupLeft & popupTop)
          if (showTutorial)
            AnimatedOpacity(
              opacity: 1,
              duration: const Duration(milliseconds: 250),
              child: IgnorePointer(
                ignoring: false,
                child: _buildTutorialPopup(screenWidth, screenHeight),
              ),
            ),
        ],
      ),
    );
  }

  // TUTORIAL POPUP ====================================================
  Widget _buildTutorialPopup(double screenWidth, double screenHeight) {
    if (popupLeft == null || popupTop == null) return const SizedBox();

    return GestureDetector(
      onTap: () => setState(() => showTutorial = false),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color.fromRGBO(86, 124, 141, 0.45),
          ),

          // POPUP
          Positioned(
            left: popupLeft,
            top: popupTop,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: popupWidth,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(86, 124, 141, 1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    "Click the letter",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: (popupWidth * 0.16).clamp(14, 22),
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // SEGITIGA PENUNJUK
                Positioned(
                  bottom: -12,
                  left: popupWidth * 0.45,
                  child: ClipPath(
                    clipper: _TopRightTriangleClipper(),
                    child: Container(
                      width: 22,
                      height: 22,
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
    final screenWidth = MediaQuery.of(context).size.width;

    // BATAS ukuran popup biar tidak terlalu besar di laptop
    final effectiveWidth = screenWidth.clamp(320, 480).toDouble();

    return Container(
      width: effectiveWidth * 0.8,
      height: effectiveWidth * 0.8,
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
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: effectiveWidth * 0.20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      letter.toLowerCase(),
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: effectiveWidth * 0.20,
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
  Widget _buildTitle(double screenWidth) {
    double titleSize = (screenWidth * 0.12).clamp(32.0, 60.0);

    return Stack(
      children: [
        Text(
          "LETTERS",
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = Colors.black,
          ),
        ),
        Text(
          "LETTERS",
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // HEALTH BAR ========================================================
  Widget _buildHealthBar(double screenWidth) {
    return Container(
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.05,
        left: screenWidth * 0.08,
        right: screenWidth * 0.08,
      ),
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 10),
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
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                child: Icon(
                  index < hearts ? Icons.favorite : Icons.favorite_border_rounded,
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
          ),
        ],
      ),
    );
  }

  // PAGINATION ========================================================
  Widget _buildPagination(double screenWidth) {
    return Container(
      margin: EdgeInsets.only(
        top: 10,
        left: screenWidth * 0.08,
        right: screenWidth * 0.05,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
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
                color: currentPage == 0 ? const Color.fromRGBO(4, 4, 63, 1) : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: currentPage == 1 ? const Color.fromRGBO(4, 4, 63, 1) : Colors.grey.shade400,
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
  Widget _buildLettersGrid(double screenWidth, double screenHeight) {
    final letters = this.letters;
    final Set<int> skippedIndexes = {24};
    final int gridCount = letters.length + skippedIndexes.length;
    final double cellWidth = screenWidth * 0.8 / 4;
    final double cellHeight = cellWidth * 1.2;

    int skippedBefore(int gridIndex) {
      return skippedIndexes.where((s) => s < gridIndex).length;
    }

    return GridView.builder(
      shrinkWrap: true, // penting agar GridView menyesuaikan tinggi kontennya
      physics: const NeverScrollableScrollPhysics(), // biar scroll di SingleChildScrollView
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.2,
      ),
      itemCount: gridCount,
      itemBuilder: (context, gridIndex) {
        if (skippedIndexes.contains(gridIndex)) return Container();
        final int letterIndex = gridIndex - skippedBefore(gridIndex);
        final letter = letters[letterIndex];
        final bool isClicked = clickedLetters.contains(letter);

        return GestureDetector(
          onTap: () {
            if (showTutorial) setState(() => showTutorial = false);
            setState(() {
              selectedLetter = letter;
              progress = (letterIndex + 1) / letters.length;
              clickedLetters.add(letter);

              int nextLetterIndex = letterIndex + 1;
              if (nextLetterIndex < letters.length) {
                int nextGridIndex = nextLetterIndex;
                for (int skip in skippedIndexes) {
                  if (skip <= nextGridIndex) nextGridIndex++;
                }
                pointerIndex = nextGridIndex;
                // ukur ulang posisi popup untuk pointerIndex baru
                WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndPositionPopup());
              } else {
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
          // apply the key to the TEXT widget that represents the letter (presisi)
          child: Container(
            padding: EdgeInsets.only(top: screenHeight * 0.02),
            child: Stack(
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              children: [
                if (pointerIndex == gridIndex && !showTutorial)
                  Positioned(
                    top: cellHeight * 0.45,
                    left: cellWidth * 0.33,
                    child: Icon(
                      Icons.pan_tool_alt,
                      size: cellWidth * 0.35,
                      color: const Color.fromRGBO(252, 209, 156, 1),
                    ),
                  ),

                Center(
                  child: Text(
                    letter,
                    key: letterTextKeys[letterIndex], // <-- key disini
                    style: TextStyle(
                      fontSize: (screenWidth * 0.10).clamp(26.0, 48.0),
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
  Widget _buildNextButton(double screenWidth, double screenHeight) {
    bool isActive = clickedLetters.length == letters.length;

    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.05),
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
          radius: screenWidth * 0.11,
          backgroundColor: isActive ? const Color.fromRGBO(4, 4, 63, 1) : Colors.grey,
          child: Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: screenWidth * 0.17,
          ),
        ),
      ),
    );
  }
}
