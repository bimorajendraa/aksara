import 'package:flutter/material.dart';

class NavigationUtils {
  static void handleNavigation(BuildContext context, int targetIndex, int currentIndex) {
    
    if (targetIndex == currentIndex) return;

    switch (targetIndex) {
      case 0:
        // --- PERBAIKAN DI SINI ---
        // "Buka Home, dan hapus semua halaman lain di belakangnya"
        // Ini menjamin Home adalah halaman utama/akar.
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        break;
      
      case 1:
        // Pastikan nama route di main.dart adalah '/book' atau '/story-mode' (sesuaikan)
        Navigator.pushReplacementNamed(context, '/story-mode'); 
        break;
      
      case 2:
        Navigator.pushReplacementNamed(context, '/achievement');
        break;
      
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }
}