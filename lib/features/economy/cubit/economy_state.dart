/// Economy State for Echo Memory
/// Manages coins, gems, and lives state

import 'package:equatable/equatable.dart';
import '../../../data/dto/economy_dto.dart';

enum EconomyStatus {
  initial,
  loading,
  loaded,
  error,
}

class EconomyState extends Equatable {
  final EconomyStatus status;
  final EconomyStateDTO? economy;
  final String? errorMessage;
  final bool isDailyBonusClaiming;
  final DailyBonusClaimDTO? lastClaimedBonus;

  const EconomyState({
    this.status = EconomyStatus.initial,
    this.economy,
    this.errorMessage,
    this.isDailyBonusClaiming = false,
    this.lastClaimedBonus,
  });

  /// Initial state
  const EconomyState.initial() : this();

  /// Loading state
  const EconomyState.loading()
      : this(status: EconomyStatus.loading);

  /// Loaded state
  EconomyState.loaded(EconomyStateDTO economy)
      : this(status: EconomyStatus.loaded, economy: economy);

  /// Error state
  EconomyState.error(String message)
      : this(status: EconomyStatus.error, errorMessage: message);

  // Convenience getters
  int get coins => economy?.coins ?? 0;
  int get gems => economy?.gems ?? 0;
  int get lives => economy?.lives ?? 0;
  int get maxLives => economy?.maxLives ?? 20;
  bool get hasFullLives => lives >= maxLives;
  bool get dailyBonusAvailable => economy?.dailyBonusAvailable ?? false;
  int get dailyLoginStreak => economy?.dailyLoginStreak ?? 0;
  Duration? get timeUntilNextLife => economy?.timeUntilNextLife;
  bool get isLoading => status == EconomyStatus.loading;
  bool get isLoaded => status == EconomyStatus.loaded;

  EconomyState copyWith({
    EconomyStatus? status,
    EconomyStateDTO? economy,
    String? errorMessage,
    bool? isDailyBonusClaiming,
    DailyBonusClaimDTO? lastClaimedBonus,
  }) {
    return EconomyState(
      status: status ?? this.status,
      economy: economy ?? this.economy,
      errorMessage: errorMessage ?? this.errorMessage,
      isDailyBonusClaiming: isDailyBonusClaiming ?? this.isDailyBonusClaiming,
      lastClaimedBonus: lastClaimedBonus ?? this.lastClaimedBonus,
    );
  }

  @override
  List<Object?> get props => [
        status,
        economy,
        errorMessage,
        isDailyBonusClaiming,
        lastClaimedBonus,
      ];
}
