import 'package:flutter/material.dart';

class MergeScoreText extends StatefulWidget {
  final int score;

  const MergeScoreText({super.key, required this.score});

  @override
  State<MergeScoreText> createState() => _MergeScoreTextState();
}

class _MergeScoreTextState extends State<MergeScoreText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
    _offset = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -1.2))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: Text(
          '+${widget.score}',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.red,
            fontWeight: FontWeight.bold,
            // shadows: [
            //   Shadow(blurRadius: 4, color: Colors.black38, offset: Offset(0, 0)),
            // ],
          ),
        ),
      ),
    );
  }
}
