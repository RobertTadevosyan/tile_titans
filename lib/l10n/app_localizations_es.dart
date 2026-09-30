// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Titanes del Azulejo';

  @override
  String get autoPlay => 'Reproducción automática';

  @override
  String get restart => '🔄';

  @override
  String get undo => '↩️';

  @override
  String get hint => '💡';

  @override
  String hintMessage(Object direction) {
    return '💡: Intenta mover $direction';
  }

  @override
  String get statistics => 'Estadísticas';

  @override
  String moves(Object moves) {
    return 'Movimientos: $moves';
  }

  @override
  String merges(Object merges) {
    return 'Fusiones: $merges';
  }

  @override
  String avgMerge(Object merges) {
    return 'Promedio de fusión: $merges';
  }

  @override
  String mergeEfficiency(Object efficiency) {
    return 'Eficiencia de fusión: $efficiency%';
  }

  @override
  String get close => 'Cerrar';

  @override
  String score(Object score) {
    return 'Puntuación: $score';
  }

  @override
  String highScore(Object highScore) {
    return 'Puntuación más alta: $highScore';
  }

  @override
  String get settings => 'Configuraciones';

  @override
  String get leaderboard => 'Clasificación';

  @override
  String get findMe => 'Encuéntrame';

  @override
  String get noScore => 'Aún no hay puntuaciones.';

  @override
  String get rank => 'Rango';

  @override
  String get scoreTitle => 'Puntuación';

  @override
  String get platform => 'Plataforma';

  @override
  String get device => 'Dispositivo';

  @override
  String get user => 'Usuario';

  @override
  String points(num p) {
    String _temp0 = intl.Intl.pluralLogic(
      p,
      locale: localeName,
      other: '$p puntos',
      one: '1 punto',
    );
    return '$_temp0';
  }

  @override
  String get appSettings => 'Configuración de la aplicación';

  @override
  String get soundEffects => 'Efectos de sonido';

  @override
  String get highScoreTitle => 'Puntuación más alta';

  @override
  String get highScoreReset => 'Puntuación más alta restablecida';

  @override
  String get aiDifficulty => 'Estilo de pistas';

  @override
  String get boardSize => 'Tamaño del tablero';

  @override
  String get appTheme => 'Tema de la aplicación';

  @override
  String get language => 'Idioma';

  @override
  String get restartGame => 'Reiniciar juego';

  @override
  String get gameModeNormal => 'Normal';

  @override
  String get gameModeTimed => 'Temporizado';

  @override
  String get gameModeHardcore => 'Extremo';

  @override
  String get gameModeZen => 'Zen';

  @override
  String get aiDiffEasy => 'Prudente';

  @override
  String get aiDiffSmart => 'Equilibrado';

  @override
  String get aiDiffAggressive => 'Agresivo';

  @override
  String get appThemeClassic => 'Clásico';

  @override
  String get appThemeDark => 'Oscuro';

  @override
  String get appThemeOcean => 'Océano';

  @override
  String get appThemeRetro => 'Retro';

  @override
  String get appThemeNeon => 'Neón';

  @override
  String get gameOver => 'Fin del juego';

  @override
  String get gameOverTitle => 'Fin del juego 🎮';

  @override
  String finalScore(Object score) {
    return 'Tu puntuación final es $score';
  }

  @override
  String get timeIsUp => '¡Se acabó el tiempo!';

  @override
  String get homeContinue => 'Continuar';

  @override
  String get homeChooseChallenge => 'Elige tu desafío';

  @override
  String get homeDailyTrial => 'Prueba diaria';

  @override
  String get homeTitanTrials => 'Pruebas de Titán';

  @override
  String get homeHallOfTitans => 'Salón de los Titanes';

  @override
  String get homeBest => 'Mejor';

  @override
  String homeStreakDays(int days) {
    return 'Racha de $days días';
  }

  @override
  String get homeRank => 'Rango';

  @override
  String homeCompleted(int done, int total) {
    return '$done de $total completadas';
  }

  @override
  String get homePlayed => 'Reanudar partida';

  @override
  String get modeClassic => 'Clásico';

  @override
  String get modeZen => 'Zen';

  @override
  String get modeTimeAttack => 'Contrarreloj';

  @override
  String get modeHardcore => 'Extremo';

  @override
  String get modeClassicDesc => 'La base estratégica';

  @override
  String get modeZenDesc => 'Sin puntos ni derrota';

  @override
  String get modeTimeAttackDesc => 'Las fusiones dan segundos';

  @override
  String get modeHardcoreDesc => '5x5, más fichas, sin ayuda';

  @override
  String trialMoveLimit(int moves) {
    return '$moves movimientos';
  }

  @override
  String trialTimeLimit(int seconds) {
    return '$seconds s';
  }

  @override
  String get trialNoUndo => 'Sin deshacer';

  @override
  String get trialNoHints => 'Sin pistas';

  @override
  String get trialObjective => 'Objetivo';

  @override
  String get trialComplete => 'Prueba superada';

  @override
  String get trialFailed => 'Prueba fallida';

  @override
  String get achievements => 'Logros';

  @override
  String get pathOfTitans => 'Senda de los Titanes';

  @override
  String get statGamesPlayed => 'Partidas jugadas';

  @override
  String get statBestScore => 'Mejor puntuación';

  @override
  String get statHighestTile => 'Ficha más alta';

  @override
  String get statTotalMerges => 'Fusiones totales';

  @override
  String get statAverageScore => 'Puntuación media';

  @override
  String get statFavouriteMode => 'Modo favorito';

  @override
  String get statPlayTime => 'Tiempo jugado';

  @override
  String get statLongestGame => 'Partida más larga';

  @override
  String get statsLifetime => 'Histórico';

  @override
  String get statsByMode => 'Por modo';

  @override
  String get statsNotPlayed => 'Aún sin jugar';

  @override
  String get statsTrials => 'Pruebas';

  @override
  String get statsDaily => 'Diarias';

  @override
  String get statsChapters => 'Capítulos';

  @override
  String get appThemeForge => 'Forja';

  @override
  String objReachTile(int tile) {
    return 'Forja una ficha $tile';
  }

  @override
  String objReachScore(int score) {
    final intl.NumberFormat scoreNumberFormat = intl
        .NumberFormat.decimalPattern(localeName);
    final String scoreString = scoreNumberFormat.format(score);

    return 'Consigue $scoreString puntos';
  }

  @override
  String objCreateTiles(int count, int tile) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichas',
      one: '1 ficha',
    );
    return 'Ten $_temp0 de $tile';
  }

  @override
  String objSurvive(int moves) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: '$moves movimientos',
      one: '1 movimiento',
    );
    return 'Sobrevive $_temp0';
  }

  @override
  String objClearBoard(int count) {
    return 'Reduce a $count fichas';
  }

  @override
  String get rankNovice => 'Novato';

  @override
  String get rankWarrior => 'Guerrero';

  @override
  String get rankChampion => 'Campeón';

  @override
  String get rankTitan => 'Titán';

  @override
  String get rankLegend => 'Leyenda';

  @override
  String get chapterForge => 'La Forja';

  @override
  String get chapterProving => 'El Campo de Pruebas';

  @override
  String get chapterSummit => 'La Cumbre';

  @override
  String get chapterForgeTheme => 'Aprende los objetivos';

  @override
  String get chapterProvingTheme => 'Celdas bloqueadas y sin deshacer';

  @override
  String get chapterSummitTheme => 'Contrarreloj y campo abierto';

  @override
  String get achFirstBlood => 'Primera Sangre';

  @override
  String get achWarrior => 'Guerrero';

  @override
  String get achChampion => 'Campeón';

  @override
  String get achTitanName => 'Titán';

  @override
  String get achBeyondGods => 'Más Allá de los Dioses';

  @override
  String get achInitiate => 'Iniciado';

  @override
  String get achProven => 'Probado';

  @override
  String get achTrialmaster => 'Maestro de Pruebas';

  @override
  String get achForgedName => 'Forjado';

  @override
  String get achPerfectTrial => 'Prueba Perfecta';

  @override
  String get achDedicated => 'Constante';

  @override
  String get achRelentless => 'Implacable';

  @override
  String get achHoarder => 'Acaparador';

  @override
  String get achIronhand => 'Mano de Hierro';

  @override
  String get achVeteran => 'Veterano';

  @override
  String achDescTrials(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Pruebas de Titanes',
      one: '1 Prueba de Titanes',
    );
    return 'Completa $_temp0';
  }

  @override
  String get achDescAllTrials => 'Completa todas las Pruebas de Titanes';

  @override
  String get achDescChapter => 'Completa un capítulo entero';

  @override
  String achDescCleanTrials(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pruebas',
      one: '1 prueba',
    );
    return 'Completa $_temp0 sin deshacer';
  }

  @override
  String achDescStreak(int days) {
    return 'Racha de $days días en la Prueba Diaria';
  }

  @override
  String achDescScore(int score) {
    return 'Consigue $score en una sola partida';
  }

  @override
  String achDescMerges(int count) {
    return 'Fusiona $count fichas en total';
  }

  @override
  String achDescGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partidas',
      one: '1 partida',
    );
    return 'Juega $_temp0';
  }

  @override
  String trialName(String numeral) {
    return 'Prueba $numeral';
  }

  @override
  String get dailyTrialTitle => 'Prueba Diaria de Titanes';

  @override
  String get findMeNoEntry => 'Aún no tienes puntuación en esta tabla';
}
