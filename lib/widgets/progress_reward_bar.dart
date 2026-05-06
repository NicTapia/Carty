import 'package:flutter/material.dart';

class ProgressRewardBar extends StatelessWidget {
  final double progress;
  final String reward;

  const ProgressRewardBar({
    super.key,
    required this.progress,
    required this.reward,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 16,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(width: 12),
        Text(reward, style: const TextStyle(fontSize: 20)),
      ],
    );
  }
}
