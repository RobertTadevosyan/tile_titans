// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Tile Titans';

  @override
  String get autoPlay => 'Otomatik';

  @override
  String get restart => '🔄';

  @override
  String get undo => '↩️';

  @override
  String get hint => '💡';

  @override
  String hintMessage(Object direction) {
    return '💡: $direction yönüne dene';
  }

  @override
  String get statistics => 'İstatistikler';

  @override
  String moves(Object moves) {
    return 'Hamle: $moves';
  }

  @override
  String merges(Object merges) {
    return 'Birleşme: $merges';
  }

  @override
  String avgMerge(Object merges) {
    return 'Ort. birleşme: $merges';
  }

  @override
  String mergeEfficiency(Object efficiency) {
    return 'Verimlilik: %$efficiency';
  }

  @override
  String get close => 'Kapat';

  @override
  String score(Object score) {
    return 'Puan: $score';
  }

  @override
  String highScore(Object highScore) {
    return 'Rekor: $highScore';
  }

  @override
  String get settings => 'Ayarlar';

  @override
  String get leaderboard => 'Sıralama';

  @override
  String get findMe => 'Beni bul';

  @override
  String get noScore => 'Henüz puan yok.';

  @override
  String get rank => 'Rütbe';

  @override
  String get scoreTitle => 'Puan';

  @override
  String get platform => 'Platform';

  @override
  String get device => 'Cihaz';

  @override
  String get user => 'Oyuncu';

  @override
  String points(num p) {
    return '$p puan';
  }

  @override
  String get appSettings => 'Ayarlar';

  @override
  String get soundEffects => 'Ses efektleri';

  @override
  String get highScoreTitle => 'Rekor';

  @override
  String get highScoreReset => 'Rekor sıfırlandı';

  @override
  String get aiDifficulty => 'İpucu tarzı';

  @override
  String get boardSize => 'Tahta boyutu';

  @override
  String get appTheme => 'Tema';

  @override
  String get language => 'Dil';

  @override
  String get restartGame => 'Yeniden başlat';

  @override
  String get gameModeNormal => 'Normal';

  @override
  String get gameModeTimed => 'Süreli';

  @override
  String get gameModeHardcore => 'Zorlu';

  @override
  String get gameModeZen => 'Zen';

  @override
  String get aiDiffEasy => 'Temkinli';

  @override
  String get aiDiffSmart => 'Dengeli';

  @override
  String get aiDiffAggressive => 'Saldırgan';

  @override
  String get appThemeClassic => 'Klasik';

  @override
  String get appThemeDark => 'Koyu';

  @override
  String get appThemeOcean => 'Okyanus';

  @override
  String get appThemeRetro => 'Retro';

  @override
  String get appThemeNeon => 'Neon';

  @override
  String get gameOver => 'Oyun bitti';

  @override
  String get gameOverTitle => 'Oyun bitti 🎮';

  @override
  String finalScore(Object score) {
    return 'Son puanın $score';
  }

  @override
  String get timeIsUp => 'Süre doldu!';

  @override
  String get homeContinue => 'Devam et';

  @override
  String get homeChooseChallenge => 'Meydan okumanı seç';

  @override
  String get homeDailyTrial => 'Günlük sınav';

  @override
  String get homeTitanTrials => 'Titan Sınavları';

  @override
  String get homeHallOfTitans => 'Titanlar Salonu';

  @override
  String get homeBest => 'Rekor';

  @override
  String homeStreakDays(int days) {
    return '$days günlük seri';
  }

  @override
  String get homeRank => 'Rütbe';

  @override
  String homeCompleted(int done, int total) {
    return '$total içinden $done';
  }

  @override
  String get homePlayed => 'Oyuna devam et';

  @override
  String get modeClassic => 'Klasik';

  @override
  String get modeZen => 'Zen';

  @override
  String get modeTimeAttack => 'Zamana karşı';

  @override
  String get modeHardcore => 'Zorlu';

  @override
  String get modeClassicDesc => 'Stratejik temel';

  @override
  String get modeZenDesc => 'Puan yok, kaybetmek yok';

  @override
  String get modeTimeAttackDesc => 'Birleşmeler saniye kazandırır';

  @override
  String get modeHardcoreDesc => '5x5, yoğun taş, yardım yok';

  @override
  String trialMoveLimit(int moves) {
    return '$moves hamle';
  }

  @override
  String trialTimeLimit(int seconds) {
    return '$seconds sn';
  }

  @override
  String get trialNoUndo => 'Geri alma yok';

  @override
  String get trialNoHints => 'İpucu yok';

  @override
  String get trialObjective => 'Hedef';

  @override
  String get trialComplete => 'Sınav geçildi';

  @override
  String get trialFailed => 'Sınav başarısız';

  @override
  String get achievements => 'Başarımlar';

  @override
  String get pathOfTitans => 'Titanlar Yolu';

  @override
  String get statGamesPlayed => 'Oynanan oyun';

  @override
  String get statBestScore => 'En iyi puan';

  @override
  String get statHighestTile => 'En yüksek taş';

  @override
  String get statTotalMerges => 'Toplam birleşme';

  @override
  String get statAverageScore => 'Ortalama puan';

  @override
  String get statFavouriteMode => 'Favori mod';

  @override
  String get statPlayTime => 'Oyun süresi';

  @override
  String get statLongestGame => 'En uzun oyun';

  @override
  String get statsLifetime => 'Tüm zamanlar';

  @override
  String get statsByMode => 'Moda göre';

  @override
  String get statsNotPlayed => 'Henüz oynanmadı';

  @override
  String get statsTrials => 'Sınavlar';

  @override
  String get statsDaily => 'Günlük';

  @override
  String get statsChapters => 'Bölümler';

  @override
  String get appThemeForge => 'Demirhane';

  @override
  String objReachTile(int tile) {
    return '$tile taşı döv';
  }

  @override
  String objReachScore(int score) {
    final intl.NumberFormat scoreNumberFormat = intl
        .NumberFormat.decimalPattern(localeName);
    final String scoreString = scoreNumberFormat.format(score);

    return '$scoreString puan topla';
  }

  @override
  String objCreateTiles(int count, int tile) {
    return '$tile değerinde $count taş tut';
  }

  @override
  String objSurvive(int moves) {
    return '$moves hamle dayan';
  }

  @override
  String objClearBoard(int count) {
    return '$count taşa indir';
  }

  @override
  String get rankNovice => 'Çırak';

  @override
  String get rankWarrior => 'Savaşçı';

  @override
  String get rankChampion => 'Şampiyon';

  @override
  String get rankTitan => 'Titan';

  @override
  String get rankLegend => 'Efsane';

  @override
  String get chapterForge => 'Demirhane';

  @override
  String get chapterProving => 'Sınav Alanı';

  @override
  String get chapterSummit => 'Zirve';

  @override
  String get chapterForgeTheme => 'Hedefleri öğren';

  @override
  String get chapterProvingTheme => 'Kapalı kareler, geri alma yok';

  @override
  String get chapterSummitTheme => 'Zaman baskısı ve açık alan';

  @override
  String get achFirstBlood => 'İlk Kan';

  @override
  String get achWarrior => 'Savaşçı';

  @override
  String get achChampion => 'Şampiyon';

  @override
  String get achTitanName => 'Titan';

  @override
  String get achBeyondGods => 'Tanrıların Ötesinde';

  @override
  String get achInitiate => 'Aday';

  @override
  String get achProven => 'Sınanmış';

  @override
  String get achTrialmaster => 'Sınav Ustası';

  @override
  String get achForgedName => 'Dövülmüş';

  @override
  String get achPerfectTrial => 'Kusursuz Sınav';

  @override
  String get achDedicated => 'Kararlı';

  @override
  String get achRelentless => 'Amansız';

  @override
  String get achHoarder => 'İstifçi';

  @override
  String get achIronhand => 'Demir El';

  @override
  String get achVeteran => 'Kıdemli';

  @override
  String achDescTrials(int count) {
    return '$count Titan Sınavını tamamla';
  }

  @override
  String get achDescAllTrials => 'Tüm Titan Sınavlarını tamamla';

  @override
  String get achDescChapter => 'Bir bölümü tamamen bitir';

  @override
  String achDescCleanTrials(int count) {
    return '$count sınavı geri alma olmadan tamamla';
  }

  @override
  String achDescStreak(int days) {
    return '$days günlük Günlük Sınav serisi';
  }

  @override
  String achDescScore(int score) {
    return 'Tek oyunda $score puan yap';
  }

  @override
  String achDescMerges(int count) {
    return 'Toplam $count karo birleştir';
  }

  @override
  String achDescGames(int count) {
    return '$count oyun oyna';
  }

  @override
  String trialName(String numeral) {
    return '$numeral. Sınav';
  }

  @override
  String get dailyTrialTitle => 'Günlük Titan Sınavı';
}
