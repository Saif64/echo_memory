/// Economy Data Transfer Objects for Echo Memory
/// Models for coins, gems, lives, and daily bonuses

import 'package:equatable/equatable.dart';

/// Economy state DTO from API
class EconomyStateDTO extends Equatable {
  final int coins;
  final int gems;
  final int lives;
  final int maxLives;
  final DateTime? nextLifeAt;
  final DateTime? livesFullAt;
  final bool dailyBonusAvailable;
  final int dailyLoginStreak;

  const EconomyStateDTO({
    required this.coins,
    required this.gems,
    required this.lives,
    required this.maxLives,
    this.nextLifeAt,
    this.livesFullAt,
    required this.dailyBonusAvailable,
    required this.dailyLoginStreak,
  });

  factory EconomyStateDTO.fromJson(Map<String, dynamic> json) {
    return EconomyStateDTO(
      coins: json['coins'] ?? 0,
      gems: json['gems'] ?? 0,
      lives: json['lives'] ?? 0,
      maxLives: json['maxLives'] ?? 20,
      nextLifeAt: json['nextLifeAt'] != null
          ? DateTime.tryParse(json['nextLifeAt'])
          : null,
      livesFullAt: json['livesFullAt'] != null
          ? DateTime.tryParse(json['livesFullAt'])
          : null,
      dailyBonusAvailable: json['dailyBonusAvailable'] ?? false,
      dailyLoginStreak: json['dailyLoginStreak'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'coins': coins,
        'gems': gems,
        'lives': lives,
        'maxLives': maxLives,
        'nextLifeAt': nextLifeAt?.toIso8601String(),
        'livesFullAt': livesFullAt?.toIso8601String(),
        'dailyBonusAvailable': dailyBonusAvailable,
        'dailyLoginStreak': dailyLoginStreak,
      };

  /// Get time until next life regenerates
  Duration? get timeUntilNextLife {
    if (nextLifeAt == null || lives >= maxLives) return null;
    final now = DateTime.now();
    if (nextLifeAt!.isBefore(now)) return Duration.zero;
    return nextLifeAt!.difference(now);
  }

  /// Get time until all lives are full
  Duration? get timeUntilFull {
    if (livesFullAt == null || lives >= maxLives) return null;
    final now = DateTime.now();
    if (livesFullAt!.isBefore(now)) return Duration.zero;
    return livesFullAt!.difference(now);
  }

  /// Check if lives are full
  bool get hasFullLives => lives >= maxLives;

  EconomyStateDTO copyWith({
    int? coins,
    int? gems,
    int? lives,
    int? maxLives,
    DateTime? nextLifeAt,
    DateTime? livesFullAt,
    bool? dailyBonusAvailable,
    int? dailyLoginStreak,
  }) {
    return EconomyStateDTO(
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      lives: lives ?? this.lives,
      maxLives: maxLives ?? this.maxLives,
      nextLifeAt: nextLifeAt ?? this.nextLifeAt,
      livesFullAt: livesFullAt ?? this.livesFullAt,
      dailyBonusAvailable: dailyBonusAvailable ?? this.dailyBonusAvailable,
      dailyLoginStreak: dailyLoginStreak ?? this.dailyLoginStreak,
    );
  }

  @override
  List<Object?> get props => [
        coins,
        gems,
        lives,
        maxLives,
        nextLifeAt,
        livesFullAt,
        dailyBonusAvailable,
        dailyLoginStreak,
      ];
}

/// Use life request
class UseLifeRequest {
  final String gameMode;

  const UseLifeRequest({required this.gameMode});

  Map<String, dynamic> toJson() => {'gameMode': gameMode};
}

/// Buy lives request
class BuyLivesRequest {
  final int quantity;
  final String currency; // 'coins' or 'gems'

  const BuyLivesRequest({required this.quantity, required this.currency});

  Map<String, dynamic> toJson() => {
        'quantity': quantity,
        'currency': currency,
      };
}

/// Daily bonus claim response
class DailyBonusClaimDTO extends Equatable {
  final int coinsAwarded;
  final int gemsAwarded;
  final int newStreak;
  final int nextBonusMultiplier;

  const DailyBonusClaimDTO({
    required this.coinsAwarded,
    required this.gemsAwarded,
    required this.newStreak,
    required this.nextBonusMultiplier,
  });

  factory DailyBonusClaimDTO.fromJson(Map<String, dynamic> json) {
    return DailyBonusClaimDTO(
      coinsAwarded: json['coinsAwarded'] ?? 0,
      gemsAwarded: json['gemsAwarded'] ?? 0,
      newStreak: json['newStreak'] ?? 1,
      nextBonusMultiplier: json['nextBonusMultiplier'] ?? 1,
    );
  }

  @override
  List<Object?> get props => [coinsAwarded, gemsAwarded, newStreak, nextBonusMultiplier];
}
