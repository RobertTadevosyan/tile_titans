import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_hy.dart';
import 'app_localizations_ru.dart';

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
    Locale('en'),
    Locale('es'),
    Locale('hy'),
    Locale('ru'),
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
  /// **'{p} points'**
  String points(Object p);

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
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'hy', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'hy':
      return AppLocalizationsHy();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
