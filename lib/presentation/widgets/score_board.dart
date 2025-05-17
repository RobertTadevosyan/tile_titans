import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final textSize = isTablet ? 24.0 : isLandscape ? 14.0 : 16.0;
    final appLocales = AppLocalizations.of(context)!;
    return Padding(
      padding:  EdgeInsets.all(isTablet ? 16.0 : 12.0),
      child:
          !isTablet && isLandscape
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(appLocales.score(score), style: TextStyle(fontSize: textSize)),
                  Text(
                    appLocales.highScore(highestScore),
                    style:  TextStyle(fontSize: textSize),
                  ),
                ],
              )
              : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(appLocales.score(score), style:  TextStyle(fontSize: textSize)),
                  Text(
                    appLocales.highScore(highestScore),
                    style:  TextStyle(fontSize: textSize),
                  ),
                ],
              ),
    );
  }
}
