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
  String points(Object p) {
    return '$p puntos';
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
  String get gameMode => 'Modo de juego';

  @override
  String get aiDifficulty => 'Dificultad IA';

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
  String get gameModeChallenge => 'Desafío';

  @override
  String get gameModeEvilAI => 'IA malvada';

  @override
  String get gameModeHardcore => 'Extremo';

  @override
  String get gameModeZen => 'Zen';

  @override
  String get aiDiffEasy => 'Fácil';

  @override
  String get aiDiffSmart => 'Inteligente';

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
  String get homeNewGame => 'Partida nueva';

  @override
  String get homePlay => 'Jugar';

  @override
  String get homeChooseChallenge => 'Elige tu desafío';

  @override
  String get homeDailyTrial => 'Prueba diaria';

  @override
  String get homeTodaysChallenge => 'Desafío de hoy';

  @override
  String get homeTitanTrials => 'Pruebas de Titán';

  @override
  String get homeHallOfTitans => 'Salón de los Titanes';

  @override
  String get homeGameModes => 'Modos de juego';

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
  String get trialLocked => 'Bloqueado';

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
  String get statsBestStreak => 'Racha';

  @override
  String get statsChapters => 'Capítulos';

  @override
  String get appThemeForge => 'Forja';
}
