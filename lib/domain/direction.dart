enum Direction { left, right, up, down }

String? directionToEmoji(String? dir) {
  switch (dir) {
    case 'left':
      return '◀️';
    case 'right':
      return '▶️';
    case 'up':
      return '🔼';
    case 'down':
      return '🔽';
    default:
      return null;
  }
}
