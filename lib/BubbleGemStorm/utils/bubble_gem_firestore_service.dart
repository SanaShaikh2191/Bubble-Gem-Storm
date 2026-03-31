import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../screens/game_screen.dart';
import 'game_challenge.dart';
import 'level_config.dart';

// class BubbleGemFirestoreService {
//   BubbleGemFirestoreService._();
//
//   static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   static final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   static DocumentReference<Map<String, dynamic>> get _doc {
//     final uid = _auth.currentUser!.uid;
//     return _firestore.collection('bubble_gem_storm').doc(uid);
//   }
//
//   // ---------------- HIGH SCORE ----------------
//
//   static Future<void> updateHighScore(int newScore) async {
//     final user = _auth.currentUser;
//     if (user == null) return;
//
//     await _firestore.runTransaction((transaction) async {
//       final snapshot = await transaction.get(_doc);
//
//       int currentHighScore = 0;
//
//       if (snapshot.exists) {
//         currentHighScore = (snapshot.data()?['highScore'] ?? 0) as int;
//       }
//
//       if (newScore > currentHighScore) {
//         transaction.set(_doc, {
//           'highScore': newScore,
//           'updatedAt': FieldValue.serverTimestamp(),
//         }, SetOptions(merge: true));
//       }
//     });
//   }
//
//   static Stream<int> highScoreStream() {
//     return _auth.authStateChanges().asyncExpand((user) {
//       if (user == null) return const Stream<int>.empty();
//
//       return _firestore
//           .collection('bubble_gem_storm')
//           .doc(user.uid)
//           .snapshots()
//           .map<int>((snapshot) => snapshot.data()?['highScore'] ?? 0)
//           .distinct();
//     });
//   }
//
//   // ---------------- LEVEL SYSTEM ----------------
//
//   static Future<void> unlockNextLevel(int currentLevel) async {
//     final user = _auth.currentUser;
//     if (user == null) return;
//
//     await _firestore.runTransaction((transaction) async {
//       final snapshot = await transaction.get(_doc);
//
//       int unlockedLevel = 1;
//
//       if (snapshot.exists) {
//         unlockedLevel = (snapshot.data()?['unlockedLevel'] ?? 1) as int;
//       }
//
//       if (currentLevel + 1 > unlockedLevel) {
//         transaction.set(_doc, {
//           'unlockedLevel': currentLevel + 1,
//         }, SetOptions(merge: true));
//       }
//     });
//   }
//
//   static Stream<int> unlockedLevelStream() {
//     return _auth.authStateChanges().asyncExpand((user) {
//       if (user == null) return const Stream<int>.empty();
//
//       return _firestore
//           .collection('bubble_gem_storm')
//           .doc(user.uid)
//           .snapshots()
//           .map<int>((snapshot) => snapshot.data()?['unlockedLevel'] ?? 1)
//           .distinct();
//     });
//   }
//
//   static Future<void> resetProgress() async {
//     final user = _auth.currentUser;
//     if (user == null) return;
//
//     try {
//       await _doc.set({
//         'unlockedLevel': 1,
//         'highScore': 0,
//         'resetAt': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));
//       print("Progress reset successfully");
//     } catch (e) {
//       print("Error resetting progress: $e");
//       rethrow;
//     }
//   }
//   // ---------------- MISSION REPORT / STATS ----------------
//
//   /// Records an attempt for a specific level.
//   /// Increments the 'attempts' counter inside a 'stats' map in Firestore.
//   static Future<void> recordAttempt(int levelId) async {
//     final user = _auth.currentUser;
//     if (user == null) return;
//
//     await _doc.set({
//       'stats': {
//         '$levelId': {'attempts': FieldValue.increment(1)},
//       },
//       'lastPlayed': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }
//
//   static Future<int> getLevelAttempts(int levelId) async {
//     final snapshot = await _doc.get();
//     if (!snapshot.exists) return 1;
//
//     final data = snapshot.data()!;
//     final statsMap = data['stats'] as Map? ?? {};
//     final levelData = statsMap['$levelId'] as Map? ?? {};
//
//     return (levelData['attempts'] ?? 1) as int;
//   }
//
//   // Record Gem Popped (Call this every time a gem is tapped) ---
//   // static Future<void> recordGemPopped(GemType type) async {
//   //   final user = _auth.currentUser;
//   //   if (user == null) return;
//   //
//   //   String gemName = type.name; // This gets "bomb", "golden", etc.
//   //
//   //   await _doc.set({
//   //     'collection': {
//   //       gemName: FieldValue.increment(
//   //         1,
//   //       ), // Use the variable, NOT 'gemKey' in quotes
//   //     },
//   //     'totalGemsPopped': FieldValue.increment(1),
//   //   }, SetOptions(merge: true));
//   // }
//
//   /// Records which gem type caused the player to lose a life
//   static Future<void> recordNemesisHit(GemType type) async {
//     final user = _auth.currentUser;
//     if (user == null) return;
//
//     String gemKey = type.name;
//
//     await _doc.set({
//       'nemesisStats': {gemKey: FieldValue.increment(1)},
//     }, SetOptions(merge: true));
//   }
//
//   /// NEW: Fetches EVERYTHING (Levels, Collection, Nemesis) for the Report Screen
//   static Future<Map<String, dynamic>> getFullReportData() async {
//     final user = _auth.currentUser;
//     if (user == null) return {};
//
//     final snapshot = await _doc.get();
//     if (!snapshot.exists) return {};
//
//     final data = snapshot.data()!;
//
//     //We still need the LevelStats list for the bottom part of the screen
//     final statsMap = data['stats'] as Map? ?? {};
//     final unlockedLevel = data['unlockedLevel'] ?? 1;
//     List<LevelStat> levelStats = [];
//
//     for (var level in myCustomLevels) {
//       final levelData = statsMap['${level.id}'] as Map? ?? {};
//       levelStats.add(
//         LevelStat(
//           levelId: level.id,
//           attempts: levelData['attempts'] ?? 0,
//           isCompleted: unlockedLevel > level.id,
//           bestScore: 0,
//         ),
//       );
//     }
//
//     // Return a Map containing both the Level List AND the Global Stats
//     return {
//       'levelStats': levelStats,
//       'collection': Map<String, dynamic>.from(data['collection'] ?? {}),
//       'nemesis': Map<String, dynamic>.from(data['nemesisStats'] ?? {}),
//       'totalGems': data['totalGemsPopped'] ?? 0,
//     };
//   }
//
//   static Future<Map<String, dynamic>> getSingleLevelStats(int levelId) async {
//     final snapshot = await _doc.get();
//     if (!snapshot.exists) return {'attempts': 0};
//     final data = snapshot.data()!;
//     final statsMap = data['stats'] as Map? ?? {};
//     return Map<String, dynamic>.from(statsMap['$levelId'] ?? {'attempts': 0});
//   }
//
//   // ---------------- COIN SYSTEM ----------------
//
//   /// Fetches current coin balance once
//   static Future<int> getCoins() async {
//     final snapshot = await _doc.get();
//     if (!snapshot.exists) return 0;
//     return (snapshot.data()?['coins'] ?? 0) as int;
//   }
//
//   /// Stream for the Home Screen to listen to coin changes in real-time
//   static Stream<int> coinsStream() {
//     return _auth.authStateChanges().asyncExpand((user) {
//       if (user == null) return const Stream<int>.empty();
//       return _doc
//           .snapshots()
//           .map<int>((snapshot) => snapshot.data()?['coins'] ?? 0)
//           .distinct();
//     });
//   }
//
//   /// Adds coins (e.g.,when level is completed)
//   static Future<void> addCoins(int amount) async {
//     final user = _auth.currentUser;
//     if (user == null) return;
//
//     await _doc.set({
//       'coins': FieldValue.increment(amount),
//     }, SetOptions(merge: true));
//   }
//
//   /// Spends coins (returns true if successful, false if not enough coins)
//   static Future<bool> spendCoins(int amount) async {
//     final user = _auth.currentUser;
//     if (user == null) return false;
//
//     return await _firestore.runTransaction((transaction) async {
//       final snapshot = await transaction.get(_doc);
//       int currentCoins = (snapshot.data()?['coins'] ?? 0) as int;
//
//       if (currentCoins < amount) return false;
//
//       transaction.update(_doc, {'coins': currentCoins - amount});
//       return true;
//     });
//   }
//
//   // Add these to your BubbleGemFirestoreService class
//
//   // ---------------- CHALLENGE SYSTEM ----------------/// Generates or fetches daily challenges from Firestore
//   static Future<List<Map<String, dynamic>>>
//   getOrGenerateDailyChallenges() async {
//     final snapshot = await _doc.get();
//     final now = DateTime.now().toIso8601String().split('T')[0];
//
//     if (snapshot.exists) {
//       final data = snapshot.data()!;
//       if (data['challengeDate'] == now) {
//         return List<Map<String, dynamic>>.from(data['dailyChallenges'] ?? []);
//       }
//     }
//
//     // Generate new random IDs from our Service
//     final randomChallenges = ChallengeDataService.getRandomDailyChallenges(3);
//     final newChallengeData = randomChallenges
//         .map(
//           (c) => {
//             'id': c.id,
//             'current': 0,
//             'isCompleted': false,
//             'isClaimed': false,
//           },
//         )
//         .toList();
//
//     await _doc.set({
//       'challengeDate': now,
//       'dailyChallenges': newChallengeData,
//     }, SetOptions(merge: true));
//
//     return newChallengeData;
//   }
//
//   /// Updates challenge progress in Firestore
//   static Future<void> updateChallengeProgress(
//     ChallengeType type,
//     int value,
//     Function(String) onNotify,
//   ) async {
//     final snapshot = await _doc.get();
//     if (!snapshot.exists) return;
//     List<dynamic> challenges = List.from(
//       snapshot.data()?['dailyChallenges'] ?? [],
//     );
//     bool changed = false;
//
//     for (var i = 0; i < challenges.length; i++) {
//       var firestoreData = challenges[i];
//       // Find the definition from our local service
//       final definition = ChallengeDataService.allChallenges
//           .cast<GameChallenge?>()
//           .firstWhere((c) => c?.id == firestoreData['id'], orElse: () => null);
//       if (definition == null) continue;
//
//       if (definition.type == type && !firestoreData['isCompleted']) {
//         if (type == ChallengeType.earnMultiplier) {
//           if (value > firestoreData['current'])
//             firestoreData['current'] = value;
//         } else if (type == ChallengeType.reachScore) {
//           firestoreData['current'] = value;
//         } else {
//           firestoreData['current'] += value;
//         }
//
//         if (firestoreData['current'] >= definition.target) {
//           firestoreData['isCompleted'] = true;
//           onNotify(definition.title);
//         }
//         challenges[i] = firestoreData;
//         changed = true;
//       }
//     }
//
//     if (changed) {
//       await _doc.update({'dailyChallenges': challenges});
//     }
//   }
//
//   /// Claims the reward for a completed challenge
//   static Future<bool> claimChallengeReward(
//     String challengeId,
//     int rewardAmount,
//   ) async {
//     return await _firestore.runTransaction((transaction) async {
//       final snapshot = await transaction.get(_doc);
//       List<dynamic> challenges = List.from(
//         snapshot.data()?['dailyChallenges'] ?? [],
//       );
//       int currentCoins = snapshot.data()?['coins'] ?? 0;
//
//       int index = challenges.indexWhere((c) => c['id'] == challengeId);
//       if (index != -1 &&
//           challenges[index]['isCompleted'] &&
//           !challenges[index]['isClaimed']) {
//         challenges[index]['isClaimed'] = true;
//         transaction.update(_doc, {
//           'dailyChallenges': challenges,
//           'coins': currentCoins + rewardAmount,
//         });
//         return true;
//       }
//       return false;
//     });
//   }
//
//   static Future<void> syncAllChallenges({
//     required int gemsPopped,
//     required int finalScore,
//     required int maxCombo,
//     required int secondsSurvived,
//     required Function(String, String) onNotify,
//   }) async {
//     final snapshot = await _doc.get();
//     if (!snapshot.exists) return;
//
//     List<dynamic> challenges = List.from(
//       snapshot.data()?['dailyChallenges'] ?? [],
//     );
//     bool changed = false;
//
//     for (var i = 0; i < challenges.length; i++) {
//       var firestoreData = challenges[i];
//       final definition = ChallengeDataService.allChallenges
//           .cast<GameChallenge?>()
//           .firstWhere((c) => c?.id == firestoreData['id'], orElse: () => null);
//
//       if (definition == null || firestoreData['isCompleted']) continue;
//
//       // Applylogic based on challenge type
//       switch (definition.type) {
//         case ChallengeType.popGems:
//           firestoreData['current'] += gemsPopped;
//           changed = true;
//           break;
//         case ChallengeType.reachScore:
//           if (finalScore > firestoreData['current']) {
//             firestoreData['current'] = finalScore;
//             changed = true;
//           }
//           break;
//         case ChallengeType.earnMultiplier:
//           if (maxCombo > firestoreData['current']) {
//             firestoreData['current'] = maxCombo;
//             changed = true;
//           }
//           break;
//         case ChallengeType.surviveTime:
//           firestoreData['current'] += secondsSurvived;
//           changed = true;
//           break;
//       }
//
//       // Check for completion
//       if (firestoreData['current'] >= definition.target) {
//         firestoreData['isCompleted'] = true;
//         onNotify(definition.title, definition.id);
//       }
//       challenges[i] = firestoreData;
//     }
//
//     if (changed) {
//       await _doc.update({'dailyChallenges': challenges});
//     }
//   }
//   // ---------------- STREAK SYSTEM ----------------
//
//   static Stream<Map<String, dynamic>> streakStream() {
//     return _auth.authStateChanges().asyncExpand((user) {
//       if (user == null) return const Stream.empty();
//       return _doc.snapshots().map((snapshot) {
//         final data = snapshot.data() ?? {};
//         return {
//           'streak': data['streak'] ?? 0,
//           'lastCheckIn': data['lastCheckIn'],
//           'hasClaimedToday': _isSameDay(data['lastCheckIn'] as Timestamp?),
//         };
//       });
//     });
//   }
//
//   static bool _isSameDay(Timestamp? timestamp) {
//     if (timestamp == null) return false;
//     final lastDate = timestamp.toDate();
//     final now = DateTime.now();
//     return lastDate.year == now.year &&
//         lastDate.month == now.month &&
//         lastDate.day == now.day;
//   }
//
//   static Future<int?> checkAndUpdateStreak() async {
//     final user = _auth.currentUser;
//     if (user == null) return null;
//
//     final snapshot = await _doc.get();
//     final data = snapshot.data() ?? {};
//
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final lastCheckInTs = data['lastCheckIn'] as Timestamp?;
//     int currentStreak = data['streak'] ?? 0;
//
//     if (lastCheckInTs != null) {
//       final lastDate = lastCheckInTs.toDate();
//       final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
//       final difference = today.difference(lastDay).inDays;
//
//       if (difference == 0) return null; // Already checked in today
//
//       if (difference == 1) {
//         currentStreak += 1;
//       } else {
//         currentStreak = 1; // Streak broken
//       }
//     } else {
//       currentStreak = 1; // First time
//     }
//
//     await _doc.set({
//       'streak': currentStreak,
//       'lastCheckIn': Timestamp.fromDate(today),
//     }, SetOptions(merge: true));
//
//     // Return the streak count if it's a multiple of 3 to trigger the reward
//     if (currentStreak % 3 == 0) {
//       return currentStreak;
//     }
//     return null;
//   }
// }
//
// class LevelStat {
//   final int levelId;
//   final int attempts;
//   final bool isCompleted;
//   final int bestScore;
//   final int stars; // 0 to 3 stars
//   final Map<String, int> gemCounts; // e.g., {'normal': 50, 'bomb': 5}
//
//   LevelStat({
//     required this.levelId,
//     required this.attempts,
//     required this.isCompleted,
//     required this.bestScore,
//     this.stars = 0,
//     this.gemCounts = const {},
//   });
// }

class BubbleGemFirestoreService {
  BubbleGemFirestoreService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ---------------- DOCUMENT HELPERS ----------------
  // Collection: user (Profile Info)
  static DocumentReference<Map<String, dynamic>> get _userDoc =>
      _firestore.collection('user').doc(_auth.currentUser!.uid);

  // Collection: progress (Coins, Streaks, Stats)
  static DocumentReference<Map<String, dynamic>> get _progressDoc =>
      _firestore.collection('user_progress').doc(_auth.currentUser!.uid);

  // Collection: challenges
  static DocumentReference<Map<String, dynamic>> get _challengeDoc =>
      _firestore.collection('daily_challenges').doc(_auth.currentUser!.uid);

  static Future<void> initializeNewUser(User user) async {
    final batch = _firestore.batch();

    // 1. Setup User Profile
    batch.set(_userDoc, {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoURL,
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // 2. Setup Progress(Coins, Streaks, Stats)
    // We use set with merge: true so we don't overwrite existing progress on re-login
    batch.set(_progressDoc, {
      'coins': FieldValue.increment(0), // Ensures field exists
      'highScore': FieldValue.increment(0),
      'unlockedLevel': 1,
      'streak': {'count': 0, 'lastCheckIn': null},
      'stats': {'totalGamesPlayed': 0},
    }, SetOptions(merge: true));

    await batch.commit();
  }

  // ---------------- HIGH SCORE & LEVELS (User Collection) ----------------
  static Future<void> updateHighScore(int newScore) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(_progressDoc);
      int currentHighScore = 0;
      if (snapshot.exists) {
        currentHighScore = (snapshot.data()?['highScore'] ?? 0) as int;
      }
      if (newScore > currentHighScore) {
        transaction.set(_progressDoc, {
          'highScore': newScore,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    });
  }

  static Stream<int> highScoreStream() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return const Stream<int>.empty();
      return _progressDoc
          .snapshots()
          .map<int>((snapshot) => snapshot.data()?['highScore'] ?? 0)
          .distinct();
    });
  }

  static Future<void> unlockNextLevel(int currentLevel) async {
    if (_auth.currentUser == null) return;
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(_progressDoc);
      int unlockedLevel = (snapshot.data()?['unlockedLevel'] ?? 1) as int;
      if (currentLevel + 1 > unlockedLevel) {
        transaction.set(_progressDoc, {
          'unlockedLevel': currentLevel + 1,
        }, SetOptions(merge: true));
      }
    });
  }

  static Stream<int> unlockedLevelStream() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return const Stream<int>.empty();
      return _progressDoc
          .snapshots()
          .map<int>((snapshot) => snapshot.data()?['unlockedLevel'] ?? 1)
          .distinct();
    });
  }

  //---------------- COIN SYSTEM (Coins Collection) ----------------
  static Stream<int> coinsStream() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return const Stream<int>.empty();
      return _progressDoc.snapshots().map<int>((snapshot) {
        return snapshot.data()?['coins'] ?? 0;
      }).distinct();
    });
  }

  static Future<int> getCoins() async {
    if (_auth.currentUser == null) return 0;
    final snapshot = await _progressDoc.get();
    if (!snapshot.exists) return 0;
    return (snapshot.data()?['coins'] ?? 0) as int;
  }

  static Future<void> addCoins(int amount) async {
    if (_auth.currentUser == null) return;
    await _progressDoc.set({
      'coins': FieldValue.increment(amount),
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<bool> spendCoins(int amount) async {
    if (_auth.currentUser == null) return false;
    return await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(_progressDoc);
      int currentCoins = (snapshot.data()?['coins'] ?? 0) as int;
      if (currentCoins < amount) return false;
      transaction.update(_progressDoc, {'coins': currentCoins - amount});
      return true;
    });
  }

  // ---------------- STATS SYSTEM (Stats Collection) ----------------
  static Future<void> recordAttempt(int levelId) async {
    if (_auth.currentUser == null) return;
    await _progressDoc.set({
      'levelStats': {
        '$levelId': {'attempts': FieldValue.increment(1)},
      },
      'lastPlayed': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>> getSingleLevelStats(int levelId) async {
    if (_auth.currentUser == null) return {'attempts': 0};
    final snapshot = await _progressDoc.get();
    if (!snapshot.exists) return {'attempts': 0};
    final data = snapshot.data()!;
    final statsMap = data['levelStats'] as Map? ?? {};
    return Map<String, dynamic>.from(statsMap['$levelId'] ?? {'attempts': 0});
  }

  static Future<void> recordNemesisHit(String gemTypeName) async {
    if (_auth.currentUser == null) return;
    await _progressDoc.set({
      'nemesisStats': {gemTypeName: FieldValue.increment(1)},
    }, SetOptions(merge: true));
  }

  static Future<int> getLevelAttempts(int levelId) async {
    final user = _auth.currentUser;
    if (user == null) return 1; // Default to 1 if not logged in

    try {
      final snapshot = await _progressDoc.get();

      if (!snapshot.exists) return 1; // First time playing any level

      final data = snapshot.data()!;

      // Look inside the 'levelStats' map for the specific level ID
      final statsMap = data['levelStats'] as Map<String, dynamic>? ?? {};
      final levelData =
          statsMap['$levelId'] as Map? ??
          {}; // Return the attempts, defaulting to 1 if this specific level hasn't been recorded yet
      return (levelData['attempts'] ?? 1) as int;
    } catch (e) {
      print("Error fetching level attempts: $e");
      return 1;
    }
  }

  // ---------------- CHALLENGE SYSTEM (Challenges Collection) ----------------

  static Future<List<Map<String, dynamic>>>
  getOrGenerateDailyChallenges() async {
    final snapshot = await _challengeDoc.get();
    final now = DateTime.now().toIso8601String().split('T')[0];

    if (snapshot.exists) {
      final data = snapshot.data()!;
      if (data['challengeDate'] == now) {
        return List<Map<String, dynamic>>.from(data['dailyChallenges'] ?? []);
      }
    } // Logic to generate new challenges (Assuming ChallengeDataService exists)
    final randomChallenges = ChallengeDataService.getRandomDailyChallenges(3);
    final newChallengeData = randomChallenges
        .map(
          (c) => {
            'id': c.id,
            'current': 0,
            'isCompleted': false,
            'isClaimed': false,
          },
        )
        .toList();

    await _challengeDoc.set({
      'challengeDate': now,
      'dailyChallenges': newChallengeData,
    }, SetOptions(merge: true));

    return newChallengeData;
  }

  static Future<bool> claimChallengeReward(
    String challengeId,
    int rewardAmount,
  ) async {
    if (_auth.currentUser == null) return false;

    return await _firestore.runTransaction((transaction) async {
      final challengeSnap = await transaction.get(_challengeDoc);
      final coinSnap = await transaction.get(_progressDoc);

      List<dynamic> challenges = List.from(
        challengeSnap.data()?['dailyChallenges'] ?? [],
      );
      int currentCoins = coinSnap.data()?['coins'] ?? 0;

      int index = challenges.indexWhere((c) => c['id'] == challengeId);

      if (index != -1 &&
          challenges[index]['isCompleted'] == true &&
          challenges[index]['isClaimed'] != true) {
        challenges[index]['isClaimed'] = true;

        // Update Challenges Collection
        transaction.update(_challengeDoc, {'dailyChallenges': challenges});

        // Update Coins Collection
        transaction.set(_progressDoc, {
          'coins': currentCoins + rewardAmount,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        return true;
      }
      return false;
    });
  }

  static Future<void> syncAllChallenges({
    required int gemsPopped,
    required int finalScore,
    required int maxCombo,
    required int secondsSurvived,
    required Function(String, String) onNotify,
  }) async {
    final snapshot = await _challengeDoc.get();
    if (!snapshot.exists) return;

    List<dynamic> challenges = List.from(
      snapshot.data()?['dailyChallenges'] ?? [],
    );
    bool changed = false;

    for (var i = 0; i < challenges.length; i++) {
      var firestoreData = challenges[i];
      final definition = ChallengeDataService.allChallenges
          .cast<GameChallenge?>()
          .firstWhere((c) => c?.id == firestoreData['id'], orElse: () => null);

      if (definition == null || firestoreData['isCompleted'])
        continue; // Update logic based on type.

      // Apply logic based on challenge type
      switch (definition.type) {
        case ChallengeType.popGems:
          firestoreData['current'] += gemsPopped;
          changed = true;
          break;
        case ChallengeType.reachScore:
          if (finalScore > firestoreData['current']) {
            firestoreData['current'] = finalScore;
            changed = true;
          }
          break;
        case ChallengeType.earnMultiplier:
          if (maxCombo > firestoreData['current']) {
            firestoreData['current'] = maxCombo;
            changed = true;
          }
          break;
        case ChallengeType.surviveTime:
          firestoreData['current'] += secondsSurvived;
          changed = true;
          break;
      }

      if (firestoreData['current'] >= definition.target) {
        firestoreData['isCompleted'] = true;
        onNotify(definition.title, definition.id);
      }
      challenges[i] = firestoreData;
      changed = true;
    }

    if (changed) {
      await _challengeDoc.update({'dailyChallenges': challenges});
    }
  }

  // ---------------- STREAK SYSTEM (Streaks Collection) ----------------
  static Stream<Map<String, dynamic>> streakStream() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return const Stream.empty();
      return _progressDoc.snapshots().map((snapshot) {
        final data = snapshot.data() ?? {};
        return {
          'streak': data['count'] ?? 0,
          'lastCheckIn': data['lastCheckIn'],
          'hasClaimedToday': _isSameDay(data['lastCheckIn'] as Timestamp?),
        };
      });
    });
  }

  static bool _isSameDay(Timestamp? timestamp) {
    if (timestamp == null) return false;
    final lastDate = timestamp.toDate();
    final now = DateTime.now();
    return lastDate.year == now.year &&
        lastDate.month == now.month &&
        lastDate.day == now.day;
  }

  static Future<Map<String, dynamic>?> checkAndUpdateStreak() async {
    if (_auth.currentUser == null) return null;

    final snapshot = await _progressDoc.get();
    final data = snapshot.data() ?? {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCheckInTs = data['lastCheckIn'] as Timestamp?;
    int currentStreak = data['count'] ?? 0;
    bool isNewDay = false;

    if (lastCheckInTs != null) {
      final lastDate = lastCheckInTs.toDate();
      final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
      final difference = today.difference(lastDay).inDays;

      if (difference == 0) return null;
      currentStreak = (difference == 1) ? currentStreak + 1 : 1;
      isNewDay = true;
    } else {
      currentStreak = 1;
      isNewDay = true;
    }
    List<String> boosters = ['shield', 'slowmo', 'magnet', 'time'];
    String rewardedBooster = boosters[Random().nextInt(boosters.length)];
    await _progressDoc.set({
      'count': currentStreak,
      'lastCheckIn': Timestamp.fromDate(today),
      'freeBooster': rewardedBooster,
    }, SetOptions(merge: true));

    return {
      'streak': currentStreak,
      'freeBooster': rewardedBooster,
      'isMilestone': currentStreak % 3 == 0,
    };
  }

  // Helper to check if a booster is currentlyfree
  static Future<String?> getFreeBooster() async {
    final snapshot = await _progressDoc.get();
    return snapshot.data()?['freeBooster'] as String?;
  }

  // Helper to consume the free booster after use
  static Future<void> consumeFreeBooster() async {
    await _progressDoc.update({'freeBooster': FieldValue.delete()});
  }

  // ---------------- RESET ALL ----------------
  static Future<void> resetProgress() async {
    if (_auth.currentUser == null) return;
    final batch = _firestore.batch();

    batch.set(_userDoc, {
      'unlockedLevel': 1,
      'highScore': 0,
    }, SetOptions(merge: true));
    batch.set(_progressDoc, {'balance': 0}, SetOptions(merge: true));
    batch.delete(_challengeDoc);
    batch.delete(_progressDoc);
    batch.delete(_progressDoc);

    await batch.commit();
  }
}

class LevelStat {
  final int levelId;
  final int attempts;
  final bool isCompleted;
  final int bestScore;
  final int stars; // 0 to 3 stars
  final Map<String, int> gemCounts; // e.g., {'normal': 50, 'bomb': 5}

  LevelStat({
    required this.levelId,
    required this.attempts,
    required this.isCompleted,
    required this.bestScore,
    this.stars = 0,
    this.gemCounts = const {},
  });
}
