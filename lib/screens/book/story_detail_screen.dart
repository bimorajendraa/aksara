import 'package:flutter/material.dart';

class StoryDetailScreen extends StatelessWidget {
  const StoryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final book = ModalRoute.of(context)!.settings.arguments as Map;

    return Scaffold(
      backgroundColor: const Color(0xFFD3E3EF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 15),

                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, size: 30),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    book["image"],
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  book["title"],
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/chapter'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Center(
                      child: Text(
                        "Continue Reading",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                buildChapterProgress("Chapter One", 0.6),
                buildChapterProgress("Chapter Two", 0.0),
                buildChapterProgress("Chapter Three", 0.0),
                buildChapterProgress("Chapter Four", 0.0),
                buildChapterProgress("Chapter Five", 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildChapterProgress(String title, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: value,
                    color: const Color(0xFF2F4156),
                    backgroundColor: Colors.white,
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text("${(value * 100).toInt()} %"),
            ],
          ),
        ],
      ),
    );
  }
}