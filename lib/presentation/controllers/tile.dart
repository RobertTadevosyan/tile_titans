class Tile {
  final String id; // unique and stable
  final int value;
  final int x;
  final int y;
  final bool isNew;
  final bool justMerged;
  final int? mergeScore; // optional
  final int? previousX;
  final int? previousY;

  /// The value this tile held before merging, so the UI can animate the colour
  /// change rather than snapping straight to the doubled tile's colour. Null
  /// for tiles that did not merge this move.
  final int? mergedFromValue;

  Tile({
    required this.id,
    required this.value,
    required this.x,
    required this.y,
    this.isNew = false,
    this.justMerged = false,
    this.mergeScore,
    this.previousX,
    this.previousY,
    this.mergedFromValue,
  });

  Tile copyWith({
    String? id,
    String? oldId,
    int? value,
    int? x,
    int? y,
    bool? isNew,
    bool? justMerged,
    int? mergeScore,
    int? previousX,
    int? previousY,
    int? mergedFromValue,
  }) {
    return Tile(
      id: id ?? this.id,
      value: value ?? this.value,
      x: x ?? this.x,
      y: y ?? this.y,
      isNew: isNew ?? this.isNew,
      justMerged: justMerged ?? this.justMerged,
      mergeScore: mergeScore ?? this.mergeScore,
      previousX: previousX ?? this.previousX,
      previousY: previousY ?? this.previousY,
      mergedFromValue: mergedFromValue ?? this.mergedFromValue,
    );
  }

  @override
  String toString() {
    return 'Tile('
        'id: $id, '
        'val: $value, '
        '{ x: $x, '
        'y: $y }, '
        // 'new: $isNew, '
        // 'JM: $justMerged, '
        // 'MS: $mergeScore, '
        '{ oldX: $previousX, '
        'oldY: $previousY }'
        ')';
  }

  static Tile empty() {
    return Tile(id: '', value: -1, x: -1, y: -1);
  }
}
