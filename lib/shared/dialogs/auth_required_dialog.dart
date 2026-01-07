/// Auth Required Dialog for Echo Memory
/// Shows when user needs to login for protected features

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../config/theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/neon_button.dart';

class AuthRequiredDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onLogin;
  final VoidCallback? onRegister;
  final VoidCallback? onCancel;

  const AuthRequiredDialog({
    super.key,
    this.title = 'Login Required',
    this.message = 'You need to be logged in to access this feature.',
    this.onLogin,
    this.onRegister,
    this.onCancel,
  });

  static Future<void> show(
    BuildContext context, {
    String? title,
    String? message,
    VoidCallback? onLogin,
    VoidCallback? onRegister,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AuthRequiredDialog(
        title: title ?? 'Login Required',
        message: message ?? 'You need to be logged in to access this feature.',
        onLogin: onLogin ?? () => Navigator.pop(context),
        onRegister: onRegister ?? () => Navigator.pop(context),
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        borderRadius: 24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.orbPurple.withOpacity(0.3),
                    AppColors.orbBlue.withOpacity(0.2),
                  ],
                ),
              ),
              child: const Icon(
                LucideIcons.logIn,
                color: AppColors.orbPurple,
                size: 32,
              ),
            ).animate().scale(delay: 100.ms),

            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Message
            Text(
              message,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                // Login button
                Expanded(
                  child: NeonButton(
                    text: 'Login',
                    color: AppColors.orbPurple,
                    onPressed: onLogin,
                    height: 44,
                  ),
                ),

                const SizedBox(width: 12),

                // Register button
                Expanded(
                  child: NeonButton(
                    text: 'Register',
                    color: AppColors.orbBlue,
                    onPressed: onRegister,
                    height: 44,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Cancel button
            TextButton(
              onPressed: onCancel ?? () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }
}

/// Extension to easily check for auth errors and show dialog
extension AuthErrorHandler on BuildContext {
  /// Shows auth required dialog if the error is an auth error
  bool handleAuthError(dynamic error, {String? customMessage}) {
    if (error.toString().contains('401') ||
        error.toString().toLowerCase().contains('unauthorized') ||
        error.toString().toLowerCase().contains('authentication')) {
      AuthRequiredDialog.show(
        this,
        title: 'Session Expired',
        message: customMessage ??
            'Your session has expired. Please login again to continue.',
      );
      return true;
    }
    return false;
  }
}
