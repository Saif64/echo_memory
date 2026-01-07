import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LuminaGridVisual extends StatelessWidget {
  const LuminaGridVisual({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(9, (index) {
          // Highlight specific cells to form a pattern
          final isHighlighted = [0, 4, 8].contains(index);
          
          return Container(
            decoration: BoxDecoration(
              color: isHighlighted 
                ? Colors.white.withOpacity(0.8) 
                : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ).animate(
            onPlay: (controller) => controller.repeat(reverse: true),
          ).scale(
            begin: isHighlighted ? const Offset(1, 1) : const Offset(0.8, 0.8),
            end: isHighlighted ? const Offset(1.1, 1.1) : const Offset(0.8, 0.8),
            duration: 1.seconds,
            delay: (index * 100).ms,
          );
        }),
      ),
    );
  }
}
