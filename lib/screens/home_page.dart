import 'package:flutter/material.dart';
import 'compass_screen.dart';
import 'level_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [CompassScreen(), LevelScreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Compass'),
          BottomNavigationBarItem(
            icon: Icon(Icons.square_foot),
            label: 'Level',
          ),
        ],
      ),
      floatingActionButton: null, // Removed temporary demo button
    );
  }
}
