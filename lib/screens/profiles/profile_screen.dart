import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

// Import Navbar & Utils
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
  String _currentAvatarPath = 'assets/icons/Monster Hijau Profile.png';

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

        final akunData = await _supabase
            .from('akun')
            .select()
            .eq('email', userEmail!)
            .maybeSingle();

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
              _username = (akunData['username'] as String?) ?? "User";
              if (akunData['avatar_path'] != null) {
                _currentAvatarPath = akunData['avatar_path'] as String;
              }
            }
          });
        }

        if (akunData != null) {
          final idAkun = akunData['id_akun'];
          if (idAkun != null) {
            await _fetchMergedAchievements(idAkun);
            await _fetchUserBooks(idAkun);
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- FETCH ACHIEVEMENT (MERGE Master + User) ---
  Future<void> _fetchMergedAchievements(dynamic userId) async {
    try {
      // A. Ambil SEMUA Achievement (Master Data)
      final masterData = await _supabase
          .from('achievement')
          .select('*, achievementicons(*)')
          .order('id_achievement', ascending: true);

      // B. Ambil Progress User
      final userProgressData = await _supabase
          .from('userachievements')
          .select()
          .eq('id_akun', userId);

      // C. Merge Data
      List<Map<String, dynamic>> mergedList = [];

      for (var master in masterData) {
        // --- PERBAIKAN DI SINI ---
        // Cari progress user. Jika tidak ketemu, return Map Kosong {}.
        final userEntry = userProgressData.firstWhere(
          (u) => u['id_achievement'] == master['id_achievement'],
          orElse: () => <String, dynamic>{}, // Return empty map, BUKAN null
        );

        // Cek apakah map kosong (artinya user belum punya progress ini)
        bool hasProgress = userEntry.isNotEmpty;

        final iconData = master['achievementicons'] ?? {};
        
        // Data Status
        bool isCompleted = hasProgress ? (userEntry['is_completed'] ?? false) : false;
        int currentProgress = hasProgress ? (userEntry['progress_value'] ?? 0) : 0;

        // Subtitle Dinamis
        String dynamicSubtitle = isCompleted ? "Completed!" : "Keep going!";

        mergedList.add({
          'name': master['name'] ?? 'Untitled',
          'max_progress': master['max_progress'] ?? 10,
          'subtitle': dynamicSubtitle,
          
          // Icon Data
          'icon_path': iconData['icon_path'], 
          'background': iconData['background'], 
          'svg_scale': iconData['svg_scale'],
          'svg_offset_x': iconData['svg_offset_x'],
          'svg_offset_y': iconData['svg_offset_y'],

          // User Progress
          'current_progress': currentProgress,
          'is_completed': isCompleted,
        });
      }

      if (mounted) {
        setState(() {
          _achievementList = mergedList;
        });
      }
    } catch (e) {
      debugPrint("Error merging achievements: $e");
    }
  }

  // --- FETCH RECENTLY READ ---
  Future<void> _fetchUserBooks(dynamic userId) async {
    try {
      final response = await _supabase
          .from('userbookprogress')
          .select('*, book(*)')
          .eq('id_akun', userId)
          .limit(5);

      List<Map<String, dynamic>> cleanedBooks = [];

      for (var item in response) {
        final bookDetail = item['book'];
        if (bookDetail != null) {
          cleanedBooks.add({
            // Data Buku Lengkap untuk Navigasi
            'id_book': bookDetail['id_book'], // Penting untuk argument navigasi
            'name': bookDetail['name'],
            'pages': bookDetail['pages'],
            'difficulty': bookDetail['difficulty'],
            'rating': bookDetail['rating'],
            'cover_book': bookDetail['cover_book'],
            // Data Progress
            'progress_percentage': item['progress_percentage'],
            'last_read_chapter': item['last_read_chapter'],
          });
        }
      }

      if (mounted) {
        setState(() {
          _bookList = cleanedBooks;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching user books: $e");
      if (mounted) setState(() => _isLoading = false);
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
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ProfileHeaderCard(avatarPath: _currentAvatarPath),
                          const SizedBox(height: 25),
                          _UserInfoSection(
                            username: _username,
                            email: _email,
                            joinedYear: _joinedSince,
                          ),
                          const SizedBox(height: 15),
                          Divider(thickness: 1, color: Colors.grey.shade200),
                          const SizedBox(height: 15),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Achievement",
                                style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, '/achievement'),
                                child: const Text("See More...", style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF2F4156), fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          _AchievementList(achievements: _achievementList),
                          
                          const SizedBox(height: 30),
                          
                          const Text(
                            "Recently Read",
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF2C3E50)),
                          ),
                          const SizedBox(height: 15),
                          _RecentlyReadList(books: _bookList),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 30, left: 0, right: 0,
                  child: CustomFloatingNavBar(
                    currentIndex: 3,
                    onTap: (index) => NavigationUtils.handleNavigation(context, index, 3),
                  ),
                ),
              ],
            ),
    );
  }
}

// --- HELPER FUNCTIONS ---

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

// --- COMPONENTS ---

class _ProfileHeaderCard extends StatelessWidget {
  final String avatarPath;
  const _ProfileHeaderCard({required this.avatarPath});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180, width: double.infinity, clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50), borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF2C3E50).withOpacity(0.3), offset: const Offset(0, 8), blurRadius: 15, spreadRadius: -5)],
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
                onTap: () => Navigator.pushNamed(context, '/editalien'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8D9E6), borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                    boxShadow: [BoxShadow(color: const Color(0xFF4F6F94), blurRadius: 0, offset: const Offset(4, 4))],
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
  final String username, email, joinedYear;
  const _UserInfoSection({required this.username, required this.email, required this.joinedYear});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(username, style: const TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            const SizedBox(height: 2),
            Text(email, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF2F4156), decoration: TextDecoration.underline, decorationColor: Color(0xFF2F4156))),
            const SizedBox(height: 8),
            Text("Joined since $joinedYear", style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/settings'),
            child: Image.asset('assets/icons/gerigi.png', width: 32, height: 32, color: Colors.black54),
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
    if (achievements.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("No achievements yet.")));
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), offset: const Offset(0, 4), blurRadius: 12)],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          for (int i = 0; i < achievements.length; i++) ...[
            _buildAchievementItem(data: achievements[i]),
            if (i != achievements.length - 1) Divider(color: Colors.grey.shade200, thickness: 1, height: 1),
          ],
        ],
      ),
    );
  }

  Widget _buildAchievementItem({required Map<String, dynamic> data}) {
    String title = data['name'] ?? 'Untitled';
    String subtitle = data['subtitle'] ?? 'Keep going!';
    String assetPath = data['icon_path'] ?? 'assets/icons/monster_ingin_tahu.svg';
    Color itemColor = _parseColorFromDb(data['background']);
    
    double scale = _safeDouble(data['svg_scale'], 1.0);
    double offsetX = _safeDouble(data['svg_offset_x'], 0.0);
    double offsetY = _safeDouble(data['svg_offset_y'], 0.0);

    int current = data['current_progress'] ?? 0;
    int max = data['max_progress'] ?? 10;
    double progressValue = (max == 0) ? 0 : (current / max);
    String progressText = "$current/$max";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        children: [
          Container(
            width: 50, height: 50, padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: itemColor, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: itemColor.withOpacity(0.3), offset: const Offset(0, 4), blurRadius: 8)]),
            child: Transform.translate(
              offset: Offset(offsetX, offsetY),
              child: Transform.scale(
                scale: scale,
                child: _buildImage(assetPath, fit: BoxFit.contain),
              ),
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
        scrollDirection: Axis.horizontal, clipBehavior: Clip.none,
        itemCount: books.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          final book = books[index];
          final title = book['name'] ?? "Untitled";
          final pages = book['pages']?.toString() ?? "0";
          final difficulty = book['difficulty'] ?? "Medium";
          final rating = book['rating']?.toString() ?? "0.0";
          final imagePath = book['cover_book'] ?? "assets/images/book image one.png";

          return _buildBookCard(
            context: context,
            bookData: book, // Mengirim FULL Data Book
            title: title, pages: "$pages Pages", difficulty: difficulty, rating: rating, imagePath: imagePath,
          );
        },
      ),
    );
  }

  Widget _buildBookCard({
    required BuildContext context,
    required Map<String, dynamic> bookData,
    required String title, required String pages, required String difficulty, required String rating, required String imagePath
  }) {
    return GestureDetector(
      // --- NAVIGASI KE STORY DETAIL ---
      onTap: () {
        Navigator.pushNamed(
          context, 
          '/story-detail', 
          arguments: {
            'id_book': bookData['id_book'],
            'book': bookData, // Kirim seluruh data buku
          },
        );
      },
      child: Container(
        width: 240, padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: const Color(0xFFC8D9E6), offset: const Offset(0, 5), blurRadius: 10)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white, width: 4), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))]), child: ClipRRect(borderRadius: BorderRadius.circular(12), child: _buildImage(imagePath, fit: BoxFit.cover)))),
          const SizedBox(height: 15),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF2F4156))),
          const SizedBox(height: 4),
          Text(pages, style: TextStyle(fontFamily: 'Poppins', color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF4F6F94), borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.access_time_filled_rounded, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(difficulty, style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600))])), const Spacer(), const Icon(Icons.star_rounded, size: 18, color: Color(0xFFFFD93D)), const SizedBox(width: 4), Text(rating, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF2C3E50)))])
        ]),
      ),
    );
  }
}