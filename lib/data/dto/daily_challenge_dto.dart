/// Daily Challenge Data Transfer Objects for Echo Memory
/// Models for daily challenges, streaks, and completion

import 'package:equatable/equatable.dart';

/// Challenge configuration
class ChallengeConfigDTO extends Equatable {
  final String difficulty;
  final int seed;
  final int sequenceLength;
  final int targetScore;
  final Map<String, dynamic>? extraParams;

  const ChallengeConfigDTO({
    required this.difficulty,
    required this.seed,
    required this.sequenceLength,
    required this.targetScore,
    this.extraParams,
  });

  factory ChallengeConfigDTO.fromJson(Map<String, dynamic> json) {
    return ChallengeConfigDTO(
      difficulty: json['difficulty'] ?? 'normal',
      seed: json['seed'] ?? 0,
      sequenceLength: json['sequenceLength'] ?? 4,
      targetScore: json['targetScore'] ?? 500,
      extraParams: json['extraParams'],
    );
  }

  Map<String, dynamic> toJson() => {
        'difficulty': difficulty,
        'seed': seed,
        'sequenceLength': sequenceLength,
        'targetScore': targetScore,
        if (extraParams != null) 'extraParams': extraParams,
      };

  @override
  List<Object?> get props => [difficulty, seed, sequenceLength, targetScore, extraParams];
}

/// Streak information
class StreakInfoDTO extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final int totalCompleted;

  const StreakInfoDTO({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompleted,
  });

  factory StreakInfoDTO.fromJson(Map<String, dynamic> json) {
    return StreakInfoDTO(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      totalCompleted: json['totalCompleted'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'totalCompleted': totalCompleted,
      };

  @override
  List<Object?> get props => [currentStreak, longestStreak, totalCompleted];
}

/// Daily challenge DTO
class DailyChallengeDTO extends Equatable {
  final String date;
  final String gameMode;
  final ChallengeConfigDTO config;
  final int targetScore;
  final bool completed;
  final int userBestScore;
  final StreakInfoDTO streakInfo;
  final ChallengeRewardsDTO? rewards;

  const DailyChallengeDTO({
    required this.date,
    required this.gameMode,
    required this.config,
    required this.targetScore,
    required this.completed,
    required this.userBestScore,
    required this.streakInfo,
    this.rewards,
  });

  factory DailyChallengeDTO.fromJson(Map<String, dynamic> json) {
    return DailyChallengeDTO(
      date: json['date'] ?? '',
      gameMode: json['gameMode'] ?? 'CLASSIC',
      config: ChallengeConfigDTO.fromJson(json['config'] ?? {}),
      targetScore: json['targetScore'] ?? 500,
      completed: json['completed'] ?? false,
      userBestScore: json['userBestScore'] ?? 0,
      streakInfo: StreakInfoDTO.fromJson(json['streakInfo'] ?? {}),
      rewards: json['rewards'] != null
          ? ChallengeRewardsDTO.fromJson(json['rewards'])
          : null,
    );
  }

  /// Check if user beat the target
  bool get beatTarget => userBestScore >= targetScore;

  /// Progress percentage toward target (0.0 - 1.0+)
  double get progressToTarget {
    if (targetScore == 0) return 0;
    return userBestScore / targetScore;
  }

  @override
  List<Object?> get props => [
        date,
        gameMode,
        config,
        targetScore,
        completed,
        userBestScore,
        streakInfo,
        rewards,
      ];
}

/// Challenge rewards
class ChallengeRewardsDTO extends Equatable {
  final int baseCoins;
  final int bonusCoins;
  final int gems;
  final int streakBonus;

  const ChallengeRewardsDTO({
    required this.baseCoins,
    required this.bonusCoins,
    required this.gems,
    required this.streakBonus,
  });

  factory ChallengeRewardsDTO.fromJson(Map<String, dynamic> json) {
    return ChallengeRewardsDTO(
      baseCoins: json['baseCoins'] ?? 0,
      bonusCoins: json['bonusCoins'] ?? 0,
      gems: json['gems'] ?? 0,
      streakBonus: json['streakBonus'] ?? 0,
    );
  }

  int get totalCoins => baseCoins + bonusCoins + streakBonus;

  @override
  List<Object?> get props => [baseCoins, bonusCoins, gems, streakBonus];
}

/// Complete challenge request
class CompleteChallengeRequest {
  final int score;
  final int durationSeconds;
  final List<String> powerUpsUsed;

  const CompleteChallengeRequest({
    required this.score,
    required this.durationSeconds,
    this.powerUpsUsed = const [],
  });

  Map<String, dynamic> toJson() => {
        'score': score,
        'durationSeconds': durationSeconds,
        'powerUpsUsed': powerUpsUsed,
      };
}

/// Complete challenge response
class CompleteChallengeResponseDTO extends Equatable {
  final bool success;
  final int coinsEarned;
  final int gemsEarned;
  final StreakInfoDTO newStreakInfo;
  final bool beatTarget;
  final bool newRecord;

  const CompleteChallengeResponseDTO({
    required this.success,
    required this.coinsEarned,
    required this.gemsEarned,
    required this.newStreakInfo,
    required this.beatTarget,
    required this.newRecord,
  });

  factory CompleteChallengeResponseDTO.fromJson(Map<String, dynamic> json) {
    return CompleteChallengeResponseDTO(
      success: json['success'] ?? false,
      coinsEarned: json['coinsEarned'] ?? 0,
      gemsEarned: json['gemsEarned'] ?? 0,
      newStreakInfo: StreakInfoDTO.fromJson(json['newStreakInfo'] ?? {}),
      beatTarget: json['beatTarget'] ?? false,
      newRecord: json['newRecord'] ?? false,
    );
  }

  @override
  List<Object?> get props => [
        success,
        coinsEarned,
        gemsEarned,
        newStreakInfo,
        beatTarget,
        newRecord,
      ];
}
