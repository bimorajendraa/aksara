import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/hash.dart';
import 'package:aksara/services/user_session.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  /// =====================================================
  /// REGISTER (FIX: TIDAK DOUBLE SIGN UP)
  /// =====================================================
  Future<String?> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (res.user == null) {
        return "Supabase Auth registration failed.";
      }

      // ✅ INSERT KE TABEL akun JIKA BELUM ADA
      final exist = await supabase
          .from('akun')
          .select('id_akun')
          .eq('email', email)
          .maybeSingle();

      if (exist == null) {
        await supabase.from('akun').insert({
          'email': email,
          'username': username,
          'password': hashPassword(password),
        });
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// =====================================================
  /// LOGIN EMAIL + PASSWORD (FIX: TIDAK RUSAK SESSION)
  /// =====================================================
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

      if (dbUser == null) {
        return "Email tidak ditemukan.";
      }

      if (dbUser['password'] != null) {
        if (dbUser['password'] != hashPassword(password)) {
          return "Password salah!";
        }
      }

      // 3️⃣ LOGIN KE SUPABASE AUTH (WAJIB UNTUK SESSION)
      await supabase.auth.signInWithPassword(email: email, password: password);

      await hydrateFromCurrentUser();

      return null;
    } catch (e) {
      return "Login gagal.";
    }
  }

  /// =====================================================
  /// GOOGLE SIGN IN (FIX: JANGAN BACA currentUser DI SINI)
  /// =====================================================
  Future<String?> signInWithGoogle() async {
    try {
      String? redirect;
      if (kIsWeb) {
        redirect = Uri.base.origin;
      }

      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirect,
      );

      // ❗ OAuth itu redirect, jadi jangan baca currentUser di sini
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// =====================================================
  /// LOGOUT
  /// =====================================================
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  bool get isLoggedIn => supabase.auth.currentUser != null;

  /// =====================================================
  /// HYDRATE USERSESSION DARI EMAIL (TETAP DIPERTAHANKAN)
  /// =====================================================
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

/// =====================================================
/// GLOBAL HYDRATE (DIPAKAI OLEH LOGIN & SESSIONGATE)
/// =====================================================
Future<void> hydrateFromCurrentUser() async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    debugPrint("[AuthService] hydrateFromCurrentUser → NO AUTH USER");
    return;
  }

  final email = user.email;
  if (email == null) {
    debugPrint("[AuthService] hydrateFromCurrentUser → USER HAS NO EMAIL");
    return;
  }

  final akunRow = await supabase
      .from('akun')
      .select()
      .eq('email', email)
      .maybeSingle();

  if (akunRow == null) {
    debugPrint("[AuthService] hydrateFromCurrentUser → akun row NOT FOUND");
    return;
  }

  UserSession.instance.setUser(
    idAkun: akunRow['id_akun'],
    username: akunRow['username'],
    email: akunRow['email'],
  );

  debugPrint("[AuthService] Hydrated → idAkun=${akunRow['id_akun']}");
}
