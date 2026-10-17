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
  String points(num p) {
    String _temp0 = intl.Intl.pluralLogic(
      p,
      locale: localeName,
      other: '$p очка',
      many: '$p очков',
      few: '$p очка',
      one: '$p очко',
    );
    return '$_temp0';
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
  String get aiDifficulty => 'Стиль подсказок';

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
  String get gameModeHardcore => 'Хардкор';

  @override
  String get gameModeZen => 'Дзен';

  @override
  String get aiDiffEasy => 'Осторожный';

  @override
  String get aiDiffSmart => 'Сбалансированный';

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
  String get homeChooseChallenge => 'Выберите испытание';

  @override
  String get homeDailyTrial => 'Ежедневное испытание';

  @override
  String get homeTitanTrials => 'Испытания титанов';

  @override
  String get homeHallOfTitans => 'Зал титанов';

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

  @override
  String get statsLifetime => 'За всё время';

  @override
  String get statsByMode => 'По режимам';

  @override
  String get statsNotPlayed => 'Ещё не играли';

  @override
  String get statsTrials => 'Испытания';

  @override
  String get statsDaily => 'Ежедневные';

  @override
  String get statsChapters => 'Главы';

  @override
  String get appThemeForge => 'Горн';

  @override
  String objReachTile(int tile) {
    return 'Создайте плитку $tile';
  }

  @override
  String objReachScore(int score) {
    final intl.NumberFormat scoreNumberFormat = intl
        .NumberFormat.decimalPattern(localeName);
    final String scoreString = scoreNumberFormat.format(score);

    return 'Наберите $scoreString';
  }

  @override
  String objCreateTiles(int count, int tile) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count плитки',
      many: '$count плиток',
      few: '$count плитки',
      one: '$count плитку',
    );
    return 'Соберите $_temp0 по $tile';
  }

  @override
  String objSurvive(int moves) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: '$moves хода',
      many: '$moves ходов',
      few: '$moves хода',
      one: '$moves ход',
    );
    return 'Продержитесь $_temp0';
  }

  @override
  String objClearBoard(int count) {
    return 'Сведите до $count плиток';
  }

  @override
  String get rankNovice => 'Новичок';

  @override
  String get rankWarrior => 'Воин';

  @override
  String get rankChampion => 'Чемпион';

  @override
  String get rankTitan => 'Титан';

  @override
  String get rankLegend => 'Легенда';

  @override
  String get chapterForge => 'Горн';

  @override
  String get chapterProving => 'Испытательное поле';

  @override
  String get chapterSummit => 'Вершина';

  @override
  String get chapterForgeTheme => 'Знакомство с целями';

  @override
  String get chapterProvingTheme => 'Закрытые клетки, без отмены';

  @override
  String get chapterSummitTheme => 'Время и открытое поле';

  @override
  String get achFirstBlood => 'Первая кровь';

  @override
  String get achWarrior => 'Воин';

  @override
  String get achChampion => 'Чемпион';

  @override
  String get achTitanName => 'Титан';

  @override
  String get achBeyondGods => 'Превыше богов';

  @override
  String get achInitiate => 'Посвящённый';

  @override
  String get achProven => 'Испытанный';

  @override
  String get achTrialmaster => 'Мастер испытаний';

  @override
  String get achForgedName => 'Закалённый';

  @override
  String get achPerfectTrial => 'Безупречное испытание';

  @override
  String get achDedicated => 'Преданный';

  @override
  String get achRelentless => 'Неумолимый';

  @override
  String get achHoarder => 'Скопидом';

  @override
  String get achIronhand => 'Железная рука';

  @override
  String get achVeteran => 'Ветеран';

  @override
  String achDescTrials(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count испытания',
      many: '$count испытаний',
      few: '$count испытания',
      one: '$count испытание',
    );
    return 'Пройдите $_temp0 титанов';
  }

  @override
  String get achDescAllTrials => 'Пройдите все испытания титанов';

  @override
  String get achDescChapter => 'Пройдите главу целиком';

  @override
  String achDescCleanTrials(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count испытания',
      many: '$count испытаний',
      few: '$count испытания',
      one: '$count испытание',
    );
    return 'Пройдите $_temp0 без отмены';
  }

  @override
  String achDescStreak(int days) {
    return 'Серия ежедневных испытаний: $days дней';
  }

  @override
  String achDescScore(int score) {
    return 'Наберите $score за одну партию';
  }

  @override
  String achDescMerges(int count) {
    return 'Объедините $count плиток всего';
  }

  @override
  String achDescGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count партии',
      many: '$count партий',
      few: '$count партии',
      one: '$count партию',
    );
    return 'Сыграйте $_temp0';
  }

  @override
  String trialName(String numeral) {
    return 'Испытание $numeral';
  }

  @override
  String get dailyTrialTitle => 'Ежедневное испытание титанов';

  @override
  String get findMeNoEntry => 'У вас пока нет результата в этой таблице';

  @override
  String get moreGames => 'Другие игры';

  @override
  String get moreGamesSubtitle => 'Другие игры этого разработчика';

  @override
  String get moreGamesRate => 'Оценить';

  @override
  String moreGamesEnjoying(String appName) {
    return 'Нравится $appName?';
  }

  @override
  String get moreGamesRateBody =>
      'Оценка займёт минуту и поможет другим игрокам найти игру.';

  @override
  String get moreGamesEmpty => 'Пока нечего показать. Загляните позже.';

  @override
  String get moreGamesOpenInStore => 'Открыть в магазине';

  @override
  String get moreGamesOpenFailed => 'Не удалось открыть магазин.';
}
