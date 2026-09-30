import 'package:flutter/material.dart';
import 'package:flutter_2048/core/theme/titan_design.dart';
import 'package:flutter_2048/l10n/app_localizations.dart';

/// Score and personal best above the board.
///
/// Previously two lines of plain centred text — the generic score row that
/// makes a merge game look like every other one. Now a pair of tiles built from
/// the design system, with the live score given visual weight over the record
/// and the numbers animated so a merge is felt in the score as well as on the
/// board.
///
/// The best shown here is the best *for the mode being played*: a Classic
/// record has nothing to say about a 5x5 Hardcore run.
class ScoreBoard extends StatelessWidget {
  final int score;
  final int highestScore;
  final bool isTablet;
  final bool isLandscape;

  const ScoreBoard({
    super.key,
    required this.score,
    required this.highestScore,
    required this.isTablet,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final compact = isLandscape && !isTablet;

    final tiles = [
      _ScoreTile(
        label: l10n.scoreTitle,
        value: score,
        emphasis: true,
        isTablet: isTablet,
        compact: compact,
      ),
      _ScoreTile(
        label: l10n.highScoreTitle,
        value: highestScore,
        emphasis: false,
        isTablet: isTablet,
        compact: compact,
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? TitanSpacing.lg : TitanSpacing.md,
        vertical: compact ? TitanSpacing.sm : TitanSpacing.md,
      ),
      // In phone landscape the board needs the width, so the tiles stack.
      child:
          compact
              ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  tiles[0],
                  const SizedBox(height: TitanSpacing.sm),
                  tiles[1],
                ],
              )
              : Row(
                children: [
                  Expanded(child: tiles[0]),
                  const SizedBox(width: TitanSpacing.md),
                  Expanded(child: tiles[1]),
                ],
              ),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  final String label;
  final int value;

  /// The live score is the one that changes, so it carries the weight.
  final bool emphasis;
  final bool isTablet;
  final bool compact;

  const _ScoreTile({
    required this.label,
    required this.value,
    required this.emphasis,
    required this.isTablet,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.primaryColor;
    final valueSize = isTablet ? 30.0 : (compact ? 17.0 : 23.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: TitanSpacing.md,
        vertical: compact ? TitanSpacing.sm : TitanSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          base.withValues(alpha: emphasis ? 0.22 : 0.1),
          theme.scaffoldBackgroundColor,
        ),
        borderRadius: TitanRadius.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TitanText.sectionLabel(
              context,
            ).copyWith(fontSize: compact ? 10 : 11),
          ),
          const SizedBox(height: 2),
          // Counting the score up makes a big merge legible as a change rather
          // than a number that simply differs from the last time you looked.
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: value, end: value),
            duration: TitanMotion.standard,
            builder: (context, shown, _) {
              return Text(
                _format(shown),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: valueSize,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                  color: theme.colorScheme.onSurface,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Seven-figure scores are real in this game, so the tile must not be sized
  /// by the digits it happens to hold today.
  String _format(int value) => value >= 100000 ? titanCompact(value) : '$value';
}
