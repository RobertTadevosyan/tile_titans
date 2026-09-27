// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Tile Titans';

  @override
  String get autoPlay => 'Jeu auto';

  @override
  String get restart => '🔄';

  @override
  String get undo => '↩️';

  @override
  String get hint => '💡';

  @override
  String hintMessage(Object direction) {
    return '💡 : Essayez d\'aller $direction';
  }

  @override
  String get statistics => 'Statistiques';

  @override
  String moves(Object moves) {
    return 'Coups : $moves';
  }

  @override
  String merges(Object merges) {
    return 'Fusions : $merges';
  }

  @override
  String avgMerge(Object merges) {
    return 'Fusion moy. : $merges';
  }

  @override
  String mergeEfficiency(Object efficiency) {
    return 'Efficacité : $efficiency %';
  }

  @override
  String get close => 'Fermer';

  @override
  String score(Object score) {
    return 'Score : $score';
  }

  @override
  String highScore(Object highScore) {
    return 'Record : $highScore';
  }

  @override
  String get settings => 'Paramètres';

  @override
  String get leaderboard => 'Classement';

  @override
  String get findMe => 'Me trouver';

  @override
  String get noScore => 'Aucun score pour l\'instant.';

  @override
  String get rank => 'Rang';

  @override
  String get scoreTitle => 'Score';

  @override
  String get platform => 'Plateforme';

  @override
  String get device => 'Appareil';

  @override
  String get user => 'Joueur';

  @override
  String points(num p) {
    String _temp0 = intl.Intl.pluralLogic(
      p,
      locale: localeName,
      other: '$p points',
      one: '$p point',
    );
    return '$_temp0';
  }

  @override
  String get appSettings => 'Paramètres';

  @override
  String get soundEffects => 'Effets sonores';

  @override
  String get highScoreTitle => 'Record';

  @override
  String get highScoreReset => 'Record réinitialisé';

  @override
  String get aiDifficulty => 'Style des indices';

  @override
  String get boardSize => 'Taille du plateau';

  @override
  String get appTheme => 'Thème';

  @override
  String get language => 'Langue';

  @override
  String get restartGame => 'Recommencer';

  @override
  String get gameModeNormal => 'Normal';

  @override
  String get gameModeTimed => 'Chrono';

  @override
  String get gameModeHardcore => 'Extrême';

  @override
  String get gameModeZen => 'Zen';

  @override
  String get aiDiffEasy => 'Prudent';

  @override
  String get aiDiffSmart => 'Équilibré';

  @override
  String get aiDiffAggressive => 'Agressif';

  @override
  String get appThemeClassic => 'Classique';

  @override
  String get appThemeDark => 'Sombre';

  @override
  String get appThemeOcean => 'Océan';

  @override
  String get appThemeRetro => 'Rétro';

  @override
  String get appThemeNeon => 'Néon';

  @override
  String get gameOver => 'Partie terminée';

  @override
  String get gameOverTitle => 'Partie terminée 🎮';

  @override
  String finalScore(Object score) {
    return 'Votre score final est $score';
  }

  @override
  String get timeIsUp => 'Temps écoulé !';

  @override
  String get homeContinue => 'Continuer';

  @override
  String get homeChooseChallenge => 'Choisissez votre défi';

  @override
  String get homeDailyTrial => 'Épreuve du jour';

  @override
  String get homeTitanTrials => 'Épreuves des Titans';

  @override
  String get homeHallOfTitans => 'Panthéon des Titans';

  @override
  String get homeBest => 'Record';

  @override
  String homeStreakDays(int days) {
    return 'Série de $days j';
  }

  @override
  String get homeRank => 'Rang';

  @override
  String homeCompleted(int done, int total) {
    return '$done sur $total';
  }

  @override
  String get homePlayed => 'Reprendre la partie';

  @override
  String get modeClassic => 'Classique';

  @override
  String get modeZen => 'Zen';

  @override
  String get modeTimeAttack => 'Contre-la-montre';

  @override
  String get modeHardcore => 'Extrême';

  @override
  String get modeClassicDesc => 'La base stratégique';

  @override
  String get modeZenDesc => 'Sans score ni défaite';

  @override
  String get modeTimeAttackDesc => 'Les fusions donnent du temps';

  @override
  String get modeHardcoreDesc => '5x5, plus de tuiles, aucune aide';

  @override
  String trialMoveLimit(int moves) {
    return '$moves coups';
  }

  @override
  String trialTimeLimit(int seconds) {
    return '$seconds s';
  }

  @override
  String get trialNoUndo => 'Sans annuler';

  @override
  String get trialNoHints => 'Sans indices';

  @override
  String get trialObjective => 'Objectif';

  @override
  String get trialComplete => 'Épreuve réussie';

  @override
  String get trialFailed => 'Épreuve échouée';

  @override
  String get achievements => 'Succès';

  @override
  String get pathOfTitans => 'Voie des Titans';

  @override
  String get statGamesPlayed => 'Parties jouées';

  @override
  String get statBestScore => 'Meilleur score';

  @override
  String get statHighestTile => 'Plus haute tuile';

  @override
  String get statTotalMerges => 'Fusions totales';

  @override
  String get statAverageScore => 'Score moyen';

  @override
  String get statFavouriteMode => 'Mode favori';

  @override
  String get statPlayTime => 'Temps de jeu';

  @override
  String get statLongestGame => 'Partie la plus longue';

  @override
  String get statsLifetime => 'Depuis toujours';

  @override
  String get statsByMode => 'Par mode';

  @override
  String get statsNotPlayed => 'Pas encore joué';

  @override
  String get statsTrials => 'Épreuves';

  @override
  String get statsDaily => 'Quotidien';

  @override
  String get statsChapters => 'Chapitres';

  @override
  String get appThemeForge => 'Forge';

  @override
  String objReachTile(int tile) {
    return 'Forgez une tuile $tile';
  }

  @override
  String objReachScore(int score) {
    final intl.NumberFormat scoreNumberFormat = intl
        .NumberFormat.decimalPattern(localeName);
    final String scoreString = scoreNumberFormat.format(score);

    return 'Marquez $scoreString points';
  }

  @override
  String objCreateTiles(int count, int tile) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tuiles',
      one: '$count tuile',
    );
    return 'Ayez $_temp0 de $tile';
  }

  @override
  String objSurvive(int moves) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: '$moves coups',
      one: '$moves coup',
    );
    return 'Tenez $_temp0';
  }

  @override
  String objClearBoard(int count) {
    return 'Réduisez à $count tuiles';
  }

  @override
  String get rankNovice => 'Novice';

  @override
  String get rankWarrior => 'Guerrier';

  @override
  String get rankChampion => 'Champion';

  @override
  String get rankTitan => 'Titan';

  @override
  String get rankLegend => 'Légende';

  @override
  String get chapterForge => 'La Forge';

  @override
  String get chapterProving => 'Le Terrain d\'Épreuve';

  @override
  String get chapterSummit => 'Le Sommet';

  @override
  String get chapterForgeTheme => 'Apprenez les objectifs';

  @override
  String get chapterProvingTheme => 'Cases bloquées, sans annuler';

  @override
  String get chapterSummitTheme => 'Le temps et le terrain ouvert';

  @override
  String get achFirstBlood => 'Premier Sang';

  @override
  String get achWarrior => 'Guerrier';

  @override
  String get achChampion => 'Champion';

  @override
  String get achTitanName => 'Titan';

  @override
  String get achBeyondGods => 'Au-delà des Dieux';

  @override
  String get achInitiate => 'Initié';

  @override
  String get achProven => 'Éprouvé';

  @override
  String get achTrialmaster => 'Maître des Épreuves';

  @override
  String get achForgedName => 'Forgé';

  @override
  String get achPerfectTrial => 'Épreuve Parfaite';

  @override
  String get achDedicated => 'Assidu';

  @override
  String get achRelentless => 'Implacable';

  @override
  String get achHoarder => 'Amasseur';

  @override
  String get achIronhand => 'Main de Fer';

  @override
  String get achVeteran => 'Vétéran';

  @override
  String achDescTrials(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Épreuves des Titans',
      one: '$count Épreuve des Titans',
    );
    return 'Terminez $_temp0';
  }

  @override
  String get achDescAllTrials => 'Terminez toutes les Épreuves des Titans';

  @override
  String get achDescChapter => 'Terminez un chapitre entier';

  @override
  String achDescCleanTrials(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count épreuves',
      one: '$count épreuve',
    );
    return 'Terminez $_temp0 sans annuler';
  }

  @override
  String achDescStreak(int days) {
    return 'Série de $days jours d\'Épreuve du Jour';
  }

  @override
  String achDescScore(int score) {
    return 'Marquez $score en une seule partie';
  }

  @override
  String achDescMerges(int count) {
    return 'Fusionnez $count tuiles au total';
  }

  @override
  String achDescGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parties',
      one: '$count partie',
    );
    return 'Jouez $_temp0';
  }

  @override
  String trialName(String numeral) {
    return 'Épreuve $numeral';
  }

  @override
  String get dailyTrialTitle => 'Épreuve du Jour des Titans';
}
