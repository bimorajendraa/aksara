import 'package:flutter/material.dart';

class TermsConditionScreen extends StatelessWidget {
  const TermsConditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. HEADER
          const _TermsHeader(),

          // 2. SCROLLABLE CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  // --- TITLE UTAMA ---
                  Text(
                    "Terms and Conditions",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w800, // Extra Bold
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Welcome to Aksara! By using our services, you agree to the following Terms and Conditions. Please read them carefully.",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 20),

                  // --- POIN 1 ---
                  _TermsSection(
                    title: "1. Acceptance of Terms",
                    content: "By accessing and using our services, you agree to be bound by these Terms and Conditions. If you do not agree with any part of these terms, you may not use our services.",
                  ),

                  // --- POIN 2 ---
                  _TermsSection(
                    title: "2. Changes to the Terms",
                    content: "We reserve the right to modify or replace these Terms and Conditions at any time. Any changes will be effective immediately upon being posted on this page. It is your responsibility to review these terms periodically for updates. Your continued use of the service after any changes constitutes acceptance of those changes.",
                  ),

                  // --- POIN 3 ---
                  _TermsSection(
                    title: "3. Use of Services",
                    content: "You must use our services in compliance with all applicable laws and regulations. You agree not to:\n\n• Engage in any activity that could harm or disrupt the services.\n• Attempt to access the system or data of others without authorization.\n• Use the service for any unlawful or fraudulent purpose.",
                  ),

                  // --- POIN 4 ---
                  _TermsSection(
                    title: "4. User Account",
                    content: "If you create an account, you are responsible for maintaining the confidentiality of your login credentials and for all activities that occur under your account. You agree to notify us immediately of any unauthorized use of your account.",
                  ),

                  // --- POIN 5 ---
                  _TermsSection(
                    title: "5. Intellectual Property",
                    content: "All content, including text, images, and software, provided on the service is owned by [Your Company Name] or licensed by third parties. You may not reproduce, distribute, or use any content without our explicit consent.",
                  ),

                  // --- POIN 6 ---
                  _TermsSection(
                    title: "6. Termination",
                    content: "We reserve the right to terminate or suspend access to our services immediately, without prior notice, for any reason, including but not limited to breach of these Terms.",
                  ),

                  // --- POIN 7 ---
                  _TermsSection(
                    title: "7. Limitation of Liability",
                    content: "To the fullest extent permitted by law, Aksara will not be liable for any indirect, incidental, or consequential damages resulting from the use of our services.",
                  ),

                  // --- POIN 8 ---
                  _TermsSection(
                    title: "8. Governing Law",
                    content: "These Terms and Conditions are governed by and construed in accordance with the laws of Indonesia, and you submit to the exclusive jurisdiction of the courts in that location.",
                  ),

                  // --- POIN 9 ---
                  _TermsSection(
                    title: "9. Contact Us",
                    content: "If you have any questions or concerns about these Terms, please contact us at aksara@gmail.com",
                  ),
                  
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// WIDGET HELPER: TERMS SECTION (JUDUL + ISI)
// ==========================================================
class _TermsSection extends StatelessWidget {
  final String title;
  final String content;

  const _TermsSection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.black87,
              height: 1.6, // Spasi baris agar mudah dibaca
            ),
            textAlign: TextAlign.justify, // Rata kiri-kanan (opsional)
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// HEADER TERMS (DIPERBAIKI SPACINGNYA)
// ==========================================================
class _TermsHeader extends StatelessWidget {
  const _TermsHeader();

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 20;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 25),
      decoration: const BoxDecoration(
        color: Color(0xFFD6E6F2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
               if (Navigator.canPop(context)) {
                 Navigator.pop(context);
               } else {
                 Navigator.pushReplacementNamed(context, '/settings'); 
               }
             },
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3E50), size: 24),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Text(
              "Terms & Conditions", // Judul Header
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
              overflow: TextOverflow.ellipsis, // Agar tidak error jika teks kepanjangan
            ),
          ),
        ],
      ),
    );
  }
}