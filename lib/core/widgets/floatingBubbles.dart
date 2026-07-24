import 'package:flutter/material.dart';

class FloatingBubbles extends StatefulWidget {
  final double size; // base size of bubble
  final Color color;
  const FloatingBubbles({super.key, this.size = 50, this.color = Colors.grey});

  @override
  State<FloatingBubbles> createState() => _FloatingBubblesState();
}

class _FloatingBubblesState extends State<FloatingBubbles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Animation controller for 1.5 seconds repeating
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    // Tween to grow and shrink bubble
    _animation = Tween<double>(
      begin: widget.size*1.5,
      end: widget.size*1.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: _animation.value,
          height: _animation.value,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.7),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
