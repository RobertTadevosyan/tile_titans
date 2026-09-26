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

  @override
  String get homeContinue => 'Продолжить';

  @override
  String get homeNewGame => 'Новая игра';

  @override
  String get homePlay => 'Играть';

  @override
  String get homeChooseChallenge => 'Выберите испытание';

  @override
  String get homeDailyTrial => 'Ежедневное испытание';

  @override
  String get homeTodaysChallenge => 'Задача дня';

  @override
  String get homeTitanTrials => 'Испытания титанов';

  @override
  String get homeHallOfTitans => 'Зал титанов';

  @override
  String get homeGameModes => 'Режимы игры';

  @override
  String get homeBest => 'Лучший';

  @override
  String homeStreakDays(int days) {
    return 'Серия: $days дн.';
  }

  @override
  String get homeRank => 'Ранг';

  @override
  String homeCompleted(int done, int total) {
    return '$done из $total пройдено';
  }

  @override
  String get homePlayed => 'Продолжить партию';

  @override
  String get modeClassic => 'Классика';

  @override
  String get modeZen => 'Дзен';

  @override
  String get modeTimeAttack => 'На время';

  @override
  String get modeHardcore => 'Хардкор';

  @override
  String get modeClassicDesc => 'Основа стратегии';

  @override
  String get modeZenDesc => 'Без очков и проигрыша';

  @override
  String get modeTimeAttackDesc => 'Слияния дают секунды';

  @override
  String get modeHardcoreDesc => '5x5, частые фишки, без помощи';

  @override
  String trialMoveLimit(int moves) {
    return '$moves ходов';
  }

  @override
  String trialTimeLimit(int seconds) {
    return '$seconds с';
  }

  @override
  String get trialNoUndo => 'Без отмены';

  @override
  String get trialNoHints => 'Без подсказок';

  @override
  String get trialLocked => 'Закрыто';

  @override
  String get trialObjective => 'Цель';

  @override
  String get trialComplete => 'Испытание пройдено';

  @override
  String get trialFailed => 'Испытание провалено';

  @override
  String get achievements => 'Достижения';

  @override
  String get pathOfTitans => 'Путь титанов';

  @override
  String get statGamesPlayed => 'Сыграно игр';

  @override
  String get statBestScore => 'Лучший счёт';

  @override
  String get statHighestTile => 'Лучшая плитка';

  @override
  String get statTotalMerges => 'Всего слияний';

  @override
  String get statAverageScore => 'Средний счёт';

  @override
  String get statFavouriteMode => 'Любимый режим';

  @override
  String get statPlayTime => 'Время игры';

  @override
  String get statLongestGame => 'Самая длинная партия';
}
