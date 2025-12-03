import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:aksara/env.dart';

import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/start_page.dart';
import 'screens/start_page2.dart';
import 'screens/start_page3.dart';
import 'screens/start_page4.dart';
import 'screens/signup_screen.dart';
import 'screens/already_registered_screen.dart';
import 'screens/home_screen.dart';
import 'screens/story_mode_screen.dart';
import 'screens/story_detail_screen.dart';
import 'screens/chapter_read_screen.dart';

Future<void> main() async {
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
      title: 'Aksara App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),

      initialRoute: '/onboarding',

      routes: {
        '/onboarding': (context) => OnboardingScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/already-registered': (context) => AlreadyRegisteredScreen(),
        '/home': (context) => HomeScreen(),
        '/startpage': (context) => StartPage(),
        '/startpage2': (context) => StartPage2(),
        '/startpage3': (context) => StartPage3(),
        '/startpage4': (context) => StartPage4(),
        '/story-mode': (context) => const StoryModeScreen(),
        '/story-detail': (context) => const StoryDetailScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/chapter') {
          final args = settings.arguments as int;

          return MaterialPageRoute(
            builder: (_) => ChapterReadScreen(idBookDetails: args),
          );
        }

        return null;
      },
    );
  }
}
