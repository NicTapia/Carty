import 'package:flutter/material.dart';

import '../widgets/app_background.dart';

class SuccessScreen extends StatelessWidget {
  final String reward;

  const SuccessScreen({super.key, required this.reward});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(150),
          child: _buildSuccessHeader(),
        ),
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 46,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHappyPanda(),
                      const SizedBox(height: 20),
                      const Text(
                        '¡Misión completada!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          height: 1.05,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF4F321B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Has encontrado todos los productos',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          height: 1.25,
                          color: Color(0xFF7A624D),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _buildRewardCard(),
                      const SizedBox(height: 28),
                      _buildReturnButton(context),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16C7D9), Color(0xFF536DFE), Color(0xFFE45DBF)],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF536DFE).withValues(alpha: 0.24),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(22, 14, 22, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Carty',
                style: TextStyle(
                  color: Color(0xFFFFF4C7),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '¡Aventura lograda!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Ahora viene la mejor parte de la misión',
                style: TextStyle(
                  color: Color(0xFFFDF2FF),
                  fontSize: 14.5,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHappyPanda() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFFFC982)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE45DBF).withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/happy_panda.png',
        height: 220,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 180,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF2B8), Color(0xFFFFD1EA)],
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              size: 92,
              color: Color(0xFFB15A00),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRewardCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE8F6), Color(0xFFEFE8FF)],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFFF91CF)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE45DBF).withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🎁 Recompensa desbloqueada',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: Color(0xFF4F321B),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.76),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
            ),
            child: Text(
              reward,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 27,
                height: 1.1,
                color: Color(0xFF6D2F66),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF7A3D), Color(0xFFE45DBF)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF7A3D).withValues(alpha: 0.24),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: const Text(
          'Volver al inicio',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
