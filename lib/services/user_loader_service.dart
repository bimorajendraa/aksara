import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aksara/services/user_session.dart';

class UserLoaderService {
  UserLoaderService._private();
  static final UserLoaderService instance = UserLoaderService._private();

  final supabase = Supabase.instance.client;

  Future<void> loadUserId() async {
    final authUser = supabase.auth.currentUser;
    if (authUser == null) return;

    final uuid = authUser.id;

    final rows = await supabase
        .from("akun")
        .select("id_akun")
        .eq("supabase_uid", uuid)
        .maybeSingle();

    if (rows == null) return;

    UserSession.instance.idAkun = rows["id_akun"];
  }
}
