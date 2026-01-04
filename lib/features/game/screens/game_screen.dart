/// Main game screen for Echo Memory
/// Core gameplay with all visual enhancements
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../config/constants/game_constants.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../shared/widgets/animated_gradient.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_button.dart';
import '../../../data/models/power_up.dart';
import '../widgets/color_orb.dart';
import '../widgets/combo_indicator.dart';
import '../widgets/score_display.dart';
import '../widgets/power_up_bar.dart';
import '../animations/celebration_overlay.dart';
import '../../home/screens/home_screen.dart';

class GameScreen extends StatefulWidget {
  final String difficulty;
  final Map<String, int> settings;

  const GameScreen({
    super.key,
    required this.difficulty,
    required this.settings,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Services
  final SoundService _soundService = SoundService();
  final HapticService _hapticService = HapticService();

  // Game state
  List<int> _sequence = [];
  int _currentIndex = 0;
  int _score = 0;
  int _lives = 3;
  int _level = 1;
  int _currentStreak = 0;
  int _bestStreak = 0;
  int _timeRemaining = 0;
  bool _showPattern = true;
  bool _isGameOver = false;
  bool _showCelebration = false;
  CelebrationType? _celebrationType;
  int _highlightedOrbIndex = -1;
  Timer? _gameTimer;
  Timer? _patternTimer;
  final Random _random = Random();
  
  // Quantum Mode State
  List<int> _orbMapping = [0, 1, 2, 3, 4]; // Maps physical index to color index
  bool get _isQuantumMode => widget.difficulty == 'quantum';

  // Power-ups
  PowerUpInventory _powerUps = PowerUpInventory(quantities: {
    PowerUpType.slowMotion: 2,
    PowerUpType.hint: 1,
    PowerUpType.shield: 1,
  });
  PowerUpType? _activePowerUp;
  bool _hasShield = false;

  // Animation controllers
  late AnimationController _shakeController;
  bool _shouldShake = false;

  @override
  void initState() {
    super.initState();
    _lives = widget.settings['lives'] ?? 3;
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _startGame();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _patternTimer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  void _startGame() {
    _generateSequence();
  }

  void _generateSequence() {
    setState(() {
      _sequence = List.generate(
        widget.settings['initialSequence'] ?? 3,
        (_) => _random.nextInt(5),
      );
      _currentIndex = 0;
      _showPattern = true;
      _level = _sequence.length - (widget.settings['initialSequence'] ?? 3) + 1;
    });
    _displayPattern();
  }

  void _displayPattern() {
    _patternTimer?.cancel();
    int displayIndex = 0;

    _patternTimer = Timer.periodic(
      Duration(milliseconds: _activePowerUp == PowerUpType.slowMotion ? 1200 : 800),
      (timer) {
        if (displayIndex < _sequence.length) {
          setState(() => _highlightedOrbIndex = _sequence[displayIndex]);
          _soundService.playColorSound(_sequence[displayIndex]);
          _hapticService.lightImpact();

          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) {
              setState(() => _highlightedOrbIndex = -1);
            }
          });
          displayIndex++;
        } else {
          timer.cancel();
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _showPattern = false;
                if (_isQuantumMode) {
                  _shuffleOrbs();
                }
                _startTimer();
              });
            }
          });
        }
      },
    );
  }

  void _startTimer() {
    final timeLimit = widget.settings['timeLimit'] ?? 10;
    if (timeLimit == 0) return; // Zen mode

    setState(() => _timeRemaining = timeLimit);

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() => _timeRemaining--);
      } else {
        _loseLife();
        timer.cancel();
      }
    });
  }

  void _onOrbTap(int colorIndex) {
    if (_showPattern || _isGameOver) return;

    _soundService.playColorSound(colorIndex);
    _hapticService.lightImpact();

    if (_sequence[_currentIndex] == colorIndex) {
      _handleCorrectAnswer();
    } else {
      _handleWrongAnswer();
    }
  }

  void _handleCorrectAnswer() {
    setState(() {
      _currentStreak++;
      if (_currentStreak > _bestStreak) _bestStreak = _currentStreak;

      // Calculate points with multiplier
      final multiplier = _getMultiplier();
      final points = (GameConstants.basePointsPerColor *
              widget.settings['pointMultiplier']! *
              multiplier)
          .round();
      _score += points;

      _currentIndex++;
    });

    // Check combo
    if (_currentStreak >= GameConstants.comboGoodThreshold) {
      _hapticService.combo(_currentStreak);
      _soundService.playCombo(_currentStreak);
    } else {
      _soundService.playCorrect();
    }

    // Check if sequence complete
    if (_currentIndex >= _sequence.length) {
      _gameTimer?.cancel();
      _handleLevelComplete();
    }
  }

  void _handleWrongAnswer() {
    _soundService.playWrong();
    _hapticService.error();

    // Check for shield power-up
    if (_hasShield) {
      setState(() {
        _hasShield = false;
        _currentStreak = 0;
      });
      return;
    }

    _loseLife();
  }

  void _loseLife() {
    _gameTimer?.cancel();
    setState(() {
      _lives--;
      _currentStreak = 0;
      _shouldShake = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _shouldShake = false);
    });

    if (_lives <= 0) {
      _handleGameOver();
    } else {
      // Retry current sequence
      setState(() => _currentIndex = 0);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _showPattern = true);
          _displayPattern();
        }
      });
    }
  }

  void _handleLevelComplete() {
    _soundService.playVictory();
    _hapticService.success();

    setState(() {
      _showCelebration = true;
      _celebrationType = CelebrationType.levelComplete;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showCelebration = false;
          _sequence.add(_random.nextInt(5));
          _currentIndex = 0;
          _level++;
          _showPattern = true;
        });
        _displayPattern();
      }
    });
  }

  void _handleGameOver() {
    _soundService.playGameOver();
    _hapticService.gameOver();

    setState(() => _isGameOver = true);
  }

  double _getMultiplier() {
    if (_currentStreak >= GameConstants.comboLegendaryThreshold) {
      return GameConstants.comboLegendaryMultiplier;
    }
    if (_currentStreak >= GameConstants.comboFireThreshold) {
      return GameConstants.comboFireMultiplier;
    }
    if (_currentStreak >= GameConstants.comboAmazingThreshold) {
      return GameConstants.comboAmazingMultiplier;
    }
    if (_currentStreak >= GameConstants.comboGoodThreshold) {
      return GameConstants.comboGoodMultiplier;
    }
    return 1.0;
  }

  void _usePowerUp(PowerUpType type) {
    if (!_powerUps.hasPowerUp(type)) return;

    _soundService.playPowerUp();
    _hapticService.powerUp();

    setState(() {
      _powerUps = _powerUps.usePowerUp(type);
      _activePowerUp = type;
    });

    switch (type) {
      case PowerUpType.shield:
        setState(() => _hasShield = true);
        break;
      case PowerUpType.hint:
        _showHint();
        break;
      case PowerUpType.timeFreeze:
        _freezeTimer();
        break;
      default:
        break;
    }

    // Clear active power-up indicator after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _activePowerUp = null);
    });
  }

  void _showHint() {
    // Flash the next 2 colors
    for (int i = 0; i < 2 && _currentIndex + i < _sequence.length; i++) {
      final targetIndex = _currentIndex + i;
      Future.delayed(Duration(milliseconds: i * 300), () {
        if (mounted) {
          setState(() => _highlightedOrbIndex = _sequence[targetIndex]);
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted) setState(() => _highlightedOrbIndex = -1);
          });
        }
      });
    }
  }

  void _freezeTimer() {
    _gameTimer?.cancel();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !_showPattern && !_isGameOver) {
        _startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);

    return Scaffold(
      body: ScreenShake(
        shake: _shouldShake,
        intensity: 10,
        child: GameGradientBackground(
          showOverlay: true,
          child: SafeArea(
            child: Stack(
              children: [
                // Main game content
                Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: _isGameOver
                          ? _buildGameOverContent()
                          : _buildGameContent(),
                    ),
                  ],
                ),

                // Celebration overlay
                if (_showCelebration && _celebrationType != null)
                  CelebrationOverlay(
                    type: _celebrationType!,
                    onComplete: () {
                      setState(() => _showCelebration = false);
                    },
                  ),

                // Combo indicator
                if (_currentStreak >= GameConstants.comboGoodThreshold &&
                    !_showPattern)
                  Positioned(
                    top: 120,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ComboIndicator(streak: _currentStreak),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Back button + Score
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.x,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Score
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.star,
                    color: AppColors.accentGold,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$_score',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Center: Timer (only when playing)
          if (widget.settings['timeLimit'] != 0 && !_showPattern)
            CircularTimer(
              timeRemaining: _timeRemaining,
              totalTime: widget.settings['timeLimit'] ?? 10,
              size: 44,
              showText: true,
            ),

          // Right: Lives
          LivesDisplay(
            lives: _lives,
            maxLives: widget.settings['lives'] ?? 3,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    final orbSize = ResponsiveUtils.getGameButtonSize().clamp(55.0, 80.0);
    final ringRadius = orbSize * 1.8; // Distance from center to orbs

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Reactor Core - Circular Orb Layout
        SizedBox(
          width: ringRadius * 2 + orbSize * 1.5,
          height: ringRadius * 2 + orbSize * 1.5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Ring Glow (decorative)
              Container(
                width: ringRadius * 2 + orbSize * 0.5,
                height: ringRadius * 2 + orbSize * 0.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (_showPattern ? AppColors.orbBlue : AppColors.orbGreen)
                        .withOpacity(0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_showPattern ? AppColors.orbBlue : AppColors.orbGreen)
                          .withOpacity(0.1),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),

              // Central Status Hub
              _buildCentralHub(),

              // Orbs positioned in a circle
              ..._buildCircularOrbs(orbSize, ringRadius),
            ],
          ),
        ).animate().fadeIn().scale(
              begin: const Offset(0.9, 0.9),
              duration: 400.ms,
              curve: Curves.easeOutBack,
            ),

        const SizedBox(height: 40),

        // Power-ups at the bottom (more ergonomic)
        PowerUpBar(
          inventory: _powerUps,
          activePowerUp: _activePowerUp,
          onPowerUpTap: _usePowerUp,
          isDisabled: _showPattern,
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

        // Shield indicator
        if (_hasShield)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.powerUpShield.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.powerUpShield.withOpacity(0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.shield,
                    color: AppColors.powerUpShield,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Shield Active',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.powerUpShield,
                    ),
                  ),
                ],
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .shimmer(duration: 1500.ms),
          ),
      ],
    );
  }

  /// The central hub showing status and level
  Widget _buildCentralHub() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.surface.withOpacity(0.8),
            AppColors.surface.withOpacity(0.4),
          ],
        ),
        border: Border.all(
          color: (_showPattern ? AppColors.orbBlue : AppColors.orbGreen)
              .withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (_showPattern ? AppColors.orbBlue : AppColors.orbGreen)
                .withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _showPattern ? 'WATCH' : 'GO!',
            style: AppTextStyles.labelLarge.copyWith(
              color: _showPattern ? AppColors.orbBlue : AppColors.orbGreen,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Level $_level',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          Text(
            '${_sequence.length} colors',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// Generate orbs positioned in a circle
  List<Widget> _buildCircularOrbs(double orbSize, double radius) {
    const int numOrbs = 5;
    const double startAngle = -90 * (3.14159 / 180); // Start from top

    return List.generate(numOrbs, (index) {
      final angle = startAngle + (index * 2 * 3.14159 / numOrbs);
      final x = radius * cos(angle);
      final y = radius * sin(angle);
      final colorIndex = _orbMapping[index];

      return Positioned(
        left: radius + x - orbSize / 2 + orbSize * 0.75,
        top: radius + y - orbSize / 2 + orbSize * 0.75,
        child: ColorOrb(
          colorIndex: colorIndex,
          size: orbSize,
          onTap: () => _onOrbTap(colorIndex),
          isDisabled: _showPattern,
          isHighlighted: _highlightedOrbIndex == colorIndex,
          showRipple: true,
        ),
      );
    });
  }

  void _shuffleOrbs() {
    setState(() {
      _orbMapping.shuffle();
      // Play shuffle sound/haptic
      _soundService.playPowerUp(); // Use powerup sound for now
      _hapticService.mediumImpact();
    });
  }

  Widget _buildGameOverContent() {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GAME OVER',
              style: AppTextStyles.displaySmall.copyWith(
                color: AppColors.accentError,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Final Score',
              style: AppTextStyles.labelMedium,
            ),
            Text(
              '$_score',
              style: AppTextStyles.score.copyWith(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatItem('Best Streak', '$_bestStreak'),
                const SizedBox(width: 24),
                _buildStatItem('Level', '$_level'),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                NeonButton(
                  text: 'Home',
                  color: AppColors.textMuted,
                  width: 120,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                NeonButton(
                  text: 'Play Again',
                  color: AppColors.orbGreen,
                  width: 140,
                  icon: LucideIcons.refreshCw,
                  onPressed: _restartGame,
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.labelSmall),
        Text(
          value,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.accentGold,
          ),
        ),
      ],
    );
  }

  void _restartGame() {
    setState(() {
      _score = 0;
      _lives = widget.settings['lives'] ?? 3;
      _currentStreak = 0;
      _bestStreak = 0;
      _level = 1;
      _isGameOver = false;
      _hasShield = false;
      _orbMapping = [0, 1, 2, 3, 4];
    });
    _startGame();
  }
}
