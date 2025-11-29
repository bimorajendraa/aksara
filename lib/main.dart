import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

<<<<<<< Updated upstream
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
=======
import 'env.dart';

// Screens
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/already_registered_screen.dart';

// HOME (MAP PAGE)
import 'screens/home/home_page.dart';

// Story
import 'screens/story_mode_screen.dart';
import 'screens/story_detail_screen.dart';
import 'screens/chapter_read_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase sebelum aplikasi dijalankan.
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
        // Onboarding & Auth flows
=======
        //Verification page
>>>>>>> Stashed changes
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/already-registered': (context) => const AlreadyRegisteredScreen(),

<<<<<<< Updated upstream
        // Home
        '/home': (context) => HomeScreen(),

        // Levels
        '/levels': (context) => const LevelPage(),
=======
        // HOME PAGE
        '/home': (context) => const HomeScreen(),

        // Story mode pages
        '/story-mode': (context) => const StoryModeScreen(),
        '/story-detail': (context) => const StoryDetailScreen(),
        '/chapter': (context) => const ChapterReadScreen(),
>>>>>>> Stashed changes
      },
    );
  }
}
