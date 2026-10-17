import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_2048/config/interstitial_service.dart';
import 'package:flutter_2048/core/theme/titan_design.dart';
import 'package:flutter_2048/domain/engine/objective.dart';
import 'package:flutter_2048/domain/engine/trial.dart';
import 'package:flutter_2048/domain/progress/achievements.dart';
import 'package:flutter_2048/domain/progress/progress_store.dart';
import 'package:flutter_2048/l10n/app_localizations.dart';
import 'package:flutter_2048/presentation/l10n_content.dart';
import 'package:flutter_2048/presentation/controllers/game_controller.dart';
import 'package:flutter_2048/presentation/widgets/game_board.dart';
import 'package:flutter_2048/presentation/widgets/screen_banner.dart';
import 'package:provider/provider.dart';

/// Plays one authored trial or the Daily Trial.
///
/// Deliberately a separate screen from free play rather than another branch
/// inside the 887-line game screen: a trial has an objective, a budget and a
/// definite end, and those need to be on screen the whole time. Mixing them
/// into the free-play layouts would have meant a fifth near-duplicate builder.
class TrialScreen extends StatefulWidget {
  final Trial trial;

  /// True for the Daily Trial, which also maintains the streak.
  final bool isDaily;

  const TrialScreen({super.key, required this.trial, this.isDaily = false});

  @override
  State<TrialScreen> createState() => _TrialScreenState();
}

class _TrialScreenState extends State<TrialScreen> {
  Timer? _clock;
  bool _moving = false;
  TrialResult? _result;
  List<Achievement> _unlocked = const [];

  /// Captured while the element is still live; see didChangeDependencies.
  GameController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // dispose() cannot look this up: the element is deactivated by then and
    // the lookup throws, so exitTrial() could fail to run and the board would
    // stay on the trial's rules after the player had left it.
    _controller = context.read<GameController>();
  }

  @override
  void initState() {
    super.initState();
    // Load the authored position after the first frame so the controller's
    // notifyListeners does not fire during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GameController>().startTrial(widget.trial);
      _startClockIfTimed();
    });
  }

  void _startClockIfTimed() {
    final limit = widget.trial.constraints.timeLimit;
    if (limit == null) return;

    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final controller = context.read<GameController>();
      controller.secondsElapsed++;
      if (controller.secondsElapsed >= limit) {
        _evaluate();
      } else {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    // Hand the board back to the player's own settings, but not from inside
    // dispose: exitTrial notifies its listeners, and the widget tree is locked
    // while a route is being torn down — "setState() or markNeedsBuild()
    // called when widget tree was locked". Deferring by a frame lets the
    // teardown finish first.
    final controller = _controller;
    if (controller != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.exitTrial();
      });
    }
    super.dispose();
  }

  void _handleSwipe(Offset delta) {
    if (_moving || _result != null) return;
    const threshold = 4.0;
    if (delta.dx.abs() < threshold && delta.dy.abs() < threshold) return;

    final controller = context.read<GameController>();
    final l10n = AppLocalizations.of(context)!;

    if (delta.dx.abs() > delta.dy.abs()) {
      delta.dx > 0
          ? controller.moveRight(context, l10n)
          : controller.moveLeft(context, l10n);
    } else {
      delta.dy > 0
          ? controller.moveDown(context, l10n)
          : controller.moveUp(context, l10n);
    }

    _moving = true;
    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted) _moving = false;
    });

    _evaluate();
  }

  Future<void> _evaluate() async {
    final controller = context.read<GameController>();
    final outcome = controller.evaluateTrial();
    if (outcome == null) return;

    _clock?.cancel();
    final progress = context.read<ProgressStore>();

    final unlocked = await progress.recordTrial(
      outcome,
      usedUndo: controller.usedUndoThisSession,
    );
    if (widget.isDaily) {
      final more = await progress.recordDaily(
        date: DateTime.now(),
        won: outcome.won,
      );
      unlocked.addAll(more);
    }

    if (!mounted) return;
    setState(() {
      _result = outcome;
      _unlocked = unlocked;
    });

    // Shown after the result is on screen, so the player sees what they earned
    // before anything interrupts — and only on every third win.
    if (outcome.won) {
      await context.read<InterstitialService>().maybeShowAfterWin();
    }
  }

  void _retry() {
    _clock?.cancel();
    context.read<GameController>().startTrial(widget.trial);
    setState(() {
      _result = null;
      _unlocked = const [];
    });
    _startClockIfTimed();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<GameController>();
    final trial = widget.trial;

    return Scaffold(
      // Same placement as the free-play board: the banner sits below the
      // controls with clear space above it, so an overshot swipe lands on the
      // gap rather than the ad.
      bottomNavigationBar: const ScreenBanner(),
      appBar: AppBar(title: Text(ContentStrings.trialName(l10n, trial))),
      body: SafeArea(
        child: Stack(
          children: [
            TitanPage(
              child: Column(
                children: [
                  _ObjectiveBanner(
                    l10n: l10n,
                    trial: trial,
                    controller: controller,
                  ),
                  const SizedBox(height: TitanSpacing.lg),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: (d) => _handleSwipe(d.delta),
                      child: GameBoard(
                        maxSize: 520,
                        minSize: 260,
                        isTablet: false,
                        isLandscape: false,
                      ),
                    ),
                  ),
                  if (controller.undoAllowed)
                    Padding(
                      padding: const EdgeInsets.only(top: TitanSpacing.sm),
                      child: TextButton.icon(
                        onPressed: controller.canUndo ? controller.undo : null,
                        icon: const Icon(Icons.undo_rounded),
                        label: Text(l10n.undo),
                      ),
                    ),
                  const SizedBox(height: TitanSpacing.lg),
                ],
              ),
            ),
            if (_result != null)
              _ResultOverlay(
                l10n: l10n,
                result: _result!,
                unlocked: _unlocked,
                onRetry: _retry,
                onLeave: () => Navigator.of(context).pop(),
              ),
          ],
        ),
      ),
    );
  }
}

/// The objective and budget, on screen for the whole attempt.
class _ObjectiveBanner extends StatelessWidget {
  final AppLocalizations l10n;
  final Trial trial;
  final GameController controller;

  const _ObjectiveBanner({
    required this.l10n,
    required this.trial,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final progress = controller.objectiveProgress ?? 0;
    final movesLeft = controller.movesRemaining;
    // A survive objective has no move budget, so nothing was shown at all and
    // the player could not see how far through it they were.
    final survivalTarget =
        trial.objective.kind == ObjectiveKind.survive
            ? trial.objective.target
            : null;
    final timeLimit = trial.constraints.timeLimit;
    final secondsLeft =
        timeLimit == null ? null : (timeLimit - controller.secondsElapsed);

    // A budget running out is the one thing that should visibly alarm.
    final urgent =
        (movesLeft != null && movesLeft <= 5) ||
        (secondsLeft != null && secondsLeft <= 10);

    return TitanCard(
      contentBuilder:
          (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.trialObjective.toUpperCase(),
                style: TitanText.sectionLabel(context),
              ),
              const SizedBox(height: TitanSpacing.xs),
              Text(
                ContentStrings.objective(l10n, trial.objective),
                style: TitanText.cardTitle(context),
              ),
              const SizedBox(height: TitanSpacing.sm),
              ClipRRect(
                borderRadius: TitanRadius.small,
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withValues(alpha: 0.18),
                ),
              ),
              const SizedBox(height: TitanSpacing.sm),
              Row(
                children: [
                  if (movesLeft != null)
                    _Budget(
                      icon: Icons.swipe_rounded,
                      label: l10n.trialMoveLimit(movesLeft),
                      urgent: urgent,
                    )
                  else if (survivalTarget != null)
                    _Budget(
                      icon: Icons.swipe_rounded,
                      label: '${controller.movesUsed} / $survivalTarget',
                      urgent: false,
                    ),
                  if (secondsLeft != null)
                    _Budget(
                      icon: Icons.timer_rounded,
                      label: l10n.trialTimeLimit(
                        secondsLeft < 0 ? 0 : secondsLeft,
                      ),
                      urgent: urgent,
                    ),
                  const Spacer(),
                  if (controller.scored)
                    Text(
                      l10n.score(controller.score),
                      style: TitanText.cardBody(context).copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                ],
              ),
            ],
          ),
    );
  }
}

class _Budget extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool urgent;

  const _Budget({
    required this.icon,
    required this.label,
    required this.urgent,
  });

  @override
  Widget build(BuildContext context) {
    // Urgency is signalled with weight and a tinted pill, never by recolouring
    // the text. Painting it colorScheme.error assumed that red contrasts with
    // whatever card it lands on, which is not true across six themes — the same
    // mistake that made the win dialog unreadable.
    final onCard = Theme.of(context).colorScheme.onSurface;
    final error = Theme.of(context).colorScheme.error;

    return Padding(
      padding: const EdgeInsets.only(right: TitanSpacing.md),
      child: Container(
        padding:
            urgent
                ? const EdgeInsets.symmetric(horizontal: 8, vertical: 2)
                : EdgeInsets.zero,
        decoration:
            urgent
                ? BoxDecoration(
                  color: error.withValues(alpha: 0.22),
                  borderRadius: TitanRadius.small,
                )
                : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: onCard),
            const SizedBox(width: 4),
            Text(
              label,
              style: TitanText.cardBody(context).copyWith(
                color: onCard,
                fontWeight: urgent ? FontWeight.w800 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Win or loss, with anything newly unlocked.
class _ResultOverlay extends StatelessWidget {
  final AppLocalizations l10n;
  final TrialResult result;
  final List<Achievement> unlocked;
  final VoidCallback onRetry;
  final VoidCallback onLeave;

  const _ResultOverlay({
    required this.l10n,
    required this.result,
    required this.unlocked,
    required this.onRetry,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    final won = result.won;

    return Container(
      color: Colors.black.withValues(alpha: 0.62),
      child: Center(
        child: TitanPage(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TitanCard(
                prominent: won,
                contentBuilder:
                    (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          won
                              ? Icons.military_tech_rounded
                              : Icons.shield_outlined,
                          size: 34,
                        ),
                        const SizedBox(height: TitanSpacing.sm),
                        Text(
                          won ? l10n.trialComplete : l10n.trialFailed,
                          style: TitanText.display(
                            context,
                          ).copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: TitanSpacing.sm),
                        Text(
                          _outcomeDetail(l10n),
                          style: TitanText.cardBody(context),
                        ),
                        if (unlocked.isNotEmpty) ...[
                          const SizedBox(height: TitanSpacing.md),
                          for (final achievement in unlocked)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 16),
                                  const SizedBox(width: TitanSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      achievement.name,
                                      style: TitanText.cardBody(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                        const SizedBox(height: TitanSpacing.lg),
                        // Buttons are styled from the card's own surface rather
                        // than the page theme. On a win the card is filled with the
                        // accent colour, so a default FilledButton renders
                        // accent-on-accent and an OutlinedButton's label is the
                        // accent too — both invisible.
                        Builder(
                          builder: (context) {
                            final onCard =
                                Theme.of(context).colorScheme.onSurface;
                            return Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: onLeave,
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: onCard,
                                      side: BorderSide(
                                        color: onCard.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: Text(l10n.close),
                                  ),
                                ),
                                const SizedBox(width: TitanSpacing.md),
                                Expanded(
                                  child: FilledButton(
                                    onPressed: onRetry,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: onCard,
                                      foregroundColor: titanForegroundOn(
                                        onCard,
                                      ),
                                    ),
                                    child: Text(l10n.restartGame),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _outcomeDetail(AppLocalizations l10n) {
    switch (result.outcome) {
      case TrialOutcome.won:
        return '${l10n.moves(result.movesUsed)} · ${l10n.score(result.score)}';
      case TrialOutcome.outOfMoves:
        return l10n.trialMoveLimit(result.movesUsed);
      case TrialOutcome.outOfTime:
        return l10n.timeIsUp;
      case TrialOutcome.boardJammed:
        return l10n.gameOver;
    }
  }
}
