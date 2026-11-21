import 'package:flutter/material.dart';

import '../utils/bubble_gem_firestore_service.dart';
import '../utils/constants.dart';
import '../utils/game_challenge.dart';
import '../utils/level_config.dart';

// class ChallengeScreen extends StatelessWidget {
//   const ChallengeScreen({super.key});

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
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   // const SizedBox(height: 10),
//                   Row(
//                     children: [
//                       Container(
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: Colors.white12,
//                           border: Border.all(color: Colors.white24),
//                         ),
//                         child: IconButton(
//                           icon: const Icon(
//                             Icons.arrow_back,
//                             color: Colors.white,
//                           ),
//                           onPressed: () => Navigator.of(context).pop(),
//                         ),
//                       ),
//                     ],
//                   ),
//                   // SizedBox(width: w * 0.02),
//                   Text(
//                     "Daily Challenges",
//                     style: TextStyle(
//                       fontSize: w * 0.1,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontFamily: 'Baloo2',
//                     ),
//                   ),

//                   // SizedBox(height: h * 0.01),
//                   const Text(
//                     "Complete tasks to earn rewards",
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontFamily: 'Baloo2',
//                     ),
//                   ),
//                   SizedBox(height: h * 0.02),
//                   Expanded(
//                     child: FutureBuilder<List<Map<String, dynamic>>>(
//                       future:
//                           BubbleGemFirestoreService.getOrGenerateDailyChallenges(),
//                       builder: (context, snapshot) {
//                         if (!snapshot.hasData)
//                           return const Center(
//                             child: CircularProgressIndicator(),
//                           );

//                         final firestoreList = snapshot.data!;

//                         return ListView.builder(
//                           itemCount: firestoreList.length,
//                           itemBuilder: (context, index) {
//                             final progressData = firestoreList[index];
//                             // Link Firestore ID back to the local GameChallenge definition
//                             final definition = ChallengeDataService
//                                 .allChallenges
//                                 .cast<GameChallenge?>()
//                                 .firstWhere(
//                                   (c) => c?.id == progressData['id'],
//                                   orElse: () => null,
//                                 );
//                             if (definition == null) {
//                               return const SizedBox.shrink();
//                             }

//                             bool isCompleted = progressData['isCompleted'];
//                             bool isClaimed = progressData['isClaimed'];
//                             double progress =
//                                 (progressData['current'] / definition.target)
//                                     .clamp(0.0, 1.0);

//                             return _staggeredWrapper(
//                               index,
//                               _buildChallengeCard(
//                                 size,
//                                 context,
//                                 definition,
//                                 progressData,
//                                 isCompleted,
//                                 isClaimed,
//                                 progress,
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildChallengeCard(
//     Size size,
//     BuildContext context,
//     GameChallenge definition,
//     Map<String, dynamic> progressData,
//     bool isCompleted,
//     bool isClaimed,
//     double progress,
//   ) {
//     double w = size.width;
//     double h = size.height;
//     return Container(
//       margin: const EdgeInsets.only(bottom: 30, left: 5, right: 5),
//       padding: EdgeInsets.all(w * 0.04),
//       decoration: BoxDecoration(
//         color: isCompleted ? Colors.white.withOpacity(0.15) : Colors.white10,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: isCompleted
//               ? Colors.greenAccent.withOpacity(0.5)
//               : title1.withValues(alpha: 0.3),
//         ),
//         boxShadow: isCompleted
//             ? [
//                 BoxShadow(
//                   color: Colors.greenAccent.withOpacity(0.1),
//                   blurRadius: 10,
//                   spreadRadius: 2,
//                   offset: Offset(0, 5),
//                 ),
//               ]
//             : [
//                 BoxShadow(
//                   color: title2.withValues(alpha: 0.15),
//                   blurRadius: 20,
//                   offset: Offset(0, 10),
//                   spreadRadius: 10,
//                 ),
//               ],
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               // Icon Circle (Like the Play/Lock icon in SelectZone)
//               Container(
//                 width: w * 0.12,
//                 height: w * 0.12,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   gradient: LinearGradient(
//                     colors: isCompleted
//                         ? [Colors.green, Colors.teal]
//                         : [title1, title2],
//                   ),
//                 ),
//                 child: Icon(
//                   isCompleted ? Icons.check : Icons.star_outline,
//                   color: Colors.white,
//                   size: w * 0.07,
//                 ),
//               ),
//               const SizedBox(width: 15),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       definition.title,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: w * 0.055,
//                         fontWeight: FontWeight.bold,
//                         fontFamily: 'Baloo2',
//                       ),
//                     ),
//                     Text(
//                       "Reward: ${definition.coinReward} 🪙",
//                       style: const TextStyle(
//                         color: Colors.amber,
//                         fontFamily: 'Baloo2',
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(width: 10),
//               //Action Button
//               SizedBox(
//                 width: w * 0.28,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: isClaimed
//                         ? Colors.grey.withOpacity(0.3)
//                         : (isCompleted ? Colors.greenAccent : title1),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 10),
//                   ),
//                   onPressed: (isCompleted && !isClaimed)
//                       ? () async {
//                           bool success =
//                               await BubbleGemFirestoreService.claimChallengeReward(
//                                 definition.id,
//                                 definition.coinReward,
//                               );
//                           if (success) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text("Reward Claimed!")),
//                             );
//                             // Trigger a rebuild toupdate the UI
//                             (context as Element).markNeedsBuild();
//                           }
//                         }
//                       : null,
//                   child: Text(
//                     isClaimed
//                         ? "DONE"
//                         : (isCompleted
//                               ? "CLAIM"
//                               : "${progressData['current']?.toInt() ?? 0} / ${definition.target}"),
//                     style: TextStyle(
//                       color: isCompleted
//                           ? whitecolor
//                           : isClaimed
//                           ? Colors.black
//                           : Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontFamily: 'Baloo2',
//                       fontSize: w * 0.04,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: h * 0.02),
//           // Progress Bar
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: LinearProgressIndicator(
//               value: progress,
//               minHeight: 8,
//               backgroundColor: Colors.white,
//               color: isCompleted ? Colors.greenAccent : title2,
//             ),
//           ),
//           const SizedBox(height: 10),
//         ],
//       ),
//     );
//   }

//   Widget _staggeredWrapper(int index, Widget child) {
//     return TweenAnimationBuilder<double>(
//       key: ValueKey('challenge_card_$index'),
//       tween: Tween(begin: 0.0, end: 1.0),
//       duration: const Duration(
//         milliseconds: 800,
//       ), // Slightly faster for challenges
//       curve: Curves.easeOutBack,
//       builder: (context, value, child) {
//         double delay = index * 0.15; // Stagger effect
//         double animatedValue = (value - delay).clamp(0.0, 1.0);

//         return Transform.translate(
//           offset: Offset(0, 60 * (1 - animatedValue)),
//           child: child,
//         );
//       },
//       child: child,
//     );
//   }
// }
class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key});

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
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // const SizedBox(height: 10),
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
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                  // SizedBox(width: w * 0.02),
                  Text(
                    "Daily Challenges",
                    style: TextStyle(
                      fontSize: w * 0.1,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Baloo2',
                    ),
                  ),

                  // SizedBox(height: h * 0.01),
                  const Text(
                    "Complete tasks to earn rewards",
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'Baloo2',
                    ),
                  ),
                  SizedBox(height: h * 0.02),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future:
                          BubbleGemFirestoreService.getOrGenerateDailyChallenges(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return const Center(
                            child: CircularProgressIndicator(),
                          );

                        final firestoreList = snapshot.data!;

                        return ListView.builder(
                          itemCount: firestoreList.length,
                          itemBuilder: (context, index) {
                            final progressData = firestoreList[index];
                            // Link Firestore ID back to the local GameChallenge definition
                            final definition = ChallengeDataService
                                .allChallenges
                                .cast<GameChallenge?>()
                                .firstWhere(
                                  (c) => c?.id == progressData['id'],
                                  orElse: () => null,
                                );
                            if (definition == null) {
                              return const SizedBox.shrink();
                            }

                            bool isCompleted = progressData['isCompleted'];
                            bool isClaimed = progressData['isClaimed'];
                            double progress =
                                (progressData['current'] / definition.target)
                                    .clamp(0.0, 1.0);

                            return _staggeredWrapper(
                              index,
                              _buildChallengeCard(
                                size,
                                context,
                                definition,
                                progressData,
                                isCompleted,
                                isClaimed,
                                progress,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(
    Size size,
    BuildContext context,
    GameChallenge definition,
    Map<String, dynamic> progressData,
    bool isCompleted,
    bool isClaimed,
    double progress,
  ) {
    double w = size.width;
    double h = size.height;
    return Container(
      margin: const EdgeInsets.only(bottom: 30, left: 5, right: 5),
      padding: EdgeInsets.all(w * 0.04),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.white.withOpacity(0.15) : Colors.white10,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? Colors.greenAccent.withOpacity(0.5)
              : title1.withValues(alpha: 0.3),
        ),
        boxShadow: isCompleted
            ? [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: Offset(0, 5),
                ),
              ]
            : [
                BoxShadow(
                  color: title2.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                  spreadRadius: 10,
                ),
              ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icon Circle (Like the Play/Lock icon in SelectZone)
              Container(
                width: w * 0.12,
                height: w * 0.12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: isCompleted
                        ? [Colors.green, Colors.teal]
                        : [title1, title2],
                  ),
                ),
                child: Icon(
                  isCompleted ? Icons.check : Icons.star_outline,
                  color: Colors.white,
                  size: w * 0.07,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      definition.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: w * 0.055,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Baloo2',
                      ),
                    ),
                    Text(
                      "Reward: ${definition.coinReward} 🪙",
                      style: const TextStyle(
                        color: Colors.amber,
                        fontFamily: 'Baloo2',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10),
              //Action Button
              SizedBox(
                width: w * 0.28,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isClaimed
                        ? Colors.grey.withOpacity(0.3)
                        : (isCompleted ? Colors.greenAccent : title1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: (isCompleted && !isClaimed)
                      ? () async {
                          bool success =
                              await BubbleGemFirestoreService.claimChallengeReward(
                                definition.id,
                                definition.coinReward,
                              );
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Reward Claimed!")),
                            );
                            // Trigger a rebuild toupdate the UI
                            (context as Element).markNeedsBuild();
                          }
                        }
                      : null,
                  child: Text(
                    isClaimed
                        ? "DONE"
                        : (isCompleted
                              ? "CLAIM"
                              : "${progressData['current']?.toInt() ?? 0} / ${definition.target}"),
                    style: TextStyle(
                      color: isCompleted
                          ? whitecolor
                          : isClaimed
                          ? Colors.black
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Baloo2',
                      fontSize: w * 0.04,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: h * 0.02),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white,
              color: isCompleted ? Colors.greenAccent : title2,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _staggeredWrapper(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('challenge_card_$index'),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(
        milliseconds: 800,
      ), // Slightly faster for challenges
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        double delay = index * 0.15; // Stagger effect
        double animatedValue = (value - delay).clamp(0.0, 1.0);

        return Transform.translate(
          offset: Offset(0, 60 * (1 - animatedValue)),
          child: child,
        );
      },
      child: child,
    );
  }
}