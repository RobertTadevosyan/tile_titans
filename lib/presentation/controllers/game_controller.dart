import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_2048/domain/ai_difficultt.dart';
import 'package:flutter_2048/domain/direction.dart';
import 'package:flutter_2048/domain/engine/board.dart';
import 'package:flutter_2048/domain/game_mode.dart';
import 'package:flutter_2048/domain/prefs.dart';
import 'package:flutter_2048/presentation/controllers/tile.dart';
import 'package:flutter_2048/utils/deviceInfo.dart';
import 'package:flutter_2048/l10n/app_localizations.dart';

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
          while (line.length < gridSize) {
            line.add(0);
          }
          copy[i] = line;
          break;
        case 'right':
          line = copy[i].reversed.toList();
          line.removeWhere((x) => x == 0);
          simulateCollapse(line);
          while (line.length < gridSize) {
            line.add(0);
          }
          copy[i] = line.reversed.toList();
          break;
        case 'up':
          line = List.generate(gridSize, (j) => copy[j][i]);
          line.removeWhere((x) => x == 0);
          simulateCollapse(line);
          while (line.length < gridSize) {
            line.add(0);
          }
          for (int j = 0; j < gridSize; j++) {
            copy[j][i] = line[j];
          }
          break;
        case 'down':
          line = List.generate(gridSize, (j) => copy[j][i]).reversed.toList();
          line.removeWhere((x) => x == 0);
          simulateCollapse(line);
          while (line.length < gridSize) {
            line.add(0);
          }
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
    // Flush any debounced leaderboard write before shutting the timers down,
    // so a qualifying score earned in the last few seconds is not lost.
    if (_pendingHighScore > 0) {
      _publishHighScore(_pendingHighScore);
    }
    _updateTimer?.cancel();
    _timer?.cancel();
    autoPlayTimer?.cancel();
  }

  Timer? _updateTimer;
  /// Highest value waiting to be published, captured at call time.
  ///
  /// This must not be read from [score] when the debounce fires: the field
  /// keeps changing during those five seconds (a reset sets it to 0, Zen mode
  /// forces it to 0), and publishing whatever it happens to hold is what used
  /// to overwrite a player's leaderboard entry with their current run.
  int _pendingHighScore = 0;

  void saveHighScoreToFirebase(int value) {
    if (value <= 0) return;
    if (value > _pendingHighScore) _pendingHighScore = value;

    _updateTimer?.cancel();
    _updateTimer = Timer(const Duration(seconds: 5), () {
      _publishHighScore(_pendingHighScore);
    });
  }

  /// Writes the leaderboard entry, never lowering an existing score.
  ///
  /// Uses a transaction rather than `set()` so a stale or smaller value can
  /// never clobber a bigger one — including from another device signed into the
  /// same account, which a plain write would silently lose.
  Future<void> _publishHighScore(int value) async {
    if (value <= 0) return;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final device = await getDeviceInfoSafe();
    final ref = FirebaseDatabase.instance.ref('leaderboard/$userId');

    try {
      await ref.runTransaction((current) {
        final existing = current is Map ? current['high_score'] : null;
        final existingScore = existing is int ? existing : 0;
        if (value <= existingScore) {
          return Transaction.abort();
        }
        return Transaction.success({
          'high_score': value,
          'platform': device['platform'],
          'device': device['device'],
          'os': device['os'],
        });
      });
    } catch (_) {
      // A failed leaderboard write must never interrupt play; the next
      // qualifying score will try again.
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

  // ---------------------------------------------------------------------------
  // Movement
  //
  // All four directions run through one pipeline backed by the pure engine in
  // `domain/engine/board.dart`. The engine reports where every tile started and
  // finished, which is what lets tiles animate their real path. The previous
  // implementation rebuilt the tile list by matching positions *after* the board
  // had moved, so a travelling tile never matched itself and was recreated with
  // no history — it animated a single cell no matter how far it actually went.
  // ---------------------------------------------------------------------------

  void moveLeft(BuildContext context, AppLocalizations appLocales) =>
      _performMove(Direction.left, context, appLocales);

  void moveRight(BuildContext context, AppLocalizations appLocales) =>
      _performMove(Direction.right, context, appLocales);

  void moveUp(BuildContext context, AppLocalizations appLocales) =>
      _performMove(Direction.up, context, appLocales);

  void moveDown(BuildContext context, AppLocalizations appLocales) =>
      _performMove(Direction.down, context, appLocales);

  static const Map<Direction, Offset> _moveOffsets = {
    Direction.left: Offset(-1, 0),
    Direction.right: Offset(1, 0),
    Direction.up: Offset(0, -1),
    Direction.down: Offset(0, 1),
  };

  void _performMove(
    Direction direction,
    BuildContext context,
    AppLocalizations appLocales,
  ) {
    final result = applyMove(board, direction);

    // A swipe into a wall must not consume a turn. The old code pushed undo
    // history before testing this, so a no-op swipe silently ate an undo step.
    if (!result.moved) {
      _checkGameOver(context, appLocales);
      return;
    }

    logMove(direction.name);
    _pushHistory();
    lastMoveOffset = _moveOffsets[direction];

    board = result.board;
    if (mode != GameMode.zen) {
      score += result.gained;
    }
    totalMerges += result.merges.length;
    totalMergeValue += result.gained;

    // One sound per move, not one per merged pair: the old collapse loop fired
    // inside the merge loop, so a four-way cascade stacked four overlapping
    // plays of the same clip.
    if (result.merges.isNotEmpty) {
      _playMergeSound();
    }

    _rebuildTilesFrom(result);
    _spawnTile();

    unawaited(prefs.saveGame(score, gridSize, board));
    _applyModeRules(context, appLocales);
    _syncHighScore();
    notifyListeners();
    _checkGameOver(context, appLocales);
  }

  /// Snapshots the pre-move state for undo.
  void _pushHistory() {
    _boardHistory.add(board.map((row) => List<int>.from(row)).toList());
    _tileHistory.add(getOldTiles());
    _scoreHistory.add(score);
    totalMoves++;
  }

  /// Rebuilds the tile list, carrying each tile's identity and origin across so
  /// the widget layer can animate the true distance travelled.
  void _rebuildTilesFrom(MoveResult result) {
    final previousById = <String, Tile>{};
    for (final tile in tiles) {
      previousById['${tile.x},${tile.y}'] = tile;
    }

    final rebuilt = <Tile>[];
    for (var y = 0; y < gridSize; y++) {
      for (var x = 0; x < gridSize; x++) {
        final value = board[y][x];
        if (value <= 0) continue;

        final origin = result.originOf(x, y);
        final merged = result.merges.any((m) => m.x == x && m.y == y);
        final source =
            origin == null ? null : previousById['${origin.fromX},${origin.fromY}'];

        rebuilt.add(
          Tile(
            // A merged tile is a new object so its pop animation retriggers;
            // a tile that merely slid keeps its id so Flutter reuses the widget
            // and the movement tween runs instead of a rebuild.
            id: merged || source == null
                ? 'tile_${_tileIdCounter++}'
                : source.id,
            value: value,
            x: x,
            y: y,
            isNew: false,
            justMerged: merged,
            mergeScore: merged ? value : null,
            // Halving is exact here: a merge is always two equal tiles.
            mergedFromValue: merged ? value ~/ 2 : null,
            previousX: origin?.fromX ?? x,
            previousY: origin?.fromY ?? y,
          ),
        );
      }
    }
    tiles = rebuilt;
  }

  /// Adds the post-move tile(s) and appends them to the list, rather than
  /// rebuilding it and losing every tile's origin.
  void _spawnTile() {
    final random = Random();
    for (var i = 0; i < _spawnCount; i++) {
      final empty = <Point<int>>[];
      for (var y = 0; y < gridSize; y++) {
        for (var x = 0; x < gridSize; x++) {
          if (board[y][x] == 0) empty.add(Point(x, y));
        }
      }
      if (empty.isEmpty) return;

      final pos = empty[random.nextInt(empty.length)];
      final value = random.nextDouble() < _fourSpawnChance ? 4 : 2;
      board[pos.y][pos.x] = value;
      tiles.add(
        Tile(
          id: 'tile_${_tileIdCounter++}',
          value: value,
          x: pos.x,
          y: pos.y,
          isNew: true,
          justMerged: false,
          previousX: pos.x,
          previousY: pos.y,
        ),
      );
    }
  }

  /// Hardcore applies real spawn pressure rather than just hiding undo.
  int get _spawnCount => mode == GameMode.hardcore ? 2 : 1;

  double get _fourSpawnChance => mode == GameMode.hardcore ? 0.7 : 0.1;

  void _syncHighScore() {
    if (score > highScore) {
      highScore = score;
      unawaited(prefs.saveHighScore(score));
      saveHighScoreToFirebase(score);
    }
  }

  void _checkGameOver(BuildContext context, AppLocalizations appLocales) {
    if (mode == GameMode.zen) return; // Zen never ends.
    if (gameOver.value) return; // Already handled; do not re-fire.
    if (!isGameOver()) return;

    if (soundEnabled) {
      _audioPlayer.play(gameOverSound);
    }
    logGameOver();
    _showGameOverDialog(context, appLocales);
    gameOver.value = true;
  }
}
