import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ====================== SUPABASE SERVICES ======================
import 'package:aksara/services/user_loader_service.dart';
import 'package:aksara/services/user_session.dart';
import 'package:aksara/services/game_progress_service.dart';
import 'package:aksara/services/level_progress_service.dart';
// ================================================================

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
  final SupabaseClient _supabase = Supabase.instance.client;
  final Map<String, String> _letterSoundUrl = {};
  bool _isSoundLoaded = false;                 
  List<String?> userAnswer = ["", "", ""];

  @override
  void initState() {
    super.initState();
    _loadUser(); 
    _fetchLetterSounds();  
  }

  Future<void> _loadUser() async {
    await UserLoaderService.instance.loadUserId();
    print("🟦 SPELLBEE: ID Loaded = ${UserSession.instance.idAkun}");
  }

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
      debugPrint('Error fetching sounds (SpellBee): $e');
    }
  }

  void _calculateErrorPosition() {
    final render = _inputKey.currentContext?.findRenderObject() as RenderBox?;
    if (render == null) return;

    final offset = render.localToGlobal(Offset.zero);
    setState(() => errorTop = offset.dy + render.size.height + 8);
  }

  void selectLetter(String letter) {
    _playLetterSound(letter);

    int index = userAnswer.indexOf("");

    if (index == -1) return;

    if (letter == answer[index]) {
      setState(() {
        userAnswer[index] = letter;
        errorMessage = null;
        highlightedLetter = letter;
      });

      checkIfCompleted();
    } else {
      showFloatingError();
      setState(() => highlightedLetter = null);
    }
  }

  Future<void> _onGameCompleted() async {
    final id = UserSession.instance.idAkun;

    if (id != null) {
      print("🟢 SPELLBEE COMPLETE → Updating Supabase progress...");

      await GameProgressService.instance.updateAggregatedProgress(
        idAkun: id,
        gameKey: "spellbee",
        isCorrect: true,
      );

      final before = await LevelProgressService.instance.getCurrentLevel(id);
      final next = await LevelProgressService.instance.incrementLevel(id);

      print("🏆 LEVEL UP: $before → $next");
    }

    showCompletionPopup();
  }

  void checkIfCompleted() {
    if (!userAnswer.contains("")) {
      _onGameCompleted();
    }
  }

  void showFloatingError() {
    setState(() => errorMessage = "Wrong letter!");
    _calculateErrorPosition();

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => errorMessage = null);
    });
  }

  void showCompletionPopup() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.white.withOpacity(0.02),
              ),
            ),
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

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context);    // tutup popup
      Navigator.pop(context);    // balik ke home
    }
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
                      key: _inputKey,
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
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            
            if (errorMessage != null)
              Positioned(
                top: errorTop,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: errorMessage != null ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
}

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
