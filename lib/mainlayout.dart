import 'package:carrentalapp/accountpage.dart';
import 'package:carrentalapp/homepage.dart';
import 'package:carrentalapp/savedpage.dart';
import 'package:flutter/material.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentBottomNavIndex = 0;

  final List<Widget> _pages = [
    const Homepage(),
    const Savedpage(),
    const Accountpage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentBottomNavIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), // Fully opaque dark color // Dark background to match your theme
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, "Home", 0),
              _buildNavItem(Icons.bookmark_outlined, "Saved", 1),
              _buildNavItem(Icons.person_outline, "Profile", 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _currentBottomNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentBottomNavIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.cyanAccent : Colors.grey, // Using your theme's secondary color
            size: isSelected ? 28 : 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.cyanAccent : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}