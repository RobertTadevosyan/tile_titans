// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Tile Titans';

  @override
  String get autoPlay => 'Auto';

  @override
  String get restart => '🔄';

  @override
  String get undo => '↩️';

  @override
  String get hint => '💡';

  @override
  String hintMessage(Object direction) {
    return '💡: Prova a muovere $direction';
  }

  @override
  String get statistics => 'Statistiche';

  @override
  String moves(Object moves) {
    return 'Mosse: $moves';
  }

  @override
  String merges(Object merges) {
    return 'Fusioni: $merges';
  }

  @override
  String avgMerge(Object merges) {
    return 'Fusione media: $merges';
  }

  @override
  String mergeEfficiency(Object efficiency) {
    return 'Efficienza: $efficiency%';
  }

  @override
  String get close => 'Chiudi';

  @override
  String score(Object score) {
    return 'Punti: $score';
  }

  @override
  String highScore(Object highScore) {
    return 'Record: $highScore';
  }

  @override
  String get settings => 'Impostazioni';

  @override
  String get leaderboard => 'Classifica';

  @override
  String get findMe => 'Trovami';

  @override
  String get noScore => 'Ancora nessun punteggio.';

  @override
  String get rank => 'Grado';

  @override
  String get scoreTitle => 'Punti';

  @override
  String get platform => 'Piattaforma';

  @override
  String get device => 'Dispositivo';

  @override
  String get user => 'Giocatore';

  @override
  String points(Object p) {
    return '$p punti';
  }

  @override
  String get appSettings => 'Impostazioni';

  @override
  String get soundEffects => 'Effetti sonori';

  @override
  String get highScoreTitle => 'Record';

  @override
  String get highScoreReset => 'Record azzerato';

  @override
  String get gameMode => 'Modalità';

  @override
  String get aiDifficulty => 'Difficoltà IA';

  @override
  String get boardSize => 'Dimensione griglia';

  @override
  String get appTheme => 'Tema';

  @override
  String get language => 'Lingua';

  @override
  String get restartGame => 'Ricomincia';

  @override
  String get gameModeNormal => 'Normale';

  @override
  String get gameModeTimed => 'A tempo';

  @override
  String get gameModeChallenge => 'Sfida';

  @override
  String get gameModeEvilAI => 'IA malvagia';

  @override
  String get gameModeHardcore => 'Estrema';

  @override
  String get gameModeZen => 'Zen';

  @override
  String get aiDiffEasy => 'Facile';

  @override
  String get aiDiffSmart => 'Astuta';

  @override
  String get aiDiffAggressive => 'Aggressiva';

  @override
  String get appThemeClassic => 'Classico';

  @override
  String get appThemeDark => 'Scuro';

  @override
  String get appThemeOcean => 'Oceano';

  @override
  String get appThemeRetro => 'Retrò';

  @override
  String get appThemeNeon => 'Neon';

  @override
  String get gameOver => 'Partita finita';

  @override
  String get gameOverTitle => 'Partita finita 🎮';

  @override
  String finalScore(Object score) {
    return 'Il tuo punteggio finale è $score';
  }

  @override
  String get timeIsUp => 'Tempo scaduto!';

  @override
  String get homeContinue => 'Continua';

  @override
  String get homeNewGame => 'Nuova partita';

  @override
  String get homePlay => 'Gioca';

  @override
  String get homeChooseChallenge => 'Scegli la tua sfida';

  @override
  String get homeDailyTrial => 'Prova del giorno';

  @override
  String get homeTodaysChallenge => 'Sfida di oggi';

  @override
  String get homeTitanTrials => 'Prove dei Titani';

  @override
  String get homeHallOfTitans => 'Sala dei Titani';

  @override
  String get homeGameModes => 'Modalità';

  @override
  String get homeBest => 'Record';

  @override
  String homeStreakDays(int days) {
    return 'Serie di $days g';
  }

  @override
  String get homeRank => 'Grado';

  @override
  String homeCompleted(int done, int total) {
    return '$done su $total';
  }

  @override
  String get homePlayed => 'Riprendi la partita';

  @override
  String get modeClassic => 'Classica';

  @override
  String get modeZen => 'Zen';

  @override
  String get modeTimeAttack => 'Contro il tempo';

  @override
  String get modeHardcore => 'Estrema';

  @override
  String get modeClassicDesc => 'La base strategica';

  @override
  String get modeZenDesc => 'Senza punti né sconfitta';

  @override
  String get modeTimeAttackDesc => 'Le fusioni danno secondi';

  @override
  String get modeHardcoreDesc => '5x5, più tessere, nessun aiuto';

  @override
  String trialMoveLimit(int moves) {
    return '$moves mosse';
  }

  @override
  String trialTimeLimit(int seconds) {
    return '$seconds s';
  }

  @override
  String get trialNoUndo => 'Senza annulla';

  @override
  String get trialNoHints => 'Senza aiuti';

  @override
  String get trialLocked => 'Bloccata';

  @override
  String get trialObjective => 'Obiettivo';

  @override
  String get trialComplete => 'Prova superata';

  @override
  String get trialFailed => 'Prova fallita';

  @override
  String get achievements => 'Obiettivi';

  @override
  String get pathOfTitans => 'Via dei Titani';

  @override
  String get statGamesPlayed => 'Partite giocate';

  @override
  String get statBestScore => 'Punteggio migliore';

  @override
  String get statHighestTile => 'Tessera più alta';

  @override
  String get statTotalMerges => 'Fusioni totali';

  @override
  String get statAverageScore => 'Punteggio medio';

  @override
  String get statFavouriteMode => 'Modalità preferita';

  @override
  String get statPlayTime => 'Tempo di gioco';

  @override
  String get statLongestGame => 'Partita più lunga';

  @override
  String get statsLifetime => 'Da sempre';

  @override
  String get statsByMode => 'Per modalità';

  @override
  String get statsNotPlayed => 'Non ancora giocata';

  @override
  String get statsTrials => 'Prove';

  @override
  String get statsDaily => 'Giornaliera';

  @override
  String get statsBestStreak => 'Serie';

  @override
  String get statsChapters => 'Capitoli';

  @override
  String get appThemeForge => 'Fucina';

  @override
  String objReachTile(int tile) {
    return 'Forgia una tessera $tile';
  }

  @override
  String objReachScore(int score) {
    return 'Totalizza $score punti';
  }

  @override
  String objCreateTiles(int count, int tile) {
    return 'Tieni $count tessere $tile insieme';
  }

  @override
  String objSurvive(int moves) {
    return 'Resisti $moves mosse';
  }

  @override
  String objClearBoard(int count) {
    return 'Riduci a $count tessere';
  }

  @override
  String get rankNovice => 'Novizio';

  @override
  String get rankWarrior => 'Guerriero';

  @override
  String get rankChampion => 'Campione';

  @override
  String get rankTitan => 'Titano';

  @override
  String get rankLegend => 'Leggenda';

  @override
  String get chapterForge => 'La Fucina';

  @override
  String get chapterProving => 'Il Campo di Prova';

  @override
  String get chapterSummit => 'La Vetta';

  @override
  String get chapterForgeTheme => 'Impara gli obiettivi';

  @override
  String get chapterProvingTheme => 'Celle bloccate e niente annulla';

  @override
  String get chapterSummitTheme => 'Tempo e campo aperto';
}
