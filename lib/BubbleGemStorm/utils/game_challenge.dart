import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide Image;

enum ChallengeType { popGems, reachScore, earnMultiplier, surviveTime }

class GameChallenge {
  final String id;
  final String title;
  final ChallengeType type;
  final int target;
  final int coinReward;

  GameChallenge({
    required this.id,
    required this.title,
    required this.type,
    required this.target,
    required this.coinReward,
  });
}

class ChallengeDataService {
  // All possible challenges in your game
  static final List<GameChallenge> allChallenges = [
    GameChallenge(
      id: 'pop_100',
      title: 'Pop 100 Gems',
      type: ChallengeType.popGems,
      target: 100,
      coinReward: 50,
    ),
    GameChallenge(
      id: 'score_500',
      title: 'Reach 500 Score',
      type: ChallengeType.reachScore,
      target: 500, //500,
      coinReward: 100,
    ),
    GameChallenge(
      id: 'score_1000',
      title: 'Reach 1000 Score',
      type: ChallengeType.reachScore,
      target: 1000, //500,
      coinReward: 500,
    ),
    GameChallenge(
      id: 'score_750',
      title: 'Reach 750 Score',
      type: ChallengeType.reachScore,
      target: 750, //500,
      coinReward: 250,
    ),
    GameChallenge(
      id: 'combo_5',
      title: 'Get 5x Multiplier',
      type: ChallengeType.earnMultiplier,
      target: 5,
      coinReward: 150,
    ),
    // GameChallenge(
    //   id: 'survive_60',
    //   title: 'Survive 60 Seconds',
    //   type: ChallengeType.surviveTime,
    //   target: 60,
    //   coinReward: 200,
    // ),
    GameChallenge(
      id: 'pop_200',
      title: 'Pop 200 Gems',
      type: ChallengeType.popGems,
      target: 200,
      coinReward: 120,
    ),
    GameChallenge(
      id: 'pop_50',
      title: 'Pop 50 Gems',
      type: ChallengeType.popGems,
      target: 50,
      coinReward: 25,
    ),
    GameChallenge(
      id: 'score_200',
      title: 'Reach 200 Score',
      type: ChallengeType.reachScore,
      target: 300,
      coinReward: 50,
    ),
    GameChallenge(
      id: 'score_150',
      title: 'Reach 150 Score',
      type: ChallengeType.reachScore,
      target: 150,
      coinReward: 25,
    ),
  ];

  // Logic to pick 3-4 random challenges
  static List<GameChallenge> getRandomDailyChallenges(int count) {
    final list = List<GameChallenge>.from(allChallenges);
    list.shuffle();
    return list.take(count).toList();
  }
}

// class ChallengeRewardOverlay extends StatefulWidget {
//   final String challengeTitle;
//   final VoidCallback onClaimed;
//
//   const ChallengeRewardOverlay({
//     super.key,
//     required this.challengeTitle,
//     required this.onClaimed,
//   });
//
//   @override
//   State<ChallengeRewardOverlay> createState() => _ChallengeRewardOverlayState();
// }
//
// class _ChallengeRewardOverlayState extends State<ChallengeRewardOverlay> {
//   SMITrigger? _openTrigger;
//   bool _isOpened = false;
//
//   void _onRiveInit(Artboard artboard) {
//     // Ensure 'State Machine 1' and 'Trigger' match your .riv file
//     final controller = StateMachineController.fromArtboard(
//       artboard,
//       'State Machine 1',
//     );
//     if (controller != null) {
//       artboard.addController(controller);
//       _openTrigger = controller.findSMI('Trigger');
//     }
//   }
//
//   void _handleClaim() {
//     if (_isOpened) return;
//     setState(() => _isOpened = true);
//     _openTrigger?.fire(); // Rive animation starts
//
//     // Wait for animation to finish, then close
//     Future.delayed(const Duration(milliseconds: 2500), () {
//       widget.onClaimed();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.black.withOpacity(0.9),
//       child: Stack(
//         children: [
//           // Background Glow/Asset (Similar to your rewardBg.png)
//           Positioned.fill(
//             child: Opacity(
//               opacity: 0.4,
//               child: Image.asset(
//                 'assets/minigame3/bubble_gem_storm/icons/rewardBg.png',
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   "CHALLENGE COMPLETE!",
//                   style: TextStyle(
//                     color: Colors.greenAccent,
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'Baloo2',
//                     shadows: [Shadow(color: Colors.black, blurRadius: 10)],
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 40),
//                   child: Text(
//                     widget.challengeTitle,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 32,
//                       fontFamily: 'Baloo2',
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//
//                 // RIVE ANIMATION
//                 GestureDetector(
//                   onTap: _handleClaim,
//                   child: SizedBox(
//                     width: 300,
//                     height: 300,
//                     child: RiveAnimation.asset(
//                       'assets/minigame3/bubble_gem_storm/animations/reward.riv',
//                       onInit: _onRiveInit,
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 20),
//                 if (!_isOpened)
//                   const Text(
//                     "TAP CHEST TO CLAIM",
//                     style: TextStyle(color: Colors.white70, letterSpacing: 2),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
class ChallengeRewardOverlay extends StatefulWidget {
  final String challengeTitle;
  final VoidCallback onClaimed;

  const ChallengeRewardOverlay({
    super.key,
    required this.challengeTitle,
    required this.onClaimed,
  });

  @override
  State<ChallengeRewardOverlay> createState() => _ChallengeRewardOverlayState();
}

class _ChallengeRewardOverlayState extends State<ChallengeRewardOverlay> {
  SMITrigger? _openTrigger;
  bool _isOpened = false;

  void _onRiveInit(Artboard artboard) {
    // Ensure 'State Machine 1' and 'Trigger' match your .riv file
    final controller = StateMachineController.fromArtboard(
      artboard,
      'State Machine 1',
    );
    if (controller != null) {
      artboard.addController(controller);
      _openTrigger = controller.findSMI('Trigger');
    }
  }

  void _handleClaim() {
    if (_isOpened) return;
    setState(() => _isOpened = true);
    _openTrigger?.fire(); // Rive animation starts

    // Wait for animation to finish, then close
    Future.delayed(const Duration(milliseconds: 2500), () {
      widget.onClaimed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.9),
      child: Stack(
        children: [
          // Background Glow/Asset (Similar to your rewardBg.png)
          Positioned.fill(
            child: Container(
              color: Color(0xff313131),

              // child: Image.asset(
              //   'assets/minigame3/bubble_gem_storm/icons/rewardBg.png',
              //   fit: BoxFit.cover,
              // ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "CHALLENGE COMPLETE!",
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Baloo2',
                    shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    widget.challengeTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontFamily: 'Baloo2',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // RIVE ANIMATION
                GestureDetector(
                  onTap: _handleClaim,
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: RiveAnimation.asset(
                      'assets/minigame3/bubble_gem_storm/animations/reward.riv',
                      onInit: _onRiveInit,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                if (!_isOpened)
                  const Text(
                    "TAP CHEST TO CLAIM",
                    style: TextStyle(color: Colors.white70, letterSpacing: 2),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
