/// Color Orb widget for Echo Memory
/// Premium animated color buttons with glow effects - Optimized
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../config/theme/app_colors.dart';

class ColorOrb extends StatefulWidget {
  final int colorIndex;
  final double size;
  final VoidCallback? onTap;
  final bool isDisabled;
  final bool isHighlighted;
  final bool showRipple;

  const ColorOrb({
    super.key,
    required this.colorIndex,
    this.size = 80,
    this.onTap,
    this.isDisabled = false,
    this.isHighlighted = false,
    this.showRipple = false,
  });

  @override
  State<ColorOrb> createState() => _ColorOrbState();
}

class _ColorOrbState extends State<ColorOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;
  
  // Cache colors to avoid recalculating every build
  late final Color _orbColor;
  late final Color _glowColor;

  @override
  void initState() {
    super.initState();
    // Cache colors once
    _orbColor = AppColors.gameOrbs[widget.colorIndex % AppColors.gameOrbs.length];
    _glowColor = AppColors.gameOrbGlows[widget.colorIndex % AppColors.gameOrbGlows.length];
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isHighlighted) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ColorOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHighlighted != oldWidget.isHighlighted) {
      if (widget.isHighlighted) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isDisabled) {
      setState(() => _isPressed = true);
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.isDisabled) {
      setState(() => _isPressed = false);
      widget.onTap?.call();
    }
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale =
              widget.isHighlighted ? _pulseAnimation.value : 1.0;
          final glowIntensity =
              widget.isHighlighted ? _glowAnimation.value : 0.3;
          
          // When highlighted, show actual colors even if disabled (for pattern display)
          final showActualColors = widget.isHighlighted || !widget.isDisabled;

          return GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: AnimatedScale(
              scale: _isPressed ? 0.9 : scale,
              duration: const Duration(milliseconds: 100),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow
                  Container(
                    width: widget.size * 1.3,
                    height: widget.size * 1.3,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _orbColor.withOpacity(
                            showActualColors ? glowIntensity : 0.1,
                          ),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),

                  // Main orb
                  Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: showActualColors
                            ? [
                                _glowColor,
                                _orbColor,
                                _orbColor.withOpacity(0.8),
                              ]
                            : [
                                Colors.grey.shade600,
                                Colors.grey.shade800,
                              ],
                        stops: showActualColors
                            ? const [0.0, 0.4, 1.0]
                            : const [0.0, 1.0],
                        center: const Alignment(-0.3, -0.3),
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(
                          showActualColors ? 0.3 : 0.1,
                        ),
                        width: 2,
                      ),
                      boxShadow: [
                        // Inner shadow (depth effect)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(3, 3),
                        ),
                        // Colored glow
                        if (showActualColors)
                          BoxShadow(
                            color: _orbColor.withOpacity(glowIntensity),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    child: child,
                  ),

                  // Ripple effect on tap
                  if (widget.showRipple && _isPressed)
                    Container(
                      width: widget.size * 1.5,
                      height: widget.size * 1.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _glowColor.withOpacity(0.5),
                          width: 3,
                        ),
                      ),
                    ).animate().scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.2, 1.2),
                          duration: 300.ms,
                        ).fadeOut(duration: 300.ms),
                ],
              ),
            ),
          );
        },
        // Static highlight decoration passed as child
        child: Stack(
          children: [
            // Highlight/reflection (static)
            Positioned(
              top: widget.size * 0.15,
              left: widget.size * 0.2,
              child: Container(
                width: widget.size * 0.25,
                height: widget.size * 0.15,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(
                        widget.isDisabled ? 0.1 : 0.4,
                      ),
                      Colors.white.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated color orb for pattern display
class PatternOrb extends StatelessWidget {
  final int colorIndex;
  final int index;
  final double size;
  final bool animateIn;

  const PatternOrb({
    super.key,
    required this.colorIndex,
    required this.index,
    this.size = 50,
    this.animateIn = true,
  });

  Color get orbColor =>
      AppColors.gameOrbs[colorIndex % AppColors.gameOrbs.length];
  Color get glowColor =>
      AppColors.gameOrbGlows[colorIndex % AppColors.gameOrbGlows.length];

  @override
  Widget build(BuildContext context) {
    Widget orb = Container(
      width: size,
      height: size,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            glowColor,
            orbColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: orbColor.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
    );

    if (animateIn) {
      orb = orb
          .animate()
          .fadeIn(delay: (index * 100).ms, duration: 300.ms)
          .scale(
            begin: const Offset(0.5, 0.5),
            end: const Offset(1, 1),
            delay: (index * 100).ms,
            duration: 300.ms,
            curve: Curves.elasticOut,
          );
    }

    return orb;
  }
}
