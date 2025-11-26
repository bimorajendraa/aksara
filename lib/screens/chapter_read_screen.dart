import 'package:flutter/material.dart';

class ChapterReadScreen extends StatelessWidget {
  const ChapterReadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EEE9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, size: 30),
              ),
              const SizedBox(height: 20),

              const Center(
                child: Text(
                  "Chapter One",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: const [
                      Text(
                        """Once upon a time, in Sherwood Forest, there lived a legendary hero named Robin Hood. 
He was an outlaw, a skilled archer, and the leader of a band of merry men...""",
                        style: TextStyle(fontSize: 20, height: 1.5),
                      ),

                      SizedBox(height: 40),

                      Icon(Icons.volume_up, size: 55),
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
}
