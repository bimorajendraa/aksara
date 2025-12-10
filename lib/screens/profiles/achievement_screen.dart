import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- IMPORT WIDGET NAVBAR ANDA ---
import '../../widgets/custom_floating_navbar.dart'; 
import '../../utils/navbar_utils.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  
  // List untuk menampung data gabungan (Master + User Progress)
  List<Map<String, dynamic>> _achievementList = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // 1. Cari ID Akun User yang Login
  Future<void> _fetchData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final akunData = await _supabase
          .from('akun')
          .select('id_akun')
          .eq('email', user.email!)
          .maybeSingle();

      if (akunData != null) {
        // Jika ID ketemu, ambil achievement dan merge
        await _fetchMergedAchievements(akunData['id_akun']);
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching user id: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. Logika Merge (Sama persis dengan ProfileScreen)
  Future<void> _fetchMergedAchievements(int userId) async {
    try {
      // A. Ambil Master Data (Join Icon)
      final masterData = await _supabase
          .from('achievement')
          .select('*, achievementicons(*)')
          .order('id_achievement', ascending: true);

      // B. Ambil Progress User
      final userProgressData = await _supabase
          .from('userachievements')
          .select()
          .eq('id_akun', userId);

      // C. Gabungkan
      List<Map<String, dynamic>> mergedList = [];

      for (var master in masterData) {
        // Cari progress user untuk achievement ini
        final userEntry = userProgressData.firstWhere(
          (u) => u['id_achievement'] == master['id_achievement'],
          orElse: () => {},
        );

        final iconData = master['achievementicons'] ?? {};
        
        bool isCompleted = userEntry != null ? (userEntry['is_completed'] ?? false) : false;
        String dynamicSubtitle = isCompleted ? "Completed!" : "Keep going!";

        mergedList.add({
          // Data Utama
          'name': master['name'] ?? 'Untitled',
          'max_progress': master['max_progress'] ?? 10,
          'subtitle': dynamicSubtitle,
          
          // Data Icon (Flattened)
          'icon_path': iconData['icon_path'], 
          'background': iconData['background'], 
          'svg_scale': iconData['svg_scale'],
          'svg_offset_x': iconData['svg_offset_x'],
          'svg_offset_y': iconData['svg_offset_y'],

          // Data Progress User
          'current_progress': userEntry != null ? (userEntry['progress_value'] ?? 0) : 0,
          'is_completed': isCompleted,
        });
      }

      if (mounted) {
        setState(() {
          _achievementList = mergedList;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error merging achievements: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definisi Navbar
    final bottomNavbar = CustomFloatingNavBar(
      currentIndex: 2, 
      onTap: (index) {
        NavigationUtils.handleNavigation(context, index, 2);
      },
      onScanTap: () {
        print("Tombol Scan ditekan");
      },
    );

    // State Loading
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            const Center(child: CircularProgressIndicator(color: Color(0xFF2C3E50))),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: bottomNavbar,
              ),
            ),
          ],
        ),
      );
    }

    // State Content
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. KONTEN HALAMAN (Layer Bawah)
          Positioned.fill(
            child: Column(
              children: [
                const _CustomHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    // Padding bawah besar agar list paling bawah tidak tertutup Navbar
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
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
          ),
          
          // 2. NAVBAR (Layer Atas)
          Positioned(
            bottom: 30, left: 0, right: 0,
            child: bottomNavbar,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HELPER FUNCTIONS (Safe)
// ---------------------------------------------------------------------------

Widget _buildImage(String? path, {double? width, double? height, BoxFit fit = BoxFit.contain}) {
  if (path == null || path.isEmpty) {
    return Container(width: width, height: height, color: Colors.grey.shade200, child: const Icon(Icons.image, color: Colors.grey));
  }
  String cleanPath = path.trim();
  if (!cleanPath.startsWith('http') && !cleanPath.startsWith('assets/')) {
    cleanPath = 'assets/$cleanPath';
  }

  if (cleanPath.toLowerCase().endsWith('.svg')) {
    return SvgPicture.asset(
      cleanPath, width: width, height: height, fit: fit,
      placeholderBuilder: (_) => const Center(child: CircularProgressIndicator()),
    );
  } else if (cleanPath.startsWith('http')) {
    return Image.network(
      cleanPath, width: width, height: height, fit: fit,
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
    );
  } else {
    return Image.asset(
      cleanPath, width: width, height: height, fit: fit,
      errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
    );
  }
}

double _safeDouble(dynamic value, double defaultValue) {
  if (value == null) return defaultValue;
  if (value is int) return value.toDouble();
  if (value is double) return value;
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

Color _parseColorFromDb(String? hexString) {
  if (hexString == null || hexString.isEmpty) return const Color(0xFFD6E6F2);
  try {
    String cleanHex = hexString.replaceAll("#", "").replaceAll("0x", "").toUpperCase();
    if (cleanHex.length == 6) cleanHex = "FF$cleanHex";
    return Color(int.parse(cleanHex, radix: 16));
  } catch (e) {
    return const Color(0xFFD6E6F2);
  }
}

// ---------------------------------------------------------------------------
// COMPONENTS
// ---------------------------------------------------------------------------

class _CustomHeader extends StatelessWidget {
  const _CustomHeader();

  @override
  Widget build(BuildContext context) {
    // Tambahkan safe area top padding
    final topPadding = MediaQuery.of(context).padding.top + 20;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 25),
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
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                // Fallback jika tidak ada history (misal refresh page)
                Navigator.pushReplacementNamed(context, '/home');
              }
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
  final Map<String, dynamic> data;

  const _AchievementItem({required this.data});

  @override
  Widget build(BuildContext context) {
    // Mapping Data
    String title = data['name'] ?? 'Unknown Title';
    String subtitle = data['subtitle'] ?? 'Keep going!'; 
    
    // Icon Logic
    String assetPath = 'assets/icons/monster_ingin_tahu.svg';
    String rawPath = data['icon_path'] ?? '';
    if (rawPath.isNotEmpty) {
       assetPath = rawPath; // Helper _buildImage akan handle prefix assets/
    }

    Color itemColor = _parseColorFromDb(data['background']);
    
    // Styling Logic
    double scale = _safeDouble(data['svg_scale'], 1.0);
    double offsetX = _safeDouble(data['svg_offset_x'], 0.0);
    double offsetY = _safeDouble(data['svg_offset_y'], 0.0);
    
    // Progress Logic
    int current = data['current_progress'] ?? 0;
    int target = data['max_progress'] ?? 10;
    double progressValue = (target == 0) ? 0 : (current / target);
    if (progressValue > 1.0) progressValue = 1.0;

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
            clipBehavior: Clip.hardEdge, 
            decoration: BoxDecoration(
              color: itemColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: itemColor.withOpacity(0.3),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                )
              ],
            ),
            child: Transform.translate(
              offset: Offset(offsetX, offsetY),
              child: Transform.scale(
                scale: scale,
                child: _buildImage(assetPath, fit: BoxFit.contain),
              ),
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
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2C3E50)),
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