import 'package:flutter/material.dart';
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth.clamp(minSize, maxSize);
        final tileSize = boardSize / gridSize;

        return Center(
          child: Container(
            width: boardSize,
            height: boardSize,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.2),
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
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
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
