import 'package:flutter/material.dart';

class StartPage2 extends StatefulWidget {
  const StartPage2({super.key});

  @override
  State<StartPage2> createState() => _StartPageState2();
}

class _StartPageState2 extends State<StartPage2> {
  int hearts = 5; // sama seperti start_page pertama

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff567c8d),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ---------------- HEALTH BAR (versi yang benar) ----------------
            _buildHealthBar2(),

            const SizedBox(height: 15),

            // ---------------- Back Button ----------------
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 35),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.5),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 70),

            // ---------------- TITLE ----------------
            const Text(
              "Those are the 26\nletters",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 70),

            // ---------------- MONSTER / CHARACTER ----------------
            SizedBox(
              height: 180,
              child: Image.asset(
                "assets/images/monster_oren.png",
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 40),

            // ---------------- QUESTION BUBBLE ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                clipBehavior: Clip.none, // <-- penting: biar widget boleh keluar area stack
                alignment: Alignment.center,
                children: [
                  // Bubble teks
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Text(
                      "now, what is a vocal letters?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  Positioned(
                    left: -3,
                    top: -20,
                    child: Column(
                      children: [
                        Transform.rotate(
                          angle: -0.4, // semakin besar nilai → semakin miring
                          child: const Icon(Icons.question_mark, color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 30)
                      ],
                    ),
                  ),

                  Positioned(
                    right: -3,
                    top: 18,
                    child: Column(
                      children: [
                        Transform.rotate(
                          angle: 0.2,
                          child: const Icon(Icons.question_mark, color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 2)
                      ],
                    ),
                  ),
                ],
              ),
            ),


            const SizedBox(height: 100),


            // ---------------- NEXT BUTTON ----------------
            GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.only(bottom: 30),
                width: 95,
                height: 95,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.arrow_forward,
                    color: Color(0xFF607D8B),
                    size: 68,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthBar2() {
    return Container(
      margin: const EdgeInsets.only(top: 40, left: 30, right: 30),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xffc8d9e6),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // HEARTS
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

          // COIN
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
}
