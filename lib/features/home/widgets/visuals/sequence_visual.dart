import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SequenceVisual extends StatelessWidget {
  final bool isComparison; // For Reflex Match vs Classic

  const SequenceVisual({
    super.key,
    this.isComparison = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (index) {
          return Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ).animate(
            onPlay: (controller) => controller.repeat(),
          ).scale(
            begin: const Offset(0.5, 0.5),
            end: const Offset(1.2, 1.2),
            duration: 600.ms,
            delay: (index * 200).ms,
            curve: Curves.easeInOut,
          ).fadeIn(
            duration: 300.ms,
          ).fadeOut(
            delay: 300.ms,
            duration: 300.ms,
          );
        }),
      ),
    );
  }
}
