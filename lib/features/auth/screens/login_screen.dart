/// Login Screen for Echo Memory
/// Premium login UI with guest, Google, and email options

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../config/theme/app_colors.dart';
import '../../../shared/widgets/animated_gradient.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/neon_button.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showEmailLogin = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.accentError,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<AuthCubit>().clearError();
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              // Animated gradient background
              const AnimatedGradientBackground(child: SizedBox.expand()),

              // Content
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),

                      // Logo and title
                      _buildHeader().animate().fadeIn(duration: 600.ms).slideY(
                            begin: -0.3,
                            end: 0,
                            curve: Curves.easeOutCubic,
                          ),

                      const SizedBox(height: 60),

                      // Login options
                      _buildLoginOptions(state),

                      const SizedBox(height: 40),

                      // Footer
                      _buildFooter(),
                    ],
                  ),
                ),
              ),

              // Loading overlay
              if (state.isLoading)
                Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.orbPurple),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App icon with glow
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.orbPurple.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
          child: Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.orbPurple,
                    AppColors.orbBlue,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orbPurple.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                LucideIcons.brain,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Title
        Text(
          'Echo Memory',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
        ),

        const SizedBox(height: 8),

        Text(
          'Train Your Brain',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 4,
              ),
        ),
      ],
    );
  }

  Widget _buildLoginOptions(AuthState state) {
    return Column(
      children: [
        // Guest Login Button
        NeonButton(
          text: 'Play as Guest',
          icon: LucideIcons.user,
          color: AppColors.orbGreen,
          onPressed: () => _guestLogin(context),
        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),

        const SizedBox(height: 16),

        // Google Sign-In Button
        NeonButton(
          text: 'Continue with Google',
          icon: LucideIcons.chrome,
          color: AppColors.orbBlue,
          onPressed: () => _googleLogin(context),
        ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.2),

        const SizedBox(height: 24),

        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.textSecondary.withOpacity(0.3))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            Expanded(child: Divider(color: AppColors.textSecondary.withOpacity(0.3))),
          ],
        ).animate().fadeIn(delay: 400.ms),

        const SizedBox(height: 24),

        // Email login toggle
        if (!_showEmailLogin)
          TextButton(
            onPressed: () => setState(() => _showEmailLogin = true),
            child: Text(
              'Sign in with Email',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ).animate().fadeIn(delay: 500.ms)
        else
          _buildEmailLoginForm(),
      ],
    );
  }

  Widget _buildEmailLoginForm() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                prefixIcon: Icon(LucideIcons.mail, color: AppColors.textSecondary),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.orbPurple),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.accentError),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.accentError),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Password field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: AppColors.textSecondary),
                prefixIcon: Icon(LucideIcons.lock, color: AppColors.textSecondary),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.orbPurple),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.accentError),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.accentError),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Sign in button
            NeonButton(
              text: 'Sign In',
              color: AppColors.orbPurple,
              onPressed: () => _emailLogin(context),
            ),

            const SizedBox(height: 16),

            // Register link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                TextButton(
                  onPressed: () => _navigateToRegister(context),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: AppColors.orbPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            // Back to options
            TextButton(
              onPressed: () => setState(() => _showEmailLogin = false),
              child: Text(
                'Back to login options',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'By continuing, you agree to our',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // TODO: Open Terms of Service
              },
              child: Text(
                'Terms of Service',
                style: TextStyle(
                  color: AppColors.orbPurple,
                  fontSize: 12,
                ),
              ),
            ),
            Text(
              ' and ',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Open Privacy Policy
              },
              child: Text(
                'Privacy Policy',
                style: TextStyle(
                  color: AppColors.orbPurple,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }

  void _guestLogin(BuildContext context) {
    context.read<AuthCubit>().guestLogin();
  }

  void _googleLogin(BuildContext context) {
    context.read<AuthCubit>().googleLogin();
  }

  void _emailLogin(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  void _navigateToRegister(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }
}
