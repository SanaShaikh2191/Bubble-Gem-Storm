// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
//
// import '../utils/bubble_gem_firestore_service.dart';
// import '../utils/constants.dart';
// import '../utils/level_config.dart';
//
// // class GameReportScreen extends StatelessWidget {
// //   const GameReportScreen({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final Color darkBg = const Color(0xFF000C1A);
// //
// //     return Scaffold(
// //       backgroundColor: darkBg,
// //       body: FutureBuilder<List<LevelStat>>(
// //         future: BubbleGemFirestoreService.getAllStats(),
// //         builder: (context, snapshot) {
// //           if (!snapshot.hasData) {
// //             return const Center(
// //               child: CircularProgressIndicator(color: title1),
// //             );
// //           }
// //
// //           final stats = snapshot.data!;
// //           final completedLevels = stats.where((s) => s.isCompleted).length;
// //           final totalAttempts = stats.fold(
// //             0,
// //             (sum, item) => sum + item.attempts,
// //           );
// //
// //           return CustomScrollView(
// //             slivers: [
// //               // --- STYLISH APP BAR ---
// //               SliverAppBar(
// //                 expandedHeight: 120,
// //                 backgroundColor: darkBg,
// //                 floating: false,
// //                 pinned: true,
// //                 // CUSTOM BACK BUTTON
// //                 leading: Padding(
// //                   padding: const EdgeInsets.all(8.0),
// //                   child: InkWell(
// //                     onTap: () => Navigator.pop(context),
// //                     child: Container(
// //                       decoration: BoxDecoration(
// //                         shape: BoxShape.circle,
// //                         color: Colors.white.withOpacity(0.1),
// //                         border: Border.all(color: Colors.white24),
// //                       ),
// //                       child: const Icon(
// //                         Icons.arrow_back_ios_new,
// //                         color: Colors.white,
// //                         size: 18,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //                 flexibleSpace: FlexibleSpaceBar(
// //                   centerTitle: true,
// //                   title: Text(
// //                     "STATISTICS",
// //                     style: TextStyle(
// //                       fontFamily: 'Baloo2',
// //                       fontWeight: FontWeight.w900,
// //                       letterSpacing: 2,
// //                       color: Colors.white,
// //                       shadows: [Shadow(color: title1, blurRadius: 10)],
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //
// //               // --- HEADER STATS CARD ---
// //               SliverToBoxAdapter(
// //                 child: _buildHeaderCard(completedLevels, totalAttempts),
// //               ),
// //
// //               // --- PROGRESS GRAPH ---
// //               SliverToBoxAdapter(child: _buildProgressGraph(stats)),
// //
// //               // --- SECTION TITLE ---
// //               const SliverToBoxAdapter(
// //                 child: Padding(
// //                   padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
// //                   child: Text(
// //                     "LEVEL BREAKDOWN",
// //                     style: TextStyle(
// //                       color: Colors.white54,
// //                       fontWeight: FontWeight.bold,
// //                       letterSpacing: 1.2,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //
// //               // --- LEVEL LIST ---
// //               SliverList(
// //                 delegate: SliverChildBuilderDelegate(
// //                   (context, index) =>
// //                       _buildLevelTile(stats[index], myCustomLevels[index]),
// //                   childCount: stats.length,
// //                 ),
// //               ),
// //               const SliverToBoxAdapter(child: SizedBox(height: 50)),
// //             ],
// //           );
// //         },
// //       ),
// //     );
// //   }
// //
// //   Widget _buildHeaderCard(int completed, int attempts) {
// //     return Container(
// //       margin: const EdgeInsets.all(16),
// //       padding: const EdgeInsets.all(24),
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(24),
// //         gradient: LinearGradient(
// //           colors: [title1.withOpacity(0.8), title2.withOpacity(0.8)],
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //             color: title1.withOpacity(0.3),
// //             blurRadius: 20,
// //             spreadRadius: 2,
// //           ),
// //         ],
// //       ),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceAround,
// //         children: [
// //           _bigStat("COMPLETED", "$completed", "LEVELS"),
// //           Container(width: 1, height: 50, color: Colors.white24),
// //           _bigStat("TOTAL", "$attempts", "ATTEMPTS"),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _bigStat(String label, String value, String sub) {
// //     return Column(
// //       children: [
// //         Text(
// //           label,
// //           style: const TextStyle(
// //             color: Colors.white70,
// //             fontSize: 10,
// //             fontWeight: FontWeight.bold,
// //           ),
// //         ),
// //         Text(
// //           value,
// //           style: const TextStyle(
// //             color: Colors.white,
// //             fontSize: 32,
// //             fontWeight: FontWeight.w900,
// //             fontFamily: 'Baloo2',
// //           ),
// //         ),
// //         Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 10)),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildProgressGraph(List<LevelStat> stats) {
// //     // Logic: Create data points based on completed levels
// //     List<FlSpot> spots = [];
// //     int completedCount = 0;
// //     for (int i = 0; i < stats.length; i++) {
// //       if (stats[i].isCompleted) completedCount++;
// //       if (i % 5 == 0 || i == stats.length - 1) {
// //         spots.add(FlSpot(i.toDouble(), completedCount.toDouble()));
// //       }
// //     }
// //
// //     return Container(
// //       height: 220,
// //       margin: const EdgeInsets.symmetric(horizontal: 16),
// //       padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
// //       decoration: BoxDecoration(
// //         color: Colors.white.withOpacity(0.03),
// //         borderRadius: BorderRadius.circular(24),
// //         border: Border.all(color: Colors.white10),
// //       ),
// //       child: LineChart(
// //         LineChartData(
// //           gridData: FlGridData(show: false),
// //           titlesData: FlTitlesData(show: false),
// //           borderData: FlBorderData(show: false),
// //           lineBarsData: [
// //             LineChartBarData(
// //               spots: spots,
// //               isCurved: true,
// //               color: title2,
// //               barWidth: 4,
// //               isStrokeCapRound: true,
// //               dotData: FlDotData(show: false),
// //               belowBarData: BarAreaData(
// //                 show: true,
// //                 gradient: LinearGradient(
// //                   colors: [title2.withOpacity(0.3), Colors.transparent],
// //                   begin: Alignment.topCenter,
// //                   end: Alignment.bottomCenter,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildLevelTile(LevelStat s, LevelConfig config) {
// //     bool isLocked = !s.isCompleted && s.attempts == 0;
// //
// //     return Container(
// //       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: s.isCompleted
// //             ? Colors.white.withOpacity(0.07)
// //             : Colors.white.withOpacity(0.02),
// //         borderRadius: BorderRadius.circular(16),
// //         border: Border.all(
// //           color: s.isCompleted ? title2.withOpacity(0.4) : Colors.white10,
// //           width: 1,
// //         ),
// //       ),
// //       child: Row(
// //         children: [
// //           // Level Number Circle
// //           Container(
// //             width: 45,
// //             height: 45,
// //             decoration: BoxDecoration(
// //               shape: BoxShape.circle,
// //               gradient: s.isCompleted
// //                   ? LinearGradient(colors: [title1, title2])
// //                   : const LinearGradient(colors: [Colors.grey, Colors.black87]),
// //             ),
// //             child: Center(
// //               child: Text(
// //                 "${config.localLevel}",
// //                 style: const TextStyle(
// //                   color: Colors.white,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ),
// //           ),
// //           const SizedBox(width: 16),
// //           // Info
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   "TIER ${config.tier.index + 1}: ${config.objective.name.toUpperCase()}",
// //                   style: TextStyle(
// //                     color: title1,
// //                     fontSize: 11,
// //                     fontWeight: FontWeight.bold,
// //                     letterSpacing: 1,
// //                   ),
// //                 ),
// //                 Text(
// //                   isLocked
// //                       ? "LOCKED"
// //                       : (s.isCompleted ? "LEVEL CLEARED ✅" : "IN PROGRESS"),
// //                   style: TextStyle(
// //                     color: isLocked ? Colors.white24 : Colors.white,
// //                     fontSize: 15,
// //                     fontFamily: 'Baloo2',
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           // Attempts
// //           Column(
// //             crossAxisAlignment: CrossAxisAlignment.end,
// //             children: [
// //               Text(
// //                 "${s.attempts}",
// //                 style: TextStyle(
// //                   color: s.attempts > 5 ? Colors.redAccent : Colors.amber,
// //                   fontWeight: FontWeight.bold,
// //                   fontSize: 18,
// //                 ),
// //               ),
// //               const Text(
// //                 "ATTEMPT",
// //                 style: TextStyle(color: Colors.white38, fontSize: 9),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// class GameReportScreen extends StatefulWidget {
//   const GameReportScreen({super.key});
//
//   @override
//   State<GameReportScreen> createState() => _GameReportScreenState();
// }
//
// class _GameReportScreenState extends State<GameReportScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     final Color darkBg = const Color(0xFF000C1A);
//
//     return Scaffold(
//       backgroundColor: darkBg,
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: BubbleGemFirestoreService.getFullReportData(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(
//               child: Text(
//                 "Error:${snapshot.error}",
//                 style: TextStyle(color: Colors.white),
//               ),
//             );
//           }
//           if (!snapshot.hasData)
//             return const Center(
//               child: CircularProgressIndicator(color: title1),
//             );
//
//           // 1. Extract the data from the snapshot
//           final data = snapshot.data!;
//           final List<LevelStat> stats = data['levelStats'];
//           final Map<String, dynamic> collection = data['collection'];
//           final Map<String, dynamic> nemesis = data['nemesis'];
//           final int totalGems = data['totalGems'] as int;
//
//           // 2. Calculate Nemesis Name (the gemthat hit you most)
//           String nemesisName = "None";
//           if (nemesis.isNotEmpty) {
//             nemesisName = nemesis.entries
//                 .reduce((a, b) => a.value > b.value ? a : b)
//                 .key;
//           }
//
//           //3. Calculate basic stats for the header
//           final completedLevels = stats.where((s) => s.isCompleted).length;
//           final totalAttempts = stats.fold(
//             0,
//             (sum, item) => sum + item.attempts,
//           );
//
//           return CustomScrollView(
//             slivers: [
//               _buildAppBar(context, darkBg),
//
//               // --- THE DATAMODULES PAGEVIEW ---
//               SliverToBoxAdapter(
//                 child: Column(
//                   children: [
//                     SizedBox(
//                       height: 260,
//                       child: PageView(
//                         controller: _pageController,
//                         onPageChanged: (i) => setState(() => _currentPage = i),
//                         children: [
//                           _moduleMastery(stats), // 1. Tier Mastery
//                           _moduleCollection(
//                             collection,
//                             totalGems,
//                           ), // 2. Gem Collection
//                           _moduleNemesis(nemesisName), // 3. Nemesis & Badges
//                           _moduleProgressGraph(stats), // 4. Visual Graph
//                         ],
//                       ),
//                     ),
//                     _buildPageIndicator(),
//                   ],
//                 ),
//               ),
//
//               const SliverToBoxAdapter(
//                 child: Padding(
//                   padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
//                   child: Text(
//                     "MISSION LOG",
//                     style: TextStyle(
//                       color: Colors.white54,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//
//               SliverList(
//                 delegate: SliverChildBuilderDelegate(
//                   (context, index) =>
//                       _buildLevelTile(stats[index], myCustomLevels[index]),
//                   childCount: stats.length,
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   // --- MODULE 1: TIER MASTERY (Circular Progress) ---
//   Widget _moduleMastery(List<LevelStat> stats) {
//     double t1 =
//         stats.where((s) => s.levelId <= 15 && s.isCompleted).length / 15;
//     double t2 =
//         stats
//             .where((s) => s.levelId > 15 && s.levelId <= 35 && s.isCompleted)
//             .length /
//         20;
//     double t3 = stats.where((s) => s.levelId > 35 && s.isCompleted).length / 30;
//
//     return _cardWrapper(
//       "TIER MASTERY",
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _circularProgress("T1", t1, Colors.blue),
//           _circularProgress("T2", t2, Colors.orange),
//           _circularProgress("T3", t3, Colors.purple),
//         ],
//       ),
//     );
//   }
//
//   // --- MODULE 2: GEM COLLECTION (Grid) ---
//   Widget _moduleCollection(Map<String, dynamic> collection, int total) {
//     return _cardWrapper(
//       "TOTAL COLLECTION",
//       GridView.count(
//         crossAxisCount: 3,
//         // shrinkWrap: true,
//         // physics: const NeverScrollableScrollPhysics(),
//         mainAxisSpacing: 0,
//         children: [
//           _miniStatItem(
//             Icons.auto_awesome,
//             "${collection['normal'] ?? 0}",
//             "Normal",
//           ),
//           _miniStatItem(Icons.bolt, "${collection['bomb'] ?? 0}", "Bombs"),
//           _miniStatItem(Icons.star, "${collection['golden'] ?? 0}", "Golden"),
//           _miniStatItem(
//             Icons.ac_unit,
//             "${collection['frozen'] ?? 0}",
//             "Frozen",
//           ),
//           _miniStatItem(
//             Icons.looks,
//             "${collection['rainbow'] ?? 0}",
//             "Rainbow",
//           ),
//           _miniStatItem(
//             Icons.flash_on,
//             "${collection['freezePowerUp'] ?? 0}",
//             "Powerups",
//           ),
//         ],
//       ),
//     );
//   }
//
//   // --- MODULE 3: NEMESIS & BADGES ---
//   Widget _moduleNemesis(String nemesisName) {
//     // Map the internal name to a display name and icon
//     IconData nemesisIcon = Icons.help_outline;
//     Color nemesisColor = Colors.white;
//
//     if (nemesisName == "frozen") {
//       nemesisIcon = Icons.ac_unit;
//       nemesisColor = Colors.cyanAccent;
//     } else if (nemesisName == "bomb") {
//       nemesisIcon = Icons.bolt;
//       nemesisColor = Colors.orangeAccent;
//     } else if (nemesisName == "normal") {
//       nemesisIcon = Icons.blur_on;
//       nemesisColor = Colors.blueAccent;
//     }
//     return _cardWrapper(
//       "PLAYER PROFILE",
//       Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _badgeItem(Icons.gps_fixed, "SNIPER", "High Accuracy"),
//                 _badgeItem(Icons.flash_on, "COMBO KING", "5x Multiplier"),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.red.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: Column(
//               children: [
//                 const Icon(
//                   Icons.warning_amber_rounded,
//                   color: Colors.redAccent,
//                 ),
//                 const Text(
//                   "NEMESIS",
//                   style: TextStyle(
//                     color: Colors.redAccent,
//                     fontSize: 10,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Icon(nemesisIcon, color: Colors.white, size: 30),
//                 Text(
//                   nemesisName.toUpperCase(),
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 10,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // --- MODULE 4: PROGRESS GRAPH ---
//   Widget _moduleProgressGraph(List<LevelStat> stats) {
//     return _cardWrapper("COMPLETION TREND", _buildProgressGraph(stats));
//   }
//
//   // --- HELPER UI COMPONENTS ---
//   Widget _cardWrapper(String title, Widget child) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: Colors.white10),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               color: title1,
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//               letterSpacing: 1.2,
//             ),
//           ),
//           const SizedBox(height: 15),
//           Expanded(child: child),
//         ],
//       ),
//     );
//   }
//
//   Widget _circularProgress(String label, double val, Color color) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Stack(
//           alignment: Alignment.center,
//           children: [
//             SizedBox(
//               width: 60,
//               height: 60,
//               child: CircularProgressIndicator(
//                 value: val,
//                 color: color,
//                 backgroundColor: Colors.white10,
//                 strokeWidth: 6,
//               ),
//             ),
//             Text(
//               "${(val * 100).toInt()}%",
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           style: const TextStyle(color: Colors.white54, fontSize: 12),
//         ),
//       ],
//     );
//   }
//
//   Widget _miniStatItem(IconData icon, String val, String label) {
//     return Column(
//       children: [
//         Icon(icon, color: title2, size: 20),
//         Text(
//           val,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9)),
//       ],
//     );
//   }
//
//   Widget _badgeItem(IconData icon, String name, String desc) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.amber, size: 24),
//           const SizedBox(width: 10),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 name,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 13,
//                 ),
//               ),
//               Text(
//                 desc,
//                 style: const TextStyle(color: Colors.white38, fontSize: 10),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPageIndicator() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(
//         4,
//         (index) => AnimatedContainer(
//           duration: const Duration(milliseconds: 300),
//           margin: const EdgeInsets.symmetric(horizontal: 4),
//           height: 8,
//           width: _currentPage == index ? 24 : 8,
//           decoration: BoxDecoration(
//             color: _currentPage == index ? title2 : Colors.white24,
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAppBar(BuildContext context, Color darkBg) {
//     return SliverAppBar(
//       expandedHeight: 100,
//       backgroundColor: darkBg,
//       floating: false,
//       pinned: true,
//       leading: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: InkWell(
//           onTap: () => Navigator.pop(context),
//           child: Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white.withOpacity(0.1),
//               border: Border.all(color: Colors.white24),
//             ),
//             child: const Icon(
//               Icons.arrow_back_ios_new,
//               color: Colors.white,
//               size: 18,
//             ),
//           ),
//         ),
//       ),
//       flexibleSpace: FlexibleSpaceBar(
//         centerTitle: true,
//         title: Text(
//           "STATISTICS",
//           style: TextStyle(
//             fontFamily: 'Baloo2',
//             fontWeight: FontWeight.w900,
//             letterSpacing: 2,
//             fontSize: 18,
//             color: Colors.white,
//             shadows: [Shadow(color: title1.withOpacity(0.5), blurRadius: 10)],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProgressGraph(List<LevelStat> stats) {
//     // Logic: Create data points based on completed levels
//     List<FlSpot> spots = [];
//     int completedCount = 0;
//     for (int i = 0; i < stats.length; i++) {
//       if (stats[i].isCompleted) completedCount++;
//       if (i % 5 == 0 || i == stats.length - 1) {
//         spots.add(FlSpot(i.toDouble(), completedCount.toDouble()));
//       }
//     }
//
//     return Container(
//       height: 220,
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.03),
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: Colors.white10),
//       ),
//       child: LineChart(
//         LineChartData(
//           gridData: FlGridData(show: false),
//           titlesData: FlTitlesData(show: false),
//           borderData: FlBorderData(show: false),
//           lineBarsData: [
//             LineChartBarData(
//               spots: spots,
//               isCurved: true,
//               color: title2,
//               barWidth: 4,
//               isStrokeCapRound: true,
//               dotData: FlDotData(show: false),
//               belowBarData: BarAreaData(
//                 show: true,
//                 gradient: LinearGradient(
//                   colors: [title2.withOpacity(0.3), Colors.transparent],
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLevelTile(LevelStat s, LevelConfig config) {
//     bool isLocked = !s.isCompleted && s.attempts == 0;
//
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: s.isCompleted
//             ? Colors.white.withOpacity(0.07)
//             : Colors.white.withOpacity(0.02),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: s.isCompleted ? title2.withOpacity(0.4) : Colors.white10,
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           // Level Number Circle
//           Container(
//             width: 45,
//             height: 45,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: s.isCompleted
//                   ? LinearGradient(colors: [title1, title2])
//                   : const LinearGradient(colors: [Colors.grey, Colors.black87]),
//             ),
//             child: Center(
//               child: Text(
//                 "${config.localLevel}",
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           // Info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "TIER ${config.tier.index + 1}: ${config.objective.name.toUpperCase()}",
//                   style: TextStyle(
//                     color: title1,
//                     fontSize: 11,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1,
//                   ),
//                 ),
//                 Text(
//                   isLocked
//                       ? "LOCKED"
//                       : (s.isCompleted ? "LEVEL CLEARED ✅" : "IN PROGRESS"),
//                   style: TextStyle(
//                     color: isLocked ? Colors.white24 : Colors.white,
//                     fontSize: 15,
//                     fontFamily: 'Baloo2',
//                   ),
//                 ),
//                 // --- STAR SYSTEM UI ---
//                 if (s.isCompleted)
//                   Row(
//                     children: List.generate(3, (index) {
//                       return Icon(
//                         Icons.star_rounded,
//                         size: 16,
//                         // Logic: If attempts < 2 give 3 stars, < 5 give 2 stars, else 1
//                         color:
//                             index <
//                                 (s.attempts < 2
//                                     ? 3
//                                     : s.attempts < 5
//                                     ? 2
//                                     : 1)
//                             ? Colors.amber
//                             : Colors.white10,
//                       );
//                     }),
//                   ),
//               ],
//             ),
//           ),
//           // Attempts
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 "${s.attempts}",
//                 style: TextStyle(
//                   color: s.attempts > 5 ? Colors.redAccent : Colors.amber,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//               const Text(
//                 "ATTEMPT",
//                 style: TextStyle(color: Colors.white38, fontSize: 9),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ... Keep your existing _buildAppBar, _buildProgressGraph, and _buildLevelTile methods ...
// }
