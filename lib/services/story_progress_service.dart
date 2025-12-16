import 'package:supabase_flutter/supabase_flutter.dart';

class StoryProgressService {
  StoryProgressService._();
  static final StoryProgressService instance = StoryProgressService._();

  final supabase = Supabase.instance.client;

  /// Tandai 1 chapter sebagai selesai.
  Future<void> completeChapter({
    required int idAkun,
    required int idBookDetails,
  }) async {
    await supabase.from('usercompletedchapter').upsert({
      'id_akun': idAkun,
      'id_bookdetails': idBookDetails,
      'is_completed': true,
      'completed_at': DateTime.now().toIso8601String(),
    }, onConflict: 'id_akun,id_bookdetails');
  }

  /// Update progress percentage di userbookprogress.
  Future<void> updateBookProgress({
    required int idAkun,
    required int idBook,
    required int completedChapterCount,
    required int totalChapterCount,
  }) async {
    final percent =
        (completedChapterCount / totalChapterCount * 100).round().clamp(0, 100);

    await supabase.from('userbookprogress').upsert({
      'id_akun': idAkun,
      'id_book': idBook,
      'progress_percentage': percent,
      'last_read_chapter': completedChapterCount,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'id_akun,id_book');
  }
}

