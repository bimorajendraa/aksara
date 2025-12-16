import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditAlienScreen extends StatefulWidget {
  const EditAlienScreen({super.key});

  @override
  State<EditAlienScreen> createState() => _EditAlienScreenState();
}

class _EditAlienScreenState extends State<EditAlienScreen> {
  final supabase = Supabase.instance.client;

  int _selectedTabIndex = 0;
  int _selectedCharIndex = 0;
  int _selectedBgIndex = 0;

  int? userDetailsId;
  int? idAkun;

  bool _loading = true;

  // LISTS DIAMBIL DARI DATABASE
  List<String> _characterAssets = [];
  List<Color> _backgroundColors = [];

  @override
  void initState() {
    super.initState();
    initAllData();
  }

  // =====================================================
  // LOAD DATA
  // =====================================================
  Future<void> initAllData() async {
    await loadIcons();
    await loadBackgrounds();
    await loadUserDetails();
  }

  Future<void> loadIcons() async {
    try {
      final data = await supabase.from("profileicons").select();
      if (mounted) {
        setState(() {
          _characterAssets = data.map<String>((row) => row["icon_path"] as String).toList();
        });
      }
    } catch (e) {
      debugPrint("Error loading icons: $e");
    }
  }

  Future<void> loadBackgrounds() async {
    try {
      final data = await supabase.from("profilebackground").select();
      if (mounted) {
        setState(() {
          _backgroundColors = data.map<Color>((row) {
            String hex = row["background_color"].toString();
            // Bersihkan format hex
            hex = hex.replaceAll("#", "").replaceAll("0x", "");
            if (hex.length == 6) hex = "FF$hex";
            return Color(int.parse(hex, radix: 16));
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("Error loading backgrounds: $e");
    }
  }

  Future<void> loadUserDetails() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final akun = await supabase
          .from('akun')
          .select('id_akun')
          .eq('email', user.email!)
          .maybeSingle();

      idAkun = akun?['id_akun'];

      if (idAkun == null) return;

      final details = await supabase
          .from('userdetails')
          .select()
          .eq('id_akun', idAkun!)
          .maybeSingle();

      if (details == null) {
        // CREATE DEFAULT USERDETAILS
        final inserted = await supabase
            .from('userdetails')
            .insert({
              'id_akun': idAkun,
              'id_profileicons': 1,
              'id_profilebackground': 1,
              'year_joined': DateTime.now().year,
            })
            .select()
            .single();

        userDetailsId = inserted["id_userdetails"];
        _selectedCharIndex = 0;
        _selectedBgIndex = 0;
      } else {
        userDetailsId = details["id_userdetails"];
        
        // Konversi ID (Database start 1) ke Index (List start 0)
        int dbIconId = details["id_profileicons"] ?? 1;
        int dbBgId = details["id_profilebackground"] ?? 1;

        // Safety clamp agar tidak error range
        _selectedCharIndex = (dbIconId - 1).clamp(0, _characterAssets.isEmpty ? 0 : _characterAssets.length - 1);
        _selectedBgIndex = (dbBgId - 1).clamp(0, _backgroundColors.isEmpty ? 0 : _backgroundColors.length - 1);
      }

      if (mounted) setState(() => _loading = false);
    } catch (e) {
      debugPrint("ERROR loadUserDetails: $e");
      if (mounted) setState(() => _loading = false);
    }
  }

  // =====================================================
  // UPDATE DATA
  // =====================================================
  Future<void> updateCharacter() async {
    if (userDetailsId == null) return;
    // Simpan ID = index + 1
    await supabase.from("userdetails").update({"id_profileicons": _selectedCharIndex + 1}).eq("id_userdetails", userDetailsId!);
  }

  Future<void> updateBackground() async {
    if (userDetailsId == null) return;
    await supabase.from("userdetails").update({"id_profilebackground": _selectedBgIndex + 1}).eq("id_userdetails", userDetailsId!);
  }

  // =====================================================
  // UI BUILDER
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final double headerHeight = 350;
    final double whiteSheetTopStart = 320;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // 1. BACKGROUND PREVIEW
          Positioned(
            top: 0, left: 0, right: 0, height: headerHeight,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: _backgroundColors.isNotEmpty 
                  ? _backgroundColors[_selectedBgIndex] 
                  : Colors.grey,
            ),
          ),

          // 2. CHARACTER PREVIEW (BIG IMAGE)
          Positioned(
            top: 100, left: 0, right: 0,
            child: Center(
              child: SizedBox(
                height: 280,
                width: 280,
                // Gunakan _buildImage untuk support SVG/PNG/Network
                child: _characterAssets.isNotEmpty
                    ? _buildImage(
                        _characterAssets[_selectedCharIndex], 
                        fit: BoxFit.contain
                      )
                    : const SizedBox(),
              ),
            ),
          ),

          // 3. CONTENT AREA (WHITE SHEET)
          Positioned.fill(
            top: whiteSheetTopStart,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), 
                  topRight: Radius.circular(30)
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  
                  // TAB BAR (Custom)
                  Container(
                    height: 70,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD6E6F2),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30), 
                        topRight: Radius.circular(30)
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTabItem(index: 0, icon: Icons.checkroom_rounded),
                        const SizedBox(width: 50),
                        _buildTabItem(index: 1, icon: Icons.grid_3x3_rounded),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(25, 25, 25, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedTabIndex == 0 ? "Choose Character" : "Choose Background",
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // GRID CHARACTERS
                          if (_selectedTabIndex == 0)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 25,
                                mainAxisSpacing: 25,
                                childAspectRatio: 1.0, 
                              ),
                              itemCount: _characterAssets.length,
                              itemBuilder: (context, index) {
                                return _buildCharacterOption(index);
                              },
                            )
                          // GRID BACKGROUNDS
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 25,
                                mainAxisSpacing: 25,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: _backgroundColors.length,
                              itemBuilder: (context, index) {
                                return _buildBackgroundColorOption(index);
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. TOP BAR
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    ),
                    const Text(
                      "Profile",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildTabItem({required int index, required IconData icon}) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 34, color: const Color(0xFF2C3E50)),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 4,
            width: isSelected ? 40 : 0,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF2C3E50),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterOption(int index) {
    bool isSelected = _selectedCharIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCharIndex = index);
        updateCharacter();
      },
      child: Container(
        padding: const EdgeInsets.all(12), // Padding agar gambar tidak mentok
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2C3E50) : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0,4))
          ] : [],
        ),
        // Gunakan _buildImage agar support SVG/Network/Asset
        child: _buildImage(_characterAssets[index], fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildBackgroundColorOption(int index) {
    bool isSelected = _selectedBgIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedBgIndex = index);
        updateBackground();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2C3E50) : Colors.transparent,
            width: 4, // Border tebal untuk selection
          ),
        ),
        padding: const EdgeInsets.all(4), // Jarak border dengan isi warna
        child: Container(
          decoration: BoxDecoration(
            color: _backgroundColors[index],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
            ],
          ),
          child: isSelected 
              ? const Center(child: Icon(Icons.check, color: Colors.white70, size: 40)) 
              : null,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HELPER FUNCTION: IMAGE LOADER (SVG/PNG/URL Support)
// ---------------------------------------------------------------------------
Widget _buildImage(String? path, {double? width, double? height, BoxFit fit = BoxFit.contain}) {
  if (path == null || path.isEmpty) {
    return Container(width: width, height: height, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported));
  }
  
  String cleanPath = path.trim();
  bool isUrl = cleanPath.startsWith('http');

  // Tambahkan assets/ jika bukan URL dan belum ada assets/
  if (!isUrl && !cleanPath.startsWith('assets/')) {
    cleanPath = 'assets/$cleanPath';
  }

  // Cek SVG
  if (cleanPath.toLowerCase().endsWith('.svg')) {
    if (isUrl) {
      return SvgPicture.network(
        cleanPath, width: width, height: height, fit: fit,
        placeholderBuilder: (_) => const Center(child: CircularProgressIndicator()),
      );
    }
    return SvgPicture.asset(
      cleanPath, width: width, height: height, fit: fit,
      placeholderBuilder: (_) => const Center(child: CircularProgressIndicator()),
    );
  } 
  // Cek PNG/JPG
  else if (isUrl) {
    return Image.network(
      cleanPath, width: width, height: height, fit: fit,
      errorBuilder: (_,__,___) => const Icon(Icons.broken_image),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
    );
  } else {
    return Image.asset(
      cleanPath, width: width, height: height, fit: fit,
      errorBuilder: (_,__,___) => const Icon(Icons.image_not_supported),
    );
  }
}