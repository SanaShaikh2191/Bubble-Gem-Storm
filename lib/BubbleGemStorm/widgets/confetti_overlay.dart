import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../utils/confetti_manager.dart';

class ConfettiOverlay extends StatelessWidget {
  const ConfettiOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ConfettiWidget(
      confettiController: ConfettiManager.controller,
      blastDirectionality: BlastDirectionality.explosive,
      shouldLoop: false,
      emissionFrequency: 0.05,
      numberOfParticles: 25,
      gravity: 0.3,
    );
  }
}