import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aksara/env.dart';
import 'package:flutter/material.dart';

import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/games/start/start_page.dart';
import 'screens/games/start/start_page2.dart';
import 'screens/games/start/start_page3.dart';
import 'screens/games/start/start_page4.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/already_registered_screen.dart';
import 'screens/book/story_mode_screen.dart';
import 'screens/book/story_detail_screen.dart';
import 'screens/book/chapter_read_screen.dart';

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
        '/startpage': (context) =>  StartPage(),
        '/startpage2': (context) =>  StartPage2(),
        '/startpage3': (context) =>  StartPage3(),
        '/startpage4': (context) =>  StartPage4(),
        '/story-detail': (context) => const StoryDetailScreen(),
        '/chapter': (context) => const ChapterReadScreen()
      }
    );
  }
}