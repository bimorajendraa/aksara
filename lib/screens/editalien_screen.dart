import 'package:flutter/material.dart';

class EditAlienScreen extends StatefulWidget {
  const EditAlienScreen({super.key});

  @override
  State<EditAlienScreen> createState() => _EditAlienScreenState();
}

class _EditAlienScreenState extends State<EditAlienScreen> {
  int _selectedTabIndex = 0; 
  int _selectedCharIndex = 0;
  int _selectedBgIndex = 0; 

  final List<String> _characterAssets = [
    'assets/icons/Monster Hijau Profile.png',
    'assets/images/yellow_monster_three_eyes.png',
    'assets/images/red_monster.png',
    'assets/images/orange_monster.png',
    'assets/images/purple_monster.png',
    'assets/images/lightblue_monster.png',
  ];

  final List<Color> _backgroundColors = [
    const Color(0xFF2C3E50), // Navy 
    const Color(0xFFD6E6F2), // Light Blue
    const Color(0xFFFFEAA7), // Cream
    const Color(0xFFFF7675), // Soft Red
    const Color(0xFFA29BFE), // Soft Purple
    const Color(0xFF55EFC4), // Mint Green
  ];

  @override
  Widget build(BuildContext context) {
    // Tinggi area header warna (di belakang monster)
    final double headerHeight = 350; 
    
    final double whiteSheetTopStart = 320; 

    return Scaffold(
      backgroundColor: Colors.white, // Pastikan scaffold putih
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // ============================================
          // LAYER 1: BACKGROUND HEADER COLOR
          // ============================================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight, // Tinggi area warna
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: _backgroundColors[_selectedBgIndex],
            ),
          ),

          // ============================================
          // LAYER 2: MONSTER (FULL BODY TAPI TERTUTUP BAWAHNYA)
          // ============================================
          Positioned(
            // Posisikan monster agar kepalanya pas di tengah area warna
            top: 100, 
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                _characterAssets[_selectedCharIndex],
                height: 280, // Ukuran monster cukup besar
                fit: BoxFit.contain, // Pastikan proporsi tetap (tidak gepeng)
                cacheWidth: 800, // Resolusi tinggi agar tajam
              ),
            ),
          ),

          // ============================================
          // LAYER 3: KONTEN PUTIH (MENUTUPI KAKI MONSTER)
          // ============================================
          Positioned.fill(
            top: whiteSheetTopStart, // Mulai dari sini ke bawah adalah area putih
            child: Container(
              color: Colors.white, // Background putih solid menutupi kaki monster
              child: Column(
                children: [
                  // --- TAB BAR ---
                  Container(
                    color: const Color(0xFFD6E6F2), // Background Tab Bar
                    height: 70,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // Center Alignment
                      children: [
                        _buildTabItem(index: 0, icon: Icons.checkroom_rounded),
                        const SizedBox(width: 50), // Jarak antar tab
                        _buildTabItem(index: 1, icon: Icons.grid_3x3_rounded),
                      ],
                    ),
                  ),
                  
                  // --- ISI KONTEN (GRID) ---
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(25, 25, 25, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedTabIndex == 0 ? "Choose Character" : "Choose Background",
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 20),

                          if (_selectedTabIndex == 0)
                            // GRID CHARACTER
                            GridView.builder(
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 25,
                                mainAxisSpacing: 25,
                                childAspectRatio: 1.0, 
                              ),
                              itemCount: _characterAssets.length,
                              itemBuilder: (context, index) => _buildCharacterOption(index),
                            )
                          else
                            // GRID BACKGROUND
                            GridView.builder(
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 25,
                                mainAxisSpacing: 25,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: _backgroundColors.length,
                              itemBuilder: (context, index) => _buildBackgroundColorOption(index),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ============================================
          // LAYER 4: HEADER NAVIGASI (BACK BUTTON)
          // ============================================
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      "Profile",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ============================================
          // LAYER 5: NAVBAR MELAYANG
          // ============================================
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: CustomFloatingNavBar(
              currentIndex: 3, 
              onTap: (index) {
                if (index == 0) {
                   Navigator.popUntil(context, ModalRoute.withName('/home')); 
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildTabItem({required int index, required IconData icon}) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        // Agar area tap lebih luas
        color: Colors.transparent, 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon, 
              size: 34, 
              color: const Color(0xFF2C3E50), 
            ),
            const SizedBox(height: 6),
            
            // Garis Bawah Kecil (Indikator)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 4,
              width: isSelected ? 40 : 0, // Jika tidak dipilih lebar 0 (hilang)
              decoration: BoxDecoration(
                color: const Color(0xFF2C3E50),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterOption(int index) {
    bool isSelected = _selectedCharIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedCharIndex = index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected 
              ? Border.all(color: const Color(0xFF2C3E50), width: 3)
              : Border.all(color: Colors.grey.shade300, width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
          ],
        ),
        padding: const EdgeInsets.all(15), 
        // DI SINI TAMPIL FULL BODY
        child: Image.asset(
          _characterAssets[index],
          fit: BoxFit.contain, 
          cacheWidth: 300, 
        ),
      ),
    );
  }

  Widget _buildBackgroundColorOption(int index) {
    bool isSelected = _selectedBgIndex == index;
    Color color = _backgroundColors[index];
    return GestureDetector(
      onTap: () => setState(() => _selectedBgIndex = index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected 
              ? Border.all(color: Colors.blue.withOpacity(0.5), width: 4)
              : Border.all(color: Colors.transparent, width: 4),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5))
          ],
        ),
        padding: const EdgeInsets.all(4), 
        child: Container(
          decoration: BoxDecoration(
            color: color, 
            borderRadius: BorderRadius.circular(16),
          ),
          child: isSelected 
            ? const Center(child: Icon(Icons.check_rounded, color: Colors.white, size: 30)) 
            : null,
        ),
      ),
    );
  }
}

// --- CUSTOM NAVBAR ---
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
              _buildNavAssetItem(assetPath: 'assets/icons/achievement navbar.png', index: 2),
              _buildNavItem(icon: Icons.person_rounded, index: 3),
            ],
          ),
        ),
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
                  BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF2C3E50), size: 30),
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
      child: Icon(icon, size: 28, color: isSelected ? const Color(0xFF4CA1AF) : Colors.grey.shade400),
    );
  }

  Widget _buildNavAssetItem({required String assetPath, required int index}) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Image.asset(assetPath, width: 28, height: 28, color: isSelected ? const Color(0xFF4CA1AF) : Colors.grey.shade400),
    );
  }
}