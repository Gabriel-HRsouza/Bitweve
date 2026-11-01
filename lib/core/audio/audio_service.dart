import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameSfx {
  buttonTap,
  ageUp,
  screenTransition,
  positiveEvent,
  negativeEvent,
  achievement,
  moneyGain,
  moneyLoss,
  lotteryWin,
  wedding,
  birth,
  promotion,
  notification,
  death,
}

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _sfxEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;

  bool get sfxEnabled => _sfxEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  // Pool of audio players for instant polyphonic playback
  static const int _poolSize = 5;
  final List<AudioPlayer> _playerPool = [];
  int _poolIndex = 0;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _sfxEnabled = prefs.getBool('bitweve_sfx_enabled') ?? true;
      _musicEnabled = prefs.getBool('bitweve_music_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('bitweve_vibration_enabled') ?? true;

      for (int i = 0; i < _poolSize; i++) {
        final player = AudioPlayer();
        await player.setPlayerMode(PlayerMode.lowLatency);
        await player.setVolume(1.0);
        _playerPool.add(player);
      }
      _initialized = true;
    } catch (_) {
      // Graceful fallback for test environments or permission limits
      _initialized = true;
    }
  }

  Future<void> setSfxEnabled(bool value) async {
    _sfxEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bitweve_sfx_enabled', value);
  }

  Future<void> setMusicEnabled(bool value) async {
    _musicEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bitweve_music_enabled', value);
  }

  Future<void> setVibrationEnabled(bool value) async {
    _vibrationEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bitweve_vibration_enabled', value);
  }

  void playSfx(GameSfx sfx) {
    if (_vibrationEnabled) {
      _triggerHaptic(sfx);
    }
    if (!_sfxEnabled) return;

    final assetFile = _getAssetForSfx(sfx);

    // Play via pooled AudioPlayer
    if (_playerPool.isNotEmpty) {
      try {
        final player = _playerPool[_poolIndex];
        _poolIndex = (_poolIndex + 1) % _playerPool.length;
        player.stop().then((_) {
          player.play(AssetSource(assetFile), volume: 1.0);
        }).catchError((_) {
          // Fallback to direct play
          player.play(AssetSource(assetFile));
        });
        return;
      } catch (_) {}
    }

    // Secondary fallback
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  String _getAssetForSfx(GameSfx sfx) {
    switch (sfx) {
      case GameSfx.buttonTap:
        return 'audio/button_tap.wav';
      case GameSfx.ageUp:
        return 'audio/age_up.wav';
      case GameSfx.screenTransition:
        return 'audio/screen_transition.wav';
      case GameSfx.positiveEvent:
      case GameSfx.birth:
      case GameSfx.notification:
        return 'audio/positive_event.wav';
      case GameSfx.negativeEvent:
        return 'audio/negative_event.wav';
      case GameSfx.achievement:
      case GameSfx.wedding:
      case GameSfx.promotion:
        return 'audio/achievement.wav';
      case GameSfx.moneyGain:
        return 'audio/money_gain.wav';
      case GameSfx.moneyLoss:
        return 'audio/money_loss.wav';
      case GameSfx.lotteryWin:
        return 'audio/lottery_win.wav';
      case GameSfx.death:
        return 'audio/death.wav';
    }
  }

  void _triggerHaptic(GameSfx sfx) {
    try {
      switch (sfx) {
        case GameSfx.buttonTap:
        case GameSfx.screenTransition:
          HapticFeedback.selectionClick();
          break;
        case GameSfx.ageUp:
          HapticFeedback.mediumImpact();
          break;
        case GameSfx.achievement:
        case GameSfx.promotion:
        case GameSfx.wedding:
        case GameSfx.birth:
        case GameSfx.lotteryWin:
          HapticFeedback.heavyImpact();
          break;
        case GameSfx.moneyGain:
        case GameSfx.moneyLoss:
          HapticFeedback.lightImpact();
          break;
        case GameSfx.negativeEvent:
        case GameSfx.death:
          HapticFeedback.vibrate();
          break;
        case GameSfx.positiveEvent:
        case GameSfx.notification:
          HapticFeedback.selectionClick();
          break;
      }
    } catch (_) {}
  }
}

