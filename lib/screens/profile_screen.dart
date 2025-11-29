import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // =========================================
          // LAYER 1: KONTEN HALAMAN (Scrollable)
          // =========================================
          Positioned.fill(
            child: SingleChildScrollView(
              // Padding bawah besar (120) agar konten terbawah tidak tertutup Navbar
              padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. HEADER AVATAR (UPDATED: Monster Hijau & Tombol Edit Baru)
                    const _ProfileHeaderCard(),

                    const SizedBox(height: 25),

                    // 2. USER INFO
                    const _UserInfoSection(),

                    const SizedBox(height: 15),
                    Divider(thickness: 1, color: Colors.grey.shade200),
                    const SizedBox(height: 15),

                    // 3. ACHIEVEMENT SECTION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Achievement",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.w800, 
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/achievement');
                          },
                          child: const Text(
                            "See More...",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 5),
                    
                    // List Achievement (UPDATED: Asset Images & New Colors)
                    const _AchievementList(),

                    const SizedBox(height: 30),

                    // 4. RECENTLY READ SECTION
                    const Text(
                      "Recently Read",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    const _RecentlyReadList(),
                  ],
                ),
              ),
            ),
          ),

          // =========================================
          // LAYER 2: CUSTOM NAVBAR MELAYANG
          // =========================================
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: CustomFloatingNavBar(
              currentIndex: 3,
              onTap: (index) {
                if (index == 0) {
                   Navigator.pop(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// WIDGET: HEADER PROFILE (MONSTER HIJAU & EDIT BUTTON FIX)
// ==========================================================
class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      // PENTING: Clip.hardEdge memotong gambar kaki monster yang keluar batas
      clipBehavior: Clip.hardEdge, 
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50), // Navy Blue Background
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withOpacity(0.3),
            offset: const Offset(0, 8),
            blurRadius: 15,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // GAMBAR MONSTER HIJAU
          Positioned(
            // Top 35: Turun sedikit dari atas
            top: 35, 
            // Bottom -30: Ditarik ke bawah agar kaki terpotong
            bottom: -30, 
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/icons/Monster Hijau Profile.png',
              fit: BoxFit.contain, // Agar proporsi gambar tetap bagus
            ),
          ),
          
          // TOMBOL EDIT (WARNA & SHADOW BARU)
          Positioned(
            top: 15,
            right: 15,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/editalien');
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    // Warna Background C8D9E6
                    color: const Color(0xFFC8D9E6), 
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                    // Shadow Warna 4F6F94
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F6F94),
                        blurRadius: 0, // Hard Edge
                        offset: const Offset(4, 4), // Kanan Bawah
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.edit_rounded, color: Color(0xFF2F4156), size: 22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// WIDGET: USER INFO SECTION
// ==========================================================
class _UserInfoSection extends StatelessWidget {
  const _UserInfoSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      // Align END agar gerigi sejajar dengan teks bawah
      crossAxisAlignment: CrossAxisAlignment.end, 
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Maulana Sudrajat",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "JFikurikuri@gmail.com",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color.fromARGB(255, 21, 19, 72),
                decoration: TextDecoration.underline,
                decorationColor: const Color.fromARGB(255, 21, 19, 72),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Joined since 2005",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        
        // Settings Icon (Gerigi)
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0), 
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
            child: Image.asset(
              'assets/icons/gerigi.png',
              width: 32,
              height: 32,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================================
// WIDGET: ACHIEVEMENT LIST (Updated Colors & Assets)
// ==========================================================
class _AchievementList extends StatelessWidget {
  const _AchievementList();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _buildAchievementItem(
            assetPath: 'assets/icons/monster ingin tahu.png',
            color: const Color(0xFFFF6C6C), // Merah Soft
            title: "Ingin Tahu!",
            subtitle: "Ingin tahu 7 Kali",
            progress: 0.7,
            progressText: "7/10",
          ),
          Divider(color: Colors.grey.shade200, thickness: 1),
          _buildAchievementItem(
            assetPath: 'assets/icons/monster merah kaya pengetahuan.png',
            color: const Color(0xFF2DBCB7), // Tosca Soft
            title: "Kaya Pengetahuan!",
            subtitle: "Kaya akan pengetahuan 7 Kali",
            progress: 0.7,
            progressText: "7/10",
          ),
          Divider(color: Colors.grey.shade200, thickness: 1),
          _buildAchievementItem(
            assetPath: 'assets/icons/roket progresif.png',
            color: const Color(0xFFFFC44F), // Kuning Soft
            title: "Progresif!",
            subtitle: "Progresif 7 Kali",
            progress: 0.7,
            progressText: "7/10",
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem({
    required String assetPath, 
    required Color color,
    required String title,
    required String subtitle,
    required double progress,
    required String progressText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          // Icon Box
          Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                )
              ],
            ),
            child: Image.asset(
              assetPath, 
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    Text(
                      progressText,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFDAE4EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2C3E50)),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
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

// ==========================================================
// WIDGET: RECENTLY READ LIST
// ==========================================================
class _RecentlyReadList extends StatelessWidget {
  const _RecentlyReadList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 270,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _buildBookCard("The Tale of Melon City", "7 Pages", "Hard", "4.9"),
          const SizedBox(width: 20),
          _buildBookCard("The Tale of the Sin City", "7 Pages", "Hard", "4.5"),
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildBookCard(String title, String pages, String difficulty, String rating) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            offset: const Offset(0, 5),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: NetworkImage('https://via.placeholder.com/150'),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Color(0xFF2C3E50),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "($pages)",
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.grey[600],
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.access_time_filled_rounded, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                difficulty,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFD93D)),
              const SizedBox(width: 2),
              Text(
                rating,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// WIDGET: CUSTOM FLOATING NAVBAR
// ==========================================================
class CustomFloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomFloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // 1. BAR PUTIH
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                spreadRadius: 5,
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: Icons.home_rounded, index: 0),
              _buildNavItem(icon: Icons.menu_book_rounded, index: 1),
              const SizedBox(width: 50),
              // Achievement Icon using Asset
              _buildNavAssetItem(
                assetPath: 'assets/icons/achievement navbar.png', 
                index: 2
              ),
              _buildNavItem(icon: Icons.person_rounded, index: 3),
            ],
          ),
        ),

        // 2. TOMBOL SCAN
        Positioned(
          top: -25,
          child: GestureDetector(
            onTap: () => print("Scan Clicked"),
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFFD6E6F2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Color(0xFF2C3E50),
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({required IconData icon, required int index}) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Icon(
        icon,
        size: 28,
        color: isSelected ? const Color(0xFF4CA1AF) : Colors.grey.shade400,
      ),
    );
  }

  Widget _buildNavAssetItem({required String assetPath, required int index}) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Image.asset(
        assetPath,
        width: 28,
        height: 28,
        color: isSelected ? const Color(0xFF4CA1AF) : Colors.grey.shade400,
      ),
    );
  }
}