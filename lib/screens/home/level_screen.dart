import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/level_model.dart';
import 'level_card.dart';

/// Halaman daftar level.
/// Menampilkan 10 level sesuai desain dan bersifat responsif.
class LevelPage extends StatelessWidget {
  const LevelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    // Padding top dibuat adaptif untuk konsistensi visual.
    final double topPad = w * 0.053;

    // Data level diambil dari model untuk memudahkan update ke depannya.
    final levels = [
      LevelModel(id: 1, title: "Level 1", description: "Get to know Alphabet", monster: "assets/images/monster1.png", isUnlocked: true),
      LevelModel(id: 2, title: "Level 2", description: "Get to know words", monster: "assets/images/monster2.png", isUnlocked: false),
      LevelModel(id: 3, title: "Level 3", description: "Get to know letters", monster: "assets/images/monster3.png", isUnlocked: false),
      LevelModel(id: 4, title: "Level 4", description: "Get to know a paragraph", monster: "assets/images/monster4.png", isUnlocked: false),
      LevelModel(id: 5, title: "Level 5", description: "Get to know pronounce", monster: "assets/images/monster5.png", isUnlocked: false),
      LevelModel(id: 6, title: "Level 6", description: "Get to know letters", monster: "assets/images/monster6.png", isUnlocked: false),
      LevelModel(id: 7, title: "Level 7", description: "Get to know letters", monster: "assets/images/monster7.png", isUnlocked: false),
      LevelModel(id: 8, title: "Level 8", description: "Get to know letters", monster: "assets/images/monster8.png", isUnlocked: false),
      LevelModel(id: 9, title: "Level 9", description: "Get to know letters", monster: "assets/images/monster9.png", isUnlocked: false),
      LevelModel(id: 10, title: "Level 10", description: "Get to know letters", monster: "assets/images/monster10.png", isUnlocked: false),
    ];

    return Scaffold(
      backgroundColor: AppColors.navy,  // Sesuai Figma

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: w * 0.053, right: w * 0.053, top: topPad),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tombol close dengan ukuran adaptif.
              Icon(Icons.close, size: w * 0.1, color: Colors.white),

              SizedBox(height: w * 0.08),

              // List level adaptif dan tidak overflow.
              Expanded(
                child: ListView.builder(
                  itemCount: levels.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, i) {
                    final lv = levels[i];

                    return LevelCard(
                      title: lv.title,
                      description: lv.description,
                      monster: lv.monster,
                      isUnlocked: lv.isUnlocked,
                      onTap: () {},
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
