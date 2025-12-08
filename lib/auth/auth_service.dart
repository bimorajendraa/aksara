import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/hash.dart';

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

      // 3. Login Supabase Auth (wajib)
      await supabase.auth.signInWithPassword(email: email, password: password);

      return null; // success
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  bool get isLoggedIn => supabase.auth.currentUser != null;
}
