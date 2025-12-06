import 'package:flutter/material.dart';
import '../../home/home_screen.dart';
import 'start_page3.dart';

class StartPage4 extends StatefulWidget {
  const StartPage4({super.key});

  @override
  State<StartPage4> createState() => _StartPageState2();
}

class _StartPageState2 extends State<StartPage4> {
  int hearts = 5; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff567c8d),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            _buildHealthBar2(),

            const SizedBox(height: 15),

            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 35),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.5),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
              ),
            ),


            const SizedBox(height: 120),

            // ---------------- TITLE ----------------
            const Text(
              "Now unlock unit 1 and let’s practice what you have learned",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),

            // ---------------- MONSTER / CHARACTER ----------------
            Padding(
              padding: const EdgeInsets.only(left: 235), // geser ke kanan
              child: SizedBox(
                height: 300,
                child: Image.asset(
                  "assets/images/monster_oren_kanan.png",
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // ---------------- NEXT BUTTON ----------------
            GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
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