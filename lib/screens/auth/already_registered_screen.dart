import 'package:flutter/material.dart';

class AlreadyRegisteredScreen extends StatelessWidget {
  const AlreadyRegisteredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EEE9),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Monster left
                  Positioned(
                    left: -40,
                    bottom: -20,
                    child: IgnorePointer(
                      child: Image.asset(
                        "assets/images/green_monster_left.png",
                        width: 220,
                      ),
                    ),
                  ),

                  // Monster right
                  Positioned(
                    right: -40,
                    top: -60,
                    child: IgnorePointer(
                      child: Image.asset(
                        "assets/images/green_monster_right.png",
                        width: 200,
                      ),
                    ),
                  ),

                  // MAIN CONTENT
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),

                        // Back button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.black12,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                            ),
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

                        const SizedBox(height: 80),

                        Row(
                          children: const [
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Login to",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  "Start",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black54,
                                  ),
                                ),
                                Text(
                                  "Learning",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 28, right: 28),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Container(
                  height: 58,
                  width: double.infinity,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
