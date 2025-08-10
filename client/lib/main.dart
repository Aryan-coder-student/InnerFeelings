import 'package:flutter/material.dart';

// import 'package:share_plus/share_plus.dart';

// import './src/features/new_entry.dart';
import './src/features/dashboard.dart';
import './src/features/journal.dart';

import './src/features/avatar.dart';
import './src/features/community.dart';

void main() {
  runApp(const InnerFeeling());
}

class InnerFeeling extends StatelessWidget {
  const InnerFeeling({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InnerFeeling',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<String> _pages = [
    'dashboard',
    // 'new_entry',
    'journal',
    'avatar',
    'community'
  ];

  void _showPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF667eea),
      body: Center(
        child: Container(
          width: 375,
          height: 812,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 50,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Stack(
                children: [
                  // Phone body (content + status bar + spacer for bottom nav)
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        // Status Bar
                        Container(
                          height: 44,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'MoodMind',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: _buildPage(_pages[_selectedIndex])),
                        const SizedBox(height: 90), // space for bottom nav
                      ],
                    ),
                  ),

                  // Bottom navigation inside the phone frame
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(top: BorderSide(color: Color(0xFFeeeeee))),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildNavItem(0, '📊', 'Dashboard'),
                          _buildNavItem(1, '📖', 'Journal'),
                          _buildNavItem(2, '🤖', 'Luna'),
                          _buildNavItem(3, '👥', 'Community'),
                        ],
                      ),
                    ),
                  ),

                  // FAB inside the phone frame
                  if (_selectedIndex != 1)
                    Positioned(
                      bottom: 80 - 30, // half-over the bottom bar
                      left: 0,
                      right: 0,
                      child: Center(
                        child: FloatingActionButton(
                          backgroundColor: const Color(0xFF667eea),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const JournalPage()),
                            );
                          },
                          shape: const CircleBorder(),
                          child: const Text(
                            '✏️',
                            style: TextStyle(fontSize: 24, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
       

  Widget _buildNavItem(int index, String icon, String label) {
    return GestureDetector(
      onTap: () => _showPage(index),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _selectedIndex == index
              ? const Color(0x33667eea)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF667eea),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(String pageId) {
    switch (pageId) {
      case 'dashboard':
        return const DashboardPage();
      case 'journal':
        return const JournalPage();
      case 'avatar':
        return const AvatarPage();
      case 'community':
        return const CommunityPage();
      default:
        return const SizedBox();
    }
  }
}