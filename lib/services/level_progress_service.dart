import 'package:supabase_flutter/supabase_flutter.dart';

class LevelProgressService {
  LevelProgressService._private();
  static final LevelProgressService instance = LevelProgressService._private();

  final supabase = Supabase.instance.client;

  /// ======================================================
  /// GET CURRENT LEVEL — ALWAYS RETURNS VALID ROW
  /// ======================================================
  Future<int> getCurrentLevel(int idAkun) async {
    final row = await supabase
        .from("levelprogress")
        .select()
        .eq("id_akun", idAkun)
        .maybeSingle();

    if (row == null) {
      // 🔥 INSERT PERTAMA KALI
      await supabase.from("levelprogress").insert({
        "id_akun": idAkun,
        "current_level": 1,
      });

      print("🟢 INSERT NEW LEVEL ROW for idAkun=$idAkun");
      return 1;
    }

    return (row["current_level"] as int?) ?? 1;
  }

  /// ======================================================
  /// INCREMENT LEVEL — GUARANTEED WORKING
  /// ======================================================
  Future<int> incrementLevel(int idAkun) async {
    final current = await getCurrentLevel(idAkun);
    final next = current + 1;

    // 🔥 UPDATE row yang pasti ada
    await supabase
        .from("levelprogress")
        .update({"current_level": next})
        .eq("id_akun", idAkun);

    print("🟢 LEVEL UP: $current → $next");
    return next;
  }

  /// ======================================================
  /// SET LEVEL MANUAL
  /// ======================================================
  Future<void> setLevel(int idAkun, int level) async {
    final existing = await supabase
        .from("levelprogress")
        .select()
        .eq("id_akun", idAkun)
        .maybeSingle();

    if (existing == null) {
      await supabase.from("levelprogress").insert({
        "id_akun": idAkun,
        "current_level": level,
      });
    } else {
      await supabase
          .from("levelprogress")
          .update({"current_level": level})
          .eq("id_akun", idAkun);
    }

    print("🟢 SET LEVEL → $level");
  }
}
