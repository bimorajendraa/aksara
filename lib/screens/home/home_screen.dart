import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:aksara/utils/navbar_utils.dart';
import 'package:aksara/widgets/custom_floating_navbar.dart';

// GAMES
import 'package:aksara/screens/games/drag-drop/drag_drop_page.dart';
import 'package:aksara/screens/games/spellbee/spellbee.dart';
import 'package:aksara/screens/games/spellbee/spellbee2.dart';
import 'package:aksara/screens/games/start/start_page.dart';
import 'package:aksara/screens/games/writing/writing_practice_screen.dart';
import 'package:aksara/screens/games/monsterColorDragDrop/monster_color_drag_drop_page.dart';

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
/// FLOW CONNECTOR — ORIGINAL, NO CHANGE
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
          color: Color.fromARGB(255, 255, 255, 255)

    
        );
        break;

      case NodeState.current:
        outer = const Color(0xFF9DB3C7);
        inner = const Color(0xFFCFDDE9);
        icon = SvgPicture.asset(
          "assets/icons/book.svg",
          width: MapNode.iconSize,
          color: Color.fromARGB(255, 255, 255, 255)
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
  /// NEXT LEVEL CARD — FIGMA ACCURATE
  /// ===========================================================================
  class NextLevelCard extends StatelessWidget {
    final int levelNumber;

    const NextLevelCard({
      super.key,
      required this.levelNumber,
    });

    @override
    Widget build(BuildContext context) {
      final monsterPath = "assets/images/monster$levelNumber.png";

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 99, 127, 159), // FIGMA OUTER DARK
          borderRadius: BorderRadius.circular(26),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 47, 65, 86), // FIGMA INNER BLUE-GREY
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              // LEFT CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Level $levelNumber",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color.fromRGBO(99, 127, 159, 1),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "What is number? how we spell it? how to write it?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(99, 127, 159, 1), // LIGHT BLUE-GREY FIGMA
                      ),
                    ),
                    const SizedBox(height: 16),

                    // LITTLE CIRCLE ARROW
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(99, 127, 159, 1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color.fromARGB(255, 47, 65, 86),
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // MONSTER IMAGE
              Image.asset(
                monsterPath,
                width: 80,
                height: 80,
                errorBuilder: (_, __, ___) {
                  return Image.asset(
                    "assets/images/monster1.png",
                    width: 80,
                    height: 80,
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
  }


/// ===========================================================================
/// FULL HEADER
/// ===========================================================================
Widget fullHeader(int currentLevel) {
  return Container(
    margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF6B85A1),
      borderRadius: BorderRadius.circular(30),
    ),

    child: Column(
      children: [
        // HEALTH BAR
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFDCE9F3),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(5, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(Icons.favorite,
                        color: const Color(0xFFFF5A5A), size: 26),
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
                    child: const Icon(Icons.attach_money,
                        size: 20, color: Colors.black),
                  ),
                  const SizedBox(width: 6),
                  const Text("13",
                      style: TextStyle(
                          fontSize: 19, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // LEVEL CARD
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFD3E1EF),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Image.asset("assets/images/monster1.png",
                  width: 80, height: 80),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Level $currentLevel",
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87)),
                    const SizedBox(height: 3),
                    const Text("Get to know letters",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
      ],
    ),
  );
}


/// ===========================================================================
/// HOME SCREEN — FINAL
/// ===========================================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentLevel = 1;
  bool loading = true;

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

    print("🟢 idAkun = ${UserSession.instance.idAkun}");

    await loadProgress();

    loading = false;
    setState(() {});
  }

  Future<void> loadProgress() async {
    final id = UserSession.instance.idAkun;
    if (id == null) {
      print("❌ idAkun NULL");
      return;
    }

    print("🟦 Mengambil current level…");

    currentLevel = await LevelProgressService.instance.getCurrentLevel(id);

    print("🔥 CURRENT LEVEL = $currentLevel");
  }

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

  void openLevel(int index) {
    print("🟪 openLevel → $index");

    switch (index) {
      case 1:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const StartPage()));
        return;

      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const DragDropPage()));
        return;

      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SpellBeePage()));
        return;

      case 4:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SpellBeePage2()));
        return;

      case 5:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const MonsterColorMatchPage()));

      case 6:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const DragDropPage()));
        return;

      case 7:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SpellBeePage()));
        return;

      case 8:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SpellBeePage2()));
        return;

      case 9:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const WritingPracticeScreen()));
        return;

      default:
        print("⚠️ No game assigned to level $index");
    }
  }

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
          Positioned.fill(
            child: Container(color: const Color(0xFF476280)),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              children: [
                fullHeader(currentLevel),  // 🔥 HEADER BARU

                const SizedBox(height: 20),

                SizedBox(
                  width: width * 0.9,
                  height: mapHeight,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(painter: DotPatternPainter()),
                      ),

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
                                print("⛔ Level $level terkunci");
                                return;
                              }
                              openLevel(level);
                            },
                            child: MapNodeWidget(
                              state: nodes[i].state,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                NextLevelCard(
                  levelNumber: currentLevel + 1,
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
}
