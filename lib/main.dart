import 'package:flutter/material.dart';

import 'dart:ui';

import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'BubbleGemStorm/utils/ad_service.dart';
import 'app_router.dart';
import 'firebase_options.dart';

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
    return MaterialApp.router(
      title: 'Bubble Gem Storm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      routerConfig: appRouter,
    );
  }
}
