// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Armenian (`hy`).
class AppLocalizationsHy extends AppLocalizations {
  AppLocalizationsHy([String locale = 'hy']) : super(locale);

  @override
  String get appTitle => 'Տիտաններ';

  @override
  String get autoPlay => 'Ինքնախաղ';

  @override
  String get restart => '🔄';

  @override
  String get undo => '↩️';

  @override
  String get hint => '💡';

  @override
  String hintMessage(Object direction) {
    return '💡 փորձիր շարժվել $direction';
  }

  @override
  String get statistics => 'Վիճակագրություն';

  @override
  String moves(Object moves) {
    return 'Քայլեր՝ $moves';
  }

  @override
  String merges(Object merges) {
    return 'Միացումներ՝ $merges';
  }

  @override
  String avgMerge(Object merges) {
    return 'Միջին միացում՝ $merges';
  }

  @override
  String mergeEfficiency(Object efficiency) {
    return 'Միացման արդյունավետություն՝ $efficiency%';
  }

  @override
  String get close => 'Փակել';

  @override
  String score(Object score) {
    return 'Միավոր՝ $score';
  }

  @override
  String highScore(Object highScore) {
    return 'Բարձր միավոր՝ $highScore';
  }

  @override
  String get settings => 'Կարգավորումներ';

  @override
  String get leaderboard => 'Առաջատարներ';

  @override
  String get findMe => 'Գտի՛ր ինձ';

  @override
  String get noScore => 'Դեռ միավորներ չկան։';

  @override
  String get rank => 'Դիրք';

  @override
  String get scoreTitle => 'Միավոր';

  @override
  String get platform => 'Հարթակ';

  @override
  String get device => 'Սարք';

  @override
  String get user => 'Օգտատեր';

  @override
  String points(Object p) {
    return '$p միավոր';
  }

  @override
  String get appSettings => 'Ծրագրի կարգավորումներ';

  @override
  String get soundEffects => 'Ձայնային էֆֆեկտներ';

  @override
  String get highScoreTitle => 'Բարձր միավոր';

  @override
  String get highScoreReset => 'Բարձր միավորը վերականգնվել է';

  @override
  String get gameMode => 'Խաղի ռեժիմ';

  @override
  String get aiDifficulty => 'ԱԲ դժվարություն';

  @override
  String get boardSize => 'Խաղատախտակի չափը';

  @override
  String get appTheme => 'Ծրագրի տեսք';

  @override
  String get language => 'Լեզու';

  @override
  String get restartGame => 'Վերամեկնարկել խաղը';

  @override
  String get gameModeNormal => 'Նորմալ';

  @override
  String get gameModeTimed => 'Ժամանակով';

  @override
  String get gameModeChallenge => 'Մրցույթ';

  @override
  String get gameModeEvilAI => 'Չար ԱԲ';

  @override
  String get gameModeHardcore => 'Դաժան';

  @override
  String get gameModeZen => 'Զեն';

  @override
  String get aiDiffEasy => 'Հեշտ';

  @override
  String get aiDiffSmart => 'Խելացի';

  @override
  String get aiDiffAggressive => 'Ագրեսիվ';

  @override
  String get appThemeClassic => 'Դասական';

  @override
  String get appThemeDark => 'Մութ';

  @override
  String get appThemeOcean => 'Ծով';

  @override
  String get appThemeRetro => 'Ռետրո';

  @override
  String get appThemeNeon => 'Նեոն';

  @override
  String get gameOver => 'Խաղը ավարտվեց';

  @override
  String get gameOverTitle => 'Խաղը ավարտվեց 🎮';

  @override
  String finalScore(Object score) {
    return 'Քո վերջնական միավորն է $score';
  }

  @override
  String get timeIsUp => 'Ժամանակը լրացավ!';
}
