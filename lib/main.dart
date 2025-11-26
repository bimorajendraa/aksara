import 'package:flutter/material.dart';

import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/already_registered_screen.dart';
import 'screens/story_mode_screen.dart';
import 'screens/story_detail_screen.dart';
import 'screens/chapter_read_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://YOUR_PROJECT_URL.supabase.co',
    anonKey: 'YOUR_ANON_KEY',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

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

        // STORY MODE
        '/story-mode': (context) => const StoryModeScreen(),
        '/story-detail': (context) => const StoryDetailScreen(),
        '/chapter': (context) => const ChapterReadScreen(),
      },
    );
  }
}
