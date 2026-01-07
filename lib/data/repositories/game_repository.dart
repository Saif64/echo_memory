/// Game Repository for Echo Memory
/// Coordinates game sessions with backend

import '../api/game_api_service.dart';
import '../dto/game_dto.dart';
import '../../core/network/api_exceptions.dart';

class GameRepository {
  final GameApiService _gameApiService;

  String? _currentSessionId;
  DateTime? _sessionStartTime;
  String? _currentGameMode;

  GameRepository({GameApiService? gameApiService})
      : _gameApiService = gameApiService ?? GameApiService();

  /// Get current session ID
  String? get currentSessionId => _currentSessionId;

  /// Check if there's an active session
  bool get hasActiveSession => _currentSessionId != null;

  /// Start a new game session
  Future<StartGameResponseDTO> startGame({
    required String gameMode,
    String? difficulty,
  }) async {
    final response = await _gameApiService.startGame(
      gameMode: gameMode,
      difficulty: difficulty,
    );

    if (!response.success || response.data == null) {
      if (response.error == 'NO_LIVES') {
        throw const NoLivesException();
      }
      throw ServerException(
        message: response.message ?? 'Failed to start game',
        errorCode: response.error,
      );
    }

    _currentSessionId = response.data!.sessionId;
    _sessionStartTime = DateTime.now();
    _currentGameMode = gameMode;

    return response.data!;
  }

  /// End the current game session
  Future<EndGameResponseDTO> endGame({
    required int score,
    required int level,
    required int streak,
    List<String> powerUpsUsed = const [],
  }) async {
    if (_currentGameMode == null) {
      throw const ServerException(
        message: 'No active game session',
        errorCode: 'NO_SESSION',
      );
    }

    final duration = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!).inSeconds
        : 0;

    final response = await _gameApiService.endGame(
      gameMode: _currentGameMode!,
      score: score,
      level: level,
      streak: streak,
      durationSeconds: duration,
      powerUpsUsed: powerUpsUsed,
    );

    // Clear session data
    _currentSessionId = null;
    _sessionStartTime = null;
    _currentGameMode = null;

    if (!response.success || response.data == null) {
      throw ServerException(
        message: response.message ?? 'Failed to submit game results',
        errorCode: response.error,
      );
    }

    return response.data!;
  }

  /// Cancel current session (without submitting)
  void cancelSession() {
    _currentSessionId = null;
    _sessionStartTime = null;
    _currentGameMode = null;
  }

  /// Get session duration in seconds
  int get sessionDurationSeconds {
    if (_sessionStartTime == null) return 0;
    return DateTime.now().difference(_sessionStartTime!).inSeconds;
  }
}
