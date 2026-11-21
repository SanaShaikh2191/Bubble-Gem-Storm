// import 'package:audioplayers/audioplayers.dart';
// import '../screens/game_screen.dart';
// import '../utils/sounds_settings.dart';

// class SoundManager {
//   // Singleton pattern
//   static final SoundManager instance = SoundManager._internal();
//   SoundManager._internal(); // A pool of players to handle overlapping sounds without lag
//   final List<AudioPlayer> _playerPool = [];
//   final int _poolSize = 10; // Maximum simultaneous sounds
//   int _currentPlayerIndex = 0;

//   final AudioPlayer _bgmPlayer = AudioPlayer();

//   // Map of sound aliases to file paths
//   static const String themeSong = 'minigame3/bubble_gem_storm/sound/theme.wav';
//   static const String gameTheme =
//       'minigame3/bubble_gem_storm/sound/gameTheme.m4a';
//   static const String playTierComplete =
//       'minigame3/bubble_gem_storm/sound/tierComplete.mp3';
//   static const String tapNormal = 'minigame3/bubble_gem_storm/sound/pop.wav';
//   static const String tapPoison = 'minigame3/bubble_gem_storm/sound/poison.wav';
//   static const String tapDizzy = 'minigame3/bubble_gem_storm/sound/dizzy.wav';
//   static const String tapGravity =
//       'minigame3/bubble_gem_storm/sound/gravity.flac';

//   static const String tapBomb = 'minigame3/bubble_gem_storm/sound/bomb.wav';
//   static const String tapRainbow =
//       'minigame3/bubble_gem_storm/sound/jingle.wav';
//   static const String tapFrozen1 = 'minigame3/bubble_gem_storm/sound/crack.mp3';
//   static const String tapFrozen2 =
//       'minigame3/bubble_gem_storm/sound/shatter.wav';
//   static const String tapGolden = 'minigame3/bubble_gem_storm/sound/golden.wav';
//   static const String tapFreeze = 'minigame3/bubble_gem_storm/sound/power.wav';
//   static const String winSound = 'minigame3/bubble_gem_storm/sound/win.wav';
//   static const String loseSound = 'minigame3/bubble_gem_storm/sound/lose.ogg';

//   /// Initialize the pooland preload sounds into cache
//   Future<void> init() async {
//     for (int i = 0; i < _poolSize; i++) {
//       final player = AudioPlayer();
//       // Low latency mode is critical for game SFX
//       player.setReleaseMode(ReleaseMode.stop);
//       _playerPool.add(player);
//     }

//     _bgmPlayer.setReleaseMode(ReleaseMode.loop);

//     // Pre-load sounds into the global cache to prevent first-tap delay
//     await AudioCache.instance.loadAll([
//       themeSong,
//       gameTheme,
//       playTierComplete,
//       tapNormal,
//       tapPoison,
//       tapDizzy,
//       tapGravity,
//       tapBomb,
//       tapRainbow,
//       tapFrozen1, tapFrozen2,
//       tapGolden, // Added
//       tapFreeze,
//       winSound, // Added
//       loseSound,
//     ]);
//   }

//   Future<void> _playBGM(String assetPath) async {
//     if (!await SoundSettings.isEnabled()) {
//       _bgmPlayer.stop();
//       return;
//     }
//     try {
//       await _bgmPlayer.stop();
//       await _bgmPlayer.setVolume(
//         0.3,
//       ); // Game music usually slightly quieter than SFX
//       await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
//       await _bgmPlayer.play(AssetSource(assetPath));
//     } catch (e) {
//       print("Error playing BGM: $e");
//     }
//   }

//   void playWinSound() {
//     play(winSound, volume: 1.0);
//   }

//   void playLoseSound() {
//     play(loseSound, volume: 1.0);
//   }

//   void setBgmVolume(double volume) {
//     _bgmPlayer.setVolume(volume);
//   }

//   //Specific methods for eachscreen
//   Future<void> playHomeTheme() => _playBGM(themeSong);
//   Future<void> playLevelTheme() => _playBGM(gameTheme);

//   // NEW: StopTheme Music
//   void stopTheme() {
//     _bgmPlayer.stop();
//   }

//   /// Plays a sound using the next available player in the pool
//   void play(String assetPath, {double volume = 1.0}) async {
//     if (!await SoundSettings.isEnabled()) return;
//     final player = _playerPool[_currentPlayerIndex];

//     try {
//       await player.stop().then((_) {
//         player.setVolume(volume);
//         player.play(AssetSource(assetPath), mode: PlayerMode.lowLatency);
//       });
//     } catch (e) {
//       print("Error playing SFX: $e");
//     }

//     // Fireand forget - don't await this in a game loop

//     // Cycle through the pool
//     _currentPlayerIndex = (_currentPlayerIndex + 1) % _poolSize;
//   }

//   Future<void> playTierCompleteSound() async {
//     // We use the 'play' helper you already built which handles
//     // thesound settings check and the player pool automatically.
//     play(playTierComplete, volume: 1.0);
//   }

//   /// Specific logic for Gem taps
//   void playGemTap(GemType type, int tapsRequired) {
//     switch (type) {
//       case GemType.normal:
//         play(tapNormal);
//         break;
//       case GemType.bomb:
//         play(tapBomb);
//         break;
//       case GemType.rainbow:
//         play(tapRainbow);
//         break;
//       case GemType.frozen:
//         // If tapsRequired is 2, it's the first hit. If 1,it's the breaking hit.
//         if (tapsRequired >= 2) {
//           play(tapFrozen1, volume: 0.8);
//         } else {
//           play(tapFrozen2);
//         }
//         break;
//       case GemType.golden:
//         play(tapGolden, volume: 1.0);
//         break;
//       case GemType.freezePowerUp:
//         play(tapFreeze, volume: 0.9);
//         break;
//       case GemType.poison:
//         play(tapPoison, volume: 0.9);
//         break;
//       case GemType.dizzy:
//         play(tapDizzy, volume: 0.9);
//         break;
//       case GemType.gravity:
//         play(tapGravity, volume: 0.9);
//         break;
//       // Handle any other types (like fake gems) to avoid errors
//       default:
//         play(tapNormal);
//         break;
//     }
//   }

//   void dispose() {
//     for (var player in _playerPool) {
//       player.dispose();
//     }
//   }
// }
import 'package:audioplayers/audioplayers.dart';
import '../screens/game_screen.dart';
import '../utils/sounds_settings.dart';

class SoundManager {
  // Singleton pattern
  static final SoundManager instance = SoundManager._internal();
  SoundManager._internal(); // A pool of players to handle overlapping sounds without lag
  final List<AudioPlayer> _playerPool = [];
  final int _poolSize = 10; // Maximum simultaneous sounds
  int _currentPlayerIndex = 0;

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _priorityPlayer = AudioPlayer();

  // Map of sound aliases to file paths
  static const String themeSong = 'minigame3/bubble_gem_storm/sound/theme.wav';
  static const String gameTheme =
      'minigame3/bubble_gem_storm/sound/gameTheme.m4a';
  static const String playTierComplete =
      'minigame3/bubble_gem_storm/sound/tierComplete.mp3';
  static const String tapNormal = 'minigame3/bubble_gem_storm/sound/pop.wav';
  static const String tapPoison = 'minigame3/bubble_gem_storm/sound/poison.wav';
  static const String tapDizzy = 'minigame3/bubble_gem_storm/sound/dizzy.wav';
  static const String tapGravity =
      'minigame3/bubble_gem_storm/sound/gravity.flac';

  static const String tapBomb = 'minigame3/bubble_gem_storm/sound/bomb.wav';
  static const String tapRainbow =
      'minigame3/bubble_gem_storm/sound/jingle.wav';
  static const String tapFrozen1 = 'minigame3/bubble_gem_storm/sound/crack.mp3';
  static const String tapFrozen2 =
      'minigame3/bubble_gem_storm/sound/shatter.wav';
  static const String tapGolden = 'minigame3/bubble_gem_storm/sound/golden.wav';
  static const String tapFreeze = 'minigame3/bubble_gem_storm/sound/power.wav';
  static const String winSound = 'minigame3/bubble_gem_storm/sound/win.wav';
  static const String loseSound = 'minigame3/bubble_gem_storm/sound/lose.ogg';

  /// Initialize the pooland preload sounds into cache
  Future<void> init() async {
    for (int i = 0; i < _poolSize; i++) {
      final player = AudioPlayer();
      // Low latency mode is critical for game SFX
      player.setReleaseMode(ReleaseMode.stop);
      _playerPool.add(player);
    }
    _priorityPlayer.setReleaseMode(ReleaseMode.stop);

    _bgmPlayer.setReleaseMode(ReleaseMode.loop);

    // Pre-load sounds into the global cache to prevent first-tap delay
    await AudioCache.instance.loadAll([
      themeSong,
      gameTheme,
      playTierComplete,
      tapNormal,
      tapPoison,
      tapDizzy,
      tapGravity,
      tapBomb,
      tapRainbow,
      tapFrozen1, tapFrozen2,
      tapGolden, // Added
      tapFreeze,
      winSound, // Added
      loseSound,
    ]);
  }

  Future<void> _playBGM(String assetPath) async {
    if (!await SoundSettings.isEnabled()) {
      _bgmPlayer.stop();
      return;
    }
    try {
      await _bgmPlayer.stop();
      await _bgmPlayer.setVolume(
        0.3,
      ); // Game music usually slightly quieter than SFX
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print("Error playing BGM: $e");
    }
  }

  // void playWinSound() {
  //   play(winSound, volume: 1.0);
  // }
  //
  // void playLoseSound() {
  //   play(loseSound, volume: 1.0);
  // }
  void playWinSound() {
    _playPriority(winSound);
  }

  void playLoseSound() {
    _playPriority(loseSound);
  }

  void _playPriority(String assetPath) async {
    if (!await SoundSettings.isEnabled()) return;

    try {
      // Stop all pool players immediately to clearaudio focus for the win/loss sound
      for (var p in _playerPool) {
        p.stop();
      }

      await _priorityPlayer.stop();
      await _priorityPlayer.setVolume(1.0);
      await _priorityPlayer.play(
        AssetSource(assetPath),
        mode: PlayerMode.lowLatency,
      );
    } catch (e) {
      print("Priority Sound Error: $e");
    }
  }

  void setBgmVolume(double volume) {
    _bgmPlayer.setVolume(volume);
  }

  //Specific methods for eachscreen
  Future<void> playHomeTheme() => _playBGM(themeSong);
  Future<void> playLevelTheme() => _playBGM(gameTheme);

  // NEW: StopTheme Music
  void stopTheme() {
    _bgmPlayer.stop();
  }

  /// Plays a sound using the next available player in the pool
  void play(String assetPath, {double volume = 1.0}) async {
    if (!await SoundSettings.isEnabled()) return;
    final player = _playerPool[_currentPlayerIndex];

    try {
      await player.stop().then((_) {
        player.setVolume(volume);
        player.play(AssetSource(assetPath), mode: PlayerMode.lowLatency);
      });
    } catch (e) {
      print("Error playing SFX: $e");
    }

    // Fireand forget - don't await this in a game loop

    // Cycle through the pool
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _poolSize;
  }

  Future<void> playTierCompleteSound() async {
    // We use the 'play' helper you already built which handles
    // thesound settings check and the player pool automatically.
    play(playTierComplete, volume: 1.0);
  }

  /// Specific logic for Gem taps
  void playGemTap(GemType type, int tapsRequired) {
    switch (type) {
      case GemType.normal:
        play(tapNormal);
        break;
      case GemType.bomb:
        play(tapBomb);
        break;
      case GemType.rainbow:
        play(tapRainbow);
        break;
      case GemType.frozen:
        // If tapsRequired is 2, it's the first hit. If 1,it's the breaking hit.
        if (tapsRequired >= 2) {
          play(tapFrozen1, volume: 0.8);
        } else {
          play(tapFrozen2);
        }
        break;
      case GemType.golden:
        play(tapGolden, volume: 1.0);
        break;
      case GemType.freezePowerUp:
        play(tapFreeze, volume: 0.9);
        break;
      case GemType.poison:
        play(tapPoison, volume: 0.9);
        break;
      case GemType.dizzy:
        play(tapDizzy, volume: 0.9);
        break;
      case GemType.gravity:
        play(tapGravity, volume: 0.9);
        break;
      // Handle any other types (like fake gems) to avoid errors
      default:
        play(tapNormal);
        break;
    }
  }

  void dispose() {
    for (var player in _playerPool) {
      player.dispose();
    }
  }
}
