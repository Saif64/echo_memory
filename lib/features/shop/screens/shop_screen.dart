/// Shop Screen for Echo Memory
/// Premium in-game shop with category tabs

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../config/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_button.dart';
import '../../../shared/dialogs/auth_required_dialog.dart';
import '../../../data/dto/shop_dto.dart';
import '../../economy/cubit/economy_cubit.dart';
import '../../economy/cubit/economy_state.dart';
import '../cubit/shop_cubit.dart';
import '../cubit/shop_state.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _categories = [
    {'type': ShopItemType.lives, 'name': 'Lives', 'icon': LucideIcons.heart},
    {'type': ShopItemType.gems, 'name': 'Gems', 'icon': LucideIcons.gem},
    {'type': ShopItemType.chest, 'name': 'Chests', 'icon': LucideIcons.box},
    {'type': ShopItemType.theme, 'name': 'Themes', 'icon': LucideIcons.palette},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    
    // Load shop items
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShopCubit>().loadItems();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                // Header with economy bar
                _buildHeader(),

                // Tab bar
                _buildTabBar(),

                // Shop items
                Expanded(
                  child: _buildShopContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            'Shop',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          
          // Economy display (compact)
          BlocBuilder<EconomyCubit, EconomyState>(
            builder: (context, state) {
              return Row(
                children: [
                  _CurrencyBadge(
                    icon: LucideIcons.coins,
                    color: AppColors.orbYellow,
                    value: state.coins,
                  ),
                  const SizedBox(width: 12),
                  _CurrencyBadge(
                    icon: LucideIcons.gem,
                    color: AppColors.orbPurple,
                    value: state.gems,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildTabBar() {
    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
        tabs: _categories.map((cat) {
          return Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(cat['icon'] as IconData, size: 16),
                const SizedBox(width: 4),
                Text(cat['name'] as String),
              ],
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildShopContent() {
    return BlocConsumer<ShopCubit, ShopState>(
      listener: (context, state) {
        if (state.lastPurchase != null) {
          _showPurchaseSuccessDialog(state.lastPurchase!);
          context.read<ShopCubit>().clearLastPurchase();
          // Refresh economy state
          context.read<EconomyCubit>().fetchState();
        }
        if (state.lastChestReward != null) {
          _showChestRewardDialog(state.lastChestReward!);
          context.read<ShopCubit>().clearLastChestReward();
          // Refresh economy state
          context.read<EconomyCubit>().fetchState();
        }
        if (state.errorMessage != null) {
          // Check if it's an auth error (401/unauthorized)
          if (_isAuthError(state.errorMessage!)) {
            AuthRequiredDialog.show(
              context,
              title: 'Login Required',
              message: 'Please login or create an account to access the shop.',
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.accentError,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          context.read<ShopCubit>().clearError();
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.orbPurple),
            ),
          );
        }

        return TabBarView(
          controller: _tabController,
          children: _categories.map((cat) {
            final items = state.getItemsByType(cat['type'] as ShopItemType);
            return _buildItemGrid(items, state);
          }).toList(),
        );
      },
    );
  }

  Widget _buildItemGrid(List<ShopItemDTO> items, ShopState state) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.packageOpen,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Coming Soon',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _ShopItemCard(
          item: item,
          isPurchasing: state.purchasingItemId == item.id,
          onPurchase: () => _purchaseItem(item),
          delay: (index * 100).ms,
        );
      },
    );
  }

  void _purchaseItem(ShopItemDTO item) {
    if (item.type == ShopItemType.chest) {
      context.read<ShopCubit>().openChest(item.id);
    } else {
      context.read<ShopCubit>().purchase(item.id);
    }
  }

  bool _isAuthError(String error) {
    final lowerError = error.toLowerCase();
    return lowerError.contains('401') ||
        lowerError.contains('unauthorized') ||
        lowerError.contains('authentication') ||
        lowerError.contains('unauthenticated') ||
        lowerError.contains('login required');
  }

  void _showPurchaseSuccessDialog(PurchaseResponseDTO result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(LucideIcons.checkCircle, color: AppColors.orbGreen),
            const SizedBox(width: 12),
            const Text('Purchase Successful!'),
          ],
        ),
        content: const Text('Your item has been added to your account.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showChestRewardDialog(ChestRewardDTO reward) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🎉 Chest Opened!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              
              // Show rewards
              ...reward.rewards.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _getRewardIcon(r),
                    const SizedBox(width: 12),
                    Text(
                      '${r.name ?? r.type} x${r.quantity}',
                      style: TextStyle(
                        color: _getRarityColor(r.rarity),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )),

              const SizedBox(height: 16),
              NeonButton(
                text: 'Awesome!',
                color: AppColors.orbPurple,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ).animate().scale(begin: const Offset(0.8, 0.8)).fadeIn(),
    );
  }

  Widget _getRewardIcon(RewardItemDTO reward) {
    final IconData icon;
    final Color color;

    switch (reward.type) {
      case 'coins':
        icon = LucideIcons.coins;
        color = AppColors.orbYellow;
        break;
      case 'gems':
        icon = LucideIcons.gem;
        color = AppColors.orbPurple;
        break;
      case 'theme':
        icon = LucideIcons.palette;
        color = AppColors.orbBlue;
        break;
      default:
        icon = LucideIcons.gift;
        color = AppColors.orbGreen;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.2),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'legendary':
        return const Color(0xFFFFD700); // Gold
      case 'epic':
        return AppColors.orbPurple;
      case 'rare':
        return AppColors.orbBlue;
      default:
        return AppColors.textPrimary;
    }
  }
}

class _CurrencyBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int value;

  const _CurrencyBadge({
    required this.icon,
    required this.color,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            _formatNumber(value),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }
}

class _ShopItemCard extends StatelessWidget {
  final ShopItemDTO item;
  final bool isPurchasing;
  final VoidCallback onPurchase;
  final Duration delay;

  const _ShopItemCard({
    required this.item,
    required this.isPurchasing,
    required this.onPurchase,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Badges
                Row(
                  children: [
                    if (item.isPopular)
                      _Badge(text: 'Popular', color: AppColors.orbRed),
                    if (item.isBestValue)
                      _Badge(text: 'Best Value', color: AppColors.orbGreen),
                  ],
                ),

                const Spacer(),

                // Icon
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          _getItemColor().withOpacity(0.3),
                          _getItemColor().withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Icon(
                      _getItemIcon(),
                      size: 30,
                      color: _getItemColor(),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Name
                Text(
                  item.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Quantity info
                if (item.quantity != null)
                  Text(
                    'x${item.quantity}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),

                const Spacer(),

                // Price button
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: isPurchasing ? null : onPurchase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getCurrencyColor(),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: isPurchasing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_getCurrencyIcon(), size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${item.price}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),

          // Discount badge
          if (item.discountPercent != null)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentError,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Text(
                  '-${item.discountPercent!.toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: delay).scale(
          begin: const Offset(0.9, 0.9),
          delay: delay,
        );
  }

  IconData _getItemIcon() {
    switch (item.type) {
      case ShopItemType.lives:
        return LucideIcons.heart;
      case ShopItemType.gems:
        return LucideIcons.gem;
      case ShopItemType.coins:
        return LucideIcons.coins;
      case ShopItemType.chest:
        return LucideIcons.box;
      case ShopItemType.theme:
        return LucideIcons.palette;
      case ShopItemType.powerUp:
        return LucideIcons.zap;
      case ShopItemType.bundle:
        return LucideIcons.gift;
    }
  }

  Color _getItemColor() {
    switch (item.type) {
      case ShopItemType.lives:
        return AppColors.orbRed;
      case ShopItemType.gems:
        return AppColors.orbPurple;
      case ShopItemType.coins:
        return AppColors.orbYellow;
      case ShopItemType.chest:
        return AppColors.orbBlue;
      case ShopItemType.theme:
        return AppColors.orbGreen;
      case ShopItemType.powerUp:
        return Colors.orange;
      case ShopItemType.bundle:
        return const Color(0xFFFFD700);
    }
  }

  IconData _getCurrencyIcon() {
    switch (item.currency) {
      case 'coins':
        return LucideIcons.coins;
      case 'gems':
        return LucideIcons.gem;
      default:
        return LucideIcons.dollarSign;
    }
  }

  Color _getCurrencyColor() {
    switch (item.currency) {
      case 'coins':
        return AppColors.orbYellow.withOpacity(0.8);
      case 'gems':
        return AppColors.orbPurple;
      default:
        return AppColors.orbGreen;
    }
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
