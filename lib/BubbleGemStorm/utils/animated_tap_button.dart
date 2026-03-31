import 'package:flutter/material.dart';
import '../utils/haptic_manager.dart';

class AnimatedTapButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration duration;

  const AnimatedTapButton({
    super.key,
    required this.child,
    required this.onTap,
    this.duration = const Duration(milliseconds: 120),
  });

  @override
  State<AnimatedTapButton> createState() => _AnimatedTapButtonState();
}

class _AnimatedTapButtonState extends State<AnimatedTapButton> {
  double scale = 1.0;

  void _onTapDown(TapDownDetails _) {
    setState(() => scale = 0.92);
    HapticManager.ligth();
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: scale,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
