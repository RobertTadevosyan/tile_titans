// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Tile Titans';

  @override
  String get autoPlay => 'オート';

  @override
  String get restart => '🔄';

  @override
  String get undo => '↩️';

  @override
  String get hint => '💡';

  @override
  String hintMessage(Object direction) {
    return '💡: $direction に動かしてみよう';
  }

  @override
  String get statistics => '統計';

  @override
  String moves(Object moves) {
    return '手数: $moves';
  }

  @override
  String merges(Object merges) {
    return '合成: $merges';
  }

  @override
  String avgMerge(Object merges) {
    return '平均合成: $merges';
  }

  @override
  String mergeEfficiency(Object efficiency) {
    return '効率: $efficiency%';
  }

  @override
  String get close => '閉じる';

  @override
  String score(Object score) {
    return 'スコア: $score';
  }

  @override
  String highScore(Object highScore) {
    return '最高記録: $highScore';
  }

  @override
  String get settings => '設定';

  @override
  String get leaderboard => 'ランキング';

  @override
  String get findMe => '自分を探す';

  @override
  String get noScore => 'まだ記録がありません。';

  @override
  String get rank => '称号';

  @override
  String get scoreTitle => 'スコア';

  @override
  String get platform => 'プラットフォーム';

  @override
  String get device => '端末';

  @override
  String get user => 'プレイヤー';

  @override
  String points(Object p) {
    return '$p 点';
  }

  @override
  String get appSettings => '設定';

  @override
  String get soundEffects => '効果音';

  @override
  String get highScoreTitle => '最高記録';

  @override
  String get highScoreReset => '最高記録をリセット';

  @override
  String get gameMode => 'ゲームモード';

  @override
  String get aiDifficulty => 'AIの強さ';

  @override
  String get boardSize => '盤面サイズ';

  @override
  String get appTheme => 'テーマ';

  @override
  String get language => '言語';

  @override
  String get restartGame => 'やり直す';

  @override
  String get gameModeNormal => 'ノーマル';

  @override
  String get gameModeTimed => 'タイム';

  @override
  String get gameModeChallenge => 'チャレンジ';

  @override
  String get gameModeEvilAI => 'イービルAI';

  @override
  String get gameModeHardcore => 'ハードコア';

  @override
  String get gameModeZen => '禅';

  @override
  String get aiDiffEasy => 'やさしい';

  @override
  String get aiDiffSmart => 'かしこい';

  @override
  String get aiDiffAggressive => '攻撃的';

  @override
  String get appThemeClassic => 'クラシック';

  @override
  String get appThemeDark => 'ダーク';

  @override
  String get appThemeOcean => 'オーシャン';

  @override
  String get appThemeRetro => 'レトロ';

  @override
  String get appThemeNeon => 'ネオン';

  @override
  String get gameOver => 'ゲームオーバー';

  @override
  String get gameOverTitle => 'ゲームオーバー 🎮';

  @override
  String finalScore(Object score) {
    return '最終スコアは $score です';
  }

  @override
  String get timeIsUp => '時間切れ！';

  @override
  String get homeContinue => 'つづきから';

  @override
  String get homeNewGame => '新しいゲーム';

  @override
  String get homePlay => 'プレイ';

  @override
  String get homeChooseChallenge => '挑戦を選ぶ';

  @override
  String get homeDailyTrial => 'デイリー試練';

  @override
  String get homeTodaysChallenge => '今日の課題';

  @override
  String get homeTitanTrials => 'タイタンの試練';

  @override
  String get homeHallOfTitans => 'タイタンの殿堂';

  @override
  String get homeGameModes => 'ゲームモード';

  @override
  String get homeBest => '最高';

  @override
  String homeStreakDays(int days) {
    return '$days日連続';
  }

  @override
  String get homeRank => '称号';

  @override
  String homeCompleted(int done, int total) {
    return '$total 中 $done';
  }

  @override
  String get homePlayed => 'プレイを再開';

  @override
  String get modeClassic => 'クラシック';

  @override
  String get modeZen => '禅';

  @override
  String get modeTimeAttack => 'タイムアタック';

  @override
  String get modeHardcore => 'ハードコア';

  @override
  String get modeClassicDesc => '戦略の基本';

  @override
  String get modeZenDesc => 'スコアも敗北もなし';

  @override
  String get modeTimeAttackDesc => '合成で時間が増える';

  @override
  String get modeHardcoreDesc => '5x5、多い出現、補助なし';

  @override
  String trialMoveLimit(int moves) {
    return '$moves 手';
  }

  @override
  String trialTimeLimit(int seconds) {
    return '$seconds 秒';
  }

  @override
  String get trialNoUndo => '取り消し不可';

  @override
  String get trialNoHints => 'ヒントなし';

  @override
  String get trialLocked => 'ロック中';

  @override
  String get trialObjective => '目標';

  @override
  String get trialComplete => '試練クリア';

  @override
  String get trialFailed => '試練失敗';

  @override
  String get achievements => '実績';

  @override
  String get pathOfTitans => 'タイタンの道';

  @override
  String get statGamesPlayed => 'プレイ回数';

  @override
  String get statBestScore => '最高スコア';

  @override
  String get statHighestTile => '最高タイル';

  @override
  String get statTotalMerges => '合成回数';

  @override
  String get statAverageScore => '平均スコア';

  @override
  String get statFavouriteMode => 'よく遊ぶモード';

  @override
  String get statPlayTime => 'プレイ時間';

  @override
  String get statLongestGame => '最長プレイ';

  @override
  String get statsLifetime => '通算';

  @override
  String get statsByMode => 'モード別';

  @override
  String get statsNotPlayed => '未プレイ';

  @override
  String get statsTrials => '試練';

  @override
  String get statsDaily => 'デイリー';

  @override
  String get statsBestStreak => '連続';

  @override
  String get statsChapters => 'チャプター';

  @override
  String get appThemeForge => '鍛冶場';
}
