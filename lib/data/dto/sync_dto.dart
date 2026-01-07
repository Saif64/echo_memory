/// Cloud Sync Data Transfer Objects for Echo Memory
/// Models for syncing player data with server

import 'package:equatable/equatable.dart';

/// Sync push request
class SyncPushRequest {
  final int totalGamesPlayed;
  final int totalScore;
  final int highScore;
  final int bestStreak;
  final int longestSequence;
  final int totalPlayTimeSeconds;
  final Map<String, int> modeHighScores;

  const SyncPushRequest({
    required this.totalGamesPlayed,
    required this.totalScore,
    required this.highScore,
    required this.bestStreak,
    required this.longestSequence,
    required this.totalPlayTimeSeconds,
    required this.modeHighScores,
  });

  Map<String, dynamic> toJson() => {
        'totalGamesPlayed': totalGamesPlayed,
        'totalScore': totalScore,
        'highScore': highScore,
        'bestStreak': bestStreak,
        'longestSequence': longestSequence,
        'totalPlayTimeSeconds': totalPlayTimeSeconds,
        'modeHighScores': modeHighScores,
      };
}

/// Sync pull response (server's copy of player data)
class SyncPullResponseDTO extends Equatable {
  final int totalGamesPlayed;
  final int totalScore;
  final int highScore;
  final int bestStreak;
  final int longestSequence;
  final int totalPlayTimeSeconds;
  final Map<String, int> modeHighScores;
  final DateTime? lastSyncedAt;
  final int serverVersion;

  const SyncPullResponseDTO({
    required this.totalGamesPlayed,
    required this.totalScore,
    required this.highScore,
    required this.bestStreak,
    required this.longestSequence,
    required this.totalPlayTimeSeconds,
    required this.modeHighScores,
    this.lastSyncedAt,
    this.serverVersion = 0,
  });

  factory SyncPullResponseDTO.fromJson(Map<String, dynamic> json) {
    return SyncPullResponseDTO(
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      totalScore: json['totalScore'] ?? 0,
      highScore: json['highScore'] ?? 0,
      bestStreak: json['bestStreak'] ?? 0,
      longestSequence: json['longestSequence'] ?? 0,
      totalPlayTimeSeconds: json['totalPlayTimeSeconds'] ?? 0,
      modeHighScores: Map<String, int>.from(json['modeHighScores'] ?? {}),
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.tryParse(json['lastSyncedAt'])
          : null,
      serverVersion: json['serverVersion'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalGamesPlayed': totalGamesPlayed,
        'totalScore': totalScore,
        'highScore': highScore,
        'bestStreak': bestStreak,
        'longestSequence': longestSequence,
        'totalPlayTimeSeconds': totalPlayTimeSeconds,
        'modeHighScores': modeHighScores,
        'lastSyncedAt': lastSyncedAt?.toIso8601String(),
        'serverVersion': serverVersion,
      };

  @override
  List<Object?> get props => [
        totalGamesPlayed,
        totalScore,
        highScore,
        bestStreak,
        longestSequence,
        totalPlayTimeSeconds,
        modeHighScores,
        lastSyncedAt,
        serverVersion,
      ];
}

/// Sync push response
class SyncPushResponseDTO extends Equatable {
  final bool success;
  final int serverVersion;
  final DateTime syncedAt;

  const SyncPushResponseDTO({
    required this.success,
    required this.serverVersion,
    required this.syncedAt,
  });

  factory SyncPushResponseDTO.fromJson(Map<String, dynamic> json) {
    return SyncPushResponseDTO(
      success: json['success'] ?? false,
      serverVersion: json['serverVersion'] ?? 0,
      syncedAt: DateTime.tryParse(json['syncedAt'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [success, serverVersion, syncedAt];
}
