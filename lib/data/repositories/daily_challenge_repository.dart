/// Daily Challenge Repository for Echo Memory
/// Manages daily challenge state and streaks

import '../api/daily_challenge_api_service.dart';
import '../dto/daily_challenge_dto.dart';
import '../../core/network/api_exceptions.dart';

class DailyChallengeRepository {
  final DailyChallengeApiService _dailyChallengeApiService;

  DailyChallengeDTO? _todayChallenge;
  StreakInfoDTO? _streakInfo;
  DateTime? _lastFetchDate;

  DailyChallengeRepository({DailyChallengeApiService? dailyChallengeApiService})
      : _dailyChallengeApiService =
            dailyChallengeApiService ?? DailyChallengeApiService();

  /// Get today's cached challenge
  DailyChallengeDTO? get todayChallenge => _todayChallenge;

  /// Get cached streak info
  StreakInfoDTO? get streakInfo => _streakInfo ?? _todayChallenge?.streakInfo;

  /// Fetch today's challenge
  Future<DailyChallengeDTO> fetchTodayChallenge({bool forceRefresh = false}) async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Use cache if same day and not forcing refresh
    if (!forceRefresh &&
        _todayChallenge != null &&
        _lastFetchDate != null &&
        _lastFetchDate!.year == todayDate.year &&
        _lastFetchDate!.month == todayDate.month &&
        _lastFetchDate!.day == todayDate.day) {
      return _todayChallenge!;
    }

    final response = await _dailyChallengeApiService.getToday();

    if (!response.success || response.data == null) {
      throw ServerException(
        message: response.message ?? 'Failed to fetch daily challenge',
        errorCode: response.error,
      );
    }

    _todayChallenge = response.data!;
    _streakInfo = response.data!.streakInfo;
    _lastFetchDate = todayDate;
    return _todayChallenge!;
  }

  /// Submit challenge completion
  Future<CompleteChallengeResponseDTO> completeChallenge({
    required int score,
    required int durationSeconds,
    List<String> powerUpsUsed = const [],
  }) async {
    final response = await _dailyChallengeApiService.complete(
      score: score,
      durationSeconds: durationSeconds,
      powerUpsUsed: powerUpsUsed,
    );

    if (!response.success || response.data == null) {
      throw ServerException(
        message: response.message ?? 'Failed to submit challenge',
        errorCode: response.error,
      );
    }

    // Update cached data
    _streakInfo = response.data!.newStreakInfo;
    if (_todayChallenge != null) {
      _todayChallenge = DailyChallengeDTO(
        date: _todayChallenge!.date,
        gameMode: _todayChallenge!.gameMode,
        config: _todayChallenge!.config,
        targetScore: _todayChallenge!.targetScore,
        completed: true,
        userBestScore: score > _todayChallenge!.userBestScore
            ? score
            : _todayChallenge!.userBestScore,
        streakInfo: response.data!.newStreakInfo,
        rewards: _todayChallenge!.rewards,
      );
    }

    return response.data!;
  }

  /// Fetch current streak info
  Future<StreakInfoDTO> fetchStreak() async {
    final response = await _dailyChallengeApiService.getStreak();

    if (!response.success || response.data == null) {
      throw ServerException(
        message: response.message ?? 'Failed to fetch streak info',
        errorCode: response.error,
      );
    }

    _streakInfo = response.data!;
    return response.data!;
  }

  /// Check if today's challenge is completed
  bool get isTodayCompleted => _todayChallenge?.completed ?? false;

  /// Get current streak count
  int get currentStreak => _streakInfo?.currentStreak ?? 0;

  /// Get longest streak
  int get longestStreak => _streakInfo?.longestStreak ?? 0;

  /// Clear cached data
  void clearCache() {
    _todayChallenge = null;
    _streakInfo = null;
    _lastFetchDate = null;
  }
}
