import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:aksara/utils/navbar_utils.dart';
import 'package:aksara/widgets/custom_floating_navbar.dart';

// GAMES
import 'package:aksara/screens/games/drag-drop/drag_drop_page.dart';
import 'package:aksara/screens/games/spellbee/spellbee.dart';
import 'package:aksara/screens/games/start/start_page.dart';

// SERVICES
import 'package:aksara/services/user_loader_service.dart';
import 'package:aksara/services/user_session.dart';
import 'package:aksara/services/level_progress_service.dart';

/// ===========================================================================
/// ENUM
/// ===========================================================================
enum NodeState { completed, current, locked }

/// ===========================================================================
/// MODEL NODE CONFIG
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
      ..color = const Color.fromARGB(255, 47, 65, 86).withOpacity(0.25);

    for (double y = 30; y < size.height; y += 55) {
      for (double x = 30; x < size.width; x += 55) {
        canvas.drawCircle(Offset(x, y), 4, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ===========================================================================
/// FLOW CONNECTOR — ORIGINAL, TIDAK DIUBAH
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
    final svgAsset = 'assets/icons/$direction.svg';

    final color =
        isCompleted ? const Color(0xFF98DAF5) : const Color(0xFF5C7590);

    double extraDrop = 0;

    if (direction == 'bawah-kiri' || direction == 'bawah-kanan') {
      extraDrop = 28;
    }

    final left = (direction == 'kiri-bawah' || direction == 'bawah-kiri')
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
/// NODE VISUAL
/// ===========================================================================
class MapNodeWidget extends StatelessWidget {
  final NodeState state;

  const MapNodeWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    Color outer;
    Color inner;
    Widget icon;

    switch (state) {
      case NodeState.completed:
        outer = const Color(0xFF5BA8C8);
        inner = const Color(0xFF8ED4F5);
        icon = SvgPicture.asset(
          "assets/icons/book-open.svg",
          width: MapNode.iconSize,
        );
        break;

      case NodeState.current:
        outer = const Color(0xFF9DB3C7);
        inner = const Color(0xFFCFDDE9);
        icon = SvgPicture.asset(
          "assets/icons/book.svg",
          width: MapNode.iconSize,
        );
        break;

      default:
        outer = const Color(0xFF637F9F);
        inner = const Color(0xFF2F4156);
        icon = const Icon(Icons.lock, color: Colors.white, size: 32);
    }

    return Container(
      width: MapNode.outerWidth,
      height: MapNode.outerHeight,
      decoration: BoxDecoration(
        color: outer,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Center(
        child: Container(
          width: MapNode.innerSize,
          height: MapNode.innerSize,
          decoration: BoxDecoration(
            color: inner,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(child: icon),
        ),
      ),
    );
  }
}

/// ===========================================================================
/// NEXT LEVEL CARD
/// ===========================================================================
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
                ],
              ),
            ),
            Image.asset(monsterAsset, width: 80, height: 80),
          ],
        ),
      ),
    );
  }
}

/// ===========================================================================
/// HOME SCREEN — FULL FIX
/// ===========================================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentLevel = 1;
  bool loading = true;     // <— penting! biar UI ga render sebelum data siap

  @override
  void initState() {
    super.initState();
    initFlow();
  }

  Future<void> initFlow() async {
    print("🟦 [HomeScreen] initFlow() mulai…");

    if (UserSession.instance.idAkun == null) {
      print("⚠️ idAkun null → mencoba loadUserId…");
      await UserLoaderService.instance.loadUserId();
    }

    print("🟢 idAkun sekarang = ${UserSession.instance.idAkun}");

    await loadProgress();

    loading = false;
    setState(() {});
  }

  Future<void> loadProgress() async {
    final id = UserSession.instance.idAkun;
    if (id == null) {
      print("❌ [HomeScreen] loadProgress gagal → idAkun NULL");
      return;
    }

    print("🟦 Ambil current level dari database…");

    currentLevel = await LevelProgressService.instance.getCurrentLevel(id);

    print("🔥 [HomeScreen] CURRENT LEVEL = $currentLevel");
  }

  /// =======================================================================
  /// BUILD NODES dynamically based on currentLevel
  /// =======================================================================
  List<MapNode> _buildNodes() {
    const spacing = 120.0;

    return List.generate(9, (i) {
      final level = i + 1;

      NodeState state;
      if (level < currentLevel) {
        state = NodeState.completed;
      } else if (level == currentLevel) {
        state = NodeState.current;
      } else {
        state = NodeState.locked;
      }

      double xFactor;
      if (i % 2 == 0) xFactor = 0.50;
      else if (i % 4 == 1) xFactor = 0.85;
      else xFactor = 0.15;

      return MapNode(
        xFactor: xFactor,
        yOffset: spacing * i,
        state: state,
      );
    });
  }

  /// =======================================================================
  /// OPEN GAME BASED ON LEVEL INDEX
  /// =======================================================================
  void openLevel(int levelIndex) {
    print("🟦 [HomeScreen] openLevel($levelIndex)");

    switch (levelIndex) {
      case 1:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const DragDropPage()));
        return;

      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const DragDropPage()));
        return;

      case 3:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SpellBeePage()));
        return;

      default:
        print("⚠️ Level $levelIndex belum ada gamenya");
    }
  }

  /// =======================================================================
  /// BUILD UI
  /// =======================================================================
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: const Color(0xFF476280),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final nodes = _buildNodes();

    final offsets =
        nodes.map((n) => Offset(n.xFactor * width * 0.9, n.yOffset)).toList();

    final mapHeight = nodes.last.yOffset + 200;

    return Scaffold(
      backgroundColor: const Color(0xFF476280),
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: const Color(0xFF476280))),

          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _header(),
                const SizedBox(height: 20),

                SizedBox(
                  width: width * 0.9,
                  height: mapHeight,
                  child: Stack(
                    children: [
                      Positioned.fill(child: CustomPaint(painter: DotPatternPainter())),

                      // CONNECTORS
                      ...List.generate(nodes.length - 1, (i) {
                        final direction = [
                          "kanan-bawah",
                          "bawah-kiri",
                          "kiri-bawah",
                          "bawah-kanan"
                        ][i % 4];

                        return FlowConnector(
                          start: offsets[i],
                          end: offsets[i + 1],
                          isCompleted: (i + 1) < currentLevel,
                          direction: direction,
                        );
                      }),

                      // NODES
                      ...List.generate(nodes.length, (i) {
                        final level = i + 1;

                        return Positioned(
                          left: offsets[i].dx - MapNode.outerWidth / 2,
                          top: offsets[i].dy,
                          child: GestureDetector(
                            onTap: () {
                              if (nodes[i].state == NodeState.locked) {
                                print("⛔ LEVEL $level dikunci");
                                return;
                              }
                              openLevel(level);
                            },
                            child: MapNodeWidget(state: nodes[i].state),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                NextLevelCard(
                  levelNumber: currentLevel + 1,
                  monsterAsset: "assets/images/monster2.png",
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: CustomFloatingNavBar(
              currentIndex: 0,
              onTap: (i) => NavigationUtils.handleNavigation(context, i, 0),
              onScanTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  /// =======================================================================
  /// HEADER
  /// =======================================================================
  Widget _header() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6B85A1),
        borderRadius: BorderRadius.circular(30),
      ),

      child: Column(
        children: [
          // HEALTH BAR RECTANGLE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFDCE9F3),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // hearts
                Row(
                  children: List.generate(5, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.favorite,
                        color: i < 5 ? const Color(0xFFE25A5A) : const Color(0xFFE5B2B2),
                        size: 26,
                      ),
                    );
                  }),
                ),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1A6),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(Icons.attach_money, size: 20, color: Colors.black),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "13",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // LEVEL CARD RECTANGLE
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFD3E1EF),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                Image.asset("assets/images/monster1.png", width: 80, height: 80),

                const SizedBox(width: 14),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Level 1",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        "Get to know letters",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}