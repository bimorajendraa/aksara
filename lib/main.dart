import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'env.dart';

import 'route/route_list.dart';
import 'route/auth_route_observer.dart';
import 'screens/book/chapter_read_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("🚀 Aplikasi mulai… initialisasi Supabase...");
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
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
      initialRoute: '/',

      routes: appRoutes,

      // Dynamic route
      onGenerateRoute: (settings) {
        if (settings.name == '/chapter') {
          final id = settings.arguments as int;
          return MaterialPageRoute(
            builder: (_) => ChapterReadScreen(idBookDetails: id),
          );
        }
        return null;
      },

      navigatorObservers: [
        AuthRouteObserver(),
      ],
    );
  }
}
