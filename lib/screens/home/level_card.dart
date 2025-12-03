import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Widget kartu level.
/// Sudah adaptif terhadap ukuran layar dan mempertahankan proporsi desain Figma.
class LevelCard extends StatelessWidget {
  final String title;
  final String description;
  final String monster;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const LevelCard({
    super.key,
    required this.title,
    required this.description,
    required this.monster,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    // Tinggi kartu dibuat proporsional agar tampilan konsisten di berbagai device.
    final double cardHeight = w * 0.165;

    // Padding dalam kartu mengikuti proporsi dari desain asli.
    final double innerPad = w * 0.053;

    // Ukuran monster dibuat responsif agar tidak pecah di layar besar.
    final double monsterSize = w * 0.18;

    // Jarak antar kartu ditambah 15% seperti permintaan.
    final double cardSpacing = (cardHeight * 0.35) * 1.15;

    // Radius mengikuti proporsi Figma.
    final double radius = w * 0.082;

    // Ukuran ikon kunci adaptif.
    final double lockSize = w * 0.1;

    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Container(
        height: cardHeight,
        margin: EdgeInsets.only(bottom: cardSpacing),
        padding: EdgeInsets.symmetric(horizontal: innerPad),

        decoration: BoxDecoration(
          color: AppColors.levelCard,
          borderRadius: BorderRadius.circular(radius),
        ),

        child: Row(
          children: [
            // Gambar monster mengikuti ukuran layar.
            Image.asset(
              monster,
              width: monsterSize,
              height: monsterSize,
              fit: BoxFit.contain,
            ),

            SizedBox(width: w * 0.04),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.levelTitle),
                const SizedBox(height: 3),
                Text(description, style: AppTextStyles.levelSubtitle),
              ],
            ),

            const Spacer(),

            if (!isUnlocked)
              Icon(
                Icons.lock,
                size: lockSize,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }
}
