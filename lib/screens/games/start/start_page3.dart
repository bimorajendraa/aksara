import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'start_page4.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final AudioPlayer _player = AudioPlayer();
  final SupabaseClient _supabase = Supabase.instance.client;
  final Map<String, String> _letterSoundUrl = {};
  bool _isSoundLoaded = false;

  final ScrollController _scrollController = ScrollController();

  final Map<String, GlobalKey> letterTextKeys = {
    "A": GlobalKey(),
    "I": GlobalKey(),
    "U": GlobalKey(),
    "E": GlobalKey(),
    "O": GlobalKey(),
  };

  double? popupLeft;
  double? popupTop;
  double popupWidth = 240;
  double popupHeight = 120;

  Future<void> _playLetterSound(String letter) async {
    if (!_isSoundLoaded) return;

    final key = letter.toLowerCase();
    final url = _letterSoundUrl[key];

    if (url == null) {
      debugPrint('Sound for letter $letter not found');
      return;
    }

    await _player.stop();
    await _player.play(UrlSource(url));
  }


  Future<void> _fetchLetterSounds() async {
    try {
      final response = await _supabase
          .from('gamesounds')
          .select('description, audio_url');

      for (final item in response) {
        final description = item['description'] as String;
        final letter = description.split(' ').last.toLowerCase(); 
        _letterSoundUrl[letter] = item['audio_url'];
      }

      setState(() {
        _isSoundLoaded = true;
      });
    } catch (e) {
      debugPrint('Error fetching sounds (StartPage3): $e');
    }
  }


  @override
  void initState() {
    super.initState();

    _fetchLetterSounds();

    _scrollController.addListener(() {
      if (showTutorial) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndPositionPopup());
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureAndPositionPopup();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureAndPositionPopup();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _measureAndPositionPopup() {
    if (!showTutorial) return;

    if (pointerIndex < 0 || pointerIndex > 4) return;

    final listLetters = ["A", "I", "U", "E", "O"];
    final String currentLetter = listLetters[pointerIndex];

    final key = letterTextKeys[currentLetter];
    if (key == null) return;

    final ctx = key.currentContext;
    if (ctx == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndPositionPopup());
      return;
    }

    final render = ctx.findRenderObject() as RenderBox;
    final safePadding = MediaQuery.of(context).padding.top;

    final letterOffset = render.localToGlobal(Offset.zero) - Offset(0, safePadding);
    final size = render.size;
    final screenWidth = MediaQuery.of(context).size.width;

    final double cellBase = size.width * 2.0;
    popupWidth = cellBase.clamp(140.0, 320.0);
    popupHeight = popupWidth * 0.55;

    final double centerOfLetter = letterOffset.dx + size.width / 2;
    final double topOfLetter = letterOffset.dy;

    double left = centerOfLetter - popupWidth / 2;
    double top = topOfLetter - popupHeight - 10.0;

    left = left.clamp(8.0, screenWidth - popupWidth - 8.0);

    if (top < 8.0) {
      top = topOfLetter + size.height + 10.0;
    }

    setState(() {
      popupLeft = left;
      popupTop = top;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth  = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // === STRUCTURE SCROLL ===
          SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.only(bottom: screenHeight * 0.02),
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight + 1),
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.015),
                    _buildHealthBar(screenWidth),
                    SizedBox(height: screenHeight * 0.005),
                    _buildPagination(screenWidth),
                    SizedBox(height: screenHeight * 0.02),
                    _buildTitle(screenWidth),
                    SizedBox(height: screenHeight * 0.06),
                    _buildLettersGrid(),
                    SizedBox(height: screenHeight * 0.12),
                    _buildNextButton(screenWidth, screenHeight),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
          ),

          // === TUTORIAL OVERLAY ===
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

  // ===== TUTORIAL POPUP  =====

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

  // ====================== POPUP HURUF ================================

  Widget letterPopup(String letter) {
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveWidth = screenWidth.clamp(320.0, 480.0);

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
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _playLetterSound(letter),
                  child: const Icon(
                    Icons.refresh,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ====================== TITLE ======================================

  Widget _buildTitle(double screenWidth) {
    final double titleSize = (screenWidth * 0.12).clamp(32.0, 60.0);

    return Column(
      children: [
        // VOCAL
        Stack(
          children: [
            Text(
              "VOCAL",
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
              "VOCAL",
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: screenWidth * 0.02),
        // LETTERS
        Stack(
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
        ),
      ],
    );
  }

  // ====================== HEALTH BAR =================================

  Widget _buildHealthBar(double screenWidth) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.only(
        top: screenHeight * 0.05,
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

  // ====================== PAGINATION =================================

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
              Navigator.pop(context);
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
                color: const Color.fromRGBO(4, 4, 63, 1),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(4, 4, 63, 1),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  // ====================== GRID AIUEO =================================

  Widget _buildLettersGrid() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Baris 1: A I U
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
        // Baris 2: E O
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 60),
            _buildLetterItem("E", 3),
            const SizedBox(width: 20),
            _buildLetterItem("O", 4),
            const SizedBox(width: 40),
          ],
        ),
      ],
    );
  }

  final Map<String, Offset> pointerOffsets = {
    "A": Offset(25, -5),
    "I": Offset(5, -5),
    "U": Offset(25, -5),
    "E": Offset(20, -5),
    "O": Offset(25, -5),
  };

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

        _playLetterSound(letter);

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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              letter,
              key: letterTextKeys[letter], 
              style: TextStyle(
                fontSize: 100,
                fontWeight: FontWeight.w700,
                color: isClicked ? Colors.blue : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ====================== NEXT BUTTON ================================

  Widget _buildNextButton(double screenWidth, double screenHeight) {
    bool isActive = selectedLetter != null;

    return Padding(
      padding: EdgeInsets.only(bottom: screenHeight * 0.3),
      child: GestureDetector(
        onTap: isActive
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StartPage4(),
                  ),
                );
              }
            : null,
        child: Container(
          alignment: Alignment.center,
          child: CircleAvatar(
            radius: (screenWidth * 0.09).clamp(38, 50),
            backgroundColor: const Color.fromRGBO(4, 4, 63, 1),
            child: Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: (screenWidth * 0.12).clamp(28, 48),
            ),
          ),
        ),
      ),
    );
  }
}
