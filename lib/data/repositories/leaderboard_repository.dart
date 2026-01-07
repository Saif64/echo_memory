/// Leaderboard Repository for Echo Memory
/// Caches and fetches leaderboard data

import '../api/leaderboard_api_service.dart';
import '../dto/leaderboard_dto.dart';
import '../../core/network/api_exceptions.dart';

class LeaderboardRepository {
  final LeaderboardApiService _leaderboardApiService;

  // Cache for leaderboards
  final Map<String, LeaderboardDTO> _allTimeCache = {};
  final Map<String, LeaderboardDTO> _weeklyCache = {};
  UserRanksDTO? _userRanks;
  DateTime? _lastFetchTime;

  // Cache duration
  static const cacheDuration = Duration(minutes: 5);

  LeaderboardRepository({LeaderboardApiService? leaderboardApiService})
      : _leaderboardApiService =
            leaderboardApiService ?? LeaderboardApiService();

  /// Get all-time leaderboard for a mode
  Future<LeaderboardDTO> getAllTime(String mode, {bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid() && _allTimeCache.containsKey(mode)) {
      return _allTimeCache[mode]!;
    }

    final response = await _leaderboardApiService.getAllTime(mode);

    if (!response.success || response.data == null) {
      throw ServerException(
        message: response.message ?? 'Failed to fetch leaderboard',
        errorCode: response.error,
      );
    }

    _allTimeCache[mode] = response.data!;
    _lastFetchTime = DateTime.now();
    return response.data!;
  }

  /// Get weekly leaderboard for a mode
  Future<LeaderboardDTO> getWeekly(String mode, {bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid() && _weeklyCache.containsKey(mode)) {
      return _weeklyCache[mode]!;
    }

    final response = await _leaderboardApiService.getWeekly(mode);

    if (!response.success || response.data == null) {
      throw ServerException(
        message: response.message ?? 'Failed to fetch leaderboard',
        errorCode: response.error,
      );
    }

    _weeklyCache[mode] = response.data!;
    _lastFetchTime = DateTime.now();
    return response.data!;
  }

  /// Get current user's ranks
  Future<UserRanksDTO> getUserRanks({bool forceRefresh = false}) async {
    if (!forceRefresh && _isCacheValid() && _userRanks != null) {
      return _userRanks!;
    }

    final response = await _leaderboardApiService.getUserRanks();

    if (!response.success || response.data == null) {
      throw ServerException(
        message: response.message ?? 'Failed to fetch user ranks',
        errorCode: response.error,
      );
    }

    _userRanks = response.data!;
    _lastFetchTime = DateTime.now();
    return response.data!;
  }

  /// Check if cache is still valid
  bool _isCacheValid() {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < cacheDuration;
  }

  /// Clear all cached data
  void clearCache() {
    _allTimeCache.clear();
    _weeklyCache.clear();
    _userRanks = null;
    _lastFetchTime = null;
  }

  /// Get cached all-time leaderboard if available
  LeaderboardDTO? getCachedAllTime(String mode) => _allTimeCache[mode];

  /// Get cached weekly leaderboard if available
  LeaderboardDTO? getCachedWeekly(String mode) => _weeklyCache[mode];

  /// Get cached user ranks if available
  UserRanksDTO? get cachedUserRanks => _userRanks;
}
