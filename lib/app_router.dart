import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'BubbleGemStorm/screens/bubble_gem_home_screen.dart';
import 'BubbleGemStorm/screens/challenge_screen.dart';
import 'BubbleGemStorm/screens/game_map_screen.dart';
import 'BubbleGemStorm/screens/game_screen.dart';
import 'BubbleGemStorm/screens/login_screen.dart';
import 'BubbleGemStorm/screens/profile_screen.dart';
import 'BubbleGemStorm/screens/setting.dart';
import 'BubbleGemStorm/screens/splash_screen.dart';
import 'BubbleGemStorm/utils/level_config.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',

  // --------------------------Main app------------------------------
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final location = state.matchedLocation;

    final isSplash = location == '/splash';
    final isLogin = location == '/login';

    // 🟡 Always allow splash
    if (isSplash) return null;

    // 🔐 Not logged in → login
    if (user == null) {
      return isLogin ? null : '/login';
    }

    // ✅ Logged in → block login
    if (isLogin) {
      return '/bubble-gem-home';
    }

    return null; // no redirect
  },
  routes: [
    // // GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
    //
    // // GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
    // GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
    //
    // // GoRoute(path: '/settings', builder: (_, _) => const SettingScreen()),
    // GoRoute(
    //   path: '/daily-challenge',
    //   builder: (_, _) => const DailyChallengesScreen(),
    // ),
    //
    // GoRoute(
    //   path: '/game',
    //   builder: (context, state) {
    //     final extra = state.extra as Map<String, dynamic>?;
    //
    //     return GameScreen(
    //       mode: extra?['mode'],
    //       dailyChallenge: extra?['challenge'],
    //     );
    //   },
    // ),
    //
    // // --------------------one second hero-------------------------------
    // GoRoute(
    //   path: '/one-second-hero-home',
    //   builder: (_, _) => OneSecondHeroHomeScreen(),
    //
    //   routes: [
    //     GoRoute(
    //       path: 'one-second-hero-game',
    //       builder: (context, state) {
    //         print('ROUTE EXTRA - ${state.extra}');
    //         final extra = state.extra as Map<String, dynamic>?;
    //
    //         return OneSecondHeroScreen(
    //           mode: extra?['mode'],
    //           dailyChallenge: extra?['challenge'],
    //         );
    //       },
    //     ),
    //   ],
    // ),
    //
    // // --------------------------------minigame 2 CIRCLE RUSH--------------------------------
    // GoRoute(
    //   path: '/circle-rush-home',
    //   builder: (context, state) {
    //     final extra = state.extra as Map<String, dynamic>?;
    //     final fromGameOver = extra?['fromGameOver'] ?? false;
    //     return CircleRushHomeScreen(
    //       // key: ValueKey('circle-rush-home'),
    //       fromGameOver: fromGameOver,
    //     );
    //   },
    // ),
    //
    // GoRoute(
    //   path: '/circle-rush-game',
    //   builder: (_, _) => const CircleRushGameScreen(),
    // ),

    // -----------------------------minigame 3 Bubble Gem Storm------------------------------------
    GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),

    GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),

    GoRoute(
      path: '/bubble-gem-home',

      builder: (_, _) => const BubbleGemHomeScreen(
        // key: ValueKey('bubble-gem-home')
      ),
    ),

    GoRoute(
      path: '/bubble-game',
      builder: (context, state) {
        final level =
            int.tryParse(state.uri.queryParameters['level'] ?? '1') ?? 1;
        final bool forceTutorial =
            state.uri.queryParameters['showTutorial'] == 'true';
        return GemGameScreen(
          level: level,
          forceTutorial: forceTutorial,
        ); // Pass it to the widget
      },
    ),
    GoRoute(
      path: '/bubble-gem-zone',

      builder: (_, _) => const SelectZoneScreen(),
    ),
    GoRoute(
      path: '/bubble-gem-map',
      builder: (context, state) {
        // Extract the unlocked level from query parameters (default to 1 if missing)
        final unlockedLevel =
            int.tryParse(state.uri.queryParameters['unlockedLevel'] ?? '1') ??
            1;
        final tierIndex =
            int.tryParse(state.uri.queryParameters['tier'] ?? '0') ?? 0;
        final selectedTier = GameTier.values[tierIndex];
        final zoneTitle = state.uri.queryParameters['title'] ?? 'Adventure Map';

        return GameMapScreen(
          currentUnlockedLevel: unlockedLevel,
          selectedTier: selectedTier,
          zoneTitle: zoneTitle,
        );
      },
    ),
    GoRoute(
      path: '/bubble-gem-profile',
      builder: (_, _) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/bubble-gem-settings',
      builder: (_, _) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/bubble-gem-challenge',
      builder: (_, _) => const ChallengeScreen(),
    ),
  ],
);

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
