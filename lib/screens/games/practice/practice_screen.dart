import 'package:aksara/screens/games/hearthesound/hearthesound.dart';
import 'package:flutter/material.dart';
import '../spellbee/spellbee.dart';
import '../spellbee/spellbee2.dart';
import '../games/monster_color_match/monster_color_match_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../widgets/custom_floating_navbar.dart';
import '../../../../utils/navbar_utils.dart';

final supabase = Supabase.instance.client;

class PracticeScreen extends StatelessWidget {
  final String username;
  const PracticeScreen({super.key, required this.username});

  Future<String> getUsernameFromSupabase() async {
    final user = supabase.auth.currentUser;

    if (user == null) return username;

    final response = await supabase
        .from('akun')
        .select('username')
        .eq('email', user.email!)
        .single();

    final fetchedUsername = response['username'] as String?;

    return fetchedUsername ?? username;
  }

  Future<String> fetchUsername() async {
    return await getUsernameFromSupabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffD7E8F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ================= USERNAME FROM SUPABASE =================
              FutureBuilder(
                future: fetchUsername(),
                builder: (context, snapshot) {
                  final name = snapshot.data ?? username;
                  return Text(
                    "Hi, $name!",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff2B4C68),
                    ),
                  );
                },
              ),

              const SizedBox(height: 4),

              const Text(
                "Ready To Learn ?",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 25),

              // ================= STORY MODE =================
              const Text(
                "Story Mode",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff2B4C68),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                height: 280,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    StoryCard(
                      title: "The Man The Tree",
                      pages: "5 Pages",
                      difficulty: "Easy",
                      rating: "4.9",
                      image: "assets/images/the_man_the_tree_cover_preview.png",
                    ),
                    SizedBox(width: 16),
                    StoryCard(
                      title: "Grim Fairy Tales",
                      pages: "8 Pages",
                      difficulty: "Medium",
                      rating: "4.7",
                      image: "assets/images/grim_fairy_tales_cover_preview.png",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ================= PRACTICE SECTION =================
              const Text(
                "Practice Section",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff2B4C68),
                ),
              ),

              const SizedBox(height: 14),

              // ---------------- Hear the Sound ----------------
              PracticeCard(
                title: "Hear the Sound",
                image: "assets/images/hear_the_sound_guy.png",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HearTheSoundPage()),
                  );
                },
              ),
              const SizedBox(height: 12),

              // ---------------- Spell Bee ----------------
              PracticeCard(
                title: "Spell the Bee",
                image: "assets/images/spell_the_bee_guy.png",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SpellBeePage()),
                  );
                },
              ),
              const SizedBox(height: 12),

              // ---------------- Mini Quiz (SpellBee2) ----------------
              PracticeCard(
                title: "Mini Quiz",
                image: "assets/images/mini_quiz_guy.png",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SpellBeePage2()),
                  );
                },
              ),
              const SizedBox(height: 12),

              // ---------------- Monster Color Match — NEW GAME ----------------
              PracticeCard(
                title: "Monster Color Match",
                image: "assets/images/monster_color_match_guy.png",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MonsterColorMatchPage()),
                  );
                },
              ),
              const SizedBox(height: 12),

              // ---------------- Pull the Arrow ----------------
              PracticeCard(
                title: "Pull the Arrow",
                image: "assets/images/pull_the_arrow_guy.png",
                onTap: () {},
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: CustomFloatingNavBar(
          currentIndex: 1,
          onTap: (index) {
            NavigationUtils.handleNavigation(context, index, 1);
          },
          onScanTap: () {
            Navigator.pushNamed(context, '/live-ocr');
          },
        ),
      ),
    );
  }
}

// =================================================================
// STORY CARD WIDGET
// =================================================================
class StoryCard extends StatelessWidget {
  final String title;
  final String pages;
  final String difficulty;
  final String rating;
  final String image;

  const StoryCard({
    super.key,
    required this.title,
    required this.pages,
    required this.difficulty,
    required this.rating,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: const Color(0xff2B4C68),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              pages,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    difficulty,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),

                const Spacer(),

                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: Colors.yellowAccent),
                    Text(
                      rating,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

// =================================================================
// PRACTICE CARD WIDGET
// =================================================================
class PracticeCard extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;

  const PracticeCard({
    super.key,
    required this.title,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        padding: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          color: const Color(0xff425F77),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Image.asset(
              image,
              height: 100,
            )
          ],
        ),
      ),
    );
  }
}
