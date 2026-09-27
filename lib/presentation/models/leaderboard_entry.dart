import 'package:flutter_2048/domain/progress/progress_store.dart';

/// Where a mode's scores are stored.
///
/// Classic stays at the flat `leaderboard/<uid>` path that every score used
/// before boards were split per mode. Several hundred rows already live there,
/// and giving Classic a bucket of its own would split that ladder in two, with
/// every existing player stranded on the old side.
///
/// The other modes nest under the same player node rather than sitting in
/// top-level buckets like `leaderboard/timeAttack/<uid>`. That is not a style
/// choice: the database's security rules only grant a player write access to
/// `leaderboard/<their uid>`, so a top-level bucket is rejected with permission
/// denied — silently, because a failed leaderboard write must never interrupt
/// play. Nesting keeps every write inside the branch the player owns, so the
/// per-mode boards work under the rules as they already are.
///
/// Every board stores the same four fields, so one model reads them all.
String leaderboardPathFor(String mode, String userId) =>
    mode == ModeKeys.classic
        ? 'leaderboard/$userId'
        : 'leaderboard/$userId/modes/$mode';

/// Pulls one mode's row out of a player's leaderboard node.
///
/// Returns null when that player has not posted a score on this board.
Map<dynamic, dynamic>? leaderboardRowFor(String mode, Map<dynamic, dynamic> node) {
  if (mode == ModeKeys.classic) {
    return node.containsKey('high_score') ? node : null;
  }
  final modes = node['modes'];
  if (modes is! Map) return null;
  final row = modes[mode];
  return row is Map && row.containsKey('high_score') ? row : null;
}

class LeaderboardEntry {
  final String userId;
  final int score;
  final String platform;
  final String device;
  final String? os;

  LeaderboardEntry({
    required this.userId,
    required this.score,
    required this.platform,
    required this.device,
    this.os,
  });

  factory LeaderboardEntry.fromMap(String id, Map<dynamic, dynamic> data) {
    return LeaderboardEntry(
      userId: id,
      score: data['high_score'] ?? 0,
      platform: data['platform'] ?? 'Unknown',
      device: data['device'] ?? 'Unknown',
      os: data['os'],
    );
  }
}
