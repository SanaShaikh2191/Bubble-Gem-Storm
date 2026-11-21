import 'package:confetti/confetti.dart';

class ConfettiManager {
  static final ConfettiController controller = ConfettiController(
    duration: Duration(seconds: 3),
  );

  static void play() {
    controller.play();

  }
  static void stop() {
    controller.stop();
    
  }
  static void dispose() {
    controller.dispose();
    
  }
}
