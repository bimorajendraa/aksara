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
import 'screens/signup_screen.dart';
import 'screens/already_registered_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Aksara App",

      initialRoute: '/onboarding',

      routes: {
        '/onboarding': (context) => OnboardingScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/already-registered': (context) => AlreadyRegisteredScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/achievement': (context) => AchievementScreen(),
        '/settings' : (context) => SettingScreen(),
        '/helpme' : (context) => HelpMeScreen(),
        '/supportcontact' : (context) => SupportContactScreen(),
        '/editalien' : (context) => EditAlienScreen(),
      },
    );
  }
}
