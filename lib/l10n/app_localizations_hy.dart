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
  String points(num p) {
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

  @override
  String get homeContinue => 'Շարունակել';

  @override
  String get homeNewGame => 'Նոր խաղ';

  @override
  String get homePlay => 'Խաղալ';

  @override
  String get homeChooseChallenge => 'Ընտրիր մարտահրավերը';

  @override
  String get homeDailyTrial => 'Օրվա փորձություն';

  @override
  String get homeTodaysChallenge => 'Այսօրվա մարտահրավերը';

  @override
  String get homeTitanTrials => 'Տիտանների փորձություններ';

  @override
  String get homeHallOfTitans => 'Տիտանների դահլիճ';

  @override
  String get homeGameModes => 'Խաղի ռեժիմներ';

  @override
  String get homeBest => 'Լավագույն';

  @override
  String homeStreakDays(int days) {
    return '$days օր անընդմեջ';
  }

  @override
  String get homeRank => 'Կոչում';

  @override
  String homeCompleted(int done, int total) {
    return '$done՝ $total-ից';
  }

  @override
  String get homePlayed => 'Շարունակել խաղը';

  @override
  String get modeClassic => 'Դասական';

  @override
  String get modeZen => 'Զեն';

  @override
  String get modeTimeAttack => 'Ժամանակի դեմ';

  @override
  String get modeHardcore => 'Ծանր';

  @override
  String get modeClassicDesc => 'Ռազմավարական հիմքը';

  @override
  String get modeZenDesc => 'Առանց միավորի և պարտության';

  @override
  String get modeTimeAttackDesc => 'Միացումները վայրկյան են տալիս';

  @override
  String get modeHardcoreDesc => '5x5, շատ սալիկ, առանց օգնության';

  @override
  String trialMoveLimit(int moves) {
    return '$moves քայլ';
  }

  @override
  String trialTimeLimit(int seconds) {
    return '$seconds վրկ';
  }

  @override
  String get trialNoUndo => 'Առանց հետարկման';

  @override
  String get trialNoHints => 'Առանց հուշումների';

  @override
  String get trialLocked => 'Փակ է';

  @override
  String get trialObjective => 'Նպատակ';

  @override
  String get trialComplete => 'Փորձությունն անցած է';

  @override
  String get trialFailed => 'Փորձությունը ձախողվեց';

  @override
  String get achievements => 'Նվաճումներ';

  @override
  String get pathOfTitans => 'Տիտանների ուղին';

  @override
  String get statGamesPlayed => 'Խաղացած խաղեր';

  @override
  String get statBestScore => 'Լավագույն միավոր';

  @override
  String get statHighestTile => 'Ամենաբարձր սալիկ';

  @override
  String get statTotalMerges => 'Ընդհանուր միացումներ';

  @override
  String get statAverageScore => 'Միջին միավոր';

  @override
  String get statFavouriteMode => 'Սիրելի ռեժիմ';

  @override
  String get statPlayTime => 'Խաղի ժամանակ';

  @override
  String get statLongestGame => 'Ամենաերկար խաղը';

  @override
  String get statsLifetime => 'Ընդհանուր';

  @override
  String get statsByMode => 'Ըստ ռեժիմի';

  @override
  String get statsNotPlayed => 'Դեռ չի խաղացվել';

  @override
  String get statsTrials => 'Փորձություններ';

  @override
  String get statsDaily => 'Օրվա';

  @override
  String get statsBestStreak => 'Շարք';

  @override
  String get statsChapters => 'Գլուխներ';

  @override
  String get appThemeForge => 'Դարբնոց';

  @override
  String objReachTile(int tile) {
    return 'Ստեղծիր $tile սալիկ';
  }

  @override
  String objReachScore(int score) {
    final intl.NumberFormat scoreNumberFormat = intl
        .NumberFormat.decimalPattern(localeName);
    final String scoreString = scoreNumberFormat.format(score);

    return 'Հավաքիր $scoreString միավոր';
  }

  @override
  String objCreateTiles(int count, int tile) {
    return 'Պահիր $count հատ $tile-անոց սալիկ';
  }

  @override
  String objSurvive(int moves) {
    return 'Դիմացիր $moves քայլ';
  }

  @override
  String objClearBoard(int count) {
    return 'Իջեցրու մինչև $count սալիկ';
  }

  @override
  String get rankNovice => 'Սկսնակ';

  @override
  String get rankWarrior => 'Մարտիկ';

  @override
  String get rankChampion => 'Ախոյան';

  @override
  String get rankTitan => 'Տիտան';

  @override
  String get rankLegend => 'Լեգենդ';

  @override
  String get chapterForge => 'Դարբնոցը';

  @override
  String get chapterProving => 'Փորձադաշտը';

  @override
  String get chapterSummit => 'Գագաթը';

  @override
  String get chapterForgeTheme => 'Սովորիր նպատակները';

  @override
  String get chapterProvingTheme => 'Փակ վանդակներ, առանց հետարկման';

  @override
  String get chapterSummitTheme => 'Ժամանակ և բաց դաշտ';

  @override
  String get achFirstBlood => 'Առաջին արյուն';

  @override
  String get achWarrior => 'Մարտիկ';

  @override
  String get achChampion => 'Չեմպիոն';

  @override
  String get achTitanName => 'Տիտան';

  @override
  String get achBeyondGods => 'Աստվածներից վեր';

  @override
  String get achInitiate => 'Նորընծա';

  @override
  String get achProven => 'Փորձված';

  @override
  String get achTrialmaster => 'Փորձությունների վարպետ';

  @override
  String get achForgedName => 'Կոփված';

  @override
  String get achPerfectTrial => 'Կատարյալ փորձություն';

  @override
  String get achDedicated => 'Նվիրված';

  @override
  String get achRelentless => 'Անդրդվելի';

  @override
  String get achHoarder => 'Կուտակող';

  @override
  String get achIronhand => 'Երկաթե ձեռք';

  @override
  String get achVeteran => 'Վետերան';

  @override
  String achDescTrials(int count) {
    return 'Անցեք տիտանների $count փորձություն';
  }

  @override
  String get achDescAllTrials => 'Անցեք տիտանների բոլոր փորձությունները';

  @override
  String get achDescChapter => 'Անցեք մի ամբողջ գլուխ';

  @override
  String achDescCleanTrials(int count) {
    return 'Անցեք $count փորձություն առանց հետարկման';
  }

  @override
  String achDescStreak(int days) {
    return 'Օրական փորձության $days օր անընդմեջ';
  }

  @override
  String achDescScore(int score) {
    return 'Հավաքեք $score միավոր մեկ խաղում';
  }

  @override
  String achDescMerges(int count) {
    return 'Միաձուլեք ընդամենը $count սալիկ';
  }

  @override
  String achDescGames(int count) {
    return 'Խաղացեք $count խաղ';
  }
}
