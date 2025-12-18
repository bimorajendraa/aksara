import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ====================== SUPABASE SERVICES ======================
import 'package:aksara/services/user_loader_service.dart';
import 'package:aksara/services/user_session.dart';

class SpellBeePage2 extends StatefulWidget {
  const SpellBeePage2({super.key});

  @override
  State<SpellBeePage2> createState() => _SpellBeePageState();
}

class _GridText extends StatelessWidget {
  final String text;
  final Color color;

  const _GridText(this.text, this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}

class _SpellBeePageState extends State<SpellBeePage2> {
  final String answer = "CAT";
  String? errorMessage;
  String? highlightedLetter;
  final AudioPlayer _player = AudioPlayer();  
  final SupabaseClient _supabase = Supabase.instance.client;
  final Map<String, String> _syllableSoundUrl = {};
  bool _isSoundLoaded = false;


  List<Color> gridColors = List.filled(9, Colors.black);

  final List<String> gridLetters = [
    "ZE", "BA", "SU",
    "XY", "JI", "HY",
    "FT", "DB", "KO",
  ];

  final List<String> validSyllables = ["ZE", "BA", "SU", "JI", "KO"];
  List<String> selectedSyllables = [];

  Future<void> _playSyllableSound(String text) async {
    if (!_isSoundLoaded) return;

    final key = text.toLowerCase();
    final url = _syllableSoundUrl[key];

    if (url == null) {
      debugPrint('Sound for syllable $text not found');
      return;
    }

    await _player.stop();
    await _player.play(UrlSource(url));
  }

  Future<void> _fetchSyllableSounds() async {
    try {
      final response = await _supabase
          .from('gamesounds')
          .select('description, audio_url');

      for (final item in response) {
        final description = item['description'] as String;

        final syllable = description.split(' ').last.toLowerCase();
        _syllableSoundUrl[syllable] = item['audio_url'];
      }

      setState(() {
        _isSoundLoaded = true;
      });
    } catch (e) {
      debugPrint('Error fetching syllable sounds: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchSyllableSounds();
  }

  // ====================== LOAD USER ID ============================
  Future<void> _loadUser() async {
    await UserLoaderService.instance.loadUserId();
    print("🟦 SPELLBEE 2: User ID = ${UserSession.instance.idAkun}");
  }
  // ================================================================

  bool isValidSyllable(String text) {
    return validSyllables.contains(text);
  }

  void onGridTap(int index) {
    final tapped = gridLetters[index];

    if (!isValidSyllable(tapped)) {
      showFloatingError();
      return;
    }

    _playSyllableSound(tapped);

    setState(() {
      gridColors[index] = Colors.blue;
      if (!selectedSyllables.contains(tapped)) {
        selectedSyllables.add(tapped);
      }
    });

    if (selectedSyllables.length == validSyllables.length) {
      _onGameCompleted();   // <= MANGGIL SUPABASE UPDATE
    }
  }

  // ============ UPDATE SUPABASE PROGRESS + LEVEL ===================
  Future<void> _onGameCompleted() async {
    final id = UserSession.instance.idAkun;
    showCompletionPopup();
  }
  // ================================================================

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
              ),
            )
          ],
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context);  // tutup popup
      Navigator.pop(context);  // balik ke home
    }
  }

  // ❗ Floating overlay
  void showFloatingError() {
    setState(() => errorMessage = "Not a syllable!");

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => errorMessage = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F2ED),
      body: SafeArea(
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Stack(
              children: [
                Column(
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
                      "Choose the right Syllabels",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      height: 200,
                      child: Image.asset(
                        "assets/images/monster_merah_mengkaget.png",
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      height: 490,
                      width: 500,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          IgnorePointer(
                            child: Image.asset(
                              "assets/images/template-puzzle.png",
                              fit: BoxFit.contain,
                            ),
                          ),

                          Positioned.fill(
                            child: Transform.translate(
                              offset: const Offset(0, 5),
                              child: Center(
                                child: SizedBox(
                                  width: 300,
                                  height: 290,
                                  child: GridView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 30,
                                      crossAxisSpacing: 30,
                                    ),
                                    itemCount: 9,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () => onGridTap(index),
                                        child: Center(
                                          child: Text(
                                            gridLetters[index],
                                            style: TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.w700,
                                              color: gridColors[index],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (errorMessage != null)
                  Positioned(
                    top: 430,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: errorMessage != null ? 1 : 0,
                        duration: const Duration(milliseconds: 150),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        ),
      ),
    );
  }
}
