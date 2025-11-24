import 'package:flutter/material.dart';

class EditAlienScreen extends StatefulWidget {
  const EditAlienScreen({super.key});

  @override
  State<EditAlienScreen> createState() => _EditAlienScreenState();
}

class _EditAlienScreenState extends State<EditAlienScreen> {
  int _selectedTabIndex = 1; 

  int _selectedColorIndex = 3;

  final List<Color> _colorOptions = [
    const Color(0xFF2C3E50),
    const Color(0xFFE76F51),
    const Color(0xFFF4A261),
    const Color(0xFF66BB6A),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              // Background Header Biru Gelap
              Container(
                height: 280,
                width: double.infinity,
                color: const Color(0xFF2C3E50),
              ),
              Expanded(child: Container(color: Colors.white)),
            ],
          ),

          Positioned.fill(
            top: 280,
            child: Column(
              children: [
                // Tab Bar
                Container(
                  color: const Color(0xFFD6E6F2),
                  height: 60,
                  child: Row(
                    children: [
                      _buildTabItem(index: 0, icon: Icons.checkroom_rounded),
                      _buildTabItem(index: 1, icon: Icons.grid_3x3_rounded),
                    ],
                  ),
                ),
                // isi konten
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedTabIndex == 1 ? "Choose Background" : "Choose Outfit",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_selectedTabIndex == 1)
                          GridView.builder(
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 25,
                              mainAxisSpacing: 25,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: _colorOptions.length,
                            itemBuilder: (context, index) => _buildColorOption(index),
                          )
                        else
                           const Center(child: Text("Coming Soon")),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 110,
            left: 0,
            right: 0,
            child: Center(
              child: _buildAlienCharacter(),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      "Profile",
                      style: TextStyle(
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

  // WIDGET ALIEN
  Widget _buildAlienCharacter() {
    return SizedBox(
      width: 220,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none, 
        children: [
          // ini posisi tubuh monster
          Container(
            height: 160,
            width: 220,
            decoration: BoxDecoration(
              color: _colorOptions[_selectedColorIndex],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(120),
                topRight: Radius.circular(120),
              ),
            ),
          ),
          
          // ini posisi mata monster
          Positioned(
            top: -30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildEye(),
                const SizedBox(width: 5),
                _buildEye(size: 60),
                const SizedBox(width: 5),
                _buildEye(),
              ],
            ),
          ),

          // ini posisi mulut monster
          Positioned(
            bottom: 50,
            child: Container(
              width: 40,
              height: 10,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.2), width: 3))
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEye({double size = 45}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: _colorOptions[_selectedColorIndex].withOpacity(0.5), width: 2),
      ),
      child: Center(
        child: Container(
          width: size * 0.5,
          height: size * 0.5,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({required int index, required IconData icon}) {
    bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          decoration: BoxDecoration(
            border: isSelected ? const Border(bottom: BorderSide(color: Color(0xFF2C3E50), width: 3)) : null,
          ),
          child: Icon(icon, size: 32, color: isSelected ? const Color(0xFF2C3E50) : Colors.grey),
        ),
      ),
    );
  }

  Widget _buildColorOption(int index) {
    bool isSelected = _selectedColorIndex == index;
    Color color = _colorOptions[index];
    return GestureDetector(
      onTap: () => setState(() => _selectedColorIndex = index),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected 
              ? Border.all(color: Colors.blue.withOpacity(0.3), width: 4)
              : Border.all(color: Colors.transparent, width: 4),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        padding: const EdgeInsets.all(4), 
        child: Container(
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
          child: isSelected ? const Center(child: Icon(Icons.check_rounded, color: Colors.white, size: 30)) : null,
        ),
      ),
    );
  }
}