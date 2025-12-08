import 'package:flutter/material.dart';

class HelpMeScreen extends StatelessWidget {
  const HelpMeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const _HelpMeHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMenuCard(
                    context,
                    title: "Support Contact",
                    icon: Icons.headset_mic_outlined,
                    onTap: () {
                      Navigator.pushNamed(context, '/supportcontact');
                    },
                  ),
                  const SizedBox(height: 15),
                  _buildMenuCard(
                    context,
                    title: "Difficulties",
                    icon: Icons.description_outlined,
                    onTap: () {},
                  ),
                  const SizedBox(height: 15),
                  _buildMenuCard(
                    context,
                    title: "Questions",
                    icon: Icons.help_outline_rounded,
                    onTap: () {},
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Popular Questions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // pertanyaan
                  _buildFaqCard("What should I do if i forgot my password?"),
                  const SizedBox(height: 15),
                  _buildFaqCard("What happened if I want to delete my account"),
                  const SizedBox(height: 15),
                  _buildFaqCard("How to use Aksara?"),
                  const SizedBox(height: 15),
                  _buildFaqCard("Why does I couldn’t scan camera?"),
                  const SizedBox(height: 15),
                  _buildFaqCard("Is Aksara secure?"),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET BUILDER: Untuk Menu Atas (Ada Ikon di Kiri)
  Widget _buildMenuCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1), // Bayangan halus
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF2C3E50), size: 28),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF455A64),
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // WIDGET BUILDER: Untuk FAQ (Tanpa Ikon di Kiri)
  Widget _buildFaqCard(String question) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Logika buka detail pertanyaan
            print("Question clicked: $question");
          },
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF455A64),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- CUSTOM HEADER WIDGET ---
class _HelpMeHeader extends StatelessWidget {
  const _HelpMeHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 25, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Color(0xFFD6E6F2), // Warna biru muda
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            }, // Kembali ke Settings
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3E50), size: 24),
          ),
          const SizedBox(width: 15),
          const Text(
            "Help Me",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }
}