import 'package:aksara/env.dart';
import 'package:aksara/screens/practice_screen.dart';
import 'package:flutter/material.dart';

import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/start_page.dart';
import 'screens/start_page2.dart';
import 'screens/start_page3.dart';
import 'screens/start_page4.dart';
import 'screens/signup_screen.dart';
import 'screens/already_registered_screen.dart';
import 'screens/writing_practice_screen.dart';
import 'screens/story_mode_screen.dart';
import 'screens/story_detail_screen.dart';
import 'screens/chapter_read_screen.dart';
import 'screens/practice_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
      title: "Aksara App",

      initialRoute: '/onboarding',

      routes: {
        '/onboarding': (context) => OnboardingScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/already-registered': (context) => AlreadyRegisteredScreen(),
        '/home': (context) => HomeScreen(),
        '/writing_practice': (context) => WritingPracticeScreen(),
        '/story-mode': (context) => const StoryModeScreen(),
        '/startpage': (context) =>  StartPage(),
        '/startpage2': (context) =>  StartPage2(),
        '/startpage3': (context) =>  StartPage3(),
        '/startpage4': (context) =>  StartPage4(),
        '/story-detail': (context) => const StoryDetailScreen(),
        '/chapter': (context) => const ChapterReadScreen(),
        '/practice': (context) => const PracticeScreen(username: "User"),
      }
    );
  }
}
