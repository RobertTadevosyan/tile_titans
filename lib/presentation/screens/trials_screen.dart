import 'package:flutter/material.dart';
import 'package:flutter_2048/content/trials.dart';
import 'package:flutter_2048/core/theme/titan_design.dart';
import 'package:flutter_2048/domain/engine/trial.dart';
import 'package:flutter_2048/domain/progress/progress_store.dart';
import 'package:flutter_2048/l10n/app_localizations.dart';
import 'package:flutter_2048/presentation/l10n_content.dart';
import 'package:flutter_2048/presentation/screens/trial_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_2048/presentation/widgets/screen_banner.dart';

/// The authored trial library, grouped into chapters.
///
/// Everything is unlocked from the start. Gating trials behind progress would
/// hide the game's differentiating content from anyone evaluating it — and
/// punishing a new player for starting at Trial X is not a design goal.
class TrialsScreen extends StatelessWidget {
  const TrialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = context.watch<ProgressStore>();

    return Scaffold(
      bottomNavigationBar: const ScreenBanner(),
      appBar: AppBar(title: Text(l10n.homeTitanTrials)),
      body: SafeArea(
        child: TitanPage(
          child: ListView(
            children: [
              Text(
                l10n.homeCompleted(progress.trialsCompleted, allTrials.length),
                style: TitanText.cardTitle(context),
              ),
              for (final chapter in trialChapters) ...[
                TitanSectionHeader(
                  label: ContentStrings.chapter(l10n, chapter.id),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: TitanSpacing.sm),
                  child: Text(
                    ContentStrings.chapterTheme(l10n, chapter.id),
                    style: TitanText.cardBody(context),
                  ),
                ),
                for (final trial in chapter.trials)
                  Padding(
                    padding: const EdgeInsets.only(bottom: TitanSpacing.md),
                    child: _TrialTile(
                      l10n: l10n,
                      trial: trial,
                      record: progress.recordFor(trial.id),
                    ),
                  ),
              ],
              const SizedBox(height: TitanSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrialTile extends StatelessWidget {
  final AppLocalizations l10n;
  final Trial trial;
  final TrialRecord? record;

  const _TrialTile({
    required this.l10n,
    required this.trial,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    final done = record?.completed ?? false;

    return TitanCard(
      onTap:
          () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => TrialScreen(trial: trial)),
          ),
      contentBuilder:
          (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    done
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 20,
                    color: done ? Theme.of(context).primaryColor : null,
                  ),
                  const SizedBox(width: TitanSpacing.sm),
                  Expanded(
                    child: Text(
                      ContentStrings.trialName(l10n, trial),
                      style: TitanText.cardTitle(context),
                    ),
                  ),
                  if (done && record!.bestMoves > 0)
                    Text(
                      '${l10n.homeBest}: ${record!.bestMoves}',
                      style: TitanText.cardBody(context),
                    ),
                ],
              ),
              const SizedBox(height: TitanSpacing.xs),
              Text(
                ContentStrings.objective(l10n, trial.objective),
                style: TitanText.cardBody(context),
              ),
              const SizedBox(height: TitanSpacing.sm),
              Wrap(
                spacing: TitanSpacing.sm,
                runSpacing: TitanSpacing.xs,
                children: [
                  // Board size is stated up front, because an authored position
                  // only works on the grid it was drawn for and that overrides the
                  // player's own board-size setting for the duration.
                  _Tag(label: '${trial.gridSize}×${trial.gridSize}'),
                  if (trial.constraints.moveLimit != null)
                    _Tag(
                      label: l10n.trialMoveLimit(trial.constraints.moveLimit!),
                    ),
                  if (trial.constraints.timeLimit != null)
                    _Tag(
                      label: l10n.trialTimeLimit(trial.constraints.timeLimit!),
                    ),
                  if (!trial.constraints.allowUndo)
                    _Tag(label: l10n.trialNoUndo),
                  if (!trial.constraints.allowHints)
                    _Tag(label: l10n.trialNoHints),
                  if (trial.hasBlockedCells) _Tag(label: '⛔'),
                ],
              ),
            ],
          ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: TitanRadius.small,
        color: Theme.of(context).primaryColor.withValues(alpha: 0.16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
