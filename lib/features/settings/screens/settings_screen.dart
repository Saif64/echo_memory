/// Settings screen for Echo Memory
/// Game configuration and preferences
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_text_styles.dart';
import '../../../core/services/sound_service.dart';
import '../../../core/services/haptic_service.dart';
import '../../../shared/widgets/animated_gradient.dart';
import '../../../shared/widgets/glass_container.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SoundService _soundService = SoundService();
  final HapticService _hapticService = HapticService();

  bool _soundEnabled = true;
  bool _hapticEnabled = true;
  String _selectedTheme = 'aurora';
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _soundEnabled = _soundService.isEnabled;
    _hapticEnabled = _hapticService.isEnabled;
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _appVersion = packageInfo.version);
    }
  }

  Future<void> _launchPrivacyPolicy() async {
    final uri = Uri.parse('https://echo-memory-one.vercel.app/privacy-policy.html');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchRateApp() async {
    final String url;
    if (Platform.isAndroid) {
      url = 'https://play.google.com/store/apps/details?id=com.pixel.peak.second';
    } else if (Platform.isIOS) {
      // Update with your actual App Store ID when available
      url = 'https://apps.apple.com/app/echo-memory/id6740020285';
    } else {
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameGradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection('Sound & Haptics', [
                          _buildSwitchTile(
                            title: 'Sound Effects',
                            subtitle: 'Game sounds and music',
                            icon: LucideIcons.volume2,
                            value: _soundEnabled,
                            onChanged: (value) {
                              setState(() => _soundEnabled = value);
                              _soundService.toggleSound(value);
                            },
                          ),
                          _buildSwitchTile(
                            title: 'Haptic Feedback',
                            subtitle: 'Vibration on interactions',
                            icon: LucideIcons.smartphone,
                            value: _hapticEnabled,
                            onChanged: (value) {
                              setState(() => _hapticEnabled = value);
                              _hapticService.toggleHaptics(value);
                            },
                          ),
                        ]),
                        const SizedBox(height: 24),
                        _buildSection('Theme', [
                          _buildThemeSelector(),
                        ]),
                        const SizedBox(height: 24),
                        _buildSection('About', [
                          _buildInfoTile(
                            title: 'Version',
                            value: _appVersion.isEmpty ? '...' : _appVersion,
                            icon: LucideIcons.info,
                          ),
                          _buildActionTile(
                            title: 'Privacy Policy',
                            icon: LucideIcons.shieldCheck,
                            onTap: _launchPrivacyPolicy,
                          ),
                          _buildActionTile(
                            title: 'Rate App',
                            icon: LucideIcons.star,
                            onTap: _launchRateApp,
                          ),
                        ]),
                      ],
                    ),
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
    return Row(
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(10),
          borderRadius: 12,
          onTap: () => Navigator.pop(context),
          child: const Icon(
            LucideIcons.arrowLeft,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Settings',
          style: AppTextStyles.headlineMedium,
        ),
      ],
    ).animate().fadeIn().slideX(begin: -0.2, end: 0);
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 1.5,
            ),
          ),
        ),
        GlassContainer(
          padding: EdgeInsets.zero,
          child: Column(
            children: List.generate(children.length, (index) {
              return Column(
                children: [
                  children[index],
                  if (index < children.length - 1)
                    Divider(
                      color: AppColors.glassBorder,
                      height: 1,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    ).animate().fadeIn(delay: (100 * children.length).ms);
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.orbBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.orbBlue, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleSmall),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.orbGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.textMuted, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: AppTextStyles.titleSmall)),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.textMuted, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: AppTextStyles.titleSmall)),
            const Icon(
              LucideIcons.chevronRight,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    final themes = [
      ('aurora', 'Aurora', AppColors.auroraGradient),
      ('neon', 'Neon', AppColors.themeGradients['neon']!),
      ('ocean', 'Ocean', AppColors.themeGradients['ocean']!),
      ('space', 'Space', AppColors.themeGradients['space']!),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: themes.map((theme) {
          final isSelected = _selectedTheme == theme.$1;
          return GestureDetector(
            onTap: () => setState(() => _selectedTheme = theme.$1),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(colors: theme.$3),
                border: isSelected
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.$3.first.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSelected)
                    const Icon(LucideIcons.check,
                        color: Colors.white, size: 24)
                  else
                    Text(
                      theme.$2,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
