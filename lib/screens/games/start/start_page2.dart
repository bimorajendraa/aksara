import 'package:flutter/material.dart';
import 'start_page.dart';
import 'start_page3.dart';

class StartPage2 extends StatefulWidget {
  const StartPage2({super.key});

  @override
  State<StartPage2> createState() => _StartPageState2();
}

class _StartPageState2 extends State<StartPage2> {
  int hearts = 5;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // ukuran efektif agar layout tidak melebar berlebihan di laptop
    final effectiveWidth = screenWidth.clamp(320.0, 500.0).toDouble();
    final effectiveHeight = screenHeight.clamp(600.0, 900.0).toDouble();

    // ukuran tombol back yang disesuaikan dan dibatasi
    final double backSize = (screenWidth * 0.06).clamp(30.0, 38.0);
    final double backIconSize = (backSize * 0.6).clamp(20.0, 24.0);

    // margin horizontal sama dengan healthbar (w * 0.08)
    final double horizontalMargin = screenWidth * 0.08;

    return Scaffold(
      backgroundColor: const Color(0xff567c8d),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: effectiveHeight * 0.02),

              /// HEALTH BAR — mengikuti StartPage
              _buildHealthBar2(screenWidth, screenHeight),

              SizedBox(height: effectiveHeight * 0.02),

              /// BACK BUTTON — sejajar dengan ujung kiri healthbar dan ukurannya di-clamp
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: horizontalMargin),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: backSize,
                      height: backSize,
                      decoration: const BoxDecoration(
                        color: Color(0xFFB3BDC4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: backIconSize,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: effectiveHeight * 0.07),

              // semua isi berikut dibatasi max width agar rapi di layar besar
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    children: [
                      // TITLE
                      Text(
                        "Those are the 26\nletters",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: effectiveWidth * 0.075,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: effectiveHeight * 0.06),

                      // MONSTER IMAGE
                      SizedBox(
                        height: effectiveHeight * 0.22,
                        child: Image.asset(
                          "assets/images/monster_oren.png",
                          fit: BoxFit.contain,
                        ),
                      ),

                      SizedBox(height: effectiveHeight * 0.05),

                      // BUBBLE
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: effectiveWidth * 0.03),
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: effectiveWidth * 0.08,
                                vertical: effectiveHeight * 0.008,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.35),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                "now, what is a vocal letters?",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: effectiveWidth * 0.05,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),

                            Positioned(
                              left: -effectiveWidth * 0.015,
                              top: -effectiveHeight * 0.03,
                              child: Transform.rotate(
                                angle: -0.4,
                                child: Icon(
                                  Icons.question_mark,
                                  size: effectiveWidth * 0.10,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            Positioned(
                              right: -effectiveWidth * 0.015,
                              top: effectiveHeight * 0.015,
                              child: Transform.rotate(
                                angle: 0.2,
                                child: Icon(
                                  Icons.question_mark,
                                  size: effectiveWidth * 0.10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: effectiveHeight * 0.08),

                      // NEXT BUTTON
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const StartPage3()),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: effectiveHeight * 0.03),
                          width: effectiveWidth * 0.23,
                          height: effectiveWidth * 0.23,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.arrow_forward,
                              size: effectiveWidth * 0.15,
                              color: const Color(0xFF607D8B),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// HEALTH BAR sama persis seperti di StartPage: margin mengikuti screen width
  Widget _buildHealthBar2(double w, double h) {
    return Container(
      margin: EdgeInsets.only(
        top: h * 0.05,
        left: w * 0.08,
        right: w * 0.08,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
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
                padding: EdgeInsets.symmetric(horizontal: w * 0.01),
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
}
