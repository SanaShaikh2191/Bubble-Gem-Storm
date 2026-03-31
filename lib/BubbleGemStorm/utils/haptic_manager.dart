import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

class HapticManager {
  static Future<void> ligth() async {
    if (!await HapticSettings.isEnabled()) return;
    try {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 20, amplitude: 40);
      } else {
        HapticFeedback.lightImpact();
      }
    } catch (_) {
      HapticFeedback.lightImpact();
    }
  }

  static Future<void> medium() async {
    if (!await HapticSettings.isEnabled()) return;
    try {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 30, amplitude: 80);
      } else {
        HapticFeedback.mediumImpact();
      }
    } catch (_) {
      HapticFeedback.mediumImpact();
    }
  }

  static Future<void> heavy() async {
    if (!await HapticSettings.isEnabled()) return;
    try {
      if (await Vibration.hasVibrator()) {
        if (await Vibration.hasAmplitudeControl()) {
          Vibration.vibrate(
            pattern: [0, 40, 30, 70],
            intensities: [0, 180, 0, 255],
          );
        } else {
          Vibration.vibrate(duration: 100);
        }
      } else {
        HapticFeedback.heavyImpact();
      }
    } catch (_) {
      HapticFeedback.heavyImpact();
    }
  }
}

class HapticSettings {
  static const _key = 'haptics.enabled';

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true;
  }

  static Future<Future<bool>> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_key, value);
  }
}
