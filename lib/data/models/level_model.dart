/// Model data untuk setiap level di halaman Level Page.
/// Disusun sederhana agar mudah dipakai di UI dan fleksibel untuk future update.
class LevelModel {
  final int id;
  final String title;
  final String description;
  final String monster;
  final bool isUnlocked;

  const LevelModel({
    required this.id,
    required this.title,
    required this.description,
    required this.monster,
    required this.isUnlocked,
  });
}
