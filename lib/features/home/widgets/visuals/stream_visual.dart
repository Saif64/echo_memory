import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

class StreamVisual extends StatelessWidget {
  const StreamVisual({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: List.generate(3, (index) {
          return Positioned(
            right: index * 15.0,
            top: index * 10.0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2 + (index * 0.2)),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Icon(
                _getIcon(index),
                size: 14,
                color: Colors.white,
              ),
            ).animate(
              onPlay: (controller) => controller.repeat(),
            ).moveY(
              begin: 0,
              end: -10,
              duration: 2.seconds,
              delay: (index * 400).ms,
              curve: Curves.easeInOut,
            ).fadeOut(
              delay: 1.5.seconds,
              duration: 500.ms,
            ),
          );
        }),
      ),
    );
  }

  IconData _getIcon(int index) {
    switch (index % 3) {
      case 0: return LucideIcons.square;
      case 1: return LucideIcons.triangle;
      default: return LucideIcons.circle;
    }
  }
}
