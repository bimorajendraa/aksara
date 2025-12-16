import 'package:flutter/material.dart';

class NavigationUtils {
  static void handleNavigation(
    BuildContext context,
    int targetIndex,
    int currentIndex,
  ) {
    if (targetIndex == currentIndex) return;

    switch (targetIndex) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        break;

      case 1:
        Navigator.pushReplacementNamed(context, '/practice');
        break;

      case 2:
        Navigator.pushReplacementNamed(context, '/leaderboard');
        break;

      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;

      case 4:
        Navigator.pushNamed(context, '/camera');
        break;
    }
  }
}
