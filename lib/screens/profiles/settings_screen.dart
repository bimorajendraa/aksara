import 'dart:ui'; // Untuk efek Blur
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Untuk SVG
import 'package:supabase_flutter/supabase_flutter.dart'; // Untuk Supabase

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  // Variable Data User
  String _username = ""; 
  String _email = "";
  bool _isLoading = true;

  // Toggle States
  bool _emailNotif = true;
  bool _activitiesNotif = true;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // --- FUNGSI AMBIL DATA DARI SUPABASE ---
  Future<void> _getUserData() async {
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;

      if (session != null) {
        final userEmail = session.user.email;
        if (userEmail != null) {
          final data = await supabase
              .from('akun')
              .select()
              .eq('email', userEmail)
              .single();

          if (mounted) {
            setState(() {
              _username = data['username'] ?? "User"; 
              _email = data['email'] ?? userEmail;
              _isLoading = false;
            });
          }
        }
      } else {
        setState(() {
          _username = "Guest";
          _email = "No Session";
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
      if (mounted) {
        setState(() {
          _username = "Error Loading";
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
        Navigator.of(context).pop(); 
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
      // Menggunakan Column langsung tanpa SafeArea di body agar Header bisa mentok ke atas,
      // tapi kita atur padding di dalam Header-nya.
      body: Column(
        children: [
          // HEADER DINAMIS
          _SettingHeader(
            username: _username,
            email: _email,
            isLoading: _isLoading,
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Column(
                children: [
                  // 1. Email Notification (SVG)
                  _buildSwitchTile(
                    iconAsset: 'assets/icons/email-notification.svg',
                    title: "Email Notification",
                    iconSize: 19.0,
                    value: _emailNotif,
                    onChanged: (val) => setState(() => _emailNotif = val),
                  ),
                  const Divider(),

                  // 2. Activities Notification (SVG)
                  _buildSwitchTile(
                    iconAsset: 'assets/icons/activities-notification.svg',
                    title: "Activities Notification",
                    value: _activitiesNotif,
                    onChanged: (val) => setState(() => _activitiesNotif = val),
                  ),
                  const Divider(),

                  // 3. About Us (SVG)
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

  // --- WIDGET HELPER: SWITCH TILE (UPDATED SVG & COLORS) ---
  Widget _buildSwitchTile({
    required String iconAsset,
    required String title,
    required bool value,
    required Function(bool) onChanged,
    double iconSize = 24.0, // <--- Parameter Baru (Default 24)
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SvgPicture.asset(
            iconAsset,
            width: iconSize,  // <--- Gunakan parameter di sini
            height: iconSize, // <--- Gunakan parameter di sini
            fit: BoxFit.contain, // Agar gambar tidak penyok
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

  // --- WIDGET HELPER: MENU TILE (UPDATED SVG SUPPORT) ---
  Widget _buildMenuTile({
    required String title, 
    String? iconAsset, 
    required VoidCallback onTap,
    double iconSize = 24.0, // <--- Parameter Baru
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            if (iconAsset != null) ...[
              SvgPicture.asset(
                iconAsset,
                width: iconSize,   // <--- Pakai parameter
                height: iconSize,  // <--- Pakai parameter
                fit: BoxFit.contain,
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
// 3. LOGOUT POPUP DIALOG (SAMA SEPERTI SEBELUMNYA)
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
            SizedBox(
              height: 130, 
              width: 130, 
              child: SvgPicture.asset(
                'assets/images/profile_avatar6_bluegrey.svg', 
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
                      // padding: const EdgeInsets.symmetric(vertical: 14),
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
                      // padding: const EdgeInsets.symmetric(vertical: 14),
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

// ==========================================================
// HEADER SETTING (UPDATED: TOP SPACING & LAYOUT)
// ==========================================================
class _SettingHeader extends StatelessWidget {
  final String username;
  final String email;
  final bool isLoading;

  const _SettingHeader({
    required this.username,
    required this.email,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    // Gunakan MediaQuery untuk padding atas agar dinamis sesuai poni HP (Safe Area)
    final topPadding = MediaQuery.of(context).padding.top + 20; 

    return Container(
      // Padding atas dikurangi agar lebih mepet
      // fromLTRB(left, top, right, bottom)
      // Top menggunakan `topPadding` agar tidak tertutup jam/status bar tapi tetap rapat.
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
                // Hilangkan padding bawaan icon button agar benar-benar di pojok
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF2C3E50), size: 22),
              ),
              const SizedBox(width: 10),
              const Text("Setting",
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50))),
            ],
          ),
          
          // Jarak antara Judul dan Profile dikurangi (dari 25 jadi 15)
          const SizedBox(height: 15), 
          
          Row(
            children: [
              // --- AVATAR ---
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF2C3E50),
                ),
                child: ClipOval(
                  child: Transform.translate(
                    offset: const Offset(-4.5, 8), // Posisi avatar
                    child: Image.asset(
                      'assets/icons/Monster Hijau Profile.png',
                      fit: BoxFit.contain, 
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.person, color: Colors.white),
                    ),
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