import 'dart:async';
import 'dart:math';
import 'dart:math' as math;

import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../analytics.dart';
import '../utils/bubble_gem_firestore_service.dart';
import '../utils/constants.dart';
import '../utils/game_challenge.dart';
import '../utils/game_tutorial.dart';
import '../utils/haptic_manager.dart';
import '../utils/level_config.dart';
import '../utils/sound_manager.dart';
import '../utils/sounds_settings.dart';
import '../utils/ad_service.dart';

// class GemGameScreen extends StatefulWidget {
//   final int level;
//   const GemGameScreen({super.key, required this.level});

//   @override
//   State<GemGameScreen> createState() => _GemGameScreenState();
// }

// class _GemGameScreenState extends State<GemGameScreen>
//     with TickerProviderStateMixin {
//   String? _completedChallengeTitle;
//   String? _completedChallengeId; // Stores the title of the finished challenge
//   bool _showChallengeReward = false;
//   int _localCoins = 0;
//   // String? _challengeNotifyText;
//   // bool _showChallengePop = false;
//   int _gemsPoppedThisSession = 0;
//   int _maxComboThisSession = 0;
//   int _secondsSurvivedThisSession = 0;

//   final Set<GemType> _warnedGemTypes = {};
//   String? _activeWarning;
//   GemType? _warningType;
//   Timer? _warningTimer;

//   bool _showCaricature = false;

//   bool _showRewardOverlay = false;
//   bool _showGameOverTransition = false;
//   // String _caricatureType = "WIN";
//   bool _shieldActive = false;
//   bool _slowMoActive = false;
//   bool _magnetActive = false;
//   bool _extraTimeActive = false; // For the +15s Time Booster

  
//   bool _showRetryOverlay = false;

//   bool _isVibrationEnabled = true;
//   bool _showTierOverlay = false;

//   final GlobalKey _scoreKey = GlobalKey();
//   final GlobalKey _livesKey = GlobalKey();
//   final GlobalKey _gameAreaKey = GlobalKey();

//   double _shakeOffset = 0.0;

//   late AnimationController _bgAnimationController;

//   bool _showTutorial = false;
//   bool _showGemGuide = false;
//   int _currentTutorialStep = 0;
//   bool isPausedByOverlay = false;
//   bool _showLevelIntro = false;

//   final List<Gem> gems = [];
//   final List<PopEffect> activeEffects = [];
//   List<FloatingText> floatingTexts = [];
//   final Random random = Random();
//   late AnimationController _comboPopController;
//   late LevelConfig currentLevel;
//   int gemsCleared = 0;
//   int secondsRemaining = 0;
//   Timer? countdownTimer;
//   bool levelCleared = false;

//   int comboCount = 0;
//   int currentMultiplier = 1;
//   Timer? comboTimer;
//   double comboBarValue = 0.0;

//   Timer? gameLoop;
//   Timer? spawnLoop;

//   int score = 0;
//   int combo = 0;
//   int lives = 3;

//   int specificGemsCollected = 0;
//   int maxComboReached = 0;
//   bool lifeLostThisLevel = false;

//   int gemId = 0;
//   double spawnRate = 1.2;
//   double speedMultiplier = 1;

//   bool gameOver = false;
//   bool dangerActive = false;
//   double dangerZoneHeight = 120;

//   bool isSlowed = false;
//   Timer? slowTimer;
//   double slowMultiplier = 0.4;

//   DateTime lastTap = DateTime.now();
//   Color? flashColor;

//   String? activeMotivation;

//   Size screenSize = Size.zero;
//   List<TutorialStep> get _tutorialSteps => [
//     TutorialStep(
//       key: _gameAreaKey,
//       title: "Welcome to Gem Pop!",
//       description:
//           "Gems will float up from the bottom. Tap them before they reach the top!",
//     ),
//     TutorialStep(
//       key: _scoreKey,
//       title: "Track your Progress",
//       description: "Keep an eye on your score and level objectives here.",
//     ),
//     TutorialStep(
//       key: _livesKey,
//       title: "Watch your Lives",
//       description:
//           "If a gem reaches the top, you lose a life. Lose 3 and it's Game Over!",
//     ),
//   ];
//   Future<void> _loadSettings() async {
//     _isVibrationEnabled = await HapticSettings.isEnabled();
//   }

//   Future<void> _startMusic() async {
//     // This will stop the Home Theme and start the Game Theme automatically
//     await SoundManager.instance.playLevelTheme();
//   }

//   Future<void> _refreshLocalCoins() async {
//     int coins = await BubbleGemFirestoreService.getCoins();
//     if (mounted) {
//       setState(() {
//         _localCoins = coins;
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     _refreshLocalCoins();
   
//     AdService.instance.loadRewarded();
//     _loadSettings();
//     _startMusic();

//     //  Configure global audio context to allow mixing
//     AudioPlayer.global.setAudioContext(
//       AudioContext(
//         iOS: AudioContextIOS(
//           category: AVAudioSessionCategory
//               .playback, // "Ambient" allows mixing with other sounds
//           options: {
//             AVAudioSessionOptions.mixWithOthers,
//             // AVAudioSessionOptions.defaultToSpeaker,
//           },
//         ),
//         android: AudioContextAndroid(
//           contentType: AndroidContentType.music,
//           usageType: AndroidUsageType.game,
//           audioFocus: AndroidAudioFocus.none, // Don't take focus away from BGM
//         ),
//       ),
//     );
//     _checkFirstTimeUser();
//     // WidgetsBinding.instance.addPostFrameCallback((_) {
//     //   _showLevelIntroOverlay();
//     // });
//     int index = widget.level - 1;
//     if (index >= myCustomLevels.length) index = myCustomLevels.length - 1;
//     currentLevel = myCustomLevels[index];

//     SoundManager.instance.init();

//     _comboPopController = AnimationController(
//       duration: const Duration(milliseconds: 150),
//       vsync: this,
//       lowerBound: 1.0,
//       upperBound: 1.3,
//     );
//     _bgAnimationController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 10), // Slow, smooth movement
//     )..repeat(); // Loop forever
//   }

//   void _showGemWarning(GemType type) {
//     if (_warnedGemTypes.contains(type)) return; // Only show once per level

//     setState(() {
//       _warnedGemTypes.add(type);
//       _warningType = type;

//       switch (type) {
//         case GemType.bomb:
//           _activeWarning = "DANGER:BOMBS deduct points and reset combos!";
//           break;
//         case GemType.poison:
//           _activeWarning = "CAUTION: POISON steals 1 life instantly!";
//           break;
//         case GemType.dizzy:
//           _activeWarning = "WARNING: DIZZY gemscause massive score loss!";
//           break;
//         case GemType.gravity:
//           _activeWarning = "WATCH OUT: GRAVITY gems double the speed!";
//           break;
//         default:
//           _activeWarning = null;
//       }
//     });

//     _warningTimer?.cancel();
//     _warningTimer = Timer(const Duration(seconds: 4), () {
//       if (mounted) setState(() => _activeWarning = null);
//     });
//   }

//   void _stopAllTimers() {
//     gameLoop?.cancel();
//     spawnLoop?.cancel();
//     countdownTimer?.cancel();
//     comboTimer?.cancel();
//     slowTimer?.cancel(); // Reset timer variables to null to be safe
//     gameLoop = null;
//     spawnLoop = null;
//     countdownTimer = null;
//   }

//   void _showLevelIntroOverlay() {
//     setState(() {
//       _showLevelIntro = true;
//       isPausedByOverlay = true; // This stops gems and timers
//       gems.clear();
//       HapticManager.heavy();
//     });
//     _stopAllTimers();
//   }

//   void _startLevelAfterIntro() {
//     setState(() {
//       _showLevelIntro = false;
//       isPausedByOverlay = false;
//     });
//     startLevel(); // This starts the timers and loops
//   }

//   Future<void> _checkFirstTimeUser() async {
//     final prefs = await SharedPreferences.getInstance();
//     // Check if tutorial was already seen
//     bool seen = prefs.getBool('tutorial_seen') ?? false;

//     if (!seen) {
//       setState(() {
//         isPausedByOverlay = true;
//         _showTutorial = true;
//         // Pausegame logic while tutorial is active
//         gameLoop?.cancel();
//         spawnLoop?.cancel();
//         countdownTimer?.cancel();
//       });
//     } else {
//       _showLevelIntroOverlay();
//     }
//   }

//   void _completeTutorial() async {
//     setState(() {
//       _showTutorial = false;
//       _showGemGuide = true; // Show guide immediately after tutorial
//       isPausedByOverlay = true;
//     });
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('tutorial_seen', true);
//   }

//   void _completeGemGuide() {
//     setState(() {
//       _showGemGuide = false;
//       isPausedByOverlay = false;
//     });
//     // Resume the game
//     _showLevelIntroOverlay();
//   }

//   void startLevel() async {
//     BubbleGemFirestoreService.recordAttempt(
//       currentLevel.id,
//     ); // Track the attempt!
//     String? freeBoosterKey = await BubbleGemFirestoreService.getFreeBooster();
//     bool usedFree = false;
//     if (freeBoosterKey != null) {
//       if (freeBoosterKey == 'shield' && _shieldActive) usedFree = true;
//       if (freeBoosterKey == 'slowmo' && _slowMoActive) usedFree = true;
//       if (freeBoosterKey == 'magnet' && _magnetActive) usedFree = true;
//       if (freeBoosterKey == 'time' && _extraTimeActive) usedFree = true;
//     }
//     if (usedFree) {
//       await BubbleGemFirestoreService.consumeFreeBooster();
//     }
//     // Cancel old timers
//     gameLoop?.cancel();
//     spawnLoop?.cancel();
//     countdownTimer?.cancel();

//     setState(() {
//       score = 0;
//       gemsCleared = 0;
//       gameOver = false;
//       levelCleared = false;
//       lives = _shieldActive ? 4 : 3;
//       speedMultiplier = currentLevel.speed;

//       if (currentLevel.objective == ObjectiveType.survive) {
//         secondsRemaining = currentLevel.targetValue;
//       } else if (currentLevel.timeLimit != null) {
//         secondsRemaining = currentLevel.timeLimit!;
//       } else {
//         secondsRemaining = 999; // Placeholder or ignore
//       }
//       if (_extraTimeActive) {
//         secondsRemaining += 15;
//       }
//       //  Apply Slow-Mo Booster (Temporary)
//       if (_slowMoActive) {
//         speedMultiplier = currentLevel.speed * 0.5;
//         Timer(const Duration(seconds: 15), () {
//           if (mounted) setState(() => speedMultiplier = currentLevel.speed);
//         });
//       }

//       // 4. Apply Magnet Booster (Temporary)
//       if (_magnetActive) {
//         _startMagnetEffect();
//       }
//     });
//     // Reset booster flags for next level attempt
//     _shieldActive = false;
//     _slowMoActive = false;
//     _magnetActive = false;
//     _extraTimeActive = false;
//     // Start Game Loop
//     gameLoop = Timer.periodic(const Duration(milliseconds: 16), updateGame);

//     // Start Spawn Loop using custom spawnRate from config
//     spawnLoop = Timer.periodic(
//       Duration(milliseconds: currentLevel.spawnRate.toInt()),
//       spawnGem,
//     );

//     //Start Countdown

//     if (currentLevel.objective == ObjectiveType.survive ||
//         currentLevel.timeLimit != null) {
//       countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//         if (gameOver || levelCleared) {
//           timer.cancel();
//           return;
//         }

//         setState(() {
//           secondsRemaining--;
//           _secondsSurvivedThisSession++;

//           if (currentLevel.objective == ObjectiveType.survive) {
//             if (secondsRemaining <= 0) winLevel();
//           } else {
//             if (secondsRemaining <= 0) {
//               checkWinCondition();
//               if (!levelCleared) loseLife(); // Custom function to end game
//             }
//           }
//         });
//       });
//     }
//   }

//   void _startMagnetEffect() {
//     // 1. Create the periodic timer
//     final Timer magnetTimer = Timer.periodic(
//       const Duration(milliseconds: 500),
//       (timer) {
//         if (!mounted || gameOver || levelCleared) {
//           timer.cancel();
//           return;
//         }

//         // Automatically pop normal gems
//         // We use a copy of the list to avoid concurrent modification errors
//         final normalGems = gems.where((g) => g.type == GemType.normal).toList();
//         for (var gem in normalGems) {
//           tapGem(gem);
//         }
//       },
//     );

//     // 2. Schedule the cancellation after 10 seconds
//     Timer(const Duration(seconds: 10), () {
//       if (magnetTimer.isActive) {
//         magnetTimer.cancel();
//         debugPrint("Magnet Effect Expired");
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _stopAllTimers();
//     // gameLoop?.cancel();
//     // spawnLoop?.cancel();
//     // comboTimer?.cancel();
//     _comboPopController.dispose();
//     _bgAnimationController.dispose();
//     SoundManager.instance.stopTheme();
//     super.dispose();
//   }

//   void spawnGem(Timer t) {
//     if (gameOver || levelCleared || isPausedByOverlay) return;

//     final typeRoll = random.nextInt(100);

//     GemType type = GemType.normal;
//     double speedBoost = 1.0;

//     if (typeRoll > 97) {
//       type = GemType.golden;
//       speedBoost = 2.5;
//     } else if (typeRoll > 94) {
//       type = GemType.freezePowerUp;
//     } else if (typeRoll > 90)
//       type = GemType.poison; // 4% chance
//     else if (typeRoll > 85)
//       type = GemType.dizzy; // 5% chance
//     else if (typeRoll > 80)
//       type = GemType.gravity;
//     else if (typeRoll > 78) {
//       type = GemType.bomb;
//     } else if (typeRoll > 70) {
//       type = GemType.rainbow;
//     } else if (typeRoll > 60) {
//       type = GemType.frozen;
//     }

//     if (type == GemType.bomb ||
//         type == GemType.poison ||
//         type == GemType.dizzy ||
//         type == GemType.gravity) {
//       _showGemWarning(type);
//     }

//     int taps = 1;

//     if (type == GemType.frozen) taps = 2;
//     double randomScale = 0.7 + (random.nextDouble() * 0.7);
//     if (type == GemType.golden) randomScale = 0.6;

//     Color color = Colors.primaries[random.nextInt(Colors.primaries.length)];
//     double currentGlobalSpeed = isSlowed
//         ? (speedMultiplier * slowMultiplier)
//         : speedMultiplier;
//     double finalSpeed =
//         (0.5 + random.nextDouble()) * currentGlobalSpeed * speedBoost;
//     double amplitude = random.nextDouble() > 0.5
//         ? (10.0 + random.nextDouble() * 20.0)
//         : 0.0;
//     double frequency = 0.02 + (random.nextDouble() * 0.03);
//     double phase = random.nextDouble() * 2 * pi;
//     double startX = random.nextDouble() * (screenSize.width - 100) + 50;

//     // THE SPLASH
//     setState(() {
//       activeSplashes.add(
//         SpawnSplash(
//           position: Offset(startX, screenSize.height - 10),
//           color: type == GemType.golden ? Colors.amber : Colors.cyanAccent,
//         ),
//       );
//     });
//     gems.add(
//       Gem(
//         id: gemId++,
//         position: Offset(
//           random.nextDouble() * (screenSize.width - 50) + 25,
//           screenSize.height + 40,
//         ),
//         speed: finalSpeed,
//         color: color,
//         type: type,
//         tapsRequired: taps,
//         scale: randomScale,
//         waveAmplitude: amplitude,
//         waveFrequency: frequency,
//         phase: phase,
//         initialX: startX,
//       ),
//     );
//   }

//   void updateGame(Timer timer) {
//     if (gameOver || levelCleared || isPausedByOverlay) return;

//     final List<Gem> remove = [];
//     bool isDanger = false;

//     for (var gem in gems) {
//       // 1. Move Upwards (Vertical)
//       double newY = gem.position.dy - gem.speed;

//       // 2. Calculate Wavy Movement (Horizontal)
//       // We use the Y position as the input for the Sine wave
//       double newX = gem.initialX;
//       if (gem.waveAmplitude > 0) {
//         newX =
//             gem.initialX +
//             (sin((newY * gem.waveFrequency) + gem.phase) * gem.waveAmplitude);
//       }

//       gem.position = Offset(newX, newY);

//       if (gem.position.dy < dangerZoneHeight) {
//         isDanger = true;
//       }

//       if (gem.position.dy < 0) {
//         remove.add(gem);
//         bool isSafeToPass =
//             gem.type == GemType.golden ||
//             gem.type == GemType.bomb ||
//             gem.type == GemType.poison ||
//             gem.type == GemType.dizzy ||
//             gem.type == GemType.gravity;

//         if (!isSafeToPass) {
//           loseLife();
//         }
//       }
//       if (gem.type == GemType.golden) {
//         gem.trail.insert(0, gem.position);
//         if (gem.trail.length > 5) gem.trail.removeLast();
//       }
//     }
//     for (var ft in floatingTexts) {
//       ft.position = Offset(ft.position.dx, ft.position.dy - 2); // Float up
//       ft.opacity -= 0.02; // Fade out
//     }
//     floatingTexts.removeWhere((ft) => ft.opacity <= 0);

//     activeEffects.removeWhere(
//       (e) => DateTime.now().difference(e.createdAt).inMilliseconds > 300,
//     );
//     for (var effect in activeEffects) {
//       effect.shockwaveScale += 0.1;
//       effect.shockwaveOpacity -= 0.05;
//       for (var p in effect.particles) {
//         p.update();
//       }
//     }
//     // Remove dead effects
//     activeEffects.removeWhere((e) => e.shockwaveOpacity <= 0);
//     // ANIMATE SPLASHES

//     for (var splash in activeSplashes) {
//       splash.radius += 3.0; //Grow the ripple
//       splash.opacity -= 0.04; // Fade out
//     }
//     // Remove dead splashes
//     activeSplashes.removeWhere((s) => s.opacity <= 0);

//     dangerActive = isDanger;
//     gems.removeWhere((g) => remove.contains(g));

//     if (mounted) {
//       setState(() {});
//     }
//   }

//   void _syncChallenges() {
//     BubbleGemFirestoreService.syncAllChallenges(
//       gemsPopped: _gemsPoppedThisSession,
//       finalScore: score,
//       maxCombo: _maxComboThisSession,
//       secondsSurvived: _secondsSurvivedThisSession,
//       onNotify: _showChallengeNotification, // Your notification function
//     );
//   }

//   void loseLife() {
//     if (gameOver || levelCleared) return;
//     lifeLostThisLevel = true;
//     lives--;

//     if (currentLevel.objective == ObjectiveType.accuracy &&
//         score >= currentLevel.targetValue) {
//       winLevel();
//       return;
//     }
//     if (currentLevel.objective == ObjectiveType.accuracy) {
//       gameOver = true;
//       _stopAllTimers();
//     }

//     if (lives <= 0) {
//       gameLoop?.cancel();
//       spawnLoop?.cancel();
//       countdownTimer?.cancel();
//       HapticManager.heavy();
//       setState(() {
//         _showGameOverTransition = true;
//         gameOver = true;
//         _syncChallenges();
//       });
//       SoundManager.instance.setBgmVolume(0.1);
//       SoundManager.instance.playLoseSound();
//       Timer(const Duration(seconds: 3), () {
//         if (mounted) {
//           SoundManager.instance.setBgmVolume(0.3);
//           setState(() {
//             _showGameOverTransition = false;
//             // The 'gameOver' flag is already true, so the build method
//             // will now show the standard buildGameOver() overlay.
//           });
//         }
//       });
//     }
//   }

//   void _showChallengeNotification(String title, String id) {
//     if (!mounted) return;
//     _stopAllTimers();
//     setState(() {
//       _completedChallengeTitle = title;
//       _completedChallengeId = id;
//       _showChallengeReward = true;
//       isPausedByOverlay = true;
//     });
//     HapticManager.heavy();
//     SoundManager.instance
//         .playTierCompleteSound(); // Or a specific "Quest" sound

//     // Timer(const Duration(seconds: 3), () {
//     //   if (mounted) {
//     //     setState(() => _showChallengePop = false); // Slide back up
//     //   }
//     // });
//   }

//   void tapGem(Gem gem) {
//     if (gameOver || levelCleared || isPausedByOverlay) return;
//     final now = DateTime.now();

//     // --- DANGER GEMS LOGIC ---
//     if (gem.type == GemType.bomb ||
//         gem.type == GemType.poison ||
//         gem.type == GemType.dizzy ||
//         gem.type == GemType.gravity) {
//       _triggerScreenShake(); // All danger gems shake the screen
//       comboCount = 0; // Reset combo for hitting a trap
//       currentMultiplier = 1;
//       comboBarValue = 0;
//       comboTimer?.cancel();
//     }

//     comboCount++;

//     lastTap = now;
//     // 2. Calculate Multiplier (e.g., every 5 gems increases multiplier)
//     //x1 (0-4), x2 (5-9), x3 (10-14), x5 (15+)
//     if (comboCount >= 15) {
//       currentMultiplier = 5;
//     } else if (comboCount >= 10) {
//       currentMultiplier = 3;
//     } else if (comboCount >= 5) {
//       currentMultiplier = 2;
//     } else {
//       currentMultiplier = 1;
//     }

//     // 3. Reset the visual combo timer
//     comboTimer?.cancel();
//     comboBarValue = 1.0;
//     comboTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
//       setState(() {
//         comboBarValue -= 0.05; // Decrease bar over 1 second (approx)
//         if (comboBarValue <= 0) {
//           comboCount = 0;
//           currentMultiplier = 1;
//           timer.cancel();
//         }
//       });
//     });
//     setState(() {
//       comboCount++;
//       _comboPopController
//           .forward(from: 1.0)
//           .then((_) => _comboPopController.reverse());
//     });
//     if (currentMultiplier > maxComboReached) {
//       maxComboReached = currentMultiplier;
//     }

//     //  Trigger the visual "Pop" effect
//     activeEffects.add(PopEffect(position: gem.position, color: gem.color));
//     if (_isVibrationEnabled) {
//       HapticManager.heavy();
//     }

//     SoundManager.instance.playGemTap(gem.type, gem.tapsRequired);
//     gem.tapsRequired--;

//     if (gem.tapsRequired > 0) {
//       setState(() {});
//       return;
//     }

//     // Track Specific Gem Collection
//     // if (currentLevel.objective == ObjectiveType.collection) {
//     //   if (gem.type == currentLevel.targetGemType) {
//     //     specificGemsCollected++;
//     //   }
//     // }

//     // --- SCORINGLOGIC ---
//     int basePoints = 0;
//     String? customPopup;
//     switch (gem.type) {
//       case GemType.golden:
//         basePoints = 20; // Massive boost
//         // SoundManager.instance.playSpecial(); // Play a "ding" sound
//         break;
//       case GemType.freezePowerUp:
//         // basePoints = 5;
//         activateFreezePowerUp();
//         final motivations = [
//           "CHILL OUT!",
//           "FREEZE!",
//           "ICE COLD!",
//           "STAY COOL!",
//           "SLOW MO!",
//         ];
//         activeMotivation = motivations[random.nextInt(motivations.length)];
//         Timer(const Duration(seconds: 2), () {
//           if (mounted) setState(() => activeMotivation = null);
//         });
//         customPopup = activeMotivation;
//         break;
//       case GemType.normal:
//         basePoints = 1;
//         break;
//       case GemType.frozen:
//         basePoints = 2;
//         break;
//       case GemType.bomb:
//         basePoints = 0;
//         score = (score - 5).clamp(0, 999999);
//         customPopup = "-5";
//         explodeBomb(gem);
//         break;
//       case GemType.rainbow:
//         basePoints = 8;
//         rainbowClear();
//         break;
//       // --- DANGERGEMS (0 POINTS) ---
//       case GemType.gravity:
//         basePoints = 0; // No points for gravity
//         // Speed up logic
//         for (var g in gems) {
//           g.speed *= 2.0;
//         }
//         customPopup = "SPEED UP!";
//         Timer(const Duration(seconds: 3), () {
//           if (mounted) {
//             for (var g in gems) {
//               g.speed /= 2.0;
//             }
//           }
//         });
//         break;

//       case GemType.poison:
//         basePoints = 0; // No points for poison
//         loseLife();
//         customPopup = "POISONED!";
//         break;

//       case GemType.dizzy:
//         basePoints = 0; // No points for dizzy
//         // We handle the score penalty (-30) separately or here:
//         score = (score - 10).clamp(0, 999999);
//         customPopup = "DIZZY! -10";
//         break;
//     }
//     String popup = customPopup ?? "+$basePoints";
//     if (currentMultiplier > 1 && customPopup == null)
//       popup = "x$currentMultiplier";
//     if (gem.type == GemType.golden) popup = "AMAZING!";

//     setState(() {
//       floatingTexts.add(
//         FloatingText(
//           text: popup,
//           position: Offset(gem.position.dx, gem.position.dy),
//           color: gem.color,
//         ),
//       );
//     });

//     // Add combo bonus to the base
//     score += (basePoints * currentMultiplier);
//     gemsCleared++;

//     if (gem.position.dy < 150) {
//       score += 10; // Bonus points
//       floatingTexts.add(
//         FloatingText(
//           text: "CLOSE CALL! \n+10",
//           position: Offset(gem.position.dx, gem.position.dy - 20),
//           color: Colors.white,
//         ),
//       );
//       HapticManager.heavy(); // Extra vibration for the save
//     }
//     // Update Challenges
//     _gemsPoppedThisSession++; // Increment local counter
//     if (currentMultiplier > _maxComboThisSession) {
//       _maxComboThisSession = currentMultiplier;
//     }

//     gems.remove(gem);
//     checkWinCondition();

//     setState(() {});
//   }

//   void _triggerScreenShake() {
//     // Shake the screen 6 times quickly
//     int shakes = 0;
//     Timer.periodic(const Duration(milliseconds: 40), (timer) {
//       if (mounted) {
//         setState(() {
//           _shakeOffset = (shakes % 2 == 0) ? 8.0 : -8.0;
//         });
//       }
//       shakes++;
//       if (shakes > 6) {
//         timer.cancel();
//         if (mounted) setState(() => _shakeOffset = 0.0);
//       }
//     });
//   }

//   void activateFreezePowerUp() {
//     slowTimer?.cancel();
//     setState(() => isSlowed = true);

//     // Slow down existing gems immediately
//     for (var g in gems) {
//       g.speed *= slowMultiplier;
//     }

//     slowTimer = Timer(const Duration(seconds: 5), () {
//       if (!mounted) return;
//       setState(() => isSlowed = false);
//       // Restore speed to existing gems
//       for (var g in gems) {
//         g.speed /= slowMultiplier;
//       }
//     });
//   }

//   void checkWinCondition() {
//     if (gameOver || levelCleared) return;

//     bool won = false;
//     switch (currentLevel.objective) {
//       case ObjectiveType.score:
//         if (score >= currentLevel.targetValue) won = true;
//         break;
//       case ObjectiveType.clearGems:
//         if (gemsCleared >= currentLevel.targetValue) won = true;
//         break;
//       case ObjectiveType.collection:
//         if (specificGemsCollected >= currentLevel.targetValue) won = true;
//         break;
//       case ObjectiveType.combo:
//         if (maxComboReached >= currentLevel.targetValue) won = true;
//         break;
//       case ObjectiveType.accuracy:
//         // For accuracy, we win if we reach a certain score/time without losing life
//         // Example: Reach targetValue score with lifeLostThisLevel == false
//         if (score >= currentLevel.targetValue && !lifeLostThisLevel) won = true;
//         break;
//       case ObjectiveType.survive: // Handled by the countdownTimer
//         break;
//     }

//     if (won) {
//       winLevel();
//     } else if (currentLevel.timeLimit != null && secondsRemaining <= 0) {
//       // Time ran out and objective not met
//       gameOver = true;
//     }
//   }

//   void winLevel() async {
//     if (gameOver || levelCleared) return;

//     gameLoop?.cancel();
//     spawnLoop?.cancel();
//     countdownTimer?.cancel();
//     SoundManager.instance.setBgmVolume(0.1);
//     SoundManager.instance.playWinSound();
//     setState(() {
//       _showRewardOverlay = true;
//       // _showCaricature = true; // Trigger the 1-second animation
//       HapticManager.heavy();
//     });
//     await Future.delayed(const Duration(seconds: 3));
//     SoundManager.instance.setBgmVolume(0.3);
//     if (!mounted) return;
//     setState(() {
//       _showRewardOverlay = false;
//       // _showCaricature = false;
//       levelCleared = true;
//       _syncChallenges();
//       gems.clear();
//     });

//     int attempts = await BubbleGemFirestoreService.getLevelAttempts(
//       currentLevel.id,
//     );
//     int starCount = attempts <= 1 ? 3 : (attempts < 5 ? 2 : 1);
//     int coinReward = starCount * 10;

//     // Save to Firestore
//     await BubbleGemFirestoreService.updateHighScore(score);
//     await BubbleGemFirestoreService.unlockNextLevel(currentLevel.id);
//     BubbleGemFirestoreService.addCoins(coinReward);
//     await _refreshLocalCoins();
//   }

//   void explodeBomb(Gem bomb) {
//     const radius = 120;

//     gems.removeWhere((g) {
//       final dist = (g.position - bomb.position).distance;
//       return dist < radius;
//     });
//   }

//   void rainbowClear() {
//     if (gems.isEmpty) return;

//     final randomGem = gems[random.nextInt(gems.length)];
//     final colorToClear = randomGem.color;

//     setState(() {
//       // 2. Set the background flash color (with some transparency)
//       flashColor = colorToClear.withOpacity(0.2);

//       // 3. Loop through and clear gems of that color
//       // We use a copy of the list to avoid concurrent modification errors
//       final gemsToRemove = gems.where((g) => g.color == colorToClear).toList();

//       for (var gem in gemsToRemove) {
//         // Add visual pop effect for every gem destroyed
//         activeEffects.add(PopEffect(position: gem.position, color: gem.color));

//         // Increment score/stats for every gem cleared
//         score += (1 * currentMultiplier);
//         gemsCleared++;
//       }

//       // 4. Remove them from the main list
//       gems.removeWhere((g) => g.color == colorToClear);
//     });

//     // 5. Reset the flash color after 200 milliseconds
//     Timer(const Duration(milliseconds: 200), () {
//       if (mounted) {
//         setState(() {
//           flashColor = null;
//         });
//       }
//     });

//     checkWinCondition();
//   }

//   void handleRestart() {
  
//       restart();
    
//   }

//   void restart() {
//     gameLoop?.cancel();
//     spawnLoop?.cancel();
//     countdownTimer?.cancel();
//     comboTimer?.cancel();
//     setState(() {
//       gems.clear();
//       score = 0;
//       combo = 0;
//       lives = 3;
//       gemsCleared = 0;
//       speedMultiplier = currentLevel.speed;
//       spawnRate = 1.2;
//       gameOver = false;
//       levelCleared = false;
//       if (currentLevel.objective == ObjectiveType.survive) {
//         secondsRemaining = currentLevel.targetValue;
//       } else {
//         secondsRemaining = currentLevel.timeLimit ?? 0;
//       }

//       // gameLoop = Timer.periodic(const Duration(milliseconds: 16), updateGame);
//       // spawnLoop = Timer.periodic(const Duration(milliseconds: 900), spawnGem);
//     });
//     startLevel();
//   }

//   void handleWatchAdRetry() {
//     AdService.instance.showRewarded(
//       onAdClosedAfterReward: () {
//         // The player watched the ad, so we resume the current session
//         resumeGame();
//       },
//     );
//   }

//   void handleCoinRetry() async {
//     const int retryCost = 50; // Set your desired cost
//     bool success = await BubbleGemFirestoreService.spendCoins(retryCost);

//     if (success) {
//       resumeGame(); // Reuses your existing resume logic (3 lives, clears gems)
//     } else {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Not enough coins!")));
//       }
//     }
//   }

//   void resumeGame() {
//     setState(() {
//       gameOver = false;
//       _showRetryOverlay = false;
//       lives = 3;
//       gems.clear();

//       // Reset danger warning if any was active
//       dangerActive = false;
//     });

//     // Restart the Game Loop
//     gameLoop = Timer.periodic(const Duration(milliseconds: 16), updateGame);

//     // Restart the Spawn Loop
//     spawnLoop = Timer.periodic(
//       Duration(milliseconds: currentLevel.spawnRate.toInt()),
//       spawnGem,
//     );

//     // Restart the Countdown Timer (if applicable)
//     if (currentLevel.objective == ObjectiveType.survive ||
//         currentLevel.timeLimit != null) {
//       countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//         if (gameOver || levelCleared) {
//           timer.cancel();
//           return;
//         }
//         setState(() {
//           secondsRemaining--;
//           if (currentLevel.objective == ObjectiveType.survive) {
//             if (secondsRemaining <= 0) winLevel();
//           } else {
//             if (secondsRemaining <= 0) {
//               checkWinCondition();
//               if (!levelCleared) loseLife();
//             }
//           }
//         });
//       });
//     }
//     setState(() {
//       floatingTexts.add(
//         FloatingText(
//           text: "RESUMED! GET READY!",
//           position: Offset(screenSize.width / 2 - 100, screenSize.height / 2),
//           color: Colors.greenAccent,
//         ),
//       );
//     });
//   }

//   String get currentObjectiveText {
//     switch (currentLevel.objective) {
//       case ObjectiveType.score:
//         return "Score: $score / ${currentLevel.targetValue}";
//       case ObjectiveType.clearGems:
//         return "Gems: $gemsCleared / ${currentLevel.targetValue}\nTime Left: $secondsRemaining";
//       case ObjectiveType.survive:
//         return "Survive!\nTime Left: $secondsRemaining";
//       // case ObjectiveType.collection:
//       //   return "Collect ${currentLevel.targetGemType?.name}: $specificGemsCollected / ${currentLevel.targetValue}";
//       case ObjectiveType.accuracy:
//         return "Score: $score / ${currentLevel.targetValue}\nDon't lose a life!";
//       case ObjectiveType.combo:
//         return "Max Multiplier: ${maxComboReached}x / ${currentLevel.targetValue}x";
//       default:
//         return "";
//     }
//   }

//   String get victoryObjectiveText {
//     switch (currentLevel.objective) {
//       case ObjectiveType.score:
//         return "Reach Score ${currentLevel.targetValue}";
//       case ObjectiveType.clearGems:
//         return "Clear ${currentLevel.targetValue} Gems in ${currentLevel.timeLimit} seconds";
//       case ObjectiveType.survive:
//         return "Survive ${currentLevel.targetValue} Seconds!";
//       // return "Collect ${currentLevel.targetGemType?.name}: $specificGemsCollected / ${currentLevel.targetValue}";
//       case ObjectiveType.accuracy:
//         return "Reach Score ${currentLevel.targetValue} Without losing a life!";
//       case ObjectiveType.combo:
//         return "Max Multiplier: ${maxComboReached}x / ${currentLevel.targetValue}x";

//       default:
//         return "Level Complete!";
//     }
//   }

//   void _handleBoosterPurchase(String type, int cost) async {
//     bool currentlyActive = false;
//     if (type == "shield") currentlyActive = _shieldActive;
//     if (type == "slowmo") currentlyActive = _slowMoActive;
//     if (type == "magnet") currentlyActive = _magnetActive;
//     if (type == "time") currentlyActive = _extraTimeActive;

//     if (currentlyActive) {
//       // --- DEACTIVATE & REFUND LOGIC ---

//       // 2. Add the coins back to Firestore
//       await BubbleGemFirestoreService.addCoins(cost);

//       setState(() {
//         if (type == "shield") _shieldActive = false;
//         if (type == "slowmo") _slowMoActive = false;
//         if (type == "magnet") _magnetActive = false;
//         if (type == "time") _extraTimeActive = false;
//       });

//       HapticManager.ligth(); // Light haptic for deactivating
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             "${type.toUpperCase()} deactivated. $cost coins refunded!",
//           ),
//           duration: const Duration(seconds: 1),
//         ),
//       );
//     } else {
//       bool success = await BubbleGemFirestoreService.spendCoins(cost);
//       if (success) {
//         setState(() {
//           if (type == "shield") _shieldActive = true;
//           if (type == "slowmo") _slowMoActive = true;
//           if (type == "magnet") _magnetActive = true;
//           if (type == "time") _extraTimeActive = true;
//         });
//         HapticManager.heavy();
//       } else {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Not enough coins!")));
//       }
//     }
//   }

//   Color _getStageColor() {
//     int stage = ((currentLevel.id - 1) / 5).floor();
//     switch (stage) {
//       case 0:
//         return Colors.blueGrey.shade900; // Levels 1-5
//       case 1:
//         return Colors.red.shade900; // Levels 6-10
//       case 2:
//         return Colors.green.shade900; // Levels 11-15
//       case 3:
//         return Colors.purple.shade900; // Levels 16-20
//       case 4:
//         return Colors.orange.shade900; // Levels 21-25
//       default:
//         return Colors.black;
//     }
//   }

//   void _exitGame() {
//     _stopAllTimers(); // 2. Stop the music
//     SoundManager.instance.stopTheme();

//     // 3. Navigate back to home
//     if (mounted) {
//       context.go('/bubble-gem-home');
//     }
//   }

//   void _moveToNextLevel(int nextGlobalId) {
//     if (nextGlobalId <= myCustomLevels.length) {
//       _stopAllTimers();
//       setState(() {
//         currentLevel = myCustomLevels.firstWhere((l) => l.id == nextGlobalId);
//         gems.clear();
//         score = 0;
//         comboCount = 0;
//         currentMultiplier = 1;
//         gemsCleared = 0;
//         lives = 3;
//         gameOver = false;
//         levelCleared = false;
//         // _showTierOverlay = false; // Ensure this is hidden
//         isSlowed = false;
//         // _showLevelIntroOverlay();
//         _showLevelIntro = true;
//         isPausedByOverlay = true;
//       });
//     } else {
//       context.go('/bubble-gem-home');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     screenSize = MediaQuery.of(context).size;
//     double width = screenSize.width;
//     double height = screenSize.height;
//     final Color currentStageColor = _getStageColor();

//     return PopScope(
//       canPop: false, // Prevent default pop
//       onPopInvokedWithResult: (didPop, result) {
//         if (didPop) return;
//         _exitGame(); // Use our clean exit logic
//       },
//       child: Transform.translate(
//         offset: Offset(_shakeOffset, _shakeOffset),
//         child: Scaffold(
//           body: Stack(
//             key: _gameAreaKey,
//             children: [
//               // // 1. Dynamic Background Color
//               Container(color: bg),
//               Positioned.fill(
//                 child: IgnorePointer(
//                   child: CustomPaint(painter: SpawnPainter(activeSplashes)),
//                 ),
//               ),
//               //THE FLASH OVERLAY
//               if (flashColor != null)
//                 Positioned.fill(
//                   child: IgnorePointer(
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 50),
//                       color: flashColor,
//                     ),
//                   ),
//                 ),
//               buildDangerZone(),
//               RepaintBoundary(
//                 child: Stack(
//                   children: gems.map((gem) => buildGem(gem)).toList(),
//                 ),
//               ),

//               ...activeEffects.map((effect) {
//                 return Stack(
//                   children: [
//                     // 1. THE SHOCKWAVE (Expanding Ring)
//                     Positioned(
//                       left: effect.position.dx - (60 * effect.shockwaveScale),
//                       top: effect.position.dy - (60 * effect.shockwaveScale),
//                       child: IgnorePointer(
//                         child: Opacity(
//                           opacity: effect.shockwaveOpacity.clamp(0, 1),
//                           child: Container(
//                             width: 120 * effect.shockwaveScale,
//                             height: 120 * effect.shockwaveScale,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(color: effect.color, width: 2),
//                               // Add a glow effect
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: effect.color.withOpacity(0.5),
//                                   blurRadius: 10,
//                                   spreadRadius: 2,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),

//                     // 2. THE PARTICLES (Flying Bits)
//                     ...effect.particles.map(
//                       (p) => Positioned(
//                         left: p.position.dx,
//                         top: p.position.dy,
//                         child: Opacity(
//                           opacity: p.opacity.clamp(0, 1),
//                           child: Container(
//                             width: 6,
//                             height: 6,
//                             decoration: BoxDecoration(
//                               color: p.color,
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               }).toList(),

//               buildTopBar(),
//               _buildDangerWarning(),
//               buildComboIndicator(width, height),
//               ...floatingTexts
//                   .map(
//                     (ft) => Positioned(
//                       left: ft.position.dx,
//                       top: ft.position.dy,
//                       child: Opacity(
//                         opacity: ft.opacity.clamp(0, 1),
//                         child: Text(
//                           ft.text,
//                           style: TextStyle(
//                             color: ft.color,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 20,
//                           ),
//                         ),
//                       ),
//                     ),
//                   )
//                   .toList(),

//               // if (_showLevelIntro)
//               //   LevelIntroOverlay(
//               //     level: currentLevel.id,
//               //     objectiveDescription:
//               //         victoryObjectiveText, // Or your custom text
//               //     onGotIt: _startLevelAfterIntro,
//               //   ),
//               // --- TUTORIAL OVERLAY ---
//               if (_showTutorial)
//                 AdvancedTutorialOverlay(
//                   steps: _tutorialSteps,
//                   currentStep: _currentTutorialStep,
//                   onNext: () {
//                     if (_currentTutorialStep < _tutorialSteps.length - 1) {
//                       setState(() => _currentTutorialStep++);
//                     } else {
//                       _completeTutorial();
//                     }
//                   },
//                   onBack: () {
//                     if (_currentTutorialStep > 0) {
//                       setState(() => _currentTutorialStep--);
//                     }
//                   },
//                   onSkip: _completeTutorial,
//                 ),

//               // --- GEM GUIDE OVERLAY ---
//               if (_showGemGuide) GemGuideOverlay(onClose: _completeGemGuide),
//               if (_showLevelIntro) _buildLevelIntro(),
//               // if (_showCaricature)
//               //   Positioned.fill(
//               //     child: Container(
//               //       color: Colors.black45, // Dim the background slightly
//               //       child: _buildCaricatureElement(),
//               //     ),
//               //   ),
//               if (_showRewardOverlay) _buildRewardOverlay(),
//               if (levelCleared) buildLevelClearedOverlay(screenSize),
//               if (_showTierOverlay)
//                 TierCompletionOverlay(
//                   completedTier: currentLevel.tier,
//                   onNextTier: () {
//                     setState(() {
//                       _showTierOverlay = false;
//                     });
//                     _moveToNextLevel(currentLevel.id + 1);
//                   },
//                 ),
//               if (_showGameOverTransition) _buildGameOverTransition(),
//               if (gameOver && !_showGameOverTransition)
//                 buildGameOver(screenSize),
//               if (_showRetryOverlay) buildRetryOverlay(),
//               if (_showChallengeReward && _completedChallengeTitle != null)
//                 ChallengeRewardOverlay(
//                   challengeTitle: _completedChallengeTitle!,
//                   onClaimed: () async {
//                     if (_completedChallengeId != null) {
//                       // We need to find the reward amount.
//                       // You can fetch it from ChallengeDataService based on the ID.
//                       final challengeDef = ChallengeDataService.allChallenges
//                           .firstWhere((c) => c.id == _completedChallengeId);

//                       await BubbleGemFirestoreService.claimChallengeReward(
//                         _completedChallengeId!,
//                         challengeDef.coinReward,
//                       );
//                     }
//                     await Future.delayed(const Duration(seconds: 3));

//                     setState(() {
//                       _showChallengeReward = false;
//                       _completedChallengeTitle = null;
//                       _completedChallengeId = null;
//                       isPausedByOverlay = false;
//                     });

//                     // Resume the game loops if the level isn't over
//                     if (!gameOver && !levelCleared) {
//                       resumeGame(); // Or your resume logic
//                     }
//                   },
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildTopBar() {
//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 15),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 InkWell(
//                   onTap: _exitGame,
//                   child: Container(
//                     padding: EdgeInsets.all(5),
//                     constraints: BoxConstraints(),
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(color: whitecolor),
//                     ),
//                     child: const Icon(
//                       Icons.home_rounded,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                   ),
//                 ),

//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 7,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.black54, // Very subtle
//                     borderRadius: BorderRadius.circular(30),
//                     // border: Border.all(
//                     //   color: purplecolor.withValues(alpha: 0.2),
//                     //   width: 1.5,
//                     // ),
//                   ),
//                   child: Row(
//                     children: [
//                       Image.asset(
//                         'assets/minigame3/bubble_gem_storm/icons/coin.png',
//                         width: 16,
//                         height: 16,
//                       ),
//                       const SizedBox(width: 5),
//                       Text(
//                         "$_localCoins",
//                         style: const TextStyle(
//                           color: Colors.white70,
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           fontFamily: 'Baloo2',
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 10),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Container(
//                   key: _scoreKey,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 18,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.black54,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: BouncingWidget(
//                     value: score + gemsCleared,
//                     child: Text(
//                       currentObjectiveText,
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontFamily: 'Baloo2',
//                       ),
//                     ),
//                   ),
//                 ),
//                 // InkWell(
//                 //   onTap: _exitGame,
//                 //   child: Container(
//                 //     padding: EdgeInsets.all(5),
//                 //     constraints: BoxConstraints(),
//                 //     decoration: BoxDecoration(
//                 //       shape: BoxShape.circle,
//                 //       border: Border.all(color: whitecolor),
//                 //     ),
//                 //     child: const Icon(
//                 //       Icons.home_rounded,
//                 //       color: Colors.white,
//                 //       size: 30,
//                 //     ),
//                 //   ),
//                 // ),
//                 // Container(
//                 //   key: _scoreKey,
//                 //   padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
//                 //   decoration: BoxDecoration(
//                 //     color: Colors.black54,
//                 //     borderRadius: BorderRadius.circular(20),
//                 //   ),
//                 //   child: BouncingWidget(
//                 //     value: score + gemsCleared,
//                 //     child: Text(
//                 //       currentObjectiveText,
//                 //       style: const TextStyle(
//                 //         fontWeight: FontWeight.bold,
//                 //         fontFamily: 'Baloo2',
//                 //       ),
//                 //     ),
//                 //   ),
//                 // ),
//                 Container(
//                   key: _livesKey,
//                   child: Row(
//                     children: List.generate(
//                       3,
//                       (index) => Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 4),
//                         child: BouncingWidget(
//                           value: lives,
//                           child: Container(
//                             padding: EdgeInsets.all(5),
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: index < lives
//                                   ? Colors.red[800]
//                                   : Colors.transparent,
//                               border: index < lives
//                                   ? Border.all()
//                                   : Border.all(color: Colors.white),
//                             ),
//                             child: Icon(
//                               index < lives
//                                   ? Icons.favorite_rounded
//                                   : Icons.favorite_border_rounded,
//                               color: Colors.white,
//                               // size: 25,
//                             ),
//                           ),
//                         ),
//                         //Icon(Icons.favorite, color: Colors.red[800]),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDangerWarning() {
//     if (_activeWarning == null) return const SizedBox.shrink();

//     Color warningColor;
//     IconData warningIcon;

//     switch (_warningType) {
//       case GemType.bomb:
//         warningColor = Colors.orangeAccent;
//         warningIcon = Icons.bolt;
//         break;
//       case GemType.poison:
//         warningColor = Colors.greenAccent;
//         warningIcon = Icons.heart_broken;
//         break;
//       case GemType.dizzy:
//         warningColor = Colors.purpleAccent;
//         warningIcon = Icons.cyclone;
//         break;
//       case GemType.gravity:
//         warningColor = Colors.deepOrange;
//         warningIcon = Icons.south;
//         break;
//       default:
//         warningColor = Colors.redAccent;
//         warningIcon = Icons.warning;
//     }

//     return Positioned(
//       top: 130, // Just below the top bar
//       left: 20,
//       right: 20,
//       child: TweenAnimationBuilder<double>(
//         tween: Tween(begin: 0.0, end: 1.0),
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.elasticOut,
//         builder: (context, value, child) {
//           return Transform.scale(
//             scale: value,
//             child: Opacity(
//               opacity: value.clamp(0, 1),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 10,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.8),
//                   borderRadius: BorderRadius.circular(15),
//                   border: Border.all(color: warningColor, width: 2),
//                   boxShadow: [
//                     BoxShadow(
//                       color: warningColor.withOpacity(0.3),
//                       blurRadius: 10,
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(warningIcon, color: warningColor, size: 28),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         _activeWarning!,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           fontFamily: 'Baloo2',
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildLevelIntro() {
//     String tierName = "";
//     int totalInTier = 0;

//     switch (currentLevel.tier) {
//       case GameTier.tier1:
//         tierName = "Tier 1: Score Rush";
//         totalInTier = 15;
//         break;
//       case GameTier.tier2:
//         tierName = "Tier 2: Survival";
//         totalInTier = 20;
//         break;
//       case GameTier.tier3:
//         tierName = "Tier 3: Gem Master";
//         totalInTier = 30;
//         break;
//     }

//     return LevelIntroOverlay(
//       tierName: tierName,
//       localLevel: currentLevel.localLevel,
//       totalInTier: totalInTier,
//       objectiveDescription: victoryObjectiveText,
//       onGotIt: _startLevelAfterIntro,
//       onBuyBooster: _handleBoosterPurchase,
//       activeBoosters: {
//         if (_shieldActive) "shield",
//         if (_slowMoActive) "slowmo",
//         if (_magnetActive) "magnet",
//         if (_extraTimeActive) "time",
//       },
//       isTimeObjective:
//           currentLevel.objective == ObjectiveType.survive ||
//           currentLevel.objective == ObjectiveType.clearGems,
//     );
//   }

//   Widget buildGem(Gem gem) {
//     // Define fixed gradients for specific types
//     Gradient gemGradient;
//     Color auraColor = Colors.transparent;
//     bool hasAura = false;

//     switch (gem.type) {
//       case GemType.poison:
//         hasAura = true;
//         auraColor = Colors.greenAccent;
//         gemGradient = const RadialGradient(
//           colors: [Colors.green, Colors.black],
//         );
//         break;
//       case GemType.dizzy:
//         hasAura = true;
//         auraColor = Colors.purpleAccent;
//         gemGradient = const RadialGradient(
//           colors: [Colors.purple, Colors.black],
//         );
//         break;
//       case GemType.gravity:
//         hasAura = true;
//         auraColor = Colors.deepOrange;
//         gemGradient = const RadialGradient(
//           colors: [Colors.deepOrange, Colors.black],
//         );
//         break;
//       case GemType.frozen:
//         gemGradient = const RadialGradient(
//           colors: [whitecolor, frozeng],
//           center: Alignment(-0.3, -0.3),
//         );
//         break;
//       case GemType.bomb:
//         gemGradient = const RadialGradient(
//           colors: [Color(0xFF555555), Color(0xFF000000)],
//           center: Alignment(-0.3, -0.3),
//         );
//         break;
//       case GemType.rainbow:
//         // Rainbow remains dynamic/multi-colored
//         gemGradient = const SweepGradient(
//           colors: [
//             Colors.red,
//             Colors.yellow,
//             Colors.green,
//             Colors.blue,
//             Colors.purple,
//             Colors.red,
//           ],
//         );
//         break;

//       case GemType.normal:
//       default:
//         // Normal gems use a fixed gradient based on their assigned base color
//         gemGradient = RadialGradient(
//           colors: [
//             Color.lerp(gem.color, Colors.white, 0.5)!, // Highlight color
//             gem.color, // Main color
//             Color.lerp(gem.color, Colors.black, 0.3)!, // Shadow color
//           ],
//           center: const Alignment(-0.3, -0.3),
//         );
//         break;
//     }
//     double rotationAngle = 0;
//     if (gem.waveAmplitude > 0) {
//       // Calculate tilt based on cosine (the derivative of sine)
//       rotationAngle =
//           cos((gem.position.dy * gem.waveFrequency) + gem.phase) * 0.2;
//     }
//     if (gem.type == GemType.golden) {
//       gemGradient = const RadialGradient(
//         colors: [Colors.white, Colors.orange, Colors.brown],
//         center: Alignment(-0.3, -0.3),
//       );
//     } else if (gem.type == GemType.freezePowerUp) {
//       gemGradient = RadialGradient(
//         colors: [Colors.white, Colors.blue.withOpacity(0.5), Colors.cyan],
//         center: const Alignment(-0.3, -0.3),
//       );
//     }
//     bool isBomb = gem.type == GemType.bomb;
//     double baseDimension = 50.0;
//     double currentSize = baseDimension * gem.scale;
//     return Stack(
//       children: [
//         if (hasAura)
//           Positioned(
//             left: gem.position.dx - 35,
//             top: gem.position.dy - 35,
//             child: BombAura(
//               size: 50,
//               color: auraColor,
//             ), // Modified BombAura below
//           ),
//         if (gem.type == GemType.golden)
//           ...gem.trail.asMap().entries.map((entry) {
//             int idx = entry.key;
//             Offset pos = entry.value;
//             return Positioned(
//               left: pos.dx - 30,
//               top: pos.dy - 20,
//               child: Opacity(
//                 opacity: 0.5 - (idx * 0.1), // Fade out the trail
//                 child: Transform.scale(
//                   scale: 1.0 - (idx * 0.1), // Shrink the trail
//                   child: Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Colors.amber.withOpacity(0.5),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }),
//         if (isBomb)
//           Positioned(
//             left: gem.position.dx - 35, //Slightly larger than the gem
//             top: gem.position.dy - 35,
//             child: TweenAnimationBuilder<double>(
//               tween: Tween(begin: 0.8, end: 1.2),
//               duration: const Duration(milliseconds: 600),
//               curve: Curves.easeInOutSine,
//               builder: (context, value, child) {
//                 return Opacity(
//                   opacity: 0.6 - (value - 0.8), // Fades as it expands
//                   child: Transform.scale(
//                     scale: value * gem.scale,
//                     child: Container(
//                       width: 70,
//                       height: 70,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.redAccent.withOpacity(0.8),
//                             blurRadius: 20,
//                             spreadRadius: 10,
//                           ),
//                         ],
//                         border: Border.all(color: Colors.orange, width: 2),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//               onEnd:
//                   () {}, // TweenAnimationBuilder automatically repeats if you toggle a state,
//               // but for a simple pulse, this works well.
//             ),
//           ),

//         Positioned(
//           left: gem.position.dx - 25, // Assuming 50px width
//           top: gem.position.dy - 25,
//           child: Transform.rotate(
//             angle: rotationAngle,
//             child: TweenAnimationBuilder<double>(
//               duration: const Duration(milliseconds: 300),
//               tween: Tween(begin: 0.0, end: 1.0),
//               curve: Curves.elasticOut, // Gives a nice "bounce" when spawning
//               builder: (context, appearScale, child) {
//                 double jitterX = isBomb ? (Random().nextDouble() * 2 - 1) : 0;
//                 double jitterY = isBomb ? (Random().nextDouble() * 2 - 1) : 0;
//                 return Transform.translate(
//                   offset: Offset(jitterX, jitterY),
//                   child: Transform.scale(
//                     scale: appearScale * gem.scale,
//                     child: child,
//                   ),
//                 );
//               },

//               child: GestureDetector(
//                 onTap: () => tapGem(gem),
//                 child: Container(
//                   width: baseDimension, //gem.type == GemType.golden ? 35 : 50,
//                   height: baseDimension, //gem.type == GemType.golden ? 35 : 50,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: gemGradient,
//                     boxShadow: [
//                       BoxShadow(
//                         color: isBomb
//                             ? Colors.red.withOpacity(0.8)
//                             : gem.type == GemType.golden
//                             ? Colors.yellow
//                             : Colors.white.withOpacity(0.3),
//                         blurRadius: isBomb ? 20 : 15,
//                         spreadRadius: isBomb
//                             ? 8
//                             : (gem.type == GemType.golden ? 5 : 2),

//                         offset: const Offset(0, 0),
//                       ),
//                     ],
//                     border: isBomb
//                         ? Border.all(color: Colors.orangeAccent, width: 2)
//                         : gem.type == GemType.frozen
//                         ? Border.all(color: Colors.white, width: 1)
//                         : null,
//                   ),
//                   child: Center(
//                     child: Transform.scale(
//                       scale: gem.scale < 0.8 ? 0.8 : 1.0,
//                       child: gem.type == GemType.bomb
//                           ? const Icon(Icons.bolt, color: Colors.orange)
//                           : gem.type == GemType.frozen && gem.tapsRequired > 1
//                           ? const Icon(
//                               Icons.ac_unit,
//                               color: Colors.white,
//                               size: 25,
//                             )
//                           : gem.type == GemType.normal
//                           ? Icon(
//                               Icons.auto_awesome,
//                               color: Colors.white,
//                               size: 25,
//                             )
//                           : gem.type == GemType.rainbow
//                           ? Icon(Icons.looks, color: Colors.white, size: 25)
//                           : gem.type == GemType.golden
//                           ? Icon(
//                               Icons.star_border,
//                               color: Colors.white,
//                               size: 20,
//                             )
//                           : gem.type == GemType.freezePowerUp
//                           ? Icon(
//                               Icons.timer_outlined,
//                               color: Colors.white,
//                               size: 25,
//                             )
//                           : gem.type == GemType.poison
//                           ? Icon(
//                               Icons.heart_broken_outlined,
//                               color: Colors.white,
//                             )
//                           : gem.type == GemType.dizzy
//                           ? Icon(Icons.cyclone, color: Colors.white)
//                           : gem.type == GemType.gravity
//                           ? Icon(Icons.south, color: Colors.white)
//                           : null,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildDangerZone() {
//     return AnimatedPositioned(
//       duration: const Duration(milliseconds: 200),
//       top: 0,
//       left: 0,
//       right: 0,
//       height: dangerZoneHeight,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: dangerActive
//                 ? [
//                     Colors.red.withOpacity(.6),
//                     Colors.red.withOpacity(.15),
//                     Colors.transparent,
//                   ]
//                 : [
//                     Colors.blue.withOpacity(.5),
//                     Colors.blue.withOpacity(.15),
//                     Colors.transparent,
//                   ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildComboIndicator(double width, double height) {
//     if (comboCount < 2 && activeMotivation == null)
//       return const SizedBox.shrink();

//     // Determine color based on multiplier
//     Color comboColor = Colors.white;
//     if (currentMultiplier >= 5)
//       comboColor = Colors.redAccent;
//     else if (currentMultiplier >= 3)
//       comboColor = Colors.orangeAccent;
//     else if (currentMultiplier >= 2)
//       comboColor = Colors.yellowAccent;

//     return Positioned(
//       top: height * 0.25,
//       right: width * 0.25,
//       child: ScaleTransition(
//         scale: _comboPopController,

//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Multiplier Badge
//             Row(
//               children: [
//                 // "COMBO" Labelwith spacing
//                 Text(
//                   "COMBO",
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.9),
//                     fontWeight: FontWeight.w900,
//                     fontSize: width * 0.09,
//                     letterSpacing: 4,
//                     fontFamily: 'Baloo2',
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 ShaderMask(
//                   shaderCallback: (bounds) => LinearGradient(
//                     colors: [Colors.white, comboColor, Colors.white],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ).createShader(bounds),
//                   child: Text(
//                     "x$currentMultiplier",
//                     style: TextStyle(
//                       fontSize: width * 0.1,
//                       fontWeight: FontWeight.bold,
//                       fontStyle: FontStyle.italic,
//                       fontFamily: 'Baloo2',
//                       height: 1.0,
//                       shadows: [
//                         Shadow(
//                           color: comboColor.withOpacity(0.8),
//                           blurRadius: 10,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 4),

//             // Small count indicator
//             Text(
//               "$comboCount HITS",
//               style: TextStyle(
//                 color: comboColor,
//                 fontSize: width * 0.035,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             if (activeMotivation != null)
//               ShaderMask(
//                 shaderCallback: (bounds) => const LinearGradient(
//                   colors: [Colors.cyanAccent, Colors.blueAccent],
//                 ).createShader(bounds),
//                 child: Text(
//                   activeMotivation!,
//                   style: TextStyle(
//                     fontSize: width * 0.06, // BIG SIZE
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'Baloo2',
//                     fontStyle: FontStyle.italic,
//                     shadows: [
//                       Shadow(
//                         color: Colors.blue.withOpacity(0.8),
//                         blurRadius: 20,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         // ),
//       ),
//     );
//   }

//   Widget buildLevelClearedOverlay(Size screenSize) {
//     double width = screenSize.width;
//     double height = screenSize.height;
//     return FutureBuilder<int>(
//       future: BubbleGemFirestoreService.getLevelAttempts(currentLevel.id),
//       builder: (context, snapshot) {
//         // Default to 1 star if loading or error
//         int attempts = snapshot.data ?? 1;
//         int starCount = attempts <= 1 ? 3 : (attempts < 5 ? 2 : 1);
//         int coinReward = starCount * 10;
//         return SafeArea(
//           child: Container(
//             margin: EdgeInsets.only(
//               left: width * 0.05,
//               right: width * 0.05,
//               bottom: height * 0.02,
//             ),
//             padding: EdgeInsets.all(width * 0.05),
//             decoration: BoxDecoration(
//               color: bg,
//               border: Border.all(color: Colors.white10),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "LEVEL COMPLETE!",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: width * 0.12,
//                       color: whitecolor,
//                       fontWeight: FontWeight.bold,
//                       fontFamily: 'Baloo2',
//                     ),
//                   ),
//                   // --- STAR SYSTEM UI ---
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: List.generate(3, (index) {
//                       bool isEarned = index < starCount;
//                       double yOffset = (index == 1) ? -10.0 : 10.0;
//                       return TweenAnimationBuilder(
//                         duration: Duration(milliseconds: 600 + (index * 200)),
//                         tween: Tween<double>(begin: 0, end: 1),
//                         curve: Curves.elasticOut,
//                         builder: (context, double value, child) {
//                           return Transform.translate(
//                             offset: Offset(0, yOffset),

//                             child: Icon(
//                               Icons.star_rounded,
//                               size: index == 1
//                                   ? width * 0.2
//                                   : width * 0.15, // Middle star is larger
//                               color: isEarned ? Colors.amber : Colors.white,
//                               shadows: isEarned
//                                   ? [
//                                       Shadow(
//                                         color: Colors.orange.withOpacity(0.5),
//                                         blurRadius: 15,
//                                       ),
//                                     ]
//                                   : [],
//                             ),
//                           );
//                         },
//                       );
//                     }),
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Image.asset(
//                         'assets/minigame3/bubble_gem_storm/icons/coin.png',
//                         width: 18,
//                       ),
//                       // const Icon(
//                       //   Icons.monetization_on,
//                       //   color: Colors.amber,
//                       //   size: 20,
//                       // ),
//                       const SizedBox(width: 5),
//                       Text(
//                         "+$coinReward COINS",
//                         style: const TextStyle(
//                           color: Colors.amber,
//                           fontWeight: FontWeight.bold,
//                           fontFamily: 'Baloo2',
//                           fontSize: 18,
//                         ),
//                       ),
//                     ],
//                   ),

//                   // Text(
//                   //   "$attempts ${attempts == 1 ? 'ATTEMPT' : 'ATTEMPTS'}",
//                   //   style: const TextStyle(
//                   //     color: Colors.white54,
//                   //     fontSize: 14,
//                   //     fontFamily: 'Baloo2',
//                   //     letterSpacing: 1.2,
//                   //   ),
//                   // ),
//                   SizedBox(height: height * 0.02),
//                   Container(
//                     padding: EdgeInsets.all(width * 0.03),
//                     decoration: BoxDecoration(
//                       // color: gameoverCard,
//                       gradient: LinearGradient(
//                         colors: [Colors.white24, Colors.transparent],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       border: Border.all(color: Colors.white10),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Column(
//                       children: [
//                         Text(
//                           "Your Target",
//                           style: TextStyle(
//                             color: title1,
//                             fontSize: width * 0.04,
//                             fontFamily: 'Baloo2',
//                           ),
//                         ),
//                         SizedBox(height: height * 0.001),
//                         Text(
//                           currentObjectiveText,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: whitecolor,
//                             fontSize: width * 0.07,
//                             fontFamily: 'Baloo2',
//                           ),
//                         ),

//                         SizedBox(height: height * 0.01),

//                         Container(
//                           width: double.infinity,
//                           padding: EdgeInsets.symmetric(
//                             vertical: 10,
//                             horizontal: 5,
//                           ),
//                           decoration: BoxDecoration(
//                             color: bg.withValues(alpha: 0.1),
//                             borderRadius: BorderRadius.circular(20),
//                             border: Border.all(color: Colors.white10),
//                           ),
//                           child: Column(
//                             children: [
//                               Icon(
//                                 Icons.track_changes,
//                                 color: Colors.amberAccent,
//                                 size: width * 0.1,
//                               ),
//                               // const SizedBox(height: 10),
//                               Text(
//                                 victoryObjectiveText,
//                                 textAlign: TextAlign.center,
//                                 // "${widget.game.targetScore}",
//                                 style: TextStyle(
//                                   color: whitecolor,
//                                   fontSize: width * 0.07,
//                                   fontFamily: 'Baloo2',
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.001),
//                               Text(
//                                 "Final Target",
//                                 style: TextStyle(
//                                   color: title1,
//                                   fontSize: width * 0.04,
//                                   fontFamily: 'Baloo2',
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: height * 0.02),

//                         InkWell(
//                           onTap: () {
//                             int currentId = currentLevel.id;
//                             int nextId =
//                                 currentId +
//                                 1; // 1. Determine if a tier was just finished
//                             bool isTierFinished =
//                                 (currentLevel.tier == GameTier.tier1 &&
//                                     currentLevel.localLevel == 20) ||
//                                 (currentLevel.tier == GameTier.tier2 &&
//                                     currentLevel.localLevel == 30) ||
//                                 (currentLevel.tier == GameTier.tier3 &&
//                                     currentLevel.localLevel == 50);

//                             if (isTierFinished) {
//                               // Show Tier Completion as before
//                               setState(() {
//                                 levelCleared = false;
//                                 _showTierOverlay = true;
//                               });
//                               context.pushReplacement(
//                                 '/bubble-gem-zone?completedTier=${currentLevel.tier.index}',
//                               );
//                             } else {
//                               // 2. Navigate back to Map with the "justUnlocked" flag
//                               _stopAllTimers();
//                               final tierIndex = currentLevel.tier.index;
//                               final title =
//                                   tierThemes[currentLevel.tier]?.name ??
//                                   "Adventure"; // We pass the nextId as the unlocked level to trigger the animation on the map
//                               context.pushReplacement(
//                                 '/bubble-gem-map?unlockedLevel=$nextId&tier=$tierIndex&title=$title&animateFrom=${currentLevel.id}',
//                               );
//                             }
//                           },
//                           child: Container(
//                             width: double.infinity,
//                             padding: EdgeInsets.symmetric(
//                               vertical: 10,
//                               // horizontal: 70,
//                             ),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(15),
//                               gradient: LinearGradient(
//                                 colors: [title1, title2],
//                                 // begin: Alignment.topCenter,
//                                 // end: Alignment.bottomCenter,
//                                 // stops: [0.3, 0.6],
//                               ),
//                             ),
//                             child: Text(
//                               "NEXT LEVEL",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: width * 0.05,
//                                 color: whitecolor,
//                                 fontFamily: 'Baloo2',
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: height * 0.02),

//                         SizedBox(
//                           width: double.infinity,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               padding: EdgeInsets.symmetric(
//                                 vertical: 10,
//                                 // horizontal: 70,
//                               ),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(15),
//                               ),
//                             ),
//                             onPressed: () {
//                               context.go('/bubble-gem-home');
//                             },
//                             child: Text(
//                               "Home",
//                               style: TextStyle(
//                                 fontSize: width * 0.05,
//                                 color: Colors.black,
//                                 fontFamily: 'Baloo2',
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildRewardOverlay() {
//     return Positioned.fill(
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // 1. THEASSET BACKGROUND
//           Positioned.fill(
//             child: Image.asset(
//               'assets/minigame3/bubble_gem_storm/icons/rewardBg.png',
//               fit: BoxFit.cover,
//             ),
//           ),

//           // 2. DIMMER (Optional:to make the character pop)
//           Positioned.fill(child: Container(color: Colors.black26)),

//           // 3. THE CENTRAL IMAGE & TEXT
//           TweenAnimationBuilder<double>(
//             duration: const Duration(milliseconds: 800),
//             curve: Curves.elasticOut,
//             tween: Tween(begin: 0.0, end: 1.0),
//             builder: (context, value, child) {
//               return Transform.scale(
//                 scale: value,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // YOUR MAIN IMAGE (Character/Chest/Badge)
//                     Image.asset(
//                       'assets/minigame3/bubble_gem_storm/icons/reward.png',
//                       height: 280,
//                     ),
//                     const SizedBox(height: 20),
//                     // VICTORY TEXT
//                     Text(
//                       "FANTASTIC!",
//                       style: TextStyle(
//                         fontSize: 50,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                         fontFamily: 'Baloo2',
//                         fontStyle: FontStyle.italic,
//                         shadows: [
//                           Shadow(
//                             color: Colors.orange,
//                             blurRadius: 15,
//                             offset: Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGameOverTransition() {
//     return Positioned.fill(
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // 1. THE LOSS ASSET BACKGROUND
//           Positioned.fill(
//             child: Image.asset(
//               'assets/minigame3/bubble_gem_storm/icons/rewardBg.png', // REPLACE WITH YOUR LOSS BG
//               fit: BoxFit.cover,
//             ),
//           ),

//           // 2. DARK OVERLAY (Tomake it feel like a defeat)
//           Positioned.fill(child: Container(color: Colors.black45)),

//           // 3. THE CENTRAL IMAGE & TEXT
//           TweenAnimationBuilder<double>(
//             duration: const Duration(milliseconds: 1000),
//             curve: Curves.bounceOut, // A "heavy" bounce for a loss
//             tween: Tween(begin: 0.0, end: 1.0),
//             builder: (context, value, child) {
//               return Transform.scale(
//                 scale: value,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // YOUR LOSS IMAGE (Sad character / Broken Gem)
//                     Image.asset(
//                       'assets/minigame3/bubble_gem_storm/icons/gameover.png',
//                       height: 250,
//                     ),
//                     const SizedBox(height: 20),
//                     // DEFEAT TEXT
//                     const Text(
//                       "OH NO!",
//                       style: TextStyle(
//                         fontSize: 55,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                         fontFamily: 'Baloo2',
//                         shadows: [
//                           Shadow(
//                             color: Colors.red,
//                             blurRadius: 20,
//                             offset: Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildGameOver(Size screenSize) {
//     double width = screenSize.width;
//     double height = screenSize.height;
//     BubbleGemFirestoreService.updateHighScore(score);
//     return SafeArea(
//       child: Center(
//         child: Container(
//           margin: EdgeInsets.only(
//             left: width * 0.05,
//             right: width * 0.05,
//             bottom: height * 0.02,
//           ),
//           padding: EdgeInsets.all(width * 0.05),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             color: bg,
//             // gradient: LinearGradient(colors: [bg, Colors.transparent]),
//             border: Border.all(color: Colors.white24),
//             // border: Border.all(color: Colors.white60),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 "Game Over",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: whitecolor,
//                   fontSize: width * 0.15,
//                   fontFamily: 'Baloo2',
//                 ),
//               ),
//               SizedBox(height: height * 0.01),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(3, (index) {
//                   // bool isEarned = index < starCount;
//                   double yOffset = (index == 1) ? -10.0 : 10.0;
//                   return TweenAnimationBuilder(
//                     duration: Duration(milliseconds: 600 + (index * 200)),
//                     tween: Tween<double>(begin: 0, end: 1),
//                     curve: Curves.elasticOut,
//                     builder: (context, double value, child) {
//                       return Transform.translate(
//                         offset: Offset(0, yOffset),

//                         child: Icon(
//                           Icons.star_rounded,
//                           size: index == 1
//                               ? width * 0.2
//                               : width * 0.15, // Middle star is larger
//                           color: Colors.white,
//                           // shadows: isEarned
//                           //     ? [
//                           //         Shadow(
//                           //           color: Colors.orange.withOpacity(0.5),
//                           //           blurRadius: 15,
//                           //         ),
//                           //       ]
//                           //     : [],
//                         ),
//                       );
//                     },
//                   );
//                 }),
//               ),
//               SizedBox(height: height * 0.02),
//               Container(
//                 padding: EdgeInsets.all(width * 0.03),
//                 decoration: BoxDecoration(
//                   // color: gameoverCard,
//                   gradient: LinearGradient(
//                     colors: [Colors.white24, Colors.transparent],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   border: Border.all(color: Colors.white10),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Column(
//                   children: [
//                     Text(
//                       "Your Target",
//                       style: TextStyle(
//                         color: title1,
//                         fontSize: width * 0.04,
//                         fontFamily: 'Baloo2',
//                       ),
//                     ),
//                     SizedBox(height: height * 0.001),
//                     Text(
//                       currentObjectiveText,
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: width * 0.07,
//                         fontFamily: 'Baloo2',
//                       ),
//                     ),
//                     SizedBox(height: height * 0.01),
//                     Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.symmetric(
//                         vertical: 10,
//                         horizontal: 10,
//                       ),
//                       decoration: BoxDecoration(
//                         color: bg.withValues(alpha: 0.1),
//                         border: Border.all(color: Colors.white10),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: StreamBuilder(
//                         stream: BubbleGemFirestoreService.highScoreStream(),
//                         builder: (context, snapshot) {
//                           final highScore = snapshot.data ?? 0;
//                           return Column(
//                             children: [
//                               Icon(
//                                 Icons.track_changes,
//                                 color: Colors.amberAccent,
//                                 size: width * 0.1,
//                               ),

//                               Text(
//                                 victoryObjectiveText,
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   color: whitecolor,
//                                   fontSize: width * 0.07,
//                                   fontWeight: FontWeight.bold,
//                                   fontFamily: 'Baloo2',
//                                 ),
//                               ),
//                               SizedBox(height: height * 0.001),
//                               Text(
//                                 "Final Target",
//                                 style: TextStyle(
//                                   color: title1,
//                                   fontSize: width * 0.04,
//                                   fontFamily: 'Baloo2',
//                                 ),
//                               ),
//                             ],
//                           );
//                         },
//                       ),
//                     ),
//                     SizedBox(height: height * 0.02),
//                     Column(
//                       children: [
//                         InkWell(
//                           onTap: handleRestart,
//                           child: Container(
//                             width: double.infinity,
//                             padding: EdgeInsets.symmetric(
//                               vertical: 10,
//                               // horizontal: 70,
//                             ),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(15),
//                               gradient: LinearGradient(
//                                 colors: [title1, title2],
//                                 // begin: Alignment.topCenter,
//                                 // end: Alignment.bottomCenter,
//                                 // stops: [0.3, 0.6],
//                               ),
//                             ),
//                             child: Text(
//                               "Play Again",
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: width * 0.05,
//                                 color: whitecolor,
//                                 fontFamily: 'Baloo2',
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: height * 0.01),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   padding: EdgeInsets.symmetric(
//                                     vertical: 10,
//                                     // horizontal: 70,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(15),
//                                   ),
//                                 ),
//                                 onPressed: () {
//                                   context.go('/bubble-gem-home');
//                                 },
//                                 child: Text(
//                                   "Home",
//                                   style: TextStyle(
//                                     fontSize: width * 0.05,
//                                     color: Colors.black,
//                                     fontFamily: 'Baloo2',
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             SizedBox(width: 10),
//                             Expanded(
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   padding: EdgeInsets.symmetric(
//                                     vertical: 10,
//                                     // horizontal: 70,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(15),
//                                   ),
//                                 ),
//                                 onPressed: () {
//                                   setState(() {
//                                     _showRetryOverlay = true;
//                                   });
//                                   ;
//                                 },
//                                 child: Text(
//                                   "Retry",
//                                   style: TextStyle(
//                                     fontSize: width * 0.05,
//                                     color: Colors.black,
//                                     fontFamily: 'Baloo2',
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: height * 0.01),
//                         // Inside buildGameOver() -> Column -> Row(where Home and Retry buttons are)
//                         StreamBuilder<int>(
//                           stream: BubbleGemFirestoreService.coinsStream(),
//                           builder: (context, snapshot) {
//                             final currentCoins = snapshot.data ?? 0;
//                             const int retryCost = 50;

//                             // Onlyshow the button if they have enough coins
//                             if (currentCoins < retryCost)
//                               return const SizedBox.shrink();

//                             return Padding(
//                               padding: const EdgeInsets.only(
//                                 bottom: 15,
//                               ), // Space above the other buttons
//                               child: InkWell(
//                                 onTap: handleCoinRetry,
//                                 child: Container(
//                                   width: double.infinity,
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 12,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(15),
//                                     // color: Colors.amber.withOpacity(0.2),
//                                     gradient: LinearGradient(
//                                       colors: [title1, title2],
//                                     ),
//                                     // border: Border.all(
//                                     //   color: Colors.amber,
//                                     //   width: 2,
//                                     // ),
//                                   ),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Text(
//                                         "RETRY  -$retryCost🪙",
//                                         style: TextStyle(
//                                           fontSize: width * 0.045,
//                                           color: whitecolor,
//                                           fontWeight: FontWeight.bold,
//                                           fontFamily: 'Baloo2',
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildRetryOverlay() {
//     return Material(
//       // Ensure text styles work correctly
//       color: Colors.black87,
//       child: Center(
//         child: Container(
//           margin: const EdgeInsets.symmetric(horizontal: 30),
//           padding: const EdgeInsets.all(25),
//           decoration: BoxDecoration(
//             color: const Color(0xFF1A1A2E), // Use your 'bg' color variable here
//             borderRadius: BorderRadius.circular(25),
//             border: Border.all(color: Colors.white24),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.favorite, color: Colors.redAccent, size: 60),
//               const SizedBox(height: 20),
//               const Text(
//                 "Second Chance!",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 28,
//                   fontFamily: 'Baloo2',
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               const Text(
//                 "Watch a short video to get 3 extra lives and continue your progress!",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.white70, fontSize: 16),
//               ),
//               const SizedBox(height: 30),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextButton(
//                       onPressed: () =>
//                           setState(() => _showRetryOverlay = false),
//                       child: const Text(
//                         "No Thanks",
//                         style: TextStyle(color: Colors.white60, fontSize: 18),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.greenAccent[700],
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       onPressed: handleWatchAdRetry,
//                       icon: const Icon(Icons.play_arrow_rounded),
//                       label: const Text(
//                         "RESUME",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class BombAura extends StatefulWidget {
//   final double size;
//   final Color color;
//   const BombAura({
//     super.key,
//     required this.size,
//     this.color = Colors.redAccent,
//   });

//   @override
//   State<BombAura> createState() => _BombAuraState();
// }

// class _BombAuraState extends State<BombAura>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     )..repeat(reverse: true); // Makes it pulse inand out
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return Container(
//           width: widget.size * (1.2 + (_controller.value * 0.3)), // Pulses size
//           height: widget.size * (1.2 + (_controller.value * 0.3)),
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             boxShadow: [
//               BoxShadow(
//                 color: widget.color.withOpacity(
//                   0.6 - (_controller.value * 0.3),
//                 ),
//                 blurRadius: 20 * _controller.value,
//                 spreadRadius: 10 * _controller.value,
//               ),
//             ],
//             border: Border.all(color: widget.color.withOpacity(0.5), width: 2),
//           ),
//         );
//       },
//     );
//   }
// }

// class BouncingWidget extends StatelessWidget {
//   final Widget child;
//   final int value; // The animation triggers when this changes

//   const BouncingWidget({super.key, required this.child, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return TweenAnimationBuilder<double>(
//       key: ValueKey(
//         value,
//       ), // Crucial: tells Flutter to restart animationwhen value changes
//       tween: Tween(begin: 1.3, end: 1.0),
//       duration: const Duration(milliseconds: 900),
//       curve: Curves.elasticOut,
//       builder: (context, scale, child) {
//         return Transform.scale(scale: scale, child: child);
//       },
//       child: child,
//     );
//   }
// }

// class Particle {
//   Offset position;
//   Offset velocity;
//   double opacity = 1.0;
//   final Color color;

//   Particle({
//     required this.position,
//     required this.velocity,
//     required this.color,
//   });

//   void update() {
//     position += velocity;
//     velocity *= 0.95; // Friction: particles slow down
//     opacity -= 0.02; // Fade out
//   }
// }

// class PopEffect {
//   final Offset position;
//   final Color color;
//   final List<Particle> particles;
//   double shockwaveScale = 0.1;
//   double shockwaveOpacity = 1.0;
//   final DateTime createdAt = DateTime.now();

//   PopEffect({required this.position, required this.color})
//     : particles = List.generate(12, (i) {
//         // Create particles flying in a circle
//         double angle = (i * 30) * (3.14159 / 180);
//         double speed = 2.0 + (i % 3);
//         return Particle(
//           position: position,
//           velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
//           color: color,
//         );
//       });
// }

// enum GemType {
//   normal,
//   bomb,
//   rainbow,
//   frozen,
//   golden,
//   freezePowerUp,
//   poison, // Loses 1 Life
//   dizzy,
//   gravity,
// }

// enum ObjectiveType { score, clearGems, survive, collection, accuracy, combo }

// class FloatingText {
//   final String text;
//   Offset position;
//   double opacity = 1.0;
//   final Color color;
//   FloatingText({
//     required this.text,
//     required this.position,
//     required this.color,
//   });
// }

// class Gem {
//   final int id;
//   Offset position;
//   double speed;
//   Color color;
//   GemType type;
//   int tapsRequired;
//   final double scale;
//   List<Offset> trail = [];
//   final double waveAmplitude;
//   final double waveFrequency; // How fast it oscillates
//   final double phase; // Random start point so they don't all move in sync
//   final double initialX;

//   Gem({
//     required this.id,
//     required this.position,
//     required this.speed,
//     required this.color,
//     required this.type,
//     required this.tapsRequired,
//     required this.scale,
//     this.waveAmplitude = 0, // Default 0 (straight)
//     this.waveFrequency = 0.05,
//     required this.phase,
//     required this.initialX,
//   });
// }

// class SpawnSplash {
//   final Offset position;
//   final Color color;
//   double radius = 10.0;
//   double opacity = 1.0;
//   final DateTime createdAt = DateTime.now();

//   SpawnSplash({required this.position, required this.color});
// }

// // In your _GemGameScreenState, add this list:
// final List<SpawnSplash> activeSplashes = [];

// class SpawnPainter extends CustomPainter {
//   final List<SpawnSplash> splashes;
//   SpawnPainter(this.splashes);

//   @override
//   void paint(Canvas canvas, Size size) {
//     for (var splash in splashes) {
//       final paint = Paint()
//         ..color = splash.color.withOpacity(splash.opacity.clamp(0, 1))
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 2;

//       // Draw an elliptical ripple (perspective)
//       canvas.drawOval(
//         Rect.fromCenter(
//           center: splash.position,
//           width: splash.radius * 2.5,
//           height: splash.radius * 0.8,
//         ),
//         paint,
//       );

//       // Draw a subtle glow
//       final glowPaint = Paint()
//         ..color = splash.color.withOpacity(splash.opacity * 0.3)
//         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

//       canvas.drawOval(
//         Rect.fromCenter(
//           center: splash.position,
//           width: splash.radius * 2,
//           height: splash.radius * 0.5,
//         ),
//         glowPaint,
//       );
//     }
//   }

//   @override
//   bool shouldRepaint(SpawnPainter oldDelegate) => true;
// }

// class GemGuideOverlay extends StatelessWidget {
//   final VoidCallback onClose;

//   const GemGuideOverlay({super.key, required this.onClose});

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Center(
//         child: Container(
//           width: MediaQuery.of(context).size.width * 0.9,
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(30),
//             gradient: const LinearGradient(
//               colors: [Color(0xFF0F2027), Color(0xFF203A43)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             border: Border.all(color: Colors.cyanAccent, width: 2),
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 const Text(
//                   "GEMS GUIDE",
//                   style: TextStyle(
//                     color: Colors.cyanAccent,
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 _buildGemInfo(
//                   icon: Icons.auto_awesome_outlined,
//                   color: normalg,
//                   title: "Normal Gem",
//                   description:
//                       "Tap to pop and earn 1 point. Basic scoring gem.",
//                 ),

//                 _buildGemInfo(
//                   icon: Icons.ac_unit,
//                   color: frozeng,
//                   title: "Frozen Gem",
//                   description: "Needs 2 taps to break. Worth 2 points.",
//                 ),

//                 _buildGemInfo(
//                   icon: Icons.bolt,
//                   color: bombg,
//                   title: "Bomb Gem",
//                   description:
//                       "Explodes nearby gems. 0 points. Safe to let pass.",
//                 ),

//                 _buildGemInfo(
//                   icon: Icons.looks,
//                   color: Colors.purple,
//                   title: "Rainbow Gem",
//                   description:
//                       "Appears in different colors.Removes ALL gems of one random type instantly.",
//                 ),
//                 _buildGemInfo(
//                   icon: Icons.stars,
//                   color: Colors.amber,
//                   title: "Golden Gem",
//                   description:
//                       "Extremely fast! Worth 20 score points..Catch fast!",
//                 ),

//                 _buildGemInfo(
//                   icon: Icons.timer_outlined,
//                   color: Colors.cyanAccent,
//                   title: "Freeze Power-up",
//                   description:
//                       "Slows down time for 5 seconds. Catch your breath!",
//                 ),

//                 _buildGemInfo(
//                   icon: Icons.heart_broken_outlined, // Alternative for Skull
//                   color: Colors.greenAccent,
//                   title: "Poison Gem",
//                   description:
//                       "WARNING: Tapping loses 1 LIFE! Let it pass safely.",
//                 ),
//                 _buildGemInfo(
//                   icon: Icons.cyclone,
//                   color: Colors.purple,
//                   title: "Dizzy Gem",
//                   description: "Causes confusion and -30 score penalty!",
//                 ),
//                 _buildGemInfo(
//                   icon: Icons.south,
//                   color: Colors.deepOrange,
//                   title: "Gravity Gem",
//                   description: "Makes all gems fall much faster for 3 seconds!",
//                 ),
//                 const SizedBox(height: 30),

//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.cyanAccent,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 60,
//                       vertical: 15,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                   ),
//                   onPressed: onClose,
//                   child: const Text(
//                     "GOT IT!",
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGemInfo({
//     required IconData icon,
//     required Color color,
//     required String title,
//     required String description,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 15),
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         color: Colors.black54,
//         border: Border.all(color: color.withOpacity(0.7)),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: 32),
//           const SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     color: color,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   description,
//                   style: const TextStyle(color: Colors.white70, fontSize: 14),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class TierCompletionOverlay extends StatelessWidget {
//   final GameTier completedTier;
//   final VoidCallback onNextTier;

//   const TierCompletionOverlay({
//     super.key,
//     required this.completedTier,
//     required this.onNextTier,
//   });

//   @override
//   Widget build(BuildContext context) {
//     String nextTierName = "";
//     String completedName = "";
//     String nextZoneTitle = "";

//     switch (completedTier) {
//       case GameTier.tier1:
//         completedName = "Tier 1: Score Rush";
//         nextTierName = "Tier 2: Survival";
//         nextZoneTitle = "Neon Heights";
//         break;
//       case GameTier.tier2:
//         completedName = "Tier 2: Survival";
//         nextTierName = "Tier 3: GemMaster";
//         nextZoneTitle = "Galaxy Depths";
//         break;
//       case GameTier.tier3:
//         completedName = "Tier 3: Gem Master";
//         nextTierName = "ALL TIERS CLEARED!";
//         nextZoneTitle = "ALL ZONE CLEARED!";
//         break;
//     }

//     return Container(
//       color: Colors.black.withOpacity(0.85),
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Glowing Icon
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.amber.withOpacity(0.5),
//                     blurRadius: 40,
//                   ),
//                 ],
//               ),
//               child: const Icon(
//                 Icons.stars_rounded,
//                 color: Colors.amber,
//                 size: 100,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               "TIER COMPLETED!",
//               style: TextStyle(
//                 fontSize: 32,
//                 fontWeight: FontWeight.w900,
//                 color: title1,
//                 fontFamily: 'Baloo2',
//                 letterSpacing: 2,
//               ),
//             ),
//             Text(
//               completedName,
//               style: const TextStyle(color: Colors.white70, fontSize: 18),
//             ),
//             const SizedBox(height: 40),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: Colors.greenAccent.withOpacity(0.5),
//                 ), // Green for unlock
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Icon(
//                         Icons.map_outlined,
//                         color: Colors.greenAccent,
//                         size: 18,
//                       ),
//                       const SizedBox(width: 8),
//                       const Text(
//                         "NEW MAP UNLOCKED",
//                         style: TextStyle(
//                           color: Colors.greenAccent,
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     nextZoneTitle.toUpperCase(),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold,
//                       fontFamily: 'Baloo2',
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: Colors.greenAccent.withOpacity(0.5),
//                 ), // Green for unlock
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Icon(
//                         Icons.map_outlined,
//                         color: Colors.greenAccent,
//                         size: 18,
//                       ),
//                       const SizedBox(width: 8),
//                       const Text(
//                         "NEW TIER UNLOCKED",
//                         style: TextStyle(
//                           color: Colors.greenAccent,
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     nextTierName.toUpperCase(),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold,
//                       fontFamily: 'Baloo2',
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 50),
//             InkWell(
//               onTap: onNextTier,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 50,
//                   vertical: 15,
//                 ),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(30),
//                   gradient: LinearGradient(colors: [title1, title2]),
//                 ),
//                 child: const Text(
//                   "CONTINUE ADVENTURE",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // class LevelIntroOverlay extends StatelessWidget {
// //   final String tierName; // Added Tier Name
// //   final int localLevel; // Level within the tier
// //   final int totalInTier; // Total levels in this tier
// //   final String objectiveDescription;
// //   final VoidCallback onGotIt;
// //   final Function(String boosterType, int cost) onBuyBooster;
// //   final Set<String> activeBoosters;
// //   final bool isTimeObjective;
// //
// //   const LevelIntroOverlay({
// //     super.key,
// //     required this.objectiveDescription,
// //     required this.onGotIt,
// //     required this.tierName,
// //     required this.localLevel,
// //     required this.totalInTier,
// //     required this.onBuyBooster,
// //     required this.activeBoosters,
// //     required this.isTimeObjective,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return SafeArea(
// //       child: Container(
// //         margin: const EdgeInsets.symmetric(horizontal: 16),
// //         padding: const EdgeInsets.all(20),
// //         decoration: BoxDecoration(
// //           color: bg,
// //           borderRadius: BorderRadius.circular(25),
// //           border: Border.all(color: Colors.white24),
// //         ),
// //         child: Center(
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               // TIER NAME DISPLAY
// //               Text(
// //                 tierName.toUpperCase(),
// //                 style: const TextStyle(
// //                   fontSize: 18,
// //                   letterSpacing: 2,
// //                   fontWeight: FontWeight.bold,
// //                   color: title2,
// //                   fontFamily: 'Baloo2',
// //                 ),
// //               ),
// //               Text(
// //                 "LEVEL $localLevel",
// //                 style: const TextStyle(
// //                   fontSize: 48,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.white,
// //                   fontFamily: 'Baloo2',
// //                 ),
// //               ),
// //               const SizedBox(height: 20),
// //               Container(
// //                 padding: const EdgeInsets.all(20),
// //                 decoration: BoxDecoration(
// //                   // color: gameoverCard,
// //                   gradient: LinearGradient(
// //                     colors: [Colors.white24, Colors.transparent],
// //                     begin: Alignment.topLeft,
// //                     end: Alignment.bottomRight,
// //                   ),
// //                   border: Border.all(color: Colors.white10),
// //                   borderRadius: BorderRadius.circular(20),
// //                 ),
// //                 child: Column(
// //                   children: [
// //                     const Icon(
// //                       Icons.track_changes,
// //                       size: 40,
// //                       color: Colors.amberAccent,
// //                     ),
// //                     const SizedBox(height: 12),
// //                     Text(
// //                       objectiveDescription,
// //                       textAlign: TextAlign.center,
// //                       style: const TextStyle(
// //                         fontSize: 20,
// //                         color: Colors.white,
// //                         fontFamily: 'Baloo2',
// //                       ),
// //                     ),
// //                     const SizedBox(height: 12),
// //                     Text(
// //                       'Target',
// //                       textAlign: TextAlign.center,
// //                       style: const TextStyle(
// //                         fontSize: 14,
// //                         color: title1,
// //                         fontFamily: 'Baloo2',
// //                       ),
// //                     ),
// //                     // --- BOOSTER SHOP SECTION ---
// //                     const SizedBox(height: 10),
// //                     const Text(
// //                       "PRE-GAME BOOSTERS",
// //                       style: TextStyle(
// //                         color: Colors.white70,
// //                         fontSize: 12,
// //                         fontWeight: FontWeight.bold,
// //                         letterSpacing: 1.2,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 10),
// //                     Wrap(
// //                       spacing: 10,
// //                       runSpacing: 10,
// //                       alignment: WrapAlignment.center,
// //                       children: [
// //                         _buildBoosterItem("Shield", Icons.shield, 30, "shield"),
// //                         _buildBoosterItem("Slow-Mo", Icons.speed, 40, "slowmo"),
// //                         _buildBoosterItem(
// //                           "Magnet",
// //                           Icons.auto_fix_high,
// //                           50,
// //                           "magnet",
// //                         ),
// //                         if (isTimeObjective)
// //                           _buildBoosterItem(
// //                             "+15s Time",
// //                             Icons.timer,
// //                             60,
// //                             "time",
// //                           ),
// //                       ],
// //                     ),
// //                     const SizedBox(height: 30),
// //                     GestureDetector(
// //                       onTap: onGotIt,
// //                       child: Container(
// //                         width: double.infinity,
// //                         padding: const EdgeInsets.symmetric(
// //                           vertical: 14,
// //                           // horizontal: 50,
// //                         ),
// //                         decoration: BoxDecoration(
// //                           borderRadius: BorderRadius.circular(18),
// //                           gradient: const LinearGradient(
// //                             colors: [title1, title2],
// //                           ),
// //                         ),
// //                         child: const Text(
// //                           "Start Level",
// //                           textAlign: TextAlign.center,
// //                           style: TextStyle(
// //                             fontSize: 20,
// //                             color: Colors.white,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildBoosterItem(String name, IconData icon, int cost, String key) {
// //     bool isActive = activeBoosters.contains(key);
// //     return GestureDetector(
// //       onTap: isActive ? null : () => onBuyBooster(key, cost),
// //       child: Opacity(
// //         opacity: isActive ? 1.0 : 0.7,
// //         child: Container(
// //           width: 100,
// //           padding: const EdgeInsets.all(8),
// //           decoration: BoxDecoration(
// //             color: isActive
// //                 ? Colors.green.withOpacity(0.2)
// //                 : Colors.white.withOpacity(0.05),
// //             borderRadius: BorderRadius.circular(15),
// //             border: Border.all(
// //               color: isActive ? Colors.greenAccent : Colors.white24,
// //             ),
// //           ),
// //           child: Column(
// //             children: [
// //               Icon(
// //                 icon,
// //                 color: isActive ? Colors.greenAccent : Colors.white,
// //                 size: 24,
// //               ),
// //               Text(
// //                 name,
// //                 style: const TextStyle(color: Colors.white, fontSize: 11),
// //               ),
// //               const SizedBox(height: 4),
// //               if (!isActive)
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     Image.asset(
// //                       'assets/minigame3/bubble_gem_storm/icons/coin.png',
// //                       width: 12,
// //                     ),
// //                     // const Icon(
// //                     //   Icons.monetization_on,
// //                     //   size: 12,
// //                     //   color: Colors.amber,
// //                     // ),
// //                     Text(
// //                       " $cost",
// //                       style: const TextStyle(
// //                         color: Colors.amber,
// //                         fontSize: 12,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                   ],
// //                 )
// //               else
// //                 const Text(
// //                   "ACTIVE",
// //                   style: TextStyle(
// //                     color: Colors.greenAccent,
// //                     fontSize: 10,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// class LevelIntroOverlay extends StatefulWidget {
//   final String tierName;
//   final int localLevel;
//   final int totalInTier;
//   final String objectiveDescription;
//   final VoidCallback onGotIt;
//   final Function(String boosterType, int cost) onBuyBooster;
//   final Set<String> activeBoosters;
//   final bool isTimeObjective;

//   const LevelIntroOverlay({
//     super.key,
//     required this.objectiveDescription,
//     required this.onGotIt,
//     required this.tierName,
//     required this.localLevel,
//     required this.totalInTier,
//     required this.onBuyBooster,
//     required this.activeBoosters,
//     required this.isTimeObjective,
//   });

//   @override
//   State<LevelIntroOverlay> createState() => _LevelIntroOverlayState();
// }

// class _LevelIntroOverlayState extends State<LevelIntroOverlay> {
//   // 1. Track which booster is currently selected to show its description
//   String? _selectedBoosterKey; // 2. The Map of descriptions
//   String? _serverFreeBooster;
//   final Map<String, String> _boosterDescriptions = {
//     "shield":
//         "🛡️ SHIELD: Protects you from one life loss. Stay in the game longer!",
//     "slowmo":
//         "⏳ SLOW-MO: Slows down all falling gems by 30% for easier popping.",
//     "magnet": "🧲 MAGNET: Automatically bursts ✨gems for 10 secs.",
//     "time":
//         "⏱️ EXTRA TIME: Adds 15 extra seconds to the clock. Great for high scores!",
//   };

//   @override
//   void initState() {
//     super.initState();
//     _fetchFreeBooster();
//   }

//   void _fetchFreeBooster() async {
//     final free = await BubbleGemFirestoreService.getFreeBooster();
//     if (mounted) setState(() => _serverFreeBooster = free);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 16),
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: bg,
//           borderRadius: BorderRadius.circular(25),
//           border: Border.all(color: Colors.white24),
//         ),
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // TIER NAME DISPLAY
//               Text(
//                 widget.tierName.toUpperCase(),
//                 style: const TextStyle(
//                   fontSize: 18,
//                   letterSpacing: 2,
//                   fontWeight: FontWeight.bold,
//                   color: title2, // Using 'title2'
//                   fontFamily: 'Baloo2',
//                 ),
//               ),
//               Text(
//                 "LEVEL ${widget.localLevel}",
//                 style: const TextStyle(
//                   fontSize: 48,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   fontFamily: 'Baloo2',
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Colors.white24, Colors.transparent],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   border: Border.all(color: Colors.white10),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Column(
//                   children: [
//                     const Icon(
//                       Icons.track_changes,
//                       size: 40,
//                       color: Colors.amberAccent,
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       widget.objectiveDescription,
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         fontSize: 20,
//                         color: Colors.white,
//                         fontFamily: 'Baloo2',
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     const Text(
//                       'Target',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: title1, // Using 'title1'
//                         fontFamily: 'Baloo2',
//                       ),
//                     ),

//                     const SizedBox(height: 20),
//                     const Text(
//                       "PRE-GAME BOOSTERS",
//                       style: TextStyle(
//                         color: Colors.white70,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1.2,
//                       ),
//                     ),
//                     const SizedBox(height: 10), // BOOSTER GRID
//                     Wrap(
//                       spacing: 10,
//                       runSpacing: 10,
//                       alignment: WrapAlignment.center,
//                       children: [
//                         _buildBoosterItem("Shield", Icons.shield, 30, "shield"),
//                         _buildBoosterItem("Slow-Mo", Icons.speed, 40, "slowmo"),
//                         _buildBoosterItem(
//                           "Magnet",
//                           Icons.auto_fix_high,
//                           50,
//                           "magnet",
//                         ),
//                         if (widget.isTimeObjective)
//                           _buildBoosterItem(
//                             "+15s Time",
//                             Icons.timer,
//                             60,
//                             "time",
//                           ),
//                       ],
//                     ),

//                     // 3. DYNAMIC DESCRIPTION AREA
//                     const SizedBox(height: 15),
//                     Container(
//                       height:
//                           60, // Fixed height so the layout doesn't jumppadding: const EdgeInsets.symmetric(horizontal: 10),
//                       alignment: Alignment.center,
//                       decoration: BoxDecoration(
//                         color: Colors.black26,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Text(
//                         _boosterDescriptions[_selectedBoosterKey] ??
//                             "Tap a booster to see its power!",
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           color: Colors.white70,
//                           fontSize: 13,
//                           fontStyle: FontStyle.italic,
//                           fontFamily: 'Baloo2',
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 20),
//                     GestureDetector(
//                       onTap: widget.onGotIt,
//                       child: Container(
//                         width: double.infinity,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(18),
//                           gradient: const LinearGradient(
//                             colors: [title1, title2],
//                           ),
//                         ),
//                         child: const Text(
//                           "Start Level",
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 20,
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildBoosterItem(String name, IconData icon, int cost, String key) {
//     bool isActive = widget.activeBoosters.contains(key);
//     bool isSelected = _selectedBoosterKey == key;
//     bool isFree = _serverFreeBooster == key;

//     return GestureDetector(
//       onTap: () {
//         // When tapped, we update the selected key to show description
//         setState(() {
//           if (isActive) {
//             _selectedBoosterKey = null;
//           } else {
//             _selectedBoosterKey = key;
//           }
//         });

//         // If it's not active, we also trigger the buy logic
//         // if (!isActive) {
//         widget.onBuyBooster(key, isFree ? 0 : cost);
//         // }
//       },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         width: 100,
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: isActive
//               ? Colors.green.withOpacity(0.2)
//               : isFree
//               ? Colors.amber.withValues(alpha: 0.1)
//               : (isSelected ? Colors.white12 : Colors.white.withOpacity(0.05)),
//           borderRadius: BorderRadius.circular(15),
//           border: Border.all(
//             color: isActive
//                 ? Colors.greenAccent
//                 : isFree
//                 ? Colors.amber
//                 : (isSelected ? title1 : Colors.white24),
//             width: (isActive || isSelected) ? 2 : 1,
//           ),
//         ),
//         child: Column(
//           children: [
//             if (isFree && !isActive)
//               Container(
//                 margin: const EdgeInsets.only(bottom: 4),
//                 padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: Colors.amber,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: const Text(
//                   "DAILY FREE",
//                   style: TextStyle(
//                     fontSize: 8,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             Icon(
//               icon,
//               color: isActive
//                   ? Colors.greenAccent
//                   : isFree
//                   ? Colors.amber
//                   : (isSelected ? Colors.amberAccent : Colors.white),
//               size: 24,
//             ),
//             Text(
//               name,
//               style: const TextStyle(color: Colors.white, fontSize: 11),
//             ),
//             const SizedBox(height: 4),
//             if (!isActive)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   if (!isFree)
//                     Image.asset(
//                       'assets/minigame3/bubble_gem_storm/icons/coin.png',
//                       width: 12,
//                     ),
//                   Text(
//                     isFree ? 'FREE' : " $cost",
//                     style: TextStyle(
//                       color: isFree ? Colors.amberAccent : Colors.amber,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               )
//             else
//               Column(
//                 children: [
//                   const Text(
//                     "ACTIVE",
//                     style: TextStyle(
//                       color: Colors.greenAccent,
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Text(
//                     "Tap to remove",
//                     style: TextStyle(color: Colors.white54, fontSize: 8),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
class GemGameScreen extends StatefulWidget {
  final int level;
  final bool forceTutorial;
  const GemGameScreen({
    super.key,
    required this.level,
    required this.forceTutorial,
  });

  @override
  State<GemGameScreen> createState() => _GemGameScreenState();
}

class _GemGameScreenState extends State<GemGameScreen>
    with TickerProviderStateMixin {
  // String? _activeBoosterNotification;
  List<String> _activeBoosterNotifications = [];
  Timer? _boosterNotifyTimer;

  String? _completedChallengeTitle;
  String? _completedChallengeId; // Stores the title of the finished challenge
  bool _showChallengeReward = false;
  int _localCoins = 0;
  // String? _challengeNotifyText;
  // bool _showChallengePop = false;
  int _gemsPoppedThisSession = 0;
  int _maxComboThisSession = 0;
  int _secondsSurvivedThisSession = 0;

  final Set<GemType> _warnedGemTypes = {};
  String? _activeWarning;
  GemType? _warningType;
  Timer? _warningTimer;

  bool _showCaricature = false;

  bool _showRewardOverlay = false;
  bool _showGameOverTransition = false;
  // String _caricatureType = "WIN";
  bool _shieldActive = false;
  bool _slowMoActive = false;
  bool _magnetActive = false;
  bool _extraTimeActive = false; // For the +15s Time Booster

  int _restartTapCount = 0;
  bool _showRetryOverlay = false;

  bool _isVibrationEnabled = true;
  bool _showTierOverlay = false;

  final GlobalKey _scoreKey = GlobalKey();
  final GlobalKey _livesKey = GlobalKey();
  final GlobalKey _gameAreaKey = GlobalKey();

  double _shakeOffset = 0.0;

  late AnimationController _bgAnimationController;

  bool _showTutorial = false;
  bool _showGemGuide = false;
  int _currentTutorialStep = 0;
  bool isPausedByOverlay = false;
  bool _showLevelIntro = false;

  final List<Gem> gems = [];
  final List<PopEffect> activeEffects = [];
  List<FloatingText> floatingTexts = [];
  final Random random = Random();
  late AnimationController _comboPopController;
  late LevelConfig currentLevel;
  int gemsCleared = 0;
  int secondsRemaining = 0;
  Timer? countdownTimer;
  bool levelCleared = false;

  int comboCount = 0;
  int currentMultiplier = 1;
  Timer? comboTimer;
  double comboBarValue = 0.0;

  Timer? gameLoop;
  Timer? spawnLoop;

  int score = 0;
  int combo = 0;
  int lives = 3;

  int specificGemsCollected = 0;
  int maxComboReached = 0;
  bool lifeLostThisLevel = false;

  int gemId = 0;
  double spawnRate = 1.2;
  double speedMultiplier = 1;

  bool gameOver = false;
  bool dangerActive = false;
  double dangerZoneHeight = 120;

  bool isSlowed = false;
  Timer? slowTimer;
  double slowMultiplier = 0.4;

  DateTime lastTap = DateTime.now();
  Color? flashColor;

  String? activeMotivation;
  bool _isProcessingWin = false;

  Size screenSize = Size.zero;
  List<TutorialStep> get _tutorialSteps => [
    TutorialStep(
      key: _gameAreaKey,
      title: "Welcome to Gem Pop!",
      description:
          "Gems will float up from the bottom. Tap them before they reach the top!",
    ),
    TutorialStep(
      key: _scoreKey,
      title: "Track your Progress",
      description: "Keep an eye on your score and level objectives here.",
    ),
    TutorialStep(
      key: _livesKey,
      title: "Watch your Lives",
      description:
          "If a gem reaches the top, you lose a life. Lose 3 and it's Game Over!",
    ),
  ];
  Future<void> _loadSettings() async {
    _isVibrationEnabled = await HapticSettings.isEnabled();
  }

  Future<void> _startMusic() async {
    // This will stop the Home Theme and start the Game Theme automatically
    await SoundManager.instance.playLevelTheme();
  }

  Future<void> _refreshLocalCoins() async {
    int coins = await BubbleGemFirestoreService.getCoins();
    if (mounted) {
      setState(() {
        _localCoins = coins;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshLocalCoins();
    AdService.instance.loadRewarded();
    _loadSettings();
    _startMusic();

    //  Configure global audio context to allow mixing
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
    _checkFirstTimeUser();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _showLevelIntroOverlay();
    // });
    int index = widget.level - 1;
    if (index >= myCustomLevels.length) index = myCustomLevels.length - 1;
    currentLevel = myCustomLevels[index];

    SoundManager.instance.init();

    _comboPopController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      lowerBound: 1.0,
      upperBound: 1.3,
    );
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // Slow, smooth movement
    )..repeat(); // Loop forever
  }

  void _showGemWarning(GemType type) {
    if (_warnedGemTypes.contains(type)) return; // Only show once per level

    setState(() {
      _warnedGemTypes.add(type);
      _warningType = type;

      switch (type) {
        case GemType.bomb:
          _activeWarning = "DANGER:BOMBS deduct points and reset combos!";
          break;
        case GemType.poison:
          _activeWarning = "CAUTION: POISON steals 1 life instantly!";
          break;
        case GemType.dizzy:
          _activeWarning = "WARNING: DIZZY gemscause massive score loss!";
          break;
        case GemType.gravity:
          _activeWarning = "WATCH OUT: GRAVITY gems double the speed!";
          break;
        default:
          _activeWarning = null;
      }
    });

    _warningTimer?.cancel();
    _warningTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _activeWarning = null);
    });
  }

  void _stopAllTimers() {
    gameLoop?.cancel();
    spawnLoop?.cancel();
    countdownTimer?.cancel();
    comboTimer?.cancel();
    slowTimer?.cancel(); // Reset timer variables to null to be safe
    gameLoop = null;
    spawnLoop = null;
    countdownTimer = null;
  }

  void _showLevelIntroOverlay() {
    setState(() {
      _showLevelIntro = true;
      isPausedByOverlay = true; // This stops gems and timers
      gems.clear();
      HapticManager.heavy();
    });
    _stopAllTimers();
  }

  void _startLevelAfterIntro() {
    setState(() {
      _showLevelIntro = false;
      isPausedByOverlay = false;
    });
    List<String> activeNames = [];
    if (_shieldActive) activeNames.add("SHIELD");
    if (_slowMoActive) activeNames.add("SLOW-MO");
    if (_magnetActive) activeNames.add("MAGNET");
    // if (_extraTimeActive) activeNames.add("TIME +15s");
    if (_extraTimeActive) {
      // Assuming 'objectiveDescription' is available in your main state
      bool isSurvival = currentLevel.objective == ObjectiveType.survive;
      if (isSurvival) {
        activeNames.add("TIME -15s"); // Tier 2 / Survival
      } else {
        activeNames.add("TIME +15s"); // Tier 3 / Time Target
      }
    }
    if (activeNames.isNotEmpty) {
      String message = "${activeNames.join(" & ")} ACTIVATED!";
      _showBoosterActivation(message);
    }
    startLevel(); // This starts the timers and loops
  }

  Future<void> _checkFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    // Check if tutorial was already seen
    bool seen = prefs.getBool('tutorial_seen') ?? false;

    if (!seen || widget.forceTutorial) {
      setState(() {
        isPausedByOverlay = true;
        _showTutorial = true;
        // Pausegame logic while tutorial is active
        gameLoop?.cancel();
        spawnLoop?.cancel();
        countdownTimer?.cancel();
      });
    } else {
      _showLevelIntroOverlay();
    }
  }

  void _completeTutorial() async {
    setState(() {
      _showTutorial = false;
      _showGemGuide = true; // Show guide immediately after tutorial
      isPausedByOverlay = true;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_seen', true);
  }

  void _completeGemGuide() {
    setState(() {
      _showGemGuide = false;
      isPausedByOverlay = false;
    });
    // Resume the game
    _showLevelIntroOverlay();
  }

  void startLevel() async {
    BubbleGemAnalyticsService.logLevelStart(levelId: currentLevel.id);
    BubbleGemFirestoreService.recordAttempt(
      currentLevel.id,
    ); // Track the attempt!
    String? freeBoosterKey = await BubbleGemFirestoreService.getFreeBooster();
    bool usedFree = false;
    if (freeBoosterKey != null) {
      if (freeBoosterKey == 'shield' && _shieldActive) usedFree = true;
      if (freeBoosterKey == 'slowmo' && _slowMoActive) usedFree = true;
      if (freeBoosterKey == 'magnet' && _magnetActive) usedFree = true;
      if (freeBoosterKey == 'time' && _extraTimeActive) usedFree = true;
    }
    if (usedFree) {
      await BubbleGemFirestoreService.consumeFreeBooster();
    }
    // Cancel old timers
    gameLoop?.cancel();
    spawnLoop?.cancel();
    countdownTimer?.cancel();

    setState(() {
      score = 0;
      gemsCleared = 0;
      gameOver = false;
      levelCleared = false;
      lives = _shieldActive ? 4 : 3;
      speedMultiplier = currentLevel.speed;

      if (currentLevel.objective == ObjectiveType.survive) {
        secondsRemaining = currentLevel.targetValue;
      } else if (currentLevel.timeLimit != null) {
        secondsRemaining = currentLevel.timeLimit!;
      } else {
        secondsRemaining = 999; // Placeholder or ignore
      }

      if (currentLevel.objective == ObjectiveType.survive) {
        secondsRemaining = currentLevel.targetValue;
        // TIER 2: If booster active, REDUCE the time you need to survive
        if (_extraTimeActive) {
          secondsRemaining = (secondsRemaining - 15).clamp(5, 999);
          // _showBoosterActivation("SURVIVAL TIME REDUCED -15s!");
        }
      } else if (currentLevel.timeLimit != null) {
        secondsRemaining = currentLevel.timeLimit!;
        // TIER 3: If booster active, INCREASE the time you have to clear gems
        if (_extraTimeActive) {
          secondsRemaining += 15;
          // _showBoosterActivation("TIME LIMIT EXTENDED +15s!");
        }
      }
      //  Apply Slow-Mo Booster (Temporary)
      if (_slowMoActive) {
        speedMultiplier = currentLevel.speed * 0.5;
        Timer(const Duration(seconds: 15), () {
          if (mounted) setState(() => speedMultiplier = currentLevel.speed);
        });
      }

      // 4. Apply Magnet Booster (Temporary)
      if (_magnetActive) {
        _startMagnetEffect();
      }
    });
    // Reset booster flags for next level attempt
    _shieldActive = false;
    _slowMoActive = false;
    _magnetActive = false;
    _extraTimeActive = false;
    // Start Game Loop
    gameLoop = Timer.periodic(const Duration(milliseconds: 16), updateGame);

    // Start Spawn Loop using custom spawnRate from config
    spawnLoop = Timer.periodic(
      Duration(milliseconds: currentLevel.spawnRate.toInt()),
      spawnGem,
    );

    //Start Countdown

    if (currentLevel.objective == ObjectiveType.survive ||
        currentLevel.timeLimit != null) {
      countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (gameOver || levelCleared) {
          timer.cancel();
          return;
        }

        setState(() {
          secondsRemaining--;
          _secondsSurvivedThisSession++;

          if (currentLevel.objective == ObjectiveType.survive) {
            if (secondsRemaining <= 0) winLevel();
          } else {
            if (secondsRemaining <= 0) {
              checkWinCondition();
              if (!levelCleared) loseLife(); // Custom function to end game
            }
          }
        });
      });
    }
  }

  void _startMagnetEffect() {
    // 1. Create the periodic timer
    final Timer magnetTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) {
        if (!mounted || gameOver || levelCleared) {
          timer.cancel();
          return;
        }

        // Automatically pop normal gems
        // We use a copy of the list to avoid concurrent modification errors
        final normalGems = gems.where((g) => g.type == GemType.normal).toList();
        for (var gem in normalGems) {
          tapGem(gem);
        }
      },
    );

    // 2. Schedule the cancellation after 10 seconds
    Timer(const Duration(seconds: 10), () {
      if (magnetTimer.isActive) {
        magnetTimer.cancel();
        debugPrint("Magnet Effect Expired");
      }
    });
  }

  @override
  void dispose() {
    _stopAllTimers();
    // gameLoop?.cancel();
    // spawnLoop?.cancel();
    // comboTimer?.cancel();
    _comboPopController.dispose();
    _bgAnimationController.dispose();
    SoundManager.instance.stopTheme();
    super.dispose();
  }

  void spawnGem(Timer t) {
    if (gameOver || levelCleared || isPausedByOverlay) return;

    final typeRoll = random.nextInt(100);

    GemType type = GemType.normal;
    double speedBoost = 1.0;

    if (typeRoll > 97) {
      type = GemType.golden;
      speedBoost = 2.5;
    } else if (typeRoll > 94) {
      type = GemType.freezePowerUp;
    } else if (typeRoll > 90)
      type = GemType.poison; // 4% chance
    else if (typeRoll > 85)
      type = GemType.dizzy; // 5% chance
    else if (typeRoll > 80)
      type = GemType.gravity;
    else if (typeRoll > 78) {
      type = GemType.bomb;
    } else if (typeRoll > 70) {
      type = GemType.rainbow;
    } else if (typeRoll > 60) {
      type = GemType.frozen;
    }

    if (type == GemType.bomb ||
        type == GemType.poison ||
        type == GemType.dizzy ||
        type == GemType.gravity) {
      _showGemWarning(type);
    }

    int taps = 1;

    if (type == GemType.frozen) taps = 2;
    double randomScale = 0.7 + (random.nextDouble() * 0.7);
    if (type == GemType.golden) randomScale = 0.6;

    Color color = Colors.primaries[random.nextInt(Colors.primaries.length)];
    double currentGlobalSpeed = isSlowed
        ? (speedMultiplier * slowMultiplier)
        : speedMultiplier;
    double finalSpeed =
        (0.5 + random.nextDouble()) * currentGlobalSpeed * speedBoost;
    double amplitude = random.nextDouble() > 0.5
        ? (10.0 + random.nextDouble() * 20.0)
        : 0.0;
    double frequency = 0.02 + (random.nextDouble() * 0.03);
    double phase = random.nextDouble() * 2 * pi;
    double startX = random.nextDouble() * (screenSize.width - 100) + 50;

    // THE SPLASH
    setState(() {
      activeSplashes.add(
        SpawnSplash(
          position: Offset(startX, screenSize.height - 10),
          color: type == GemType.golden ? Colors.amber : Colors.cyanAccent,
        ),
      );
    });
    gems.add(
      Gem(
        id: gemId++,
        position: Offset(
          random.nextDouble() * (screenSize.width - 50) + 25,
          screenSize.height + 40,
        ),
        speed: finalSpeed,
        color: color,
        type: type,
        tapsRequired: taps,
        scale: randomScale,
        waveAmplitude: amplitude,
        waveFrequency: frequency,
        phase: phase,
        initialX: startX,
      ),
    );
  }

  void updateGame(Timer timer) {
    if (gameOver || levelCleared || isPausedByOverlay || _isProcessingWin)
      return;

    final List<Gem> remove = [];
    bool isDanger = false;

    for (var gem in gems) {
      // 1. Move Upwards (Vertical)
      double newY = gem.position.dy - gem.speed;

      // 2. Calculate Wavy Movement (Horizontal)
      // We use the Y position as the input for the Sine wave
      double newX = gem.initialX;
      if (gem.waveAmplitude > 0) {
        newX =
            gem.initialX +
            (sin((newY * gem.waveFrequency) + gem.phase) * gem.waveAmplitude);
      }

      gem.position = Offset(newX, newY);

      if (gem.position.dy < dangerZoneHeight) {
        isDanger = true;
      }

      if (gem.position.dy < 0) {
        remove.add(gem);
        bool isSafeToPass =
            gem.type == GemType.golden ||
            gem.type == GemType.bomb ||
            gem.type == GemType.poison ||
            gem.type == GemType.dizzy ||
            gem.type == GemType.gravity;

        if (!isSafeToPass) {
          loseLife();
        }
      }
      if (gem.type == GemType.golden) {
        gem.trail.insert(0, gem.position);
        if (gem.trail.length > 5) gem.trail.removeLast();
      }
    }
    for (var ft in floatingTexts) {
      ft.position = Offset(ft.position.dx, ft.position.dy - 2); // Float up
      ft.opacity -= 0.02; // Fade out
    }
    floatingTexts.removeWhere((ft) => ft.opacity <= 0);

    activeEffects.removeWhere(
      (e) => DateTime.now().difference(e.createdAt).inMilliseconds > 300,
    );
    for (var effect in activeEffects) {
      effect.shockwaveScale += 0.1;
      effect.shockwaveOpacity -= 0.05;
      for (var p in effect.particles) {
        p.update();
      }
    }
    // Remove dead effects
    activeEffects.removeWhere((e) => e.shockwaveOpacity <= 0);
    // ANIMATE SPLASHES

    for (var splash in activeSplashes) {
      splash.radius += 3.0; //Grow the ripple
      splash.opacity -= 0.04; // Fade out
    }
    // Remove dead splashes
    activeSplashes.removeWhere((s) => s.opacity <= 0);

    dangerActive = isDanger;
    gems.removeWhere((g) => remove.contains(g));

    if (mounted) {
      setState(() {});
    }
  }

  void _syncChallenges() {
    BubbleGemFirestoreService.syncAllChallenges(
      gemsPopped: _gemsPoppedThisSession,
      finalScore: score,
      maxCombo: _maxComboThisSession,
      secondsSurvived: _secondsSurvivedThisSession,
      onNotify: _showChallengeNotification, // Your notification function
    );
  }

  void loseLife() {
    if (gameOver || levelCleared) return;
    lifeLostThisLevel = true;
    lives--;

    if (currentLevel.objective == ObjectiveType.accuracy &&
        score >= currentLevel.targetValue) {
      winLevel();
      return;
    }
    if (currentLevel.objective == ObjectiveType.accuracy) {
      gameOver = true;
      _stopAllTimers();
    }

    if (lives <= 0) {
      _stopAllTimers();
      // gameLoop?.cancel();
      // spawnLoop?.cancel();
      // countdownTimer?.cancel();

      setState(() {
        _showGameOverTransition = true;
        gameOver = true;
      });
      SoundManager.instance.playLoseSound();
      SoundManager.instance.setBgmVolume(0.1);
      HapticManager.heavy();

      _syncChallenges();
      BubbleGemAnalyticsService.logGameOver(
        levelId: currentLevel.id,
        score: score,
        gemsPopped: gemsCleared,
      );

      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          SoundManager.instance.setBgmVolume(0.3);
          setState(() {
            _showGameOverTransition = false;
            // The 'gameOver' flag is already true, so the build method
            // will now show the standard buildGameOver() overlay.
          });
        }
      });
    }
  }

  void _showChallengeNotification(String title, String id) {
    if (!mounted) return;
    _stopAllTimers();
    setState(() {
      _completedChallengeTitle = title;
      _completedChallengeId = id;
      _showChallengeReward = true;
      isPausedByOverlay = true;
    });
    HapticManager.heavy();
    SoundManager.instance
        .playTierCompleteSound(); // Or a specific "Quest" sound

    // Timer(const Duration(seconds: 3), () {
    //   if (mounted) {
    //     setState(() => _showChallengePop = false); // Slide back up
    //   }
    // });
  }

  void tapGem(Gem gem) {
    if (gameOver || levelCleared || isPausedByOverlay || _isProcessingWin)
      return;
    final now = DateTime.now();

    // --- DANGER GEMS LOGIC ---
    if (gem.type == GemType.bomb ||
        gem.type == GemType.poison ||
        gem.type == GemType.dizzy ||
        gem.type == GemType.gravity) {
      _triggerScreenShake(); // All danger gems shake the screen
      comboCount = 0; // Reset combo for hitting a trap
      currentMultiplier = 1;
      comboBarValue = 0;
      comboTimer?.cancel();
    }

    comboCount++;

    lastTap = now;
    // 2. Calculate Multiplier (e.g., every 5 gems increases multiplier)
    //x1 (0-4), x2 (5-9), x3 (10-14), x5 (15+)
    if (comboCount >= 15) {
      currentMultiplier = 5;
    } else if (comboCount >= 10) {
      currentMultiplier = 3;
    } else if (comboCount >= 5) {
      currentMultiplier = 2;
    } else {
      currentMultiplier = 1;
    }

    // 3. Reset the visual combo timer
    comboTimer?.cancel();
    comboBarValue = 1.0;
    comboTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        comboBarValue -= 0.05; // Decrease bar over 1 second (approx)
        if (comboBarValue <= 0) {
          comboCount = 0;
          currentMultiplier = 1;
          timer.cancel();
        }
      });
    });
    setState(() {
      comboCount++;
      _comboPopController
          .forward(from: 1.0)
          .then((_) => _comboPopController.reverse());
    });
    if (currentMultiplier > maxComboReached) {
      maxComboReached = currentMultiplier;
    }

    //  Trigger the visual "Pop" effect
    activeEffects.add(PopEffect(position: gem.position, color: gem.color));
    if (_isVibrationEnabled) {
      HapticManager.heavy();
    }

    SoundManager.instance.playGemTap(gem.type, gem.tapsRequired);
    gem.tapsRequired--;

    if (gem.tapsRequired > 0) {
      setState(() {});
      return;
    }

    // Track Specific Gem Collection
    // if (currentLevel.objective == ObjectiveType.collection) {
    //   if (gem.type == currentLevel.targetGemType) {
    //     specificGemsCollected++;
    //   }
    // }

    // --- SCORINGLOGIC ---
    int basePoints = 0;
    String? customPopup;
    switch (gem.type) {
      case GemType.golden:
        basePoints = 20; // Massive boost
        // SoundManager.instance.playSpecial(); // Play a "ding" sound
        break;
      case GemType.freezePowerUp:
        // basePoints = 5;
        activateFreezePowerUp();
        final motivations = [
          "CHILL OUT!",
          "FREEZE!",
          "ICE COLD!",
          "STAY COOL!",
          "SLOW MO!",
        ];
        activeMotivation = motivations[random.nextInt(motivations.length)];
        Timer(const Duration(seconds: 2), () {
          if (mounted) setState(() => activeMotivation = null);
        });
        customPopup = activeMotivation;
        break;
      case GemType.normal:
        basePoints = 1;
        break;
      case GemType.frozen:
        basePoints = 2;
        break;
      case GemType.bomb:
        basePoints = 0;
        score = (score - 5).clamp(0, 999999);
        customPopup = "-5";
        explodeBomb(gem);
        break;
      case GemType.rainbow:
        basePoints = 8;
        rainbowClear();
        break;
      // --- DANGERGEMS (0 POINTS) ---
      case GemType.gravity:
        basePoints = 0; // No points for gravity
        // Speed up logic
        for (var g in gems) {
          g.speed *= 2.0;
        }
        customPopup = "SPEED UP!";
        Timer(const Duration(seconds: 3), () {
          if (mounted) {
            for (var g in gems) {
              g.speed /= 2.0;
            }
          }
        });
        break;

      case GemType.poison:
        basePoints = 0; // No points for poison
        loseLife();
        customPopup = "POISONED!";
        break;

      case GemType.dizzy:
        basePoints = 0; // No points for dizzy
        // We handle the score penalty (-30) separately or here:
        score = (score - 10).clamp(0, 999999);
        customPopup = "DIZZY! -10";
        break;
    }
    String popup = customPopup ?? "+$basePoints";
    if (currentMultiplier > 1 && customPopup == null)
      popup = "x$currentMultiplier";
    if (gem.type == GemType.golden) popup = "AMAZING!";

    setState(() {
      floatingTexts.add(
        FloatingText(
          text: popup,
          position: Offset(gem.position.dx, gem.position.dy),
          color: gem.color,
        ),
      );
    });

    // Add combo bonus to the base
    score += (basePoints * currentMultiplier);
    gemsCleared++;

    if (gem.position.dy < 150) {
      score += 10; // Bonus points
      floatingTexts.add(
        FloatingText(
          text: "CLOSE CALL! \n+10",
          position: Offset(gem.position.dx, gem.position.dy - 20),
          color: Colors.white,
        ),
      );
      HapticManager.heavy(); // Extra vibration for the save
    }
    // Update Challenges
    _gemsPoppedThisSession++; // Increment local counter
    if (currentMultiplier > _maxComboThisSession) {
      _maxComboThisSession = currentMultiplier;
    }

    gems.remove(gem);
    checkWinCondition();

    setState(() {});
  }

  void _triggerScreenShake() {
    // Shake the screen 6 times quickly
    int shakes = 0;
    Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (mounted) {
        setState(() {
          _shakeOffset = (shakes % 2 == 0) ? 8.0 : -8.0;
        });
      }
      shakes++;
      if (shakes > 6) {
        timer.cancel();
        if (mounted) setState(() => _shakeOffset = 0.0);
      }
    });
  }

  void activateFreezePowerUp() {
    slowTimer?.cancel();
    setState(() => isSlowed = true);

    // Slow down existing gems immediately
    for (var g in gems) {
      g.speed *= slowMultiplier;
    }

    slowTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() => isSlowed = false);
      // Restore speed to existing gems
      for (var g in gems) {
        g.speed /= slowMultiplier;
      }
    });
  }

  void checkWinCondition() {
    if (gameOver || levelCleared) return;

    bool won = false;
    switch (currentLevel.objective) {
      case ObjectiveType.score:
        if (score >= currentLevel.targetValue) won = true;
        break;
      case ObjectiveType.clearGems:
        if (gemsCleared >= currentLevel.targetValue) won = true;
        break;
      case ObjectiveType.collection:
        if (specificGemsCollected >= currentLevel.targetValue) won = true;
        break;
      case ObjectiveType.combo:
        if (maxComboReached >= currentLevel.targetValue) won = true;
        break;
      case ObjectiveType.accuracy:
        // For accuracy, we win if we reach a certain score/time without losing life
        // Example: Reach targetValue score with lifeLostThisLevel == false
        if (score >= currentLevel.targetValue && !lifeLostThisLevel) won = true;
        break;
      case ObjectiveType.survive: // Handled by the countdownTimer
        break;
    }

    if (won) {
      winLevel();
    } else if (currentLevel.timeLimit != null && secondsRemaining <= 0) {
      // Time ran out and objective not met
      gameOver = true;
    }
  }

  // void winLevel() async {
  //   if (gameOver || levelCleared) return;
  //   SoundManager.instance.setBgmVolume(0.1);
  //   SoundManager.instance.playWinSound();
  //   // gameLoop?.cancel();
  //   // spawnLoop?.cancel();
  //   // countdownTimer?.cancel();
  //   _stopAllTimers();
  //   setState(() {
  //     _showRewardOverlay = true;
  //
  //     HapticManager.heavy();
  //   });
  //   await Future.delayed(const Duration(seconds: 3));
  //   SoundManager.instance.setBgmVolume(0.3);
  //   if (!mounted) return;
  //   setState(() {
  //     _showRewardOverlay = false;
  //     levelCleared = true;
  //     _syncChallenges();
  //     gems.clear();
  //   });
  //
  //   int attempts = await BubbleGemFirestoreService.getLevelAttempts(
  //     currentLevel.id,
  //   );
  //   int starCount = attempts <= 1 ? 3 : (attempts < 5 ? 2 : 1);
  //   int coinReward = starCount * 10;
  //   BubbleGemAnalyticsService.logLevelWin(
  //     levelId: currentLevel.id,
  //     score: score,
  //     stars: starCount,
  //   );
  //
  //   // Save to Firestore
  //   await BubbleGemFirestoreService.updateHighScore(score);
  //   await BubbleGemFirestoreService.unlockNextLevel(currentLevel.id);
  //   BubbleGemFirestoreService.addCoins(coinReward);
  //   await _refreshLocalCoins();
  // }
  void winLevel() async {
    // Prevent double triggersif (gameOver || levelCleared || _isProcessingWin) return;

    // 1. STOP THE GAME ENGINE ONLY (Don't set levelCleared yet!)
    _stopAllTimers();
    setState(() {
      _isProcessingWin = true;
    }); // 2. IMMEDIATE AUDIO & HAPTIC
    SoundManager.instance.setBgmVolume(0.1);
    SoundManager.instance.playWinSound();
    HapticManager.heavy();

    // 3. SHOW THE "FANTASTIC" OVERLAY ONLY
    setState(() {
      _showRewardOverlay = true;
    });

    // 4. START BACKGROUND TASKS (Don't await)
    _syncChallenges();
    BubbleGemFirestoreService.updateHighScore(score);
    BubbleGemFirestoreService.unlockNextLevel(
      currentLevel.id,
    ); // 5. WAIT 3 SECONDS (User sees the "Fantastic" screen)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // 6. NOW HIDE REWARD AND SHOW THE FINAL RESULTS OVERLAY
    int attempts = await BubbleGemFirestoreService.getLevelAttempts(
      currentLevel.id,
    );
    int starCount = attempts <= 1 ? 3 : (attempts < 5 ? 2 : 1);
    int coinReward = starCount * 10;

    await BubbleGemFirestoreService.addCoins(coinReward);
    await _refreshLocalCoins();

    SoundManager.instance.setBgmVolume(0.3);

    setState(() {
      _showRewardOverlay = false; // Hide "Fantastic"
      levelCleared = true; // NOW show the "Level Complete" results
      _isProcessingWin = false;
      gems.clear();
    });
  }

  void explodeBomb(Gem bomb) {
    const radius = 120;

    gems.removeWhere((g) {
      final dist = (g.position - bomb.position).distance;
      return dist < radius;
    });
  }

  void rainbowClear() {
    if (gems.isEmpty) return;

    final randomGem = gems[random.nextInt(gems.length)];
    final colorToClear = randomGem.color;

    setState(() {
      // 2. Set the background flash color (with some transparency)
      flashColor = colorToClear.withOpacity(0.2);

      // 3. Loop through and clear gems of that color
      // We use a copy of the list to avoid concurrent modification errors
      final gemsToRemove = gems.where((g) => g.color == colorToClear).toList();

      for (var gem in gemsToRemove) {
        // Add visual pop effect for every gem destroyed
        activeEffects.add(PopEffect(position: gem.position, color: gem.color));

        // Increment score/stats for every gem cleared
        score += (1 * currentMultiplier);
        gemsCleared++;
      }

      // 4. Remove them from the main list
      gems.removeWhere((g) => g.color == colorToClear);
    });

    // 5. Reset the flash color after 200 milliseconds
    Timer(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          flashColor = null;
        });
      }
    });

    checkWinCondition();
  }

  void handleRestart() {
   
      restart();
    
  }

  void restart() {
    gameLoop?.cancel();
    spawnLoop?.cancel();
    countdownTimer?.cancel();
    comboTimer?.cancel();
    setState(() {
      gems.clear();
      score = 0;
      combo = 0;
      lives = 3;
      gemsCleared = 0;
      speedMultiplier = currentLevel.speed;
      spawnRate = 1.2;
      gameOver = false;
      levelCleared = false;
      if (currentLevel.objective == ObjectiveType.survive) {
        secondsRemaining = currentLevel.targetValue;
      } else {
        secondsRemaining = currentLevel.timeLimit ?? 0;
      }

      // gameLoop = Timer.periodic(const Duration(milliseconds: 16), updateGame);
      // spawnLoop = Timer.periodic(const Duration(milliseconds: 900), spawnGem);
    });
    startLevel();
  }

  void handleWatchAdRetry() {
    AdService.instance.showRewarded(
      onAdClosedAfterReward: () {
        // The player watched the ad, so we resume the current session
        resumeGame();
      },
    );
  }

  void handleCoinRetry() async {
    const int retryCost = 50; // Set your desired cost
    bool success = await BubbleGemFirestoreService.spendCoins(retryCost);

    if (success) {
      resumeGame(); // Reuses your existing resume logic (3 lives, clears gems)
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Not enough coins!")));
      }
    }
  }

  void resumeGame() {
    setState(() {
      gameOver = false;
      _showRetryOverlay = false;
      lives = 3;
      gems.clear();

      // Reset danger warning if any was active
      dangerActive = false;
    });

    // Restart the Game Loop
    gameLoop = Timer.periodic(const Duration(milliseconds: 16), updateGame);

    // Restart the Spawn Loop
    spawnLoop = Timer.periodic(
      Duration(milliseconds: currentLevel.spawnRate.toInt()),
      spawnGem,
    );

    // Restart the Countdown Timer (if applicable)
    if (currentLevel.objective == ObjectiveType.survive ||
        currentLevel.timeLimit != null) {
      countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (gameOver || levelCleared) {
          timer.cancel();
          return;
        }
        setState(() {
          secondsRemaining--;
          if (currentLevel.objective == ObjectiveType.survive) {
            if (secondsRemaining <= 0) winLevel();
          } else {
            if (secondsRemaining <= 0) {
              checkWinCondition();
              if (!levelCleared) loseLife();
            }
          }
        });
      });
    }
    setState(() {
      floatingTexts.add(
        FloatingText(
          text: "RESUMED! GET READY!",
          position: Offset(screenSize.width / 2 - 100, screenSize.height / 2),
          color: Colors.greenAccent,
        ),
      );
    });
  }

  String get currentObjectiveText {
    switch (currentLevel.objective) {
      case ObjectiveType.score:
        return "Score: $score / ${currentLevel.targetValue}";
      case ObjectiveType.clearGems:
        return "Gems: $gemsCleared / ${currentLevel.targetValue}\nTime Left: $secondsRemaining";
      case ObjectiveType.survive:
        return "Survive!\nTime Left: $secondsRemaining";
      // case ObjectiveType.collection:
      //   return "Collect ${currentLevel.targetGemType?.name}: $specificGemsCollected / ${currentLevel.targetValue}";
      case ObjectiveType.accuracy:
        return "Score: $score / ${currentLevel.targetValue}\nDon't lose a life!";
      case ObjectiveType.combo:
        return "Max Multiplier: ${maxComboReached}x / ${currentLevel.targetValue}x";
      default:
        return "";
    }
  }

  String get victoryObjectiveText {
    switch (currentLevel.objective) {
      case ObjectiveType.score:
        return "Reach Score ${currentLevel.targetValue}";
      case ObjectiveType.clearGems:
        return "Clear ${currentLevel.targetValue} Gems in ${currentLevel.timeLimit} seconds";
      case ObjectiveType.survive:
        return "Survive ${currentLevel.targetValue} Seconds!";
      // return "Collect ${currentLevel.targetGemType?.name}: $specificGemsCollected / ${currentLevel.targetValue}";
      case ObjectiveType.accuracy:
        return "Reach Score ${currentLevel.targetValue} Without losing a life!";
      case ObjectiveType.combo:
        return "Max Multiplier: ${maxComboReached}x / ${currentLevel.targetValue}x";

      default:
        return "Level Complete!";
    }
  }

  void _showBoosterActivation(String message) {
    setState(() {
      _activeBoosterNotifications.add(message);
    });

    // Cancel any existing timer to prevent overlapping
    _boosterNotifyTimer?.cancel();

    // Hide the notification after 3 seconds
    _boosterNotifyTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _activeBoosterNotifications.remove(message);
        });
      }
    });
  }

  void _handleBoosterPurchase(String type, int cost) async {
    bool currentlyActive = false;
    if (type == "shield") currentlyActive = _shieldActive;
    if (type == "slowmo") currentlyActive = _slowMoActive;
    if (type == "magnet") currentlyActive = _magnetActive;
    if (type == "time") currentlyActive = _extraTimeActive;

    if (currentlyActive) {
      // --- DEACTIVATE & REFUND LOGIC ---

      // 2. Add the coins back to Firestore
      await BubbleGemFirestoreService.addCoins(cost);

      setState(() {
        if (type == "shield") _shieldActive = false;
        if (type == "slowmo") _slowMoActive = false;
        if (type == "magnet") _magnetActive = false;
        if (type == "time") _extraTimeActive = false;
      });

      HapticManager.ligth(); // Light haptic for deactivating
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${type.toUpperCase()} deactivated. $cost coins refunded!",
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      bool success = await BubbleGemFirestoreService.spendCoins(cost);
      if (success) {
        BubbleGemAnalyticsService.logBoosterPurchased(
          boosterType: type,
          cost: cost,
        );
        setState(() {
          if (type == "shield") _shieldActive = true;
          if (type == "slowmo") _slowMoActive = true;
          if (type == "magnet") _magnetActive = true;
          if (type == "time") _extraTimeActive = true;
        });
        // _showBoosterActivation(type);
        HapticManager.heavy();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Not enough coins!")));
      }
    }
  }

  void _exitGame() {
    _stopAllTimers(); // 2. Stop the music
    SoundManager.instance.stopTheme();

    // 3. Navigate back to home
    if (mounted) {
      context.go('/bubble-gem-home');
    }
  }

  void _moveToNextLevel(int nextGlobalId) {
    if (nextGlobalId <= myCustomLevels.length) {
      _stopAllTimers();
      setState(() {
        currentLevel = myCustomLevels.firstWhere((l) => l.id == nextGlobalId);
        gems.clear();
        score = 0;
        comboCount = 0;
        currentMultiplier = 1;
        gemsCleared = 0;
        lives = 3;
        gameOver = false;
        levelCleared = false;
        // _showTierOverlay = false; // Ensure this is hidden
        isSlowed = false;
        // _showLevelIntroOverlay();
        _showLevelIntro = true;
        isPausedByOverlay = true;
      });
    } else {
      context.go('/bubble-gem-home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = tierThemeManager.current;
    screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    return PopScope(
      canPop: false, // Prevent default pop
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _exitGame(); // Use our clean exit logic
      },
      child: Transform.translate(
        offset: Offset(_shakeOffset, _shakeOffset),
        child: Scaffold(
          body: Stack(
            key: _gameAreaKey,
            children: [
              // // 1. Dynamic Background Color
              Container(color: theme.gradient[0]),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: SpawnPainter(activeSplashes)),
                ),
              ),
              //THE FLASH OVERLAY
              if (flashColor != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 50),
                      color: flashColor,
                    ),
                  ),
                ),
              buildDangerZone(),
              RepaintBoundary(
                child: Stack(
                  children: gems.map((gem) => buildGem(gem)).toList(),
                ),
              ),

              ...activeEffects.map((effect) {
                return Stack(
                  children: [
                    // 1. THE SHOCKWAVE (Expanding Ring)
                    Positioned(
                      left: effect.position.dx - (60 * effect.shockwaveScale),
                      top: effect.position.dy - (60 * effect.shockwaveScale),
                      child: IgnorePointer(
                        child: Opacity(
                          opacity: effect.shockwaveOpacity.clamp(0, 1),
                          child: Container(
                            width: 120 * effect.shockwaveScale,
                            height: 120 * effect.shockwaveScale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: effect.color, width: 2),
                              // Add a glow effect
                              boxShadow: [
                                BoxShadow(
                                  color: effect.color.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 2. THE PARTICLES (Flying Bits)
                    ...effect.particles.map(
                      (p) => Positioned(
                        left: p.position.dx,
                        top: p.position.dy,
                        child: Opacity(
                          opacity: p.opacity.clamp(0, 1),
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: p.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),

              buildTopBar(),
              _buildDangerWarning(),
              buildComboIndicator(width, height),
              ...floatingTexts
                  .map(
                    (ft) => Positioned(
                      left: ft.position.dx,
                      top: ft.position.dy,
                      child: Opacity(
                        opacity: ft.opacity.clamp(0, 1),
                        child: Text(
                          ft.text,
                          style: TextStyle(
                            color: ft.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),

              // if (_showLevelIntro)
              //   LevelIntroOverlay(
              //     level: currentLevel.id,
              //     objectiveDescription:
              //         victoryObjectiveText, // Or your custom text
              //     onGotIt: _startLevelAfterIntro,
              //   ),
              // --- TUTORIAL OVERLAY ---
              if (_showTutorial)
                AdvancedTutorialOverlay(
                  steps: _tutorialSteps,
                  currentStep: _currentTutorialStep,
                  onNext: () {
                    if (_currentTutorialStep < _tutorialSteps.length - 1) {
                      setState(() => _currentTutorialStep++);
                    } else {
                      _completeTutorial();
                    }
                  },
                  onBack: () {
                    if (_currentTutorialStep > 0) {
                      setState(() => _currentTutorialStep--);
                    }
                  },
                  onSkip: _completeTutorial,
                ),

              // --- GEM GUIDE OVERLAY ---
              if (_showGemGuide) GemGuideOverlay(onClose: _completeGemGuide),
              if (_showLevelIntro) _buildLevelIntro(),
              // if (_showCaricature)
              //   Positioned.fill(
              //     child: Container(
              //       color: Colors.black45, // Dim the background slightly
              //       child: _buildCaricatureElement(),
              //     ),
              //   ),
              if (_showRewardOverlay) _buildRewardOverlay(),
              if (levelCleared) buildLevelClearedOverlay(screenSize),
              if (_showTierOverlay)
                TierCompletionOverlay(
                  completedTier: currentLevel.tier,
                  onNextTier: () {
                    setState(() {
                      _showTierOverlay = false;
                    });
                    _moveToNextLevel(currentLevel.id + 1);
                  },
                ),
              if (_showGameOverTransition) _buildGameOverTransition(),
              if (gameOver && !_showGameOverTransition)
                buildGameOver(screenSize),
              if (_showRetryOverlay) buildRetryOverlay(),
              _buildBoosterNotification(),
              if (_showChallengeReward && _completedChallengeTitle != null)
                ChallengeRewardOverlay(
                  challengeTitle: _completedChallengeTitle!,
                  onClaimed: () async {
                    if (_completedChallengeId != null) {
                      // We need to find the reward amount.
                      // You can fetch it from ChallengeDataService based on the ID.
                      final challengeDef = ChallengeDataService.allChallenges
                          .firstWhere((c) => c.id == _completedChallengeId);

                      await BubbleGemFirestoreService.claimChallengeReward(
                        _completedChallengeId!,
                        challengeDef.coinReward,
                      );
                      await BubbleGemAnalyticsService.logRewardClaimed(
                        challengeId: _completedChallengeId!,
                        coinAmount: challengeDef.coinReward,
                      );
                    }
                    await Future.delayed(const Duration(seconds: 3));

                    setState(() {
                      _showChallengeReward = false;
                      _completedChallengeTitle = null;
                      _completedChallengeId = null;
                      isPausedByOverlay = false;
                    });

                    // Resume the game loops if the level isn't over
                    if (!gameOver && !levelCleared) {
                      resumeGame(); // Or your resume logic
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: _exitGame,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    constraints: BoxConstraints(),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: whitecolor),
                    ),
                    child: const Icon(
                      Icons.home_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54, // Very subtle
                    borderRadius: BorderRadius.circular(30),
                    // border: Border.all(
                    //   color: purplecolor.withValues(alpha: 0.2),
                    //   width: 1.5,
                    // ),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/minigame3/bubble_gem_storm/icons/coin.png',
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "$_localCoins",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Baloo2',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  key: _scoreKey,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: BouncingWidget(
                    value: score + gemsCleared,
                    child: Text(
                      currentObjectiveText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Baloo2',
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                // InkWell(
                //   onTap: _exitGame,
                //   child: Container(
                //     padding: EdgeInsets.all(5),
                //     constraints: BoxConstraints(),
                //     decoration: BoxDecoration(
                //       shape: BoxShape.circle,
                //       border: Border.all(color: whitecolor),
                //     ),
                //     child: const Icon(
                //       Icons.home_rounded,
                //       color: Colors.white,
                //       size: 30,
                //     ),
                //   ),
                // ),
                // Container(
                //   key: _scoreKey,
                //   padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                //   decoration: BoxDecoration(
                //     color: Colors.black54,
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                //   child: BouncingWidget(
                //     value: score + gemsCleared,
                //     child: Text(
                //       currentObjectiveText,
                //       style: const TextStyle(
                //         fontWeight: FontWeight.bold,
                //         fontFamily: 'Baloo2',
                //       ),
                //     ),
                //   ),
                // ),
                Container(
                  key: _livesKey,
                  child: Row(
                    children: List.generate(
                      3,
                      (index) => Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: BouncingWidget(
                          value: lives,
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index < lives
                                  ? Colors.red[800]
                                  : Colors.transparent,
                              border: index < lives
                                  ? Border.all()
                                  : Border.all(color: Colors.white),
                            ),
                            child: Icon(
                              index < lives
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: Colors.white,
                              // size: 25,
                            ),
                          ),
                        ),
                        //Icon(Icons.favorite, color: Colors.red[800]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerWarning() {
    if (_activeWarning == null) return const SizedBox.shrink();

    Color warningColor;
    IconData warningIcon;

    switch (_warningType) {
      case GemType.bomb:
        warningColor = Colors.orangeAccent;
        warningIcon = Icons.bolt;
        break;
      case GemType.poison:
        warningColor = Colors.greenAccent;
        warningIcon = Icons.heart_broken;
        break;
      case GemType.dizzy:
        warningColor = Colors.purpleAccent;
        warningIcon = Icons.cyclone;
        break;
      case GemType.gravity:
        warningColor = Colors.deepOrange;
        warningIcon = Icons.south;
        break;
      default:
        warningColor = Colors.redAccent;
        warningIcon = Icons.warning;
    }

    return Positioned(
      top: 130, // Just below the top bar
      left: 20,
      right: 20,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value.clamp(0, 1),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: warningColor, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: warningColor.withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(warningIcon, color: warningColor, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _activeWarning!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Baloo2',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLevelIntro() {
    String tierName = "";
    int totalInTier = 0;

    switch (currentLevel.tier) {
      case GameTier.tier1:
        tierName = "Tier 1: Score Rush";
        totalInTier = 15;
        break;
      case GameTier.tier2:
        tierName = "Tier 2: Survival";
        totalInTier = 20;
        break;
      case GameTier.tier3:
        tierName = "Tier 3: Gem Master";
        totalInTier = 30;
        break;
    }

    return LevelIntroOverlay(
      tierName: tierName,
      localLevel: currentLevel.localLevel,
      totalInTier: totalInTier,
      objectiveDescription: victoryObjectiveText,
      onGotIt: _startLevelAfterIntro,
      onBuyBooster: _handleBoosterPurchase,
      activeBoosters: {
        if (_shieldActive) "shield",
        if (_slowMoActive) "slowmo",
        if (_magnetActive) "magnet",
        if (_extraTimeActive) "time",
      },
      isTimeObjective:
          currentLevel.objective == ObjectiveType.survive ||
          currentLevel.objective == ObjectiveType.clearGems,
    );
  }

  Widget buildGem(Gem gem) {
    // Define fixed gradients for specific types
    Gradient gemGradient;
    Color auraColor = Colors.transparent;
    bool hasAura = false;

    switch (gem.type) {
      case GemType.poison:
        hasAura = true;
        auraColor = Colors.greenAccent;
        gemGradient = const RadialGradient(
          colors: [Colors.green, Colors.black],
        );
        break;
      case GemType.dizzy:
        hasAura = true;
        auraColor = Colors.purpleAccent;
        gemGradient = const RadialGradient(
          colors: [Colors.purple, Colors.black],
        );
        break;
      case GemType.gravity:
        hasAura = true;
        auraColor = Colors.deepOrange;
        gemGradient = const RadialGradient(
          colors: [Colors.deepOrange, Colors.black],
        );
        break;
      case GemType.frozen:
        gemGradient = const RadialGradient(
          colors: [whitecolor, frozeng],
          center: Alignment(-0.3, -0.3),
        );
        break;
      case GemType.bomb:
        gemGradient = const RadialGradient(
          colors: [Color(0xFF555555), Color(0xFF000000)],
          center: Alignment(-0.3, -0.3),
        );
        break;
      case GemType.rainbow:
        // Rainbow remains dynamic/multi-colored
        gemGradient = const SweepGradient(
          colors: [
            Colors.red,
            Colors.yellow,
            Colors.green,
            Colors.blue,
            Colors.purple,
            Colors.red,
          ],
        );
        break;

      case GemType.normal:
      default:
        // Normal gems use a fixed gradient based on their assigned base color
        gemGradient = RadialGradient(
          colors: [
            Color.lerp(gem.color, Colors.white, 0.5)!, // Highlight color
            gem.color, // Main color
            Color.lerp(gem.color, Colors.black, 0.3)!, // Shadow color
          ],
          center: const Alignment(-0.3, -0.3),
        );
        break;
    }
    double rotationAngle = 0;
    if (gem.waveAmplitude > 0) {
      // Calculate tilt based on cosine (the derivative of sine)
      rotationAngle =
          cos((gem.position.dy * gem.waveFrequency) + gem.phase) * 0.2;
    }
    if (gem.type == GemType.golden) {
      gemGradient = const RadialGradient(
        colors: [Colors.white, Colors.orange, Colors.brown],
        center: Alignment(-0.3, -0.3),
      );
    } else if (gem.type == GemType.freezePowerUp) {
      gemGradient = RadialGradient(
        colors: [Colors.white, Colors.blue.withOpacity(0.5), Colors.cyan],
        center: const Alignment(-0.3, -0.3),
      );
    }
    bool isBomb = gem.type == GemType.bomb;
    double baseDimension = 50.0;
    double currentSize = baseDimension * gem.scale;
    return Stack(
      children: [
        if (hasAura)
          Positioned(
            left: gem.position.dx - 35,
            top: gem.position.dy - 35,
            child: BombAura(
              size: 50,
              color: auraColor,
            ), // Modified BombAura below
          ),
        if (gem.type == GemType.golden)
          ...gem.trail.asMap().entries.map((entry) {
            int idx = entry.key;
            Offset pos = entry.value;
            return Positioned(
              left: pos.dx - 30,
              top: pos.dy - 20,
              child: Opacity(
                opacity: 0.5 - (idx * 0.1), // Fade out the trail
                child: Transform.scale(
                  scale: 1.0 - (idx * 0.1), // Shrink the trail
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            );
          }),
        if (isBomb)
          Positioned(
            left: gem.position.dx - 35, //Slightly larger than the gem
            top: gem.position.dy - 35,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.2),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOutSine,
              builder: (context, value, child) {
                return Opacity(
                  opacity: 0.6 - (value - 0.8), // Fades as it expands
                  child: Transform.scale(
                    scale: value * gem.scale,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.8),
                            blurRadius: 20,
                            spreadRadius: 10,
                          ),
                        ],
                        border: Border.all(color: Colors.orange, width: 2),
                      ),
                    ),
                  ),
                );
              },
              onEnd:
                  () {}, // TweenAnimationBuilder automatically repeats if you toggle a state,
              // but for a simple pulse, this works well.
            ),
          ),

        Positioned(
          left: gem.position.dx - 25, // Assuming 50px width
          top: gem.position.dy - 25,
          child: Transform.rotate(
            angle: rotationAngle,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.elasticOut, // Gives a nice "bounce" when spawning
              builder: (context, appearScale, child) {
                double jitterX = isBomb ? (Random().nextDouble() * 2 - 1) : 0;
                double jitterY = isBomb ? (Random().nextDouble() * 2 - 1) : 0;
                return Transform.translate(
                  offset: Offset(jitterX, jitterY),
                  child: Transform.scale(
                    scale: appearScale * gem.scale,
                    child: child,
                  ),
                );
              },

              child: GestureDetector(
                onTap: () => tapGem(gem),
                child: Container(
                  width: baseDimension, //gem.type == GemType.golden ? 35 : 50,
                  height: baseDimension, //gem.type == GemType.golden ? 35 : 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: gemGradient,
                    boxShadow: [
                      BoxShadow(
                        color: isBomb
                            ? Colors.red.withOpacity(0.8)
                            : gem.type == GemType.golden
                            ? Colors.yellow
                            : Colors.white.withOpacity(0.3),
                        blurRadius: isBomb ? 20 : 15,
                        spreadRadius: isBomb
                            ? 8
                            : (gem.type == GemType.golden ? 5 : 2),

                        offset: const Offset(0, 0),
                      ),
                    ],
                    border: isBomb
                        ? Border.all(color: Colors.orangeAccent, width: 2)
                        : gem.type == GemType.frozen
                        ? Border.all(color: Colors.white, width: 1)
                        : null,
                  ),
                  child: Center(
                    child: Transform.scale(
                      scale: gem.scale < 0.8 ? 0.8 : 1.0,
                      child: gem.type == GemType.bomb
                          ? const Icon(Icons.bolt, color: Colors.orange)
                          : gem.type == GemType.frozen && gem.tapsRequired > 1
                          ? const Icon(
                              Icons.ac_unit,
                              color: Colors.white,
                              size: 25,
                            )
                          : gem.type == GemType.normal
                          ? Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 25,
                            )
                          : gem.type == GemType.rainbow
                          ? Icon(Icons.looks, color: Colors.white, size: 25)
                          : gem.type == GemType.golden
                          ? Icon(
                              Icons.star_border,
                              color: Colors.white,
                              size: 20,
                            )
                          : gem.type == GemType.freezePowerUp
                          ? Icon(
                              Icons.timer_outlined,
                              color: Colors.white,
                              size: 25,
                            )
                          : gem.type == GemType.poison
                          ? Icon(
                              Icons.heart_broken_outlined,
                              color: Colors.white,
                            )
                          : gem.type == GemType.dizzy
                          ? Icon(Icons.cyclone, color: Colors.white)
                          : gem.type == GemType.gravity
                          ? Icon(Icons.south, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDangerZone() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      top: 0,
      left: 0,
      right: 0,
      height: dangerZoneHeight,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: dangerActive
                ? [
                    Colors.red.withOpacity(.6),
                    Colors.red.withOpacity(.15),
                    Colors.transparent,
                  ]
                : [
                    Colors.blue.withOpacity(.5),
                    Colors.blue.withOpacity(.15),
                    Colors.transparent,
                  ],
          ),
        ),
      ),
    );
  }

  Widget buildComboIndicator(double width, double height) {
    if (comboCount < 2 && activeMotivation == null)
      return const SizedBox.shrink();

    // Determine color based on multiplier
    Color comboColor = Colors.white;
    if (currentMultiplier >= 5)
      comboColor = Colors.redAccent;
    else if (currentMultiplier >= 3)
      comboColor = Colors.orangeAccent;
    else if (currentMultiplier >= 2)
      comboColor = Colors.yellowAccent;

    return Positioned(
      top: height * 0.25,
      right: width * 0.25,
      child: ScaleTransition(
        scale: _comboPopController,

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Multiplier Badge
            Row(
              children: [
                // "COMBO" Labelwith spacing
                Text(
                  "COMBO",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w900,
                    fontSize: width * 0.09,
                    letterSpacing: 4,
                    fontFamily: 'Baloo2',
                  ),
                ),
                const SizedBox(width: 8),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.white, comboColor, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    "x$currentMultiplier",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: width * 0.1,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Baloo2',
                      height: 1.0,
                      shadows: [
                        Shadow(
                          color: comboColor.withOpacity(0.8),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Small count indicator
            Text(
              "$comboCount HITS",
              style: TextStyle(
                color: comboColor,
                fontSize: width * 0.035,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (activeMotivation != null)
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.cyanAccent, Colors.blueAccent],
                ).createShader(bounds),
                child: Text(
                  activeMotivation!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: width * 0.06, // BIG SIZE
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Baloo2',
                    fontStyle: FontStyle.italic,
                    shadows: [
                      Shadow(
                        color: Colors.blue.withOpacity(0.8),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        // ),
      ),
    );
  }

  Widget buildLevelClearedOverlay(Size screenSize) {
    double width = screenSize.width;
    double height = screenSize.height;
    return FutureBuilder<int>(
      future: BubbleGemFirestoreService.getLevelAttempts(currentLevel.id),
      builder: (context, snapshot) {
        // Default to 1 star if loading or error
        int attempts = snapshot.data ?? 1;
        int starCount = attempts <= 1 ? 3 : (attempts < 5 ? 2 : 1);
        int coinReward = starCount * 10;
        return SafeArea(
          child: Container(
            margin: EdgeInsets.only(
              left: width * 0.05,
              right: width * 0.05,
              bottom: height * 0.02,
            ),
            padding: EdgeInsets.all(width * 0.05),
            decoration: BoxDecoration(
              color: bg,
              border: Border.all(color: Colors.white10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "LEVEL COMPLETE!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: width * 0.12,
                      color: whitecolor,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Baloo2',
                    ),
                  ),
                  // --- STAR SYSTEM UI ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      bool isEarned = index < starCount;
                      double yOffset = (index == 1) ? -10.0 : 10.0;
                      return TweenAnimationBuilder(
                        duration: Duration(milliseconds: 600 + (index * 200)),
                        tween: Tween<double>(begin: 0, end: 1),
                        curve: Curves.elasticOut,
                        builder: (context, double value, child) {
                          return Transform.translate(
                            offset: Offset(0, yOffset),

                            child: Icon(
                              Icons.star_rounded,
                              size: index == 1
                                  ? width * 0.2
                                  : width * 0.15, // Middle star is larger
                              color: isEarned ? Colors.amber : Colors.white,
                              shadows: isEarned
                                  ? [
                                      Shadow(
                                        color: Colors.orange.withOpacity(0.5),
                                        blurRadius: 15,
                                      ),
                                    ]
                                  : [],
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/minigame3/bubble_gem_storm/icons/coin.png',
                        width: 18,
                      ),
                      // const Icon(
                      //   Icons.monetization_on,
                      //   color: Colors.amber,
                      //   size: 20,
                      // ),
                      const SizedBox(width: 5),
                      Text(
                        "+$coinReward COINS",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Baloo2',
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),

                  // Text(
                  //   "$attempts ${attempts == 1 ? 'ATTEMPT' : 'ATTEMPTS'}",
                  //   style: const TextStyle(
                  //     color: Colors.white54,
                  //     fontSize: 14,
                  //     fontFamily: 'Baloo2',
                  //     letterSpacing: 1.2,
                  //   ),
                  // ),
                  SizedBox(height: height * 0.02),
                  Container(
                    padding: EdgeInsets.all(width * 0.03),
                    decoration: BoxDecoration(
                      // color: gameoverCard,
                      gradient: LinearGradient(
                        colors: [Colors.white24, Colors.transparent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.white10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Your Target",
                          style: TextStyle(
                            color: title1,
                            fontSize: width * 0.04,
                            fontFamily: 'Baloo2',
                          ),
                        ),
                        SizedBox(height: height * 0.001),
                        Text(
                          currentObjectiveText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: whitecolor,
                            fontSize: width * 0.07,
                            fontFamily: 'Baloo2',
                          ),
                        ),

                        SizedBox(height: height * 0.01),

                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 5,
                          ),
                          decoration: BoxDecoration(
                            color: bg.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.track_changes,
                                color: Colors.amberAccent,
                                size: width * 0.1,
                              ),
                              // const SizedBox(height: 10),
                              Text(
                                victoryObjectiveText,
                                textAlign: TextAlign.center,
                                // "${widget.game.targetScore}",
                                style: TextStyle(
                                  color: whitecolor,
                                  fontSize: width * 0.07,
                                  fontFamily: 'Baloo2',
                                ),
                              ),
                              SizedBox(height: height * 0.001),
                              Text(
                                "Final Target",
                                style: TextStyle(
                                  color: title1,
                                  fontSize: width * 0.04,
                                  fontFamily: 'Baloo2',
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.02),

                        InkWell(
                          onTap: () {
                            int currentId = currentLevel.id;
                            int nextId =
                                currentId +
                                1; // 1. Determine if a tier was just finished
                            bool isTierFinished =
                                (currentLevel.tier == GameTier.tier1 &&
                                    currentLevel.localLevel == 20) ||
                                (currentLevel.tier == GameTier.tier2 &&
                                    currentLevel.localLevel == 30) ||
                                (currentLevel.tier == GameTier.tier3 &&
                                    currentLevel.localLevel == 50);

                            if (isTierFinished) {
                              // Show Tier Completion as before
                              setState(() {
                                levelCleared = false;
                                _showTierOverlay = true;
                              });
                              context.pushReplacement(
                                '/bubble-gem-zone?completedTier=${currentLevel.tier.index}',
                              );
                            } else {
                              // 2. Navigate back to Map with the "justUnlocked" flag
                              _stopAllTimers();
                              final tierIndex = currentLevel.tier.index;
                              final title =
                                  tierThemes[currentLevel.tier]?.name ??
                                  "Adventure"; // We pass the nextId as the unlocked level to trigger the animation on the map
                              context.pushReplacement(
                                '/bubble-gem-map?unlockedLevel=$nextId&tier=$tierIndex&title=$title&animateFrom=${currentLevel.id}',
                              );
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                              // horizontal: 70,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [title1, title2],
                                // begin: Alignment.topCenter,
                                // end: Alignment.bottomCenter,
                                // stops: [0.3, 0.6],
                              ),
                            ),
                            child: Text(
                              "NEXT LEVEL",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: width * 0.05,
                                color: whitecolor,
                                fontFamily: 'Baloo2',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.02),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                                // horizontal: 70,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: () {
                              context.go('/bubble-gem-home');
                            },
                            child: Text(
                              "Home",
                              style: TextStyle(
                                fontSize: width * 0.05,
                                color: Colors.black,
                                fontFamily: 'Baloo2',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRewardOverlay() {
    return Positioned.fill(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. THEASSET BACKGROUND
          Positioned.fill(
            child: Image.asset(
              'assets/minigame3/bubble_gem_storm/icons/rewardBg.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. DIMMER (Optional:to make the character pop)
          Positioned.fill(child: Container(color: Colors.black26)),

          // 3. THE CENTRAL IMAGE & TEXT
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // YOUR MAIN IMAGE (Character/Chest/Badge)
                    Image.asset(
                      'assets/minigame3/bubble_gem_storm/icons/reward.png',
                      height: 280,
                    ),
                    const SizedBox(height: 20),
                    // VICTORY TEXT
                    Text(
                      "FANTASTIC!",
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Baloo2',
                        fontStyle: FontStyle.italic,
                        shadows: [
                          Shadow(
                            color: Colors.orange,
                            blurRadius: 15,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverTransition() {
    return Positioned.fill(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. THE LOSS ASSET BACKGROUND
          Positioned.fill(
            child: Image.asset(
              'assets/minigame3/bubble_gem_storm/icons/rewardBg.png', // REPLACE WITH YOUR LOSS BG
              fit: BoxFit.cover,
            ),
          ),

          // 2. DARK OVERLAY (Tomake it feel like a defeat)
          Positioned.fill(child: Container(color: Colors.black45)),

          // 3. THE CENTRAL IMAGE & TEXT
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.bounceOut, // A "heavy" bounce for a loss
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // YOUR LOSS IMAGE (Sad character / Broken Gem)
                    Image.asset(
                      'assets/minigame3/bubble_gem_storm/icons/gameover.png',
                      height: 250,
                    ),
                    const SizedBox(height: 20),
                    // DEFEAT TEXT
                    const Text(
                      "OH NO!",
                      style: TextStyle(
                        fontSize: 55,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Baloo2',
                        shadows: [
                          Shadow(
                            color: Colors.red,
                            blurRadius: 20,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildGameOver(Size screenSize) {
    double width = screenSize.width;
    double height = screenSize.height;
    BubbleGemFirestoreService.updateHighScore(score);
    return SafeArea(
      child: Center(
        child: Container(
          margin: EdgeInsets.only(
            left: width * 0.05,
            right: width * 0.05,
            bottom: height * 0.02,
          ),
          padding: EdgeInsets.all(width * 0.05),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: bg,
            // gradient: LinearGradient(colors: [bg, Colors.transparent]),
            border: Border.all(color: Colors.white24),
            // border: Border.all(color: Colors.white60),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Game Over",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: whitecolor,
                  fontSize: width * 0.15,
                  fontFamily: 'Baloo2',
                ),
              ),
              SizedBox(height: height * 0.01),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  // bool isEarned = index < starCount;
                  double yOffset = (index == 1) ? -10.0 : 10.0;
                  return TweenAnimationBuilder(
                    duration: Duration(milliseconds: 600 + (index * 200)),
                    tween: Tween<double>(begin: 0, end: 1),
                    curve: Curves.elasticOut,
                    builder: (context, double value, child) {
                      return Transform.translate(
                        offset: Offset(0, yOffset),

                        child: Icon(
                          Icons.star_rounded,
                          size: index == 1
                              ? width * 0.2
                              : width * 0.15, // Middle star is larger
                          color: Colors.white,
                          // shadows: isEarned
                          //     ? [
                          //         Shadow(
                          //           color: Colors.orange.withOpacity(0.5),
                          //           blurRadius: 15,
                          //         ),
                          //       ]
                          //     : [],
                        ),
                      );
                    },
                  );
                }),
              ),
              SizedBox(height: height * 0.02),
              Container(
                padding: EdgeInsets.all(width * 0.03),
                decoration: BoxDecoration(
                  // color: gameoverCard,
                  gradient: LinearGradient(
                    colors: [Colors.white24, Colors.transparent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      "Your Target",
                      style: TextStyle(
                        color: title1,
                        fontSize: width * 0.04,
                        fontFamily: 'Baloo2',
                      ),
                    ),
                    SizedBox(height: height * 0.001),
                    Text(
                      currentObjectiveText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.07,
                        fontFamily: 'Baloo2',
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: bg.withValues(alpha: 0.1),
                        border: Border.all(color: Colors.white10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: StreamBuilder(
                        stream: BubbleGemFirestoreService.highScoreStream(),
                        builder: (context, snapshot) {
                          final highScore = snapshot.data ?? 0;
                          return Column(
                            children: [
                              Icon(
                                Icons.track_changes,
                                color: Colors.amberAccent,
                                size: width * 0.1,
                              ),

                              Text(
                                victoryObjectiveText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: whitecolor,
                                  fontSize: width * 0.07,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Baloo2',
                                ),
                              ),
                              SizedBox(height: height * 0.001),
                              Text(
                                "Final Target",
                                style: TextStyle(
                                  color: title1,
                                  fontSize: width * 0.04,
                                  fontFamily: 'Baloo2',
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    Column(
                      children: [
                        InkWell(
                          onTap: handleRestart,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                              // horizontal: 70,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [title1, title2],
                                // begin: Alignment.topCenter,
                                // end: Alignment.bottomCenter,
                                // stops: [0.3, 0.6],
                              ),
                            ),
                            child: Text(
                              "Play Again",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: width * 0.05,
                                color: whitecolor,
                                fontFamily: 'Baloo2',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: height * 0.01),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    // horizontal: 70,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: () {
                                  context.go('/bubble-gem-home');
                                },
                                child: Text(
                                  "Home",
                                  style: TextStyle(
                                    fontSize: width * 0.05,
                                    color: Colors.black,
                                    fontFamily: 'Baloo2',
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10,
                                    // horizontal: 70,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showRetryOverlay = true;
                                  });
                                  ;
                                },
                                child: Text(
                                  "Retry",
                                  style: TextStyle(
                                    fontSize: width * 0.05,
                                    color: Colors.black,
                                    fontFamily: 'Baloo2',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.01),
                        // Inside buildGameOver() -> Column -> Row(where Home and Retry buttons are)
                        StreamBuilder<int>(
                          stream: BubbleGemFirestoreService.coinsStream(),
                          builder: (context, snapshot) {
                            final currentCoins = snapshot.data ?? 0;
                            const int retryCost = 50;

                            // Onlyshow the button if they have enough coins
                            if (currentCoins < retryCost)
                              return const SizedBox.shrink();

                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 15,
                              ), // Space above the other buttons
                              child: InkWell(
                                onTap: handleCoinRetry,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    // color: Colors.amber.withOpacity(0.2),
                                    gradient: LinearGradient(
                                      colors: [title1, title2],
                                    ),
                                    // border: Border.all(
                                    //   color: Colors.amber,
                                    //   width: 2,
                                    // ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "RETRY  -$retryCost🪙",
                                        style: TextStyle(
                                          fontSize: width * 0.045,
                                          color: whitecolor,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Baloo2',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoosterNotification() {
    if (_activeBoosterNotifications.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: screenSize.height * 0.25, // Start a bit higher
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _activeBoosterNotifications.map((msg) {
          return Padding(
            padding: const EdgeInsets.only(
              bottom: 10,
            ), // Space between notifications
            child: TweenAnimationBuilder<double>(
              key: ValueKey(msg), // Unique key for each message
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)), // Slide up effect
                    child: Transform.scale(
                      scale: 0.9 + (value * 0.1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.greenAccent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.greenAccent.withOpacity(0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.bolt,
                              color: Colors.greenAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              // Prevents horizontal overflow if text is long
                              child: Text(
                                msg,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Baloo2',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget buildRetryOverlay() {
    return Material(
      // Ensure text styles work correctly
      color: Colors.black87,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E), // Use your 'bg' color variable here
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite, color: Colors.redAccent, size: 60),
              const SizedBox(height: 20),
              const Text(
                "Second Chance!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontFamily: 'Baloo2',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Watch a short video to get 3 extra lives and continue your progress!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () =>
                          setState(() => _showRetryOverlay = false),
                      child: const Text(
                        "No Thanks",
                        style: TextStyle(color: Colors.white60, fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: handleWatchAdRetry,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text(
                        "RESUME",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BombAura extends StatefulWidget {
  final double size;
  final Color color;
  const BombAura({
    super.key,
    required this.size,
    this.color = Colors.redAccent,
  });

  @override
  State<BombAura> createState() => _BombAuraState();
}

class _BombAuraState extends State<BombAura>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true); // Makes it pulse inand out
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size * (1.2 + (_controller.value * 0.3)), // Pulses size
          height: widget.size * (1.2 + (_controller.value * 0.3)),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(
                  0.6 - (_controller.value * 0.3),
                ),
                blurRadius: 20 * _controller.value,
                spreadRadius: 10 * _controller.value,
              ),
            ],
            border: Border.all(color: widget.color.withOpacity(0.5), width: 2),
          ),
        );
      },
    );
  }
}

class BouncingWidget extends StatelessWidget {
  final Widget child;
  final int value; // The animation triggers when this changes

  const BouncingWidget({super.key, required this.child, required this.value});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(
        value,
      ), // Crucial: tells Flutter to restart animationwhen value changes
      tween: Tween(begin: 1.3, end: 1.0),
      duration: const Duration(milliseconds: 900),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: child,
    );
  }
}

class Particle {
  Offset position;
  Offset velocity;
  double opacity = 1.0;
  final Color color;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
  });

  void update() {
    position += velocity;
    velocity *= 0.95; // Friction: particles slow down
    opacity -= 0.02; // Fade out
  }
}

class PopEffect {
  final Offset position;
  final Color color;
  final List<Particle> particles;
  double shockwaveScale = 0.1;
  double shockwaveOpacity = 1.0;
  final DateTime createdAt = DateTime.now();

  PopEffect({required this.position, required this.color})
    : particles = List.generate(12, (i) {
        // Create particles flying in a circle
        double angle = (i * 30) * (3.14159 / 180);
        double speed = 2.0 + (i % 3);
        return Particle(
          position: position,
          velocity: Offset(math.cos(angle) * speed, math.sin(angle) * speed),
          color: color,
        );
      });
}

enum GemType {
  normal,
  bomb,
  rainbow,
  frozen,
  golden,
  freezePowerUp,
  poison, // Loses 1 Life
  dizzy,
  gravity,
}

enum ObjectiveType { score, clearGems, survive, collection, accuracy, combo }

class FloatingText {
  final String text;
  Offset position;
  double opacity = 1.0;
  final Color color;
  FloatingText({
    required this.text,
    required this.position,
    required this.color,
  });
}

class Gem {
  final int id;
  Offset position;
  double speed;
  Color color;
  GemType type;
  int tapsRequired;
  final double scale;
  List<Offset> trail = [];
  final double waveAmplitude;
  final double waveFrequency; // How fast it oscillates
  final double phase; // Random start point so they don't all move in sync
  final double initialX;

  Gem({
    required this.id,
    required this.position,
    required this.speed,
    required this.color,
    required this.type,
    required this.tapsRequired,
    required this.scale,
    this.waveAmplitude = 0, // Default 0 (straight)
    this.waveFrequency = 0.05,
    required this.phase,
    required this.initialX,
  });
}

class SpawnSplash {
  final Offset position;
  final Color color;
  double radius = 10.0;
  double opacity = 1.0;
  final DateTime createdAt = DateTime.now();

  SpawnSplash({required this.position, required this.color});
}

// In your _GemGameScreenState, add this list:
final List<SpawnSplash> activeSplashes = [];

class SpawnPainter extends CustomPainter {
  final List<SpawnSplash> splashes;
  SpawnPainter(this.splashes);

  @override
  void paint(Canvas canvas, Size size) {
    for (var splash in splashes) {
      final paint = Paint()
        ..color = splash.color.withOpacity(splash.opacity.clamp(0, 1))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      // Draw an elliptical ripple (perspective)
      canvas.drawOval(
        Rect.fromCenter(
          center: splash.position,
          width: splash.radius * 2.5,
          height: splash.radius * 0.8,
        ),
        paint,
      );

      // Draw a subtle glow
      final glowPaint = Paint()
        ..color = splash.color.withOpacity(splash.opacity * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawOval(
        Rect.fromCenter(
          center: splash.position,
          width: splash.radius * 2,
          height: splash.radius * 0.5,
        ),
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(SpawnPainter oldDelegate) => true;
}

class GemGuideOverlay extends StatelessWidget {
  final VoidCallback onClose;

  const GemGuideOverlay({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [Color(0xFF0F2027), Color(0xFF203A43)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.cyanAccent, width: 2),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "GEMS GUIDE",
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                _buildGemInfo(
                  icon: Icons.auto_awesome_outlined,
                  color: normalg,
                  title: "Normal Gem",
                  description:
                      "Tap to pop and earn 1 point. Basic scoring gem.",
                ),

                _buildGemInfo(
                  icon: Icons.ac_unit,
                  color: frozeng,
                  title: "Frozen Gem",
                  description: "Needs 2 taps to break. Worth 2 points.",
                ),

                _buildGemInfo(
                  icon: Icons.bolt,
                  color: bombg,
                  title: "Bomb Gem",
                  description:
                      "Explodes nearby gems. 0 points. Safe to let pass.",
                ),

                _buildGemInfo(
                  icon: Icons.looks,
                  color: Colors.purple,
                  title: "Rainbow Gem",
                  description:
                      "Appears in different colors.Removes ALL gems of one random type instantly.",
                ),
                _buildGemInfo(
                  icon: Icons.stars,
                  color: Colors.amber,
                  title: "Golden Gem",
                  description:
                      "Extremely fast! Worth 20 score points..Catch fast!",
                ),

                _buildGemInfo(
                  icon: Icons.timer_outlined,
                  color: Colors.cyanAccent,
                  title: "Freeze Power-up",
                  description:
                      "Slows down time for 5 seconds. Catch your breath!",
                ),

                _buildGemInfo(
                  icon: Icons.heart_broken_outlined, // Alternative for Skull
                  color: Colors.greenAccent,
                  title: "Poison Gem",
                  description:
                      "WARNING: Tapping loses 1 LIFE! Let it pass safely.",
                ),
                _buildGemInfo(
                  icon: Icons.cyclone,
                  color: Colors.purple,
                  title: "Dizzy Gem",
                  description: "Causes confusion and -30 score penalty!",
                ),
                _buildGemInfo(
                  icon: Icons.south,
                  color: Colors.deepOrange,
                  title: "Gravity Gem",
                  description: "Makes all gems fall much faster for 3 seconds!",
                ),
                const SizedBox(height: 30),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: onClose,
                  child: const Text(
                    "GOT IT!",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGemInfo({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black54,
        border: Border.all(color: color.withOpacity(0.7)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TierCompletionOverlay extends StatelessWidget {
  final GameTier completedTier;
  final VoidCallback onNextTier;

  const TierCompletionOverlay({
    super.key,
    required this.completedTier,
    required this.onNextTier,
  });

  @override
  Widget build(BuildContext context) {
    String nextTierName = "";
    String completedName = "";
    String nextZoneTitle = "";

    switch (completedTier) {
      case GameTier.tier1:
        completedName = "Tier 1: Score Rush";
        nextTierName = "Tier 2: Survival";
        nextZoneTitle = "Neon Heights";
        break;
      case GameTier.tier2:
        completedName = "Tier 2: Survival";
        nextTierName = "Tier 3: GemMaster";
        nextZoneTitle = "Galaxy Depths";
        break;
      case GameTier.tier3:
        completedName = "Tier 3: Gem Master";
        nextTierName = "ALL TIERS CLEARED!";
        nextZoneTitle = "ALL ZONE CLEARED!";
        break;
    }

    return Container(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.5),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: const Icon(
                Icons.stars_rounded,
                color: Colors.amber,
                size: 100,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "TIER COMPLETED!",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: title1,
                fontFamily: 'Baloo2',
                letterSpacing: 2,
              ),
            ),
            Text(
              completedName,
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.greenAccent.withOpacity(0.5),
                ), // Green for unlock
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.map_outlined,
                        color: Colors.greenAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "NEW MAP UNLOCKED",
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    nextZoneTitle.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Baloo2',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.greenAccent.withOpacity(0.5),
                ), // Green for unlock
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.map_outlined,
                        color: Colors.greenAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "NEW TIER UNLOCKED",
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    nextTierName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Baloo2',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            InkWell(
              onTap: onNextTier,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(colors: [title1, title2]),
                ),
                child: const Text(
                  "CONTINUE ADVENTURE",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LevelIntroOverlay extends StatefulWidget {
  final String tierName;
  final int localLevel;
  final int totalInTier;
  final String objectiveDescription;
  final VoidCallback onGotIt;
  final Function(String boosterType, int cost) onBuyBooster;
  final Set<String> activeBoosters;
  final bool isTimeObjective;

  const LevelIntroOverlay({
    super.key,
    required this.objectiveDescription,
    required this.onGotIt,
    required this.tierName,
    required this.localLevel,
    required this.totalInTier,
    required this.onBuyBooster,
    required this.activeBoosters,
    required this.isTimeObjective,
  });

  @override
  State<LevelIntroOverlay> createState() => _LevelIntroOverlayState();
}

class _LevelIntroOverlayState extends State<LevelIntroOverlay> {
  // 1. Track which booster is currently selected to show its description
  String? _selectedBoosterKey; // 2. The Map of descriptions
  String? _serverFreeBooster;
  Map<String, String> get _dynamicBoosterDescriptions {
    bool isSurvival = widget.objectiveDescription.toLowerCase().contains(
      "survive",
    );

    return {
      "shield":
          "🛡️ SHIELD: Protects you from one life loss. Stay in the game longer!",
      "slowmo":
          "⏳ SLOW-MO: Slows down all falling gems by 30% for easier popping.",
      "magnet": "🧲 MAGNET: Automatically bursts ✨gems for 10 secs.",
      "time": isSurvival
          ? "⏱️ QUICK FINISH: Reduces the survival time by 15 seconds. Win faster!"
          : "⏱️ EXTRA TIME: Adds 15 extra seconds to the clock. Great for high scores!",
    };
  }

  @override
  void initState() {
    super.initState();
    _fetchFreeBooster();
  }

  void _fetchFreeBooster() async {
    final free = await BubbleGemFirestoreService.getFreeBooster();
    if (mounted) setState(() => _serverFreeBooster = free);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white24),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TIER NAME DISPLAY
              Text(
                widget.tierName.toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color: title2, // Using 'title2'
                  fontFamily: 'Baloo2',
                ),
              ),
              Text(
                "LEVEL ${widget.localLevel}",
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Baloo2',
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white24, Colors.transparent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.track_changes,
                      size: 40,
                      color: Colors.amberAccent,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.objectiveDescription,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: 'Baloo2',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Target',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: title1, // Using 'title1'
                        fontFamily: 'Baloo2',
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "PRE-GAME BOOSTERS",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10), // BOOSTER GRID
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildBoosterItem("Shield", Icons.shield, 30, "shield"),
                        _buildBoosterItem("Slow-Mo", Icons.speed, 40, "slowmo"),
                        _buildBoosterItem(
                          "Magnet",
                          Icons.auto_fix_high,
                          50,
                          "magnet",
                        ),
                        if (widget.isTimeObjective)
                          _buildBoosterItem(
                            widget.objectiveDescription.toLowerCase().contains(
                                  "survive",
                                )
                                ? "-15s Survival"
                                : "+15s Time",
                            Icons.timer,
                            60,
                            "time",
                          ),
                      ],
                    ),

                    // 3. DYNAMIC DESCRIPTION AREA
                    const SizedBox(height: 15),
                    Container(
                      height:
                          60, // Fixed height so the layout doesn't jumppadding: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _dynamicBoosterDescriptions[_selectedBoosterKey] ??
                            "Tap a booster to see its power!",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Baloo2',
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: widget.onGotIt,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: const LinearGradient(
                            colors: [title1, title2],
                          ),
                        ),
                        child: const Text(
                          "Start Level",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoosterItem(String name, IconData icon, int cost, String key) {
    bool isActive = widget.activeBoosters.contains(key);
    bool isSelected = _selectedBoosterKey == key;
    bool isFree = _serverFreeBooster == key;

    return GestureDetector(
      onTap: () {
        // When tapped, we update the selected key to show description
        setState(() {
          if (isActive) {
            _selectedBoosterKey = null;
          } else {
            _selectedBoosterKey = key;
          }
        });

        // If it's not active, we also trigger the buy logic
        // if (!isActive) {
        widget.onBuyBooster(key, isFree ? 0 : cost);
        // }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.green.withOpacity(0.2)
              : (isSelected ? Colors.white12 : Colors.white.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isActive
                ? Colors.greenAccent
                : (isSelected ? title1 : Colors.white24),
            width: (isActive || isSelected) ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (isFree && !isActive)
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "DAILY FREE",
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            Icon(
              icon,
              color: isActive
                  ? Colors.greenAccent
                  : isFree
                  ? Colors.amber
                  : (isSelected ? Colors.amberAccent : Colors.white),
              size: 24,
            ),
            Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
            const SizedBox(height: 4),
            if (!isActive)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isFree)
                    Image.asset(
                      'assets/minigame3/bubble_gem_storm/icons/coin.png',
                      width: 12,
                    ),
                  Text(
                    isFree ? 'FREE' : " $cost",
                    style: TextStyle(
                      color: isFree ? Colors.amberAccent : Colors.amber,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  const Text(
                    "ACTIVE",
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Tap to remove",
                    style: TextStyle(color: Colors.white54, fontSize: 8),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
