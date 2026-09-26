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
  String points(Object p) {
    return '$p pontos';
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
}
