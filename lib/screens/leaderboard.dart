import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final _supabase = Supabase.instance.client;
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _topThree = [];
  List<Map<String, dynamic>> _restOfList = [];

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    try {
      // PERUBAHAN DI SINI:
      // Kita mengambil data dari VIEW 'leaderboard_global'
      // View ini sudah berisi kolom: id_akun, username, total_score
      final response = await _supabase
          .from('leaderboard_global')
          .select() // Select all fields (id_akun, username, total_score)
          .order('total_score', ascending: false) // Urutkan berdasarkan total_score
          .limit(50); 

      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);

      setState(() {
        if (data.length >= 3) {
          _topThree = data.sublist(0, 3);
          _restOfList = data.sublist(3);
        } else {
          _topThree = data;
          _restOfList = [];
        }
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching data: $e');
      setState(() => _isLoading = false);
    }
  }

  // Fungsi refresh untuk pull-to-refresh
  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC7D9E5), // Warna background biru muda
      
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _refreshData,
            child: Stack(
              children: [
                // -----------------------------------------------------------
                // 1. BACKGROUND DECORATION (3 AWAN BERBEDA)
                // -----------------------------------------------------------
                
                // Awan 1: Kanan Atas
                Positioned(
                  top: 40,
                  right: -20,
                  child: Image.asset(
                    'assets/images/awan1.png',
                    width: 180, 
                    fit: BoxFit.contain,
                    errorBuilder: (c, o, s) => const SizedBox(), // Handle jika asset belum ada
                  ),
                ),

                // Awan 2: Kiri Tengah
                Positioned(
                  top: 120,
                  left: -30,
                  child: Image.asset(
                    'assets/images/awan2.png',
                    width: 210, 
                    fit: BoxFit.contain,
                    errorBuilder: (c, o, s) => const SizedBox(),
                  ),
                ),

                // Awan 3: Kanan Bawah
                Positioned(
                  top: 280, 
                  right: -10,
                  child: Opacity(
                    opacity: 0.9, 
                    child: Image.asset(
                      'assets/images/awan3.png',
                      width: 160,
                      fit: BoxFit.contain,
                      errorBuilder: (c, o, s) => const SizedBox(),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: PodiumSection(topThree: _topThree),
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
                          // Mengirim data sisa (rank 4 ke bawah) ke widget list
                          child: LeaderboardList(users: _restOfList),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
  final List<Map<String, dynamic>> topThree;

  const PodiumSection({super.key, required this.topThree});

  @override
  Widget build(BuildContext context) {
    // Helper untuk ambil data aman (null safety)
    Map<String, dynamic>? getData(int index) {
      if (index < topThree.length) return topThree[index];
      return null;
    }

    final user1 = getData(0);
    final user2 = getData(1);
    final user3 = getData(2);

    // PERUBAHAN: Mengambil 'username' langsung dari view
    String getName(Map<String, dynamic>? user) {
      if (user == null) return "-";
      return (user['username'] ?? "Unknown").toString();
    }

    // PERUBAHAN: Mengambil 'total_score' dari view
    String getScore(Map<String, dynamic>? user) {
      return (user?['total_score'] ?? 0).toString();
    }

    return SizedBox(
      height: 270, 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Juara 2
          if (user2 != null)
          _buildPodiumItem(
            rank: 2,
            name: getName(user2),
            score: getScore(user2),
            color: const Color(0xFF4A7C96),
            height: 140,
            assetPath: 'assets/images/monster3bg.png', 
          ) else const Spacer(),

          // Juara 1
          if (user1 != null)
          _buildPodiumItem(
            rank: 1,
            name: getName(user1),
            score: getScore(user1),
            color: const Color(0xFFFF9F1C),
            height: 170,
            isWinner: true,
            assetPath: 'assets/images/monster11bg.png', 
          ) else const Spacer(),

          // Juara 3
          if (user3 != null)
          _buildPodiumItem(
            rank: 3,
            name: getName(user3),
            score: getScore(user3),
            color: const Color(0xFF5C4033),
            height: 140,
            assetPath: 'assets/images/monster12bg.png', 
          ) else const Spacer(),
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
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.person, size: isWinner ? 40 : 30, color: Colors.grey);
                      },
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
              maxLines: 1,
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
  final List<Map<String, dynamic>> users;

  const LeaderboardList({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text("Belum ada data lainnya.", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        // Rank dimulai dari 4
        return _buildListItem(user, index + 4);
      },
    );
  }

  Widget _buildListItem(Map<String, dynamic> user, int rank) {
    // PERUBAHAN: Ambil username langsung (bukan user['akun']['username'])
    String name = (user['username'] ?? "User").toString();

    // PERUBAHAN: Ambil total_score (bukan progress_score)
    int score = user['total_score'] ?? 0;
    
    // Rotasi gambar monster (agar variatif walaupun data dari DB tidak punya avatar)
    String imgPath = 'assets/images/monster3bg.png';
    if (rank % 3 == 1) imgPath = 'assets/images/monster11bg.png';
    if (rank % 3 == 2) imgPath = 'assets/images/monster12bg.png';

    // Logika Trend Dummy (Karena di DB view leaderboard_global tidak ada data trend history)
    bool isTrendUp = rank % 2 == 0; 
    int trendVal = (rank % 3) + 1;
    Color trendColor = isTrendUp ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8), 
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Rank Number
          SizedBox(
            width: 30,
            child: Text(
              rank.toString().padLeft(2, '0'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          
          // Avatar Monster
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.transparent, 
            child: Image.asset(
              imgPath, 
              width: 35,
              height: 35,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) => const Icon(Icons.person),
            ),
          ),
          const SizedBox(width: 12),
          
          // Nama & Skor
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "$score Points",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          
          // Indikator Trend (Dummy Visual)
          Text(
            isTrendUp ? "+$trendVal" : "-$trendVal",
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 12,
              color: trendColor, 
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isTrendUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: trendColor, 
          ),
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