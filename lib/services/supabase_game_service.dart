import 'package:supabase_flutter/supabase_flutter.dart';

class GameService {
  final supabase = Supabase.instance.client;

  /// UPDATE PROGRESS GAME
  Future<void> updateProgress({
    required int userId,
    required String gameKey,
    required bool isCorrect,
  }) async {
    // cek data existing
    final existing = await supabase
        .from('gameprogress')
        .select()
        .eq('id_akun', userId)
        .eq('game_key', gameKey)
        .maybeSingle();

    if (existing == null) {
      await supabase.from('gameprogress').insert({
        'id_akun': userId,
        'game_key': gameKey,
        'play_count': 1,
        'correct_count': isCorrect ? 1 : 0,
        'wrong_count': isCorrect ? 0 : 1,
        'progress_score': isCorrect ? 20 : 0,
      });
      return;
    }

    await supabase
        .from('gameprogress')
        .update({
          'play_count': existing['play_count'] + 1,
          'correct_count': existing['correct_count'] + (isCorrect ? 1 : 0),
          'wrong_count': existing['wrong_count'] + (isCorrect ? 0 : 1),
          'progress_score': (existing['progress_score'] + (isCorrect ? 10 : -5))
              .clamp(0, 100),
          'last_played': DateTime.now().toIso8601String(),
        })
        .eq('id_gameprogress', existing['id_gameprogress']);
  }
}
