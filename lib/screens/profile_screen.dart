import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Akses Client Supabase
  final _supabase = Supabase.instance.client;

  bool _isLoading = true;

  // Data User
  String _username = "Loading...";
  String _email = "Loading...";
  String _joinedSince = "...";

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

        // 1. AMBIL DATA USER DARI TABEL 'akun'
        final akunData = await _supabase
            .from('akun')
            .select('username') // Ambil kolom username saja
            .eq('email', userEmail!)
            .maybeSingle();

        // Hitung tahun join dari metadata auth
        final createdAt = DateTime.parse(user.createdAt);
        final yearStr = DateFormat('yyyy').format(createdAt);

        if (mounted) {
          setState(() {
            _email = userEmail;
            _joinedSince = yearStr;
            // Gunakan username dari DB, atau fallback ke 'User'
            _username = akunData != null ? akunData['username'] : "User";
          });
        }
      }

      // 2. AMBIL DATA ACHIEVEMENT
      final achievementsData = await _supabase
          .from('achievement')
          .select()
          .order('id_achievement', ascending: true);

      // 3. AMBIL DATA BOOK
      final booksData = await _supabase
          .from('book')
          .select()
          .order('id_book', ascending: true);

      if (mounted) {
        setState(() {
          _achievementList = List<Map<String, dynamic>>.from(achievementsData);
          _bookList = List<Map<String, dynamic>>.from(booksData);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _username = "Error Load";
        });
      }
    }
  }

  void _handleNavigation(int index) {
    // Index 3 adalah Profile (Halaman ini), jadi tidak perlu reload
    if (index == 3) return;

    // Logika pindah halaman sesuai route yang didaftarkan di main.dart
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home'); // Pindah ke Home
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/story-mode'); // Pindah ke Book
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/achievement'); // Pindah ke Achievement
        break;
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2C3E50)))
          : Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // LAYER 1: KONTEN
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 20, bottom: 120),
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // HEADER AVATAR
                          const _ProfileHeaderCard(),

                          const SizedBox(height: 25),

                          // USER INFO (DINAMIS)
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

                          // ACHIEVEMENT LIST (DINAMIS)
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

                          // RECENTLY READ LIST (DINAMIS)
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
                    currentIndex: 3,
                    onTap: _handleNavigation,
                  ),
                ),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// WIDGET HELPER
// ---------------------------------------------------------------------------

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
                decorationColor: Color(0xFF2F4156), // Warna garis bawah disamakan
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Joined since $joinedYear",
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2F4156),
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
              color: Colors.black54, // Warna icon gerigi
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
      return const Text("No achievements yet.");
    }

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
    // Mapping Data dari DB
    String title = data['name'] ?? 'Title';
    String subtitle = data['subtitle'] ?? '';
    String assetPath = data['asset_path'] ?? 'assets/icons/monster ingin tahu.svg';
    
    // Parse Hex Color
    String hexString = data['color_hex'] ?? 'FF000000';
    Color itemColor = Color(int.parse("0x$hexString"));

    // Hitung Progress
    int current = data['current_progress'] ?? 0;
    int max = data['max_progress'] ?? 10;
    double progressValue = (max == 0) ? 0 : (current / max);
    String progressText = "$current/$max";

    // Parameter SVG (Safe Casting ke double)
    bool isSvg = data['is_svg'] ?? false;
    double svgScale = (data['svg_scale'] ?? 1.0).toDouble();
    double svgOffsetX = (data['svg_offset_x'] ?? 0.0).toDouble();
    double svgOffsetY = (data['svg_offset_y'] ?? 0.0).toDouble();

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
          // Mapping kolom 'cover_book' -> 'imagePath'
          return _buildBookCard(
            title: book['name'] ?? "",
            pages: "${book['pages']} Pages",
            difficulty: book['difficulty'] ?? "Medium",
            rating: "${book['rating']}",
            imagePath: book['cover_book'] ?? "assets/images/book image one.png",
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
      width: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(20),
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
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  // Logic cek apakah URL atau Asset Lokal
                  image: imagePath.startsWith('http')
                      ? NetworkImage(imagePath)
                      : AssetImage(imagePath) as ImageProvider,
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
          const SizedBox(height: 15),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF2F4156),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "($pages)",
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F6F94),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_filled_rounded,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      difficulty,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: Colors.white, // Text Difficulty Putih
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(Icons.star_rounded,
                  size: 18, color: Color(0xFFFFD93D)),
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

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard();
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
            top: 35,
            bottom: -30,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/icons/Monster Hijau Profile.png',
              fit: BoxFit.contain,
            ),
          ),
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
                    color: const Color(0xFFC8D9E6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.4), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F6F94),
                        blurRadius: 0,
                        offset: const Offset(4, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.edit_rounded,
                      color: Color(0xFF2F4156), size: 22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
              _buildNavAssetItem(
                assetPath: 'assets/icons/home navbar.svg',
                index: 0,
                isSvg: true,
                scale: 1.2,
                offsetX: 2,
              ),
              _buildNavAssetItem(
                assetPath: 'assets/icons/book navbar.svg',
                index: 1,
                isSvg: true,
                scale: 1.5,
                offsetY: 1,
              ),
              const SizedBox(width: 50),
              _buildNavAssetItem(
                assetPath: 'assets/icons/achievement navbar.svg',
                index: 2,
                isSvg: true,
                scale: 1,
                offsetY: -1,
              ),
              _buildNavAssetItem(
                assetPath: 'assets/icons/user navbar active.svg',
                index: 3,
                isSvg: true,
                scale: 1.25,
                offsetY: -2.0,
                offsetX: -3,
              )
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
              child: SvgPicture.asset(
                'assets/icons/qr navbar.svg',
                colorFilter:
                    const ColorFilter.mode(Color(0xFF2C3E50), BlendMode.srcIn),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavAssetItem({
    required String assetPath,
    required int index,
    bool isSvg = false,
    double offsetX = 0.0,
    double offsetY = 0.0,
    double scale = 1.0,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? const Color(0xFF4CA1AF) : Colors.grey.shade400;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Transform.translate(
        offset: Offset(offsetX, offsetY),
        child: Transform.scale(
          scale: scale,
          child: isSvg
              ? SvgPicture.asset(
                  assetPath,
                  width: 26,
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