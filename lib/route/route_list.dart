import 'package:aksara/screens/profiles/account_screen.dart';
import 'package:aksara/screens/profiles/termsconditions_screen.dart';
import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/already_registered_screen.dart';

import '../screens/home/home_screen.dart';
import '../screens/profiles/profile_screen.dart';
import '../screens/profiles/achievement_screen.dart';
import '../screens/profiles/settings_screen.dart';
import '../screens/profiles/account_screen.dart';
import '../screens/profiles/helpme_screen.dart';
import '../screens/profiles/supportcontact_screen.dart';
import '../screens/profiles/editalien_screen.dart';
import '../screens/profiles/difficulties_screen.dart';

import '../screens/entry_screen.dart';
import '../screens/games/start/start_page.dart';
import '../screens/games/start/start_page2.dart';
import '../screens/games/start/start_page3.dart';
import '../screens/games/start/start_page4.dart';
import '../screens/games/drag-drop/drag_drop_page.dart';

import '../screens/book/story_mode_screen.dart';
import '../screens/book/story_detail_screen.dart';
import '../screens/book/chapter_read_screen.dart';
<<<<<<< HEAD
import '../screens/games/spellbee/spellbee.dart';
=======
import '../screens/spellbee.dart';
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a

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
<<<<<<< HEAD
  '/spellbee': (_) => SpellBeePage(),
=======
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a

  // BOOK
  '/story-mode': (_) => StoryModeScreen(),
  '/story-detail': (_) => StoryDetailScreen(),
<<<<<<< HEAD
=======

  // SPELLBEE
  '/spellbee': (_) => SpellBeePage(),
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a
};
