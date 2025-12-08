import 'dart:ui';
import 'package:flutter/material.dart';

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
  final String answer = "CAT"; // jawaban (tidak dipakai di sini)
  String? errorMessage;
  String? highlightedLetter;

  // warna awal semua hitam
  List<Color> gridColors = List.filled(9, Colors.black);

  final List<String> gridLetters = [
    "ZE", "BA", "SU",
    "XY", "JI", "HY",
    "FT", "DB", "KO",
  ];

  // Hanya syllable ini yang dianggap valid & boleh di-click
  final Set<String> allowedSyllables = {"ZE", "BA", "SU", "JI", "KO"};
  final List<String> validSyllables = ["ZE", "BA", "SU", "JI", "KO"];

  // track syllabel yg sudah dipilih
  List<String> selectedSyllables = [];

  bool isValidSyllable(String text) {
    return validSyllables.contains(text);
  }

  void onGridTap(int index) {
    final tapped = gridLetters[index];

    // Jika bukan syllabel valid → error
    if (!isValidSyllable(tapped)) {
      showFloatingError();
      return;
    }

    // Jika valid → ubah warna menjadi biru permanen
    setState(() {
      gridColors[index] = Colors.blue;

      if (!selectedSyllables.contains(tapped)) {
        selectedSyllables.add(tapped);
      }
    });

    // Cek apakah semua syllabel valid sudah dipencet
    if (selectedSyllables.length == validSyllables.length) {
      showCompletionPopup();
  }
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
            child: AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              child: Image.asset(
                "assets/images/yeay_correct.png",
                width: 700,
                height: 700,
              ),
            )
          )
        ],
      );
    },
  );

  await Future.delayed(const Duration(seconds: 2));

  if (mounted) {
    Navigator.pushReplacementNamed(context, "/home");
  }
}

  // 🟥 ERROR MELAYANG (Overlay)
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
                                    behavior: HitTestBehavior.translucent,
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

            // Floating error (tidak menggeser layout)
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
    );
  }
}
