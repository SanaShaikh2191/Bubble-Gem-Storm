// -----------------------------Tutorial--------------------------------------

import 'dart:ui';

import 'package:flutter/material.dart';

import 'constants.dart';

class TutorialStep {
  final GlobalKey key;
  final String title;
  final String description;
  // final Offset offset;
  // final EdgeInsets padding;

  TutorialStep({
    required this.key,
    required this.title,
    required this.description,
    // this.offset = Offset.zero,
    // this.padding = EdgeInsets.zero,
  });
}

class SpotlightPainter extends CustomPainter {
  final Rect? holeRect;
  final double pulse;

  SpotlightPainter(this.holeRect, this.pulse);

  @override
  void paint(Canvas canvas, Size size) {
    if (holeRect == null) return;

    final paint = Paint()..color = Colors.black.withOpacity(0.85);
    final currentHoleSize = 15 + (pulse * 15);

    // Draw the dark overlay
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addOval(holeRect!.inflate(currentHoleSize)),
      ),
      paint,
    );

    // DRAW THE SOFT GLOW (The "Popular Game" look)
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withOpacity(0.4), Colors.transparent],
      ).createShader(holeRect!.inflate(currentHoleSize + 20));

    canvas.drawOval(holeRect!.inflate(currentHoleSize + 20), glowPaint);
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) => true;
}

class AdvancedTutorialOverlay extends StatefulWidget {
  final List<TutorialStep> steps;
  final int currentStep;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  // final ScrollController scrollController;

  const AdvancedTutorialOverlay({
    super.key,
    required this.steps,
    required this.currentStep,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
    // required this.scrollController,
  });

  @override
  State<AdvancedTutorialOverlay> createState() =>
      _AdvancedTutorialOverlayState();
}

class _AdvancedTutorialOverlayState extends State<AdvancedTutorialOverlay>
    with TickerProviderStateMixin {
  Rect? targetRect;
  late AnimationController _pulseController;
  late AnimationController _appearController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // 1. Pulse for the spotlight
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // 2. Entrance animation (SpringBounce)
    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _appearController,
      curve: Curves.elasticOut, //This gives the "Game Pop" feel
    );

    _appearController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateTarget());
  }

  @override
  void didUpdateWidget(covariant AdvancedTutorialOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      _appearController.forward(from: 0.0); // Re-pop on next step
      _updateTarget();
    }
  }

  void _updateTarget() {
    final step = widget.steps[widget.currentStep];
    final targetContext = step.key.currentContext;
    if (targetContext == null) return;

    final targetBox = targetContext.findRenderObject() as RenderBox?;
    final overlayBox = context.findRenderObject() as RenderBox?;
    if (targetBox != null && overlayBox != null) {
      final position = targetBox.localToGlobal(
        Offset.zero,
        ancestor: overlayBox,
      );
      setState(() {
        targetRect = position & targetBox.size;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[widget.currentStep];
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate position: If spotlight is low, put text high.
    double? top;
    double? bottom;
    if (targetRect != null) {
      if (targetRect!.center.dy > screenHeight / 2) {
        top = screenHeight * 0.15;
      } else {
        bottom = screenHeight * 0.15;
      }
    }

    return Positioned.fill(
      child: Stack(
        children: [
          // 1. THE SPOTLIGHT (Background)
          if (targetRect != null)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: SpotlightPainter(targetRect, _pulseController.value),
                );
              },
            ),

          // 2. THE CONTENT (Floating Card)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            top: top,
            bottom: bottom,
            left: 20,
            right: 20,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: _buildGameCard(step),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(TutorialStep step) {
    return Container(
      padding: const EdgeInsets.all(2), // Border thickness
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.5), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Frosted Glass
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // STEP INDICATOR
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    // color: title2,
                    gradient: LinearGradient(colors: [title1, title2]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "STEP ${widget.currentStep + 1} / ${widget.steps.length}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // TITLE
                Text(
                  step.title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Baloo2',
                    shadows: [Shadow(color: title1, blurRadius: 20)],
                  ),
                ),
                const SizedBox(height: 10),
                // DESCRIPTION
                Text(
                  step.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 30),
                // THE "JUICY" BUTTON
                _buildJuicyButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJuicyButton() {
    return GestureDetector(
      onTap: widget.onNext,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 1.1),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: _pulseController.value * 0.1 + 1.0, // Button pulses too!
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: title1.withOpacity(0.5), blurRadius: 20),
                ],
                gradient: LinearGradient(colors: [title1, title2]),
              ),
              child: const Text(
                "GOT IT!",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _appearController.dispose();
    super.dispose();
  }
}
