import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // Variabel penampung data
  String _username = "Loading...";
  String _email = "Loading...";
  String _phoneNumber = "-"; 
  
  // Tampilan Profile (Default)
  String _currentAvatarPath = 'assets/icons/Monster Hijau Profile.png'; 
  Color _profileBackgroundColor = const Color(0xFF2C3E50); // Default Navy

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAccountData();
  }

  // --- FUNGSI AMBIL DATA (METODE BERTAHAP / SEQUENTIAL) ---
  // Metode ini LEBIH STABIL daripada Join Table kompleks
  Future<void> _fetchAccountData() async {
    try {
      final supabase = Supabase.instance.client;
      final session = supabase.auth.currentSession;

      if (session != null) {
        final userEmail = session.user.email;

        // 1. AMBIL DATA TABEL AKUN
        final akunData = await supabase
            .from('akun')
            .select()
            .eq('email', userEmail!)
            .maybeSingle();

        if (akunData == null) {
           if (mounted) setState(() { _username = "User Not Found"; _isLoading = false; });
           return;
        }

        // Ambil data dasar
        String fetchedUsername = akunData['username'] ?? "User";
        String fetchedPhone = akunData['phone_number'] ?? "+62 812 3456 7890";
        final int idAkun = akunData['id_akun'];
        
        // Default sementara
        String fetchedAvatar = _currentAvatarPath;
        Color fetchedBg = _profileBackgroundColor;

        // 2. AMBIL DATA USER DETAILS (Untuk ID Icon & ID Background)
        final userDetails = await supabase
            .from('userdetails')
            .select('id_profileicons, id_profilebackground')
            .eq('id_akun', idAkun)
            .maybeSingle();

        if (userDetails != null) {
           // A. Ambil Path Icon
           if (userDetails['id_profileicons'] != null) {
             final iconData = await supabase
                 .from('profileicons')
                 .select('icon_path')
                 .eq('id_profileicons', userDetails['id_profileicons'])
                 .maybeSingle();
             
             if (iconData != null) fetchedAvatar = iconData['icon_path'];
           }

           // B. Ambil Warna Background
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
        // Fallback: Cek kolom legacy di akun
        else if (akunData['avatar_path'] != null) {
           fetchedAvatar = akunData['avatar_path'];
        }

        if (mounted) {
          setState(() {
            _username = fetchedUsername;
            _email = userEmail!;
            _phoneNumber = fetchedPhone;
            _currentAvatarPath = fetchedAvatar;
            _profileBackgroundColor = fetchedBg;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading account data: $e");
      if (mounted) {
        setState(() {
          _username = "Error Load"; 
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. HEADER
          const _AccountHeader(),

          // 2. KONTEN (SCROLLABLE)
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2C3E50)))
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- PROFILE PICTURE SECTION ---
                        Center(
                          child: Column(
                            children: [
                              // Lingkaran Avatar Besar
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _profileBackgroundColor, // <--- WARNA DINAMIS DARI DB
                                ),
                                child: ClipOval(
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned(
                                        bottom: -10, 
                                        top: 10,
                                        left: 0,
                                        right: 0,
                                        child: _buildImage(_currentAvatarPath, fit: BoxFit.contain),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              // Nama Besar
                              Text(
                                _username,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 5),
                              // Email Kecil
                              Text(
                                _email,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // --- FORM FIELDS ---
                        _buildAccountField(label: "Username", value: _username),
                        _buildAccountField(label: "Email", value: _email),
                        _buildAccountField(label: "Phone Number", value: _phoneNumber),
                        _buildAccountField(label: "Password", value: "********"),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: FIELD ITEM ---
  Widget _buildAccountField({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Color(0xFF2C3E50))),
          const SizedBox(height: 8),
          const Divider(color: Colors.grey, thickness: 0.5, height: 1),
        ],
      ),
    );
  }
}

// ==========================================================
// HELPER FUNCTIONS
// ==========================================================

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

Widget _buildImage(String? path, {double? width, double? height, BoxFit fit = BoxFit.contain}) {
  if (path == null || path.isEmpty) {
    return const Icon(Icons.person, color: Colors.white, size: 50);
  }
  
  String cleanPath = path.trim();
  if (!cleanPath.startsWith('http') && !cleanPath.startsWith('assets/')) {
    cleanPath = 'assets/$cleanPath';
  }

  if (cleanPath.toLowerCase().endsWith('.svg')) {
    if (cleanPath.startsWith('http')) {
      return SvgPicture.network(cleanPath, width: width, height: height, fit: fit);
    }
    return SvgPicture.asset(cleanPath, width: width, height: height, fit: fit);
  } else if (cleanPath.startsWith('http')) {
    return Image.network(cleanPath, width: width, height: height, fit: fit);
  } else {
    return Image.asset(cleanPath, width: width, height: height, fit: fit);
  }
}

// ==========================================================
// HEADER ACCOUNT
// ==========================================================
class _AccountHeader extends StatelessWidget {
  const _AccountHeader();

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 20;

    return Container(
      width: double.infinity,
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
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
               if (Navigator.canPop(context)) {
                 Navigator.pop(context);
               } else {
                 Navigator.pushReplacementNamed(context, '/settings'); 
               }
             },
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3E50), size: 24),
          ),
          const SizedBox(width: 15),
          const Text(
            "Account",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
        ],
      ),
    );
  }
}