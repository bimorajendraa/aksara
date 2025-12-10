import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/hash.dart';
import 'package:aksara/services/user_session.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  // ===================================================================
  // REGISTER
  // ===================================================================
  Future<String?> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      // 1. Create Supabase Auth user
      final res = await supabase.auth.signUp(email: email, password: password);

      if (res.user == null) return "Supabase Auth registration failed.";

      // 2. Insert to custom DB table
      await supabase.from('akun').insert({
        'email': email,
        'username': username,
        'password': hashPassword(password),
      });

      return null; // success
    } catch (e) {
      return e.toString();
    }
  }

  // ===================================================================
  // LOGIN
  // ===================================================================
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Cek user di table akun
      final dbUser = await supabase
          .from('akun')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (dbUser == null) {
        return "Email tidak ditemukan.";
      }

      // 2. Validasi password hash
      if (dbUser['password'] != hashPassword(password)) {
        return "Password salah!";
      }

      // 3. Login Supabase Auth (wajib) dan hydrate untuk id
      await supabase.auth.signInWithPassword(email: email, password: password);
      await hydrateFromCurrentUser();

      return null; // success
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  bool get isLoggedIn => supabase.auth.currentUser != null;

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
}
