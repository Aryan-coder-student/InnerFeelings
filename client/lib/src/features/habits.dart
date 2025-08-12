import 'package:flutter/material.dart';

class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.fitness_center, size: 48, color: Color(0xFF667eea)),
          SizedBox(height: 12),
          Text('Habits coming soon', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}