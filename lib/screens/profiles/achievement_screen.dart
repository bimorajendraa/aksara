import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<Map<String, dynamic>> _achievementList = [];

  @override
  void initState() {
    super.initState();
    _fetchAchievements();
  }

  Future<void> _fetchAchievements() async {
    try {
      // --- PERUBAHAN UTAMA DI SINI ---
      // Kita ambil data dari tabel 'achievement'
      // DAN minta tolong ambilkan 'icon_path' dari tabel 'achievementicons'
      final data = await _supabase
          .from('achievement')
          .select('*, achievementicons(icon_path)') 
          .order('id_achievement', ascending: true);

      // Hasil datanya nanti seperti ini:
      // {
      //    "name": "Ingin Tahu",
      //    "achievementicons": { "icon_path": "icons/monster.svg" }  <-- Nested
      // }

      setState(() {
        _achievementList = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching achievements: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Color(0xFF2C3E50))),
      );
    }

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
                    child: _achievementList.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(child: Text("No achievements yet.")),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _achievementList.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1, thickness: 1),
                            itemBuilder: (context, index) {
                              return _AchievementItem(data: _achievementList[index]);
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
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF2C3E50)),
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
  final Map<String, dynamic> data;

  const _AchievementItem({required this.data});

  @override
  Widget build(BuildContext context) {
    // 1. Ambil Nama
    String title = data['name'] ?? 'Unknown Title';
    
    // 2. Ambil Subtitle (Jika ada di DB)
    String subtitle = data['subtitle'] ?? 'Keep going!'; 

    // --- 3. AMBIL ICON PATH (LOGIC BARU) ---
    String assetPath = 'assets/icons/red_monster_achievement.svg'; // Default fallback
    
    // Cek apakah data relasi 'achievementicons' ada isinya
    if (data['achievementicons'] != null) {
      String rawPath = data['achievementicons']['icon_path'] ?? '';
      
      // Bersihkan Path (tambah 'assets/' jika belum ada)
      if (rawPath.isNotEmpty) {
        if (!rawPath.startsWith('assets/')) {
           assetPath = 'assets/$rawPath';
        } else {
           assetPath = rawPath;
        }
      }
    }
    // ---------------------------------------

    // Warna Sementara (Hardcoded dulu biar tidak error)
    Color itemColor = const Color(0xFFD6E6F2); // Biru Muda Default

    // Hitung Progress
    int current = data['current_progress'] ?? 0;
    int target = data['max_progress'] ?? 10;
    double progressValue = (target == 0) ? 0 : (current / target);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KOTAK GAMBAR
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: itemColor,
              borderRadius: BorderRadius.circular(15),
            ),
            // Logic Icon SVG vs PNG
            child: assetPath.toLowerCase().endsWith('.svg')
                ? SvgPicture.asset(
                    assetPath, 
                    fit: BoxFit.contain,
                    placeholderBuilder: (context) => const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Image.asset(assetPath, fit: BoxFit.contain),
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
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      "$current/$target",
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
                    value: progressValue,
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