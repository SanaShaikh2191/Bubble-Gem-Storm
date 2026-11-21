// import 'package:flutter/material.dart';

// import 'dart:ui';

// import 'package:device_preview/device_preview.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'BubbleGemStorm/utils/ad_service.dart';
// import 'app_router.dart';
// import 'firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   print('🔥APP STARTING');
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   print('🔥FIREBASE INITIALIZED');

//   FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

//   // This catches errors that happen outside of the Flutter framework.
//   PlatformDispatcher.instance.onError = (error, stack) {
//     FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
//     return true;
//   };
//   await AdService.instance.init();

//   runApp(
//     DevicePreview(
//       enabled: true,
//       builder: (context) {
//         return MyApp();
//       },
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       title: 'Bubble Gem Storm',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),

//       routerConfig: appRouter,
//     );
//   }
// }
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:one_second_hero/app_router.dart';
import 'package:one_second_hero/firebase_options.dart';

import 'BubbleGemStorm/utils/ad_service.dart';
import 'BubbleGemStorm/utils/app_text_theme.dart';
import 'BubbleGemStorm/utils/level_config.dart';
// import 'package:one_second_hero/mini-game/one_second_hero/theme/app_text_theme.dart';
// import 'package:one_second_hero/main%20app/utils/main_app_ad_service.dart';

// import 'mini-game 3/BubbleGemStorm/utils/constants.dart';
// import 'mini-game 3/BubbleGemStorm/utils/level_config.dart';
// import 'package:one_second_hero/main%20app/utils/app_showcase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🔥APP STARTING');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('🔥FIREBASE INITIALIZED');

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // This catches errors that happen outside of the Flutter framework.
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  // Enable offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  await AdService.instance.init();

  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) {
        return MyApp();
      },
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: tierThemeManager,
      builder: (context, child) {
        final theme = tierThemeManager.current;
        return MaterialApp.router(
          title: 'Bubble Gem Storm',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: theme.gradient[0],
            textTheme: AppTextTheme.textTheme,
            colorScheme: ColorScheme.fromSeed(seedColor: theme.gradient[1]),
          ),

          routerConfig: appRouter,
        );
      },
    );
  }
}