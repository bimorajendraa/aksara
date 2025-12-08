class MapNode {
  final double x; // posisi: 0.0 - 1.0 (persentase)
  final double y; // posisi: 0.0 - 1.0
  final bool unlocked;
  final String asset; // icon path

  MapNode({
    required this.x,
    required this.y,
    required this.unlocked,
    required this.asset,
  });
}
