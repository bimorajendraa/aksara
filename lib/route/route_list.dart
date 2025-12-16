// Package
import 'package:aksara/screens/profiles/account_screen.dart';
import 'package:aksara/screens/profiles/termsconditions_screen.dart';
import 'package:flutter/material.dart';

// Auth
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/already_registered_screen.dart';

// Homescreen
import '../screens/home/home_screen.dart';

// Profile
import '../screens/profiles/profile_screen.dart';
import '../screens/profiles/achievement_screen.dart';
import '../screens/profiles/settings_screen.dart';
import '../screens/profiles/account_screen.dart';
import '../screens/profiles/helpme_screen.dart';
import '../screens/profiles/supportcontact_screen.dart';
import '../screens/profiles/editalien_screen.dart';
import '../screens/profiles/difficulties_screen.dart';

// Entry
import '../screens/entry_screen.dart';

// Games
// Game Start
import '../screens/games/start/start_page.dart';
import '../screens/games/start/start_page2.dart';
import '../screens/games/start/start_page3.dart';
import '../screens/games/start/start_page4.dart';
// Game Drag-Drop
import '../screens/games/drag-drop/drag_drop_page.dart';
// Game Spellbee
import '../screens/games/spellbee/spellbee.dart';
// Game Practice
import '../screens/games/practice/practice_screen.dart';
// Game Writing
import '../screens/games/writing/writing_practice_screen.dart';
// Game Monster Match
import '../screens/games/monsterColorDragDrop/monster_color_drag_drop_page.dart';

// Book
import '../screens/book/story_mode_screen.dart';
import '../screens/book/story_detail_screen.dart';
import '../screens/book/chapter_read_screen.dart';

// Camera
import '../screens/camera/camera_capture_ocr_page.dart';

// Leaderboard
import '../screens/leaderboard/leaderboard.dart';

Map<String, WidgetBuilder> appRoutes = {
  '/': (_) => OnboardingScreen(),

  // AUTH
  '/login': (_) => LoginScreen(),
  '/signup': (_) => SignUpScreen(),
  '/already-registered': (_) => AlreadyRegisteredScreen(),

  // ENTRY
  '/entry': (_) => EntryScreen(),

  // HOME
  '/home': (_) => HomeScreen(),

  // PROFILE
  '/profile': (_) => ProfileScreen(),
  '/achievement': (_) => AchievementScreen(),
  '/settings': (_) => SettingScreen(),
  '/account': (_) => AccountScreen(),
  '/helpme': (_) => HelpMeScreen(),
  '/supportcontact': (_) => SupportContactScreen(),
  '/editalien': (_) => EditAlienScreen(),
  '/difficulties': (_) => DifficultiesScreen(),
  '/terms-conditions': (_) => TermsConditionScreen(),

  // GAMES
  '/startpage': (_) => StartPage(),
  '/startpage2': (_) => StartPage2(),
  '/startpage3': (_) => StartPage3(),
  '/startpage4': (_) => StartPage4(),
  '/aksara-random-drag': (_) => DragDropPage(),
  '/spellbee': (_) => SpellBeePage(),
  '/writing' : (_) => WritingPracticeScreen(),
  '/monster-match' : (_) => MonsterColorMatchPage(),
  '/practice' : (_) => PracticeScreen(username: ''),

  // BOOK
  '/story-mode': (_) => StoryModeScreen(),
  '/story-detail': (_) => StoryDetailScreen(),

  // Camera
  '/camera': (_) => CameraCaptureOCRPage(),

  // Leaderboard
  '/leaderboard': (_) => LeaderboardPage(),
  
};
