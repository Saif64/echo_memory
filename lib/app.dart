/// Echo Memory - App Configuration
/// Main app widget with theme, routing, and bloc providers

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/theme/app_theme.dart';
import 'core/di/service_locator.dart';
import 'core/network/environment_config.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/economy_repository.dart';
import 'data/repositories/leaderboard_repository.dart';
import 'data/repositories/shop_repository.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/cubit/auth_state.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/economy/cubit/economy_cubit.dart';
import 'features/navigation/screens/main_navigation_screen.dart';
import 'features/leaderboard/cubit/leaderboard_cubit.dart';
import 'features/shop/cubit/shop_cubit.dart';

class EchoMemoryApp extends StatelessWidget {
  const EchoMemoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(
            authRepository: getIt<AuthRepository>(),
          )..checkAuthStatus(),
        ),
        BlocProvider<EconomyCubit>(
          create: (_) => EconomyCubit(
            economyRepository: getIt<EconomyRepository>(),
          ),
        ),
        BlocProvider<LeaderboardCubit>(
          create: (_) => LeaderboardCubit(
            leaderboardRepository: getIt<LeaderboardRepository>(),
          ),
        ),
        BlocProvider<ShopCubit>(
          create: (_) => ShopCubit(
            shopRepository: getIt<ShopRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Echo Memory',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            // Show loading indicator while checking auth
            if (state.status == AuthStatus.initial ||
                state.status == AuthStatus.loading) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Show main navigation if authenticated
            if (state.isAuthenticated) {
              // Only fetch economy state for non-guest users
              // Guest users will get 401 prompts when using shop/protected features
              if (state.user?.isGuest != true) {
                context.read<EconomyCubit>().fetchState();
              }
              return const MainNavigationScreen();
            }

            // Show login screen if not authenticated
            return const LoginScreen();
          },
        ),
        builder: (context, child) {
          // Show environment banner in debug/staging mode
          if (EnvironmentConfig.isStaging) {
            return Banner(
              message: 'STAGING',
              location: BannerLocation.topEnd,
              color: Colors.orange,
              child: child ?? const SizedBox(),
            );
          }
          return child ?? const SizedBox();
        },
      ),
    );
  }
}
