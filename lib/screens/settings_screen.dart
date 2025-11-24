import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _emailNotif = true;
  bool _activitiesNotif = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const _SettingHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Column(
                children: [
                  _buildSwitchTile(
                    icon: Icons.mail_outline_rounded,
                    title: "Email Notification",
                    value: _emailNotif,
                    onChanged: (val) {
                      setState(() => _emailNotif = val);
                    },
                  ),
                  const Divider(),
                  _buildSwitchTile(
                    icon: Icons.bar_chart_rounded,
                    title: "Activities Notification",
                    value: _activitiesNotif,
                    onChanged: (val) {
                      setState(() => _activitiesNotif = val);
                    },
                  ),
                  const Divider(),

                  _buildMenuTile(
                    title: "About Us",
                    icon: Icons.info_outline_rounded,
                    onTap: () {},
                  ),
                  const Divider(),

                  _buildMenuTile(title: "Account", onTap: () {}),
                  const Divider(),

                  _buildMenuTile(title: "Delete Account", onTap: () {}),
                  const Divider(),

                  _buildMenuTile(title: "Help Me", onTap: () {
                    Navigator.pushNamed(context, '/profile/settings/helpme');
                  }),
                  const Divider(),

                  _buildMenuTile(title: "Terms & Condition", onTap: () {}),
                  const Divider(),

                  const SizedBox(height: 20),
                  
                  _buildLogOutTile(),
                  const Divider(),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2C3E50), size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2C3E50),
            activeTrackColor: const Color(0xFF2C3E50).withOpacity(0.4),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required String title,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: const Color(0xFF2C3E50), size: 24),
              const SizedBox(width: 15),
            ],
            
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildLogOutTile() {
    return InkWell(
      onTap: () {
        print("Logout clicked");
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                "Log Out",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.deepOrange),
          ],
        ),
      ),
    );
  }
}

class _SettingHeader extends StatelessWidget {
  const _SettingHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
      decoration: const BoxDecoration(
        color: Color(0xFFD6E6F2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                   Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3E50), size: 22),
              ),
              const SizedBox(width: 10),
              const Text(
                "Setting",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF2C3E50),
                ),
                child: Center(
                  child: Container(
                    width: 50,
                    height: 40,
                     decoration: const BoxDecoration(
                      color: Color(0xFF66BB6A),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    ),
                    child: const Icon(Icons.face, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Maulana Sudrajat",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "JFikurikuri@gmail.com",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF546E7A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}