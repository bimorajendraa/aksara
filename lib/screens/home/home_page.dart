import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum NodeState { completed, current, locked }

class MapNode {
  final double xFactor; // 0..1 posisi horizontal relatif terhadap lebar
  final double yOffset; // offset vertikal dalam pixels
  final NodeState state;

  MapNode({
    required this.xFactor,
    required this.yOffset,
    required this.state,
  });

  static const double size = 72.0; // lebih besar
}

/// ===========================================================
/// FIXED DOT PATTERN — SESUAI FIGMA 
/// (dot lebih kecil, spacing lebih renggang, warna lebih soft)
/// ===========================================================
class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3D4F5F).withOpacity(0.45)
      ..style = PaintingStyle.fill;

    const double dotSize = 3;      // DOT FIX
    const double spacingX = 48.0;  // FIGMA ACCURATE
    const double spacingY = 48.0;

    for (double y = spacingY / 2; y < size.height; y += spacingY) {
      for (double x = spacingX / 2; x < size.width; x += spacingX) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FlowConnector extends StatelessWidget {
  final Offset start;
  final Offset end;
  final bool isCompleted;
  final String direction;

  const FlowConnector({
    super.key,
    required this.start,
    required this.end,
    required this.isCompleted,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    final svgAsset = 'assets/icons/$direction.svg';

    final color = isCompleted
        ? const Color(0xFF98DAF5)
        : const Color(0xFF5C7590);

    // Tambahan drop khusus yang GENAP (bawah-belok)
    double extraDrop = 0;

    if (direction == 'bawah-kiri' || direction == 'bawah-kanan') {
      extraDrop = 28; // PERFECT ke Figma, tweakable
    }

    final left = (direction == 'kiri-bawah' || direction == 'bawah-kiri')
        ? end.dx
        : start.dx;

    final top = start.dy + MapNode.size / 2 + extraDrop;

    final width = (end.dx - start.dx).abs();
    final height = end.dy - start.dy - MapNode.size / 2;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: SvgPicture.asset(
        svgAsset,
        fit: BoxFit.fill,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}



/// ===========================================================
/// NODE WIDGET — TIDAK DIUBAH KECUALI WARNA SUDAH SESUAI
/// ===========================================================
class MapNodeWidget extends StatelessWidget {
  final NodeState state;

  const MapNodeWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    Color outerBg;
    Color innerBg;
    Widget icon;

    switch (state) {
      case NodeState.completed:
        outerBg = const Color(0xFF5BA8C8);
        innerBg = const Color(0xFF8ED4F5);
        icon = SvgPicture.asset(
          "assets/icons/book-open.svg",
          width: 28,
          height: 28,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        );
        break;

      case NodeState.current:
        outerBg = const Color(0xFF9DB3C7);
        innerBg = const Color(0xFFCFDDE9);
        icon = SvgPicture.asset(
          "assets/icons/book.svg",
          width: 28,
          height: 28,
          colorFilter: const ColorFilter.mode(
            Color(0xFF3D4F5F),
            BlendMode.srcIn,
          ),
        );
        break;

      case NodeState.locked:
        outerBg = const Color(0xFF637F9F);
        innerBg = const Color(0xFF2F4156);
        icon = const Icon(
          Icons.lock,
          color: Color(0xFF7D8FA3),
          size: 28,
        );
        break;
    }

    return Container(
      width: MapNode.size,
      height: MapNode.size,
      decoration: BoxDecoration(
        color: outerBg,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(5),
      child: Container(
        decoration: BoxDecoration(
          color: innerBg,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Center(child: icon),
      ),
    );
  }
}

/// ===========================================================
/// NEXT LEVEL CARD (TIDAK DIRUBAH, HANYA SPACING DIPERBAIKI)
/// ===========================================================
class NextLevelCard extends StatelessWidget {
  final int levelNumber;
  final String monsterAsset;

  const NextLevelCard({
    super.key,
    required this.levelNumber,
    required this.monsterAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 40, 20, 30),  // FIX spacing
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF637F9F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF476280),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Level $levelNumber",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "What is number? how we spell it?\nhow to write it?",
                    style: TextStyle(
                      color: Color(0xFFB0BCC9),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFC8D9E6),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(0xFF476280),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Image.asset(
              monsterAsset,
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}

/// ===========================================================
/// NAVBAR (TIDAK DIOTAK-ATIK KARENA SUDAH BAGUS)
/// ===========================================================
class HomeBottomNavBar extends StatelessWidget {
  const HomeBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SvgPicture.asset(
                  "assets/icons/home.svg",
                  width: 32,
                  height: 32,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF5C7590),
                    BlendMode.srcIn,
                  ),
                ),
                SvgPicture.asset(
                  "assets/icons/book-open.svg",
                  width: 32,
                  height: 32,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFB0BCC9),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 70),
                SvgPicture.asset(
                  "assets/icons/leaderboard.svg",
                  width: 32,
                  height: 32,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFB0BCC9),
                    BlendMode.srcIn,
                  ),
                ),
                SvgPicture.asset(
                  "assets/icons/user.svg",
                  width: 32,
                  height: 32,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFB0BCC9),
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: -30,
            left: MediaQuery.of(context).size.width / 2 - 38,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFD5E3F0),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 66,
                  height: 66,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8ED4F5),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/icons/tdesign_scan.svg",
                      width: 32,
                      height: 32,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF0E0F1A),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===========================================================
/// HOME SCREEN — MAIN PAGE
/// PATCH: background + flow fix + dot fix
/// ===========================================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  List<MapNode> _buildNodes() {
    const spacing = 120.0;
    return [
      MapNode(xFactor: 0.50, yOffset: 0, state: NodeState.completed),
      MapNode(xFactor: 0.72, yOffset: spacing, state: NodeState.completed),
      MapNode(xFactor: 0.50, yOffset: spacing * 2, state: NodeState.current),
      MapNode(xFactor: 0.28, yOffset: spacing * 3, state: NodeState.locked),
      MapNode(xFactor: 0.50, yOffset: spacing * 4, state: NodeState.locked),
      MapNode(xFactor: 0.72, yOffset: spacing * 5, state: NodeState.locked),
      MapNode(xFactor: 0.50, yOffset: spacing * 6, state: NodeState.locked),
      MapNode(xFactor: 0.28, yOffset: spacing * 7, state: NodeState.locked),
      MapNode(xFactor: 0.50, yOffset: spacing * 8, state: NodeState.locked),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final nodes = _buildNodes();

    final currentIndex = nodes.indexWhere((n) => n.state == NodeState.current);
    final effectiveCurrentIndex = currentIndex == -1 ? 0 : currentIndex;

    final offsets = nodes.map((n) {
      return Offset(
        n.xFactor * screenWidth,
        n.yOffset,
      );
    }).toList();

    final mapHeight = nodes.last.yOffset + 180;

    return Scaffold(
      backgroundColor: const Color(0xFF476280),  // FIX BACKGROUND
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: const Color(0xFF476280), // FIX
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC8D9E6),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: List.generate(5, (i) {
                            return Padding(
                              padding: EdgeInsets.only(
                                right: i < 4 ? 6 : 0,
                              ),
                              child: SvgPicture.asset(
                                "assets/images/heart.svg",
                                width: 22,
                                height: 22,
                              ),
                            );
                          }),
                        ),
                        Row(
                          children: [
                            SvgPicture.asset(
                              "assets/images/coin.svg",
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              "13",
                              style: TextStyle(
                                color: Color(0xFF0E0F1A),
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC8D9E6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/monster1.png",
                          width: 64,
                          height: 64,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Level 1",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0E0F1A),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Get to know letters",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF5C7590),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Center(
                          child: SizedBox(
                            width: screenWidth * 0.8,
                            height: mapHeight,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: DotPatternPainter(),
                                  ),
                                ),

                                ...List.generate(nodes.length - 1, (i) {
                                  final isCompleted = i < effectiveCurrentIndex;

                                  String direction;
                                  switch (i % 4) {
                                    case 0:
                                      direction = 'kanan-bawah';
                                      break;
                                    case 1:
                                      direction = 'bawah-kiri';
                                      break;
                                    case 2:
                                      direction = 'kiri-bawah';
                                      break;
                                    default:
                                      direction = 'bawah-kanan';
                                  }

                                  final startOffset = Offset(
                                    nodes[i].xFactor * screenWidth * 0.8,
                                    offsets[i].dy,
                                  );
                                  final endOffset = Offset(
                                    nodes[i + 1].xFactor * screenWidth * 0.8,
                                    offsets[i + 1].dy,
                                  );

                                  return FlowConnector(
                                    start: startOffset,
                                    end: endOffset,
                                    isCompleted: isCompleted,
                                    direction: direction,
                                  );
                                }),

                                ...List.generate(nodes.length, (i) {
                                  final nodeX = nodes[i].xFactor * screenWidth * 0.8;

                                  return Positioned(
                                    left: nodeX - MapNode.size / 2,
                                    top: offsets[i].dy,
                                    child: MapNodeWidget(state: nodes[i].state),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),

                        NextLevelCard(
                          levelNumber: 2,
                          monsterAsset: "assets/images/monster2.png",
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: const HomeBottomNavBar(),
    );
  }
}
