import 'package:aksara/screens/writing_practice_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/navbar_utils.dart';
import '../../widgets/custom_floating_navbar.dart';
import '../games/start/start_page.dart';

/// Status node di map.
/// - completed  : sudah selesai
/// - current    : level/progress yang lagi aktif
/// - locked     : level yang belum kebuka
enum NodeState { completed, current, locked }

/// Representasi 1 titik node di map (satu kotak buku / lock)
class MapNode {
  /// Posisi horizontal relatif lebar container map
  /// 0.0 = paling kiri, 0.5 = tengah, 1.0 = paling kanan
  final double xFactor;

  /// Posisi vertikal dalam pixel dari atas container map
  final double yOffset;

  /// Status node (completed / current / locked)
  final NodeState state;

  MapNode({
    required this.xFactor,
    required this.yOffset,
    required this.state,
  });

  /// Ukuran kotak node (width & height)
  /// Kalau mau node lebih besar/kecil, ubah di sini.
  // Explicit sizes requested by the user:
  // - outer/background box: width x height = 85.78 x 92
  // - inner/foreground box: square 75.84 x 75.84
  // - icon size: 47 x 47
  static const double outerWidth = 85.78;
  static const double outerHeight = 92.0;
  static const double innerSize = 75.84;
  static const double iconSize = 47.0;
}

/// ===========================================================
/// DOT PATTERN BACKGROUND DI AREA MAP
/// ===========================================================
/// Ini yang bikin titik-titik kecil di belakang path.
/// Mirip banget sama desain Figma, bisa di-tune dari:
///   - dotSize   : besar titik
///   - spacingX  : jarak antar titik horizontal
///   - spacingY  : jarak antar titik vertikal
class DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      // Warna dot (disesuaikan dengan figma)
      ..color = const Color.fromARGB(0, 47, 65, 86).withOpacity(0.85)
      ..style = PaintingStyle.fill;

    const double dotSize = 4;      // diameter dot, makin besar makin kelihatan
    const double spacingX = 55.0;  // jarak antar dot horizontal
    const double spacingY = 55.0;  // jarak antar dot vertikal

    // Loop row (y) dan column (x) untuk gambar dot di seluruh area
    for (double y = spacingY / 2; y < size.height; y += spacingY) {
      for (double x = spacingX / 2; x < size.width; x += spacingX) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ===========================================================
/// FLOW CONNECTOR (PATH YANG MELENGKUNG ANTAR NODE)
/// ===========================================================
/// Ini bukan digambar manual, tapi pakai SVG siap pakai:
///   - assets/icons/kanan-bawah.svg
///   - assets/icons/bawah-kiri.svg
///   - assets/icons/kiri-bawah.svg
///   - assets/icons/bawah-kanan.svg
///
/// Komponen ini cuma:
///   - nentuin warna (completed vs locked)
///   - nentuin posisi dan ukuran rect tempat SVG itu ditempel
class FlowConnector extends StatelessWidget {
  /// Titik awal path (titik tengah bawah node awal)
  final Offset start;

  /// Titik akhir path (titik tengah atas node tujuan)
  final Offset end;

  /// True kalau path ini sudah lewat (levelnya sudah completed)
  final bool isCompleted;

  /// Nama arah SVG yang dipakai
  /// 'kanan-bawah', 'bawah-kiri', 'kiri-bawah', 'bawah-kanan'
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
    // Pilih file SVG sesuai direction
    final svgAsset = 'assets/icons/$direction.svg';

    // Warna path:
    // - biru terang kalau level di atasnya sudah completed
    // - abu gelap kalau masih locked
    final color = isCompleted
        ? const Color(0xFF98DAF5)
        : const Color(0xFF5C7590);

    // Tambahan drop khusus yang GENAP (bawah-belok)
    // tujuannya biar path yang "turun dulu baru belok"
    // nggak nempel ke node, agak turun sedikit.
    double extraDrop = 0;

    // Flow yang "bawah-..." (turun dulu baru belok)
    if (direction == 'bawah-kiri' || direction == 'bawah-kanan') {
      extraDrop = 28; // kalau mau path turun lebih jauh, gedein angka ini
    }

    // Untuk kiri-bawah & bawah-kiri, rect-nya dihitung dari end (biar arah benar)
    // selain itu dihitung dari start
    final left = (direction == 'kiri-bawah' || direction == 'bawah-kiri')
        ? end.dx
        : start.dx;

    // Rect di-anchorkan di bawah node awal + extraDrop
    final top = start.dy + MapNode.outerHeight / 2 + extraDrop;

    // Lebar rect = selisih horizontal antara start & end
    final width = (end.dx - start.dx).abs();

    // Tinggi rect = jarak vertikal antara node, minus setengah node pertama
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

/// ==========================
/// =================================
/// NODE WIDGET (KOTAK BUKU / LOCK)
/// ===========================================================
/// Semua style node diatur di sini:
///   - warna border / isi
///   - icon yang dipakai
/// Kalau mau ganti warna tema / bentuk node, cukup ubah class ini.
class MapNodeWidget extends StatelessWidget {
  final NodeState state;

  const MapNodeWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    Color outerBg;
    Color innerBg;
    Widget icon;
    // Use explicit sizes provided in MapNode.
    final double outerWidth = MapNode.outerWidth;
    final double outerHeight = MapNode.outerHeight;
    final double innerSize = MapNode.innerSize;
    final double iconSize = MapNode.iconSize;
    final double outerRadius = outerWidth * 0.25;
    final double innerRadius = innerSize * 0.18;

    switch (state) {
      case NodeState.completed:
        // Node yang sudah completed (biru terang)
        outerBg = const Color(0xFF5BA8C8);
        innerBg = const Color(0xFF8ED4F5);
        icon = SvgPicture.asset(
          "assets/icons/book-open.svg",
          width: iconSize,
          height: iconSize,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        );
        break;

      case NodeState.current:
        // Node aktif (abu terang, icon buku biru gelap)
        outerBg = const Color(0xFF9DB3C7);
        innerBg = const Color(0xFFCFDDE9);
        icon = SvgPicture.asset(
          "assets/icons/book.svg",
          width: iconSize,
          height: iconSize,
          colorFilter: const ColorFilter.mode(
            Color(0xFF3D4F5F),
            BlendMode.srcIn,
          ),
        );
        break;

      case NodeState.locked:
        // Node terkunci (abu gelap + ikon gembok)
        outerBg = const Color(0xFF637F9F);
        innerBg = const Color(0xFF2F4156);
        icon = Icon(
          Icons.lock,
          color: const Color(0xFF7D8FA3),
          size: iconSize,
        );
        break;
    }

    return Container(
      width: outerWidth,
      height: outerHeight,
      decoration: BoxDecoration(
        color: outerBg,
        borderRadius: BorderRadius.circular(outerRadius),
      ),
      child: Center(
        child: Container(
          width: innerSize,
          height: innerSize,
          decoration: BoxDecoration(
            color: innerBg,
            borderRadius: BorderRadius.circular(innerRadius),
          ),
          child: Center(child: icon),
        ),
      ),
    );
  }
}

/// ===========================================================
/// CARD NEXT LEVEL DI PALING BAWAH
/// ===========================================================
/// Ini yang "Level 2 - What is number?" bla bla.
/// Kalau nanti text / monster per level beda, tinggal
/// ganti param levelNumber & monsterAsset
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
      // Margin atas 40 biar ada jarak dari node terakhir
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
            // Bagian teks kiri (Level 2 & deskripsi)
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
                  // Tombol bulat panah ke kanan
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
            // Monster di kanan
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
/// BOTTOM NAVBAR
/// ===========================================================
/// Ini nav bar bawah yang ada home / book / medal / user.
/// Hanya layout static, belum ada onTap atau route logic.
/// Kalau mau aktif tab lain, tinggal ganti warna icon di sini.


/// ===========================================================
/// HOME SCREEN — PAGE UTAMA STORY MODE
/// ===========================================================
/// Bagian penting yang bisa lu utak-atik:
///   - _buildNodes() : pola posisi node & statusnya
///   - spacing       : jarak vertikal antar node
///   - xFactor       : posisi kiri/kanan node
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<MapNode> _buildNodes() {
    const spacing = 120.0;
    return [
      MapNode(xFactor: 0.50, yOffset: 0, state: NodeState.completed),
      MapNode(xFactor: 0.85, yOffset: spacing, state: NodeState.completed),
      MapNode(xFactor: 0.50, yOffset: spacing * 2, state: NodeState.current),
      MapNode(xFactor: 0.15, yOffset: spacing * 3, state: NodeState.locked),
      MapNode(xFactor: 0.50, yOffset: spacing * 4, state: NodeState.locked),
      MapNode(xFactor: 0.85, yOffset: spacing * 5, state: NodeState.locked),
      MapNode(xFactor: 0.50, yOffset: spacing * 6, state: NodeState.locked),
      MapNode(xFactor: 0.15, yOffset: spacing * 7, state: NodeState.locked),
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
      backgroundColor: const Color(0xFF476280),
      body: Stack(
        alignment: Alignment.bottomCenter, // Pastikan Navbar di bawah
        children: [
          // 1. Background
          Positioned.fill(
            child: Container(
              color: const Color(0xFF476280),
            ),
          ),

          // 2. Konten Utama (Scrollable)
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120), // Padding bawah agar tidak tertutup navbar
              physics: const BouncingScrollPhysics(),
              child: SafeArea(
                child: Column(
                  children: [
                    // --- Header (Heart & Coin) ---
                    Padding(
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
                              children: List.generate(5, (i) {
                                return Padding(
                                  padding: EdgeInsets.only(right: i < 4 ? 6 : 0),
                                  child: SvgPicture.asset(
                                    "assets/images/heart.svg",
                                    width: 22, height: 22,
                                  ),
                                );
                              }),
                            ),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  "assets/images/coin.svg",
                                  width: 24, height: 24,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  "13",
                                  style: TextStyle(
                                    color: Color(0xFF0E0F1A),
                                    fontSize: 18, fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // --- Card Level 1 ---
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
                              width: 64, height: 64, fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Level 1",
                                    style: TextStyle(
                                      fontSize: 24, fontWeight: FontWeight.w700,
                                      color: Color(0xFF0E0F1A),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Get to know letters",
                                    style: TextStyle(
                                      fontSize: 13, color: Color(0xFF5C7590),
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

                    // --- Area Map (Canvas & Nodes) ---
                    Center(
                      child: SizedBox(
                        width: screenWidth * 0.9,
                        height: mapHeight,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(painter: DotPatternPainter()),
                            ),
                            // Flow Connector
                            ...List.generate(nodes.length - 1, (i) {
                              final isCompleted = i < effectiveCurrentIndex;
                              String direction;
                              switch (i % 4) {
                                case 0: direction = 'kanan-bawah'; break;
                                case 1: direction = 'bawah-kiri'; break;
                                case 2: direction = 'kiri-bawah'; break;
                                default: direction = 'bawah-kanan';
                              }
                              final startOffset = Offset(
                                nodes[i].xFactor * screenWidth * 0.9,
                                offsets[i].dy,
                              );
                              final endOffset = Offset(
                                nodes[i + 1].xFactor * screenWidth * 0.9,
                                offsets[i + 1].dy,
                              );
                              return FlowConnector(
                                start: startOffset,
                                end: endOffset,
                                isCompleted: isCompleted,
                                direction: direction,
                              );
                            }),
                            // Nodes
                            ...List.generate(nodes.length, (i) {
                              final nodeX = nodes[i].xFactor * screenWidth * 0.9;
                              return Positioned(
                                left: nodeX - MapNode.outerWidth / 2,
                                top: offsets[i].dy,
                                child: GestureDetector(
                                onTap: () {
                                  if (i == 1) { // change index to whichever node should open the writing screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const WritingPracticeScreen()),
                                    );
                                  } else if (i == 0) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const StartPage()),
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
                    ),

                    // --- Next Level Card ---
                    const NextLevelCard(
                      levelNumber: 2,
                      monsterAsset: "assets/images/monster2.png",
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Navbar Melayang (Paling Atas)
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: CustomFloatingNavBar(
              currentIndex: 0, // Set 0 karena ini Home
              onTap: (index) {
                NavigationUtils.handleNavigation(context, index, 0);
              }, // Sambungkan Fungsi Navigasi
              onScanTap: () => print("Scan Clicked"),
            ),
          ),
        ],
      ),
    );
  }
}