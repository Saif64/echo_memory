import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../shared/widgets/animated_gradient.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_button.dart';
import '../../game/widgets/score_display.dart';
import '../controllers/lumina_controller.dart';
import '../widgets/matrix_grid.dart';

class LuminaScreen extends StatefulWidget {
  const LuminaScreen({super.key});

  @override
  State<LuminaScreen> createState() => _LuminaScreenState();
}

class _LuminaScreenState extends State<LuminaScreen> {
  late LuminaGameController _controller;
  Timer? _phaseTimer;
  String _statusText = 'WATCH';

  @override
  void initState() {
    super.initState();
    _controller = LuminaGameController();
    _startLevelSequence();
  }

  void _startLevelSequence() {
    _controller.startGame(); // Generates pattern
    _statusText = 'WATCH PATTERN';
    
    // Show pattern for 2 seconds, then hide
    _phaseTimer?.cancel();
    _phaseTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _statusText = 'RECALL NOW';
        _controller.startRecall();
      });
    });
  }

  void _handleGridTap(int index) {
    if (_controller.state != LuminaState.playing) return;

    bool correct = _controller.handleTap(index);
    
    if (_controller.state == LuminaState.success) {
      _handleSuccess();
    } else if (_controller.state == LuminaState.failed) {
      _handleFailure();
    }
  }

  void _handleSuccess() {
    setState(() => _statusText = 'EXCELLENT!');
    // Wait then next round
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _controller.nextRound(); // Generates new level
      setState(() => _statusText = 'WATCH PATTERN');
      
      // Pattern display logic again
      _phaseTimer?.cancel();
      _phaseTimer = Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _statusText = 'RECALL NOW';
          _controller.startRecall();
        });
      });
    });
  }

  void _handleFailure() {
    setState(() => _statusText = 'GAME OVER');
    // Simple retry dialog for now
    showDialog(
       context: context,
       barrierDismissible: false,
       builder: (context) => AlertDialog(
         backgroundColor: const Color(0xFF1A1A2E),
         title: Text('Game Over', style: AppTextStyles.headlineMedium),
         content: Text(
           'Score: ${_controller.score}\nLevel: ${_controller.level}',
           style: AppTextStyles.bodyLarge,
         ),
         actions: [
           TextButton(
             onPressed: () {
               Navigator.pop(context); // Close dialog
               Navigator.pop(context); // Close screen
             },
             child: const Text('Exit'),
           ),
           ElevatedButton(
             onPressed: () {
               Navigator.pop(context);
               _startLevelSequence(); // Restart
             },
             style: ElevatedButton.styleFrom(
               backgroundColor: AppColors.orbBlue,
             ),
             child: const Text('Try Again'),
           ),
         ],
       ),
    );
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
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
            builder: (context, child) {
              return Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildGrid(),
                          const SizedBox(height: 32),
                          _buildStatus(),
                        ],
                      ),
                    ),
                  ),
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
          Row(
            children: [
              Text('LV ${_controller.level}', style: AppTextStyles.labelMedium.copyWith(color: AppColors.orbPurple)),
              const SizedBox(width: 12),
              const Icon(LucideIcons.gem, color: AppColors.orbBlue, size: 16),
              const SizedBox(width: 4),
              Text('${_controller.score}', style: AppTextStyles.titleMedium),
            ],
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }


  Widget _buildGrid() {
    return MatrixGrid(
      gridSize: _controller.gridSize,
      activeIndices: _controller.state == LuminaState.watching 
          ? _controller.activePattern 
          : _controller.state == LuminaState.playing  || _controller.state == LuminaState.success
              ? _controller.activePattern // Show what user tapped
              : _controller.activePattern, // Show correct pattern on fail?
      onTap: _handleGridTap,
      state: _controller.state,
    );
  }

  Widget _buildStatus() {
    Color color = AppColors.textPrimary;
    if (_controller.state == LuminaState.watching) color = AppColors.orbBlue;
    if (_controller.state == LuminaState.playing) color = AppColors.orbGreen;
    if (_controller.state == LuminaState.failed) color = AppColors.orbRed;

    return Text(
      _statusText,
      style: AppTextStyles.headlineMedium.copyWith(
        color: color,
        letterSpacing: 3,
      ),
    ).animate(key: ValueKey(_statusText)).fadeIn().slideY(begin: 0.2, end: 0);
  }
}
