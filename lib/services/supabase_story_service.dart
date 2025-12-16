// class StoryService {
//   final supabase = Supabase.instance.client;

//   Future<void> markChapterCompleted({
//     required int userId,
//     required int bookDetailId,
//   }) async {
//     await supabase.from('usercompletedchapter').insert({
//       'id_akun': userId,
//       'id_bookdetails': bookDetailId,
//       'is_completed': true,
//       'completed_at': DateTime.now().toIso8601String(),
//     });
//   }
// }
