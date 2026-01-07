import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/theme/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';

class ModernGameCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? badge;
  final bool isLarge;
  final Widget? visualContent;
  final String? statLabel;
  final String? statValue;

  final bool useWhiteForeground;

  const ModernGameCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
    this.isLarge = false,
    this.visualContent,
    this.statLabel,
    this.statValue,
    this.useWhiteForeground = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = useWhiteForeground ? Colors.white : const Color(0xFF1E1E2E);
    final iconBgColor = useWhiteForeground ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1);
    final statBgColor = useWhiteForeground ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isLarge ? 280 : 160,
        height: isLarge ? 220 : 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative Circle 1 (Top Right)
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),

             // Decorative Circle 2 (Bottom Left)
            Positioned(
              bottom: -20,
              left: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.05),
                ),
              ),
            ),

            // Visual Content (Game Preview)
            if (visualContent != null)
              Positioned(
                top: 20,
                right: 20,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    useWhiteForeground 
                        ? Colors.white.withOpacity(0.1) // Subtle white for dark cards
                        : Colors.black12, // Subtle dark for light cards
                    BlendMode.srcATop,
                  ),
                  child: visualContent!,
                ),
              ),

             // Helper visual pattern
            if (isLarge && visualContent == null)
              Positioned(
                right: 20,
                bottom: 20,
                 child: _buildDotGrid(useWhiteForeground ? Colors.white : Colors.black),
              ),

            // Main Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: iconBgColor,
                    ),
                    child: Icon(
                      icon,
                      color: textColor,
                      size: 24,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Stats Badge
                  if (statLabel != null && statValue != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            statLabel!,
                            style: TextStyle(
                              color: textColor.withOpacity(0.7),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statValue!,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Description
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: textColor.withOpacity(0.7),
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // New/Hot Badge
            if (badge != null)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      color: color, // Use card color for text to tie it in
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95), duration: 200.ms);
  }

  Widget _buildDotGrid(Color color) {
    return Column(
      children: List.generate(3, (i) {
        return Row(
          children: List.generate(3, (j) {
            return Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.3),
              ),
            );
          }),
        );
      }),
    );
  }
}
