import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SafeArea agar konten tidak tertutup notch HP
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER (Profil & Level)
              const HeaderSection(),

              const SizedBox(height: 20),

              // 2. STATISTIK (Streak & Poin)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: StatsRow(),
              ),

              const SizedBox(height: 25),

              // 3. JUDUL SEKSI
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  "Mulai Belajar",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // 4. GRID MENU (Games, Buku, dll)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: MenuGrid(),
              ),
              
              const SizedBox(height: 30), 
            ],
          ),
        ),
      ),
      
      // 5. NAVIGASI BAWAH
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF4CA1AF),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: 0, // Aktif di Home
        onTap: (index) {
          if (index == 2) {
            Navigator.pushNamed(context, '/profile');
          } 
          // Logika navigasi bisa ditambahkan di sini nanti
          else if (index == 1) {
            
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard_rounded), label: "Peringkat"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profil"),
        ],
      ),
    );
  }
}

// --- WIDGET PENDUKUNG (Bisa dipisah ke file terpisah nanti) ---

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4CA1AF), Color(0xFF2C3E50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(Icons.face, size: 40, color: Color(0xFF4CA1AF)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Halo, Gerald!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Level 5 - Pejuang Aksara",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: 0.7,
                        minHeight: 8,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF4D03F)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatsRow extends StatelessWidget {
  const StatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatCard(Icons.local_fire_department_rounded, "12 Hari", Colors.orange),
        const SizedBox(width: 15),
        _buildStatCard(Icons.diamond_rounded, "450 Poin", Colors.blue),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuGrid extends StatelessWidget {
  const MenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.1,
      children: [
        _buildMenuCard("Mini Games", "Belajar sambil bermain", Icons.gamepad_rounded, const Color(0xFFFF6B6B)),
        _buildMenuCard("Membaca Buku", "Perpustakaan digital", Icons.menu_book_rounded, const Color(0xFF4ECDC4)),
        _buildMenuCard("Latihan Menulis", "Coret layar sesukamu", Icons.edit_rounded, const Color(0xFFFFD93D)),
        _buildMenuCard("Tantangan", "Misi harianmu", Icons.flag_rounded, const Color(0xFF6C5CE7)),
      ],
    );
  }

  Widget _buildMenuCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Disini nanti tambahkan: Navigator.pushNamed(context, '/game_menu');
          },
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}