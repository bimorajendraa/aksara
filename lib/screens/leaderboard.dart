import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/custom_floating_navbar.dart'; 
import '../../utils/navbar_utils.dart';

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
      final response = await _supabase
          .from('leaderboard_global')
          .select()
          .order('total_score', ascending: false)
          .limit(50); 

      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);

      if (mounted) {
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
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC7D9E5),
      
      body: Stack(
        children: [
          // -----------------------------------------------------------
          // LAYER 1: KONTEN UTAMA (Background + List Data)
          // -----------------------------------------------------------
          _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refreshData,
                child: Stack(
                  children: [
                    // A. Dekorasi Awan
                    Positioned(
                      top: 40, right: -20,
                      child: Image.asset('assets/images/awan1.png', width: 180, fit: BoxFit.contain, errorBuilder: (c, o, s) => const SizedBox()),
                    ),
                    Positioned(
                      top: 120, left: -30,
                      child: Image.asset('assets/images/awan2.png', width: 210, fit: BoxFit.contain, errorBuilder: (c, o, s) => const SizedBox()),
                    ),
                    Positioned(
                      top: 280, right: -10,
                      child: Opacity(opacity: 0.9, child: Image.asset('assets/images/awan3.png', width: 160, fit: BoxFit.contain, errorBuilder: (c, o, s) => const SizedBox())),
                    ),

                    // B. Layout Podium & List
                    Column(
                      children: [
                        const SizedBox(height: 50), // Spasi untuk status bar
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: PodiumSection(topThree: _topThree),
                        ),
                        const SizedBox(height: 20),

                        // List di dalam Container putih
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
                              // Padding bottom agar item paling bawah tidak tertutup Navbar
                              child: LeaderboardList(users: _restOfList),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

          // -----------------------------------------------------------
          // LAYER 2: NAVBAR (Positioned Floating)
          // -----------------------------------------------------------
          Positioned(
            bottom: 30, // Jarak dari bawah layar
            left: 0,
            right: 0,
            child: CustomFloatingNavBar(
              currentIndex: 2, // Index 2 untuk Leaderboard (Achievement)
              onTap: (index) {
                // PERBAIKAN DI SINI:
                // Menggunakan NavigationUtils untuk berpindah halaman
                // Index '2' adalah index halaman ini (Leaderboard/Achievement)
                NavigationUtils.handleNavigation(context, index, 2);
              },
              onScanTap: () {
                // Biasanya tombol scan ditangani langsung di dalam CustomFloatingNavBar
                // atau Anda bisa memanggil navigasi manual di sini
                // NavigationUtils.handleNavigation(context, 4, 2);
                debugPrint("Scan Clicked form Leaderboard");
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET PENDUKUNG (Podium & List) ---

class PodiumSection extends StatelessWidget {
  final List<Map<String, dynamic>> topThree;
  const PodiumSection({super.key, required this.topThree});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? getData(int index) => index < topThree.length ? topThree[index] : null;

    final user1 = getData(0);
    final user2 = getData(1);
    final user3 = getData(2);

    String getName(Map<String, dynamic>? user) => (user?['username'] ?? "Unknown").toString();
    String getScore(Map<String, dynamic>? user) => (user?['total_score'] ?? 0).toString();

    return SizedBox(
      height: 270, 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (user2 != null)
            _buildPodiumItem(2, getName(user2), getScore(user2), const Color(0xFF4A7C96), 140, 'assets/images/monster3bg.png') 
          else const Spacer(),

          if (user1 != null)
            _buildPodiumItem(1, getName(user1), getScore(user1), const Color(0xFFFF9F1C), 170, 'assets/images/monster11bg.png', isWinner: true) 
          else const Spacer(),

          if (user3 != null)
            _buildPodiumItem(3, getName(user3), getScore(user3), const Color(0xFF5C4033), 140, 'assets/images/monster12bg.png') 
          else const Spacer(),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(int rank, String name, String score, Color color, double height, String assetPath, {bool isWinner = false}) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isWinner) const Icon(Icons.emoji_events, color: Colors.amber, size: 30),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 4), color: Colors.white),
                child: CircleAvatar(
                  radius: isWinner ? 40 : 30,
                  backgroundColor: Colors.transparent, 
                  child: ClipOval(
                    child: Image.asset(assetPath, fit: BoxFit.contain, width: isWinner ? 80 : 60, height: isWinner ? 80 : 60,
                      errorBuilder: (c, e, s) => Icon(Icons.person, size: isWinner ? 40 : 30, color: Colors.grey)),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: 20, height: 20,
                  decoration: BoxDecoration(color: isWinner ? Colors.amber : Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey[300]!)),
                  child: Center(child: Text("$rank", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10))),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, maxLines: 1),
          ),
          const SizedBox(height: 4),
          Text(score, style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}

class LeaderboardList extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  const LeaderboardList({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const Center(child: Padding(padding: EdgeInsets.only(top: 20), child: Text("Belum ada data lainnya.", style: TextStyle(color: Colors.grey))));
    
    return ListView.builder(
      // Padding bottom 130 agar aman dari navbar yang posisinya bottom: 30 + tinggi navbar
      padding: const EdgeInsets.only(top: 20, bottom: 130), 
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildListItem(user, index + 4);
      },
    );
  }

  Widget _buildListItem(Map<String, dynamic> user, int rank) {
    String name = (user['username'] ?? "User").toString();
    int score = user['total_score'] ?? 0;
    
    String imgPath = 'assets/images/monster3bg.png';
    if (rank % 3 == 1) imgPath = 'assets/images/monster11bg.png';
    if (rank % 3 == 2) imgPath = 'assets/images/monster12bg.png';

    bool isTrendUp = rank % 2 == 0; 
    int trendVal = (rank % 3) + 1;
    Color trendColor = isTrendUp ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF0F4F8), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text(rank.toString().padLeft(2, '0'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 20, backgroundColor: Colors.transparent, 
            child: Image.asset(imgPath, width: 35, height: 35, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.person)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                Text("$score Points", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Text(isTrendUp ? "+$trendVal" : "-$trendVal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: trendColor)),
          const SizedBox(width: 4),
          Icon(isTrendUp ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: trendColor),
        ],
      ),
    );
  }
}