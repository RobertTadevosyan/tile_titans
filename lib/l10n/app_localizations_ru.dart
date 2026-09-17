// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Титаны';

  @override
  String get autoPlay => 'Автоигра';

  @override
  String get restart => '🔄';

  @override
  String get undo => '↩️';

  @override
  String get hint => '💡';

  @override
  String hintMessage(Object direction) {
    return '💡: попробуйте сдвинуть $direction';
  }

  @override
  String get statistics => 'Статистика';

  @override
  String moves(Object moves) {
    return 'Ходы: $moves';
  }

  @override
  String merges(Object merges) {
    return 'Слияния: $merges';
  }

  @override
  String avgMerge(Object merges) {
    return 'Среднее слияние: $merges';
  }

  @override
  String mergeEfficiency(Object efficiency) {
    return 'Эффективность слияния: $efficiency%';
  }

  @override
  String get close => 'Закрыть';

  @override
  String score(Object score) {
    return 'Счёт: $score';
  }

  @override
  String highScore(Object highScore) {
    return 'Рекорд: $highScore';
  }

  @override
  String get settings => 'Настройки';

  @override
  String get leaderboard => 'Таблица лидеров';

  @override
  String get findMe => 'Найти меня';

  @override
  String get noScore => 'Пока нет результатов.';

  @override
  String get rank => 'Ранг';

  @override
  String get scoreTitle => 'Очки';

  @override
  String get platform => 'Платформа';

  @override
  String get device => 'Устройство';

  @override
  String get user => 'Пользователь';

  @override
  String points(Object p) {
    return '$p очков';
  }

  @override
  String get appSettings => 'Настройки приложения';

  @override
  String get soundEffects => 'Звуковые эффекты';

  @override
  String get highScoreTitle => 'Рекорд';

  @override
  String get highScoreReset => 'Рекорд сброшен';

  @override
  String get gameMode => 'Режим игры';

  @override
  String get aiDifficulty => 'Сложность ИИ';

  @override
  String get boardSize => 'Размер поля';

  @override
  String get appTheme => 'Тема';

  @override
  String get language => 'Язык';

  @override
  String get restartGame => 'Перезапустить игру';

  @override
  String get gameModeNormal => 'Обычный';

  @override
  String get gameModeTimed => 'На время';

  @override
  String get gameModeChallenge => 'Испытание';

  @override
  String get gameModeEvilAI => 'Злой ИИ';

  @override
  String get gameModeHardcore => 'Хардкор';

  @override
  String get gameModeZen => 'Дзен';

  @override
  String get aiDiffEasy => 'Лёгкий';

  @override
  String get aiDiffSmart => 'Умный';

  @override
  String get aiDiffAggressive => 'Агрессивный';

  @override
  String get appThemeClassic => 'Классика';

  @override
  String get appThemeDark => 'Тёмный';

  @override
  String get appThemeOcean => 'Океан';

  @override
  String get appThemeRetro => 'Ретро';

  @override
  String get appThemeNeon => 'Неон';

  @override
  String get gameOver => 'Конец игры';

  @override
  String get gameOverTitle => 'Конец игры 🎮';

  @override
  String finalScore(Object score) {
    return 'Ваш итоговый счёт: $score';
  }

  @override
  String get timeIsUp => 'Время вышло!';
}
