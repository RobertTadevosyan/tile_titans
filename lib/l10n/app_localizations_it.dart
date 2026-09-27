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
  String points(num p) {
    String _temp0 = intl.Intl.pluralLogic(
      p,
      locale: localeName,
      other: '$p punti',
      one: '1 punto',
    );
    return '$_temp0';
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
    final intl.NumberFormat scoreNumberFormat = intl
        .NumberFormat.decimalPattern(localeName);
    final String scoreString = scoreNumberFormat.format(score);

    return 'Totalizza $scoreString punti';
  }

  @override
  String objCreateTiles(int count, int tile) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tessere',
      one: '1 tessera',
    );
    return 'Tieni $_temp0 da $tile';
  }

  @override
  String objSurvive(int moves) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: '$moves mosse',
      one: '1 mossa',
    );
    return 'Resisti $_temp0';
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

  @override
  String get achFirstBlood => 'Primo Sangue';

  @override
  String get achWarrior => 'Guerriero';

  @override
  String get achChampion => 'Campione';

  @override
  String get achTitanName => 'Titano';

  @override
  String get achBeyondGods => 'Oltre gli Dèi';

  @override
  String get achInitiate => 'Iniziato';

  @override
  String get achProven => 'Provato';

  @override
  String get achTrialmaster => 'Maestro delle Prove';

  @override
  String get achForgedName => 'Forgiato';

  @override
  String get achPerfectTrial => 'Prova Perfetta';

  @override
  String get achDedicated => 'Costante';

  @override
  String get achRelentless => 'Implacabile';

  @override
  String get achHoarder => 'Accumulatore';

  @override
  String get achIronhand => 'Mano di Ferro';

  @override
  String get achVeteran => 'Veterano';

  @override
  String achDescTrials(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Prove dei Titani',
      one: '1 Prova dei Titani',
    );
    return 'Completa $_temp0';
  }

  @override
  String get achDescAllTrials => 'Completa tutte le Prove dei Titani';

  @override
  String get achDescChapter => 'Completa un capitolo intero';

  @override
  String achDescCleanTrials(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prove',
      one: '1 prova',
    );
    return 'Completa $_temp0 senza annullare';
  }

  @override
  String achDescStreak(int days) {
    return 'Serie di $days giorni nella Prova del Giorno';
  }

  @override
  String achDescScore(int score) {
    return 'Totalizza $score in una sola partita';
  }

  @override
  String achDescMerges(int count) {
    return 'Unisci $count tessere in totale';
  }

  @override
  String achDescGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partite',
      one: '1 partita',
    );
    return 'Gioca $_temp0';
  }

  @override
  String trialName(String numeral) {
    return 'Prova $numeral';
  }

  @override
  String get dailyTrialTitle => 'Prova Quotidiana dei Titani';
}
