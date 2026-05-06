import 'package:flutter/material.dart';

import 'screens/parent_screen.dart';

void main() {
  runApp(const CartyApp());
}

class CartyApp extends StatelessWidget {
  const CartyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carty',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const ParentScreen(),
    );
  }
}
