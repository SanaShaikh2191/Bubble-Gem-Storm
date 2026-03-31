import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/bubble_gem_firestore_service.dart';
import '../utils/constants.dart';
import '../utils/game_tutorial.dart';
import '../utils/level_config.dart';
import '../utils/sound_manager.dart';
import '../widgets/text_gradient.dart';
import '../utils/ad_service.dart';

class BubbleGemHomeScreen extends StatefulWidget {
  const BubbleGemHomeScreen({super.key});

  @override
  State<BubbleGemHomeScreen> createState() => _BubbleGemHomeScreenState();
}

class _BubbleGemHomeScreenState extends State<BubbleGemHomeScreen>
    with SingleTickerProviderStateMixin {
  bool sound = true;
  bool vibration = true;
  String? _dailyFreeBooster;

  bool showStreakReward = false;
  int rewardStreakCount = 0;

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
    SoundManager.instance.playHomeTheme();
    // loadSoundSettings();
    _checkTutorial();

    _handleStreak();
  }

  Future<void> _handleStreak() async {
    // Wait a bit for the UI to settle
    await Future.delayed(const Duration(seconds: 3));

    // // TEMPORARY FOR TESTING:
    // setState(() {
    //   rewardStreakCount = 3; // Pretend they hit day 3
    //   showStreakReward = true; // Force the overlay to show
    // });

    final streakData = await BubbleGemFirestoreService.checkAndUpdateStreak();

    if (streakData != null) {
      int currentUnlockedLevel =
          await BubbleGemFirestoreService.unlockedLevelStream().first;

      // Find the tier of the current level
      final currentLevelConfig = myCustomLevels.firstWhere(
        (l) => l.id == currentUnlockedLevel,
        orElse: () => myCustomLevels.first,
      );

      String booster = streakData['freeBooster'] ?? 'shield';

      // LOGIC: If inTier 1 and the booster is 'time', swap it
      // because Tier 1 (Score Rush) usually doesn't use the time booster.
      if (currentLevelConfig.tier == GameTier.tier1 && booster == 'time') {
        // Swap to a booster useful in Tier 1, e.g., 'shield' or 'magnet'
        booster = 'shield';
      }

      // if (streakData != null) {
      setState(() {
        rewardStreakCount = streakData['streak'];
        _dailyFreeBooster = streakData['freeBooster'];
        showStreakReward = true;
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
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    return Scaffold(
      backgroundColor: bg,
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
                                ],
                              ),
                            );
                          },
                        ),
                        SizedBox(width: w * 0.02),
                        // InkWell(
                        //   onTap: () {
                        //     SoundManager.instance.stopTheme();
                        //     context.go('/circle-rush-home');
                        //   },
                        //   child: Container(
                        //     padding: EdgeInsets.symmetric(horizontal: w * 0.03),
                        //     // width: 47,
                        //     height: h * 0.05,
                        //     decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(12),
                        //       // shape: BoxShape.circle,
                        //       border: Border.all(color: title1),
                        //     ),
                        //     child: Row(
                        //       children: [
                        //         Icon(Icons.home, color: title2, size: 20),
                        //         SizedBox(width: 5),
                        //         Text(
                        //           'EXIT',
                        //           style: TextStyle(
                        //             fontSize: w * 0.035,
                        //             fontWeight: FontWeight.w700,
                        //             fontFamily: 'Baloo2',
                        //             color: title1,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        InkWell(
                          onTap: () => context.push('/bubble-gem-profile'),
                          child: Container(
                            height: w * 0.11,
                            width: w * 0.11,
                            decoration: BoxDecoration(
                              color: bg,
                              boxShadow: [
                                BoxShadow(
                                  color: whitecolor.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
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
                      ],
                    ),
                    Spacer(),
                    // SizedBox(height: h * 0.095),
                    gradientText(
                      [title1, title2],
                      "Bubble  Gem ",
                      fontsize: w * 0.17,
                      height: 0.8,
                      fontweight: FontWeight.bold,
                    ),
                    gradientText(
                      [title1, title2],
                      "Storm ",
                      fontsize: w * 0.17,
                      height: 1,
                      fontweight: FontWeight.bold,
                    ),
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
                                  fontSize: w * 0.08,
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
                              context.go('/bubble-game?level=$unlocked');
                              // context.go('/bubble-gem-game?level=$unlocked');
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(height: h * 0.020),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton(
                          onPressed: () async {
                            await BubbleGemFirestoreService.resetProgress();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Progress has been reset!"),
                              ),
                            );
                          },
                          child: Text(
                            ' LEVEL RESET',
                            style: TextStyle(color: whitecolor),
                          ),
                        ),
                        // Inside your Home Screen build method
                        // StreamBuilder(
                        //   stream:
                        //       BubbleGemFirestoreService.unlockedLevelStream(),
                        //   builder: (context, snapshot) {
                        //     final unlockedLevel = snapshot.data ?? 1;
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
                      ],
                    ),

                    Spacer(),
                    _bannerAd(),
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
          if (showStreakReward)
            StreakRewardOverlay(
              streak: rewardStreakCount,
              reward: (rewardStreakCount % 3 == 0) ? 50 : 0,
              freeBooster: _dailyFreeBooster,
              onClaim: _claimStreakReward,
            ),
        ],
      ),
    );
  }

  Widget _bannerAd() {
    return SizedBox(
      height: 50,
      child: AdWidget(ad: AdService.instance.createBannerAd()),
    );
  }
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

  const StreakRewardOverlay({
    super.key,
    required this.streak,
    required this.reward,
    required this.freeBooster,
    required this.onClaim,
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
        return {
          'name': '+15s TIME',
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
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bg, // Match your theme
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: title1, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Colors.orange,
                size: 80,
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
                  border: Border.all(color: booster['color'].withOpacity(0.5)),
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
              if (reward > 0) ...[
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
                      width: 30,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "+$reward",
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: title2,
                  foregroundColor: Colors.white,
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
