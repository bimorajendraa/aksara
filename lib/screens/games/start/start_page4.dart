import 'package:flutter/material.dart';
import '../../home/home_screen.dart';
import 'start_page3.dart';

// SERVICES
import 'package:aksara/services/user_loader_service.dart';
import 'package:aksara/services/user_session.dart';
import 'package:aksara/services/level_progress_service.dart';
import 'package:aksara/services/game_progress_service.dart';   // <<< WAJIB

class StartPage4 extends StatefulWidget {
  const StartPage4({super.key});

  @override
  State<StartPage4> createState() => _StartPage4State();
}

class _StartPage4State extends State<StartPage4> {
  int hearts = 5;

  @override
  void initState() {
    super.initState();
    _ensureUserLoaded();
  }

  /// Pastikan idAkun sudah ada sebelum increment level
  Future<void> _ensureUserLoaded() async {
    if (UserSession.instance.idAkun == null) {
      await UserLoaderService.instance.loadUserId();
    }
  }

  /// ============================================================
  /// HANDLE NEXT → UPDATE PROGRESS + LEVEL + REDIRECT HOME
  /// ============================================================
  Future<void> _completeStartFlow() async {
    final idAkun = UserSession.instance.idAkun;

    if (idAkun != null) {
      print("🔵 [StartPage4] Current user id = $idAkun");

      // 1) UPDATE GAME PROGRESS SUPABASE
      print("🟪 [StartPage4] Updating game progress...");
      await GameProgressService.instance.updateAggregatedProgress(
        idAkun: idAkun,
        gameKey: "start_unit_1",       // <<< sesuaikan nama game yang lu mau
        isCorrect: true,
      );

      // 2) GET CURRENT LEVEL
      final current =
          await LevelProgressService.instance.getCurrentLevel(idAkun);

      print("🟦 [StartPage4] current level before up = $current");

      // 3) INCREMENT LEVEL
      final next =
          await LevelProgressService.instance.incrementLevel(idAkun);

      print("🟢 [StartPage4] LEVEL UP → $current → $next");
    } else {
      print("❌ [StartPage4] idAkun still NULL");
    }

    // Redirect ke HomeScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final double effectiveWidth = screenWidth.clamp(320.0, 500.0);
    final double effectiveHeight = screenHeight.clamp(600.0, 900.0);

    final double backSize = (screenWidth * 0.06).clamp(30.0, 38.0);
    final double backIconSize = (backSize * 0.6).clamp(20.0, 24.0);

    final double horizontalMargin = screenWidth * 0.08;

    return Scaffold(
      backgroundColor: const Color(0xff567c8d),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: effectiveHeight * 0.02),

              _buildHealthBar2(screenWidth, screenHeight),

              SizedBox(height: effectiveHeight * 0.02),

              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: horizontalMargin),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: backSize,
                      height: backSize,
                      decoration: const BoxDecoration(
                        color: Color(0xFFB3BDC4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: backIconSize,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: effectiveHeight * 0.10),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: effectiveWidth * 0.06),
                child: Text(
                  "Now unlock unit 1 and let’s practice what you have learned",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: effectiveWidth * 0.075,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: effectiveHeight * 0.06),

              SizedBox(
                height: effectiveHeight * 0.25,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Image.asset(
                    "assets/images/monster_oren_kanan.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              SizedBox(height: effectiveHeight * 0.07),

              /// ============================
              /// NEXT BUTTON — UPDATE + NEXT
              /// ============================
              GestureDetector(
                onTap: _completeStartFlow,
                child: Container(
                  margin: EdgeInsets.only(bottom: effectiveHeight * 0.03),
                  width: effectiveWidth * 0.23,
                  height: effectiveWidth * 0.23,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward,
                      size: effectiveWidth * 0.15,
                      color: const Color(0xFF607D8B),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthBar2(double w, double h) {
    return Container(
      margin: EdgeInsets.only(
        top: h * 0.05,
        left: w * 0.08,
        right: w * 0.08,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 186, 216, 255),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(5, (index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.01),
                child: Icon(
                  index < hearts ? Icons.favorite : Icons.favorite_border_rounded,
                  color: const Color.fromRGBO(212, 0, 0, 1),
                  size: 26,
                ),
              );
            }),
          ),

          Row(
            children: [
              Image.asset(
                'assets/images/mingcute_coin-2-fill.png',
                width: 26,
                height: 26,
              ),
              const SizedBox(width: 5),
              const Text(
                "13",
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
