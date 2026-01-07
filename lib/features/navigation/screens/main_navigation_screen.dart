/// Main Navigation Screen for Echo Memory
/// Floating bottom tab navigation

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../config/theme/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../home/screens/home_screen.dart';
import '../../leaderboard/screens/leaderboard_screen.dart';
import '../../shop/screens/shop_screen.dart';
import '../../settings/screens/settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  final List<_NavItem> _navItems = [
    _NavItem(
      icon: LucideIcons.home,
      activeIcon: LucideIcons.home,
      label: 'Home',
    ),
    _NavItem(
      icon: LucideIcons.trophy,
      activeIcon: LucideIcons.trophy,
      label: 'Leaderboard',
    ),
    _NavItem(
      icon: LucideIcons.shoppingBag,
      activeIcon: LucideIcons.shoppingBag,
      label: 'Shop',
    ),
    _NavItem(
      icon: LucideIcons.settings,
      activeIcon: LucideIcons.settings,
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page content
          IndexedStack(
            index: _currentIndex,
            children: const [
              HomeContentScreen(),
              LeaderboardScreen(),
              ShopScreen(),
              SettingsScreen(),
            ],
          ),
          
          // Floating bottom navigation
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: _buildFloatingNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNavBar() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      borderRadius: 28,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_navItems.length, (index) {
          final item = _navItems[index];
          final isActive = _currentIndex == index;
          
          return _NavBarItem(
            icon: isActive ? item.activeIcon : item.icon,
            label: item.label,
            isActive: isActive,
            onTap: () => setState(() => _currentIndex = index),
          );
        }),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5, end: 0);
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isActive
              ? LinearGradient(
                  colors: [
                    AppColors.orbPurple.withOpacity(0.3),
                    AppColors.orbBlue.withOpacity(0.2),
                  ],
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? AppColors.orbPurple : AppColors.textSecondary,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.orbPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Home content without the bottom actions (now in nav bar)
class HomeContentScreen extends StatefulWidget {
  const HomeContentScreen({super.key});

  @override
  State<HomeContentScreen> createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> {
  @override
  Widget build(BuildContext context) {
    // We'll use the actual HomeScreen content here
    return const HomeScreen();
  }
}
