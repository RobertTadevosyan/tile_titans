import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hy.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hy'),
    Locale('it'),
    Locale('ja'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tile Titans'**
  String get appTitle;

  /// No description provided for @autoPlay.
  ///
  /// In en, this message translates to:
  /// **'Auto Play'**
  String get autoPlay;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'🔄'**
  String get restart;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'↩️'**
  String get undo;

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'💡'**
  String get hint;

  /// No description provided for @hintMessage.
  ///
  /// In en, this message translates to:
  /// **'💡: Try moving {direction}'**
  String hintMessage(Object direction);

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @moves.
  ///
  /// In en, this message translates to:
  /// **'Moves: {moves}'**
  String moves(Object moves);

  /// No description provided for @merges.
  ///
  /// In en, this message translates to:
  /// **'Merges: {merges}'**
  String merges(Object merges);

  /// No description provided for @avgMerge.
  ///
  /// In en, this message translates to:
  /// **'Avg Merge: {merges}'**
  String avgMerge(Object merges);

  /// No description provided for @mergeEfficiency.
  ///
  /// In en, this message translates to:
  /// **'Merge Efficiency: {efficiency}%'**
  String mergeEfficiency(Object efficiency);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String score(Object score);

  /// No description provided for @highScore.
  ///
  /// In en, this message translates to:
  /// **'High Score: {highScore}'**
  String highScore(Object highScore);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @findMe.
  ///
  /// In en, this message translates to:
  /// **'Find Me'**
  String get findMe;

  /// No description provided for @noScore.
  ///
  /// In en, this message translates to:
  /// **'No scores yet.'**
  String get noScore;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @scoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get scoreTitle;

  /// No description provided for @platform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platform;

  /// No description provided for @device.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get device;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'{p, plural, =1{1 point} other{{p} points}}'**
  String points(num p);

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// No description provided for @highScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'High Score'**
  String get highScoreTitle;

  /// No description provided for @highScoreReset.
  ///
  /// In en, this message translates to:
  /// **'High score reset'**
  String get highScoreReset;

  /// No description provided for @gameMode.
  ///
  /// In en, this message translates to:
  /// **'Game Mode'**
  String get gameMode;

  /// No description provided for @aiDifficulty.
  ///
  /// In en, this message translates to:
  /// **'AI Difficulty'**
  String get aiDifficulty;

  /// No description provided for @boardSize.
  ///
  /// In en, this message translates to:
  /// **'Board Size'**
  String get boardSize;

  /// No description provided for @appTheme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get appTheme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @restartGame.
  ///
  /// In en, this message translates to:
  /// **'Restart Game'**
  String get restartGame;

  /// No description provided for @gameModeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get gameModeNormal;

  /// No description provided for @gameModeTimed.
  ///
  /// In en, this message translates to:
  /// **'Timed'**
  String get gameModeTimed;

  /// No description provided for @gameModeChallenge.
  ///
  /// In en, this message translates to:
  /// **'Challenge'**
  String get gameModeChallenge;

  /// No description provided for @gameModeEvilAI.
  ///
  /// In en, this message translates to:
  /// **'EvilAI'**
  String get gameModeEvilAI;

  /// No description provided for @gameModeHardcore.
  ///
  /// In en, this message translates to:
  /// **'Hardcore'**
  String get gameModeHardcore;

  /// No description provided for @gameModeZen.
  ///
  /// In en, this message translates to:
  /// **'Zen'**
  String get gameModeZen;

  /// No description provided for @aiDiffEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get aiDiffEasy;

  /// No description provided for @aiDiffSmart.
  ///
  /// In en, this message translates to:
  /// **'Smart'**
  String get aiDiffSmart;

  /// No description provided for @aiDiffAggressive.
  ///
  /// In en, this message translates to:
  /// **'Aggressive'**
  String get aiDiffAggressive;

  /// No description provided for @appThemeClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get appThemeClassic;

  /// No description provided for @appThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appThemeDark;

  /// No description provided for @appThemeOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get appThemeOcean;

  /// No description provided for @appThemeRetro.
  ///
  /// In en, this message translates to:
  /// **'Retro'**
  String get appThemeRetro;

  /// No description provided for @appThemeNeon.
  ///
  /// In en, this message translates to:
  /// **'Neon'**
  String get appThemeNeon;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOver;

  /// No description provided for @gameOverTitle.
  ///
  /// In en, this message translates to:
  /// **'Game Over 🎮'**
  String get gameOverTitle;

  /// No description provided for @finalScore.
  ///
  /// In en, this message translates to:
  /// **'Your final score is {score}'**
  String finalScore(Object score);

  /// No description provided for @timeIsUp.
  ///
  /// In en, this message translates to:
  /// **'Time\'s Up!'**
  String get timeIsUp;

  /// No description provided for @homeContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get homeContinue;

  /// No description provided for @homeNewGame.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get homeNewGame;

  /// No description provided for @homePlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get homePlay;

  /// No description provided for @homeChooseChallenge.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Challenge'**
  String get homeChooseChallenge;

  /// No description provided for @homeDailyTrial.
  ///
  /// In en, this message translates to:
  /// **'Daily Titan Trial'**
  String get homeDailyTrial;

  /// No description provided for @homeTodaysChallenge.
  ///
  /// In en, this message translates to:
  /// **'Today\'s challenge'**
  String get homeTodaysChallenge;

  /// No description provided for @homeTitanTrials.
  ///
  /// In en, this message translates to:
  /// **'Titan Trials'**
  String get homeTitanTrials;

  /// No description provided for @homeHallOfTitans.
  ///
  /// In en, this message translates to:
  /// **'Hall of Titans'**
  String get homeHallOfTitans;

  /// No description provided for @homeGameModes.
  ///
  /// In en, this message translates to:
  /// **'Game Modes'**
  String get homeGameModes;

  /// No description provided for @homeBest.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get homeBest;

  /// No description provided for @homeStreakDays.
  ///
  /// In en, this message translates to:
  /// **'{days} day streak'**
  String homeStreakDays(int days);

  /// No description provided for @homeRank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get homeRank;

  /// No description provided for @homeCompleted.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} complete'**
  String homeCompleted(int done, int total);

  /// No description provided for @homePlayed.
  ///
  /// In en, this message translates to:
  /// **'Resume your run'**
  String get homePlayed;

  /// No description provided for @modeClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get modeClassic;

  /// No description provided for @modeZen.
  ///
  /// In en, this message translates to:
  /// **'Zen'**
  String get modeZen;

  /// No description provided for @modeTimeAttack.
  ///
  /// In en, this message translates to:
  /// **'Time Attack'**
  String get modeTimeAttack;

  /// No description provided for @modeHardcore.
  ///
  /// In en, this message translates to:
  /// **'Hardcore'**
  String get modeHardcore;

  /// No description provided for @modeClassicDesc.
  ///
  /// In en, this message translates to:
  /// **'The strategic baseline'**
  String get modeClassicDesc;

  /// No description provided for @modeZenDesc.
  ///
  /// In en, this message translates to:
  /// **'No score, no game over'**
  String get modeZenDesc;

  /// No description provided for @modeTimeAttackDesc.
  ///
  /// In en, this message translates to:
  /// **'Merges buy you seconds'**
  String get modeTimeAttackDesc;

  /// No description provided for @modeHardcoreDesc.
  ///
  /// In en, this message translates to:
  /// **'5x5, heavy spawns, no help'**
  String get modeHardcoreDesc;

  /// No description provided for @trialMoveLimit.
  ///
  /// In en, this message translates to:
  /// **'{moves} moves'**
  String trialMoveLimit(int moves);

  /// No description provided for @trialTimeLimit.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String trialTimeLimit(int seconds);

  /// No description provided for @trialNoUndo.
  ///
  /// In en, this message translates to:
  /// **'No undo'**
  String get trialNoUndo;

  /// No description provided for @trialNoHints.
  ///
  /// In en, this message translates to:
  /// **'No hints'**
  String get trialNoHints;

  /// No description provided for @trialLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get trialLocked;

  /// No description provided for @trialObjective.
  ///
  /// In en, this message translates to:
  /// **'Objective'**
  String get trialObjective;

  /// No description provided for @trialComplete.
  ///
  /// In en, this message translates to:
  /// **'Trial complete'**
  String get trialComplete;

  /// No description provided for @trialFailed.
  ///
  /// In en, this message translates to:
  /// **'Trial failed'**
  String get trialFailed;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @pathOfTitans.
  ///
  /// In en, this message translates to:
  /// **'Path of the Titans'**
  String get pathOfTitans;

  /// No description provided for @statGamesPlayed.
  ///
  /// In en, this message translates to:
  /// **'Games played'**
  String get statGamesPlayed;

  /// No description provided for @statBestScore.
  ///
  /// In en, this message translates to:
  /// **'Best score'**
  String get statBestScore;

  /// No description provided for @statHighestTile.
  ///
  /// In en, this message translates to:
  /// **'Highest tile'**
  String get statHighestTile;

  /// No description provided for @statTotalMerges.
  ///
  /// In en, this message translates to:
  /// **'Total merges'**
  String get statTotalMerges;

  /// No description provided for @statAverageScore.
  ///
  /// In en, this message translates to:
  /// **'Average score'**
  String get statAverageScore;

  /// No description provided for @statFavouriteMode.
  ///
  /// In en, this message translates to:
  /// **'Favourite mode'**
  String get statFavouriteMode;

  /// No description provided for @statPlayTime.
  ///
  /// In en, this message translates to:
  /// **'Play time'**
  String get statPlayTime;

  /// No description provided for @statLongestGame.
  ///
  /// In en, this message translates to:
  /// **'Longest game'**
  String get statLongestGame;

  /// No description provided for @statsLifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get statsLifetime;

  /// No description provided for @statsByMode.
  ///
  /// In en, this message translates to:
  /// **'By mode'**
  String get statsByMode;

  /// No description provided for @statsNotPlayed.
  ///
  /// In en, this message translates to:
  /// **'Not played yet'**
  String get statsNotPlayed;

  /// No description provided for @statsTrials.
  ///
  /// In en, this message translates to:
  /// **'Trials'**
  String get statsTrials;

  /// No description provided for @statsDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get statsDaily;

  /// No description provided for @statsBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get statsBestStreak;

  /// No description provided for @statsChapters.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get statsChapters;

  /// No description provided for @appThemeForge.
  ///
  /// In en, this message translates to:
  /// **'Forge'**
  String get appThemeForge;

  /// No description provided for @objReachTile.
  ///
  /// In en, this message translates to:
  /// **'Forge a {tile} tile'**
  String objReachTile(int tile);

  /// No description provided for @objReachScore.
  ///
  /// In en, this message translates to:
  /// **'Score {score}'**
  String objReachScore(int score);

  /// No description provided for @objCreateTiles.
  ///
  /// In en, this message translates to:
  /// **'Hold {count, plural, =1{1 tile} other{{count} tiles}} of {tile}'**
  String objCreateTiles(int count, int tile);

  /// No description provided for @objSurvive.
  ///
  /// In en, this message translates to:
  /// **'Survive {moves, plural, =1{1 move} other{{moves} moves}}'**
  String objSurvive(int moves);

  /// No description provided for @objClearBoard.
  ///
  /// In en, this message translates to:
  /// **'Collapse to {count} tiles'**
  String objClearBoard(int count);

  /// No description provided for @rankNovice.
  ///
  /// In en, this message translates to:
  /// **'Novice'**
  String get rankNovice;

  /// No description provided for @rankWarrior.
  ///
  /// In en, this message translates to:
  /// **'Warrior'**
  String get rankWarrior;

  /// No description provided for @rankChampion.
  ///
  /// In en, this message translates to:
  /// **'Champion'**
  String get rankChampion;

  /// No description provided for @rankTitan.
  ///
  /// In en, this message translates to:
  /// **'Titan'**
  String get rankTitan;

  /// No description provided for @rankLegend.
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get rankLegend;

  /// No description provided for @chapterForge.
  ///
  /// In en, this message translates to:
  /// **'The Forge'**
  String get chapterForge;

  /// No description provided for @chapterProving.
  ///
  /// In en, this message translates to:
  /// **'The Proving Ground'**
  String get chapterProving;

  /// No description provided for @chapterSummit.
  ///
  /// In en, this message translates to:
  /// **'The Summit'**
  String get chapterSummit;

  /// No description provided for @chapterForgeTheme.
  ///
  /// In en, this message translates to:
  /// **'Learn the objectives'**
  String get chapterForgeTheme;

  /// No description provided for @chapterProvingTheme.
  ///
  /// In en, this message translates to:
  /// **'Blocked cells and no undo'**
  String get chapterProvingTheme;

  /// No description provided for @chapterSummitTheme.
  ///
  /// In en, this message translates to:
  /// **'Time pressure and open ground'**
  String get chapterSummitTheme;

  /// No description provided for @achFirstBlood.
  ///
  /// In en, this message translates to:
  /// **'First Blood'**
  String get achFirstBlood;

  /// No description provided for @achWarrior.
  ///
  /// In en, this message translates to:
  /// **'Warrior'**
  String get achWarrior;

  /// No description provided for @achChampion.
  ///
  /// In en, this message translates to:
  /// **'Champion'**
  String get achChampion;

  /// No description provided for @achTitanName.
  ///
  /// In en, this message translates to:
  /// **'Titan'**
  String get achTitanName;

  /// No description provided for @achBeyondGods.
  ///
  /// In en, this message translates to:
  /// **'Beyond the Gods'**
  String get achBeyondGods;

  /// No description provided for @achInitiate.
  ///
  /// In en, this message translates to:
  /// **'Initiate'**
  String get achInitiate;

  /// No description provided for @achProven.
  ///
  /// In en, this message translates to:
  /// **'Proven'**
  String get achProven;

  /// No description provided for @achTrialmaster.
  ///
  /// In en, this message translates to:
  /// **'Trialmaster'**
  String get achTrialmaster;

  /// No description provided for @achForgedName.
  ///
  /// In en, this message translates to:
  /// **'Forged'**
  String get achForgedName;

  /// No description provided for @achPerfectTrial.
  ///
  /// In en, this message translates to:
  /// **'Perfect Trial'**
  String get achPerfectTrial;

  /// No description provided for @achDedicated.
  ///
  /// In en, this message translates to:
  /// **'Dedicated'**
  String get achDedicated;

  /// No description provided for @achRelentless.
  ///
  /// In en, this message translates to:
  /// **'Relentless'**
  String get achRelentless;

  /// No description provided for @achHoarder.
  ///
  /// In en, this message translates to:
  /// **'Hoarder'**
  String get achHoarder;

  /// No description provided for @achIronhand.
  ///
  /// In en, this message translates to:
  /// **'Ironhand'**
  String get achIronhand;

  /// No description provided for @achVeteran.
  ///
  /// In en, this message translates to:
  /// **'Veteran'**
  String get achVeteran;

  /// No description provided for @achDescTrials.
  ///
  /// In en, this message translates to:
  /// **'Complete {count, plural, =1{1 Titan Trial} other{{count} Titan Trials}}'**
  String achDescTrials(int count);

  /// No description provided for @achDescAllTrials.
  ///
  /// In en, this message translates to:
  /// **'Complete every Titan Trial'**
  String get achDescAllTrials;

  /// No description provided for @achDescChapter.
  ///
  /// In en, this message translates to:
  /// **'Complete a full chapter'**
  String get achDescChapter;

  /// No description provided for @achDescCleanTrials.
  ///
  /// In en, this message translates to:
  /// **'Complete {count, plural, =1{1 trial} other{{count} trials}} without undo'**
  String achDescCleanTrials(int count);

  /// No description provided for @achDescStreak.
  ///
  /// In en, this message translates to:
  /// **'A {days}-day Daily Trial streak'**
  String achDescStreak(int days);

  /// No description provided for @achDescScore.
  ///
  /// In en, this message translates to:
  /// **'Score {score} in a single run'**
  String achDescScore(int score);

  /// No description provided for @achDescMerges.
  ///
  /// In en, this message translates to:
  /// **'Merge {count} tiles in total'**
  String achDescMerges(int count);

  /// No description provided for @achDescGames.
  ///
  /// In en, this message translates to:
  /// **'Play {count, plural, =1{1 game} other{{count} games}}'**
  String achDescGames(int count);

  /// No description provided for @trialName.
  ///
  /// In en, this message translates to:
  /// **'Trial {numeral}'**
  String trialName(String numeral);

  /// No description provided for @dailyTrialTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Titan Trial'**
  String get dailyTrialTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'hy',
    'it',
    'ja',
    'pt',
    'ru',
    'tr',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hy':
      return AppLocalizationsHy();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
