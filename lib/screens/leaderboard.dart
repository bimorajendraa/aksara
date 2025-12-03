import 'package:flutter/material.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC7D9E5), // Warna background biru muda
      
      body: Stack(
        children: [
          // -----------------------------------------------------------
          // 1. BACKGROUND DECORATION (3 AWAN BERBEDA)
          // -----------------------------------------------------------
          
          // Awan 1: Kanan Atas
          Positioned(
            top: 40,
            right: -20, // Muncul dari kanan
            child: Image.asset(
              'assets/images/awan1.png', // GANTI NAMA FILE
              width: 180, 
              fit: BoxFit.contain,
            ),
          ),

          // Awan 2: Kiri Tengah
          Positioned(
            top: 120, // Posisi vertikal di tengah area atas
            left: -30, // Muncul dari kiri
            child: Image.asset(
              'assets/images/awan2.png', // GANTI NAMA FILE
              width: 210, 
              fit: BoxFit.contain,
            ),
          ),

          // Awan 3: Kanan Bawah (Di belakang list)
          Positioned(
            top: 280, 
            right: -10,
            child: Opacity(
              opacity: 0.9, 
              child: Image.asset(
                'assets/images/awan3.png', // GANTI NAMA FILE
                width: 160,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // -----------------------------------------------------------
          // 2. KONTEN UTAMA (PODIUM & LIST)
          // -----------------------------------------------------------
          Column(
            children: [
              const SizedBox(height: 50), // Spasi status bar
              
              // Bagian Atas: Podium
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: PodiumSection(),
              ),
              const SizedBox(height: 20),

              // Bagian Bawah: List Scrollable
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: const LeaderboardList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      // Navigation Bar Fixed di Bawah
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}

// ---------------------------------------------------------------------------
// WIDGET: PODIUM
// ---------------------------------------------------------------------------
class PodiumSection extends StatelessWidget {
  const PodiumSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 270, 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Juara 2
          _buildPodiumItem(
            rank: 2,
            name: "Maulana",
            score: "4099",
            color: const Color(0xFF4A7C96),
            height: 140,
            assetPath: 'assets/images/monster3bg.png', 
          ),
          // Juara 1
          _buildPodiumItem(
            rank: 1,
            name: "Maulana",
            score: "4120",
            color: const Color(0xFFFF9F1C),
            height: 170,
            isWinner: true,
            assetPath: 'assets/images/monster11bg.png', 
          ),
          // Juara 3
          _buildPodiumItem(
            rank: 3,
            name: "Maulana",
            score: "3902",
            color: const Color(0xFF5C4033),
            height: 140,
            assetPath: 'assets/images/monster12bg.png', 
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem({
    required int rank,
    required String name,
    required String score,
    required Color color,
    required double height,
    required String assetPath, 
    bool isWinner = false,
  }) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isWinner) 
            const Icon(Icons.emoji_events, color: Colors.amber, size: 30),
          
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 4),
                  color: Colors.white,
                ),
                child: CircleAvatar(
                  radius: isWinner ? 40 : 30,
                  backgroundColor: Colors.transparent, 
                  child: ClipOval(
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.contain, 
                      width: isWinner ? 80 : 60,
                      height: isWinner ? 80 : 60,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isWinner ? Colors.amber : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Center(
                    child: Text(
                      "$rank",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.bold, 
                fontSize: 11
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            score,
            style: TextStyle(
              color: Colors.grey[800], 
              fontWeight: FontWeight.bold,
              fontSize: 12
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// WIDGET: LIST DAFTAR PERINGKAT
// ---------------------------------------------------------------------------
class LeaderboardList extends StatelessWidget {
  const LeaderboardList({super.key});

  @override
  Widget build(BuildContext context) {
    // Data Dummy 
    final List<Map<String, dynamic>> users = [
      {'rank': 4, 'name': 'Maulana Sudrajat', 'score': 3580, 'trend': 'up', 'trendVal': 3, 'img': 'assets/images/monster3bg.png'},
      {'rank': 5, 'name': 'Bimo Rajendra', 'score': 3120, 'trend': 'down', 'trendVal': 2, 'img': 'assets/images/monster11bg.png'},
      {'rank': 6, 'name': 'Nathania Princess', 'score': 3120, 'trend': 'up', 'trendVal': 3, 'img': 'assets/images/monster12bg.png'},
      {'rank': 7, 'name': 'aulnatbim', 'score': 3120, 'trend': 'up', 'trendVal': 3, 'img': 'assets/images/monster3bg.png'},
      {'rank': 8, 'name': 'User Lain', 'score': 3120, 'trend': 'flat', 'trendVal': 0, 'img': 'assets/images/monster11bg.png'},
      {'rank': 9, 'name': 'natanyaShobah', 'score': 3120, 'trend': 'up', 'trendVal': 3, 'img': 'assets/images/monster12bg.png'},
      {'rank': 10, 'name': 'You', 'score': 3120, 'trend': 'up', 'trendVal': 3, 'isMe': true, 'img': 'assets/images/monster12bg.png'},
      {'rank': 11, 'name': 'Scroll Test', 'score': 2000, 'trend': 'down', 'trendVal': 5, 'img': 'assets/images/monster3bg.png'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildListItem(user);
      },
    );
  }

  Widget _buildListItem(Map<String, dynamic> user) {
    bool isMe = user['isMe'] ?? false;
    String trend = user['trend'];
    int trendVal = user['trendVal'];
    
    // Tentukan warna trend
    Color trendColor = Colors.grey;
    if (trend == 'up') trendColor = Colors.green;
    if (trend == 'down') trendColor = Colors.red;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? Colors.white : const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(16),
        border: isMe ? Border.all(color: const Color(0xFF4A7C96), width: 2) : null,
        boxShadow: isMe ? [
          BoxShadow(color: Colors.blue.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
        ] : [],
      ),
      child: Row(
        children: [
          // Rank Number
          SizedBox(
            width: 30,
            child: Text(
              user['rank'].toString().padLeft(2, '0'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          
          // Avatar Monster
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.transparent, 
            child: Image.asset(
              user['img'], 
              width: 35,
              height: 35,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          
          // Nama & Skor
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "${user['score']} Points",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          
          // --- INDIKATOR TREND (+/- Angka di KIRI Segitiga) ---
          if (trend != 'flat') ...[
             Text(
              trend == 'up' ? "+$trendVal" : "-$trendVal",
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 12,
                color: trendColor, 
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              trend == 'down' ? Icons.arrow_drop_down : Icons.arrow_drop_up,
              color: trendColor, 
            ),
          ] else ...[
             const Text("-", style: TextStyle(color: Colors.grey)),
          ]
          // ----------------------------------------------------
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// WIDGET: CUSTOM BOTTOM NAV BAR
// ---------------------------------------------------------------------------
class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.home, size: 28, color: Colors.grey)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.menu_book, size: 28, color: Colors.grey)),
            
            // Tombol Tengah
            Transform.translate(
              offset: const Offset(0, -15),
              child: Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFC7D9E5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)
                  ]
                ),
                child: const Icon(Icons.qr_code_scanner, color: Colors.black87),
              ),
            ),
            
            IconButton(onPressed: () {}, icon: const Icon(Icons.emoji_events, size: 28, color: Color(0xFF4A7C96))),
            IconButton(onPressed: () {}, icon: const Icon(Icons.person, size: 28, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}