/// Economy Bar Widget for Echo Memory
/// Floating bar showing coins, gems, and lives

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../config/theme/app_colors.dart';
import '../cubit/economy_cubit.dart';
import '../cubit/economy_state.dart';

class EconomyBar extends StatefulWidget {
  final VoidCallback? onShopTap;
  final bool showLives;

  const EconomyBar({
    super.key,
    this.onShopTap,
    this.showLives = true,
  });

  @override
  State<EconomyBar> createState() => _EconomyBarState();
}

class _EconomyBarState extends State<EconomyBar> {
  Timer? _lifeTimer;
  Duration? _timeUntilNextLife;

  @override
  void initState() {
    super.initState();
    _startLifeTimer();
  }

  @override
  void dispose() {
    _lifeTimer?.cancel();
    super.dispose();
  }

  void _startLifeTimer() {
    _lifeTimer?.cancel();
    _lifeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final state = context.read<EconomyCubit>().state;
      if (state.timeUntilNextLife != null) {
        setState(() {
          _timeUntilNextLife = state.timeUntilNextLife;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EconomyCubit, EconomyState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.glassBackground,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: AppColors.glassBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Coins
              _CurrencyItem(
                icon: LucideIcons.coins,
                color: AppColors.orbYellow,
                value: state.coins,
                onTap: widget.onShopTap,
              ),

              const SizedBox(width: 16),

              // Gems
              _CurrencyItem(
                icon: LucideIcons.gem,
                color: AppColors.orbPurple,
                value: state.gems,
                onTap: widget.onShopTap,
              ),

              if (widget.showLives) ...[
                const SizedBox(width: 16),

                // Divider
                Container(
                  width: 1,
                  height: 24,
                  color: AppColors.glassBorder,
                ),

                const SizedBox(width: 16),

                // Lives
                _LivesItem(
                  lives: state.lives,
                  maxLives: state.maxLives,
                  timeUntilNext: state.timeUntilNextLife,
                  onTap: widget.onShopTap,
                ),
              ],
            ],
          ),
        ).animate().fadeIn().slideY(begin: -0.5);
      },
    );
  }
}

class _CurrencyItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int value;
  final VoidCallback? onTap;

  const _CurrencyItem({
    required this.icon,
    required this.color,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 6),
          Text(
            _formatNumber(value),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }
}

class _LivesItem extends StatelessWidget {
  final int lives;
  final int maxLives;
  final Duration? timeUntilNext;
  final VoidCallback? onTap;

  const _LivesItem({
    required this.lives,
    required this.maxLives,
    this.timeUntilNext,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFull = lives >= maxLives;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Heart icon with glow effect
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.orbRed.withOpacity(0.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.orbRed.withOpacity(0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              LucideIcons.heart,
              color: AppColors.orbRed,
              size: 18,
            ),
          ),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$lives/$maxLives',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (!isFull && timeUntilNext != null)
                Text(
                  _formatDuration(timeUntilNext!),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
