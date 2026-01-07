/// Sync Repository for Echo Memory
/// Cloud save operations

import '../api/sync_api_service.dart';
import '../dto/sync_dto.dart';
import '../../core/network/api_exceptions.dart';

class SyncRepository {
  final SyncApiService _syncApiService;

  SyncPullResponseDTO? _lastPulledData;
  DateTime? _lastSyncTime;

  SyncRepository({SyncApiService? syncApiService})
      : _syncApiService = syncApiService ?? SyncApiService();

  /// Get last synced time
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Get last pulled data
  SyncPullResponseDTO? get lastPulledData => _lastPulledData;

  /// Pull server state (download cloud save)
  Future<SyncPullResponseDTO> pull() async {
    final response = await _syncApiService.pull();

    if (!response.success || response.data == null) {
      throw ServerException(
        message: response.message ?? 'Failed to pull cloud data',
        errorCode: response.error,
      );
    }

    _lastPulledData = response.data!;
    _lastSyncTime = DateTime.now();
    return response.data!;
  }

  /// Push client state (upload to cloud)
  Future<SyncPushResponseDTO> push({
    required int totalGamesPlayed,
    required int totalScore,
    required int highScore,
    required int bestStreak,
    required int longestSequence,
    required int totalPlayTimeSeconds,
    required Map<String, int> modeHighScores,
  }) async {
    final response = await _syncApiService.push(
      totalGamesPlayed: totalGamesPlayed,
      totalScore: totalScore,
      highScore: highScore,
      bestStreak: bestStreak,
      longestSequence: longestSequence,
      totalPlayTimeSeconds: totalPlayTimeSeconds,
      modeHighScores: modeHighScores,
    );

    if (!response.success || response.data == null) {
      throw ServerException(
        message: response.message ?? 'Failed to push cloud data',
        errorCode: response.error,
      );
    }

    _lastSyncTime = response.data!.syncedAt;
    return response.data!;
  }

  /// Merge local and server data (take higher values)
  Map<String, dynamic> mergeData({
    required Map<String, dynamic> local,
    required SyncPullResponseDTO server,
  }) {
    return {
      'totalGamesPlayed': _max(
        local['totalGamesPlayed'] ?? 0,
        server.totalGamesPlayed,
      ),
      'totalScore': _max(
        local['totalScore'] ?? 0,
        server.totalScore,
      ),
      'highScore': _max(
        local['highScore'] ?? 0,
        server.highScore,
      ),
      'bestStreak': _max(
        local['bestStreak'] ?? 0,
        server.bestStreak,
      ),
      'longestSequence': _max(
        local['longestSequence'] ?? 0,
        server.longestSequence,
      ),
      'totalPlayTimeSeconds': _max(
        local['totalPlayTimeSeconds'] ?? 0,
        server.totalPlayTimeSeconds,
      ),
      'modeHighScores': _mergeHighScores(
        Map<String, int>.from(local['modeHighScores'] ?? {}),
        server.modeHighScores,
      ),
    };
  }

  int _max(int a, int b) => a > b ? a : b;

  Map<String, int> _mergeHighScores(
    Map<String, int> local,
    Map<String, int> server,
  ) {
    final merged = Map<String, int>.from(local);
    server.forEach((key, value) {
      merged[key] = _max(merged[key] ?? 0, value);
    });
    return merged;
  }
}
