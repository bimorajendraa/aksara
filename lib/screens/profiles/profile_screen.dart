import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

// Import Navbar & Utils
// Pastikan path ini sesuai dengan struktur folder project Anda
import '../../widgets/custom_floating_navbar.dart';
import '../../utils/navbar_utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;

  bool _isLoading = true;

  // Data User
  String _username = "Loading...";
  String _email = "Loading...";
  String _joinedSince = "...";
  String _currentAvatarPath = 'assets/icons/Monster Hijau Profile.png'; // Default Avatar

  // Data Lists
  List<Map<String, dynamic>> _achievementList = [];
  List<Map<String, dynamic>> _bookList = [];

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user != null) {
        final userEmail = user.email;

        // 1. AMBIL DATA USER
        // Kita gunakan .select() tanpa argumen spesifik agar mengambil semua kolom yang ada.
        // Ini mencegah error jika kolom 'avatar_path' belum dibuat di DB.
        final akunData = await _supabase
            .from('akun')
            .select() 
            .eq('email', userEmail!)
            .maybeSingle();

        // Format Tanggal
        String yearStr = "2024";
        try {
          final createdAt = DateTime.parse(user.createdAt);
          yearStr = DateFormat('yyyy').format(createdAt);
        } catch (_) {}

        if (mounted) {
          setState(() {
            _email = userEmail;
            _joinedSince = yearStr;
            
            if (akunData != null) {
              _username = akunData['username'] ?? "User";
              
              // Cek apakah kolom avatar_path ada dan tidak null
              // Jika tidak ada di DB, dia akan tetap pakai default yang kita set di atas
              if (akunData['avatar_path'] != null) {
                _currentAvatarPath = akunData['avatar_path'];
              }
            }
          });
        }
      }

      // 2. AMBIL DATA ACHIEVEMENT (JOIN dengan achievementicons)
      // Kita coba ambil data. Jika relasi belum di-setup di DB, ini mungkin error, 
      // jadi kita wrap try-catch khusus fetch list biar user info tetap muncul.
      try {
        final achievementsData = await _supabase
            .from('achievement')
            .select('*, achievementicons(icon_path, color_hex)') 
            .order('id_achievement', ascending: true);
        
        if (mounted) {
          setState(() {
            _achievementList = List<Map<String, dynamic>>.from(achievementsData);
          });
        }
      } catch (e) {
        debugPrint("Error fetching achievements: $e");
        // Achievement list tetap kosong, tidak bikin crash
      }

      // 3. AMBIL DATA BOOK
      try {
        final booksData = await _supabase
            .from('book')
            .select()
            .order('id_book', ascending: true);

        if (mounted) {
          setState(() {
            _bookList = List<Map<String, dynamic>>.from(booksData);
          });
        }
      } catch (e) {
        debugPrint("Error fetching books: $e");
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }

    } catch (e) {
      debugPrint("Error fetching general data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _username = "Error Load";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2C3E50)))
          : Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // LAYER 1: KONTEN
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // HEADER AVATAR
                          _ProfileHeaderCard(avatarPath: _currentAvatarPath),

                          const SizedBox(height: 25),

                          // USER INFO
                          _UserInfoSection(
                            username: _username,
                            email: _email,
                            joinedYear: _joinedSince,
                          ),

                          const SizedBox(height: 15),
                          Divider(thickness: 1, color: Colors.grey.shade200),
                          const SizedBox(height: 15),

                          // ACHIEVEMENT HEADER
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

                          // LIST ACHIEVEMENT
                          _AchievementList(achievements: _achievementList),

                          const SizedBox(height: 30),

                          // RECENTLY READ HEADER
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

                          // LIST BOOK
                          _RecentlyReadList(books: _bookList),
                        ],
                      ),
                    ),
                  ),
                ),

                // LAYER 2: NAVBAR
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: CustomFloatingNavBar(
                    currentIndex: 3, // Profile Index
                    onTap: (index) {
                      // Menggunakan Utils agar tombol Home berfungsi reset stack
                      NavigationUtils.handleNavigation(context, index, 3);
                    },
                    onScanTap: () {
                      print("Scan Clicked");
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// HELPER FUNCTION (SVG & PNG SUPPORT + NULL SAFETY)
// ---------------------------------------------------------------------------
Widget _buildImage(String? path, {double? width, double? height, BoxFit fit = BoxFit.contain}) {
  // Jika path null atau kosong, return icon error atau placeholder
  if (path == null || path.isEmpty) {
    return Container(
      width: width, height: height,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  // Bersihkan path
  String cleanPath = path.trim();
  
  // Logic: Jika tidak dimulai dengan 'http' (bukan url) dan tidak ada 'assets/', tambahkan 'assets/'
  if (!cleanPath.startsWith('http') && !cleanPath.startsWith('assets/')) {
    cleanPath = 'assets/$cleanPath';
  }

  // Cek SVG
  if (cleanPath.toLowerCase().endsWith('.svg')) {
    return SvgPicture.asset(
      cleanPath,
      width: width,
      height: height,
      fit: fit,
      placeholderBuilder: (context) => const Center(child: CircularProgressIndicator()),
    );
  } 
  // Cek URL
  else if (cleanPath.startsWith('http')) {
    return Image.network(
      cleanPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
    );
  }
  // Default Asset PNG/JPG
  else {
    return Image.asset(
      cleanPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
    );
  }
}

// ---------------------------------------------------------------------------
// WIDGET COMPONENTS
// ---------------------------------------------------------------------------

class _ProfileHeaderCard extends StatelessWidget {
  final String avatarPath;
  
  const _ProfileHeaderCard({required this.avatarPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
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
          Positioned(
            top: 35, bottom: -30, left: 0, right: 0,
            child: _buildImage(avatarPath, fit: BoxFit.contain),
          ),
          Positioned(
            top: 15, right: 15,
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
                    color: const Color(0xFFC8D9E6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F6F94),
                        blurRadius: 0, offset: const Offset(4, 4),
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

class _UserInfoSection extends StatelessWidget {
  final String username;
  final String email;
  final String joinedYear;

  const _UserInfoSection({
    required this.username,
    required this.email,
    required this.joinedYear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              email,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF2F4156),
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF2F4156),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Joined since $joinedYear",
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
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

class _AchievementList extends StatelessWidget {
  final List<Map<String, dynamic>> achievements;

  const _AchievementList({required this.achievements});

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text("No achievements yet.")),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          for (int i = 0; i < achievements.length; i++) ...[
            _buildAchievementItem(data: achievements[i]),
            if (i != achievements.length - 1)
              Divider(color: Colors.grey.shade200, thickness: 1, height: 1),
          ]
        ],
      ),
    );
  }

  Widget _buildAchievementItem({required Map<String, dynamic> data}) {
    // === MAPPING DATA AMAN (NULL SAFETY) ===
    String title = data['name'] ?? 'Untitled';
    String subtitle = data['subtitle'] ?? 'Keep going!'; // Default text jika null
    
    String assetPath = 'assets/icons/monster_ingin_tahu.svg';
    String hexString = 'FFD6E6F2';

    // Cek Relasi achievementicons
    if (data['achievementicons'] != null) {
       assetPath = data['achievementicons']['icon_path'] ?? assetPath;
       hexString = data['achievementicons']['color_hex'] ?? hexString;
    }

    // Warna
    Color itemColor;
    try {
      itemColor = Color(int.parse("0x$hexString"));
    } catch (_) {
      itemColor = const Color(0xFFD6E6F2); // Default color jika parse error
    }

    // Progress
    int current = data['current_progress'] ?? 0;
    int max = data['max_progress'] ?? 10;
    double progressValue = (max == 0) ? 0 : (current / max);
    String progressText = "$current/$max";

    // SVG Settings (Default values)
    bool isSvg = data['is_svg'] ?? true;
    double svgScale = (data['svg_scale'] ?? 1.0).toDouble();
    double svgOffsetX = (data['svg_offset_x'] ?? 0.0).toDouble();
    double svgOffsetY = (data['svg_offset_y'] ?? 0.0).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        children: [
          Container(
            width: 50, height: 50, padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: itemColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: itemColor.withOpacity(0.3),
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
                      child: _buildImage(assetPath, fit: BoxFit.contain),
                    ),
                  )
                : _buildImage(assetPath, fit: BoxFit.contain),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF2C3E50))),
                    Text(progressText, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progressValue, minHeight: 8,
                    backgroundColor: const Color(0xFFDAE4EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2C3E50)),
                  ),
                ),
                const SizedBox(height: 6),
                Text(subtitle, style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w400, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentlyReadList extends StatelessWidget {
  final List<Map<String, dynamic>> books;

  const _RecentlyReadList({required this.books});

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return const Text("No books read yet.");

    return SizedBox(
      height: 300,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: books.length,
        separatorBuilder: (context, index) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          final book = books[index];
          // Null Safety untuk Book
          final title = book['name'] ?? "Untitled";
          final pages = book['pages']?.toString() ?? "0";
          final difficulty = book['difficulty'] ?? "Medium";
          final rating = book['rating']?.toString() ?? "0.0";
          final imagePath = book['cover_book'] ?? "assets/images/book image one.png";

          return _buildBookCard(
            title: title,
            pages: "$pages Pages",
            difficulty: difficulty,
            rating: rating,
            imagePath: imagePath,
          );
        },
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
      width: 240, padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFFC8D9E6), offset: const Offset(0, 5), blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildImage(imagePath, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF2F4156))),
          const SizedBox(height: 4),
          Text(pages, style: TextStyle(fontFamily: 'Poppins', color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF4F6F94), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_filled_rounded, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(difficulty, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(Icons.star_rounded, size: 18, color: Color(0xFFFFD93D)),
              const SizedBox(width: 4),
              Text(rating, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2C3E50))),
            ],
          ),
        ],
      ),
    );
  }
}