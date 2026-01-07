/// Leaderboard Screen for Echo Memory
/// Full-featured leaderboard with tabs and mode selection

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../config/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/dialogs/auth_required_dialog.dart';
import '../cubit/leaderboard_cubit.dart';
import '../cubit/leaderboard_state.dart';
import '../../../data/dto/leaderboard_dto.dart';


class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _gameModes = [
    {'id': 'classic', 'name': 'Classic', 'icon': LucideIcons.brain},
    {'id': 'stream', 'name': 'Stream', 'icon': LucideIcons.waves},
    {'id': 'lumina', 'name': 'Lumina', 'icon': LucideIcons.layoutGrid},
    {'id': 'reflex', 'name': 'Reflex', 'icon': LucideIcons.zap},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeaderboardCubit>().loadLeaderboard();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final period = _tabController.index == 0
          ? LeaderboardPeriod.allTime
          : LeaderboardPeriod.weekly;
      context.read<LeaderboardCubit>().switchPeriod(period);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          const AnimatedGradientBackground(child: SizedBox.expand()),

          // Content
          SafeArea(
            child: Column(
              children: [
                // App bar
                _buildAppBar(),

                // Mode selector
                _buildModeSelector(),

                // Tab bar
                _buildTabBar(),

                // Leaderboard content
                Expanded(
                  child: _buildLeaderboardContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            'Leaderboard',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => context.read<LeaderboardCubit>().refresh(),
            icon: const Icon(LucideIcons.refreshCw),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildModeSelector() {
    return BlocBuilder<LeaderboardCubit, LeaderboardState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _gameModes.map((mode) {
                final isSelected = state.selectedMode == mode['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _ModeChip(
                    name: mode['name'],
                    icon: mode['icon'],
                    isSelected: isSelected,
                    onTap: () => context
                        .read<LeaderboardCubit>()
                        .switchMode(mode['id']),
                  ),
                );
              }).toList(),
            ),
          ),
        ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1);
      },
    );
  }

  Widget _buildTabBar() {
    return GlassContainer(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      borderRadius: 16,
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              AppColors.orbPurple,
              AppColors.orbBlue,
            ],
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        tabs: const [
          Tab(text: 'All-Time'),
          Tab(text: 'Weekly'),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildLeaderboardContent() {
    return BlocBuilder<LeaderboardCubit, LeaderboardState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.orbPurple),
            ),
          );
        }

        if (state.errorMessage != null) {
          // Check if it's an auth error
          final isAuthError = _isAuthError(state.errorMessage!);
          
          if (isAuthError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.logIn,
                    size: 64,
                    color: AppColors.orbPurple.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Login Required',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Login to see leaderboards',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => AuthRequiredDialog.show(
                      context,
                      title: 'Login Required',
                      message: 'Please login to view leaderboards.',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orbPurple,
                    ),
                    child: const Text('Login'),
                  ),
                ],
              ),
            );
          }
          
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.alertCircle,
                  size: 48,
                  color: AppColors.accentError,
                ),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage!,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.read<LeaderboardCubit>().refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final entries = state.entries;
        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.trophy,
                  size: 64,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No entries yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to set a record!',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<LeaderboardCubit>().refresh(),
          color: AppColors.orbPurple,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length + 1, // +1 for podium
            itemBuilder: (context, index) {
              if (index == 0) {
                // Top 3 podium
                return _buildPodium(entries.take(3).toList());
              }
              final entry = entries[index - 1];
              if (entry.rank <= 3) return const SizedBox.shrink();
              return _LeaderboardTile(
                entry: entry,
                delay: (index * 50).ms,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPodium(List<LeaderboardEntryDTO> topThree) {
    if (topThree.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          if (topThree.length > 1)
            _PodiumItem(
              entry: topThree[1],
              height: 100,
              color: const Color(0xFFC0C0C0), // Silver
              delay: 200.ms,
            ),
          
          // 1st place
          if (topThree.isNotEmpty)
            _PodiumItem(
              entry: topThree[0],
              height: 130,
              color: const Color(0xFFFFD700), // Gold
              delay: 100.ms,
            ),
          
          // 3rd place
          if (topThree.length > 2)
            _PodiumItem(
              entry: topThree[2],
              height: 80,
              color: const Color(0xFFCD7F32), // Bronze
              delay: 300.ms,
            ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  bool _isAuthError(String error) {
    final lowerError = error.toLowerCase();
    return lowerError.contains('401') ||
        lowerError.contains('unauthorized') ||
        lowerError.contains('authentication') ||
        lowerError.contains('unauthenticated') ||
        lowerError.contains('login required');
  }
}

class _ModeChip extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.name,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected
              ? LinearGradient(
                  colors: [AppColors.orbPurple, AppColors.orbBlue],
                )
              : null,
          color: isSelected ? null : AppColors.glassBackground,
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.glassBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final LeaderboardEntryDTO entry;
  final double height;
  final Color color;
  final Duration delay;

  const _PodiumItem({
    required this.entry,
    required this.height,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                entry.displayName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Name
          Text(
            entry.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          
          // Score
          Text(
            '${entry.score}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          
          // Podium base
          Container(
            width: 80,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withOpacity(0.8),
                  color.withOpacity(0.3),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Text(
                '#${entry.rank}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay).slideY(begin: 0.3);
  }
}

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntryDTO entry;
  final Duration delay;

  const _LeaderboardTile({
    required this.entry,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: Text(
              '#${entry.rank}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.orbPurple.withOpacity(0.5),
                  AppColors.orbBlue.withOpacity(0.5),
                ],
              ),
            ),
            child: Center(
              child: Text(
                entry.displayName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  style: TextStyle(
                    color: entry.isCurrentUser
                        ? AppColors.orbPurple
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (entry.isCurrentUser)
                  Text(
                    'You',
                    style: TextStyle(
                      color: AppColors.orbPurple,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          
          // Score
          Text(
            '${entry.score}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay).slideX(begin: 0.1);
  }
}
