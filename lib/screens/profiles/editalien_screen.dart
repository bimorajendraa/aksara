import 'package:flutter/material.dart';
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

  // LISTS DIAMBIL DARI DATABASE (TIDAK HARDCODE)
  List<String> _characterAssets = [];
  List<Color> _backgroundColors = [];

  @override
  void initState() {
    super.initState();
    initAllData();
  }

  // =====================================================
  // LOAD SEMUA DATA: icons, backgrounds, lalu userdetails
  // =====================================================
  Future<void> initAllData() async {
    await loadIcons();
    await loadBackgrounds();
    await loadUserDetails();
  }

  // =====================================================
  // LOAD PROFILE ICONS FROM DATABASE
  // =====================================================
  Future<void> loadIcons() async {
    final data = await supabase.from("profileicons").select();

    _characterAssets = data.map<String>((row) {
      return row["icon_path"];
    }).toList();
  }

  // =====================================================
  // LOAD BACKGROUND COLORS FROM DATABASE
  // =====================================================
  Future<void> loadBackgrounds() async {
    final data = await supabase.from("profilebackground").select();

    _backgroundColors = data.map<Color>((row) {
      final hex = row["background_color"].toString().replaceAll("0x", "");
      return Color(int.parse("0x$hex"));
    }).toList();
  }

  // =====================================================
  // LOAD USER DETAILS — AUTO INSERT IF MISSING
  // =====================================================
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

      if (idAkun == null) {
        print("❌ id_akun not found");
        return;
      }

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

        print("✨ Created default userdetails");
      } else {
        userDetailsId = details["id_userdetails"];

        _selectedCharIndex = (details["id_profileicons"] ?? 1) - 1;
        _selectedBgIndex = (details["id_profilebackground"] ?? 1) - 1;
      }

      setState(() => _loading = false);
    } catch (e) {
      print("ERROR loadUserDetails: $e");
      setState(() => _loading = false);
    }
  }

  // =====================================================
  // UPDATE CHARACTER
  // =====================================================
  Future<void> updateCharacter() async {
    if (userDetailsId == null) return;

    await supabase
        .from("userdetails")
        .update({"id_profileicons": _selectedCharIndex + 1})
        .eq("id_userdetails", userDetailsId!);

    print("🔄 Character updated");
  }

  // =====================================================
  // UPDATE BACKGROUND
  // =====================================================
  Future<void> updateBackground() async {
    if (userDetailsId == null) return;

    await supabase
        .from("userdetails")
        .update({"id_profilebackground": _selectedBgIndex + 1})
        .eq("id_userdetails", userDetailsId!);

    print("🔄 Background updated");
  }

  // =====================================================
  // UI BELOW (TIDAK DIUBAH)
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final double headerHeight = 350;
    final double whiteSheetTopStart = 320;

    if (_loading || _characterAssets.isEmpty || _backgroundColors.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // BACKGROUND PREVIEW
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: _backgroundColors[_selectedBgIndex],
            ),
          ),

          // CHARACTER PREVIEW
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                _characterAssets[_selectedCharIndex],
                height: 280,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // CONTENT AREA
          Positioned.fill(
            top: whiteSheetTopStart,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  // TAB BAR
                  Container(
                    height: 70,
                    color: const Color(0xFFD6E6F2),
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
                            _selectedTabIndex == 0
                                ? "Choose Character"
                                : "Choose Background",
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // GRID CHARS
                          if (_selectedTabIndex == 0)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 25,
                                    mainAxisSpacing: 25,
                                  ),
                              itemCount: _characterAssets.length,
                              itemBuilder: (context, index) {
                                return _buildCharacterOption(index);
                              },
                            )
                          // GRID BACKGROUND
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 25,
                                    mainAxisSpacing: 25,
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

          // TOP BAR
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
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
        ],
      ),
    );
  }

  // UI COMPONENTS (TIDAK DIUBAH)
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2C3E50) : Colors.grey,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Image.asset(_characterAssets[index]),
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
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 4,
          ),
        ),
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            color: _backgroundColors[index],
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
