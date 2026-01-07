/// Service Locator for Echo Memory
/// GetIt dependency injection configuration

import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../network/api_client.dart';
import '../../data/api/auth_api_service.dart';
import '../../data/api/economy_api_service.dart';
import '../../data/api/game_api_service.dart';
import '../../data/api/leaderboard_api_service.dart';
import '../../data/api/daily_challenge_api_service.dart';
import '../../data/api/shop_api_service.dart';
import '../../data/api/iap_api_service.dart';
import '../../data/api/sync_api_service.dart';
import '../../data/api/config_api_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/economy_repository.dart';
import '../../data/repositories/game_repository.dart';
import '../../data/repositories/leaderboard_repository.dart';
import '../../data/repositories/daily_challenge_repository.dart';
import '../../data/repositories/shop_repository.dart';
import '../../data/repositories/sync_repository.dart';
import '../services/storage_service.dart';

final getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> setupServiceLocator() async {
  // ============ Core Services ============
  
  // API Client (singleton)
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  // Google Sign-In
  getIt.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(scopes: ['email', 'profile']),
  );

  // Storage Service (singleton)
  getIt.registerLazySingleton<StorageService>(() => StorageService());

  // ============ API Services ============
  
  getIt.registerLazySingleton<AuthApiService>(
    () => AuthApiService(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<EconomyApiService>(
    () => EconomyApiService(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<GameApiService>(
    () => GameApiService(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<LeaderboardApiService>(
    () => LeaderboardApiService(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<DailyChallengeApiService>(
    () => DailyChallengeApiService(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<ShopApiService>(
    () => ShopApiService(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<IapApiService>(
    () => IapApiService(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<SyncApiService>(
    () => SyncApiService(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<ConfigApiService>(
    () => ConfigApiService(apiClient: getIt<ApiClient>()),
  );

  // ============ Repositories ============
  
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      authApiService: getIt<AuthApiService>(),
      apiClient: getIt<ApiClient>(),
      googleSignIn: getIt<GoogleSignIn>(),
    ),
  );

  getIt.registerLazySingleton<EconomyRepository>(
    () => EconomyRepository(economyApiService: getIt<EconomyApiService>()),
  );

  getIt.registerLazySingleton<GameRepository>(
    () => GameRepository(gameApiService: getIt<GameApiService>()),
  );

  getIt.registerLazySingleton<LeaderboardRepository>(
    () => LeaderboardRepository(
      leaderboardApiService: getIt<LeaderboardApiService>(),
    ),
  );

  getIt.registerLazySingleton<DailyChallengeRepository>(
    () => DailyChallengeRepository(
      dailyChallengeApiService: getIt<DailyChallengeApiService>(),
    ),
  );

  getIt.registerLazySingleton<ShopRepository>(
    () => ShopRepository(shopApiService: getIt<ShopApiService>()),
  );

  getIt.registerLazySingleton<SyncRepository>(
    () => SyncRepository(syncApiService: getIt<SyncApiService>()),
  );
}

/// Reset all dependencies (useful for testing or logout)
Future<void> resetServiceLocator() async {
  await getIt.reset();
  await setupServiceLocator();
}
