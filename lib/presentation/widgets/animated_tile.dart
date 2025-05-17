import 'package:flutter/material.dart';
import 'package:flutter_2048/core/theme/app_theme.dart';
import 'package:flutter_2048/core/theme/theme_provider.dart';
import 'package:flutter_2048/core/theme/themes.dart';
import 'package:flutter_2048/presentation/controllers/game_controller.dart';
import 'package:flutter_2048/presentation/controllers/tile.dart';
import 'package:flutter_2048/presentation/widgets/merge_score_text.dart';
import 'package:provider/provider.dart';

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
  Color? _mergeColor;

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

    if (widget.tile.justMerged && !oldWidget.tile.justMerged) {
      _scaleController.forward(from: 0.5);
      setState(() {
        _mergeColor = Colors.amberAccent;
      });

      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) {
          setState(() {
            _mergeColor = null;
          });
        }
      });
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
    if (tile.id.isEmpty) return SizedBox();
    final tileSize = widget.tileSize;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final defaultColor = Theme.of(context).primaryColor.withOpacity(0.85);
    final controller = Provider.of<GameController>(context);
    final lastMoveOffset = controller.lastMoveOffset ?? Offset(0, 0);
    final diffX = /*tile.isNew ? 0 : */ lastMoveOffset.dx;
    final diffY = /*tile.isNew ? 0 : */ lastMoveOffset.dy;
    final dx =
        tile.previousX != null
            ? (tile.previousX! - tile.x - diffX) * tileSize
            : 0.0;
    final dy =
        tile.previousY != null
            ? (tile.previousY! - tile.y - diffY) * tileSize
            : 0.0;

    return Positioned(
      key: ValueKey(tile.id),
      left: tile.x * tileSize,
      top: tile.y * tileSize,
      width: tileSize,
      height: tileSize,
      child: TweenAnimationBuilder<Offset>(
        tween: Tween<Offset>(begin: Offset(dx, dy), end: Offset.zero),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        builder: (context, offset, child) {
          return Transform.translate(offset: offset, child: child);
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color:
                  tileColors[themeProvider.currentTheme]?[tile.value] ??
                  defaultColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(3, 3),
                ),
              ],
            ),
            margin: const EdgeInsets.all(4),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '${tile.value}',
                  style: TextStyle(
                    fontSize: _getFontSize(tile.value),
                    fontWeight: FontWeight.bold,
                    color: tile.value <= 4 ? Colors.black : Colors.white,
                  ),
                ),
                if (tile.justMerged && tile.mergeScore != null)
                  Positioned(child: MergeScoreText(score: tile.mergeScore!)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _getFontSize(int value) {
    final isPhoneLandscape = widget.isLandscape && !widget.isTablet;
    final length = value.toString().length;
    if (length <= 2) return isPhoneLandscape ? 22 : 24;
    if (length == 3) return isPhoneLandscape ? 20 : 22;
    if (length == 4) return isPhoneLandscape ? 16 : 18;
    if (length == 5) return isPhoneLandscape ? 14 : 16;
    if (length == 6) return isPhoneLandscape ? 12 : 14;
    return isPhoneLandscape ? 10 : 14; // fallback for larger values
  }
}
