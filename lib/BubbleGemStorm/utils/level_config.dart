import 'package:flutter/material.dart';

import '../screens/game_screen.dart';
import 'bubble_gem_firestore_service.dart';

enum GameTier { tier1, tier2, tier3 }

class LevelConfig {
  final int id; // Global ID (1 to 65)
  final int localLevel; // Levelwithin the tier (e.g., 1 to 15)
  final GameTier tier;
  final ObjectiveType objective;
  final int targetValue;
  final int? timeLimit;
  final double spawnRate;
  final double speed;

  LevelConfig({
    required this.id,
    required this.localLevel,
    required this.tier,
    required this.objective,
    required this.targetValue,
    this.timeLimit,
    this.speed = 1.0,
    this.spawnRate = 900,
  });
}

// Helper to generate levels easily
List<LevelConfig> generateAllLevels() {
  List<LevelConfig> levels = [];
  int globalId = 1;

  // TIER 1: Score Target (20 Levels)
  for (int i = 1; i <= 20; i++) {
    levels.add(
      LevelConfig(
        id: globalId++,
        localLevel: i,
        tier: GameTier.tier1,
        objective: ObjectiveType.score,
        targetValue: 1, //20 + (i * 10), // Scales from 30 to 220
        speed: 1.2 + (i * 0.05), //1.5 + (i * 0.08), // Gradual speed increase
        spawnRate:
            1500 -
            (i * 20), //1000 - (i * 15), // Gradual spawn frequency increase
      ),
    );
  }

  // TIER 2: Survival (30 Levels)
  for (int i = 1; i <= 30; i++) {
    levels.add(
      LevelConfig(
        id: globalId++,
        localLevel: i,
        tier: GameTier.tier2,
        objective: ObjectiveType.survive,
        targetValue: 20 + (i * 2), //30 + (i * 3), // Scales from 22s to 80s
        speed: 1.8 + (i * 0.04), //2.5 + (i * 0.07), // Faster base speed
        spawnRate: 1200 - (i * 15), //800 - (i * 10), // More gems on screen
      ),
    );
  }

  // TIER 3: Clear Gems (50 Levels)
  for (int i = 1; i <= 50; i++) {
    levels.add(
      LevelConfig(
        id: globalId++,
        localLevel: i,
        tier: GameTier.tier3,
        objective: ObjectiveType.clearGems,
        targetValue: 15 + (i * 1.5).toInt(), //20 + (i * 2),
        timeLimit: 80 + (i * 2), //60 + (i > 25 ? 30 : 0),
        speed: 2.2 + (i * 0.03), //3.5 + (i * 0.04), // Very fast
        spawnRate: 1000 - (i * 10), //600 - (i * 5), // Intense spawning
      ),
    );
  }
  return levels;
}

final List<LevelConfig> myCustomLevels = generateAllLevels();

class TierTheme {
  final String name;
  final List<Color> gradient;
  final String backgroundImage; // e.g., 'assets/map/jungle.png'
  final Color pathColor;

  TierTheme({
    required this.name,
    required this.gradient,
    required this.backgroundImage,
    required this.pathColor,
  });
}

final Map<GameTier, TierTheme> tierThemes = {
  GameTier.tier1: TierTheme(
    name: "Crystal Caverns",
    gradient: [Color(0xff070F2B), Color(0xFF00bcd4)],
    backgroundImage: 'assets/map/jungle_bg.png',
    pathColor: Colors.greenAccent,
  ),
  GameTier.tier2: TierTheme(
    name: "Neon Heights",
    gradient: [Color(0xFF0d47a1), Color(0xFF6a1b9a)],
    backgroundImage: 'assets/map/space_bg.png',
    pathColor: Colors.purpleAccent,
  ),
  GameTier.tier3: TierTheme(
    name: "Galaxy Depths",
    gradient: [Color(0xFFb71c1c), Color(0xFFff6f00)],
    backgroundImage: 'assets/map/lava_bg.png',
    pathColor: Colors.orangeAccent,
  ),
};

class TierThemeManager extends ChangeNotifier {
  TierTheme _current = tierThemes[GameTier.tier1]!;
  TierTheme get current => _current;

  TierThemeManager() {
    _listenToProgress();
  }

  void _listenToProgress() {
    BubbleGemFirestoreService.unlockedLevelStream().listen((level) {
      GameTier newTier;
      if (level > 50) {
        newTier = GameTier.tier3;
      } else if (level > 20) {
        newTier = GameTier.tier2;
      } else {
        newTier = GameTier.tier1;
      }

      if (tierThemes[newTier] != _current) {
        _current = tierThemes[newTier]!;
        notifyListeners(); // This tells the whole app to rebuild with new colors!
      }
    });
  }
}

// Global instance
final tierThemeManager = TierThemeManager();