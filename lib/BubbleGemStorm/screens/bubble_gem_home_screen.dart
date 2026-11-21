import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/bubble_gem_firestore_service.dart';
import '../utils/confetti_manager.dart';
import '../utils/constants.dart';
import '../utils/game_tutorial.dart';
import '../utils/level_config.dart';
import '../utils/sound_manager.dart';
import '../widgets/confetti_overlay.dart';
import '../utils/ad_service.dart';

// class BubbleGemHomeScreen extends StatefulWidget {
//   const BubbleGemHomeScreen({super.key});

//   @override
//   State<BubbleGemHomeScreen> createState() => _BubbleGemHomeScreenState();
// }

// class _BubbleGemHomeScreenState extends State<BubbleGemHomeScreen>
//     with SingleTickerProviderStateMixin {
//   bool sound = true;
//   bool vibration = true;
//   String? _dailyFreeBooster;

//   bool showStreakReward = false;
//   int rewardStreakCount = 0;

//   final GlobalKey levelKey = GlobalKey();
//   final GlobalKey highscoreKey = GlobalKey();
//   final GlobalKey startGameKey = GlobalKey();
//   int highScore = 0;
//   bool showTutorial = false;
//   int currentTutorialStep = 0;
//   List<TutorialStep> _tutorialSteps() {
//     return [
//       TutorialStep(
//         key: levelKey,
//         title: 'Levels',
//         description:
//             'Level will complete after completing the different objective of different level.You will be rewarded with a LIFE❤️ ',
//       ),
//       // TutorialStep(
//       //   key: infoKey,
//       //   title: 'TUTORIAL BUTTON',
//       //   description: 'Click the button to Rewatch the Game Tutorial ',
//       // ),
//       TutorialStep(
//         key: highscoreKey,
//         title: 'HIGH SCORE DISPLAY',
//         description:
//             'Your best score is displayed here. Challenge yourself to beat it!',
//       ),
//       TutorialStep(
//         key: startGameKey,
//         title: 'PLAY BUTTON',
//         description:
//             'Begin your Bubble gems adventure! Burst bubble gems to acheive the objectives .',
//       ),
//     ];
//   }

//   @override
//   void initState() {
//     super.initState();
//     SoundManager.instance.playHomeTheme();
//     // loadSoundSettings();
//     _checkTutorial();

//     _handleStreak();
//   }

//   Future<void> _handleStreak() async {
//     // Wait a bit for the UI to settle
//     await Future.delayed(const Duration(seconds: 3));

//     // // TEMPORARY FOR TESTING:
//     // setState(() {
//     //   rewardStreakCount = 3; // Pretend they hit day 3
//     //   showStreakReward = true; // Force the overlay to show
//     // });

//     final streakData = await BubbleGemFirestoreService.checkAndUpdateStreak();

//     if (streakData != null) {
//       int currentUnlockedLevel =
//           await BubbleGemFirestoreService.unlockedLevelStream().first;

//       // Find the tier of the current level
//       final currentLevelConfig = myCustomLevels.firstWhere(
//         (l) => l.id == currentUnlockedLevel,
//         orElse: () => myCustomLevels.first,
//       );

//       String booster = streakData['freeBooster'] ?? 'shield';

//       // LOGIC: If inTier 1 and the booster is 'time', swap it
//       // because Tier 1 (Score Rush) usually doesn't use the time booster.
//       if (currentLevelConfig.tier == GameTier.tier1 && booster == 'time') {
//         // Swap to a booster useful in Tier 1, e.g., 'shield' or 'magnet'
//         booster = 'shield';
//       }

//       // if (streakData != null) {
//       setState(() {
//         rewardStreakCount = streakData['streak'];
//         _dailyFreeBooster = streakData['freeBooster'];
//         showStreakReward = true;
//       });
//       // }
//     }
//   }

//   void _claimStreakReward() async {
//     // Give 100 coins forevery 3-day milestone

//     if (rewardStreakCount % 3 == 0) {
//       await BubbleGemFirestoreService.addCoins(50);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("50 Coins added to your treasure!")),
//       );
//     }
//     setState(() {
//       showStreakReward = false;
//     });
//   }

//   // // -------------to show tutorial only once per user--------------
//   Future<void> _checkTutorial() async {
//     final prefs = await SharedPreferences.getInstance();
//     final seen = prefs.getBool('home_tutorial_seen') ?? false;
//     // final force = prefs.getBool('circle_rush_force_tutorial') ?? false;

//     if (!seen) {
//       await Future.delayed(Duration(milliseconds: 400));

//       setState(() {
//         showTutorial = true;
//       });
//       // await prefs.setBool('circle_rush_force_tutorial', false);
//     }
//   }

//   Future<void> _completeTutorial() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('home_tutorial_seen', true);

//     setState(() {
//       showTutorial = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final w = size.width;
//     final h = size.height;
//     return Scaffold(
//       backgroundColor: bg,
//       body: Stack(
//         children: [
//           SafeArea(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: w * 0.04),
//               child: Center(
//                 child: Column(
//                   // mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Container(
//                             key: levelKey,
//                             child: StreamBuilder<int>(
//                               stream:
//                                   BubbleGemFirestoreService.unlockedLevelStream(),
//                               builder: (context, snapshot) {
//                                 final unlocked = snapshot.data ?? 1;
//                                 // const maxLevels = 25;
//                                 //
//                                 // final progress = unlocked / maxLevels;
//                                 // Find the current level config based on global unlocked ID
//                                 final currentLevelConfig = myCustomLevels
//                                     .firstWhere(
//                                       (l) => l.id == unlocked,
//                                       orElse: () => myCustomLevels.last,
//                                     );

//                                 String tierName = "";
//                                 int totalInTier = 0;
//                                 switch (currentLevelConfig.tier) {
//                                   case GameTier.tier1:
//                                     tierName = "Tier 1: Score Rush";
//                                     totalInTier = 20;
//                                     break;
//                                   case GameTier.tier2:
//                                     tierName = "Tier 2: Survivor";
//                                     totalInTier = 30;
//                                     break;
//                                   case GameTier.tier3:
//                                     tierName = "Tier 3:Master";
//                                     totalInTier = 50;
//                                     break;
//                                 }

//                                 final progress =
//                                     currentLevelConfig.localLevel / totalInTier;
//                                 return Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     SizedBox(height: h * 0.01),
//                                     Text(
//                                       tierName,
//                                       style: TextStyle(
//                                         color: title1,
//                                         fontSize: w * 0.055,
//                                         fontWeight: FontWeight.bold,
//                                         fontFamily: 'Baloo2',
//                                       ),
//                                     ),
//                                     Text(
//                                       "Level  ${currentLevelConfig.localLevel} / $totalInTier",
//                                       style: TextStyle(
//                                         color: title1,
//                                         fontSize: w * 0.043,
//                                         fontWeight: FontWeight.w400,
//                                         fontFamily: 'Baloo2',
//                                         letterSpacing: -1,
//                                       ),
//                                     ),

//                                     SizedBox(height: h * 0.01),
//                                     Container(
//                                       decoration: BoxDecoration(
//                                         // border: Border.all(color: title2),
//                                         borderRadius: BorderRadius.circular(20),
//                                       ),
//                                       child: ClipRRect(
//                                         borderRadius: BorderRadius.circular(20),
//                                         child: LinearProgressIndicator(
//                                           value: progress.clamp(0.0, 1.0),
//                                           minHeight: 8,
//                                           backgroundColor: whitecolor,
//                                           // .withValues(alpha: 0.2),
//                                           valueColor: AlwaysStoppedAnimation(
//                                             title2,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     SizedBox(height: h * 0.02),
//                                   ],
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                         SizedBox(
//                           width: w * 0.06,
//                         ), // Space between progress and coins
//                         // --- NEW COIN DISPLAY ---
//                         StreamBuilder<int>(
//                           stream: BubbleGemFirestoreService.coinsStream(),
//                           builder: (context, snapshot) {
//                             final coins = snapshot.data ?? 0;
//                             return Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 8,
//                               ),
//                               decoration: BoxDecoration(
//                                 // color: whitecolor.withOpacity(0.05),
//                                 borderRadius: BorderRadius.circular(15),
//                                 border: Border.all(
//                                   color: purplecolor.withValues(alpha: 0.2),
//                                   width: 1.5,
//                                 ),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Image.asset(
//                                     'assets/minigame3/bubble_gem_storm/icons/coin.png',
//                                     width: 18,
//                                   ),
//                                   // const Icon(
//                                   //   Icons.monetization_on,
//                                   //   color: Colors.amber,
//                                   //   size: 18,
//                                   // ),
//                                   SizedBox(width: w * 0.015),
//                                   Text(
//                                     "$coins",
//                                     style: TextStyle(
//                                       color: purplecolor,
//                                       fontWeight: FontWeight.bold,
//                                       fontFamily: 'Baloo2',
//                                       fontSize: w * 0.04,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                         SizedBox(width: w * 0.02),
//                         // InkWell(
//                         //   onTap: () {
//                         //     SoundManager.instance.stopTheme();
//                         //     context.go('/circle-rush-home');
//                         //   },
//                         //   child: Container(
//                         //     padding: EdgeInsets.symmetric(horizontal: w * 0.03),
//                         //     // width: 47,
//                         //     height: h * 0.05,
//                         //     decoration: BoxDecoration(
//                         //       borderRadius: BorderRadius.circular(12),
//                         //       // shape: BoxShape.circle,
//                         //       border: Border.all(color: title1),
//                         //     ),
//                         //     child: Row(
//                         //       children: [
//                         //         Icon(Icons.home, color: title2, size: 20),
//                         //         SizedBox(width: 5),
//                         //         Text(
//                         //           'EXIT',
//                         //           style: TextStyle(
//                         //             fontSize: w * 0.035,
//                         //             fontWeight: FontWeight.w700,
//                         //             fontFamily: 'Baloo2',
//                         //             color: title1,
//                         //           ),
//                         //         ),
//                         //       ],
//                         //     ),
//                         //   ),
//                         // ),
//                         InkWell(
//                           onTap: () => context.push('/bubble-gem-profile'),
//                           child: Container(
//                             height: w * 0.11,
//                             width: w * 0.11,
//                             decoration: BoxDecoration(
//                               color: bg,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: whitecolor.withValues(alpha: 0.1),
//                                   blurRadius: 20,
//                                   spreadRadius: 2,
//                                 ),
//                               ],
//                               borderRadius: BorderRadius.circular(13),
//                               // gradient: LinearGradient(
//                               //   colors: [
//                               //     whiteColor.withOpacity(0.1),
//                               //     whiteColor.withOpacity(0.1),
//                               //   ],
//                               // ),
//                               border: Border.all(
//                                 color: purplecolor.withValues(alpha: 0.2),
//                                 width: 1.5,
//                               ),
//                             ),
//                             child: Center(
//                               child: Icon(
//                                 Icons.local_parking_rounded,
//                                 color: purplecolor,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     Spacer(),
//                     // SizedBox(height: h * 0.095),
//                     gradientText(
//                       [title1, title2],
//                       "Bubble  Gem ",
//                       fontsize: w * 0.17,
//                       height: 0.8,
//                       fontweight: FontWeight.bold,
//                     ),
//                     gradientText(
//                       [title1, title2],
//                       "Storm ",
//                       fontsize: w * 0.17,
//                       height: 1,
//                       fontweight: FontWeight.bold,
//                     ),
//                     // SizedBox(height: h * 0.01),
//                     Text(
//                       "Tap fast,Survive,Dominate!",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: w * 0.05,
//                         fontWeight: FontWeight.bold,
//                         color: whitecolor.withValues(alpha: 0.7),
//                         fontFamily: 'Baloo2',
//                       ),
//                     ),
//                     SizedBox(height: h * 0.02),
//                     Container(
//                       key: highscoreKey,
//                       padding: EdgeInsets.symmetric(
//                         vertical: 10,
//                         horizontal: 20,
//                       ),
//                       decoration: BoxDecoration(
//                         color: whitecolor.withValues(alpha: 0.1),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: StreamBuilder(
//                         stream: BubbleGemFirestoreService.highScoreStream(),
//                         builder: (context, snapshot) {
//                           final highScore = snapshot.data ?? 0;
//                           return Column(
//                             children: [
//                               Icon(
//                                 Icons.emoji_events_outlined,
//                                 color: Colors.amberAccent,
//                                 size: w * 0.08,
//                               ),

//                               Text(
//                                 "$highScore",
//                                 style: TextStyle(
//                                   color: whitecolor,
//                                   fontSize: w * 0.08,
//                                   fontWeight: FontWeight.bold,
//                                   fontFamily: 'Baloo2',
//                                 ),
//                               ),
//                               Text(
//                                 "High Score",
//                                 style: TextStyle(
//                                   color: Colors.white60,
//                                   fontSize: w * 0.04,
//                                   fontFamily: 'Baloo2',
//                                 ),
//                               ),
//                             ],
//                           );
//                         },
//                       ),
//                     ),
//                     SizedBox(height: h * 0.030),
//                     InkWell(
//                       onTap: () => context.push('/bubble-gem-challenge'),
//                       child: Container(
//                         padding: EdgeInsets.symmetric(
//                           vertical: 10,
//                           horizontal: 20,
//                         ),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(15),
//                           gradient: const LinearGradient(
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                             colors: [Color(0xFFFF4FD8), Color(0xFFD000B8)],
//                           ),
//                         ),
//                         child: Text(
//                           'Daily Challenges',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 20,
//                             fontFamily: 'Baloo2',
//                           ),
//                         ),
//                       ),
//                     ),

//                     SizedBox(height: h * 0.03),
//                     Container(
//                       key: startGameKey,
//                       child: StreamBuilder(
//                         stream: BubbleGemFirestoreService.unlockedLevelStream(),
//                         builder: (context, snapshot) {
//                           final unlocked = snapshot.data ?? 1;
//                           return PlayButton(
//                             onPressed: () {
//                               SoundManager.instance.stopTheme();
//                               context.go('/bubble-game?level=$unlocked');
//                               // context.go('/bubble-gem-game?level=$unlocked');
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                     SizedBox(height: h * 0.020),

//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         OutlinedButton(
//                           onPressed: () async {
//                             await BubbleGemFirestoreService.resetProgress();
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                 content: Text("Progress has been reset!"),
//                               ),
//                             );
//                           },
//                           child: Text(
//                             ' LEVEL RESET',
//                             style: TextStyle(color: whitecolor),
//                           ),
//                         ),
//                         // Inside your Home Screen build method
//                         // StreamBuilder(
//                         //   stream:
//                         //       BubbleGemFirestoreService.unlockedLevelStream(),
//                         //   builder: (context, snapshot) {
//                         //     final unlockedLevel = snapshot.data ?? 1;
//                         InkWell(
//                           onTap: () => context.push('/bubble-gem-zone'),
//                           child: Container(
//                             padding: EdgeInsets.symmetric(
//                               vertical: 10,
//                               horizontal: 20,
//                             ),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(15),
//                               gradient: const LinearGradient(
//                                 begin: Alignment.topCenter,
//                                 end: Alignment.bottomCenter,
//                                 colors: [Color(0xFFFF4FD8), Color(0xFFD000B8)],
//                               ),
//                             ),
//                             child: Text(
//                               'Map',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 20,
//                                 fontFamily: 'Baloo2',
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     // Spacer(),
//                     // _bannerAd(),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           if (showTutorial)
//             AdvancedTutorialOverlay(
//               steps: _tutorialSteps(),
//               currentStep: currentTutorialStep,
//               onNext: () {
//                 if (currentTutorialStep < _tutorialSteps().length - 1) {
//                   setState(() => currentTutorialStep++);
//                 } else {
//                   _completeTutorial();
//                 }
//               },
//               onBack: () {
//                 if (currentTutorialStep > 0) {
//                   setState(() => currentTutorialStep--);
//                 }
//               },
//               onSkip: _completeTutorial,
//               // scrollController: tutorialScrollController,
//             ),
//           if (showStreakReward)
//             StreakRewardOverlay(
//               streak: rewardStreakCount,
//               reward: (rewardStreakCount % 3 == 0) ? 50 : 0,
//               freeBooster: _dailyFreeBooster,
//               onClaim: _claimStreakReward,
//             ),
//         ],
//       ),
//     );
//   }

//   // Widget _bannerAd() {
//   //   return SizedBox(
//   //     height: 50,
//   //     child: AdWidget(ad: AdService.instance.createBannerAd()),
//   //   );
//   // }
// }

// class PlayButton extends StatelessWidget {
//   final VoidCallback onPressed;

//   const PlayButton({super.key, required this.onPressed});

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final w = size.width;
//     final h = size.height;
//     return GestureDetector(
//       onTap: onPressed,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // Bottom white 3D shadow layer
//           Transform.translate(
//             offset: const Offset(0, 6),
//             child: Container(
//               width: w * 0.53, //250,
//               height: h * 0.090, //90,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.9),
//                 borderRadius: BorderRadius.circular(25),
//               ),
//             ),
//           ),

//           // Main button
//           Container(
//             width: w * 0.5,
//             height: h * 0.090,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(25),
//               gradient: const LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Color(0xFFFF4FD8), Color(0xFFD000B8)],
//               ),
//             ),
//             child: Stack(
//               children: [
//                 // Gloss highlight
//                 Positioned(
//                   top: 7,
//                   left: 5,
//                   child: Transform.rotate(
//                     angle: -0.6,
//                     child: Container(
//                       width: w * 0.06,
//                       height: h * 0.011,
//                       decoration: BoxDecoration(
//                         color: whitecolor,
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                     ),
//                   ),
//                 ),

//                 // Small right gloss
//                 Positioned(
//                   bottom: 7,
//                   right: 5,
//                   child: Transform.rotate(
//                     angle: -0.6,
//                     child: Container(
//                       width: w * 0.06,
//                       height: h * 0.011,
//                       decoration: BoxDecoration(
//                         color: whitecolor,
//                         borderRadius: BorderRadius.circular(5),
//                       ),
//                     ),
//                   ),
//                 ),

//                 // Text
//                 const Center(
//                   child: Text(
//                     "PLAY",
//                     style: TextStyle(
//                       fontFamily: 'Baloo2',
//                       fontSize: 40,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                       letterSpacing: 1.5,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class StreakRewardOverlay extends StatelessWidget {
//   final int streak;
//   final int reward;
//   final String? freeBooster;
//   final VoidCallback onClaim;

//   const StreakRewardOverlay({
//     super.key,
//     required this.streak,
//     required this.reward,
//     required this.freeBooster,
//     required this.onClaim,
//   });
//   Map<String, dynamic> _getBoosterDetails(String key) {
//     switch (key) {
//       case 'shield':
//         return {
//           'name': 'SHIELD',
//           'icon': Icons.shield,
//           'color': Colors.greenAccent,
//         };
//       case 'slowmo':
//         return {
//           'name': 'SLOW-MO',
//           'icon': Icons.speed,
//           'color': Colors.cyanAccent,
//         };
//       case 'magnet':
//         return {
//           'name': 'MAGNET',
//           'icon': Icons.auto_fix_high,
//           'color': Colors.purpleAccent,
//         };
//       case 'time':
//         return {
//           'name': '+15s TIME',
//           'icon': Icons.timer,
//           'color': Colors.orangeAccent,
//         };
//       default:
//         return {'name': 'BOOSTER', 'icon': Icons.bolt, 'color': Colors.white};
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final booster = _getBoosterDetails(freeBooster ?? "");
//     return Material(
//       color: Colors.black54,
//       child: Center(
//         child: Container(
//           width: MediaQuery.of(context).size.width * 0.8,
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: bg, // Match your theme
//             borderRadius: BorderRadius.circular(30),
//             border: Border.all(color: title1, width: 1),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(
//                 Icons.local_fire_department,
//                 color: Colors.orange,
//                 size: 80,
//               ),
//               Text(
//                 "$streak DAY STREAK!",
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   fontFamily: 'Baloo2',
//                 ),
//               ),
//               const Text(
//                 "Daily Advantage",
//                 style: TextStyle(
//                   color: Colors.white70,
//                   fontSize: 14,
//                   letterSpacing: 1.2,
//                 ),
//               ),
//               const SizedBox(height: 25),
//               Container(
//                 padding: const EdgeInsets.all(15),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.05),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: booster['color'].withOpacity(0.5)),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(booster['icon'], color: booster['color'], size: 40),
//                     const SizedBox(width: 15),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             "FREE ${booster['name']}",
//                             style: TextStyle(
//                               color: booster['color'],
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               fontFamily: 'Baloo2',
//                             ),
//                           ),
//                           const Text(
//                             "One-time free use in your next game!",
//                             style: TextStyle(
//                               color: Colors.white60,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (reward > 0) ...[
//                 const SizedBox(height: 10),
//                 Text(
//                   "You've played for $streak days straight! Here is a special reward:",
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(color: Colors.white70, fontSize: 16),
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Image.asset(
//                       'assets/minigame3/bubble_gem_storm/icons/coin.png',
//                       width: 30,
//                     ),
//                     const SizedBox(width: 10),
//                     Text(
//                       "+$reward",
//                       style: const TextStyle(
//                         color: Colors.amber,
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//               const SizedBox(height: 30),
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: title2,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 40,
//                     vertical: 10,
//                   ),
//                 ),
//                 onPressed: onClaim,
//                 child: const Text(
//                   "CLAIM REWARD",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'Baloo2',
//                     fontSize: 18,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


class BubbleGemHomeScreen extends StatefulWidget {
  const BubbleGemHomeScreen({super.key});

  @override
  State<BubbleGemHomeScreen> createState() => _BubbleGemHomeScreenState();
}

class _BubbleGemHomeScreenState extends State<BubbleGemHomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool showFeatureOnboarding = false;
  bool _pendingGameTutorial = false;

  bool sound = true;
  bool vibration = true;
  String? _dailyFreeBooster;
  GameTier _currentTier = GameTier.tier1;

  bool showStreakReward = false;
  int rewardStreakCount = 0;
  bool showStreakProgress = false;

  final GlobalKey levelKey = GlobalKey();
  final GlobalKey highscoreKey = GlobalKey();
  final GlobalKey startGameKey = GlobalKey();
  int highScore = 0;
  bool showTutorial = false;
  int currentTutorialStep = 0;
  List<TutorialStep> _tutorialSteps() {
    return [
      TutorialStep(
        key: levelKey,
        title: 'Levels',
        description:
            'Level will complete after completing the different objective of different level.You will be rewarded with a LIFE❤️ ',
      ),
      // TutorialStep(
      //   key: infoKey,
      //   title: 'TUTORIAL BUTTON',
      //   description: 'Click the button to Rewatch the Game Tutorial ',
      // ),
      TutorialStep(
        key: highscoreKey,
        title: 'HIGH SCORE DISPLAY',
        description:
            'Your best score is displayed here. Challenge yourself to beat it!',
      ),
      TutorialStep(
        key: startGameKey,
        title: 'PLAY BUTTON',
        description:
            'Begin your Bubble gems adventure! Burst bubble gems to acheive the objectives .',
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AdService.instance.loadRewarded();
    AudioPlayer.global.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory
              .playback, // "Ambient" allows mixing with other sounds
          options: {
            AVAudioSessionOptions.mixWithOthers,
            // AVAudioSessionOptions.defaultToSpeaker,
          },
        ),
        android: AudioContextAndroid(
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.none, // Don't take focus away from BGM
        ),
      ),
    );
    SoundManager.instance.playHomeTheme();
    // loadSoundSettings();
    _checkTutorial();

    _handleStreak();
  }

  @override
  void dispose() {
    // 2. Unregister the observer to prevent memory leaks
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // App is in background or being closed
      SoundManager.instance
          .stopTheme(); // Or SoundManager.instance.pauseHomeTheme();
    } else if (state == AppLifecycleState.resumed) {
      // App is back in the foreground
      SoundManager.instance.playHomeTheme();
    }
  }

  // Future<void> _handleStreak() async {
  //   await Future.delayed(const Duration(seconds: 2));
  //
  //   // --- CHANGE THIS NUMBER TO TEST DIFFERENT DAYS ---
  //   int mockStreak = 2; // Test 1,2, 3, 6, etc.
  //   // -------------------------------------------------
  //
  //   // Mocking the logic that usually comes from Firestore
  //   String? mockBooster = (mockStreak == 1) ? null : 'shield';
  //   if (mockStreak % 3 == 0)
  //     mockBooster = 'magnet'; // Special booster for milestones
  //
  //   setState(() {
  //     _currentTier = GameTier.tier1; // Mock tier
  //     rewardStreakCount = mockStreak;
  //     _dailyFreeBooster = mockBooster;
  //
  //     // This triggers the first overlay (The Animation)
  //     showStreakProgress = true;
  //     showStreakReward = false;
  //   });
  // }

  Future<void> _handleStreak() async {
    // Wait a bit for the UI to settle
    // await Future.delayed(const Duration(seconds: 2));

    final streakData = await BubbleGemFirestoreService.checkAndUpdateStreak();

    if (streakData != null) {
      int currentUnlockedLevel =
          await BubbleGemFirestoreService.unlockedLevelStream().first;

      // Find the tier of the current level
      final currentLevelConfig = myCustomLevels.firstWhere(
        (l) => l.id == currentUnlockedLevel,
        orElse: () => myCustomLevels.first,
      );
      int streak = streakData['streak'] ?? 1;
      bool isNewCheckIn = streakData['isNewCheckIn'] ?? false;
      String? booster = streakData['freeBooster'] ?? 'shield';
      if (streak == 1) {
        booster = null;
      }
      // LOGIC: If inTier 1 and the booster is 'time', swap it
      // because Tier 1 (Score Rush) usually doesn't use the time booster.
      else if (currentLevelConfig.tier == GameTier.tier1 && booster == 'time') {
        // Swap to a booster useful in Tier 1, e.g., 'shield' or 'magnet'
        booster = 'shield';
      }

      // if (streakData != null) {
      setState(() {
        _currentTier = currentLevelConfig.tier;
        rewardStreakCount = streak;
        _dailyFreeBooster = booster;
        if (isNewCheckIn) {
          showStreakProgress = true;
        } else {
          showStreakProgress = false;
        }

        showStreakReward = false;
        showStreakReward = false;
      });
      // }
    }
  }

  void _claimStreakReward() async {
    // Give 100 coins forevery 3-day milestone

    if (rewardStreakCount % 3 == 0) {
      await BubbleGemFirestoreService.addCoins(50);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("50 Coins added to your treasure!")),
      );
    }
    setState(() {
      showStreakReward = false;
    });
  }

  // // -------------to show tutorial only once per user--------------
  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('home_tutorial_seen') ?? false;
    // final force = prefs.getBool('circle_rush_force_tutorial') ?? false;

    if (!seen) {
      await Future.delayed(Duration(milliseconds: 400));

      setState(() {
        showTutorial = true;
      });
      // await prefs.setBool('circle_rush_force_tutorial', false);
    }
  }

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('home_tutorial_seen', true);

    setState(() {
      showTutorial = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = tierThemeManager.current;
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    return Scaffold(
      backgroundColor: theme.gradient[0],
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: w * 0.04),
              child: Center(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            key: levelKey,
                            child: StreamBuilder<int>(
                              stream:
                                  BubbleGemFirestoreService.unlockedLevelStream(),
                              builder: (context, snapshot) {
                                final unlocked = snapshot.data ?? 1;
                                // const maxLevels = 25;
                                //
                                // final progress = unlocked / maxLevels;
                                // Find the current level config based on global unlocked ID
                                final currentLevelConfig = myCustomLevels
                                    .firstWhere(
                                      (l) => l.id == unlocked,
                                      orElse: () => myCustomLevels.last,
                                    );

                                String tierName = "";
                                int totalInTier = 0;
                                switch (currentLevelConfig.tier) {
                                  case GameTier.tier1:
                                    tierName = "Tier 1: Score Rush";
                                    totalInTier = 20;
                                    break;
                                  case GameTier.tier2:
                                    tierName = "Tier 2: Survivor";
                                    totalInTier = 30;
                                    break;
                                  case GameTier.tier3:
                                    tierName = "Tier 3:Master";
                                    totalInTier = 50;
                                    break;
                                }

                                final progress =
                                    currentLevelConfig.localLevel / totalInTier;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: h * 0.01),
                                    Text(
                                      tierName,
                                      style: TextStyle(
                                        color: title1,
                                        fontSize: w * 0.055,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Baloo2',
                                      ),
                                    ),
                                    Text(
                                      "Level  ${currentLevelConfig.localLevel} / $totalInTier",
                                      style: TextStyle(
                                        color: title1,
                                        fontSize: w * 0.043,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Baloo2',
                                        letterSpacing: -1,
                                      ),
                                    ),

                                    SizedBox(height: h * 0.01),
                                    Container(
                                      decoration: BoxDecoration(
                                        // border: Border.all(color: title2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: LinearProgressIndicator(
                                          value: progress.clamp(0.0, 1.0),
                                          minHeight: 8,
                                          backgroundColor: whitecolor,
                                          // .withValues(alpha: 0.2),
                                          valueColor: AlwaysStoppedAnimation(
                                            title2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: h * 0.02),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: w * 0.06,
                        ), // Space between progress and coins
                        // --- NEW COIN DISPLAY ---
                        StreamBuilder<int>(
                          stream: BubbleGemFirestoreService.coinsStream(),
                          builder: (context, snapshot) {
                            final coins = snapshot.data ?? 0;
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                // color: whitecolor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: purplecolor.withValues(alpha: 0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/minigame3/bubble_gem_storm/icons/coin.png',
                                    width: 18,
                                  ),
                                  // const Icon(
                                  //   Icons.monetization_on,
                                  //   color: Colors.amber,
                                  //   size: 18,
                                  // ),
                                  SizedBox(width: w * 0.015),
                                  Text(
                                    "$coins",
                                    style: TextStyle(
                                      color: purplecolor,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Baloo2',
                                      fontSize: w * 0.04,
                                    ),
                                  ),
                                  SizedBox(width: w * 0.015),
                                  InkWell(
                                    onTap: () => _showWatchAdDialog(context),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: purplecolor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        color: purplecolor,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(width: w * 0.02),

                        InkWell(
                          onTap: () => context.push('/bubble-gem-profile'),
                          child: Container(
                            height: w * 0.11,
                            width: w * 0.11,
                            decoration: BoxDecoration(
                              // boxShadow: [
                              //   BoxShadow(
                              //     color: whitecolor.withValues(alpha: 0.1),
                              //     blurRadius: 20,
                              //     spreadRadius: 2,
                              //   ),
                              // ],
                              borderRadius: BorderRadius.circular(13),
                              // gradient: LinearGradient(
                              //   colors: [
                              //     whiteColor.withOpacity(0.1),
                              //     whiteColor.withOpacity(0.1),
                              //   ],
                              // ),
                              border: Border.all(
                                color: purplecolor.withValues(alpha: 0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.local_parking_rounded,
                                color: purplecolor,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showOnboarding(context),
                          icon: Icon(Icons.info_outline, color: purplecolor),
                        ),
                      ],
                    ),
                    Spacer(),
                    // SizedBox(height: h * 0.095),
                    Text(
                      'Bub',
                      style: TextStyle(
                        fontFamily: 'Baloo2',
                        fontSize: w * 0.18,
                        height: 0.5,
                        color: bubcolor,
                        shadows: [
                          Shadow(
                            offset: Offset(2.0, 5.0),
                            blurRadius: 10.0,
                            color: title1.withOpacity(0.8),
                            // Shadow color
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'PoP',
                      style: TextStyle(
                        fontFamily: 'Baloo2',
                        fontSize: w * 0.18,
                        height: 1,
                        color: popcolor,
                        shadows: [
                          Shadow(
                            offset: Offset(2.0, 5.0),
                            blurRadius: 10.0,
                            color: title1.withOpacity(0.8),
                          ),
                        ],
                      ),
                    ),
                    // gradientText(
                    //   [bubcolor, bubcolor],
                    //   "Bub ",
                    //   fontsize: w * 0.17,
                    //   height: 0.8,
                    //   fontweight: FontWeight.bold,
                    // ),
                    // gradientText(
                    //   [popcolor, popcolor],
                    //   "PoP ",
                    //   fontsize: w * 0.17,
                    //   height: 1,
                    //   fontweight: FontWeight.bold,
                    // ),
                    // SizedBox(height: h * 0.01),
                    Text(
                      "Tap fast,Survive,Dominate!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: w * 0.05,
                        fontWeight: FontWeight.bold,
                        color: whitecolor.withValues(alpha: 0.7),
                        fontFamily: 'Baloo2',
                      ),
                    ),
                    SizedBox(height: h * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          key: highscoreKey,
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: whitecolor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: StreamBuilder(
                            stream: BubbleGemFirestoreService.highScoreStream(),
                            builder: (context, snapshot) {
                              final highScore = snapshot.data ?? 0;
                              return Column(
                                children: [
                                  Icon(
                                    Icons.emoji_events_outlined,
                                    color: Colors.amberAccent,
                                    size: w * 0.08,
                                  ),

                                  Text(
                                    "$highScore",
                                    style: TextStyle(
                                      color: whitecolor,
                                      fontSize: w * 0.09,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Baloo2',
                                    ),
                                  ),
                                  Text(
                                    "High Score",
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: w * 0.04,
                                      fontFamily: 'Baloo2',
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        SizedBox(width: w * 0.05),
                        InkWell(
                          onTap: () async {
                            if (rewardStreakCount == 0) {
                              // Optional: Re-fetch data if it's 0
                              final data =
                                  await BubbleGemFirestoreService.checkAndUpdateStreak();
                              if (data != null) {
                                setState(() {
                                  rewardStreakCount = data['streak'];
                                  _dailyFreeBooster = data['freeBooster'];
                                });
                              }
                            }
                            showDialog(
                              context: context,
                              builder: (context) => StreakStatusDialog(
                                currentStreak: rewardStreakCount == 0
                                    ? 1
                                    : rewardStreakCount,
                                nextReward:
                                    _dailyFreeBooster ?? "Shield Booster",
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: whitecolor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                // Icon(
                                //   Icons.emoji_events_outlined,
                                //   color: Colors.amberAccent,
                                //   size: w * 0.08,
                                // ),
                                Lottie.asset(
                                  'assets/minigame3/bubble_gem_storm/animations/Fire animation.json',
                                  height:
                                      w *
                                      0.08, // Increased size for "Wow" factor
                                  repeat: true,
                                ),

                                Text(
                                  "${rewardStreakCount == 0 ? 1 : rewardStreakCount}",
                                  style: TextStyle(
                                    color: whitecolor,
                                    fontSize: w * 0.09,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Baloo2',
                                  ),
                                ),
                                Text(
                                  "Day Streak",
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: w * 0.04,
                                    fontFamily: 'Baloo2',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: h * 0.030),
                    InkWell(
                      onTap: () => context.push('/bubble-gem-challenge'),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFF4FD8), Color(0xFFD000B8)],
                          ),
                        ),
                        child: Text(
                          'Daily Challenges',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Baloo2',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: h * 0.03),
                    Container(
                      key: startGameKey,
                      child: StreamBuilder(
                        stream: BubbleGemFirestoreService.unlockedLevelStream(),
                        builder: (context, snapshot) {
                          final unlocked = snapshot.data ?? 1;
                          return PlayButton(
                            onPressed: () {
                              SoundManager.instance.stopTheme();
                              context.go(
                                '/bubble-game?level=$unlocked&showTutorial=$_pendingGameTutorial',
                              );
                              // context.go('/bubble-gem-game?level=$unlocked');
                              if (_pendingGameTutorial) {
                                setState(() {
                                  _pendingGameTutorial = false;
                                });
                              }
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: h * 0.03),

                    InkWell(
                      onTap: () => context.push('/bubble-gem-zone'),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFF4FD8), Color(0xFFD000B8)],
                          ),
                        ),
                        child: Text(
                          'Map',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Baloo2',
                          ),
                        ),
                      ),
                    ),

                    //   ],
                    // ),
                    Spacer(),
                    // _bannerAd(),
                  ],
                ),
              ),
            ),
          ),
          if (showTutorial)
            AdvancedTutorialOverlay(
              steps: _tutorialSteps(),
              currentStep: currentTutorialStep,
              onNext: () {
                if (currentTutorialStep < _tutorialSteps().length - 1) {
                  setState(() => currentTutorialStep++);
                } else {
                  _completeTutorial();
                }
              },
              onBack: () {
                if (currentTutorialStep > 0) {
                  setState(() => currentTutorialStep--);
                }
              },
              onSkip: _completeTutorial,
              // scrollController: tutorialScrollController,
            ),
          if (showStreakProgress)
            StreakProgressOverlay(
              currentStreak: rewardStreakCount,
              onContinue: () {
                setState(() {
                  showStreakProgress = false;
                  // Only show reward overlay if it's NOT day 1 (since day1 has no booster/coins)
                  if (rewardStreakCount > 1 || rewardStreakCount % 3 == 0) {
                    showStreakReward = true;
                    ConfettiManager.play();
                    SoundManager.instance.playWinSound();
                  }
                });
              },
            ),
          if (showStreakReward)
            StreakRewardOverlay(
              streak: rewardStreakCount,
              reward: (rewardStreakCount % 3 == 0) ? 50 : 0,
              freeBooster: _dailyFreeBooster,
              onClaim: _claimStreakReward,
              currentTier: _currentTier,
            ),
          ConfettiOverlay(),
          if (showFeatureOnboarding)
            FeatureOnboardingOverlay(
              onComplete: () {
                setState(() {
                  showFeatureOnboarding = false;
                });
              },
            ),
        ],
      ),
    );
  }

  void _showWatchAdDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.amber),
        ),
        title: Column(
          children: [
            Image.asset(
              'assets/minigame3/bubble_gem_storm/icons/coin.png',
              width: 50,
            ),
            const SizedBox(height: 15),
            const Text(
              "EARN COINS",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Baloo2',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image.asset(
            //   'assets/minigame3/bubble_gem_storm/icons/coin.png',
            //   width: 50,
            // ),
            // const SizedBox(height: 15),
            const Text(
              "Watch a short video to earn 50 extra coins?",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontFamily: 'Baloo2'),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 38),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("LATER", style: TextStyle(color: Colors.white)),
          ),
          SizedBox(width: 5),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _handleRewardedAd();
            },
            child: const Text(
              "WATCH AD",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRewardedAd() {
    // Show a loading snackbar or overlay if the ad is still loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Loading Ad..."),
        duration: Duration(seconds: 1),
      ),
    );

    AdService.instance.showRewarded(
      onAdClosedAfterReward: () async {
        // 1. Add coins to Firestore
        await BubbleGemFirestoreService.addCoins(50);

        // 2. Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Success! 50 Coins added!"),
            ),
          );
          // Optional: Play a coin sound here
          // SoundManager.instance.playCoinSound();
        }
      },
    );
  }

  void _showOnboarding(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: const BorderSide(color: title2, width: 2),
        ),
        title: const Text(
          "HELP CENTER",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Baloo2',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHelpOption(
              context,
              title: "APP GUIDE",
              subtitle: "Learn about Gems, Tiers & Rewards",
              icon: Icons.auto_stories,
              color: Colors.cyanAccent,
              onTap: () {
                Navigator.pop(context); // Close choice dialog
                _openFeatureOnboarding();
              },
            ),
            const SizedBox(height: 15),
            _buildHelpOption(
              context,
              title: "SCREEN TUTORIAL",
              subtitle: "How to navigate this screen",
              icon: Icons.ads_click,
              color: Colors.orangeAccent,
              onTap: () {
                Navigator.pop(context); // Close choice dialog

                setState(() {
                  currentTutorialStep = 0;
                  showTutorial = true;
                  _pendingGameTutorial = true;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for the dialog buttons
  Widget _buildHelpOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Baloo2',
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  // Separate method to trigger the Feature Onboarding Overlay
  void _openFeatureOnboarding() {
    setState(() {
      showFeatureOnboarding = true;
    });
  }

  // Widget _bannerAd() {
  //   return SizedBox(
  //     height: 50,
  //     child: AdWidget(ad: AdService.instance.createBannerAd()),
  //   );
  // }
}

class PlayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const PlayButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Bottom white 3D shadow layer
          Transform.translate(
            offset: const Offset(0, 6),
            child: Container(
              width: w * 0.53, //250,
              height: h * 0.090, //90,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),

          // Main button
          Container(
            width: w * 0.5,
            height: h * 0.090,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFF4FD8), Color(0xFFD000B8)],
              ),
            ),
            child: Stack(
              children: [
                // Gloss highlight
                Positioned(
                  top: 7,
                  left: 5,
                  child: Transform.rotate(
                    angle: -0.6,
                    child: Container(
                      width: w * 0.06,
                      height: h * 0.011,
                      decoration: BoxDecoration(
                        color: whitecolor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),

                // Small right gloss
                Positioned(
                  bottom: 7,
                  right: 5,
                  child: Transform.rotate(
                    angle: -0.6,
                    child: Container(
                      width: w * 0.06,
                      height: h * 0.011,
                      decoration: BoxDecoration(
                        color: whitecolor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),

                // Text
                const Center(
                  child: Text(
                    "PLAY",
                    style: TextStyle(
                      fontFamily: 'Baloo2',
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StreakRewardOverlay extends StatelessWidget {
  final int streak;
  final int reward;
  final String? freeBooster;
  final VoidCallback onClaim;
  final GameTier currentTier;

  const StreakRewardOverlay({
    super.key,
    required this.streak,
    required this.reward,
    required this.freeBooster,
    required this.onClaim,
    required this.currentTier,
  });
  Map<String, dynamic> _getBoosterDetails(String key) {
    switch (key) {
      case 'shield':
        return {
          'name': 'SHIELD',
          'icon': Icons.shield,
          'color': Colors.greenAccent,
        };
      case 'slowmo':
        return {
          'name': 'SLOW-MO',
          'icon': Icons.speed,
          'color': Colors.cyanAccent,
        };
      case 'magnet':
        return {
          'name': 'MAGNET',
          'icon': Icons.auto_fix_high,
          'color': Colors.purpleAccent,
        };
      case 'time':
        // 3. Dynamic Name Logic based on Tier
        String timeName = "+15s TIME"; // Default for Tier 3
        if (currentTier == GameTier.tier2) {
          timeName = "-15s SURVIVAL"; // For Tier 2
        }

        return {
          'name': timeName,
          'icon': Icons.timer,
          'color': Colors.orangeAccent,
        };
      default:
        return {'name': 'BOOSTER', 'icon': Icons.bolt, 'color': Colors.white};
    }
  }

  @override
  Widget build(BuildContext context) {
    final booster = _getBoosterDetails(freeBooster ?? "");
    final bool isMilestone = streak % 3 == 0;
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.amber, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // const Icon(
              //   Icons.local_fire_department,
              //   color: Colors.orange,
              //   size: 80,
              // ),
              Lottie.asset(
                'assets/minigame3/bubble_gem_storm/animations/Fire animation.json',
                height: 100, // Increased size for "Wow" factor
                repeat: true,
              ),
              Text(
                "$streak DAY STREAK!",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Baloo2',
                ),
              ),
              // --- CONDITIONAL CONTENT ---
              if (isMilestone) ...[
                // Milestone Day (3, 6, 9...)
                const SizedBox(height: 10),
                Text(
                  "You've played for $streak days straight! Here is a special reward:",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/minigame3/bubble_gem_storm/icons/coin.png',
                      width: 40,
                    ),
                    const SizedBox(width: 15),
                    Text(
                      "+$reward",
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Baloo2',
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Regular Day (1, 2, 4, 5...)
                const Text(
                  "Daily Advantage",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: booster['color'].withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(booster['icon'], color: booster['color'], size: 40),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "FREE ${booster['name']}",
                              style: TextStyle(
                                color: booster['color'],
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Baloo2',
                              ),
                            ),
                            const Text(
                              "One-time free use in your next game!",
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 10,
                  ),
                ),
                onPressed: onClaim,
                child: const Text(
                  "CLAIM REWARD",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Baloo2',
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StreakProgressOverlay extends StatefulWidget {
  final int currentStreak;
  final VoidCallback onContinue;

  const StreakProgressOverlay({
    super.key,
    required this.currentStreak,
    required this.onContinue,
  });

  @override
  State<StreakProgressOverlay> createState() => _StreakProgressOverlayState();
}

class _StreakProgressOverlayState extends State<StreakProgressOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  bool _showButton = false;
  final int maxDays = 7;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Logic: Animate from previous day to current day
    // We normalize the value to a 0.0 - 1.0 range for the progress bar
    double startValue = (widget.currentStreak - 1) / maxDays;
    double endValue = widget.currentStreak / maxDays;

    _progressAnimation =
        Tween<double>(
          begin: widget.currentStreak <= 1 ? endValue : startValue,
          end: endValue,
        ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
        );

    _controller.forward().then((_) {
      if (widget.currentStreak > 1) {
        // AUTOMATIC: If it's not Day 1, proceed to rewards immediately
        widget.onContinue();
      } else {
        // MANUAL: If Day 1, show the continue button
        setState(() {
          _showButton = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: Center(
        child: AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.amber),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "STREAK PROGRESS",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontSize: 22,
                      fontFamily: 'Baloo2',
                    ),
                  ),
                  const SizedBox(height: 40),

                  //--- LINEAR PROGRESS SECTION ---
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          // 1. Background Track
                          Container(
                            height: 12,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          // 2. Animated Progress Fill
                          FractionallySizedBox(
                            widthFactor: _progressAnimation.value.clamp(
                              0.0,
                              1.0,
                            ),
                            child: Container(
                              height: 12,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.orangeAccent,
                                    Colors.greenAccent,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.greenAccent.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //3. Day Markers (Dots/Icons)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(maxDays, (index) {
                              int day = index + 1;
                              bool isReached = widget.currentStreak >= day;
                              bool isSpecial = day % 3 == 0;

                              return Column(
                                children: [
                                  // The "Tick" or "Gift" on the bar
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: isReached
                                          ? Colors.white
                                          : const Color(0xFF1A1A2E),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isReached
                                            ? Colors.greenAccent
                                            : Colors.white24,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      isSpecial
                                          ? Icons.card_giftcard
                                          : Icons.check,
                                      size: 12,
                                      color: isReached
                                          ? Colors.black
                                          : Colors.white24,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Day Labels below the bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(maxDays, (index) {
                          int day = index + 1;
                          bool isReached = widget.currentStreak >= day;
                          return SizedBox(
                            width: 20,
                            child: Text(
                              "D$day",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isReached
                                    ? Colors.white
                                    : Colors.white38,
                                fontSize: 11,
                                fontWeight: isReached
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontFamily: 'Baloo2',
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),

                  // --- END PROGRESS SECTION ---
                  const SizedBox(height: 40),
                  if (widget.currentStreak == 1)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: _showButton ? 1.0 : 0.0,
                      child: Column(
                        children: [
                          Text(
                            widget.currentStreak == 1
                                ? "Welcome! Come back tomorrow for your first booster!"
                                : "Streak updated! Day ${widget.currentStreak} reached!",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Baloo2',
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: title2,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 12,
                              ),
                            ),
                            onPressed: _showButton ? widget.onContinue : null,
                            child: const Text(
                              "CONTINUE",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Baloo2',
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const Text(
                      "Claiming Reward...",
                      style: TextStyle(
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Baloo2',
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class StreakStatusDialog extends StatefulWidget {
  final int currentStreak;
  final String? nextReward;

  const StreakStatusDialog({
    super.key,
    required this.currentStreak,
    this.nextReward = "Shield Booster",
  });

  @override
  State<StreakStatusDialog> createState() => _StreakStatusDialogState();
}

class _StreakStatusDialogState extends State<StreakStatusDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  final int maxDays = 7;

  @override
  void initState() {
    super.initState();

    int displayStreak = widget.currentStreak <= 0 ? 1 : widget.currentStreak;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // Smooth fill duration
    );
    double endValue = (displayStreak / maxDays).clamp(0.0, 1.0);

    _progressAnimation = Tween<double>(begin: 0.0, end: endValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    // Startanimation after a tiny delay so the user sees it start
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
        side: BorderSide(color: Colors.amber),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "STREAK STATUS",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Baloo2',
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white54),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- ANIMATED LINEAR PROGRESS BAR ---
                Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Background Track
                    Container(
                      height: 10,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    // Animated Fill
                    FractionallySizedBox(
                      widthFactor: _progressAnimation.value,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.orangeAccent, Colors.greenAccent],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.greenAccent.withOpacity(0.2),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Day Markers (Dots)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(maxDays, (index) {
                        int day = index + 1;
                        // Marker lights up when the animated bar reaches it
                        bool isReached =
                            (_progressAnimation.value * maxDays) >= (day - 0.5);
                        bool isSpecial = day % 3 == 0;

                        return Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: isReached
                                ? Colors.white
                                : const Color(0xFF1A1A2E),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isReached
                                  ? Colors.greenAccent
                                  : Colors.white24,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            isSpecial ? Icons.card_giftcard : Icons.check,
                            size: 10,
                            color: isReached ? Colors.black : Colors.white24,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Day Labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(maxDays, (index) {
                    bool isReached =
                        (_progressAnimation.value * maxDays) >= (index + 0.9);
                    return Text(
                      "D${index + 1}",
                      style: TextStyle(
                        color: isReached ? Colors.white : Colors.white38,
                        fontSize: 10,
                        fontWeight: isReached
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    );
                  }),
                ),

                const Divider(color: Colors.white10, height: 40),

                // Professional Info Section
                _buildInfoRow(
                  Icons.bolt,
                  "Current Streak",
                  "${widget.currentStreak} Days",
                ),
                _buildInfoRow(
                  Icons.redeem,
                  "Next Reward",
                  widget.currentStreak >= 7 ? "Maxed!" : widget.nextReward!,
                ),
                _buildInfoRow(
                  Icons.verified_user,
                  "Status",
                  "Active Today",
                  color: Colors.greenAccent,
                ),

                const SizedBox(height: 20),
                Text(
                  "Don't miss a day or your streak will reset!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Baloo2',
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color color = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color.withOpacity(0.7), size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontFamily: 'Baloo2'),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontFamily: 'Baloo2',
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureOnboardingOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  FeatureOnboardingOverlay({super.key, required this.onComplete});

  @override
  State<FeatureOnboardingOverlay> createState() =>
      _FeatureOnboardingOverlayState();
}

class _FeatureOnboardingOverlayState extends State<FeatureOnboardingOverlay> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // --- PROFESSIONAL ONBOARDING STEPS ---
  late final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: "WELCOME TO THE BUBBLE GEM STORM",
      description:
          "The Gem Storm has arrived! Tap floating gems to collect points and clear objectives. Don't let them reach the top danger zone!",
      assetPath: 'assets/minigame3/bubble_gem_storm/icons/game.jpg',
      accentColor: Colors.purpleAccent,
    ),
    OnboardingStep(
      title: "MASTER THE HUD",
      description:
          "Watch your LIVES ❤️ at the top right. Track your TARGET 🎯 at the top left. Keep an eye on your COINS 🪙 to buy powerful boosters!",
      assetPath: 'assets/minigame3/bubble_gem_storm/icons/game.jpg',
      accentColor: Colors.blueAccent,
    ),
    OnboardingStep(
      title: "THREE EPIC TIERS",
      description:
          "Master 'Score Rush' (Tier 1), survive 'Neon Heights' (Tier2), and conquer 'Galaxy Depths' (Tier 3) across 100 unique levels.",
      assetPath: 'assets/minigame3/bubble_gem_storm/icons/rewardBg.png',
      accentColor: Colors.teal,
    ),
    OnboardingStep(
      title: "KNOW YOUR GEMS",
      description:
          "Normal gems give points. GOLDEN gems are ultra-fast and worth 20x! FROZEN gems require two taps to shatter.",
      assetPath: 'assets/minigame3/bubble_gem_storm/icons/coin.png',
      accentColor: Colors.cyanAccent,
    ),
    OnboardingStep(
      title: "BEWARE OF TRAPS",
      description:
          "Avoid BOMBS (point loss), POISON (life loss), and DIZZY gems. They shake your screen and resetyour combo multiplier!",
      assetPath: 'assets/minigame3/bubble_gem_storm/icons/gameover.png',
      accentColor: Colors.redAccent,
    ),
    OnboardingStep(
      title: "PRE-GAME BOOSTERS",
      description:
          "Equip SHIELDS for protection, SLOW-MO for control, or MAGNETS for auto-collection. Use them to beat tough objectives!",
      assetPath: 'assets/minigame3/bubble_gem_storm/icons/booster.jpg',
      accentColor: Colors.greenAccent,
    ),
    OnboardingStep(
      title: "MAP & PROGRESSION",
      description:
          "Climb the zig-zag path! Earn up to 3 stars per level based on your attempts. Unlock new zones as you grow stronger.",
      assetPath: 'assets/minigame3/bubble_gem_storm/animations/maps.json',
      accentColor: Colors.pinkAccent,
      isLottie: true,
    ),
    OnboardingStep(
      title: "DAILY REWARDS",
      description:
          "Check the Challenge Board daily! Complete specific tasks like 'Pop 50 Golden Gems' to earn massive coin rewards.",
      assetPath:
          'assets/minigame3/bubble_gem_storm/animations/Gift Rewards.json',
      accentColor: Colors.lightGreen,
      isLottie: true,
    ),
    OnboardingStep(
      title: "STREAK BONUSES",
      description:
          "Don't break the chain! Play every day to increase your streak and unlock FREE pre-game boosters and coin milestones.",
      assetPath: 'assets/minigame3/bubble_gem_storm/animations/streak.json',
      accentColor: Colors.amberAccent,
      isLottie: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final step = _steps[_currentPage];

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Background Blur
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: size.width * 0.88,
                height: size.height * 0.88,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: step.accentColor.withOpacity(0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: step.accentColor.withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildProgressBar(),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) =>
                            setState(() => _currentPage = index),
                        itemCount: _steps.length,
                        itemBuilder: (context, index) =>
                            _buildPageContent(index, size),
                      ),
                    ),
                    _buildNavigationButtons(),
                  ],
                ),
              ),
            ),
          ),
          // Skip Button
          Positioned(
            top: size.height * 0.07,
            right: 25,
            child: TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: widget.onComplete,
              child: Icon(Icons.close, color: whitecolor, size: 20),
              // const Text(
              //   "SKIP",
              //   style: TextStyle(
              //     color: Colors.white38,
              //     fontWeight: FontWeight.bold,
              //     letterSpacing: 1.2,
              //   ),
              // ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(int index, Size size) {
    final step = _steps[index];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //DYNAMIC VISUAL AREA
          SizedBox(height: 200, child: _getVisualForStep(index)),
          const SizedBox(height: 30),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: step.accentColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Baloo2',
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            step.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontFamily: 'Baloo2',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // --- DYNAMIC VISUAL LOGIC ---
  Widget _getVisualForStep(int index) {
    switch (index) {
      case 2: // Gems
        return _buildItemGrid([
          {
            'icon': Icons.auto_awesome,
            'label': 'Normal',
            'color': Colors.blueAccent,
          },
          {'icon': Icons.star, 'label': 'Golden', 'color': Colors.amber},
          {
            'icon': Icons.ac_unit,
            'label': 'Frozen',
            'color': Colors.cyanAccent,
          },
        ]);
      case 3: // Traps
        return _buildItemGrid([
          {'icon': Icons.bolt, 'label': 'Bomb', 'color': Colors.orangeAccent},
          {
            'icon': Icons.heart_broken,
            'label': 'Poison',
            'color': Colors.greenAccent,
          },
          {
            'icon': Icons.cyclone,
            'label': 'Dizzy',
            'color': Colors.purpleAccent,
          },
        ]);
      case 4: // Boosters
        return _buildItemGrid([
          {
            'icon': Icons.shield,
            'label': 'Shield',
            'color': Colors.greenAccent,
          },
          {'icon': Icons.speed, 'label': 'Slow-Mo', 'color': Colors.cyanAccent},
          {
            'icon': Icons.auto_fix_high,
            'label': 'Magnet',
            'color': Colors.purpleAccent,
          },
        ]);
      default:
        return TweenAnimationBuilder<double>(
          key: ValueKey(index),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (context, value, child) => Transform.scale(
            scale: value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  // BoxShadow(
                  //   color: _steps[index].accentColor.withOpacity(0.2),
                  //   blurRadius: 20,
                  //   spreadRadius: 5,
                  // ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _steps[index].isLottie
                    ? Lottie.asset(
                        _steps[index].assetPath,
                        height: 180,
                        fit: BoxFit.contain,
                        repeat: true, // Keep the streak/map moving
                      )
                    : Image.asset(
                        _steps[index].assetPath,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
        );
    }
  }

  Widget _buildItemGrid(List<Map<String, dynamic>> items) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (item['color'] as Color).withOpacity(0.1),
                      border: Border.all(color: item['color'], width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: (item['color'] as Color).withOpacity(0.2),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(item['icon'], color: item['color'], size: 30),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item['label'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_steps.length, (index) {
          bool isActive = _currentPage == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 6,
            width: isActive ? 24 : 8,
            decoration: BoxDecoration(
              color: isActive
                  ? _steps[_currentPage].accentColor
                  : Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton(
              onPressed: () => _pageController.previousPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              ),
              child: const Text(
                "BACK",
                style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            const SizedBox(width: 60),
          GestureDetector(
            onTap: () {
              if (_currentPage < _steps.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              } else {
                widget.onComplete();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _steps[_currentPage].accentColor,
                    _steps[_currentPage].accentColor.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: _steps[_currentPage].accentColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                _currentPage == _steps.length - 1 ? "START PLAYING" : "NEXT",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingStep {
  final String title;
  final String description;
  final String assetPath;
  final Color accentColor;
  final bool isLottie;

  OnboardingStep({
    required this.title,
    required this.description,
    required this.assetPath,
    required this.accentColor,
    this.isLottie = false,
  });
}
