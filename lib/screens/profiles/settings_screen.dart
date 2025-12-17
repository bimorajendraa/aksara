import 'dart:ui'; // Untuk efek Blur
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  // Variable Data User
  String _username = "Loading...";
  String _email = "Loading...";
  
  // Tampilan Profile
  String _currentAvatarPath = 'assets/icons/Monster Hijau Profile.png'; // Default Avatar
  Color _profileBackgroundColor = const Color(0xFF2C3E50); // Default Navy
  
  bool _isLoading = true;

  // Toggle States
  bool _emailNotif = true;
  bool _activitiesNotif = true;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // --- FUNGSI AMBIL DATA DARI SUPABASE (METODE BERTAHAP / SEQUENTIAL) ---
  // Metode ini lebih aman untuk menghindari error join table
  Future<void> _getUserData() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user != null) {
        final userEmail = user.email;

        // 1. AMBIL DATA AKUN
        final akunData = await supabase
            .from('akun')
            .select()
            .eq('email', userEmail!)
            .maybeSingle();

        if (akunData == null) {
           if (mounted) setState(() { _username = "User Not Found"; _isLoading = false; });
           return;
        }

        String fetchedUsername = akunData['username'] ?? "User";
        final int idAkun = akunData['id_akun'];
        
        // Default values
        String fetchedAvatar = _currentAvatarPath;
        Color fetchedBg = _profileBackgroundColor;

        // 2. AMBIL USER DETAILS (Untuk ID Icon & ID Background)
        final userDetails = await supabase
            .from('userdetails')
            .select('id_profileicons, id_profilebackground')
            .eq('id_akun', idAkun)
            .maybeSingle();

        if (userDetails != null) {
           // A. Ambil Icon Path
           if (userDetails['id_profileicons'] != null) {
             final iconData = await supabase
                .from('profileicons')
                .select('icon_path')
                .eq('id_profileicons', userDetails['id_profileicons'])
                .maybeSingle();
             
             if (iconData != null && iconData['icon_path'] != null) {
               fetchedAvatar = iconData['icon_path'];
             }
           }

           // B. Ambil Background Color
           if (userDetails['id_profilebackground'] != null) {
             final bgData = await supabase
                .from('profilebackground')
                .select('background_color')
                .eq('id_profilebackground', userDetails['id_profilebackground'])
                .maybeSingle();
             
             if (bgData != null) {
               fetchedBg = _parseColorFromDb(bgData['background_color']);
             }
           }
        } 
        // Fallback: Cek kolom legacy
        else if (akunData.containsKey('avatar_path') && akunData['avatar_path'] != null) {
           fetchedAvatar = akunData['avatar_path'];
        }

        if (mounted) {
          setState(() {
            _username = fetchedUsername;
            _email = userEmail!;
            _currentAvatarPath = fetchedAvatar;
            _profileBackgroundColor = fetchedBg; // Update warna background
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _username = "Guest";
            _email = "No Session";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching settings data: $e");
      if (mounted) {
        setState(() {
          _username = "Error Load";
          _email = "-";
          _isLoading = false;
        });
      }
    }
  }

  // --- FUNGSI LOGOUT ---
  Future<void> _handleLogout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.of(context).pop(); // Tutup Dialog
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      debugPrint("Error logout: $e");
    }
  }

  // --- FUNGSI POPUP ---
  void _showLogoutPopup() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.2),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: LogoutDialog(onLogoutPressed: _handleLogout),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER DINAMIS (Kirim Warna & Avatar)
          _SettingHeader(
            username: _username,
            email: _email,
            isLoading: _isLoading,
            avatarPath: _currentAvatarPath, 
            profileBackgroundColor: _profileBackgroundColor, // Warna dari DB
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Column(
                children: [
                  // 1. Email Notification
                  _buildSwitchTile(
                    iconAsset: 'assets/icons/email-notification.svg',
                    title: "Email Notification",
                    iconSize: 19.0,
                    value: _emailNotif,
                    onChanged: (val) => setState(() => _emailNotif = val),
                  ),
                  const Divider(),

                  // 2. Activities Notification
                  _buildSwitchTile(
                    iconAsset: 'assets/icons/activities-notification.svg',
                    title: "Activities Notification",
                    value: _activitiesNotif,
                    onChanged: (val) => setState(() => _activitiesNotif = val),
                  ),
                  const Divider(),

                  // 3. Menu Items
                  _buildMenuTile(
                    title: "About Us", 
                    iconAsset: 'assets/icons/about-us.svg', 
                    onTap: () {}
                  ),
                  const Divider(),

                  _buildMenuTile(title: "Account", onTap: () {
                    Navigator.pushNamed(context, '/account');
                  }),
                  const Divider(),
                  
                  _buildMenuTile(title: "Delete Account", onTap: () {}),
                  const Divider(),
                  
                  _buildMenuTile(title: "Help Me", onTap: () {
                    Navigator.pushNamed(context, '/helpme');
                  }),
                  const Divider(),
                  
                  _buildMenuTile(title: "Terms & Condition", onTap: () {
                    Navigator.pushNamed(context, '/terms-conditions');
                  }),
                  const Divider(),
                  
                  const SizedBox(height: 20),

                  // TOMBOL LOGOUT
                  _buildLogOutTile(),
                  
                  const Divider(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildSwitchTile({
    required String iconAsset,
    required String title,
    required bool value,
    required Function(bool) onChanged,
    double iconSize = 24.0,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // Gunakan _buildImage untuk safety jika svg tidak ada
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: _buildImage(iconAsset, fit: BoxFit.contain),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title, 
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Color(0xFF2C3E50))
            )
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            thumbColor: const MaterialStatePropertyAll(Colors.white),
            activeTrackColor: const Color(0xFF2F4156),
            inactiveTrackColor: const Color(0xFFE0E0E0),
            trackOutlineColor: const MaterialStatePropertyAll(Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required String title, 
    String? iconAsset, 
    required VoidCallback onTap,
    double iconSize = 24.0,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            if (iconAsset != null) ...[
              SizedBox(
                width: iconSize,
                height: iconSize,
                child: _buildImage(iconAsset, fit: BoxFit.contain),
              ),
              const SizedBox(width: 15),
            ],
            Expanded(
              child: Text(
                title, 
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Color(0xFF2C3E50))
              )
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildLogOutTile() {
    return InkWell(
      onTap: _showLogoutPopup, 
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(child: Text("Log Out", style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.deepOrange, fontWeight: FontWeight.w500))),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.deepOrange),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// 1. HELPER FUNCTIONS
// ==========================================================

// Parse Hex Color (e.g., 0xFF123456)
Color _parseColorFromDb(String? hexString) {
  if (hexString == null || hexString.isEmpty) return const Color(0xFF2C3E50);
  try {
    String cleanHex = hexString.replaceAll("#", "").replaceAll("0x", "").toUpperCase();
    if (cleanHex.length == 6) cleanHex = "FF$cleanHex";
    return Color(int.parse(cleanHex, radix: 16));
  } catch (e) {
    return const Color(0xFF2C3E50);
  }
}

// Image Loader (SVG/PNG/URL Support)
Widget _buildImage(String? path, {double? width, double? height, BoxFit fit = BoxFit.contain}) {
  if (path == null || path.isEmpty) {
    return Container(width: width, height: height, color: Colors.grey.shade200, child: const Icon(Icons.person, color: Colors.grey));
  }
  
  String cleanPath = path.trim();
  if (!cleanPath.startsWith('http') && !cleanPath.startsWith('assets/')) {
    cleanPath = 'assets/$cleanPath';
  }

  // Cek Tipe File
  if (cleanPath.toLowerCase().endsWith('.svg')) {
    if (cleanPath.startsWith('http')) {
      return SvgPicture.network(cleanPath, width: width, height: height, fit: fit, placeholderBuilder: (_) => const Center(child: CircularProgressIndicator()));
    }
    return SvgPicture.asset(cleanPath, width: width, height: height, fit: fit);
  } else if (cleanPath.startsWith('http')) {
    return Image.network(cleanPath, width: width, height: height, fit: fit, errorBuilder: (_,__,___) => const Icon(Icons.broken_image));
  } else {
    return Image.asset(cleanPath, width: width, height: height, fit: fit, errorBuilder: (_,__,___) => const Icon(Icons.image_not_supported));
  }
}

// ==========================================================
// 2. HEADER SETTING
// ==========================================================
class _SettingHeader extends StatelessWidget {
  final String username;
  final String email;
  final bool isLoading;
  final String avatarPath;
  final Color profileBackgroundColor; // Warna background dinamis

  const _SettingHeader({
    required this.username,
    required this.email,
    required this.isLoading,
    required this.avatarPath,
    required this.profileBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 20;

    return Container(
      padding: EdgeInsets.fromLTRB(25, topPadding, 25, 20),
      decoration: const BoxDecoration(
        color: Color(0xFFD6E6F2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF2C3E50), size: 22),
              ),
              const SizedBox(width: 10),
              const Text("Settings",
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50))),
            ],
          ),
          
          const SizedBox(height: 15),
          
          Row(
            children: [
              // --- AVATAR DINAMIS ---
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: profileBackgroundColor, // <--- Warna dari DB
                ),
                child: ClipOval(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                       Positioned(
                         bottom: -6, 
                         top: 6,
                         left: 0,
                         right: 0,
                         child: _buildImage(avatarPath, fit: BoxFit.contain), 
                       ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 15),
              
              // --- INFO USER ---
              isLoading
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            width: 120, height: 20,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(4))),
                        const SizedBox(height: 8),
                        Container(
                            width: 180, height: 14,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(4))),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Color(0xFF546E7A)),
                        ),
                      ],
                    ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// 3. LOGOUT POPUP DIALOG
// ==========================================================
class LogoutDialog extends StatelessWidget {
  final VoidCallback onLogoutPressed;

  const LogoutDialog({super.key, required this.onLogoutPressed});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close, color: Colors.grey, size: 24),
              ),
            ),
            const SizedBox(height: 10),
            
            // --- GAMBAR MONSTER STATIS (PINK) ---
            SizedBox(
              height: 130, width: 130, 
              child: Image.asset(
                'assets/icons/logout-monster.png', // Pastikan file ini ada
                fit: BoxFit.contain,
              ),
            ),
            
            const SizedBox(height: 20),
            const Text("Are you sure want to logout?", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            const SizedBox(height: 10),
            const Text("You are logout, You need to input\nyour detail to get back this app", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey, height: 1.5)),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    child: const Text("CANCEL", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onLogoutPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5722),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 4,
                      shadowColor: const Color(0xFFFF5722).withOpacity(0.4),
                    ),
                    child: const Text("LOGOUT", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}