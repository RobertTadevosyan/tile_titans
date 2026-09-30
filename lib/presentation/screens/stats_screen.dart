import 'package:flutter/material.dart';
import 'package:flutter_2048/content/trials.dart';
import 'package:flutter_2048/core/theme/titan_design.dart';
import 'package:flutter_2048/domain/progress/achievements.dart';
import 'package:flutter_2048/domain/progress/progress_store.dart';
import 'package:flutter_2048/l10n/app_localizations.dart';
import 'package:flutter_2048/presentation/l10n_content.dart';
import 'package:provider/provider.dart';

/// Statistics, achievements and the Path of the Titans.
///
/// Records are shown per mode rather than pooled. The modes are not comparable
/// — Hardcore is a 5x5 board flooded with 4s, Time Attack is ninety seconds,
/// Zen keeps no score — so a single "best score" across all of them would be a
/// number describing nothing. Lifetime figures are still shown, but only for
/// the quantities that genuinely add up: games, merges and time played.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = context.watch<ProgressStore>();
    final stats = progress.stats;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statistics)),
      body: SafeArea(
        child: TitanPage(
          child: ListView(
            children: [
              _RankCard(l10n: l10n, progress: progress),

              TitanSectionHeader(label: l10n.statsLifetime),
              _MetricGrid(
                entries: [
                  (label: l10n.statGamesPlayed, value: '${stats.gamesPlayed}'),
                  (
                    label: l10n.statTotalMerges,
                    value: titanCompact(stats.totalMerges),
                  ),
                  (
                    label: l10n.statPlayTime,
                    value: titanDuration(stats.playTimeSeconds),
                  ),
                  (
                    label: l10n.statFavouriteMode,
                    value: _modeLabel(l10n, stats.favouriteMode) ?? '—',
                  ),
                ],
              ),

              TitanSectionHeader(label: l10n.statsByMode),
              for (final mode in ModeKeys.freePlay)
                Padding(
                  padding: const EdgeInsets.only(bottom: TitanSpacing.md),
                  child: _ModeCard(
                    l10n: l10n,
                    title: _modeLabel(l10n, mode)!,
                    mode: mode,
                    stats: stats.forMode(mode),
                  ),
                ),

              TitanSectionHeader(label: l10n.statsTrials),
              _MetricGrid(
                entries: [
                  (
                    label: l10n.statsTrials,
                    value: '${progress.trialsCompleted}/${allTrials.length}',
                  ),
                  (
                    label: l10n.statsChapters,
                    value:
                        '${progress.chaptersCompleted}/${trialChapters.length}',
                  ),
                  (label: l10n.statsDaily, value: '${progress.dailyStreak}'),
                  (
                    label: l10n.trialNoUndo,
                    value: '${progress.trialsWonWithoutUndo}',
                  ),
                ],
              ),

              TitanSectionHeader(label: l10n.achievements),
              for (final achievement in achievements)
                Padding(
                  padding: const EdgeInsets.only(bottom: TitanSpacing.sm),
                  child: _AchievementRow(
                    achievement: achievement,
                    unlocked: progress.hasAchievement(achievement.id),
                    progress: progress.progressToward(achievement),
                  ),
                ),
              const SizedBox(height: TitanSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  /// Mode keys are stored as stable strings; this maps them to the player's
  /// language without the storage format depending on it.
  static String? _modeLabel(AppLocalizations l10n, String? mode) {
    switch (mode) {
      case ModeKeys.classic:
        return l10n.modeClassic;
      case ModeKeys.zen:
        return l10n.modeZen;
      case ModeKeys.timeAttack:
        return l10n.modeTimeAttack;
      case ModeKeys.hardcore:
        return l10n.modeHardcore;
      default:
        return null;
    }
  }
}

class _ModeCard extends StatelessWidget {
  final AppLocalizations l10n;
  final String title;
  final String mode;
  final ModeStats stats;

  const _ModeCard({
    required this.l10n,
    required this.title,
    required this.mode,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    // Zen keeps no score, so showing a best score for it would be a lie.
    final scored = mode != ModeKeys.zen;

    return TitanCard(
      contentBuilder:
          (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(title, style: TitanText.cardTitle(context)),
                  ),
                  Text(
                    '${stats.gamesPlayed}',
                    style: TitanText.cardBody(context),
                  ),
                ],
              ),
              const SizedBox(height: TitanSpacing.sm),
              if (stats.isEmpty)
                Text(l10n.statsNotPlayed, style: TitanText.cardBody(context))
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final metrics = <Widget>[
                      if (scored)
                        TitanMetric(
                          label: l10n.statBestScore,
                          value: titanCompact(stats.bestScore),
                        ),
                      TitanMetric(
                        label: l10n.statHighestTile,
                        value: '${stats.highestTile}',
                      ),
                      TitanMetric(
                        label: l10n.statLongestGame,
                        value: '${stats.longestGameMoves}',
                      ),
                      if (scored)
                        TitanMetric(
                          label: l10n.statAverageScore,
                          value: titanCompact(stats.averageScore),
                        ),
                    ];

                    // Four columns inside a card leave about 75dp each on a phone.
                    // English fits; "Partie la plus longue" does not, and adjacent
                    // labels ran into each other with no gap between them. Two
                    // columns on a narrow card, four when there is room.
                    final columns = constraints.maxWidth >= 420 ? 4 : 2;
                    const gap = TitanSpacing.md;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < metrics.length; i += columns) ...[
                          if (i > 0) const SizedBox(height: gap),
                          Row(
                            // A label that wraps to two lines is taller than its
                            // neighbours, and a centred row hangs them at
                            // different heights — close enough to read as
                            // overlapping text.
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (
                                var j = i;
                                j < i + columns && j < metrics.length;
                                j++
                              ) ...[
                                if (j > i) const SizedBox(width: gap),
                                Expanded(child: metrics[j]),
                              ],
                            ],
                          ),
                        ],
                      ],
                    );
                  },
                ),
            ],
          ),
    );
  }
}

class _RankCard extends StatelessWidget {
  final AppLocalizations l10n;
  final ProgressStore progress;

  const _RankCard({required this.l10n, required this.progress});

  @override
  Widget build(BuildContext context) {
    final rank = progress.rank;
    final next = progress.nextRank;
    final span = next == null ? 1 : (next.required - rank.required);
    final into = next == null ? 1 : (progress.points - rank.required);
    final fraction = span <= 0 ? 1.0 : (into / span).clamp(0.0, 1.0);

    return TitanCard(
      prominent: true,
      contentBuilder:
          (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.pathOfTitans.toUpperCase(),
                style: TitanText.sectionLabel(context),
              ),
              const SizedBox(height: TitanSpacing.xs),
              Text(
                ContentStrings.rank(l10n, rank),
                style: TitanText.display(context).copyWith(fontSize: 26),
              ),
              const SizedBox(height: TitanSpacing.sm),
              ClipRRect(
                borderRadius: TitanRadius.small,
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 6,
                  backgroundColor: Colors.black.withValues(alpha: 0.15),
                ),
              ),
              const SizedBox(height: TitanSpacing.xs),
              Text(
                next == null
                    ? '${progress.points} / $maxAchievementPoints'
                    : '${progress.points} / ${next.required} → '
                        '${ContentStrings.rank(l10n, next)}',
                style: TitanText.cardBody(context),
              ),
            ],
          ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  final List<({String label, String value})> entries;

  const _MetricGrid({required this.entries});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 520 ? 4 : 2;
        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: TitanSpacing.md,
          crossAxisSpacing: TitanSpacing.md,
          childAspectRatio: 1.7,
          children: [
            for (final entry in entries)
              TitanCard(
                padding: const EdgeInsets.all(TitanSpacing.md),
                contentBuilder:
                    (context) => Center(
                      child: TitanMetric(
                        label: entry.label,
                        value: entry.value,
                      ),
                    ),
              ),
          ],
        );
      },
    );
  }
}

class _AchievementRow extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;
  final double progress;

  const _AchievementRow({
    required this.achievement,
    required this.unlocked,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TitanCard(
      padding: const EdgeInsets.all(TitanSpacing.md),
      contentBuilder:
          (context) => Row(
            children: [
              Icon(
                unlocked
                    ? Icons.military_tech_rounded
                    : Icons.lock_outline_rounded,
                size: 22,
                color: unlocked ? Theme.of(context).primaryColor : null,
              ),
              const SizedBox(width: TitanSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ContentStrings.achievementName(l10n, achievement.id),
                      style: TitanText.cardTitle(context),
                    ),
                    Text(
                      ContentStrings.achievementDescription(l10n, achievement),
                      style: TitanText.cardBody(context),
                    ),
                    if (!unlocked) ...[
                      const SizedBox(height: TitanSpacing.sm),
                      ClipRRect(
                        borderRadius: TitanRadius.small,
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: Theme.of(
                            context,
                          ).primaryColor.withValues(alpha: 0.18),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: TitanSpacing.sm),
              Text('${achievement.points}', style: TitanText.cardBody(context)),
            ],
          ),
    );
  }
}
