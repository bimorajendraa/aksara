import 'package:flutter/material.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, 
      body: Column(
        children: [
          // 1. CUSTOM HEADER
          const _CustomHeader(),

          // 2. KONTEN SCROLLABLE
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "All Achievement",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Container Besar List
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(0), 
                      physics: const NeverScrollableScrollPhysics(), 
                      shrinkWrap: true, 
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

// --- COMPONENTS ---

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
              fontFamily: 'Poppins',
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
          // KOTAK GAMBAR
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(10), // Padding agar gambar tidak mepet pinggir
            decoration: BoxDecoration(
              color: data.color,
              borderRadius: BorderRadius.circular(15),
            ),
            // Menggunakan Image.asset sesuai request
            child: Image.asset(
              data.assetPath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 15),

          // TEXT & PROGRESS
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
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "${data.current}/${data.target}",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
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
                    fontFamily: 'Poppins',
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

// --- DATA MODEL ---

class AchievementData {
  final String title;
  final String subtitle;
  final int current;
  final int target;
  final Color color;
  final String assetPath; // Ubah dari IconData ke String Path Gambar

  AchievementData({
    required this.title,
    required this.subtitle,
    required this.current,
    required this.target,
    required this.color,
    required this.assetPath,
  });
}

// --- DUMMY DATA LIST ---

final List<AchievementData> dummyAchievements = [
  AchievementData(
    title: "Ingin Tahu!",
    subtitle: "Ingin tahu 7 Kali",
    current: 7,
    target: 10,
    color: const Color(0xFFFF6C6C), // Merah Soft
    assetPath: 'assets/icons/monster ingin tahu.png',
  ),
  AchievementData(
    title: "Kaya Pengetahuan!",
    subtitle: "Kaya akan pengetahuan 7 Kali",
    current: 5,
    target: 10,
    color: const Color(0xFF2DBCB7), // Tosca Soft
    assetPath: 'assets/icons/monster merah kaya pengetahuan.png',
  ),
  AchievementData(
    title: "Progresif!",
    subtitle: "Progresif 7 Kali",
    current: 7,
    target: 10,
    color: const Color(0xFFFFC44F), // Yellow Soft
    assetPath: 'assets/icons/monster pink progresif.png',
  ),
  // Mengulang data untuk list panjang (sesuai contoh sebelumnya)
  AchievementData(
    title: "Ingin Tahu!",
    subtitle: "Ingin tahu 7 Kali",
    current: 9,
    target: 10,
    color: const Color(0xFFFF6C6C),
    assetPath: 'assets/icons/monster ingin tahu.png',
  ),
  AchievementData(
    title: "Kaya Pengetahuan!",
    subtitle: "Kaya akan pengetahuan 7 Kali",
    current: 7,
    target: 10,
    color: const Color(0xFF2DBCB7),
    assetPath: 'assets/icons/monster merah kaya pengetahuan.png',
  ),
  AchievementData(
    title: "Progresif!",
    subtitle: "Progresif 7 Kali",
    current: 2,
    target: 10,
    color: const Color(0xFFFFC44F),
    assetPath: 'assets/icons/monster pink progresif.png',
  ),
  AchievementData(
    title: "Ingin Tahu!",
    subtitle: "Ingin tahu 7 Kali",
    current: 5,
    target: 10,
    color: const Color(0xFFFF6C6C),
    assetPath: 'assets/icons/monster ingin tahu.png',
  ),
   AchievementData(
    title: "Kaya Pengetahuan!",
    subtitle: "Kaya akan pengetahuan 7 Kali",
    current: 7,
    target: 10,
    color: const Color(0xFF2DBCB7),
    assetPath: 'assets/icons/monster merah kaya pengetahuan.png',
  ),
   AchievementData(
    title: "Progresif!",
    subtitle: "Progresif 7 Kali",
    current: 1,
    target: 10,
    color: const Color(0xFFFFC44F),
    assetPath: 'assets/icons/monster pink progresif.png',
  ),
];