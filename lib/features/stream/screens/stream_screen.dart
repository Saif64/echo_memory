import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../shared/widgets/animated_gradient.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../game/widgets/score_display.dart';
import '../controllers/stream_controller.dart' as game;
import '../widgets/stream_item_widget.dart';

class StreamScreen extends StatefulWidget {
  const StreamScreen({super.key});

  @override
  State<StreamScreen> createState() => _StreamScreenState();
}

class _StreamScreenState extends State<StreamScreen> {
  late game.StreamController _controller;
  Timer? _flowTimer;
  int _visibleItems = 0;
  bool _showingFlow = true;

  @override
  void initState() {
    super.initState();
    _controller = game.StreamController();
    // Don't auto start, wait for difficulty selection
  }

  void _startFlow() {
    _visibleItems = 0;
    _showingFlow = true;
    
    _flowTimer?.cancel();
    _flowTimer = Timer.periodic(_controller.flowSpeed, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _visibleItems++;
      });
      
      if (_visibleItems >= _controller.streamItems.length) {
        timer.cancel();
        // Wait a moment then hide
        Future.delayed(const Duration(milliseconds: 1000), () { // Slightly longer view time
          if (!mounted) return;
          setState(() => _showingFlow = false);
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!mounted) return;
            _controller.hideItems();
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _flowTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameGradientBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              if (_controller.isGameOver) {
                return _buildGameOver();
              }
              return Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  Expanded(child: _buildContent()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(LucideIcons.arrowLeft, color: Colors.white70, size: 24),
          ),
          if (_controller.state != game.StreamState.ready)
            Row(
              children: [
                Text('LV ${_controller.level}', style: AppTextStyles.labelMedium.copyWith(color: AppColors.orbBlue)),
                const SizedBox(width: 12),
                const Icon(LucideIcons.gem, color: AppColors.orbGreen, size: 16),
                const SizedBox(width: 4),
                Text('${_controller.score}', style: AppTextStyles.titleMedium),
              ],
            ),
          if (_controller.state != game.StreamState.ready)
            Row(
              children: List.generate(3, (i) => Icon(
                LucideIcons.heart,
                color: i < _controller.lives ? AppColors.orbRed : AppColors.textMuted.withOpacity(0.3),
                size: 18,
              )),
            )
          else
            const SizedBox(width: 48), // Spacer
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_controller.state) {
      case game.StreamState.ready:
        return _buildDifficultySelect();
      case game.StreamState.flowing:
        return _buildFlowingItems();
      case game.StreamState.recall:
        return _buildRecallUI();
      case game.StreamState.levelComplete:
        return _buildLevelComplete();
      case game.StreamState.feedback:
        return _buildFeedback();
      default:
        return const SizedBox();
    }
  }

  Widget _buildDifficultySelect() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(LucideIcons.waves, size: 80, color: AppColors.orbBlue),
          const SizedBox(height: 16),
          Text('ECHO STREAM', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Items will flow past.\nRemember them in sequence.',
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Text('SELECT MODE', style: AppTextStyles.labelMedium.copyWith(color: Colors.white54)),
          const SizedBox(height: 16),
          
          _buildDifficultyButton(
            mode: 'COLOR',
            icon: LucideIcons.palette,
            color: AppColors.orbPurple,
            desc: 'Shapes are same. Remember colors.',
            onTap: () {
              _controller.setDifficulty(game.StreamDifficulty.color);
              _startFlow();
            },
          ),
          const SizedBox(height: 16),
          _buildDifficultyButton(
            mode: 'SHAPE',
            icon: LucideIcons.shapes,
            color: AppColors.orbBlue,
            desc: 'Colors are same. Remember shapes.',
            onTap: () {
              _controller.setDifficulty(game.StreamDifficulty.shape);
              _startFlow();
            },
          ),
          const SizedBox(height: 16),
          _buildDifficultyButton(
            mode: 'BOTH',
            icon: LucideIcons.layers,
            color: AppColors.orbGreen,
            desc: 'Remember both shape AND color.',
            onTap: () {
              _controller.setDifficulty(game.StreamDifficulty.both);
              _startFlow();
            },
          ),
        ],
      ),
    ).animate().fadeIn();
  }
  
  Widget _buildDifficultyButton({
    required String mode,
    required IconData icon,
    required Color color,
    required String desc,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        borderWidth: 1, // Fixed typo
        borderColor: color.withOpacity(0.5),
        backgroundColor: color.withOpacity(0.1),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mode, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(desc, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70)),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowingItems() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'MEMORIZE',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.orbBlue,
            letterSpacing: 4,
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 40),
        SizedBox(
          height: 200,
          child: SingleChildScrollView(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: List.generate(_controller.streamItems.length, (i) {
                final item = _controller.streamItems[i];
                final isVisible = _showingFlow && i < _visibleItems;
                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isVisible ? 1 : 0,
                  child: StreamItemWidget(item: item, size: 60),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 40),
        // Tunnel indicator
        Container(
          width: 200,
          height: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.orbPurple.withOpacity(0.5),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildRecallUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'WHAT WAS ITEM #${_controller.hiddenIndex + 1}?',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.orbGreen,
            letterSpacing: 2,
          ),
        ).animate().fadeIn().slideY(begin: -0.2, end: 0),
        const SizedBox(height: 40),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _controller.choices.map((item) {
            return GestureDetector(
              onTap: () => _handleChoice(item),
              child: StreamItemWidget(item: item, size: 80),
            );
          }).toList(),
        ).animate().fadeIn(delay: 200.ms).scale(),
      ],
    );
  }

  void _handleChoice(game.StreamItem item) {
    bool correct = _controller.selectAnswer(item);
    
    if (_controller.state == game.StreamState.levelComplete) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        _controller.nextLevel();
        _startFlow();
      });
    } else if (!_controller.isGameOver) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        _controller.retry();
        _startFlow();
      });
    }
  }

  Widget _buildLevelComplete() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.checkCircle, size: 60, color: AppColors.orbGreen),
          const SizedBox(height: 12),
          Text('CORRECT!', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.orbGreen)),
          const SizedBox(height: 24),
          Text('The sequence was:', style: AppTextStyles.bodyLarge),
          const SizedBox(height: 12),
          _buildStreamReview(isCorrect: true),
          const SizedBox(height: 16),
          Text('Next level loading...', style: AppTextStyles.bodyMedium),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildFeedback() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.xCircle, size: 60, color: AppColors.orbRed),
          const SizedBox(height: 12),
          Text('WRONG!', style: AppTextStyles.headlineLarge.copyWith(color: AppColors.orbRed)),
          const SizedBox(height: 24),
          Text('Item #${_controller.hiddenIndex + 1} was:', style: AppTextStyles.bodyLarge),
          const SizedBox(height: 12),
          _buildStreamReview(isCorrect: false),
          const SizedBox(height: 16),
          if (_controller.lives > 0)
            Text('${_controller.lives} lives remaining', style: AppTextStyles.bodyMedium),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildStreamReview({required bool isCorrect}) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_controller.streamItems.length, (i) {
        final item = _controller.streamItems[i];
        final isTarget = i == _controller.hiddenIndex;
        return Container(
          decoration: isTarget ? BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCorrect ? AppColors.orbGreen : AppColors.orbYellow,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: (isCorrect ? AppColors.orbGreen : AppColors.orbYellow).withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ) : null,
          child: StreamItemWidget(item: item, size: 50),
        );
      }),
    );
  }

  Widget _buildGameOver() {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.waves, size: 64, color: AppColors.orbBlue),
            const SizedBox(height: 16),
            Text('Stream Ended', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text('Final Score: ${_controller.score}', style: AppTextStyles.titleLarge),
            Text('Reached Level: ${_controller.level}', style: AppTextStyles.bodyLarge),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Exit'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    _controller.resetGame();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.orbBlue),
                  child: const Text('Play Again'),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale();
  }
}
