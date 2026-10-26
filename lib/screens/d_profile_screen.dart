import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MY PROFILE'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 20),
          const Center(
            child: CircleAvatar(
              radius: 42,
              backgroundColor: Color(0xFFDDEAE3),
              child: Icon(
                Icons.person,
                size: 45,
                color: Color(0xFF2D7770),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Traveler',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF183B3A),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'YOUR JOURNEY, YOUR STORY',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 1.5,
                color: Color(0xFF78908A),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.luggage_outlined),
                  title: const Text('나의 여행'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pop(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('여행 기록'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('여행 기록 기능입니다.')),
                );
               },
              ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('설정'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => AlertDialog(
                      title: const Text('설정'),
                      content: const Text('Polarsteps v2 설정 페이지입니다.'),
                      actions: [
                        TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('닫기'),
                        ),
                       ],
                       ),
                      );
                      },
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
