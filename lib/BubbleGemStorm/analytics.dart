import 'package:firebase_analytics/firebase_analytics.dart';

class BubbleGemAnalyticsService {
  BubbleGemAnalyticsService._();

  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // ---------------- LEVEL FLOW ----------------

  /// Logs when a player starts a specific level
  static Future<void> logLevelStart({required int levelId}) async {
    await _logEvent(name: 'bg_level_start', parameters: {'level_id': levelId});
  }

  /// Logs when a player clears a level successfully
  static Future<void> logLevelWin({
    required int levelId,
    required int score,
    required int stars,
  }) async {
    await _logEvent(
      name: 'bg_level_win',
      parameters: {'level_id': levelId, 'score': score, 'stars': stars},
    );
  }

  /// Logs when a player loses a level
  static Future<void> logGameOver({
    required int levelId,
    required int score,
    required int gemsPopped,
  }) async {
    await _logEvent(
      name: 'bg_game_over',
      parameters: {
        'level_id': levelId,
        'score': score,
        'gems_popped': gemsPopped,
      },
    );
  }

  // ---------------- ECONOMY & BOOSTERS ----------------

  /// Logs when a player spends coins on a booster
  static Future<void> logBoosterPurchased({
    required String boosterType,
    required int cost,
  }) async {
    await _logEvent(
      name: 'bg_booster_purchased',
      parameters: {'booster_type': boosterType, 'cost': cost},
    );
  }

  /// Logs when a player claimsa challenge reward
  static Future<void> logRewardClaimed({
    required String challengeId,
    required int coinAmount,
  }) async {
    await _logEvent(
      name: 'bg_reward_claimed',
      parameters: {'challenge_id': challengeId, 'coin_amount': coinAmount},
    );
  }

  // ---------------- INTERNAL ----------------

  static Future<void> _logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    // This print helps you debug in the VS Code console
    print('📊 Analytics : $name --> $parameters');
    await _analytics.logEvent(name: name, parameters: parameters);
  }
}
