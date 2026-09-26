import 'package:flutter_2048/domain/engine/board.dart';
import 'package:flutter_2048/domain/engine/objective.dart';
import 'package:flutter_2048/domain/engine/rules.dart';
import 'package:flutter_2048/domain/engine/trial.dart';

/// The authored Titan Trials library.
///
/// This file is the game's content. Every board below is hand-placed rather
/// than generated, which is the point: an endless merge game has no levels, so
/// a library of designed positions is the clearest possible evidence that this
/// is a different product.
///
/// Board notation: `0` empty, `-1` blocked (written as [x] below for reading),
/// any other number is a starting tile.
///
/// Design rules followed throughout:
///  * No trial starts nearly solved — the player does the work.
///  * Blocked cells never sit in all four corners; corner strategy must survive.
///  * Move budgets are generous enough to allow one bad swipe.
///  * Each chapter introduces exactly one new idea.
const int _x = blockedCell;

/// A named group of trials, so progression reads as chapters rather than a
/// flat list of 18 items.
class TrialChapter {
  final String id;
  final String name;

  /// One line on what this chapter teaches.
  final String theme;
  final List<Trial> trials;

  const TrialChapter({
    required this.id,
    required this.name,
    required this.theme,
    required this.trials,
  });
}

/// Chapter I — objectives, with room to breathe. Teaches that a trial ends on
/// a goal rather than on a jammed board.
const _chapterOne = TrialChapter(
  id: 'forge',
  name: 'The Forge',
  theme: 'Learn the objectives',
  trials: [
    Trial(
      id: 'forge-1',
      name: 'Trial I',
      summary: 'Reach 64 in 40 moves',
      startBoard: [
        [2, 4, 0, 0],
        [0, 2, 0, 0],
        [0, 0, 4, 0],
        [0, 0, 0, 2],
      ],
      objective: Objective.reachTile(64),
      constraints: Constraints(moveLimit: 40),
    ),
    Trial(
      id: 'forge-2',
      name: 'Trial II',
      summary: 'Reach 128 in 60 moves',
      startBoard: [
        [8, 4, 2, 0],
        [4, 2, 0, 0],
        [2, 0, 0, 0],
        [0, 0, 0, 0],
      ],
      objective: Objective.reachTile(128),
      constraints: Constraints(moveLimit: 60),
    ),
    Trial(
      id: 'forge-3',
      name: 'Trial III',
      summary: 'Score 1,500 in 50 moves',
      startBoard: [
        [0, 2, 2, 0],
        [0, 4, 4, 0],
        [0, 2, 2, 0],
        [0, 0, 0, 0],
      ],
      objective: Objective.reachScore(1500),
      constraints: Constraints(moveLimit: 50),
    ),
    Trial(
      id: 'forge-4',
      name: 'Trial IV',
      summary: 'Hold two 32 tiles at once',
      startBoard: [
        [16, 0, 0, 16],
        [8, 0, 0, 8],
        [0, 4, 4, 0],
        [0, 2, 2, 0],
      ],
      objective: Objective.createTiles(32, 2),
      constraints: Constraints(moveLimit: 45),
    ),
    Trial(
      id: 'forge-5',
      name: 'Trial V',
      summary: 'Survive 60 moves',
      startBoard: [
        [2, 4, 8, 16],
        [4, 8, 16, 32],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
      objective: Objective.survive(60),
    ),
    Trial(
      id: 'forge-6',
      name: 'Trial VI',
      summary: 'Reach 256 in 90 moves',
      startBoard: [
        [32, 16, 8, 4],
        [16, 8, 4, 2],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
      ],
      objective: Objective.reachTile(256),
      constraints: Constraints(moveLimit: 90),
    ),
  ],
);

/// Chapter II — blocked cells. One new idea: part of the board is simply gone,
/// so the usual corner-stacking opening has to be rethought.
const _chapterTwo = TrialChapter(
  id: 'proving',
  name: 'The Proving Ground',
  theme: 'Blocked cells and no undo',
  trials: [
    Trial(
      id: 'proving-1',
      name: 'Trial VII',
      summary: 'Reach 64 with the centre blocked',
      startBoard: [
        [2, 0, 0, 2],
        [0, _x, _x, 0],
        [0, _x, _x, 0],
        [4, 0, 0, 4],
      ],
      objective: Objective.reachTile(64),
      constraints: Constraints(moveLimit: 60, allowUndo: false),
    ),
    Trial(
      id: 'proving-2',
      name: 'Trial VIII',
      summary: 'Reach 128 through a split board',
      startBoard: [
        [2, 4, _x, 2],
        [4, 2, _x, 4],
        [0, 0, _x, 0],
        [0, 0, _x, 0],
      ],
      objective: Objective.reachTile(128),
      constraints: Constraints(moveLimit: 80, allowUndo: false),
    ),
    Trial(
      id: 'proving-3',
      name: 'Trial IX',
      summary: 'Score 2,000 around the pillars',
      startBoard: [
        [0, 2, 2, 0],
        [_x, 4, 4, _x],
        [0, 8, 8, 0],
        [_x, 2, 2, _x],
      ],
      objective: Objective.reachScore(2000),
      constraints: Constraints(moveLimit: 70, allowUndo: false),
    ),
    Trial(
      id: 'proving-4',
      name: 'Trial X',
      summary: 'Hold three 32 tiles at once',
      startBoard: [
        [16, 16, 0, 0],
        [8, 8, _x, 0],
        [16, 16, 0, 0],
        [8, 8, 0, 0],
      ],
      objective: Objective.createTiles(32, 3),
      constraints: Constraints(moveLimit: 55, allowUndo: false),
    ),
    Trial(
      id: 'proving-5',
      name: 'Trial XI',
      summary: 'Reach 256 without hints',
      startBoard: [
        [2, 4, 8, 0],
        [0, _x, 16, 0],
        [0, 0, 32, 0],
        [0, 0, 64, 0],
      ],
      objective: Objective.reachTile(256),
      constraints: Constraints(
        moveLimit: 100,
        allowUndo: false,
        allowHints: false,
      ),
    ),
    // The one pure puzzle in the library: nothing spawns, so the position is
    // fully deterministic and has a known solution. A merge game with a
    // solvable fixed position is the clearest "this is not an endless board"
    // artifact in the app.
    Trial(
      id: 'proving-6',
      name: 'Trial XII',
      summary: 'Collapse the stack to 2 tiles',
      startBoard: [
        [2, 2, 2, 2],
        [2, 2, 2, 2],
        [4, 4, 4, 4],
        [0, 0, 0, 0],
      ],
      objective: Objective.clearBoard(2),
      constraints: Constraints(moveLimit: 12, allowUndo: false),
      rules: RuleSet(
        spawnPerMove: 0,
        endBehaviour: EndBehaviour.objective,
      ),
    ),
  ],
);

/// Chapter III — the clock, and a wider board. The final trial is deliberately
/// hard; it is the one people will talk about.
const _chapterThree = TrialChapter(
  id: 'summit',
  name: 'The Summit',
  theme: 'Time pressure and open ground',
  trials: [
    Trial(
      id: 'summit-1',
      name: 'Trial XIII',
      summary: 'Reach 128 in 90 seconds',
      startBoard: [
        [4, 2, 0, 0],
        [2, 4, 0, 0],
        [0, 0, 2, 0],
        [0, 0, 0, 4],
      ],
      objective: Objective.reachTile(128),
      constraints: Constraints(timeLimit: 90, allowUndo: false),
    ),
    Trial(
      id: 'summit-2',
      name: 'Trial XIV',
      summary: 'Score 3,000 in two minutes',
      startBoard: [
        [8, 4, 2, 0],
        [4, 2, 0, 0],
        [2, 0, 0, 0],
        [0, 0, 0, 0],
      ],
      objective: Objective.reachScore(3000),
      constraints: Constraints(timeLimit: 120, allowUndo: false),
    ),
    Trial(
      id: 'summit-3',
      name: 'Trial XV',
      summary: 'Reach 512 on open ground',
      startBoard: [
        [64, 32, 16, 8, 0],
        [32, 16, 8, 4, 0],
        [0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0],
      ],
      objective: Objective.reachTile(512),
      constraints: Constraints(moveLimit: 150, allowUndo: false),
      rules: RuleSet(gridSize: 5, endBehaviour: EndBehaviour.objective),
    ),
    Trial(
      id: 'summit-4',
      name: 'Trial XVI',
      summary: 'Survive 100 moves under pressure',
      startBoard: [
        [2, 4, 2, 4, 2],
        [4, 2, 4, 2, 4],
        [0, 0, _x, 0, 0],
        [0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0],
      ],
      objective: Objective.survive(100),
      constraints: Constraints(allowUndo: false),
      rules: RuleSet(
        gridSize: 5,
        spawnWeights: {2: 4, 4: 6},
        endBehaviour: EndBehaviour.objective,
      ),
    ),
    Trial(
      id: 'summit-5',
      name: 'Trial XVII',
      summary: 'Hold two 128 tiles at once',
      startBoard: [
        [64, 0, 0, 64],
        [32, 0, 0, 32],
        [16, _x, _x, 16],
        [8, 0, 0, 8],
      ],
      objective: Objective.createTiles(128, 2),
      constraints: Constraints(moveLimit: 70, allowUndo: false),
    ),
    Trial(
      id: 'summit-6',
      name: 'Trial XVIII',
      summary: 'Reach 1024. No undo, no hints.',
      startBoard: [
        [128, 64, 32, 16, 8],
        [64, 32, 16, 8, 4],
        [0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0],
      ],
      objective: Objective.reachTile(1024),
      constraints: Constraints(
        moveLimit: 200,
        allowUndo: false,
        allowHints: false,
      ),
      rules: RuleSet(gridSize: 5, endBehaviour: EndBehaviour.objective),
    ),
  ],
);

/// Every chapter, in play order.
const List<TrialChapter> trialChapters = [
  _chapterOne,
  _chapterTwo,
  _chapterThree,
];

/// Every trial, flattened, in play order.
List<Trial> get allTrials =>
    trialChapters.expand((chapter) => chapter.trials).toList();

/// Looks up a trial by its stable id, or null when it is not in the library.
Trial? trialById(String id) {
  for (final chapter in trialChapters) {
    for (final trial in chapter.trials) {
      if (trial.id == id) return trial;
    }
  }
  return null;
}

/// The chapter a trial belongs to.
TrialChapter? chapterForTrial(String trialId) {
  for (final chapter in trialChapters) {
    if (chapter.trials.any((t) => t.id == trialId)) return chapter;
  }
  return null;
}
