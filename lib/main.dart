import 'package:aksara/env.dart';
import 'package:aksara/screens/profiles/editalien_screen.dart';
import 'package:aksara/screens/profiles/helpme_screen.dart';
import 'package:aksara/screens/profiles/supportcontact_screen.dart';
import 'package:flutter/material.dart';

import 'screens/games/spellbee/spellbee.dart';
import 'screens/games/spellbee/spellbee2.dart';
import 'screens/profiles/profile_screen.dart';
import 'screens/profiles/achievement_screen.dart';
import 'screens/profiles/settings_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/entry_screen.dart';
import 'auth/session_gate.dart';
import 'screens/book/chapter_read_screen.dart';


import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/games/start/start_page.dart';
import 'screens/games/start/start_page2.dart';
import 'screens/games/start/start_page3.dart';
import 'screens/games/start/start_page4.dart';
import 'screens/games/drag-drop/drag_drop_page.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/already_registered_screen.dart';
import 'screens/book/story_mode_screen.dart';
import 'screens/book/story_detail_screen.dart';

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

      initialRoute: '/',

      routes: {
        '/': (context) => SessionGate(
          authenticated: HomeScreen(),
          unauthenticated: OnboardingScreen(),
        ),
        '/entry': (context) => const EntryScreen(),
        '/onboarding': (context) => OnboardingScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/already-registered': (context) => AlreadyRegisteredScreen(),
        '/aksara-random-drag': (context) => DragDropPage(),
        '/home': (context) => HomeScreen(),
        '/startpage': (context) => StartPage(),
        '/startpage2': (context) => StartPage2(),
        '/startpage3': (context) => StartPage3(),
        '/startpage4': (context) => StartPage4(),
        '/story-mode': (context) => const StoryModeScreen(),
        '/story-detail': (context) => const StoryDetailScreen(),
        '/spellbee': (context) => SpellBeePage(),
        '/spellbee2': (context) => SpellBeePage2(),
        '/profile': (context) => ProfileScreen(),
        '/achievement': (context) => AchievementScreen(),
        '/settings' : (context) => SettingScreen(),
        '/helpme' : (context) => HelpMeScreen(),
        '/supportcontact' : (context) => SupportContactScreen(),
        '/editalien' : (context) => EditAlienScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/chapter') {
          final idBookDetails = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) =>
                ChapterReadScreen(idBookDetails: idBookDetails),
          );
        }
        return null;
      },
    );
  }
}