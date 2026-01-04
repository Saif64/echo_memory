/// Neon glowing button widget for Echo Memory
/// Premium buttons with glow effects and animations
import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_text_styles.dart';

class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final double width;
  final double height;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;

  const NeonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color = AppColors.orbBlue,
    this.width = 200,
    this.height = 56,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      setState(() => _isPressed = true);
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      setState(() => _isPressed = false);
      widget.onPressed?.call();
    }
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isActive = !widget.isDisabled && !widget.isLoading;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isActive
                      ? [
                          widget.color,
                          widget.color.withOpacity(0.8),
                        ]
                      : [
                          Colors.grey.shade600,
                          Colors.grey.shade700,
                        ],
                ),
                boxShadow: isActive
                    ? [
                        // Inner glow
                        BoxShadow(
                          color:
                              widget.color.withOpacity(_glowAnimation.value),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                        // Outer glow
                        BoxShadow(
                          color: widget.color
                              .withOpacity(_glowAnimation.value * 0.5),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                        // Bottom shadow
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Shimmer effect
                  if (isActive)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedOpacity(
                          opacity: _glowAnimation.value,
                          duration: const Duration(milliseconds: 100),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.1),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Content
                  if (widget.isLoading)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textPrimary,
                        ),
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: AppColors.textPrimary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: AppTextStyles.button.copyWith(
                            color: isActive
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                            shadows: isActive
                                ? [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Small circular neon button for icons
class NeonIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final double size;
  final bool isActive;

  const NeonIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color = AppColors.orbBlue,
    this.size = 48,
    this.isActive = true,
  });

  @override
  State<NeonIconButton> createState() => _NeonIconButtonState();
}

class _NeonIconButtonState extends State<NeonIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final glowIntensity = 0.3 + (_controller.value * 0.2);

        return GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onPressed?.call();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.9 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isActive
                    ? widget.color.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                border: Border.all(
                  color: widget.isActive
                      ? widget.color.withOpacity(0.6)
                      : Colors.grey.withOpacity(0.4),
                  width: 2,
                ),
                boxShadow: widget.isActive
                    ? [
                        BoxShadow(
                          color: widget.color.withOpacity(glowIntensity),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                widget.icon,
                color: widget.isActive
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
                size: widget.size * 0.5,
              ),
            ),
          ),
        );
      },
    );
  }
}
