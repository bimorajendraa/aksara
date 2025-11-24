import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header avatar
              const _ProfileHeaderCard(),

              const SizedBox(height: 20),

              // user info
              const _UserInfoSection(),

              const SizedBox(height: 10),
              const Divider(thickness: 1, color: Colors.grey),
              const SizedBox(height: 10),

              // ACHIEVEMENT
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Achievement",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/profile/achievement');
                    },
                    child: const Text(
                      "See More...",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const _AchievementList(),

              const SizedBox(height: 25),

              // RECENT
              const Text(
                "Recently Read",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 15),
              
              const _RecentlyReadList(),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4CA1AF),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        
        currentIndex: 2, 
        
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context); 
          } else if (index == 1) {
          }
        },
        
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded), 
            label: "Home"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_rounded), 
            label: "Peringkat"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded), 
            label: "Profil"
          ),
        ],
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 130,
                width: 180,
                decoration: const BoxDecoration(
                  color: Color(0xFF66BB6A),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(100),
                    topRight: Radius.circular(100),
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.face_rounded, size: 80, color: Colors.white),
                ),
              ),
            ),
          ),
          Positioned(
            top: 15,
            right: 15,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/profile/editalien');
                  print("Edit start!");
                },
                child: Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(
                   color: Colors.white.withOpacity(0.2),
                   borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
              ),
            )
          ),
        ],
      ),
    );
  }
}

class _UserInfoSection extends StatelessWidget {
  const _UserInfoSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Maulana Sudrajat",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "JFikurikuri@gmail.com",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Joined since 2005",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/profile/settings');
          },
          icon: const Icon(Icons.settings_outlined, size: 28, color: Colors.black54),
        ),
      ],
    );
  }
}

class _AchievementList extends StatelessWidget {
  const _AchievementList();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAchievementItem(
            icon: Icons.help_outline_rounded,
            color: const Color(0xFFFF6B6B),
            title: "Ingin Tahu!",
            subtitle: "Ingin tahu 7 Kali",
            progress: 0.7,
            progressText: "7/10",
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _buildAchievementItem(
            icon: Icons.emoji_events_rounded,
            color: const Color(0xFF4ECDC4),
            title: "Kaya Pengetahuan!",
            subtitle: "Kaya akan pengetahuan 7 Kali",
            progress: 0.7,
            progressText: "7/10",
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _buildAchievementItem(
            icon: Icons.rocket_launch_rounded,
            color: const Color(0xFFFFD93D),
            title: "Progresif!",
            subtitle: "Progresif 7 Kali",
            progress: 0.7,
            progressText: "7/10",
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required double progress,
    required String progressText,
  }) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    progressText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2C3E50)),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentlyReadList extends StatelessWidget {
  const _RecentlyReadList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildBookCard(
            "The Tale of Melon City",
            "7 Pages",
            "Hard",
            "4.9",
            Colors.blue.shade100,
          ),
          const SizedBox(width: 15),
          _buildBookCard(
            "The Tale of..",
            "7 Pages",
            "Hard",
            "4.5",
            Colors.orange.shade100,
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(String title, String pages, String difficulty, String rating, Color bgColor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          print("Buku $title diklik!");
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    image: const DecorationImage(
                      image: NetworkImage('https://via.placeholder.com/150'), 
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2C3E50),
                ),
              ),
              Text(
                "($pages)",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(difficulty, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const Spacer(),
                  const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                  Text(rating, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        )
      )
    );
  }
}