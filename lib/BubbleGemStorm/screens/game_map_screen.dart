import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/bubble_gem_firestore_service.dart';
import '../utils/level_config.dart';
import '../utils/constants.dart';
import '../utils/sound_manager.dart';
import 'game_screen.dart';
import '../utils/haptic_manager.dart';

// class GameMapScreen extends StatefulWidget {
//   final int currentUnlockedLevel;
//   final GameTier selectedTier;
//   final String zoneTitle;
//   const GameMapScreen({
//     super.key,
//     required this.currentUnlockedLevel,
//     required this.selectedTier,
//     required this.zoneTitle,
//   });

//   @override
//   State<GameMapScreen> createState() => _GameMapScreenState();
// }

// class _GameMapScreenState extends State<GameMapScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _markerController;
//   late Animation<Offset> _markerAnimation;
//   late ScrollController _scrollController;
//   Offset? _currentMarkerPos;
//   int? _autoOpenLevelId; // To track ifwe should show the "Play" overlay

//   final double levelHeight = 100.0;
//   List<LevelConfig> get _filteredLevels {
//     return myCustomLevels
//         .where((level) => level.tier == widget.selectedTier)
//         .toList();
//   }

//   int _getGlobalLevelNumber(LevelConfig level) {
//     return _filteredLevels.indexOf(level) + 1;
//   }

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _markerController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     );

//     // Initialize the marker position immediately
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeMarker();
//     });
//   }

//   void _initializeMarker() {
//     final params = GoRouterState.of(context).uri.queryParameters;
//     final levels = _filteredLevels;

//     // 1. Find the current level index in the filtered list
//     int currentIdx = levels.indexWhere(
//       (l) => l.id == widget.currentUnlockedLevel,
//     );
//     if (currentIdx == -1) currentIdx = 0;

//     // 2. Calculate the static position
//     Offset targetPos = _calculateNodePosition(currentIdx, levels.length);

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollToPosition(targetPos.dy);
//     });

//     // 3. Check if we need to animate from a previous level
//     if (params.containsKey('animateFrom')) {
//       int fromId = int.parse(params['animateFrom']!);
//       int fromIdx = levels.indexWhere((l) => l.id == fromId);

//       if (fromIdx != -1) {
//         Offset startPos = _calculateNodePosition(fromIdx, levels.length);
//         _runUnlockAnimation(startPos, targetPos);
//         return;
//       }
//     }

//     // If no animation needed, just set the static position
//     setState(() {
//       _currentMarkerPos = targetPos;
//     });
//   }

//   Offset _calculateNodePosition(int index, int totalLevels) {
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final double totalContentHeight = (totalLevels * levelHeight) + 250;

//     double x = (screenWidth / 2) + (sin(index * 1.2) * (screenWidth * 0.25));
//     double y = totalContentHeight - 150 - (index * levelHeight);
//     return Offset(x, y);
//   }

//   void _scrollToPosition(double y) {
//     if (!_scrollController.hasClients) return;

//     // Get the height of the phone screen
//     double screenHeight = MediaQuery.of(context).size.height;

//     // Calculate the scroll offset to keep the marker in the center ofthe screen
//     double targetScroll = y - (screenHeight / 2);

//     // Ensure we don't scroll past the top or bottom of the map
//     if (_scrollController.hasClients) {
//       double maxScroll = _scrollController.position.maxScrollExtent;
//       targetScroll = targetScroll.clamp(0.0, maxScroll);

//       _scrollController.jumpTo(targetScroll);
//     }
//   }

//   void _runUnlockAnimation(Offset start, Offset end) {
//     _markerAnimation =
//         Tween<Offset>(begin: start, end: end).animate(
//           CurvedAnimation(
//             parent: _markerController,
//             curve: Curves.easeInOutCubic,
//           ),
//         )..addListener(() {
//           setState(() {
//             _currentMarkerPos = _markerAnimation.value;
//             _scrollToPosition(_markerAnimation.value.dy);
//           });
//         });

//     _markerController.forward().then((_) async {
//       // Wait for a tiny moment (optional) so the player sees the marker land
//       await Future.delayed(const Duration(milliseconds: 300));

//       if (mounted) {
//         // Navigate directly to the game screen
//         context.pushReplacement(
//           '/bubble-game?level=${widget.currentUnlockedLevel}',
//         );
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _markerController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final levels = _filteredLevels;

//     final double screenWidth = MediaQuery.of(context).size.width;
//     final double totalContentHeight = (levels.length * levelHeight) + 250;

//     List<Offset> nodePositions = List.generate(levels.length, (index) {
//       // Horizontal zig-zag (0.25 instead of 0.3 to keep nodes away from edges)
//       double x = (screenWidth / 2) + (sin(index * 1.2) * (screenWidth * 0.25));

//       // Vertical: Start from the bottom of the total content height
//       // index 0 (Level 1) will be at the bottom
//       double y = totalContentHeight - 150 - (index * levelHeight);

//       return Offset(x, y);
//     });

//     return Scaffold(
//       backgroundColor: const Color(0xFF000C1A),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             controller: _scrollController,
//             reverse: false,
//             child: Container(
//               height: totalContentHeight,
//               width: screenWidth,
//               child: Stack(
//                 children: [
//                   // THE PATH
//                   CustomPaint(
//                     size: Size(screenWidth, totalContentHeight),
//                     painter: PathPainter(nodePositions: nodePositions),
//                   ),

//                   // THE NODES
//                   ...levels.asMap().entries.map((entry) {
//                     final pos = _calculateNodePosition(
//                       entry.key,
//                       levels.length,
//                     );
//                     return Positioned(
//                       left: pos.dx - 30,
//                       top: pos.dy - 40,
//                       child: _buildLevelNode(
//                         context,
//                         entry.value,
//                         entry.key + 1,
//                       ),
//                     );
//                   }).toList(),

//                   if (_currentMarkerPos != null)
//                     Positioned(
//                       left: _currentMarkerPos!.dx - 20, // Centered on node
//                       top:
//                           _currentMarkerPos!.dy -
//                           105, // Floating slightly above
//                       child: _buildPlayerMarker(),
//                     ),
//                 ],
//               ),
//             ),
//           ),

//           _buildHeader(context),
//           _buildLegend(),
//         ],
//       ),
//     );
//   }

//   Widget _buildPlayerMarker() {
//     return TweenAnimationBuilder<double>(
//       tween: Tween(begin: 0, end: 10),
//       duration: const Duration(seconds: 1),
//       curve: Curves.easeInOutSine,
//       builder: (context, value, child) {
//         return Transform.translate(
//           offset: Offset(0, value), // Floating effect
//           child: Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(4),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.pinkAccent.withOpacity(0.5),
//                       blurRadius: 15,
//                       spreadRadius: 5,
//                     ),
//                   ],
//                 ),
//                 child: const Icon(Icons.person, color: title2, size: 30),
//               ),
//               const Icon(Icons.arrow_drop_down, color: Colors.white, size: 25),
//             ],
//           ),
//         );
//       },
//       onEnd: () {}, // Optional: loopthe floating animation
//     );
//   }

//   // Helper to get objective text without being in the GameScreen
//   String victoryObjectiveTextForLevel(LevelConfig level) {
//     switch (level.objective) {
//       case ObjectiveType.score:
//         return "Reach Score ${level.targetValue}";
//       case ObjectiveType.survive:
//         return "Survive for ${level.targetValue} seconds";
//       case ObjectiveType.clearGems:
//         return "Clear ${level.targetValue} gems";
//       default:
//         return "Complete the challenge!";
//     }
//   }

//   Widget _buildLevelNode(
//     BuildContext context,
//     LevelConfig level,
//     // int levelNum,
//     int visualLevelNum,
//   ) {
//     final int actualLevelId = myCustomLevels.indexOf(level) + 1;
//     bool isLocked = actualLevelId > widget.currentUnlockedLevel;
//     bool isCurrent = actualLevelId == widget.currentUnlockedLevel;

//     return GestureDetector(
//       onTap: () => isLocked
//           ? _showLockedMessage(context)
//           : context.push('/bubble-game?level=$actualLevelId'),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // The "Candy" Button
//           Container(
//             width: isCurrent ? 65 : 50,
//             height: isCurrent ? 65 : 50,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: isLocked
//                   ? const LinearGradient(colors: [Colors.grey, Colors.black87])
//                   : LinearGradient(colors: [zonecolor, zonecolor1]),
//               boxShadow: [
//                 BoxShadow(
//                   color: isLocked
//                       ? Colors.transparent
//                       : title1.withOpacity(0.4),
//                   blurRadius: 15,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//               border: Border.all(
//                 color: Colors.white,
//                 width: isCurrent ? 4 : 0.5,
//               ),
//             ),
//             child: Center(
//               child: isLocked
//                   ? const Icon(Icons.lock, color: Colors.white54, size: 20)
//                   : Text(
//                       "$visualLevelNum",
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 20,
//                       ),
//                     ),
//             ),
//           ),
//           // Level Name / Tier
//           const SizedBox(height: 5),

//           Text(
//             "LEVEL $visualLevelNum",
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 10,
//               fontWeight: FontWeight.bold,
//               shadows: [Shadow(blurRadius: 5)],
//             ),
//           ),
//           SizedBox(
//             height: 16, // Fixed height to prevent layout jumping
//             child: isLocked
//                 ? const SizedBox.shrink()
//                 : FutureBuilder<Map<String, dynamic>>(
//                     future: BubbleGemFirestoreService.getSingleLevelStats(
//                       actualLevelId,
//                     ),
//                     builder: (context, snapshot) {
//                       if (!snapshot.hasData || snapshot.data == null) {
//                         return const SizedBox.shrink();
//                       }

//                       final int attempts = snapshot.data!['attempts'] ?? 0;

//                       // Logic: 0 attempts = no stars, 1 =3 stars, <5 = 2 stars, else 1
//                       int starCount = 0;
//                       if (attempts > 0) {
//                         starCount = attempts <= 1 ? 3 : (attempts < 5 ? 2 : 1);
//                       }

//                       return Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: List.generate(3, (index) {
//                           return Icon(
//                             Icons.star_rounded,
//                             size: 14,
//                             color: index < starCount
//                                 ? Colors.amber
//                                 : Colors.white10,
//                           );
//                         }),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLegend() {
//     return Positioned(
//       bottom: 30, // Adjusted for better visibility
//       left: 0,
//       right: 0,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         color: Colors.black.withOpacity(
//           0.3,
//         ), // Subtle background for readability
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             _legendItem(const Color(0xFFEC4899), "Unlocked", 2),
//             const SizedBox(width: 15),
//             _legendItem(Color(0xFFEC4899), "Completed", 0.1),
//             const SizedBox(width: 15),
//             _legendItem(Colors.white38, "Locked", 0.1),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _legendItem(Color color, String label, double borderWidth) {
//     return Row(
//       children: [
//         Container(
//           width: 12,
//           height: 12,
//           decoration: BoxDecoration(
//             color: color,
//             shape: BoxShape.circle,
//             border: Border.all(color: whitecolor, width: borderWidth),
//           ),
//         ),
//         const SizedBox(width: 5),
//         Text(
//           label,
//           style: const TextStyle(color: Colors.white70, fontSize: 12),
//         ),
//       ],
//     );
//   }

//   Widget _buildHeader(BuildContext context) {
//     String tierSubtitle = "";
//     switch (widget.selectedTier) {
//       case GameTier.tier1:
//         tierSubtitle = "TIER 1: SCORE RUSH";
//         break;
//       case GameTier.tier2:
//         tierSubtitle = "TIER 2: SURVIVOR";
//         break;
//       case GameTier.tier3:
//         tierSubtitle = "TIER3: GEM MASTER";
//         break;
//     }
//     return Positioned(
//       top: 0,
//       left: 0,
//       right: 0,
//       child: Container(
//         padding: const EdgeInsets.fromLTRB(10, 50, 10, 20),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.black.withOpacity(0.8), Colors.transparent],
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white12,
//                 border: Border.all(color: Colors.white24),
//               ),
//               child: IconButton(
//                 icon: const Icon(Icons.arrow_back, color: Colors.white),
//                 onPressed: () => context.pop(),
//               ),
//             ),
//             SizedBox(width: 20),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     widget.zoneTitle.toUpperCase(),
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontFamily: 'Baloo2',
//                       fontWeight: FontWeight.w900,
//                       fontSize: 25,
//                       letterSpacing: 1.5,
//                     ),
//                   ),
//                   Text(
//                     tierSubtitle,
//                     style: const TextStyle(
//                       color: whitecolor,
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 2,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 40), // Spacer for balance
//           ],
//         ),
//       ),
//     );
//   }

//   void _showLockedMessage(BuildContext context) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text("Unlock previous levels first!"),
//         backgroundColor: Colors.redAccent.withOpacity(0.9),
//         behavior: SnackBarBehavior.floating,
//         margin: const EdgeInsets.all(20),
//       ),
//     );
//   }
// }

// class PathPainter extends CustomPainter {
//   final List<Offset> nodePositions;
//   PathPainter({required this.nodePositions});

//   @override
//   void paint(Canvas canvas, Size size) {
//     if (nodePositions.length < 2) return;

//     final paint = Paint()
//       ..color = const Color(0xFFF472B6)
//           .withOpacity(0.5) // Soft Pink
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 3.0;

//     final path = Path();
//     path.moveTo(nodePositions[0].dx, nodePositions[0].dy);

//     for (int i = 1; i < nodePositions.length; i++) {
//       path.lineTo(nodePositions[i].dx, nodePositions[i].dy);
//     }

//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

// class SelectZoneScreen extends StatefulWidget {
//   const SelectZoneScreen({super.key});

//   @override
//   State<SelectZoneScreen> createState() => _SelectZoneScreenState();
// }

// class _SelectZoneScreenState extends State<SelectZoneScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _shakeController;
//   GameTier? _justCompletedTier;
//   bool _isTierUnlocked(GameTier tier, int unlockedLevel) {
//     switch (tier) {
//       case GameTier.tier1:
//         return true;
//       case GameTier.tier2:
//         return unlockedLevel > 20;
//       case GameTier.tier3:
//         return unlockedLevel > 50;
//     }
//   }

//   final Map<GameTier, GlobalKey<ShakeWrapperState>> _shakeKeys = {
//     GameTier.tier1: GlobalKey<ShakeWrapperState>(),
//     GameTier.tier2: GlobalKey<ShakeWrapperState>(),
//     GameTier.tier3: GlobalKey<ShakeWrapperState>(),
//   };

//   @override
//   void initState() {
//     super.initState();

//     // Check if we arrived here after completing a tier
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final params = GoRouterState.of(context).uri.queryParameters;
//       if (params.containsKey('completedTier')) {
//         setState(() {
//           int index = int.parse(params['completedTier']!);
//           _justCompletedTier = GameTier.values[index];
//         });
//         SoundManager.instance.playTierCompleteSound();
//         HapticManager.heavy();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final w = size.width;
//     final h = size.height;
//     return Scaffold(
//       body: Stack(
//         children: [
//           StreamBuilder<int>(
//             stream: BubbleGemFirestoreService.unlockedLevelStream(),
//             builder: (context, snapshot) {
//               final unlockedLevel = snapshot.data ?? 1;

//               return Container(
//                 decoration: const BoxDecoration(color: bg),
//                 child: SafeArea(
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       children: [
//                         // const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             Container(
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.white12,
//                                 border: Border.all(color: Colors.white24),
//                               ),
//                               child: IconButton(
//                                 icon: const Icon(
//                                   Icons.arrow_back,
//                                   color: Colors.white,
//                                 ),
//                                 onPressed: () => Navigator.of(context).pop(),
//                               ),
//                             ),
//                           ],
//                         ),

//                         Text(
//                           "Select Zone",
//                           style: TextStyle(
//                             fontSize: w * 0.12,
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontFamily: 'Baloo2',
//                             shadows: [
//                               Shadow(
//                                 color: title2.withValues(alpha: 0.8),
//                                 offset: const Offset(2, 2),
//                                 blurRadius: 5,
//                               ),
//                               // 2. The First Spread (Medium)
//                               Shadow(
//                                 color: title2.withValues(alpha: 0.5),
//                                 offset: const Offset(
//                                   0,
//                                   0,
//                                 ), // No offset to spread evenly in all directions
//                                 blurRadius: 15,
//                               ),
//                               // 3. The Outer Spread (Wide)
//                               Shadow(
//                                 color: title2.withValues(alpha: 0.3),
//                                 offset: const Offset(0, 0),
//                                 blurRadius:
//                                     30, // Large blur creates the "spread" look
//                               ),
//                             ],
//                           ),
//                         ),

//                         SizedBox(height: h * 0.001),

//                         const Text(
//                           "Choose your battlefield",
//                           style: TextStyle(color: Colors.white70),
//                         ),

//                         SizedBox(height: h * 0.01),

//                         Expanded(
//                           child: ListView(
//                             padding: const EdgeInsets.all(16),
//                             children: [
//                               _staggeredWrapper(
//                                 0,
//                                 _buildTierCard(
//                                   size,
//                                   context,
//                                   tier: GameTier.tier1,
//                                   title: "Crystal Caverns",
//                                   subtitle:
//                                       "Master the basics in the glowing depths.",
//                                   unlocked: _isTierUnlocked(
//                                     GameTier.tier1,
//                                     unlockedLevel,
//                                   ),
//                                 ),
//                               ),

//                               const SizedBox(height: 20),

//                               _staggeredWrapper(
//                                 1,
//                                 _buildTierCard(
//                                   size,
//                                   context,
//                                   tier: GameTier.tier2,
//                                   title: "Neon Heights",
//                                   subtitle:
//                                       "Test your survival skills in the electric sky.",
//                                   unlocked: _isTierUnlocked(
//                                     GameTier.tier2,
//                                     unlockedLevel,
//                                   ),
//                                 ),
//                               ),

//                               const SizedBox(height: 20),

//                               _staggeredWrapper(
//                                 2,
//                                 _buildTierCard(
//                                   size,
//                                   context,
//                                   tier: GameTier.tier3,
//                                   title: "Galaxy Depths",
//                                   subtitle:
//                                       "The ultimate challenge in the heart of the void.",
//                                   unlocked: _isTierUnlocked(
//                                     GameTier.tier3,
//                                     unlockedLevel,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//           if (_justCompletedTier != null)
//             TierCompletionOverlay(
//               completedTier: _justCompletedTier!,
//               onNextTier: () {
//                 setState(() => _justCompletedTier = null);
//                 // Optional: Auto-scroll to the newly unlocked card
//               },
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _staggeredWrapper(int index, Widget child) {
//     return TweenAnimationBuilder<double>(
//       // We use a unique key so the animation triggers every time the screen builds
//       key: ValueKey('tier_card_$index'),
//       tween: Tween(begin: 0.0, end: 1.0),
//       // Total duration of the slide
//       duration: const Duration(seconds: 2),
//       // Use a "Back" curve for that professional "pull and settle" bounce
//       curve: Curves.easeOutBack,
//       builder: (context, value, child) {
//         // Create a staggered start:
//         // Card 0 starts at 0.0, Card 1 starts after a short delay, etc.
//         // We use a simple math trick to delay the animation start
//         double delay = index * 0.2; // 200ms delay per card
//         double animatedValue = (value - delay).clamp(0.0, 1.0);

//         return Opacity(
//           opacity: animatedValue, // Fades in as it pulls out
//           child: Transform.translate(
//             // Pulls up from 120 pixels below its final position
//             offset: Offset(0, 120 * (1 - animatedValue)),
//             child: child,
//           ),
//         );
//       },
//       child: child,
//     );
//   }

//   Widget _buildTierCard(
//     Size size,
//     BuildContext context, {
//     required GameTier tier,
//     required String title,
//     required String subtitle,
//     required bool unlocked,
//   }) {
//     double w = size.width;
//     double h = size.height;
//     return ShakeWrapper(
//       key: _shakeKeys[tier],
//       child: StreamBuilder(
//         stream: BubbleGemFirestoreService.unlockedLevelStream(),
//         builder: (context, snapshot) {
//           final tierIndex = tier.index;
//           final unlockedLevel = snapshot.data ?? 1;
//           return GestureDetector(
//             onTap: () {
//               if (unlocked) {
//                 // Fetch the current unlocked level from your Firestore state
//                 context.push(
//                   '/bubble-gem-map?unlockedLevel=$unlockedLevel&tier=$tierIndex&title=$title',
//                 );
//               } else {
//                 _shakeKeys[tier]?.currentState?.shake();
//                 HapticManager.medium();
//                 // Show Snackbar if locked
//                 ScaffoldMessenger.of(
//                   context,
//                 ).clearSnackBars(); // Clear existing ones
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Row(
//                       children: [
//                         const Icon(Icons.lock_outline, color: Colors.white),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: Text(
//                             "This zone is locked! $subtitle",
//                             style: const TextStyle(fontFamily: 'Baloo2'),
//                           ),
//                         ),
//                       ],
//                     ),
//                     backgroundColor: Colors.redAccent.withOpacity(0.9),
//                     behavior: SnackBarBehavior.floating,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     duration: const Duration(seconds: 2),
//                   ),
//                 );
//               }
//             },
//             child: Container(
//               padding: EdgeInsets.all(w * 0.025),
//               decoration: BoxDecoration(
//                 color: unlocked ? Colors.white10 : Colors.white12,
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: Colors.white24),
//                 boxShadow: unlocked
//                     ? [
//                         BoxShadow(
//                           color: title2.withValues(alpha: 0.15),
//                           offset: Offset(0, 5),
//                           blurRadius: 10,
//                           spreadRadius: 10,
//                         ),
//                       ]
//                     : [],
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: w * 0.12, // radius * 2
//                     height: w * 0.12,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       // Apply gradient based on unlocked status
//                       gradient: unlocked
//                           ? const LinearGradient(
//                               colors: [zonecolor, zonecolor1],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             )
//                           : LinearGradient(
//                               colors: [
//                                 Colors.grey.shade600,
//                                 Colors.grey.shade700,
//                               ],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                       boxShadow: [
//                         if (unlocked)
//                           BoxShadow(
//                             color: Colors.pinkAccent.withOpacity(0.4),
//                             blurRadius: 8,
//                             offset: const Offset(0, 4),
//                           ),
//                       ],
//                     ),
//                     child: Icon(
//                       unlocked ? Icons.play_arrow : Icons.lock_outline,
//                       color: Colors.white,
//                       size: w * 0.06,
//                     ),
//                   ),
//                   const SizedBox(width: 20),

//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           title,
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: w * 0.07,
//                             fontWeight: FontWeight.bold,
//                             fontFamily: 'Baloo2',
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           subtitle,

//                           style: const TextStyle(
//                             color: Colors.white70,
//                             fontFamily: 'Baloo2',
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   if (unlocked)
//                     Icon(
//                       Icons.check_circle_outline,
//                       color: rainbowg.withValues(alpha: 0.5),
//                       size: 40,
//                     ),
//                   // else
//                   //   const Icon(Icons.lock, color: Colors.white54),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class ShakeWrapper extends StatefulWidget {
//   final Widget child;
//   final bool shouldShake;

//   // We use a GlobalKey or a wayto trigger it from the parent
//   const ShakeWrapper({
//     super.key,
//     required this.child,
//     this.shouldShake = false,
//   });

//   @override
//   State<ShakeWrapper> createState() => ShakeWrapperState();
// }

// class ShakeWrapperState extends State<ShakeWrapper>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//   }

//   // This is the functionwe will call from the parent
//   void shake() {
//     _controller.forward(from: 0.0);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContextcontext) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         // Sine wave for the left-right shake
//         final sineValue = sin(4 * pi * _controller.value);
//         return Transform.translate(
//           offset: Offset(sineValue * 8, 0),
//           child: child,
//         );
//       },
//       child: widget.child,
//     );
//   }
// }
class GameMapScreen extends StatefulWidget {
  final int currentUnlockedLevel;
  final GameTier selectedTier;
  final String zoneTitle;
  const GameMapScreen({
    super.key,
    required this.currentUnlockedLevel,
    required this.selectedTier,
    required this.zoneTitle,
  });

  @override
  State<GameMapScreen> createState() => _GameMapScreenState();
}

class _GameMapScreenState extends State<GameMapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _markerController;
  late Animation<Offset> _markerAnimation;
  late ScrollController _scrollController;
  Offset? _currentMarkerPos;
  int? _autoOpenLevelId; // To track ifwe should show the "Play" overlay

  final double levelHeight = 100.0;
  List<LevelConfig> get _filteredLevels {
    return myCustomLevels
        .where((level) => level.tier == widget.selectedTier)
        .toList();
  }

  int _getGlobalLevelNumber(LevelConfig level) {
    return _filteredLevels.indexOf(level) + 1;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _markerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Initialize the marker position immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMarker();
    });
  }

  void _initializeMarker() {
    final params = GoRouterState.of(context).uri.queryParameters;
    final levels = _filteredLevels;

    // 1. Find the current level index in the filtered list
    int currentIdx = levels.indexWhere(
      (l) => l.id == widget.currentUnlockedLevel,
    );
    if (currentIdx == -1) currentIdx = 0;

    // 2. Calculate the static position
    Offset targetPos = _calculateNodePosition(currentIdx, levels.length);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToPosition(targetPos.dy);
    });

    // 3. Check if we need to animate from a previous level
    if (params.containsKey('animateFrom')) {
      int fromId = int.parse(params['animateFrom']!);
      int fromIdx = levels.indexWhere((l) => l.id == fromId);

      if (fromIdx != -1) {
        Offset startPos = _calculateNodePosition(fromIdx, levels.length);
        _runUnlockAnimation(startPos, targetPos);
        return;
      }
    }

    // If no animation needed, just set the static position
    setState(() {
      _currentMarkerPos = targetPos;
    });
  }

  Offset _calculateNodePosition(int index, int totalLevels) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double totalContentHeight = (totalLevels * levelHeight) + 250;

    double x = (screenWidth / 2) + (sin(index * 1.2) * (screenWidth * 0.25));
    double y = totalContentHeight - 150 - (index * levelHeight);
    return Offset(x, y);
  }

  void _scrollToPosition(double y) {
    if (!_scrollController.hasClients) return;

    // Get the height of the phone screen
    double screenHeight = MediaQuery.of(context).size.height;

    // Calculate the scroll offset to keep the marker in the center ofthe screen
    double targetScroll = y - (screenHeight / 2);

    // Ensure we don't scroll past the top or bottom of the map
    if (_scrollController.hasClients) {
      double maxScroll = _scrollController.position.maxScrollExtent;
      targetScroll = targetScroll.clamp(0.0, maxScroll);

      _scrollController.jumpTo(targetScroll);
    }
  }

  void _runUnlockAnimation(Offset start, Offset end) {
    _markerAnimation =
        Tween<Offset>(begin: start, end: end).animate(
          CurvedAnimation(
            parent: _markerController,
            curve: Curves.easeInOutCubic,
          ),
        )..addListener(() {
          setState(() {
            _currentMarkerPos = _markerAnimation.value;
            _scrollToPosition(_markerAnimation.value.dy);
          });
        });

    _markerController.forward().then((_) async {
      // Wait for a tiny moment (optional) so the player sees the marker land
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        // Navigate directly to the game screen
        context.pushReplacement(
          '/bubble-game?level=${widget.currentUnlockedLevel}',
        );
      }
    });
  }

  @override
  void dispose() {
    _markerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final levels = _filteredLevels;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double totalContentHeight = (levels.length * levelHeight) + 250;

    List<Offset> nodePositions = List.generate(levels.length, (index) {
      // Horizontal zig-zag (0.25 instead of 0.3 to keep nodes away from edges)
      double x = (screenWidth / 2) + (sin(index * 1.2) * (screenWidth * 0.25));

      // Vertical: Start from the bottom of the total content height
      // index 0 (Level 1) will be at the bottom
      double y = totalContentHeight - 150 - (index * levelHeight);

      return Offset(x, y);
    });
    final theme = tierThemeManager.current;
    return Scaffold(
      backgroundColor: theme.gradient[0],
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            reverse: false,
            child: Container(
              height: totalContentHeight,
              width: screenWidth,
              child: Stack(
                children: [
                  // THE PATH
                  CustomPaint(
                    size: Size(screenWidth, totalContentHeight),
                    painter: PathPainter(nodePositions: nodePositions),
                  ),

                  // THE NODES
                  ...levels.asMap().entries.map((entry) {
                    final pos = _calculateNodePosition(
                      entry.key,
                      levels.length,
                    );
                    return Positioned(
                      left: pos.dx - 30,
                      top: pos.dy - 40,
                      child: _buildLevelNode(
                        context,
                        entry.value,
                        entry.key + 1,
                      ),
                    );
                  }).toList(),

                  if (_currentMarkerPos != null)
                    Positioned(
                      left: _currentMarkerPos!.dx - 20, // Centered on node
                      top:
                          _currentMarkerPos!.dy -
                          105, // Floating slightly above
                      child: _buildPlayerMarker(),
                    ),
                ],
              ),
            ),
          ),

          _buildHeader(context),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildPlayerMarker() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 10),
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOutSine,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value), // Floating effect
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pinkAccent.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.person, color: title2, size: 30),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.white, size: 25),
            ],
          ),
        );
      },
      onEnd: () {}, // Optional: loopthe floating animation
    );
  }

  // Helper to get objective text without being in the GameScreen
  String victoryObjectiveTextForLevel(LevelConfig level) {
    switch (level.objective) {
      case ObjectiveType.score:
        return "Reach Score ${level.targetValue}";
      case ObjectiveType.survive:
        return "Survive for ${level.targetValue} seconds";
      case ObjectiveType.clearGems:
        return "Clear ${level.targetValue} gems";
      default:
        return "Complete the challenge!";
    }
  }

  Widget _buildLevelNode(
    BuildContext context,
    LevelConfig level,
    // int levelNum,
    int visualLevelNum,
  ) {
    final int actualLevelId = myCustomLevels.indexOf(level) + 1;
    bool isLocked = actualLevelId > widget.currentUnlockedLevel;
    bool isCurrent = actualLevelId == widget.currentUnlockedLevel;

    return GestureDetector(
      onTap: () => isLocked
          ? _showLockedMessage(context)
          : context.push('/bubble-game?level=$actualLevelId'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The "Candy" Button
          Container(
            width: isCurrent ? 65 : 50,
            height: isCurrent ? 65 : 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isLocked
                  ? const LinearGradient(colors: [Colors.grey, Colors.black87])
                  : LinearGradient(colors: [zonecolor, zonecolor1]),
              boxShadow: [
                BoxShadow(
                  color: isLocked
                      ? Colors.transparent
                      : title1.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: Colors.white,
                width: isCurrent ? 4 : 0.5,
              ),
            ),
            child: Center(
              child: isLocked
                  ? const Icon(Icons.lock, color: Colors.white54, size: 20)
                  : Text(
                      "$visualLevelNum",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
            ),
          ),
          // Level Name / Tier
          const SizedBox(height: 5),

          Text(
            "LEVEL $visualLevelNum",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(blurRadius: 5)],
            ),
          ),
          SizedBox(
            height: 16, // Fixed height to prevent layout jumping
            child: isLocked
                ? const SizedBox.shrink()
                : FutureBuilder<Map<String, dynamic>>(
                    future: BubbleGemFirestoreService.getSingleLevelStats(
                      actualLevelId,
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                        return const SizedBox.shrink();
                      }

                      final int attempts = snapshot.data!['attempts'] ?? 0;

                      // Logic: 0 attempts = no stars, 1 =3 stars, <5 = 2 stars, else 1
                      int starCount = 0;
                      if (attempts > 0) {
                        starCount = attempts <= 1 ? 3 : (attempts < 5 ? 2 : 1);
                      }

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (index) {
                          return Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: index < starCount
                                ? Colors.amber
                                : Colors.white10,
                          );
                        }),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Positioned(
      bottom: 30, // Adjusted for better visibility
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        color: Colors.black.withOpacity(
          0.3,
        ), // Subtle background for readability
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _legendItem(const Color(0xFFEC4899), "Unlocked", 2),
            const SizedBox(width: 15),
            _legendItem(Color(0xFFEC4899), "Completed", 0.1),
            const SizedBox(width: 15),
            _legendItem(Colors.white38, "Locked", 0.1),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label, double borderWidth) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: whitecolor, width: borderWidth),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    String tierSubtitle = "";
    switch (widget.selectedTier) {
      case GameTier.tier1:
        tierSubtitle = "TIER 1: SCORE RUSH";
        break;
      case GameTier.tier2:
        tierSubtitle = "TIER 2: SURVIVOR";
        break;
      case GameTier.tier3:
        tierSubtitle = "TIER3: GEM MASTER";
        break;
    }
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 50, 10, 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white12,
                border: Border.all(color: Colors.white24),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.zoneTitle.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Baloo2',
                      fontWeight: FontWeight.w900,
                      fontSize: 25,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    tierSubtitle,
                    style: const TextStyle(
                      color: whitecolor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40), // Spacer for balance
          ],
        ),
      ),
    );
  }

  void _showLockedMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Unlock previous levels first!"),
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
      ),
    );
  }
}

class PathPainter extends CustomPainter {
  final List<Offset> nodePositions;
  PathPainter({required this.nodePositions});

  @override
  void paint(Canvas canvas, Size size) {
    if (nodePositions.length < 2) return;

    final paint = Paint()
      ..color = const Color(0xFFF472B6)
          .withOpacity(0.5) // Soft Pink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final path = Path();
    path.moveTo(nodePositions[0].dx, nodePositions[0].dy);

    for (int i = 1; i < nodePositions.length; i++) {
      path.lineTo(nodePositions[i].dx, nodePositions[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SelectZoneScreen extends StatefulWidget {
  const SelectZoneScreen({super.key});

  @override
  State<SelectZoneScreen> createState() => _SelectZoneScreenState();
}

class _SelectZoneScreenState extends State<SelectZoneScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  GameTier? _justCompletedTier;
  bool _isTierUnlocked(GameTier tier, int unlockedLevel) {
    switch (tier) {
      case GameTier.tier1:
        return true;
      case GameTier.tier2:
        return unlockedLevel > 20;
      case GameTier.tier3:
        return unlockedLevel > 50;
    }
  }

  final Map<GameTier, GlobalKey<ShakeWrapperState>> _shakeKeys = {
    GameTier.tier1: GlobalKey<ShakeWrapperState>(),
    GameTier.tier2: GlobalKey<ShakeWrapperState>(),
    GameTier.tier3: GlobalKey<ShakeWrapperState>(),
  };

  @override
  void initState() {
    super.initState();

    // Check if we arrived here after completing a tier
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final params = GoRouterState.of(context).uri.queryParameters;
      if (params.containsKey('completedTier')) {
        setState(() {
          int index = int.parse(params['completedTier']!);
          _justCompletedTier = GameTier.values[index];
        });
        SoundManager.instance.playTierCompleteSound();
        HapticManager.heavy();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = tierThemeManager.current;
    final size = MediaQuery.of(context).size;
    final w = size.width;
    final h = size.height;
    return Scaffold(
      body: Stack(
        children: [
          StreamBuilder<int>(
            stream: BubbleGemFirestoreService.unlockedLevelStream(),
            builder: (context, snapshot) {
              final unlockedLevel = snapshot.data ?? 1;

              return Container(
                decoration: BoxDecoration(color: theme.gradient[0]),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // const SizedBox(height: 20),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white12,
                                border: Border.all(color: Colors.white24),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () =>
                                    context.push('/bubble-gem-home'),
                              ),
                            ),
                          ],
                        ),

                        Text(
                          "Select Zone",
                          style: TextStyle(
                            fontSize: w * 0.12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Baloo2',
                            shadows: [
                              Shadow(
                                color: title2.withValues(alpha: 0.8),
                                offset: const Offset(2, 2),
                                blurRadius: 5,
                              ),
                              // 2. The First Spread (Medium)
                              Shadow(
                                color: title2.withValues(alpha: 0.5),
                                offset: const Offset(
                                  0,
                                  0,
                                ), // No offset to spread evenly in all directions
                                blurRadius: 15,
                              ),
                              // 3. The Outer Spread (Wide)
                              Shadow(
                                color: title2.withValues(alpha: 0.3),
                                offset: const Offset(0, 0),
                                blurRadius:
                                    30, // Large blur creates the "spread" look
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: h * 0.001),

                        const Text(
                          "Choose your battlefield",
                          style: TextStyle(color: Colors.white70),
                        ),

                        SizedBox(height: h * 0.01),

                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              _staggeredWrapper(
                                0,
                                _buildTierCard(
                                  size,
                                  context,
                                  tier: GameTier.tier1,
                                  title: "Crystal Caverns",
                                  subtitle:
                                      "Master the basics in the glowing depths.",
                                  unlocked: _isTierUnlocked(
                                    GameTier.tier1,
                                    unlockedLevel,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              _staggeredWrapper(
                                1,
                                _buildTierCard(
                                  size,
                                  context,
                                  tier: GameTier.tier2,
                                  title: "Neon Heights",
                                  subtitle:
                                      "Test your survival skills in the electric sky.",
                                  unlocked: _isTierUnlocked(
                                    GameTier.tier2,
                                    unlockedLevel,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              _staggeredWrapper(
                                2,
                                _buildTierCard(
                                  size,
                                  context,
                                  tier: GameTier.tier3,
                                  title: "Galaxy Depths",
                                  subtitle:
                                      "The ultimate challenge in the heart of the void.",
                                  unlocked: _isTierUnlocked(
                                    GameTier.tier3,
                                    unlockedLevel,
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
          ),
          if (_justCompletedTier != null)
            TierCompletionOverlay(
              completedTier: _justCompletedTier!,
              onNextTier: () {
                setState(() => _justCompletedTier = null);
                // Optional: Auto-scroll to the newly unlocked card
              },
            ),
        ],
      ),
    );
  }

  Widget _staggeredWrapper(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      // We use a unique key so the animation triggers every time the screen builds
      key: ValueKey('tier_card_$index'),
      tween: Tween(begin: 0.0, end: 1.0),
      // Total duration of the slide
      duration: const Duration(seconds: 2),
      // Use a "Back" curve for that professional "pull and settle" bounce
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        // Create a staggered start:
        // Card 0 starts at 0.0, Card 1 starts after a short delay, etc.
        // We use a simple math trick to delay the animation start
        double delay = index * 0.2; // 200ms delay per card
        double animatedValue = (value - delay).clamp(0.0, 1.0);

        return Opacity(
          opacity: animatedValue, // Fades in as it pulls out
          child: Transform.translate(
            // Pulls up from 120 pixels below its final position
            offset: Offset(0, 120 * (1 - animatedValue)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildTierCard(
    Size size,
    BuildContext context, {
    required GameTier tier,
    required String title,
    required String subtitle,
    required bool unlocked,
  }) {
    double w = size.width;
    double h = size.height;
    return ShakeWrapper(
      key: _shakeKeys[tier],
      child: StreamBuilder(
        stream: BubbleGemFirestoreService.unlockedLevelStream(),
        builder: (context, snapshot) {
          final tierIndex = tier.index;
          final unlockedLevel = snapshot.data ?? 1;
          return GestureDetector(
            onTap: () {
              if (unlocked) {
                // Fetch the current unlocked level from your Firestore state
                context.push(
                  '/bubble-gem-map?unlockedLevel=$unlockedLevel&tier=$tierIndex&title=$title',
                );
              } else {
                _shakeKeys[tier]?.currentState?.shake();
                HapticManager.medium();
                // Show Snackbar if locked
                ScaffoldMessenger.of(
                  context,
                ).clearSnackBars(); // Clear existing ones
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.lock_outline, color: Colors.white),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "This zone is locked! $subtitle",
                            style: const TextStyle(fontFamily: 'Baloo2'),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: Colors.redAccent.withOpacity(0.9),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Container(
              padding: EdgeInsets.all(w * 0.025),
              decoration: BoxDecoration(
                color: unlocked ? Colors.white10 : Colors.white12,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
                boxShadow: unlocked
                    ? [
                        BoxShadow(
                          color: title2.withValues(alpha: 0.15),
                          offset: Offset(0, 5),
                          blurRadius: 10,
                          spreadRadius: 10,
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Container(
                    width: w * 0.12, // radius * 2
                    height: w * 0.12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // Apply gradient based on unlocked status
                      gradient: unlocked
                          ? const LinearGradient(
                              colors: [zonecolor, zonecolor1],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [
                                Colors.grey.shade600,
                                Colors.grey.shade700,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      boxShadow: [
                        if (unlocked)
                          BoxShadow(
                            color: Colors.pinkAccent.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Icon(
                      unlocked ? Icons.play_arrow : Icons.lock_outline,
                      color: Colors.white,
                      size: w * 0.06,
                    ),
                  ),
                  const SizedBox(width: 20),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: w * 0.07,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Baloo2',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,

                          style: const TextStyle(
                            color: Colors.white70,
                            fontFamily: 'Baloo2',
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (unlocked)
                    Icon(
                      Icons.check_circle_outline,
                      color: rainbowg.withValues(alpha: 0.5),
                      size: 40,
                    ),
                  // else
                  //   const Icon(Icons.lock, color: Colors.white54),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ShakeWrapper extends StatefulWidget {
  final Widget child;
  final bool shouldShake;

  // We use a GlobalKey or a wayto trigger it from the parent
  const ShakeWrapper({
    super.key,
    required this.child,
    this.shouldShake = false,
  });

  @override
  State<ShakeWrapper> createState() => ShakeWrapperState();
}

class ShakeWrapperState extends State<ShakeWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  // This is the functionwe will call from the parent
  void shake() {
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContextcontext) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Sine wave for the left-right shake
        final sineValue = sin(4 * pi * _controller.value);
        return Transform.translate(
          offset: Offset(sineValue * 8, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
