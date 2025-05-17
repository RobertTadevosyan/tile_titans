import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_2048/domain/ai_difficultt.dart';
import 'package:flutter_2048/domain/game_mode.dart';
import 'package:flutter_2048/domain/prefs.dart';
import 'package:flutter_2048/presentation/controllers/tile.dart';
import 'package:flutter_2048/utils/deviceInfo.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GameController extends ChangeNotifier {
  final analytics = FirebaseAnalytics.instance;
  final db = FirebaseDatabase.instance.ref();
  final userId = FirebaseAuth.instance.currentUser?.uid;
  late List<List<int>> board;
  List<Tile> tiles = [];
  int score = 0;
  int gridSize;
  int _tileIdCounter = 0;
  Offset? lastMoveOffset;
  final _audioPlayer = AudioPlayer(); // Add to class scope
  final prefs = Prefs();
  int highScore = 0;

  final List<List<List<int>>> _boardHistory = [];
  final List<List<Tile>> _tileHistory = [];
  final List<int> _scoreHistory = [];

  bool soundEnabled = true;
  bool get canUndo => _boardHistory.isNotEmpty;
  final mergeSound = AssetSource('sounds/merge.wav');
  final gameOverSound = AssetSource('sounds/game_over.wav');

  bool isInitialized = false;

  int totalMoves = 0;
  int totalMerges = 0;
  int totalCreatedTiles = 0;
  int totalMergeValue = 0;

  GameMode mode = GameMode.normal;
  Timer? _timer;
  int timeLeft = 60; // for timed mode
  bool get isTimed => mode == GameMode.timed;

  AIDifficulty aiDifficulty = AIDifficulty.smart;

  final ValueNotifier<bool> gameOver = ValueNotifier(false);

  // String? getHint() {
  //   final directions = ['left', 'right', 'up', 'down'];
  //   int bestScore = -1;
  //   String? bestMove;

  //   for (final dir in directions) {
  //     final simulated = simulateMove(dir);
  //     if (!_boardsEqual(board, simulated)) {
  //       final emptyTiles =
  //           simulated.expand((row) => row).where((v) => v == 0).length;
  //       final simulatedScore = estimateMergeScore(board, simulated);

  //       final moveValue =
  //           (emptyTiles * 5) + simulatedScore; // 💡 Heuristic formula
  //       if (moveValue > bestScore) {
  //         bestScore = moveValue;
  //         bestMove = dir;
  //       }
  //     }
  //   }

  //   return bestMove;
  // }

  int estimateMergeScore(List<List<int>> original, List<List<int>> simulated) {
    int delta = 0;
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        if (simulated[y][x] > original[y][x]) {
          delta += simulated[y][x] - original[y][x];
        }
      }
    }
    return delta;
  }

  void setAIDifficulty(AIDifficulty difficulty) {
    aiDifficulty = difficulty;
    notifyListeners();
  }

  String? getHint() {
    final directions = ['left', 'right', 'up', 'down'];
    int bestScore = -1;
    String? bestMove;

    for (final dir in directions) {
      final simulated = simulateMove(dir);
      if (!_boardsEqual(board, simulated)) {
        final emptyTiles =
            simulated.expand((row) => row).where((v) => v == 0).length;
        final mergeScore = estimateMergeScore(board, simulated);

        int value;
        switch (aiDifficulty) {
          case AIDifficulty.easy:
            value = emptyTiles;
            break;
          case AIDifficulty.smart:
            value = (emptyTiles * 4) + mergeScore;
            break;
          case AIDifficulty.aggressive:
            value = (mergeScore * 2) + emptyTiles;
            break;
        }

        if (value > bestScore) {
          bestScore = value;
          bestMove = dir;
        }
      }
    }

    return bestMove;
  }

  // String? getHint() {
  //   final directions = ['left', 'right', 'up', 'down'];
  //   int maxEmpty = -1;
  //   String? bestMove;

  //   for (final dir in directions) {
  //     final simulated = simulateMove(dir);

  //     // ✅ Only consider moves that actually change the board
  //     if (!_boardsEqual(board, simulated)) {
  //       final empty =
  //           simulated.expand((row) => row).where((val) => val == 0).length;
  //       if (empty > maxEmpty) {
  //         maxEmpty = empty;
  //         bestMove = dir;
  //       }
  //     }
  //   }

  //   return bestMove;
  // }

  bool _boardsEqual(List<List<int>> a, List<List<int>> b) {
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        if (a[y][x] != b[y][x]) return false;
      }
    }
    return true;
  }

  List<List<int>> simulateMove(String direction) {
    List<List<int>> copy = board.map((r) => List<int>.from(r)).toList();

    void simulateCollapse(List<int> line) {
      int i = 0;
      while (i < line.length - 1) {
        if (line[i] == line[i + 1]) {
          line[i] *= 2;
          line.removeAt(i + 1);
          line.add(0);
          i++;
        } else {
          i++;
        }
      }
    }

    for (int i = 0; i < gridSize; i++) {
      List<int> line;
      switch (direction) {
        case 'left':
          line = copy[i];
          line.removeWhere((x) => x == 0);
          simulateCollapse(line);
          while (line.length < gridSize) line.add(0);
          copy[i] = line;
          break;
        case 'right':
          line = copy[i].reversed.toList();
          line.removeWhere((x) => x == 0);
          simulateCollapse(line);
          while (line.length < gridSize) line.add(0);
          copy[i] = line.reversed.toList();
          break;
        case 'up':
          line = List.generate(gridSize, (j) => copy[j][i]);
          line.removeWhere((x) => x == 0);
          simulateCollapse(line);
          while (line.length < gridSize) line.add(0);
          for (int j = 0; j < gridSize; j++) {
            copy[j][i] = line[j];
          }
          break;
        case 'down':
          line = List.generate(gridSize, (j) => copy[j][i]).reversed.toList();
          line.removeWhere((x) => x == 0);
          simulateCollapse(line);
          while (line.length < gridSize) line.add(0);
          for (int j = 0; j < gridSize; j++) {
            copy[gridSize - j - 1][i] = line[j];
          }
          break;
      }
    }

    return copy;
  }

  final Set<Point<int>> _lockedTiles = {};

  Future<void> signInAnonymously() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
  }

  void logMove(String direction) {
    totalMoves++;
    String? id = FirebaseAuth.instance.currentUser?.uid;
    analytics.setUserId(
      id: id,
      callOptions: AnalyticsCallOptions(global: true),
    );
    analytics.logEvent(
      name: 'move_tile',
      parameters: {'direction': direction, 'score': score},
    );
  }

  void logGameOver() {
    String? id = FirebaseAuth.instance.currentUser?.uid;
    analytics.setUserId(
      id: id,
      callOptions: AnalyticsCallOptions(global: true),
    );
    analytics.logEvent(
      name: 'game_over',
      parameters: {'score': score, 'grid_size': gridSize},
    );
  }

  void cancelTimers() {
    print("cancelTimers");
    setHighScoreInFirebaseDbActionPerformed();
    _updateTimer?.cancel();
    _timer?.cancel();
    autoPlayTimer?.cancel();
  }

  Timer? _updateTimer;
  void saveHighScoreToFirebase(int score) async {
    _updateTimer?.cancel();
    _updateTimer = Timer(Duration(seconds: 5), () async {
      setHighScoreInFirebaseDbActionPerformed();
    });
  }

  void setHighScoreInFirebaseDbActionPerformed() async{
    print("setHighScoreInFirebaseDbActionPerformed");
      final db = FirebaseDatabase.instance.ref();
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final device = await getDeviceInfoSafe();
      print("saveHighScoreToFirebase: userId: $userId, $device");
      if (userId != null) {
        await db.child('leaderboard/$userId').set({
          'high_score': score,
          'platform': device['platform'],
          'device': device['device'],
          'os': device['os'],
        });
      }
  }

  void _lockRandomTile() {
    final unlocked = <Point<int>>[];

    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        if (board[y][x] != 0 && !_lockedTiles.contains(Point(x, y))) {
          unlocked.add(Point(x, y));
        }
      }
    }

    if (unlocked.isNotEmpty) {
      _lockedTiles.add(unlocked[Random().nextInt(unlocked.length)]);
    }
  }

  void _addEvilTile() {
    if (score % 3 == 0) {
      // every 3 moves?
      final empty = <Point<int>>[];
      for (int y = 0; y < gridSize; y++) {
        for (int x = 0; x < gridSize; x++) {
          if (board[y][x] == 0) empty.add(Point(x, y));
        }
      }
      if (empty.isNotEmpty) {
        final pos = empty[Random().nextInt(empty.length)];
        board[pos.y][pos.x] = 1; // or 3
      }
    }
  }

  void _applyModeRules(BuildContext context, AppLocalizations appLocales) {
    if (mode == GameMode.timed) {
      _startTimer(context, appLocales);
    }

    if (mode == GameMode.challenge) {
      _lockRandomTile();
    }

    if (mode == GameMode.evilAI) {
      _addEvilTile();
    }

    if (mode == GameMode.hardcore) {
      // No undo, disable it in UI
    }

    if (mode == GameMode.zen) {
      score = 0;
      // Disable score in UI
    }
  }

  bool autoPlay = false;
  Timer? autoPlayTimer;

  void toggleAutoPlay(BuildContext context, AppLocalizations appLocales) {
    autoPlay = !autoPlay;

    if (autoPlay) {
      autoPlayTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        final move = getHint();
        if (move == null) {
          autoPlay = false;
          autoPlayTimer?.cancel();
          notifyListeners();
          return;
        }

        switch (move) {
          case 'left':
            moveLeft(context, appLocales);
            break;
          case 'right':
            moveRight(context, appLocales);
            break;
          case 'up':
            moveUp(context, appLocales);
            break;
          case 'down':
            moveDown(context, appLocales);
            break;
        }
      });
    } else {
      autoPlayTimer?.cancel();
    }

    notifyListeners();
  }

  void _startTimer(BuildContext context, AppLocalizations appLocales) {
    if (_timer?.isActive == true) {
      return;
    }
    _timer?.cancel();
    timeLeft = 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timeLeft--;
      notifyListeners();
      if (timeLeft <= 0) {
        timer.cancel();
        _endTimedGame(context, appLocales);
      }
    });
  }

  bool isGameOver() {
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        final current = board[y][x];
        if (current == 0) return false; // Empty tile found

        // Check right
        if (x + 1 < gridSize && board[y][x + 1] == current) return false;

        // Check down
        if (y + 1 < gridSize && board[y + 1][x] == current) return false;
      }
    }
    return true;
  }

  void _endTimedGame(BuildContext context, AppLocalizations appLocales) {
    if (dialogShown) return;
    dialogShown = true;
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          backgroundColor: theme.appBarTheme.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            appLocales.timeIsUp,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.appBarTheme.foregroundColor,
            ),
          ),
          content: Text(
            appLocales.finalScore(score),
            style: theme.textTheme.bodyLarge,
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                resetGame();
                dialogShown = false;
                Navigator.of(ctx).pop();
              },
              child: Text(
                appLocales.restart,
                style: TextStyle(color: theme.appBarTheme.foregroundColor),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                resetGame();
                setGameMode(GameMode.normal);
                dialogShown = false;
                Navigator.of(ctx).pop();
              },
              child: Text(
                appLocales.close,
                style: TextStyle(color: theme.appBarTheme.foregroundColor),
              ),
            ),
          ],
        );
      },
    );
  }

  void setGameMode(GameMode newMode) {
    if (mode != newMode) {
      mode = newMode;
      resetGame(); // re-init with new mode
    }
  }

  void setGridSize(int size) async {
    // if (![3, 4, 5, 6].contains(size)) return; // ✅ prevent invalid values
    await prefs.saveGameBoardSize(size);
    gridSize = size;
    resetGame(size); // optional: or use preserveGameState() if continuing
    notifyListeners();
  }

  void toggleSound(bool enabled) async {
    soundEnabled = enabled;
    await prefs.setSoundEnabled(enabled);
    notifyListeners();
  }

  void resetHighScore() async {
    prefs.resetHighScore();
    highScore = 0;
    notifyListeners();
  }

  GameController({this.gridSize = 4}) {
    resetGame();
    _initialize();
  }

  void _initialize() async {
    highScore = await prefs.loadHighScore();
    saveHighScoreToFirebase(highScore);
    soundEnabled = await prefs.getSoundEnabled();
    gridSize = await prefs.getGameBoardSize();

    final gameSettings = await prefs.loadGame();
    if (gameSettings != null) {
      gridSize = gameSettings.gridSize;
      score = gameSettings.scroe;
      board = gameSettings.board;
      _updateTileList();
    } else {
      newGame();
    }
    isInitialized = true; // ✅ Set flag
    notifyListeners(); // ✅ notify only after data is ready
    signInAnonymously();
  }

  void newGame() {
    board = List.generate(gridSize, (_) => List.filled(gridSize, 0));
    tiles.clear();
    _addRandomTile();
    _addRandomTile();
    _updateTileList();
  }

  void _playMergeSound() {
    if (soundEnabled) {
      _audioPlayer.play(mergeSound);
    }
  }

  void resetGame([int? size]) {
    score = 0;
    _tileIdCounter = 0;
    if (size != null) gridSize = size;
    newGame();
    gameOver.value = false;
    notifyListeners();
  }

  void _addRandomTile() {
    final empty = <Point<int>>[];
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        if (board[y][x] == 0) empty.add(Point(x, y));
      }
    }

    if (empty.isNotEmpty) {
      final pos = empty[Random().nextInt(empty.length)];
      final value = Random().nextDouble() < 0.9 ? 2 : 4;
      board[pos.y][pos.x] = value;
      final id = 'tile_${_tileIdCounter++}';
      tiles.add(
        Tile(
          id: id,
          value: value,
          x: pos.x,
          y: pos.y,
          isNew: true,
          justMerged: false,
        ),
      );
    }
  }

  void _resetTileStates() {
    tiles =
        tiles
            .map((tile) => tile.copyWith(isNew: false, justMerged: false))
            .toList();
  }

  List<Tile> getTiles() => tiles;

  void _updateTileList() {
    final updatedTiles = <Tile>[];

    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        final value = board[y][x];
        if (value != 0) {
          // Find existing tile by position and value
          final match = tiles.firstWhere(
            (t) => t.x == x && t.y == y && t.value == value,
            orElse: (() {
              final id = 'tile_${_tileIdCounter++}';
              return Tile(
                id: id,
                value: value,
                x: x,
                y: y,
                isNew: true,
                justMerged: true,
                previousX: null,
                previousY: null,
              );
            }),
          );
          updatedTiles.add(
            match.copyWith(x: x, y: y, previousX: match.x, previousY: match.y),
          );
        }
      }
    }
    tiles = updatedTiles;
  }

  List<Tile> getOldTiles() {
    return tiles
        .map(
          (tile) => tile.copyWith(
            previousX: tile.x,
            previousY: tile.y,
            isNew: tile.isNew,
            justMerged: tile.justMerged,
          ),
        )
        .toList();
  }

  void undo() {
    if (mode == GameMode.hardcore) return;
    if (_boardHistory.isEmpty) return;
    board = _boardHistory.removeLast();
    tiles = _tileHistory.removeLast();
    score = _scoreHistory.removeLast();
    notifyListeners();
  }

  void updateHistory(BuildContext context, AppLocalizations appLocales) async {
    _boardHistory.add(board.map((row) => List<int>.from(row)).toList());
    _tileHistory.add(getOldTiles()); // use clone
    _scoreHistory.add(score);
    totalMoves++;
    await prefs.saveGame(score, gridSize, board);
    _applyModeRules(context, appLocales);
    if (isGameOver()) {
      if (soundEnabled) {
        _audioPlayer.play(gameOverSound);
      }
      logGameOver();
      _showGameOverDialog(context, appLocales);
      gameOver.value = true;
    }
    notifyListeners();
  }

  bool dialogShown = false;
  void _showGameOverDialog(BuildContext context, AppLocalizations appLocales) {
    if (dialogShown) return;
    dialogShown = true;
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: appLocales.gameOver,
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, _, __) {
        final theme = Theme.of(context);
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          child: AlertDialog(
            backgroundColor: theme.appBarTheme.backgroundColor,
            title: Text(
              appLocales.gameOverTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.appBarTheme.foregroundColor,
              ),
            ),
            content: Text(appLocales.finalScore(score)),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  _boardHistory.clear();
                  _tileHistory.clear(); // use clone
                  _scoreHistory.clear();
                  await prefs.saveGame(score, gridSize, board);
                  setGameMode(GameMode.normal);
                  resetGame();
                  dialogShown = false;
                  Navigator.of(context).pop();
                },
                child: Text(
                  appLocales.restart,
                  style: TextStyle(color: theme.appBarTheme.foregroundColor),
                ),
              ),
            ],
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  void update() async {
    if (mode == GameMode.zen) {
      score = 0;
    }
    _addRandomTile();
    _updateTileList();
    if (score > highScore) {
      highScore = score;
      await prefs.saveHighScore(score); // 👈 call here
      saveHighScoreToFirebase(score);
    }
    notifyListeners();
  }

  void moveLeft(BuildContext context, AppLocalizations appLocales) {
    logMove("left");
    updateHistory(context, appLocales);
    lastMoveOffset = const Offset(-1, 0);
    bool moved = false;
    _resetTileStates();

    for (int y = 0; y < gridSize; y++) {
      final row = board[y];
      final originalRow = List<int>.from(row);
      final newRow = _collapse(row, y: y, horizontal: true);
      if (!_listsEqual(originalRow, newRow)) moved = true;
      board[y] = newRow;
    }

    if (moved) {
      update();
    }
  }

  void moveRight(BuildContext context, AppLocalizations appLocales) {
    logMove("right");
    updateHistory(context, appLocales);
    lastMoveOffset = const Offset(1, 0);
    bool moved = false;
    _resetTileStates();

    for (int y = 0; y < gridSize; y++) {
      final row = board[y].reversed.toList();
      final originalRow = List<int>.from(row);
      final newRow = _collapse(row, y: y, horizontal: true, reversed: true);
      if (!_listsEqual(originalRow, newRow.reversed.toList())) moved = true;
      board[y] = newRow.reversed.toList();
    }

    if (moved) {
      update();
    }
  }

  void moveUp(BuildContext context, AppLocalizations appLocales) {
    logMove("up");
    updateHistory(context, appLocales);
    lastMoveOffset = const Offset(0, -1);
    bool moved = false;
    _resetTileStates();

    for (int x = 0; x < gridSize; x++) {
      final col = List.generate(gridSize, (y) => board[y][x]);
      final originalCol = List<int>.from(col);
      final newCol = _collapse(col, x: x, horizontal: false);
      if (!_listsEqual(originalCol, newCol)) moved = true;
      for (int y = 0; y < gridSize; y++) {
        board[y][x] = newCol[y];
      }
    }

    if (moved) {
      update();
    }
  }

  void moveDown(BuildContext context, AppLocalizations appLocales) {
    logMove("down");
    updateHistory(context, appLocales);
    lastMoveOffset = const Offset(0, 1);
    bool moved = false;
    _resetTileStates();

    for (int x = 0; x < gridSize; x++) {
      final col = List.generate(gridSize, (y) => board[y][x]).reversed.toList();
      final originalCol = List<int>.from(col);
      var newCol = _collapse(col, x: x, horizontal: false, reversed: true);
      if (!_listsEqual(originalCol, newCol.reversed.toList())) moved = true;
      newCol = newCol.reversed.toList();
      for (int y = 0; y < gridSize; y++) {
        board[y][x] = newCol[y];
      }
    }

    if (moved) {
      update();
    }
  }

  List<int> _collapse(
    List<int> line, {
    int? x,
    int? y,
    required bool horizontal,
    bool reversed = false,
  }) {
    List<int> result = [];
    List<int> newLine = line.where((x) => x != 0).toList();

    int index = 0;
    while (index < newLine.length) {
      if (index + 1 < newLine.length && newLine[index] == newLine[index + 1]) {
        final mergedValue = newLine[index] * 2;
        score += mergedValue;
        totalMerges++;
        totalMergeValue += mergedValue;
        _playMergeSound();
        result.add(mergedValue);

        final posX =
            horizontal
                ? (reversed ? (gridSize - result.length) : result.length - 1)
                : x!;
        final posY =
            horizontal
                ? y!
                : (reversed ? (gridSize - result.length) : result.length - 1);

        tiles.add(
          Tile(
            id: 'tile_${_tileIdCounter++}',
            value: mergedValue,
            x: posX,
            y: posY,
            justMerged: true,
            mergeScore: mergedValue,
          ),
        );

        index += 2;
      } else {
        result.add(newLine[index]);
        index++;
      }
    }

    while (result.length < gridSize) {
      result.add(0);
    }

    return result;
  }

  bool _listsEqual(List<int> a, List<int> b) =>
      a.length == b.length &&
      List.generate(a.length, (i) => a[i] == b[i]).every((e) => e);
}
