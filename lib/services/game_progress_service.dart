import 'package:supabase_flutter/supabase_flutter.dart';

class GameProgressService {
  GameProgressService._private();
  static final GameProgressService instance = GameProgressService._private();

  final SupabaseClient supabase = Supabase.instance.client;

  // ============================================================
  // 1. MENAMBAHKAN GAME HISTORY
  // ============================================================
  Future<void> addHistory({
    required int idAkun,
    required String gameKey,
    required int score,
    required bool isSuccess,
  }) async {
    print("🟦 [GameHistory] INSERT history → "
        "idAkun=$idAkun, gameKey=$gameKey, score=$score, success=$isSuccess");

    try {
      await supabase.from('gamehistory').insert({
        'id_akun': idAkun,
        'game_key': gameKey,
        'score': score,
        'is_success': isSuccess,
        'played_at': DateTime.now().toIso8601String(),
      });

      print("🟢 [GameHistory] SUCCESS insert");
    } catch (e) {
      print("🔴 [GameHistory] ERROR insert → $e");
    }
  }

  // ============================================================
  // 2. GET PROGRESS (INTERNAL)
  // ============================================================
  Future<Map<String, dynamic>?> _getProgress(int idAkun, String gameKey) async {
    print("🟦 [_getProgress] Fetching progress… idAkun=$idAkun, gameKey=$gameKey");

    try {
      final row = await supabase
          .from('gameprogress')
          .select()
          .eq('id_akun', idAkun)
          .eq('game_key', gameKey)
          .maybeSingle();

      print("🟢 [_getProgress] Result: $row");

      if (row == null) print("⚠️ [_getProgress] NULL (record belum ada)");

      return row;
    } catch (e) {
      print("🔴 [_getProgress] ERROR → $e");
      return null;
    }
  }

  // ============================================================
  // 3. UPDATE AGGREGATED PROGRESS
  // ============================================================
  Future<void> updateAggregatedProgress({
    required int idAkun,
    required String gameKey,
    required bool isCorrect,
  }) async {
    print("===============================================");
    print("🟦 [updateAggregatedProgress] START");
    print("   idAkun     : $idAkun");
    print("   gameKey    : $gameKey");
    print("   isCorrect  : $isCorrect");
    print("===============================================");

    try {
      final current = await _getProgress(idAkun, gameKey);
      final gainedScore = isCorrect ? 10 : 0;

      // CASE 1: RECORD TIDAK ADA → INSERT
      if (current == null) {
        print("🟧 [updateAggregatedProgress] RECORD EMPTY → INSERT NEW ONE");

        await supabase.from('gameprogress').insert({
          'id_akun': idAkun,
          'game_key': gameKey,
          'play_count': 1,
          'correct_count': isCorrect ? 1 : 0,
          'wrong_count': isCorrect ? 0 : 1,
          'progress_score': gainedScore,
          'last_played': DateTime.now().toIso8601String(),
        });

        print("🟢 [updateAggregatedProgress] INSERT SUCCESS");
        return;
      }

      // CASE 2: RECORD ADA → PROSES UPDATE
      print("🟦 [updateAggregatedProgress] Updating existing row…");
      print("   BEFORE UPDATE → $current");

      final newPlayCount = (current['play_count'] ?? 0) + 1;
      final newCorrect = (current['correct_count'] ?? 0) + (isCorrect ? 1 : 0);
      final newWrong = (current['wrong_count'] ?? 0) + (isCorrect ? 0 : 1);
      final newScore = (current['progress_score'] ?? 0) + gainedScore;

      print("   newPlayCount : $newPlayCount");
      print("   newCorrect   : $newCorrect");
      print("   newWrong     : $newWrong");
      print("   gainedScore  : +$gainedScore");
      print("   finalScore   : $newScore");

      await supabase
          .from('gameprogress')
          .update({
            'play_count': newPlayCount,
            'correct_count': newCorrect,
            'wrong_count': newWrong,
            'progress_score': newScore,
            'last_played': DateTime.now().toIso8601String(),
          })
          .eq('id_akun', idAkun)
          .eq('game_key', gameKey);

      print("🟢 [updateAggregatedProgress] UPDATE SUCCESS");

    } catch (e) {
      print("🔴 [updateAggregatedProgress] ERROR → $e");
    }

    print("===============================================");
    print("🟩 [updateAggregatedProgress] FINISHED");
    print("===============================================");
  }

  // ============================================================
  // 4. PUBLIC GETTER FOR UI
  // ============================================================
  Future<Map<String, dynamic>?> getProgress(int idAkun, String gameKey) async {
    print("🟦 [getProgress] Request for gameKey=$gameKey");
    return await _getProgress(idAkun, gameKey);
  }
}
