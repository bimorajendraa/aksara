import 'package:flutter/material.dart';

class NavigationUtils {
  // Fungsi static agar bisa dipanggil tanpa membuat object
  static void handleNavigation(BuildContext context, int targetIndex, int currentIndex) {
    
    // Jika menekan tombol halaman yang sedang aktif, jangan lakukan apa-apa
    if (targetIndex == currentIndex) return;

    // Logika Switch Case dipindah ke sini
    switch (targetIndex) {
      case 0:
        // Gunakan pushReplacementNamed agar tidak menumpuk halaman terus menerus
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/book');
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