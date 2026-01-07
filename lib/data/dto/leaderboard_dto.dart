/// Leaderboard Data Transfer Objects for Echo Memory
/// Models for rankings and player entries

import 'package:equatable/equatable.dart';

/// Single leaderboard entry
class LeaderboardEntryDTO extends Equatable {
  final int rank;
  final String playerId;
  final String displayName;
  final int score;
  final String? avatarUrl;
  final bool isCurrentUser;

  const LeaderboardEntryDTO({
    required this.rank,
    required this.playerId,
    required this.displayName,
    required this.score,
    this.avatarUrl,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntryDTO.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryDTO(
      rank: json['rank'] ?? 0,
      playerId: json['playerId'] ?? '',
      displayName: json['displayName'] ?? 'Unknown',
      score: json['score'] ?? 0,
      avatarUrl: json['avatarUrl'],
      isCurrentUser: json['isCurrentUser'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'rank': rank,
        'playerId': playerId,
        'displayName': displayName,
        'score': score,
        'avatarUrl': avatarUrl,
        'isCurrentUser': isCurrentUser,
      };

  @override
  List<Object?> get props => [rank, playerId, displayName, score, avatarUrl, isCurrentUser];
}

/// Leaderboard response (list of entries)
class LeaderboardDTO extends Equatable {
  final String mode;
  final String period; // 'all_time' or 'weekly'
  final List<LeaderboardEntryDTO> entries;
  final int totalPlayers;
  final LeaderboardEntryDTO? currentUserEntry;

  const LeaderboardDTO({
    required this.mode,
    required this.period,
    required this.entries,
    this.totalPlayers = 0,
    this.currentUserEntry,
  });

  factory LeaderboardDTO.fromJson(Map<String, dynamic> json) {
    return LeaderboardDTO(
      mode: json['mode'] ?? '',
      period: json['period'] ?? 'all_time',
      entries: (json['entries'] as List<dynamic>?)
              ?.map((e) => LeaderboardEntryDTO.fromJson(e))
              .toList() ??
          [],
      totalPlayers: json['totalPlayers'] ?? 0,
      currentUserEntry: json['currentUserEntry'] != null
          ? LeaderboardEntryDTO.fromJson(json['currentUserEntry'])
          : null,
    );
  }

  @override
  List<Object?> get props => [mode, period, entries, totalPlayers, currentUserEntry];
}

/// User's ranks across all modes
class UserRanksDTO extends Equatable {
  final Map<String, RankInfo> allTime;
  final Map<String, RankInfo> weekly;

  const UserRanksDTO({
    required this.allTime,
    required this.weekly,
  });

  factory UserRanksDTO.fromJson(Map<String, dynamic> json) {
    return UserRanksDTO(
      allTime: _parseRankMap(json['allTime']),
      weekly: _parseRankMap(json['weekly']),
    );
  }

  static Map<String, RankInfo> _parseRankMap(dynamic data) {
    if (data == null) return {};
    final map = <String, RankInfo>{};
    (data as Map<String, dynamic>).forEach((key, value) {
      if (value is Map<String, dynamic>) {
        map[key] = RankInfo.fromJson(value);
      } else if (value is int) {
        map[key] = RankInfo(rank: value, score: 0);
      }
    });
    return map;
  }

  @override
  List<Object?> get props => [allTime, weekly];
}

/// Rank info for a specific mode
class RankInfo extends Equatable {
  final int rank;
  final int score;
  final int? totalPlayers;

  const RankInfo({
    required this.rank,
    required this.score,
    this.totalPlayers,
  });

  factory RankInfo.fromJson(Map<String, dynamic> json) {
    return RankInfo(
      rank: json['rank'] ?? 0,
      score: json['score'] ?? 0,
      totalPlayers: json['totalPlayers'],
    );
  }

  /// Get percentile (top X%)
  double? get percentile {
    if (totalPlayers == null || totalPlayers == 0) return null;
    return (rank / totalPlayers!) * 100;
  }

  @override
  List<Object?> get props => [rank, score, totalPlayers];
}
