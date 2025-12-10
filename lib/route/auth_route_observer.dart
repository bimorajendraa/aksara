import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    _check(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    if (newRoute != null) {
      _check(newRoute);
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  void _check(Route route) {
    final client = Supabase.instance.client;
    final isLoggedIn = client.auth.currentSession != null;

    final name = route.settings.name;

    // Semua halaman yang butuh login
    const protectedRoutes = [
      '/home',
      '/profile',
      '/achievement',
      '/settings',
      '/account',
      '/story-mode',
      '/story-detail',
      '/editalien',
      '/helpme',
      '/supportcontact',
      '/difficulties',
      '/terms-conditions',
      '/startpage',
      '/startpage2',
      '/startpage3',
      '/startpage4',
      '/aksara-random-drag',
      '/spellbee',
    ];

    // Jika page punya argument (dynamic)
    final isChapter = (name == '/chapter');

    // Jika user BELUM login → lempar balik ke login
    if (!isLoggedIn && (protectedRoutes.contains(name) || isChapter)) {
      Future.microtask(() {
        navigator?.pushReplacementNamed('/login');
      });
      return;
    }

    // Jika user SUDAH login, jangan boleh buka halaman login/signup
    if (isLoggedIn && (name == '/login' || name == '/signup')) {
      Future.microtask(() {
        navigator?.pushReplacementNamed('/home');
      });
    }
  }
}
