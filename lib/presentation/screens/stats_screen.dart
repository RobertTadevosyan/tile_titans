import 'package:flutter/material.dart';
import 'package:flutter_2048/core/theme/titan_design.dart';
import 'package:flutter_2048/domain/progress/achievements.dart';
import 'package:flutter_2048/domain/progress/progress_store.dart';
import 'package:flutter_2048/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// Statistics, achievements and the Path of the Titans.
///
/// The controller already counted moves and merges every game and then threw
/// them away when the run ended. This is where they finally go.
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
              TitanSectionHeader(label: l10n.statistics),
              _StatGrid(
                entries: [
                  (label: l10n.statGamesPlayed, value: '${stats.gamesPlayed}'),
                  (
                    label: l10n.statBestScore,
                    value: titanCompact(stats.bestScore)
                  ),
                  (
                    label: l10n.statHighestTile,
                    value: '${stats.highestTile}'
                  ),
                  (
                    label: l10n.statTotalMerges,
                    value: titanCompact(stats.totalMerges)
                  ),
                  (
                    label: l10n.statAverageScore,
                    value: titanCompact(stats.averageScore)
                  ),
                  (
                    label: l10n.statLongestGame,
                    value: '${stats.longestGameMoves}'
                  ),
                  (
                    label: l10n.statPlayTime,
                    value: titanDuration(stats.playTimeSeconds)
                  ),
                  (
                    label: l10n.statFavouriteMode,
                    value: stats.favouriteMode ?? '—'
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.pathOfTitans.toUpperCase(),
            style: TitanText.sectionLabel(context),
          ),
          const SizedBox(height: TitanSpacing.xs),
          Text(rank.name, style: TitanText.display(context).copyWith(fontSize: 26)),
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
                : '${progress.points} / ${next.required} → ${next.name}',
            style: TitanText.cardBody(context),
          ),
        ],
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  final List<({String label, String value})> entries;

  const _StatGrid({required this.entries});

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
                child: Center(
                  child: TitanMetric(label: entry.label, value: entry.value),
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
    return TitanCard(
      padding: const EdgeInsets.all(TitanSpacing.md),
      child: Row(
        children: [
          Icon(
            unlocked ? Icons.military_tech_rounded : Icons.lock_outline_rounded,
            size: 22,
            color: unlocked ? Theme.of(context).primaryColor : null,
          ),
          const SizedBox(width: TitanSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(achievement.name, style: TitanText.cardTitle(context)),
                Text(
                  achievement.description,
                  style: TitanText.cardBody(context),
                ),
                if (!unlocked) ...[
                  const SizedBox(height: TitanSpacing.sm),
                  ClipRRect(
                    borderRadius: TitanRadius.small,
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: Theme.of(context)
                          .primaryColor
                          .withValues(alpha: 0.18),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: TitanSpacing.sm),
          Text(
            '${achievement.points}',
            style: TitanText.cardBody(context),
          ),
        ],
      ),
    );
  }
}
