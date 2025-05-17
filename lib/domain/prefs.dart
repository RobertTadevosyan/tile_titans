import 'package:flutter/material.dart';
import 'package:flutter_2048/core/theme/app_theme.dart';
import 'package:flutter_2048/domain/game_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs extends ChangeNotifier{
  Future<int> loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('high_score') ?? 0;
  }

  Future<void> saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final highestScore = await loadHighScore();
    if (score > highestScore) {
      await prefs.setInt('high_score', score);
    }
  }

  Future<void> resetHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('high_score');
  }

  Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('sound_enabled') ?? true;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_enabled', enabled);
  }

  Future<int> getGameBoardSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('board_size') ?? 4;
  }

  Future<void> saveGameBoardSize(int size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('board_size', size);
  }

  Future<void> saveGame(int score, int gridSize, List<List> board) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('saved_score', score);
    prefs.setInt('saved_grid_size', gridSize);
    prefs.setString('saved_board', board.map((row) => row.join(',')).join(';'));
  }

  Future<GameSettings?> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('saved_board');
    if (raw == null || raw.replaceAll(' ', '').isEmpty || raw.isEmpty) {
      return null;
    }

    final gridSize = prefs.getInt('saved_grid_size') ?? 4;
    final score = prefs.getInt('saved_score') ?? 0;
    final board =
        raw
            .split(';')
            .map((r) => r.split(',').map(int.parse).toList())
            .toList();
    return GameSettings(gridSize: gridSize, scroe: score, board: board);
  }

  Future<String> getCurrentTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('theme') ?? AppTheme.Classic.name;
  }

  Future<void> setCurrentTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', themeName);
  }
}
