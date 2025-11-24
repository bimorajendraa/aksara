import 'package:flutter/material.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background dasar putih
      body: Column(
        children: [
          // 1. CUSTOM HEADER (Biru Muda Lengkung)
          const _CustomHeader(),

          // 2. KONTEN SCROLLABLE
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul Halaman Konten
                  const Text(
                    "All Achievement",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Container Besar untuk List Achievement
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                    ),
                    // Menggunakan ListView.separated agar ada garis pemisah otomatis
                    child: ListView.separated(
                      padding: const EdgeInsets.all(0), // Padding diatur di dalam item
                      physics: const NeverScrollableScrollPhysics(), // Agar scroll ikut parent
                      shrinkWrap: true, // Agar tinggi menyesuaikan konten
                      itemCount: dummyAchievements.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1),
                      itemBuilder: (context, index) {
                        final item = dummyAchievements[index];
                        return _AchievementItem(data: item);
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// components
class _CustomHeader extends StatelessWidget {
  const _CustomHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 25, left: 10, right: 20),
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
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3E50)),
          ),
          const SizedBox(width: 5),
          const Text(
            "Achievement",
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

class _AchievementItem extends StatelessWidget {
  final AchievementData data;

  const _AchievementItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: data.color,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(data.icon, color: Colors.white, size: 35),
          ),
          const SizedBox(width: 15),

          // progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      data.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "${data.current}/${data.target}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: data.current / data.target,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFDAE4EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2C3E50)),
                  ),
                ),
                
                const SizedBox(height: 6),

                Text(
                  data.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class AchievementData {
  final String title;
  final String subtitle;
  final int current;
  final int target;
  final Color color;
  final IconData icon;

  AchievementData({
    required this.title,
    required this.subtitle,
    required this.current,
    required this.target,
    required this.color,
    required this.icon,
  });
}

final List<AchievementData> dummyAchievements = [
  AchievementData(
    title: "Ingin Tahu!",
    subtitle: "Ingin tahu 7 Kali",
    current: 7,
    target: 10,
    color: const Color(0xFFFF6B6B),
    icon: Icons.help_outline_rounded,
  ),
  AchievementData(
    title: "Kaya Pengetahuan!",
    subtitle: "Kaya akan pengetahuan 7 Kali",
    current: 5,
    target: 10,
    color: const Color(0xFF1DD1A1),
    icon: Icons.emoji_events_rounded,
  ),
  AchievementData(
    title: "Progresif!",
    subtitle: "Progresif 7 Kali",
    current: 7,
    target: 10,
    color: const Color(0xFFFFD93D),
    icon: Icons.rocket_launch_rounded,
  ),
  AchievementData(
    title: "Ingin Tahu!",
    subtitle: "Ingin tahu 7 Kali",
    current: 9,
    target: 10,
    color: const Color(0xFFFF6B6B),
    icon: Icons.help_outline_rounded,
  ),
  AchievementData(
    title: "Ingin Tahu!",
    subtitle: "Ingin tahu 7 Kali",
    current: 7,
    target: 10,
    color: const Color(0xFF1DD1A1),
    icon: Icons.emoji_events_rounded,
  ),
  AchievementData(
    title: "Ingin Tahu!",
    subtitle: "Ingin tahu 7 Kali",
    current: 2,
    target: 10,
    color: const Color(0xFFFFD93D),
    icon: Icons.rocket_launch_rounded,
  ),
  AchievementData(
    title: "Ingin Tahu!",
    subtitle: "Ingin tahu 7 Kali",
    current: 5,
    target: 10,
    color: const Color(0xFFFF6B6B),
    icon: Icons.help_outline_rounded,
  ),
   AchievementData(
    title: "Ingin Tahu!",
    subtitle: "Ingin tahu 7 Kali",
    current: 7,
    target: 10,
    color: const Color(0xFF1DD1A1),
    icon: Icons.emoji_events_rounded,
  ),
   AchievementData(
    title: "Ingin Tahu!",
    subtitle: "Ingin tahu 7 Kali",
    current: 1,
    target: 10,
    color: const Color(0xFFFFD93D),
    icon: Icons.rocket_launch_rounded,
  ),
];