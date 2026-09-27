// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Tile Titans';

  @override
  String get autoPlay => 'Automático';

  @override
  String get restart => '🔄';

  @override
  String get undo => '↩️';

  @override
  String get hint => '💡';

  @override
  String hintMessage(Object direction) {
    return '💡: Tente mover para $direction';
  }

  @override
  String get statistics => 'Estatísticas';

  @override
  String moves(Object moves) {
    return 'Jogadas: $moves';
  }

  @override
  String merges(Object merges) {
    return 'Fusões: $merges';
  }

  @override
  String avgMerge(Object merges) {
    return 'Fusão média: $merges';
  }

  @override
  String mergeEfficiency(Object efficiency) {
    return 'Eficiência: $efficiency%';
  }

  @override
  String get close => 'Fechar';

  @override
  String score(Object score) {
    return 'Pontos: $score';
  }

  @override
  String highScore(Object highScore) {
    return 'Recorde: $highScore';
  }

  @override
  String get settings => 'Definições';

  @override
  String get leaderboard => 'Classificação';

  @override
  String get findMe => 'Encontrar-me';

  @override
  String get noScore => 'Ainda sem pontuações.';

  @override
  String get rank => 'Patente';

  @override
  String get scoreTitle => 'Pontos';

  @override
  String get platform => 'Plataforma';

  @override
  String get device => 'Dispositivo';

  @override
  String get user => 'Jogador';

  @override
  String points(num p) {
    String _temp0 = intl.Intl.pluralLogic(
      p,
      locale: localeName,
      other: '$p pontos',
      one: '1 ponto',
    );
    return '$_temp0';
  }

  @override
  String get appSettings => 'Definições';

  @override
  String get soundEffects => 'Efeitos sonoros';

  @override
  String get highScoreTitle => 'Recorde';

  @override
  String get highScoreReset => 'Recorde reposto';

  @override
  String get gameMode => 'Modo de jogo';

  @override
  String get aiDifficulty => 'Dificuldade da IA';

  @override
  String get boardSize => 'Tamanho do tabuleiro';

  @override
  String get appTheme => 'Tema';

  @override
  String get language => 'Idioma';

  @override
  String get restartGame => 'Recomeçar';

  @override
  String get gameModeNormal => 'Normal';

  @override
  String get gameModeTimed => 'Cronometrado';

  @override
  String get gameModeChallenge => 'Desafio';

  @override
  String get gameModeEvilAI => 'IA maligna';

  @override
  String get gameModeHardcore => 'Extremo';

  @override
  String get gameModeZen => 'Zen';

  @override
  String get aiDiffEasy => 'Fácil';

  @override
  String get aiDiffSmart => 'Inteligente';

  @override
  String get aiDiffAggressive => 'Agressiva';

  @override
  String get appThemeClassic => 'Clássico';

  @override
  String get appThemeDark => 'Escuro';

  @override
  String get appThemeOcean => 'Oceano';

  @override
  String get appThemeRetro => 'Retro';

  @override
  String get appThemeNeon => 'Néon';

  @override
  String get gameOver => 'Fim de jogo';

  @override
  String get gameOverTitle => 'Fim de jogo 🎮';

  @override
  String finalScore(Object score) {
    return 'A tua pontuação final é $score';
  }

  @override
  String get timeIsUp => 'Tempo esgotado!';

  @override
  String get homeContinue => 'Continuar';

  @override
  String get homeNewGame => 'Novo jogo';

  @override
  String get homePlay => 'Jogar';

  @override
  String get homeChooseChallenge => 'Escolhe o teu desafio';

  @override
  String get homeDailyTrial => 'Prova diária';

  @override
  String get homeTodaysChallenge => 'Desafio de hoje';

  @override
  String get homeTitanTrials => 'Provas dos Titãs';

  @override
  String get homeHallOfTitans => 'Salão dos Titãs';

  @override
  String get homeGameModes => 'Modos de jogo';

  @override
  String get homeBest => 'Recorde';

  @override
  String homeStreakDays(int days) {
    return 'Sequência de $days d';
  }

  @override
  String get homeRank => 'Patente';

  @override
  String homeCompleted(int done, int total) {
    return '$done de $total';
  }

  @override
  String get homePlayed => 'Retomar o jogo';

  @override
  String get modeClassic => 'Clássico';

  @override
  String get modeZen => 'Zen';

  @override
  String get modeTimeAttack => 'Contra o tempo';

  @override
  String get modeHardcore => 'Extremo';

  @override
  String get modeClassicDesc => 'A base estratégica';

  @override
  String get modeZenDesc => 'Sem pontos nem derrota';

  @override
  String get modeTimeAttackDesc => 'As fusões dão segundos';

  @override
  String get modeHardcoreDesc => '5x5, mais peças, sem ajuda';

  @override
  String trialMoveLimit(int moves) {
    return '$moves jogadas';
  }

  @override
  String trialTimeLimit(int seconds) {
    return '$seconds s';
  }

  @override
  String get trialNoUndo => 'Sem anular';

  @override
  String get trialNoHints => 'Sem dicas';

  @override
  String get trialLocked => 'Bloqueada';

  @override
  String get trialObjective => 'Objetivo';

  @override
  String get trialComplete => 'Prova concluída';

  @override
  String get trialFailed => 'Prova falhada';

  @override
  String get achievements => 'Conquistas';

  @override
  String get pathOfTitans => 'Caminho dos Titãs';

  @override
  String get statGamesPlayed => 'Jogos jogados';

  @override
  String get statBestScore => 'Melhor pontuação';

  @override
  String get statHighestTile => 'Peça mais alta';

  @override
  String get statTotalMerges => 'Fusões totais';

  @override
  String get statAverageScore => 'Pontuação média';

  @override
  String get statFavouriteMode => 'Modo favorito';

  @override
  String get statPlayTime => 'Tempo de jogo';

  @override
  String get statLongestGame => 'Jogo mais longo';

  @override
  String get statsLifetime => 'Desde sempre';

  @override
  String get statsByMode => 'Por modo';

  @override
  String get statsNotPlayed => 'Ainda não jogado';

  @override
  String get statsTrials => 'Provas';

  @override
  String get statsDaily => 'Diária';

  @override
  String get statsBestStreak => 'Sequência';

  @override
  String get statsChapters => 'Capítulos';

  @override
  String get appThemeForge => 'Forja';

  @override
  String objReachTile(int tile) {
    return 'Forja uma peça $tile';
  }

  @override
  String objReachScore(int score) {
    final intl.NumberFormat scoreNumberFormat = intl
        .NumberFormat.decimalPattern(localeName);
    final String scoreString = scoreNumberFormat.format(score);

    return 'Faz $scoreString pontos';
  }

  @override
  String objCreateTiles(int count, int tile) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peças',
      one: '1 peça',
    );
    return 'Tem $_temp0 de $tile';
  }

  @override
  String objSurvive(int moves) {
    String _temp0 = intl.Intl.pluralLogic(
      moves,
      locale: localeName,
      other: '$moves jogadas',
      one: '1 jogada',
    );
    return 'Sobrevive $_temp0';
  }

  @override
  String objClearBoard(int count) {
    return 'Reduz a $count peças';
  }

  @override
  String get rankNovice => 'Novato';

  @override
  String get rankWarrior => 'Guerreiro';

  @override
  String get rankChampion => 'Campeão';

  @override
  String get rankTitan => 'Titã';

  @override
  String get rankLegend => 'Lenda';

  @override
  String get chapterForge => 'A Forja';

  @override
  String get chapterProving => 'O Campo de Provas';

  @override
  String get chapterSummit => 'O Cume';

  @override
  String get chapterForgeTheme => 'Aprende os objetivos';

  @override
  String get chapterProvingTheme => 'Células bloqueadas e sem anular';

  @override
  String get chapterSummitTheme => 'Tempo e campo aberto';

  @override
  String get achFirstBlood => 'Primeiro Sangue';

  @override
  String get achWarrior => 'Guerreiro';

  @override
  String get achChampion => 'Campeão';

  @override
  String get achTitanName => 'Titã';

  @override
  String get achBeyondGods => 'Além dos Deuses';

  @override
  String get achInitiate => 'Iniciado';

  @override
  String get achProven => 'Provado';

  @override
  String get achTrialmaster => 'Mestre das Provas';

  @override
  String get achForgedName => 'Forjado';

  @override
  String get achPerfectTrial => 'Prova Perfeita';

  @override
  String get achDedicated => 'Dedicado';

  @override
  String get achRelentless => 'Implacável';

  @override
  String get achHoarder => 'Acumulador';

  @override
  String get achIronhand => 'Mão de Ferro';

  @override
  String get achVeteran => 'Veterano';

  @override
  String achDescTrials(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Provas dos Titãs',
      one: '1 Prova dos Titãs',
    );
    return 'Complete $_temp0';
  }

  @override
  String get achDescAllTrials => 'Complete todas as Provas dos Titãs';

  @override
  String get achDescChapter => 'Complete um capítulo inteiro';

  @override
  String achDescCleanTrials(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count provas',
      one: '1 prova',
    );
    return 'Complete $_temp0 sem desfazer';
  }

  @override
  String achDescStreak(int days) {
    return 'Sequência de $days dias na Prova Diária';
  }

  @override
  String achDescScore(int score) {
    return 'Marque $score numa única partida';
  }

  @override
  String achDescMerges(int count) {
    return 'Funda $count peças no total';
  }

  @override
  String achDescGames(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partidas',
      one: '1 partida',
    );
    return 'Jogue $_temp0';
  }
}
