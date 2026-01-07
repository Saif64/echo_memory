/// API Configuration constants for Echo Memory
/// Endpoints, timeouts, and headers

class ApiConfig {
  ApiConfig._();

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Headers
  static const String contentType = 'application/json';
  static const String acceptHeader = 'application/json';

  // Auth
  static const String authorizationHeader = 'Authorization';
  static const String bearerPrefix = 'Bearer ';

  // API Endpoints
  static const String auth = '/auth';
  static const String authGuest = '$auth/guest';
  static const String authGoogle = '$auth/google';
  static const String authRegister = '$auth/register';
  static const String authLogin = '$auth/login';
  static const String authLink = '$auth/link';
  static const String authRefresh = '$auth/refresh';

  static const String economy = '/economy';
  static const String economyState = '$economy/state';
  static const String economyUseLife = '$economy/use-life';
  static const String economyBuyLives = '$economy/buy-lives';
  static const String economyClaimDaily = '$economy/claim-daily';

  static const String game = '/game';
  static const String gameStart = '$game/start';
  static const String gameEnd = '$game/end';

  static const String leaderboard = '/leaderboard';
  static String leaderboardMode(String mode) => '$leaderboard/$mode';
  static String leaderboardWeekly(String mode) => '$leaderboard/$mode/weekly';
  static const String leaderboardMe = '$leaderboard/me';

  static const String daily = '/daily';
  static const String dailyToday = '$daily/today';
  static const String dailyComplete = '$daily/complete';
  static const String dailyStreak = '$daily/streak';

  static const String sync = '/sync';
  static const String syncPull = '$sync/pull';
  static const String syncPush = '$sync/push';

  static const String shop = '/shop';
  static const String shopItems = '$shop/items';
  static const String shopBuy = '$shop/buy';
  static const String shopOpenChest = '$shop/open-chest';

  static const String iap = '/iap';
  static const String iapVerify = '$iap/verify';
  static const String iapProducts = '$iap/products';

  static const String config = '/config';
}
