import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomFloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback? onScanTap;

  const CustomFloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onScanTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // 1. BAR PUTIH
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
                scale: 1.0,
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

        // 2. TOMBOL SCAN
        Positioned(
          top: -25,
          child: GestureDetector(
            onTap: () {
              if (onScanTap != null) {
                onScanTap!();
              } else {
                print("Scan Clicked");
              }
            },
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
      behavior: HitTestBehavior.opaque,
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