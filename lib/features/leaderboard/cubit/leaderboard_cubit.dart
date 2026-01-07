/// Leaderboard Cubit for Echo Memory
/// Manages leaderboard data fetching and caching

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../data/repositories/leaderboard_repository.dart';
import 'leaderboard_state.dart';

class LeaderboardCubit extends Cubit<LeaderboardState> {
  final LeaderboardRepository _leaderboardRepository;

  LeaderboardCubit({LeaderboardRepository? leaderboardRepository})
      : _leaderboardRepository =
            leaderboardRepository ?? getIt<LeaderboardRepository>(),
        super(const LeaderboardState.initial());

  /// Load leaderboard for selected mode and period
  Future<void> loadLeaderboard({
    String? mode,
    LeaderboardPeriod? period,
    bool forceRefresh = false,
  }) async {
    final selectedMode = mode ?? state.selectedMode;
    final selectedPeriod = period ?? state.period;

    emit(LeaderboardState.loading(mode: selectedMode, period: selectedPeriod));

    try {
      final leaderboard = selectedPeriod == LeaderboardPeriod.allTime
          ? await _leaderboardRepository.getAllTime(
              selectedMode,
              forceRefresh: forceRefresh,
            )
          : await _leaderboardRepository.getWeekly(
              selectedMode,
              forceRefresh: forceRefresh,
            );

      // Also fetch user ranks
      final userRanks = await _leaderboardRepository.getUserRanks(
        forceRefresh: forceRefresh,
      );

      emit(state.copyWith(
        status: LeaderboardStatus.loaded,
        leaderboard: leaderboard,
        userRanks: userRanks,
        selectedMode: selectedMode,
        period: selectedPeriod,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: LeaderboardStatus.error,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LeaderboardStatus.error,
        errorMessage: 'Failed to load leaderboard',
      ));
    }
  }

  /// Switch to a different game mode
  void switchMode(String mode) {
    if (mode == state.selectedMode) return;
    loadLeaderboard(mode: mode);
  }

  /// Switch between all-time and weekly
  void switchPeriod(LeaderboardPeriod period) {
    if (period == state.period) return;
    loadLeaderboard(period: period);
  }

  /// Refresh current leaderboard
  Future<void> refresh() async {
    await loadLeaderboard(forceRefresh: true);
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
