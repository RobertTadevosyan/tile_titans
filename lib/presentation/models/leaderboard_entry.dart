import 'package:flutter_2048/domain/progress/progress_store.dart';

/// Where a mode's scores are stored.
///
/// Classic writes to the flat `leaderboard/<uid>` path that every score used
/// before boards were split per mode. Several hundred rows already live there,
/// and giving Classic a bucket of its own would split that ladder in two, with
/// every existing player stranded on the old side. The other modes each get
/// their own bucket, because a 90-second Time Attack run and a 5x5 Hardcore run
/// are not comparable with Classic — ranking them together measures nothing.
///
/// Every board stores the same four fields, so one model reads them all.
String leaderboardPathFor(String mode, String userId) =>
    mode == ModeKeys.classic
        ? 'leaderboard/$userId'
        : 'leaderboard/$mode/$userId';

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
