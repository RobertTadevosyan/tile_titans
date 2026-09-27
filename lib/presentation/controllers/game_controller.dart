import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_2048/core/theme/titan_design.dart';
import 'package:flutter_2048/presentation/models/leaderboard_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_2048/domain/ai_difficultt.dart';
import 'package:flutter_2048/domain/direction.dart';
import 'package:flutter_2048/domain/engine/board.dart';
import 'package:flutter_2048/domain/engine/objective.dart';
import 'package:flutter_2048/domain/engine/rules.dart';
import 'package:flutter_2048/domain/engine/trial.dart';
import 'package:flutter_2048/domain/game_mode.dart';
import 'package:flutter_2048/domain/prefs.dart';
import 'package:flutter_2048/domain/progress/progress_store.dart';
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
  /// Whether this session is against a clock.
  ///
  /// The legacy [GameMode] enum and the newer [RuleSet] both describe a timed
  /// game, and the home screen sets only the rules. Gating on the enum alone
  /// meant Time Attack started from the home screen had no countdown, never
  /// ran out, and never finished — so it recorded no statistics and its
  /// leaderboard could not fill no matter what the publishing code did.
  bool get isTimed => mode == GameMode.timed || rules.timeLimit != null;

  /// How long a timed session starts with.
  int get timeLimitSeconds => rules.timeLimit ?? 60;

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


  /// Signs in anonymously so scores can be attributed to a stable id.
  ///
  /// Both callers fire this without awaiting it, so a throw here became an
  /// unhandled async error: opening the app with no connectivity raised
  /// `[firebase_auth/network-request-failed]` with nobody to catch it. Sign-in
  /// is not something the player asked for and nothing on screen depends on it
  /// — the game is fully playable offline — so a failure is recorded and the
  /// app carries on. The next launch tries again.
  Future<void> signInAnonymously() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser != null) return;
    try {
      await auth.signInAnonymously();
    } catch (error, stack) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          error,
          stack,
          reason: 'anonymous sign-in failed',
          fatal: false,
        ),
      );
    }
  }

  /// Sends telemetry without letting it interrupt the game.
  ///
  /// These are Futures that nothing awaits, so a failure — which is what
  /// happens whenever the device cannot reach Firebase — became an unhandled
  /// async error. logMove runs on every swipe, so an offline session produced
  /// one per move. Nothing the player does depends on the event arriving.
  void _fire(Future<void> Function() call) {
    unawaited(call().catchError((Object _) {}));
  }

  void logMove(String direction) {
    totalMoves++;
    final id = FirebaseAuth.instance.currentUser?.uid;
    _fire(
      () => analytics.setUserId(
        id: id,
        callOptions: AnalyticsCallOptions(global: true),
      ),
    );
    _fire(
      () => analytics.logEvent(
        name: 'move_tile',
        parameters: {'direction': direction, 'score': score},
      ),
    );
  }

  void logGameOver() {
    final id = FirebaseAuth.instance.currentUser?.uid;
    _fire(
      () => analytics.setUserId(
        id: id,
        callOptions: AnalyticsCallOptions(global: true),
      ),
    );
    _fire(
      () => analytics.logEvent(
        name: 'game_over',
        parameters: {'score': score, 'grid_size': gridSize},
      ),
    );
  }

  void cancelTimers() {
    // Flush any debounced leaderboard write before shutting the timers down,
    // so a qualifying score earned in the last few seconds is not lost.
    if (_pendingHighScore > 0) {
      _publishHighScore(_pendingHighScore, _pendingScoreMode);
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

  /// Which board the pending score belongs to, captured with it.
  ///
  /// [_modeName] is derived from the live rules, so reading it when the
  /// debounce fires would file the score under whatever mode the player had
  /// switched to by then.
  String _pendingScoreMode = ModeKeys.classic;

  void saveHighScoreToFirebase(int value, {String? mode}) {
    if (value <= 0) return;
    final board = mode ?? _modeName;

    // A score for a different board must not be folded into the one waiting:
    // flush it first, or switching modes inside the debounce window would post
    // one mode's score to the other's ladder.
    if (board != _pendingScoreMode && _pendingHighScore > 0) {
      _updateTimer?.cancel();
      _publishHighScore(_pendingHighScore, _pendingScoreMode);
      _pendingHighScore = 0;
    }

    _pendingScoreMode = board;
    if (value > _pendingHighScore) _pendingHighScore = value;

    _updateTimer?.cancel();
    _updateTimer = Timer(const Duration(seconds: 5), () {
      _publishHighScore(_pendingHighScore, _pendingScoreMode);
    });
  }

  DatabaseReference _leaderboardRef(String mode, String userId) =>
      FirebaseDatabase.instance.ref(leaderboardPathFor(mode, userId));

  /// Writes the leaderboard entry, never lowering an existing score.
  ///
  /// Uses a transaction rather than `set()` so a stale or smaller value can
  /// never clobber a bigger one — including from another device signed into the
  /// same account, which a plain write would silently lose.
  Future<void> _publishHighScore(int value, String mode) async {
    if (value <= 0) return;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final device = await getDeviceInfoSafe();

    // One board per mode. A 5x5 Hardcore run and a 90-second Time Attack run
    // are not comparable with Classic, so ranking them together would produce
    // a ladder that measures nothing. The row keeps the same four fields on
    // every board, so one reader and one model serve them all.
    final ref = _leaderboardRef(mode, userId);

    try {
      await ref.runTransaction((current) {
        final existing = current is Map ? current['high_score'] : null;
        final existingScore = existing is int ? existing : 0;
        if (value <= existingScore) {
          return Transaction.abort();
        }
        return Transaction.success({
          // Classic writes the player's whole node, which now also carries the
          // other modes underneath it. Replacing the node outright would delete
          // every per-mode score the moment a Classic record was beaten.
          if (current is Map) ...current.cast<String, Object?>(),
          'high_score': value,
          'platform': device['platform'],
          'device': device['device'],
          'os': device['os'],
        });
      });
    } catch (error, stack) {
      // A failed leaderboard write must never interrupt play; the next
      // qualifying score will try again. But it must not vanish either: this
      // catch is what hid the per-mode boards being rejected with permission
      // denied on every single write, for as long as they existed. Recording
      // it non-fatally keeps play uninterrupted and the failure visible.
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          error,
          stack,
          reason: 'leaderboard write failed for $mode',
          fatal: false,
        ),
      );
    }
  }


  /// Rules that have to run after a move rather than being described by data.
  ///
  /// Only the clock is left. Zen's scoring and Hardcore's lack of undo are
  /// properties of their RuleSet now, and the two modes that used to be
  /// handled here — a locked tile and a hostile spawn — were removed: nothing
  /// could start them, and neither worked. The lock was recorded in a set the
  /// move logic never consulted, and the hostile spawn placed a 1 or a 3 on a
  /// board where every tile is a power of two, so it could never merge with
  /// anything.
  void _applyModeRules(BuildContext context, AppLocalizations appLocales) {
    if (isTimed) {
      _startTimer(context, appLocales);
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
    timeLeft = timeLimitSeconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timeLeft--;
      notifyListeners();
      if (timeLeft <= 0) {
        timer.cancel();
        _endTimedGame(context, appLocales);
      }
    });
  }


  // ---------------------------------------------------------------------------
  // Session
  //
  // A session is "what am I playing right now": a rule set, optionally an
  // authored trial, and the counters those need. Before this the controller had
  // only a `GameMode` enum that a handful of scattered `if`s consulted, which is
  // why the six advertised modes all played identically.
  // ---------------------------------------------------------------------------

  /// The mechanics currently in force.
  RuleSet rules = RuleSet.classic;

  /// The trial being attempted, or null during free play.
  Trial? activeTrial;

  /// Moves spent in this session, for trial move budgets.
  int movesUsed = 0;

  /// Seconds spent, for trial time budgets and play-time statistics.
  int secondsElapsed = 0;

  /// Set once the trial's objective is satisfied.
  bool objectiveMet = false;

  /// True once a trial has been won or lost, so the result is reported once.
  bool sessionResolved = false;

  /// Whether undo was used this session, for the "Perfect Trial" achievement.
  bool usedUndoThisSession = false;

  /// The player's own board-size preference, restored when a trial ends.
  int playerGridSize = 4;

  /// Records finished runs. Injected rather than constructed here so the
  /// controller keeps no dependency on how progress is stored.
  ProgressStore? progressStore;

  /// When the current session began, for play-time statistics.
  DateTime? _sessionStart;

  /// Set once the player has explicitly chosen what to play.
  ///
  /// `_initialize()` runs asynchronously at startup and finishes by restoring a
  /// saved game or dealing a new one. Without this guard it would land *after*
  /// a trial had been opened and overwrite its authored position with a random
  /// board — the grid size survived, so the bug looked like a rendering fault
  /// rather than a race.
  bool _sessionStarted = false;

  bool get isTrial => activeTrial != null;

  /// The best score for whatever is being played right now.
  ///
  /// The board used to show one global high score regardless of mode, which
  /// put a Classic record next to a Hardcore run it has nothing to do with.
  /// Falls back to the legacy global figure only until a mode has been played.
  int get sessionBestScore {
    final store = progressStore;
    if (store == null) return highScore;
    final best = store.stats.forMode(_modeName).bestScore;
    if (best > 0) return best;
    // Classic inherits the legacy global record until it has per-mode
    // statistics of its own. Returning 0 instead contradicted the fallback this
    // getter documents and showed "RECORD 0" to a player whose Classic record
    // was on the board in front of them — 1124, visible in settings and at
    // #120 on the ladder.
    return _modeName == ModeKeys.classic ? highScore : 0;
  }

  Constraints get constraints =>
      activeTrial?.constraints ?? const Constraints();

  bool get undoAllowed => rules.allowUndo && constraints.allowUndo;

  bool get hintsAllowed => rules.allowHints && constraints.allowHints;

  bool get scored => rules.scored;

  /// Moves left in a budgeted trial, or null when unbudgeted.
  int? get movesRemaining {
    final limit = constraints.moveLimit;
    if (limit == null) return null;
    final left = limit - movesUsed;
    return left < 0 ? 0 : left;
  }

  /// Progress toward the active trial's objective, or null in free play.
  double? get objectiveProgress {
    final trial = activeTrial;
    if (trial == null) return null;
    return trial.objective.progress(
      board: board,
      score: score,
      movesUsed: movesUsed,
    );
  }

  /// Starts free play under [ruleSet], honouring the player's board size unless
  /// the rule set defines its own.
  void startMode(RuleSet ruleSet) {
    _sessionStarted = true;
    _stopTimers();
    activeTrial = null;
    rules = ruleSet;
    gridSize =
        ruleSet.respectsPlayerGrid ? playerGridSize : ruleSet.gridSize;
    _resetSessionCounters();
    resetGame();
  }

  /// Starts an authored trial from its fixed position.
  void startTrial(Trial trial) {
    _sessionStarted = true;
    _stopTimers();
    activeTrial = trial;
    rules = trial.rules;
    gridSize = trial.gridSize;
    _resetSessionCounters();

    board = trial.freshBoard();
    tiles.clear();
    score = 0;
    _tileIdCounter = 0;
    _seedTilesFromBoard();
    gameOver.value = false;
    notifyListeners();
  }

  /// Leaves a trial and returns to free play on the player's own board size.
  void exitTrial() {
    _stopTimers();
    activeTrial = null;
    rules = RuleSet.classic;
    gridSize = playerGridSize;
    _resetSessionCounters();
    resetGame();
  }

  void _resetSessionCounters() {
    _sessionStart = DateTime.now();
    // Show the round's real length before the first move. The field defaults
    // to 60, so a 90-second round opened reading "60s" with the bar two
    // thirds full, then jumped up once the clock actually started.
    timeLeft = timeLimitSeconds;
    movesUsed = 0;
    secondsElapsed = 0;
    objectiveMet = false;
    sessionResolved = false;
    usedUndoThisSession = false;
    _boardHistory.clear();
    _tileHistory.clear();
    _scoreHistory.clear();
  }

  void _stopTimers() {
    _timer?.cancel();
    autoPlayTimer?.cancel();
    autoPlay = false;
  }

  /// Builds the tile list for a board that was set directly, such as a trial's
  /// authored starting position.
  void _seedTilesFromBoard() {
    final seeded = <Tile>[];
    for (var y = 0; y < gridSize; y++) {
      for (var x = 0; x < gridSize; x++) {
        final value = board[y][x];
        if (value <= 0) continue; // 0 empty, -1 blocked: neither is a tile
        seeded.add(
          Tile(
            id: 'tile_${_tileIdCounter++}',
            value: value,
            x: x,
            y: y,
            previousX: x,
            previousY: y,
          ),
        );
      }
    }
    tiles = seeded;
  }

  /// Evaluates the active trial after a move. Returns a result once the attempt
  /// is decided, and null while it is still in play.
  TrialResult? evaluateTrial() {
    final trial = activeTrial;
    if (trial == null || sessionResolved) return null;

    final won = trial.objective.isMet(
      board: board,
      score: score,
      movesUsed: movesUsed,
    );
    if (won) {
      objectiveMet = true;
      sessionResolved = true;
      return TrialResult(
        trialId: trial.id,
        outcome: TrialOutcome.won,
        movesUsed: movesUsed,
        score: score,
        highestTile: maxTile(board),
      );
    }

    final exhausted = constraints.isExhausted(
      movesUsed: movesUsed,
      secondsElapsed: secondsElapsed,
    );
    final jammed = !hasMoves(board);
    if (!exhausted && !jammed) return null;

    sessionResolved = true;
    return TrialResult(
      trialId: trial.id,
      outcome: jammed
          ? TrialOutcome.boardJammed
          : (constraints.moveLimit != null && movesUsed >= constraints.moveLimit!
              ? TrialOutcome.outOfMoves
              : TrialOutcome.outOfTime),
      movesUsed: movesUsed,
      score: score,
      highestTile: maxTile(board),
    );
  }

  /// Delegates to the engine, which understands blocked cells.
  ///
  /// The previous hand-rolled scan compared neighbouring cells for equality, so
  /// two adjacent blocked cells (-1 == -1) looked like an available merge and
  /// the game would never end on a board containing them.
  bool isGameOver() => !hasMoves(board);


  void _endTimedGame(BuildContext context, AppLocalizations appLocales) {
    if (dialogShown) return;
    dialogShown = true;
    _timer?.cancel();
    // A timed run ends here rather than through _checkGameOver, so without
    // this it was the one finished game that never reached the statistics.
    logGameOver();
    _recordFinishedGame();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final dialogColors = titanDialogColors(ctx);
        return AlertDialog(
          backgroundColor: dialogColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            appLocales.timeIsUp,
            style: theme.textTheme.titleLarge?.copyWith(
              color: dialogColors.foreground,
            ),
          ),
          content: Text(
            appLocales.finalScore(score),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: dialogColors.foreground,
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: dialogColors.foreground,
                foregroundColor: dialogColors.surface,
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
                // The `restart` string is the bare glyph 🔄 in every locale,
                // which is fine on the small on-board button but leaves a
                // dialog's primary action unlabelled — and an emoji ignores
                // the text colour, so it rendered at 2.1:1 on the button fill.
                appLocales.restartGame,
                style: TextStyle(color: dialogColors.surface),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: dialogColors.foreground,
                foregroundColor: dialogColors.surface,
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
                style: TextStyle(color: dialogColors.surface),
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
    playerGridSize = size;
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
    // The stored figure predates per-mode boards, so it belongs to Classic.
    saveHighScoreToFirebase(highScore, mode: ModeKeys.classic);
    soundEnabled = await prefs.getSoundEnabled();

    // Remember the player's own choice so a fixed-grid mode or trial can
    // borrow the board temporarily and hand it back afterwards.
    playerGridSize = await prefs.getGameBoardSize();

    // A session chosen while these awaits were in flight wins. Do not touch its
    // grid or board — only the preference above is still worth recording.
    if (_sessionStarted) {
      isInitialized = true;
      notifyListeners();
      signInAnonymously();
      return;
    }

    gridSize = playerGridSize;

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
    if (!undoAllowed) return;
    usedUndoThisSession = true;
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
        final dialogColors = titanDialogColors(context);
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          child: AlertDialog(
            backgroundColor: dialogColors.surface,
            title: Text(
              appLocales.gameOverTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                color: dialogColors.foreground,
              ),
            ),
            content: Text(
              appLocales.finalScore(score),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: dialogColors.foreground,
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: dialogColors.foreground,
                  foregroundColor: dialogColors.surface,
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
                  appLocales.restartGame,
                  style: TextStyle(color: dialogColors.surface),
                ),
              ),
            ],
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
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
    if (rules.scored) {
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

    movesUsed++;
    _rebuildTilesFrom(result);
    _spawnTile();

    // Time Attack pays seconds for merges, so chaining is the strategy rather
    // than raw speed.
    if (rules.secondsPerMerge > 0 && result.merges.isNotEmpty) {
      // Capped at the round's own length. Uncapped, merging pays for itself:
      // at +2s a merge, anyone playing competently banks time faster than it
      // drains, and the round never ends — measured on device, a run climbed
      // from 84s to 190s while being played. A round that cannot end cannot
      // post a score either. Merging now staves the clock off rather than
      // banking it, which keeps the pressure the mode exists for.
      final bonus = rules.secondsPerMerge * result.merges.length;
      timeLeft = min(timeLeft + bonus, timeLimitSeconds);
    }

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
            // Always inherit the origin tile's id, merges included. Keeping the
            // identity is what lets AnimatedPositioned slide the tile along its
            // real path; a fresh id would make it pop into existence at the
            // destination. The merge pop is driven by `justMerged` instead.
            id: source?.id ?? 'tile_${_tileIdCounter++}',
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

  int get _spawnCount => rules.spawnPerMove;

  /// Derived from the rule set's spawn weights, so Hardcore's flood of 4s is a
  /// property of the mode's data rather than a conditional here.
  double get _fourSpawnChance {
    final weights = rules.spawnWeights;
    final total = weights.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return 0.1;
    return (weights[4] ?? 0) / total;
  }

  void _syncHighScore() {
    // Trials start from an authored position, so their score is not comparable
    // with a free-play run — a trial can begin with a 512 already on the board.
    // Letting them set the high score would corrupt the leaderboard.
    if (isTrial) return;
    if (!rules.scored) return; // Zen keeps no score to promote.

    // The global figure is still kept — settings shows it, and it is what the
    // legacy Classic board was built from — but it must not gate publishing.
    // It did, and that is why the Time Attack and Hardcore boards were empty:
    // a player holding a 153,532 Classic record would have to beat it in a
    // 90-second run before their first Time Attack score ever posted.
    final mode = _modeName;
    final previousGlobal = highScore;

    // The stored global figure is the legacy *Classic* record, and _initialize
    // republishes it to the Classic ladder on the next launch. Letting any
    // scored mode write it meant a Time Attack run leaked onto the main board
    // a launch later: a 24-point 90-second run posted itself next to six-figure
    // Classic scores. Other modes keep their record in per-mode statistics.
    if (mode == ModeKeys.classic && score > highScore) {
      highScore = score;
      unawaited(prefs.saveHighScore(score));
    }

    final modeBest = progressStore?.stats.forMode(mode).bestScore ?? 0;
    // Classic shares the legacy ladder, so until it has per-mode statistics of
    // its own it is measured against the global figure rather than zero —
    // otherwise the first Classic run after updating would repost a low score.
    final threshold =
        mode == ModeKeys.classic && modeBest == 0 ? previousGlobal : modeBest;

    if (score > threshold) {
      saveHighScoreToFirebase(score, mode: mode);
    }
  }

  void _checkGameOver(BuildContext context, AppLocalizations appLocales) {
    // Zen never ends: a jammed board dissolves its lowest tiles instead, which
    // is what makes it genuinely relaxed rather than "normal with the score
    // hidden".
    if (rules.endBehaviour == EndBehaviour.dissolveLowest) {
      if (!hasMoves(board)) {
        final dissolved = dissolveLowestTiles(board);
        board = dissolved.board;
        _seedTilesFromBoard();
        notifyListeners();
      }
      return;
    }
    if (rules.endBehaviour == EndBehaviour.objective) return;
    if (gameOver.value) return; // Already handled; do not re-fire.
    if (!isGameOver()) return;

    if (soundEnabled) {
      _audioPlayer.play(gameOverSound);
    }
    logGameOver();
    _recordFinishedGame();
    _showGameOverDialog(context, appLocales);
    gameOver.value = true;
  }

  /// Files a completed free-play run into the statistics store.
  ///
  /// Trials are excluded: they report through TrialScreen with their own
  /// outcome, and counting them here would double-count the run.
  void _recordFinishedGame() {
    if (isTrial) return;
    final store = progressStore;
    if (store == null) return;

    final started = _sessionStart;
    final seconds =
        started == null ? 0 : DateTime.now().difference(started).inSeconds;

    store.recordGame(
      mode: _modeName,
      score: score,
      highestTile: maxTile(board),
      moves: movesUsed,
      merges: totalMerges,
      seconds: seconds,
    );
  }

  /// A stable key for per-mode statistics, independent of display language.
  String get _modeName {
    if (rules.endBehaviour == EndBehaviour.dissolveLowest) return ModeKeys.zen;
    if (rules.timeLimit != null) return ModeKeys.timeAttack;
    if (!rules.allowUndo && !rules.allowHints) return ModeKeys.hardcore;
    return ModeKeys.classic;
  }
}
