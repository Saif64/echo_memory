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
import '../widgets/home_header.dart';
import '../widgets/hero_featured_card.dart';
import '../widgets/section_header.dart';
import '../widgets/modern_game_card.dart';
import '../widgets/visuals/lumina_grid_visual.dart';
import '../widgets/visuals/stream_visual.dart';
import '../widgets/visuals/sequence_visual.dart';
import '../../game/screens/game_screen.dart';
import '../../practice/screens/practice_screen.dart';
import '../../daily_challenge/screens/daily_challenge_screen.dart';
import '../../lumina/screens/lumina_screen.dart';
import '../../nback/screens/nback_screen.dart';
import '../../stream/screens/stream_screen.dart';
import '../../shop/screens/shop_screen.dart';
import '../../settings/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background
          const ParticleBackground(
            particleCount: 20,
            particleColor: Color(0x336C5CE7), // Subtle purple particles
            child: AnimatedGradientBackground(
              colors: [
                Color(0xFF0D0D1A),
                Color(0xFF1A1A3A),
                Color(0xFF0D1B2A),
              ],
              child: SizedBox.expand(),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 100), // Space for nav bar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header
                  HomeHeader(
                    onShopTap: () => _navigateTo(const ShopScreen()),
                    onSettingsTap: () => _navigateTo(const SettingsScreen()),
                  ),

                  // 2. Hero Section (Daily Challenge)
                  HeroFeaturedCard(
                    title: 'Daily Challenge',
                    subtitle: 'New puzzle available!',
                    icon: LucideIcons.calendar,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () => _navigateTo(const DailyChallengeScreen()),
                  ),

                  const SizedBox(height: 24),

                  // 3. Featured / New Modes
                  const SectionHeader(title: 'Featured Modes'),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        ModernGameCard(
                          title: 'Lumina Matrix',
                          description: 'Watch the grid glow and recall the exact pattern. A test of spatial memory and focus.',
                          icon: LucideIcons.layoutGrid,
                          color: AppColors.bentoPurple,
                          useWhiteForeground: true,
                          onTap: () => _navigateTo(const LuminaScreen()),
                          badge: 'NEW',
                          isLarge: true,
                          visualContent: const LuminaGridVisual(),
                          statLabel: 'BEST',
                          statValue: '850', // Placeholder
                        ),
                        ModernGameCard(
                          title: 'Echo Stream',
                          description: 'Symbols flow by—match them to the current rule. Keep your streak alive as speed increases!',
                          icon: LucideIcons.waves,
                          color: AppColors.bentoGreen, // Green
                          onTap: () => _navigateTo(const StreamScreen()),
                          badge: 'HOT',
                          isLarge: true,
                          visualContent: const StreamVisual(),
                          statLabel: 'STREAK',
                          statValue: '12',
                        ),
                         ModernGameCard(
                          title: 'Reflex Match',
                          description: 'Does the current symbol match the one from N steps back? A challenging workout for working memory.',
                          icon: LucideIcons.zap,
                          color: AppColors.bentoYellow, // Yellow
                          onTap: () => _navigateTo(const NBackScreen()),
                          isLarge: true,
                          visualContent: const SequenceVisual(isComparison: true),
                          statLabel: 'LEVEL',
                          statValue: '5',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 4. Classics Section
                  const SectionHeader(title: 'Classics'),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        ModernGameCard(
                          title: 'Classic Echo',
                          description: 'Follow the sequence of lights and sounds. How long of a chain can you remember?',
                          icon: LucideIcons.brain,
                          color: AppColors.bentoRed,
                          useWhiteForeground: true,
                          onTap: () => _navigateToDifficultySelect(),
                          visualContent: const SequenceVisual(),
                          statLabel: 'MAX',
                          statValue: '14',
                        ),
                        ModernGameCard(
                          title: 'Quantum Flux',
                          description: 'The sequence shifts and changes every turn. Adapt quickly to the new pattern!',
                          icon: LucideIcons.shuffle,
                          color: AppColors.bentoYellow, // Blue
                          onTap: () => _navigateToQuantumMode(),
                          statLabel: 'SCORE',
                          statValue: '2.4k',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 5. Training & Relax
                  const SectionHeader(title: 'Training & Relax'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: ModernGameCard(
                            title: 'Practice',
                            description: 'Hone your skills without the pressure of lives or timers. Perfect for warming up.',
                            icon: LucideIcons.graduationCap,
                            color: AppColors.bentoOrange, // Orange
                            onTap: () => _navigateTo(const PracticeGameScreen()),
                            isLarge: false,
                          ),
                        ),
                        Expanded(
                          child: ModernGameCard(
                            title: 'Zen Mode',
                            description: 'Endless, relaxing gameplay with soothing visuals. Flow state for your mind.',
                            icon: LucideIcons.leaf,
                            color: AppColors.bentoPink,
                            onTap: () => _navigateToZenMode(),
                            isLarge: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
                begin: const Offset(0.05, 0),
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
          return FadeTransition(opacity: animation, child: child);
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
            'pointMultiplier': 3,
            'lives': 3,
          },
        ),
      ),
    );
  }
}

/// Difficulty selection screen (unchanged logic, updated UI to match)
class DifficultySelectScreen extends StatelessWidget {
  const DifficultySelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ResponsiveUtils.init(context);

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedGradientBackground(
             colors: [
                Color(0xFF0D0D1A),
                Color(0xFF1A1A3A),
              ],
              child: SizedBox.expand(),
          ),
          SafeArea(
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
        ],
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
