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
