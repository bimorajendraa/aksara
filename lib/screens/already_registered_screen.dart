import 'package:flutter/material.dart';

class AlreadyRegisteredScreen extends StatelessWidget {
  const AlreadyRegisteredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EEE9),
      body: SafeArea(
        child: Stack(
          children: [
            // Monster left
            Positioned(
              left: -40,
              bottom: -20,
              child: Image.asset(
                "assets/images/green_monster_left.png",
                width: 220,
              ),
            ),

            // Monster right
            Positioned(
              right: -20,
              top: 140,
              child: Image.asset(
                "assets/images/green_monster_right.png",
                width: 200,
              ),
            ),

            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),

                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.black12,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: Image.asset(
                      "assets/images/aksara_logo.png",
                      width: 140,
                    ),
                  ),

                  const SizedBox(height: 50),

                  const Text(
                    "Your Account\nAlready\nRegistered",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Login to\nStart\nLearning",
                    style: TextStyle(
                      fontSize: 28,
                      fontStyle: FontStyle.italic,
                      height: 1.2,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Container(
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Center(
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
