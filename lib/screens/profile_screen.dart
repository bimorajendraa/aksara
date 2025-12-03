import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                              color: Color(0xFF2F4156),
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
                        offset: const Offset(-4, 4), // Kanan Bawah
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
                color: const Color(0xFF2F4156),
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
                color: Color(0xFF2F4156),
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
              color: Color(0xFF2F4156),
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
      // 1. HAPUS PADDING DI SINI AGAR DIVIDER BISA FULL
      // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), 
      
      // Tambahkan clip agar anak-anak container mengikuti sudut bulat (rounded)
      clipBehavior: Clip.hardEdge, 
      
      child: Column(
        children: [
          _buildAchievementItem(
            assetPath: 'assets/icons/monster ingin tahu.svg',
            color: const Color(0xFFFF6C6C),
            title: "Ingin Tahu!",
            subtitle: "Ingin tahu 7 Kali",
            progress: 0.7,
            progressText: "7/10",
            isSvg: true,
            svgScale: 1.6,
            svgOffsetX: 2.0,
            svgOffsetY: -2.8,
          ),
          
          // Divider Full Width (Tanpa indent)
          Divider(color: Colors.grey.shade200, thickness: 1, height: 1),
          
          _buildAchievementItem(
            assetPath: 'assets/icons/monster merah kaya pengetahuan.svg',
            color: const Color(0xFF2DBCB7),
            title: "Kaya Pengetahuan!",
            subtitle: "Kaya akan pengetahuan 7 Kali",
            progress: 0.7,
            progressText: "7/10",
            isSvg: true,
            svgScale: 1.4,
            svgOffsetY: -1.5,
          ),
          
          Divider(color: Colors.grey.shade200, thickness: 1, height: 1),
          
          _buildAchievementItem(
            assetPath: 'assets/icons/monster pink rocket.svg',
            color: const Color(0xFFFFC44F),
            title: "Progresif!",
            subtitle: "Progresif 7 Kali",
            progress: 0.7,
            progressText: "7/10",
            isSvg: true,
            svgScale: 1.4,
            svgOffsetY: -1,
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
    bool isSvg = false,
    double svgOffsetX = 0.0,
    double svgOffsetY = 0.0,
    double svgScale = 1.0,
  }) {
    // 2. PINDAHKAN PADDING KE SINI
    // Agar konten teks tetap rapi masuk ke dalam, tapi divider di luar tetap full
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
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
            child: isSvg
                ? Transform.translate(
                    offset: Offset(svgOffsetX, svgOffsetY),
                    child: Transform.scale(
                      scale: svgScale,
                      child: SvgPicture.asset(
                        assetPath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                : Image.asset(
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
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF2C3E50)),
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
      // Tinggi area diperbesar sedikit agar muat kartu yang lebih lebar/tinggi
      height: 300, 
      child: ListView(
        scrollDirection: Axis.horizontal,
        // Clip.none agar shadow tidak terpotong saat di ujung kiri/kanan
        clipBehavior: Clip.none, 
        children: [
          _buildBookCard(
            title: "The Tale of Melon City",
            pages: "7 Pages",
            difficulty: "Hard",
            rating: "4.9",
            imagePath: "assets/images/book image one.png", 
          ),
          
          const SizedBox(width: 20),
          
          _buildBookCard(
            title: "The Tale of the Sin City",
            pages: "7 Pages",
            difficulty: "Hard",
            rating: "4.5",
            imagePath: "assets/images/book image one.png",
          ),
          
          const SizedBox(width: 20),

          // Tambahan item agar kelihatan bisa di-scroll
          _buildBookCard(
            title: "Harry Potter",
            pages: "300 Pages",
            difficulty: "Medium",
            rating: "4.8",
            imagePath: "assets/images/book image one.png",
          ),
          
          const SizedBox(width: 20),
        ],
      ),
    );
  }

  Widget _buildBookCard({
    required String title,
    required String pages,
    required String difficulty,
    required String rating,
    required String imagePath,
  }) {
    return Container(
      // UBAH LEBAR DI SINI (Sebelumnya 160, sekarang 240 biar lebar)
      width: 240, 
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(20), // Radius diperhalus
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC8D9E6),
            offset: const Offset(0, 5),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian Cover Buku
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage(imagePath), 
                  fit: BoxFit.cover, // Gambar memenuhi kotak
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
          const SizedBox(height: 15),
          
          // Judul Buku
          Text(
            title,
            maxLines: 1, // Batasi 1 baris agar rapi, atau 2 jika mau
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 16, // Font diperbesar sedikit
              color: Color(0xFF2F4156),
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Pages Info
          Text(
            "($pages)",
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Color(0xFF2F4156),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Footer (Difficulty & Rating)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFF4F6F94),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_filled_rounded, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      difficulty,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Color(0xFF2F4156),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(Icons.star_rounded, size: 18, color: Color(0xFFFFD93D)),
              const SizedBox(width: 4),
              Text(
                rating,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
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
              // ITEM 0: HOME (Contoh geser sedikit ke atas)
              _buildNavAssetItem(
                assetPath: 'assets/icons/home navbar.svg', // Ganti .svg jika pakai svg
                index: 0,
                isSvg: true, // Ubah true jika file assetnya SVG
                scale: 1.2,
                offsetX: 2,
                // offsetYY: -2.0, // Contoh: Geser ke atas
              ),
              
              // ITEM 1: BOOK
              _buildNavAssetItem(
                assetPath: 'assets/icons/book navbar.svg', 
                index: 1,
                isSvg: true,
                scale: 1.5,
                offsetY: 1, 
              ),
              
              const SizedBox(width: 50), // Spacer tengah
              
              // ITEM 2: ACHIEVEMENT (Contoh diperbesar sedikit)
              _buildNavAssetItem(
                assetPath: 'assets/icons/achievement navbar.svg', 
                index: 2,
                isSvg: true,
                scale: 1,
                offsetY: -1,
                // scale: 1.1, // Contoh: Perbesar 10%
              ),
              
              // ITEM 3: PROFILE (Icon Bawaan)
              _buildNavAssetItem(
                assetPath: 'assets/icons/user navbar active.svg', 
                index: 2,
                isSvg: true,
                scale: 1.25,
                offsetY: -2.0,
                offsetX: -3,
              )
            ],
          ),
        ),

        // 2. TOMBOL SCAN (Tengah)
        Positioned(
          top: -25,
          child: GestureDetector(
            onTap: () => print("Scan Clicked"),
            child: Container(
              width: 65,
              height: 65,
              // Tambahkan padding agar icon di dalamnya tidak mepet
              padding: const EdgeInsets.all(16), 
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
              // CONTOH: Menggunakan SVG di tombol tengah juga bisa diatur
              child: SvgPicture.asset(
                'assets/icons/qr navbar.svg', // Pastikan file SVG ada
                colorFilter: const ColorFilter.mode(Color(0xFF2C3E50), BlendMode.srcIn),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper untuk Icon Bawaan (IconData)
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

  // Helper untuk Gambar/SVG Custom (UPDATED dengan Transform)
  Widget _buildNavAssetItem({
    required String assetPath, 
    required int index,
    bool isSvg = false, // Deteksi SVG
    double offsetX = 0.0, // Geser X
    double offsetY = 0.0, // Geser Y
    double scale = 1.0,   // Skala Besar/Kecil
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? const Color(0xFF4CA1AF) : Colors.grey.shade400;

    return GestureDetector(
      onTap: () => onTap(index),
      // BUNGKUS DENGAN TRANSFORM
      child: Transform.translate(
        offset: Offset(offsetX, offsetY),
        child: Transform.scale(
          scale: scale,
          child: isSvg 
            ? SvgPicture.asset(
                assetPath,
                width: 26, // Ukuran dasar
                height: 26,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              )
            : Image.asset(
                assetPath,
                width: 26,
                height: 26,
                color: color,
              ),
        ),
      ),
    );
  }
}