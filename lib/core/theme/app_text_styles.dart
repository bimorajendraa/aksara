import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Style teks global agar konsisten di seluruh halaman.
/// Menggunakan font Poppins sesuai desain.
class AppTextStyles {
  /// Judul level (contoh: "Level 1")
  static const TextStyle levelTitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );

  /// Subjudul level (contoh: "Get to know Alphabet")
  static const TextStyle levelSubtitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );
}
