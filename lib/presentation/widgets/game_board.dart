import 'package:flutter/material.dart';
import 'package:flutter_2048/domain/engine/board.dart';
import 'package:flutter_2048/presentation/controllers/game_controller.dart';
import 'package:flutter_2048/presentation/widgets/animated_tile.dart';
import 'package:provider/provider.dart';

class GameBoard extends StatelessWidget {
  final double maxSize;
  final double minSize;
  final bool isTablet;
  final bool isLandscape;
  const GameBoard({
    super.key,
    required this.maxSize,
    required this.minSize,
    required this.isTablet,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<GameController>(context);
    final tiles = controller.getTiles();
    final gridSize = controller.gridSize;
    final board = controller.board;

    return LayoutBuilder(
      builder: (context, constraints) {
        // The board is square, so it has to fit the shorter of the two axes.
        // Sizing from width alone worked until the surrounding column ran out
        // of room: on an iPhone SE the game screen overflowed by 148 pixels,
        // because a 343-wide board was asked for on a screen that had less
        // than that left over. Height is only considered when it is bounded —
        // inside a scrolling parent it is not.
        final available = constraints.maxHeight.isFinite
            ? (constraints.maxWidth < constraints.maxHeight
                ? constraints.maxWidth
                : constraints.maxHeight)
            : constraints.maxWidth;
        final boardSize = available.clamp(minSize, maxSize);
        final tileSize = boardSize / gridSize;

        return Center(
          child: Container(
            width: boardSize,
            height: boardSize,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Static background tiles
                for (int y = 0; y < gridSize; y++)
                  for (int x = 0; x < gridSize; x++)
                    Positioned(
                      left: x * tileSize,
                      top: y * tileSize,
                      width: tileSize,
                      height: tileSize,
                      child: _BackgroundCell(
                        // A blocked cell must look solid rather than empty,
                        // otherwise a trial's shape is invisible and the player
                        // cannot tell why a tile will not slide there.
                        blocked: y < board.length &&
                            x < board[y].length &&
                            board[y][x] == blockedCell,
                      ),
                    ),

                // Animated foreground tiles
                ...tiles
                    .where((t) => t.id.isNotEmpty && t.value > 0)
                    .map(
                      (tile) => AnimatedTile(
                        key: ValueKey(tile.id),
                        tile: tile,
                        tileSize: tileSize,
                        isLandscape: isLandscape,
                        isTablet: isTablet,
                      ),
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// An empty or blocked cell behind the tiles.
class _BackgroundCell extends StatelessWidget {
  final bool blocked;

  const _BackgroundCell({required this.blocked});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    // Derived from the theme rather than a fixed grey. The hard-coded
    // Colors.grey[300] glared as near-white holes on every dark palette.
    final empty = onSurface.withValues(alpha: 0.1);

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: blocked ? onSurface.withValues(alpha: 0.55) : empty,
        borderRadius: BorderRadius.circular(8),
        border: blocked
            ? Border.all(color: onSurface.withValues(alpha: 0.75), width: 2)
            : null,
      ),
      child: blocked
          ? Center(
              child: Icon(
                Icons.close_rounded,
                size: 18,
                // Blocked state is carried by shape as well as colour, so it
                // does not rely on colour vision alone.
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            )
          : null,
    );
  }
}
