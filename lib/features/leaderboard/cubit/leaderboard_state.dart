/// Leaderboard State for Echo Memory
/// Manages leaderboard data state

import 'package:equatable/equatable.dart';
import '../../../data/dto/leaderboard_dto.dart';

enum LeaderboardStatus {
  initial,
  loading,
  loaded,
  error,
}

enum LeaderboardPeriod {
  allTime,
  weekly,
}

class LeaderboardState extends Equatable {
  final LeaderboardStatus status;
  final LeaderboardDTO? leaderboard;
  final UserRanksDTO? userRanks;
  final String selectedMode;
  final LeaderboardPeriod period;
  final String? errorMessage;

  const LeaderboardState({
    this.status = LeaderboardStatus.initial,
    this.leaderboard,
    this.userRanks,
    this.selectedMode = 'classic',
    this.period = LeaderboardPeriod.allTime,
    this.errorMessage,
  });

  /// Initial state
  const LeaderboardState.initial() : this();

  /// Loading state
  LeaderboardState.loading({
    required String mode,
    required LeaderboardPeriod period,
  }) : this(
          status: LeaderboardStatus.loading,
          selectedMode: mode,
          period: period,
        );

  bool get isLoading => status == LeaderboardStatus.loading;
  bool get isLoaded => status == LeaderboardStatus.loaded;
  List<LeaderboardEntryDTO> get entries => leaderboard?.entries ?? [];
  int get totalPlayers => leaderboard?.totalPlayers ?? 0;
  LeaderboardEntryDTO? get currentUserEntry => leaderboard?.currentUserEntry;

  LeaderboardState copyWith({
    LeaderboardStatus? status,
    LeaderboardDTO? leaderboard,
    UserRanksDTO? userRanks,
    String? selectedMode,
    LeaderboardPeriod? period,
    String? errorMessage,
  }) {
    return LeaderboardState(
      status: status ?? this.status,
      leaderboard: leaderboard ?? this.leaderboard,
      userRanks: userRanks ?? this.userRanks,
      selectedMode: selectedMode ?? this.selectedMode,
      period: period ?? this.period,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        leaderboard,
        userRanks,
        selectedMode,
        period,
        errorMessage,
      ];
}
