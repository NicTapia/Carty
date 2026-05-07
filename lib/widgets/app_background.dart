import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/app_background.png', fit: BoxFit.cover),
        ColoredBox(color: const Color(0xFFFFF9ED).withValues(alpha: 0.24)),
        child,
      ],
    );
  }
}
