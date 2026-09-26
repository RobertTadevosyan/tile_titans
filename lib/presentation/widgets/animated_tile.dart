import 'package:flutter/material.dart';
import 'package:flutter_2048/content/titan_ranks.dart';
import 'package:flutter_2048/core/theme/theme_provider.dart';
import 'package:flutter_2048/core/theme/titan_design.dart';
import 'package:flutter_2048/core/theme/themes.dart';
import 'package:flutter_2048/presentation/controllers/tile.dart';
import 'package:flutter_2048/presentation/widgets/merge_bloom.dart';
import 'package:flutter_2048/presentation/widgets/merge_score_text.dart';
import 'package:flutter_2048/presentation/widgets/titan_emblem.dart';
import 'package:provider/provider.dart';

/// One tile on the board.
///
/// Three animations run here, each explaining a different change:
///  * **Movement** — the tile slides from where it actually came from. The
///    origin comes from the engine's move tracking; it used to be inferred by
///    matching positions after the board had moved, which meant every tile
///    animated exactly one cell no matter how far it travelled.
///  * **Merge** — the surviving tile's colour travels from the pair's colour to
///    its own while a bloom rings outward, so fusing is a visible process
///    rather than a silent swap.
///  * **Arrival** — a scale pop for newly spawned and freshly merged tiles.
class AnimatedTile extends StatefulWidget {
  final Tile tile;
  final double tileSize;
  final bool isTablet;
  final bool isLandscape;

  const AnimatedTile({
    super.key,
    required this.tile,
    required this.tileSize,
    required this.isTablet,
    required this.isLandscape,
  });

  @override
  State<AnimatedTile> createState() => _AnimatedTileState();
}

class _AnimatedTileState extends State<AnimatedTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    );

    if (widget.tile.isNew && !widget.tile.justMerged) {
      _scaleController.forward();
    } else {
      _scaleController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Punch the tile when it merges, so the fusion has weight.
    if (widget.tile.justMerged && !oldWidget.tile.justMerged) {
      _scaleController.forward(from: 0.5);
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tile = widget.tile;
    if (tile.id.isEmpty) return const SizedBox();

    final tileSize = widget.tileSize;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final palette = tileColors[themeProvider.currentTheme];
    final defaultColor = Theme.of(context).primaryColor.withOpacity(0.85);
    final tileColor = palette?[tile.value] ?? defaultColor;

    // Where the merge colour tween starts. Null for tiles that did not merge.
    Color? mergedFromColor;
    final fromValue = tile.mergedFromValue;
    if (tile.justMerged && fromValue != null) {
      mergedFromColor = palette?[fromValue];
    }

    // Honour the platform's reduce-motion setting: the bloom is decoration, so
    // it is dropped entirely rather than merely shortened.
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final rank = rankForValue(tile.value);

    // Position is animated by AnimatedPositioned rather than by tweening an
    // offset back to zero.
    //
    // The offset approach cannot work here: a sliding tile keeps its id, so
    // Flutter reuses the widget, and TweenAnimationBuilder only re-runs when
    // its `end` changes. With `end` pinned at Offset.zero the tile was already
    // sitting at the target, so a new `begin` was ignored and the tile jumped.
    // AnimatedPositioned interpolates left/top between builds instead, which
    // gives the true path for any distance.
    return AnimatedPositioned(
      key: ValueKey(tile.id),
      duration: Duration(milliseconds: reduceMotion ? 0 : 190),
      curve: Curves.easeOutCubic,
      left: tile.x * tileSize,
      top: tile.y * tileSize,
      width: tileSize,
      height: tileSize,
      child: ScaleTransition(
          scale: _scaleAnimation,
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(
              begin: mergedFromColor ?? tileColor,
              end: tileColor,
            ),
            duration: Duration(
              milliseconds: reduceMotion ? 0 : (tile.justMerged ? 300 : 200),
            ),
            curve: Curves.easeOutCubic,
            builder: (context, animatedColor, _) {
              return _buildSurface(
                surfaceColor: animatedColor ?? tileColor,
                finalColor: tileColor,
                tile: tile,
                tileSize: tileSize,
                rank: rank,
                reduceMotion: reduceMotion,
              );
            },
          ),
        ),
    );
  }

  Widget _buildSurface({
    required Color surfaceColor,
    required Color finalColor,
    required Tile tile,
    required double tileSize,
    required TitanRank rank,
    required bool reduceMotion,
  }) {
    // Contrast is measured from the colour actually on screen, so the numeral
    // stays readable mid-merge and across every theme. The old rule keyed off
    // the tile's value and guessed wrong on the dark palettes.
    final numeralColor = surfaceColor.computeLuminance() > kContrastCrossover
        ? const Color(0xFF14181C)
        : Colors.white;
    final showEmblem = tileSize >= 44;

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          // Glow picks up the tile's own colour, so it strengthens naturally
          // as values climb and the palette deepens.
          BoxShadow(
            color: surfaceColor.withOpacity(0.6),
            blurRadius: 14,
            spreadRadius: 0.5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The sigil is the tile's identity; the numeral is a label beneath
          // it. Stacked rather than overlaid — overlaying was tried and made
          // both unreadable, because the digits cover the middle of the emblem.
          //
          // On very small tiles (large grids) the emblem is dropped and the
          // numeral returns to full size: a 10 px sigil is noise, and the
          // number is what you actually need.
          if (showEmblem) ...[
            Align(
              alignment: const Alignment(0, -0.2),
              child: TitanEmblem(
                emblem: rank.emblem,
                color: numeralColor.withOpacity(rank.isMilestone ? 0.98 : 0.88),
                size: tileSize * (rank.isMilestone ? 0.58 : 0.54),
                weight: rank.isMilestone ? 0.12 : 0.105,
              ),
            ),
            Align(
              alignment: const Alignment(0, 0.86),
              child: Text(
                '${tile.value}',
                maxLines: 1,
                style: TextStyle(
                  fontSize: _numeralSize(tile.value, tileSize),
                  fontWeight: FontWeight.w700,
                  height: 1,
                  letterSpacing: 0.2,
                  color: numeralColor.withOpacity(0.92),
                ),
              ),
            ),
          ] else
            Text(
              '${tile.value}',
              style: TextStyle(
                fontSize: _getFontSize(tile.value, tileSize),
                fontWeight: FontWeight.bold,
                color: numeralColor,
              ),
            ),

          // The forge flash, keyed so it replays on each new merge.
          if (tile.justMerged)
            Positioned.fill(
              child: MergeBloom(
                key: ValueKey('bloom-${tile.id}-${tile.value}'),
                color: _bloomColor(finalColor, numeralColor),
                emphatic: rank.isMilestone,
                enabled: !reduceMotion,
              ),
            ),

          if (tile.justMerged && tile.mergeScore != null)
            Positioned(child: MergeScoreText(score: tile.mergeScore!)),
        ],
      ),
    );
  }

  /// The bloom reads as heat, so it leans toward the light end of the tile's
  /// own palette rather than using a fixed accent that would clash per theme.
  Color _bloomColor(Color tileColor, Color numeralColor) {
    return Color.lerp(tileColor, numeralColor, 0.65) ?? numeralColor;
  }

  /// Numeral size when the emblem leads. Scales with the tile and shrinks as
  /// digits pile up, so 131072 still fits the same footprint as 2.
  double _numeralSize(int value, double tileSize) {
    final digits = value.toString().length;
    final scale = switch (digits) {
      1 || 2 => 1.0,
      3 => 0.94,
      4 => 0.84,
      5 => 0.74,
      _ => 0.64,
    };
    return (tileSize * 0.185 * scale).clamp(8.0, 19.0);
  }

  /// Fallback sizing for boards too small to carry an emblem.
  double _getFontSize(int value, double tileSize) {
    final isPhoneLandscape = widget.isLandscape && !widget.isTablet;
    final length = value.toString().length;
    switch (length) {
      case 1:
        return isPhoneLandscape ? 22 : (widget.isTablet ? 38 : 32);
      case 2:
        return isPhoneLandscape ? 22 : (widget.isTablet ? 38 : 30);
      case 3:
        return isPhoneLandscape ? 20 : (widget.isTablet ? 34 : 22);
    }
    return (tileSize.round() / length) + 2;
  }
}
