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
}
