import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:aksara/utils/navbar_utils.dart';
import 'package:aksara/widgets/custom_floating_navbar.dart';

import 'package:aksara/screens/games/drag-drop/drag_drop_page.dart';
import 'package:aksara/screens/games/spellbee/spellbee.dart';

// SERVICES
import 'package:aksara/services/user_loader_service.dart';
import 'package:aksara/services/user_session.dart';
import 'package:aksara/services/level_progress_service.dart';


/// ===========================================================================
/// ENUM STATUS NODE
/// ===========================================================================
enum NodeState { completed, current, locked }

/// ===========================================================================
/// MODEL SATU NODE DI MAP
/// ===========================================================================
class MapNode {
  final double xFactor;
  final double yOffset;
  final NodeState state;

  MapNode({
    required this.xFactor,
    required this.yOffset,
    required this.state,
  });

  static const double outerWidth = 85.78;
  static const double outerHeight = 92.0;
  static const double innerSize = 75.84;
  static const double iconSize = 47.0;
}

/// ===========================================================================
/// DOT BACKGROUND
/// ===========================================================================
class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(255, 47, 65, 86).withOpacity(0.25)
      ..style = PaintingStyle.fill;

    const double dotSize = 4;
    const double spacingX = 55.0;
    const double spacingY = 55.0;

    for (double y = spacingY / 2; y < size.height; y += spacingY) {
      for (double x = spacingX / 2; x < size.width; x += spacingX) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ===========================================================================
/// FLOW CONNECTOR
/// ===========================================================================
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
    final svgAsset = "assets/icons/$direction.svg";

    final color = isCompleted
        ? const Color(0xFF98DAF5)
        : const Color(0xFF5C7590);

    double extraDrop = 0;
    if (direction == "bawah-kiri" || direction == "bawah-kanan") {
      extraDrop = 28;
    }

    final left = (direction == "kiri-bawah" || direction == "bawah-kiri")
        ? end.dx
        : start.dx;

    final top = start.dy + MapNode.outerHeight / 2 + extraDrop;
    final width = (end.dx - start.dx).abs();
    final height = end.dy - start.dy - MapNode.outerHeight / 2;

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

/// ===========================================================================
/// NODE WIDGET
/// ===========================================================================
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
          width: MapNode.iconSize,
          height: MapNode.iconSize,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        );
        break;

      case NodeState.current:
        outerBg = const Color(0xFF9DB3C7);
        innerBg = const Color(0xFFCFDDE9);
        icon = SvgPicture.asset(
          "assets/icons/book.svg",
          width: MapNode.iconSize,
          height: MapNode.iconSize,
          colorFilter: const ColorFilter.mode(Color(0xFF3D4F5F), BlendMode.srcIn),
        );
        break;

      default:
        outerBg = const Color(0xFF637F9F);
        innerBg = const Color(0xFF2F4156);
        icon = Icon(Icons.lock, color: const Color(0xFF7D8FA3), size: MapNode.iconSize);
        break;
    }

    return Container(
      width: MapNode.outerWidth,
      height: MapNode.outerHeight,
      decoration: BoxDecoration(
        color: outerBg,
        borderRadius: BorderRadius.circular(MapNode.outerWidth * 0.25),
      ),
      child: Center(
        child: Container(
          width: MapNode.innerSize,
          height: MapNode.innerSize,
          decoration: BoxDecoration(
            color: innerBg,
            borderRadius: BorderRadius.circular(MapNode.innerSize * 0.18),
          ),
          child: Center(child: icon),
        ),
      ),
    );
  }
}

/// ===========================================================================
/// HOMESCREEN FINAL WITH NEW PROGRESS SYSTEM
/// ===========================================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int currentLevel = 1;

  @override
  void initState() {
    super.initState();
    initializeUserAndLoadProgress();
  }

  /// ============================================================
  /// LOAD USER SESSION FIRST (GUARANTEED)
  /// ============================================================
  Future<void> initializeUserAndLoadProgress() async {
    // make sure idAkun exists
    if (UserSession.instance.idAkun == null) {
      print("🔵 [Home] idAkun NULL → loading…");
      await UserLoaderService.instance.loadUserId();
    }

    await loadProgress();
  }

  /// ============================================================
  /// LOAD CURRENT LEVEL USING NEW SERVICE
  /// ============================================================
  Future<void> loadProgress() async {
    final idAkun = UserSession.instance.idAkun;

    if (idAkun == null) {
      print("❌ [Home] Cannot load progress → idAkun null");
      return;
    }

    currentLevel = await LevelProgressService.instance.getCurrentLevel(idAkun);

    print("🟢 [Home] currentLevel = $currentLevel");

    setState(() {});
  }

  /// ============================================================
  /// BUILD NODE STATES BASED ON currentLevel
  /// ============================================================
  List<MapNode> _buildNodes() {
    const spacing = 120.0;
    List<MapNode> list = [];

    for (int i = 1; i <= 9; i++) {
      NodeState state;

      if (i < currentLevel) {
        state = NodeState.completed;
      } else if (i == currentLevel) {
        state = NodeState.current;
      } else {
        state = NodeState.locked;
      }

      double xFactor;
      int idx = i - 1;

      if (idx % 2 == 0) {
        xFactor = 0.5;
      } else if (idx % 4 == 1) {
        xFactor = 0.85;
      } else {
        xFactor = 0.15;
      }

      list.add(MapNode(
        xFactor: xFactor,
        yOffset: spacing * idx,
        state: state,
      ));
    }

    return list;
  }

  
  /// ============================================================
  /// BUILD UI
  /// ============================================================
  @override
  Widget build(BuildContext context) {
    final nodes = _buildNodes();
    final screenWidth = MediaQuery.of(context).size.width;

    final offsets =
        nodes.map((n) => Offset(n.xFactor * screenWidth * 0.9, n.yOffset)).toList();

    final mapHeight = nodes.last.yOffset + 200;

    return Scaffold(
      backgroundColor: const Color(0xFF476280),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [

          Positioned.fill(child: Container(color: const Color(0xFF476280))),

          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: SafeArea(
                child: Column(
                  children: [

                    // HEADER (COIN + HEART)
                    _header(),

                    const SizedBox(height: 16),

                    // MAP AREA
                    SizedBox(
                      width: screenWidth * 0.9,
                      height: mapHeight,
                      child: Stack(
                        children: [

                          Positioned.fill(
                            child: CustomPaint(painter: DotPatternPainter()),
                          ),

                          // CONNECTORS
                          ...List.generate(nodes.length - 1, (i) {
                            final isCompleted =
                                nodes[i].state == NodeState.completed;

                            final direction = [
                              "kanan-bawah",
                              "bawah-kiri",
                              "kiri-bawah",
                              "bawah-kanan"
                            ][i % 4];

                            return FlowConnector(
                              start: offsets[i],
                              end: offsets[i + 1],
                              isCompleted: isCompleted,
                              direction: direction,
                            );
                          }),

                          // NODES
                          ...List.generate(nodes.length, (i) {
                            return Positioned(
                              left: offsets[i].dx - MapNode.outerWidth / 2,
                              top: offsets[i].dy,
                              child: GestureDetector(
                                onTap: () {
                                  if (nodes[i].state == NodeState.locked) return;

                                  final level = i + 1;

                                  if (level == 1) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const DragDropPage()),
                                    );
                                  } else if (level == 2) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const DragDropPage()),
                                    );
                                  } else if (level == 3) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const SpellBeePage()),
                                    );
                                  }
                                },
                                child: MapNodeWidget(state: nodes[i].state),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    // NEXT LEVEL CARD
                    const NextLevelCard(
                      levelNumber: 2,
                      monsterAsset: "assets/images/monster2.png",
                    ),
                  ],
                ),
              ),
            ),
          ),

          // NAVBAR
          Positioned(
            bottom: 30,
            child: CustomFloatingNavBar(
              currentIndex: 0,
              onTap: (i) => NavigationUtils.handleNavigation(context, i, 0),
              onScanTap: () {},
            ),
          )
        ],
      ),
    );
  }

  /// HEADER UI (TIDAK DIUBAH)
  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFC8D9E6),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: List.generate(
                5,
                (i) => Padding(
                  padding: EdgeInsets.only(right: i < 4 ? 6 : 0),
                  child: SvgPicture.asset(
                    "assets/images/heart.svg",
                    width: 22,
                    height: 22,
                  ),
                ),
              ),
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
            )
          ],
        ),
      ),
    );
  }
}

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
      margin: const EdgeInsets.fromLTRB(20, 40, 20, 30),
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
                    child: const Icon(Icons.arrow_forward_rounded,
                        color: Color(0xFF476280)),
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

