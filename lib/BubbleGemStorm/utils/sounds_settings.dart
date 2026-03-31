import 'package:shared_preferences/shared_preferences.dart';

class SoundSettings {
  static const _key = 'sound_enabled';

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true;
  }

  static Future<bool> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_key, value);
  }
}
