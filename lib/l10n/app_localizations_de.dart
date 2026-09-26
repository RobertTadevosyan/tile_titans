// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Tile Titans';

  @override
  String get autoPlay => 'Autoplay';

  @override
  String get restart => '🔄';

  @override
  String get undo => '↩️';

  @override
  String get hint => '💡';

  @override
  String hintMessage(Object direction) {
    return '💡: Versuch es nach $direction';
  }

  @override
  String get statistics => 'Statistiken';

  @override
  String moves(Object moves) {
    return 'Züge: $moves';
  }

  @override
  String merges(Object merges) {
    return 'Fusionen: $merges';
  }

  @override
  String avgMerge(Object merges) {
    return 'Ø Fusion: $merges';
  }

  @override
  String mergeEfficiency(Object efficiency) {
    return 'Effizienz: $efficiency %';
  }

  @override
  String get close => 'Schließen';

  @override
  String score(Object score) {
    return 'Punkte: $score';
  }

  @override
  String highScore(Object highScore) {
    return 'Rekord: $highScore';
  }

  @override
  String get settings => 'Einstellungen';

  @override
  String get leaderboard => 'Bestenliste';

  @override
  String get findMe => 'Mich finden';

  @override
  String get noScore => 'Noch keine Punkte.';

  @override
  String get rank => 'Rang';

  @override
  String get scoreTitle => 'Punkte';

  @override
  String get platform => 'Plattform';

  @override
  String get device => 'Gerät';

  @override
  String get user => 'Spieler';

  @override
  String points(Object p) {
    return '$p Punkte';
  }

  @override
  String get appSettings => 'Einstellungen';

  @override
  String get soundEffects => 'Soundeffekte';

  @override
  String get highScoreTitle => 'Rekord';

  @override
  String get highScoreReset => 'Rekord zurückgesetzt';

  @override
  String get gameMode => 'Spielmodus';

  @override
  String get aiDifficulty => 'KI-Schwierigkeit';

  @override
  String get boardSize => 'Feldgröße';

  @override
  String get appTheme => 'Design';

  @override
  String get language => 'Sprache';

  @override
  String get restartGame => 'Neu starten';

  @override
  String get gameModeNormal => 'Normal';

  @override
  String get gameModeTimed => 'Auf Zeit';

  @override
  String get gameModeChallenge => 'Challenge';

  @override
  String get gameModeEvilAI => 'Böse KI';

  @override
  String get gameModeHardcore => 'Hardcore';

  @override
  String get gameModeZen => 'Zen';

  @override
  String get aiDiffEasy => 'Leicht';

  @override
  String get aiDiffSmart => 'Klug';

  @override
  String get aiDiffAggressive => 'Aggressiv';

  @override
  String get appThemeClassic => 'Klassisch';

  @override
  String get appThemeDark => 'Dunkel';

  @override
  String get appThemeOcean => 'Ozean';

  @override
  String get appThemeRetro => 'Retro';

  @override
  String get appThemeNeon => 'Neon';

  @override
  String get gameOver => 'Spiel vorbei';

  @override
  String get gameOverTitle => 'Spiel vorbei 🎮';

  @override
  String finalScore(Object score) {
    return 'Dein Endstand ist $score';
  }

  @override
  String get timeIsUp => 'Zeit abgelaufen!';

  @override
  String get homeContinue => 'Fortsetzen';

  @override
  String get homeNewGame => 'Neues Spiel';

  @override
  String get homePlay => 'Spielen';

  @override
  String get homeChooseChallenge => 'Wähle deine Herausforderung';

  @override
  String get homeDailyTrial => 'Tägliche Prüfung';

  @override
  String get homeTodaysChallenge => 'Heutige Aufgabe';

  @override
  String get homeTitanTrials => 'Titanen-Prüfungen';

  @override
  String get homeHallOfTitans => 'Halle der Titanen';

  @override
  String get homeGameModes => 'Spielmodi';

  @override
  String get homeBest => 'Bestwert';

  @override
  String homeStreakDays(int days) {
    return '$days Tage in Folge';
  }

  @override
  String get homeRank => 'Rang';

  @override
  String homeCompleted(int done, int total) {
    return '$done von $total';
  }

  @override
  String get homePlayed => 'Spiel fortsetzen';

  @override
  String get modeClassic => 'Klassisch';

  @override
  String get modeZen => 'Zen';

  @override
  String get modeTimeAttack => 'Zeitrennen';

  @override
  String get modeHardcore => 'Hardcore';

  @override
  String get modeClassicDesc => 'Die strategische Basis';

  @override
  String get modeZenDesc => 'Ohne Punkte, ohne Ende';

  @override
  String get modeTimeAttackDesc => 'Fusionen bringen Sekunden';

  @override
  String get modeHardcoreDesc => '5x5, viele Steine, keine Hilfe';

  @override
  String trialMoveLimit(int moves) {
    return '$moves Züge';
  }

  @override
  String trialTimeLimit(int seconds) {
    return '$seconds s';
  }

  @override
  String get trialNoUndo => 'Kein Rückgängig';

  @override
  String get trialNoHints => 'Keine Tipps';

  @override
  String get trialLocked => 'Gesperrt';

  @override
  String get trialObjective => 'Ziel';

  @override
  String get trialComplete => 'Prüfung bestanden';

  @override
  String get trialFailed => 'Prüfung gescheitert';

  @override
  String get achievements => 'Erfolge';

  @override
  String get pathOfTitans => 'Pfad der Titanen';

  @override
  String get statGamesPlayed => 'Gespielte Spiele';

  @override
  String get statBestScore => 'Bester Punktestand';

  @override
  String get statHighestTile => 'Höchster Stein';

  @override
  String get statTotalMerges => 'Fusionen gesamt';

  @override
  String get statAverageScore => 'Ø Punkte';

  @override
  String get statFavouriteMode => 'Lieblingsmodus';

  @override
  String get statPlayTime => 'Spielzeit';

  @override
  String get statLongestGame => 'Längstes Spiel';

  @override
  String get statsLifetime => 'Insgesamt';

  @override
  String get statsByMode => 'Nach Modus';

  @override
  String get statsNotPlayed => 'Noch nicht gespielt';

  @override
  String get statsTrials => 'Prüfungen';

  @override
  String get statsDaily => 'Täglich';

  @override
  String get statsBestStreak => 'Serie';

  @override
  String get statsChapters => 'Kapitel';

  @override
  String get appThemeForge => 'Schmiede';
}
