/// Home screen for Echo Memory
/// Premium main menu with animated background and mode selection
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../shared/widgets/animated_gradient.dart';
import '../../../shared/widgets/glass_container.dart';
import '../widgets/game_mode_card.dart';
import '../widgets/animated_title.dart';
import '../../game/screens/game_screen.dart';
import '../../practice/screens/practice_screen.dart';
import '../../daily_challenge/screens/daily_challenge_screen.dart';
import '../../lumina/screens/lumina_screen.dart';
import '../../nback/screens/nback_screen.dart';
import '../../stream/screens/stream_screen.dart';
import '../../shop/screens/shop_screen.dart';
import '../../economy/widgets/economy_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);

    return Scaffold(
      body: ParticleBackground(
        particleCount: 25, // Reduced from 40 for better performance
        particleColor: AppColors.orbBlue.withOpacity(0.3),
        child: AnimatedGradientBackground(
          colors: [
            const Color(0xFF0D0D1A),
            const Color(0xFF1A1A3A),
            const Color(0xFF0D1B2A),
          ],
          duration: const Duration(seconds: 15),
          child: SafeArea(
            child: OrientationBuilder(
              builder: (context, orientation) {
                return orientation == Orientation.portrait
                    ? _buildPortraitLayout()
                    : _buildLandscapeLayout();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Economy bar at top
          Align(
            alignment: Alignment.topCenter,
            child: EconomyBar(
              onShopTap: () => _navigateTo(const ShopScreen()),
            ),
          ),
          const SizedBox(height: 24),
          // Animated title
          const AnimatedGameTitle(),
          const SizedBox(height: 16),
          // Tagline
          Text(
            'Test your memory, challenge your mind',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 48),
          // Game mode cards
          _buildModeCards(),
          // Bottom padding for floating nav bar
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        // Left side - Title
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AnimatedGameTitle(fontSize: 40),
                const SizedBox(height: 16),
                Text(
                  'Test your memory,\nchallenge your mind',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms),
              ],
            ),
          ),
        ),
        // Right side - Mode cards
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                _buildModeCards(),
                const SizedBox(height: 100), // Padding for floating nav
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeCards() {
    return Column(
      children: [
        // Classic Echo (formerly Challenge Mode)
        GameModeCard(
          title: 'Classic Echo',
          description: 'The original sequence memory challenge',
          icon: LucideIcons.waves, // distinctive icon for Classic
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
          ),
          onTap: () => _navigateToDifficultySelect(),
          delay: 0,
        ),
        const SizedBox(height: 16),
        // Lumina Matrix (New)
        GameModeCard(
          title: 'Lumina Matrix',
          description: 'Spatial memory training on a grid',
          icon: LucideIcons.layoutGrid,
          gradient: const LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
          ),
          onTap: () => _navigateTo(const LuminaScreen()),
          delay: 50,
          badge: 'NEW',
        ),
        const SizedBox(height: 16),
        // Reflex Match (formerly Dual Core)
        GameModeCard(
          title: 'Reflex Match',
          description: 'Same or Different? Test your reaction!',
          icon: LucideIcons.zap,
          gradient: const LinearGradient(
            colors: [Color(0xFF8E44AD), Color(0xFFBB6BD9)],
          ),
          onTap: () => _navigateTo(const NBackScreen()),
          delay: 100,
          badge: 'NEW',
        ),
        const SizedBox(height: 16),
        // Echo Stream
        GameModeCard(
          title: 'Echo Stream',
          description: 'Speed memory with flowing items',
          icon: LucideIcons.waves,
          gradient: const LinearGradient(
            colors: [Color(0xFF00B894), Color(0xFF55EFC4)],
          ),
          onTap: () => _navigateTo(const StreamScreen()),
          delay: 150,
          badge: 'NEW',
        ),
        const SizedBox(height: 16),
        // Quantum Flux Mode
        GameModeCard(
          title: 'Quantum Flux',
          description: 'Orbs shuffle positions! Watch the colors.',
          icon: LucideIcons.shuffle,
          gradient: const LinearGradient(
            colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
          ),
          onTap: () => _navigateToQuantumMode(),
          delay: 200,
        ),
        const SizedBox(height: 16),
        // Practice Mode
        GameModeCard(
          title: 'Practice Mode',
          description: 'Learn at your own pace without time limits',
          icon: LucideIcons.graduationCap,
          gradient: const LinearGradient(
            colors: [Color(0xFF4ECDC4), Color(0xFF7EDFD8)],
          ),
          onTap: () => _navigateTo(const PracticeGameScreen()),
          delay: 100,
        ),
        const SizedBox(height: 16),
        // Daily Challenge
        GameModeCard(
          title: 'Daily Challenge',
          description: 'New challenge every day',
          icon: LucideIcons.calendar,
          gradient: const LinearGradient(
            colors: [Color(0xFFB794F6), Color(0xFFD4B8FF)],
          ),
          onTap: () => _navigateTo(const DailyChallengeScreen()),
          delay: 200,
          badge: 'NEW',
        ),
        const SizedBox(height: 16),
        // Zen Mode
        GameModeCard(
          title: 'Zen Mode',
          description: 'Relaxing infinite play',
          icon: LucideIcons.leaf,
          gradient: const LinearGradient(
            colors: [Color(0xFF45B7D1), Color(0xFF74CAE0)],
          ),
          onTap: () => _navigateToZenMode(),
          delay: 300,
        ),
      ],
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToDifficultySelect() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DifficultySelectScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToZenMode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GameScreen(
          difficulty: 'zen',
          settings: {
            'initialSequence': 3,
            'timeLimit': 0,
            'pointMultiplier': 1,
            'lives': 999,
          },
        ),
      ),
    );
  }

  void _navigateToQuantumMode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GameScreen(
          difficulty: 'quantum',
          settings: {
            'initialSequence': 3,
            'timeLimit': 10,
            'pointMultiplier': 3, // High risk, high reward
            'lives': 3,
          },
        ),
      ),
    );
  }
}

/// Difficulty selection screen
class DifficultySelectScreen extends StatelessWidget {
  const DifficultySelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);

    return Scaffold(
      body: GameGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Back button & title
                Row(
                  children: [
                    GlassContainer(
                      padding: const EdgeInsets.all(12),
                      borderRadius: 12,
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        LucideIcons.arrowLeft,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Select Difficulty',
                      style: AppTextStyles.headlineMedium,
                    ),
                  ],
                ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                const Spacer(),
                // Difficulty options
                _buildDifficultyCard(
                  context,
                  title: 'Beginner',
                  description: 'Perfect for learning',
                  color: AppColors.difficultyBeginner,
                  icon: LucideIcons.star,
                  settings: {
                    'initialSequence': 3,
                    'timeLimit': 12,
                    'pointMultiplier': 1,
                    'lives': 3,
                  },
                  delay: 0,
                ),
                const SizedBox(height: 16),
                _buildDifficultyCard(
                  context,
                  title: 'Expert',
                  description: 'For experienced players',
                  color: AppColors.difficultyExpert,
                  icon: LucideIcons.zap,
                  settings: {
                    'initialSequence': 4,
                    'timeLimit': 8,
                    'pointMultiplier': 2,
                    'lives': 2,
                  },
                  delay: 100,
                ),
                const SizedBox(height: 16),
                _buildDifficultyCard(
                  context,
                  title: 'Master',
                  description: 'Ultimate challenge',
                  color: AppColors.difficultyMaster,
                  icon: LucideIcons.skull,
                  settings: {
                    'initialSequence': 5,
                    'timeLimit': 5,
                    'pointMultiplier': 3,
                    'lives': 1,
                  },
                  delay: 200,
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyCard(
    BuildContext context, {
    required String title,
    required String description,
    required Color color,
    required IconData icon,
    required Map<String, int> settings,
    required int delay,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(
              difficulty: title.toLowerCase(),
              settings: settings,
            ),
          ),
        );
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
                border: Border.all(color: color.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleLarge.copyWith(color: color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1, end: 0);
  }
}
