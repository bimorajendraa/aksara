import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MapNodeWidget extends StatelessWidget {
  final String asset;
  final bool unlocked;
  final double size;

  const MapNodeWidget({
    super.key,
    required this.asset,
    required this.unlocked,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: unlocked ? const Color(0xFF98DAF5) : const Color(0xFF3D1F16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: unlocked ? const Color(0xFF7FBCD6) : const Color(0xFF64331F),
          width: 4,
        ),
      ),
      child: Center(
        child: SvgPicture.asset(
          asset,
          width: size * 0.45,
          height: size * 0.45,
        ),
      ),
    );
  }
}
