/// Game Session Data Transfer Objects for Echo Memory
/// Models for game start/end and session tracking

import 'package:equatable/equatable.dart';

/// Start game request
class StartGameRequest {
  final String gameMode;
  final String? difficulty;

  const StartGameRequest({required this.gameMode, this.difficulty});

  Map<String, dynamic> toJson() => {
        'gameMode': gameMode,
        if (difficulty != null) 'difficulty': difficulty,
      };
}

/// Start game response
class StartGameResponseDTO extends Equatable {
  final String sessionId;
  final int livesRemaining;
  final Map<String, dynamic>? gameConfig;

  const StartGameResponseDTO({
    required this.sessionId,
    required this.livesRemaining,
    this.gameConfig,
  });

  factory StartGameResponseDTO.fromJson(Map<String, dynamic> json) {
    return StartGameResponseDTO(
      sessionId: json['sessionId'] ?? '',
      livesRemaining: json['livesRemaining'] ?? 0,
      gameConfig: json['gameConfig'],
    );
  }

  @override
  List<Object?> get props => [sessionId, livesRemaining, gameConfig];
}

/// End game request
class EndGameRequest {
  final String gameMode;
  final int score;
  final int level;
  final int streak;
  final int durationSeconds;
  final List<String> powerUpsUsed;

  const EndGameRequest({
    required this.gameMode,
    required this.score,
    required this.level,
    required this.streak,
    required this.durationSeconds,
    this.powerUpsUsed = const [],
  });

  Map<String, dynamic> toJson() => {
        'gameMode': gameMode,
        'score': score,
        'level': level,
        'streak': streak,
        'durationSeconds': durationSeconds,
        'powerUpsUsed': powerUpsUsed,
      };
}

/// End game response
class EndGameResponseDTO extends Equatable {
  final int coinsEarned;
  final int gemsEarned;
  final int newHighScore;
  final int? leaderboardRank;
  final List<String> unlockedAchievements;
  final bool isNewRecord;

  const EndGameResponseDTO({
    required this.coinsEarned,
    required this.gemsEarned,
    required this.newHighScore,
    this.leaderboardRank,
    this.unlockedAchievements = const [],
    this.isNewRecord = false,
  });

  factory EndGameResponseDTO.fromJson(Map<String, dynamic> json) {
    return EndGameResponseDTO(
      coinsEarned: json['coinsEarned'] ?? 0,
      gemsEarned: json['gemsEarned'] ?? 0,
      newHighScore: json['newHighScore'] ?? 0,
      leaderboardRank: json['leaderboardRank'],
      unlockedAchievements: List<String>.from(json['unlockedAchievements'] ?? []),
      isNewRecord: json['isNewRecord'] ?? false,
    );
  }

  @override
  List<Object?> get props => [
        coinsEarned,
        gemsEarned,
        newHighScore,
        leaderboardRank,
        unlockedAchievements,
        isNewRecord,
      ];
}
