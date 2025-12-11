import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/hash.dart';
<<<<<<< HEAD
import 'package:aksara/services/user_session.dart';
=======
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a

class AuthService {
  final supabase = Supabase.instance.client;

  Future<String?> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final res = await supabase.auth.signUp(email: email, password: password);

      if (res.user == null) {
        return "Supabase Auth registration failed.";
      }

      await supabase.from('akun').insert({
        'email': email,
        'username': username,
        'password': hashPassword(password),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final dbUser = await supabase
          .from('akun')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (dbUser == null) return "Email tidak ditemukan.";

      if (dbUser['password'] != hashPassword(password)) {
        return "Password salah!";
      }

<<<<<<< HEAD
      // 3. Login Supabase Auth (wajib) dan hydrate untuk id
      await supabase.auth.signInWithPassword(email: email, password: password);
      await hydrateFromCurrentUser();
=======
      await supabase.auth.signInWithPassword(email: email, password: password);
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> signInWithGoogle() async {
    try {
      String? redirect;

      if (kIsWeb) {
        redirect = Uri.base.origin;
      } else {
        redirect = null;
      }

      // Supabase OAuth
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirect,
      );

      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final email = user.email;
      final name = user.userMetadata?['full_name'] ?? email?.split('@')[0];
      final avatar = user.userMetadata?['avatar_url'];

      if (email == null) return "Email Google tidak ditemukan.";

      final exist = await supabase
          .from('akun')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (exist == null) {
        await supabase.from('akun').insert({
          'email': email,
          'username': name,
          'password': null,
          'avatar_url': avatar,
        });
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  bool get isLoggedIn => supabase.auth.currentUser != null;
<<<<<<< HEAD

    /// Panggil ini setelah login sukses.
  Future<void> hydrateUserSessionFromAkun(String email) async {
    final row = await supabase
        .from('akun')
        .select('id_akun, username, email')
        .eq('email', email)
        .single();

    UserSession.instance.setUser(
      idAkun: row['id_akun'] as int,
      username: row['username'] as String?,
      email: row['email'] as String?,
      );
  }
}

Future<void> hydrateFromCurrentUser() async {
  final _supabase = Supabase.instance.client;
  final user = _supabase.auth.currentUser;

  if (user == null) {
    print("[AuthService] hydrateFromCurrentUser → NO AUTH USER");
    return;
  }

  final email = user.email;
  if (email == null) {
    print("[AuthService] hydrateFromCurrentUser → USER HAS NO EMAIL");
    return;
  }

  final akunRow = await _supabase
      .from('akun')
      .select()
      .eq('email', email)
      .maybeSingle();

  if (akunRow == null) {
    print("[AuthService] hydrateFromCurrentUser → akun row NOT FOUND");
    return;
  }

  UserSession.instance.setUser(
    idAkun: akunRow['id_akun'],
    username: akunRow['username'],
    email: akunRow['email'],
  );

  print("[AuthService] Hydrated from currentUser → idAkun=${akunRow['id_akun']}");
=======
>>>>>>> 147adc4881ed146917d7bb89ce8368b252deb78a
}
