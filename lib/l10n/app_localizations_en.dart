// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tile Titans';

  @override
  String get autoPlay => 'Auto Play';

  @override
  String get restart => '🔄';

  @override
  String get undo => '↩️';

  @override
  String get hint => '💡';

  @override
  String hintMessage(Object direction) {
    return '💡: Try moving $direction';
  }

  @override
  String get statistics => 'Statistics';

  @override
  String moves(Object moves) {
    return 'Moves: $moves';
  }

  @override
  String merges(Object merges) {
    return 'Merges: $merges';
  }

  @override
  String avgMerge(Object merges) {
    return 'Avg Merge: $merges';
  }

  @override
  String mergeEfficiency(Object efficiency) {
    return 'Merge Efficiency: $efficiency%';
  }

  @override
  String get close => 'Close';

  @override
  String score(Object score) {
    return 'Score: $score';
  }

  @override
  String highScore(Object highScore) {
    return 'High Score: $highScore';
  }

  @override
  String get settings => 'Settings';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get findMe => 'Find Me';

  @override
  String get noScore => 'No scores yet.';

  @override
  String get rank => 'Rank';

  @override
  String get scoreTitle => 'Score';

  @override
  String get platform => 'Platform';

  @override
  String get device => 'Device';

  @override
  String get user => 'User';

  @override
  String points(Object p) {
    return '$p points';
  }

  @override
  String get appSettings => 'App Settings';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get highScoreTitle => 'High Score';

  @override
  String get highScoreReset => 'High score reset';

  @override
  String get gameMode => 'Game Mode';

  @override
  String get aiDifficulty => 'AI Difficulty';

  @override
  String get boardSize => 'Board Size';

  @override
  String get appTheme => 'App Theme';

  @override
  String get language => 'Language';

  @override
  String get restartGame => 'Restart Game';

  @override
  String get gameModeNormal => 'Normal';

  @override
  String get gameModeTimed => 'Timed';

  @override
  String get gameModeChallenge => 'Challenge';

  @override
  String get gameModeEvilAI => 'EvilAI';

  @override
  String get gameModeHardcore => 'Hardcore';

  @override
  String get gameModeZen => 'Zen';

  @override
  String get aiDiffEasy => 'Easy';

  @override
  String get aiDiffSmart => 'Smart';

  @override
  String get aiDiffAggressive => 'Aggressive';

  @override
  String get appThemeClassic => 'Classic';

  @override
  String get appThemeDark => 'Dark';

  @override
  String get appThemeOcean => 'Ocean';

  @override
  String get appThemeRetro => 'Retro';

  @override
  String get appThemeNeon => 'Neon';

  @override
  String get gameOver => 'Game Over';

  @override
  String get gameOverTitle => 'Game Over 🎮';

  @override
  String finalScore(Object score) {
    return 'Your final score is $score';
  }

  @override
  String get timeIsUp => 'Time\'s Up!';
}
