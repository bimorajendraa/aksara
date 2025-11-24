import 'package:aksara/screens/editalien_screen.dart';
import 'package:aksara/screens/helpme_screen.dart';
import 'package:aksara/screens/supportcontact_screen.dart';
import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/achievement_screen.dart';
import 'screens/settings_screen.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (context) => OnboardingScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/profile/achievement': (context) => AchievementScreen(),
        '/profile/settings' : (context) => SettingScreen(),
        '/profile/settings/helpme' : (context) => HelpMeScreen(),
        '/profile/settings/helpme/supportcontact' : (context) => SupportContactScreen(),
        '/profile/editalien' : (context) => EditAlienScreen(),
      },
    );
  }
}
