import 'package:flutter/material.dart';

// ==========================
// Import semua halaman
// ==========================

// Onboarding
import 'presentation/screens/onboarding_screen.dart';

// Auth
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/signup_screen.dart';
import 'presentation/screens/already_registered_screen.dart';

// Home
import 'presentation/screens/home_screen.dart';

// Levels
import 'presentation/screens/level_screen.dart';

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
        // Onboarding & Auth flows
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/already-registered': (context) => const AlreadyRegisteredScreen(),

        // Home
        '/home': (context) => HomeScreen(),

        // Levels
        '/levels': (context) => const LevelPage(),
      },
    );
  }
}
