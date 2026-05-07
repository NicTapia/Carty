import 'package:flutter/material.dart';

import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _startApp(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/background.png', fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  const Color(0xFFFFF7E8).withValues(alpha: 0.48),
                ],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.sizeOf(context).width;
                final logoMaxHeight = constraints.maxHeight * 0.46;
                final buttonWidth = screenWidth * 0.74;

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Column(
                    children: [
                      const Spacer(),
                      Flexible(
                        flex: 5,
                        child: Image.asset(
                          'assets/images/carty_panda.png',
                          width: 280,
                          height: logoMaxHeight.clamp(160.0, 300.0),
                          fit: BoxFit.contain,
                        ),
                      ),
                      const Spacer(flex: 2),
                      Center(
                        child: GestureDetector(
                          onTap: () => _startApp(context),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: buttonWidth,
                              maxHeight: 140,
                            ),
                            child: Image.asset(
                              'assets/images/carty_panda_button.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return SizedBox(
                                  width: buttonWidth,
                                  height: 58,
                                  child: FilledButton(
                                    onPressed: () => _startApp(context),
                                    child: const Text(
                                      'Comenzar',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
