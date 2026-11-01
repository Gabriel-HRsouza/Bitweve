import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameSfx {
  buttonTap,
  ageUp,
  notification,
  achievement,
  wedding,
  birth,
  promotion,
  moneyGain,
  moneyLoss,
  sadEvent,
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

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _sfxEnabled = prefs.getBool('bitweve_sfx_enabled') ?? true;
      _musicEnabled = prefs.getBool('bitweve_music_enabled') ?? true;
      _vibrationEnabled = prefs.getBool('bitweve_vibration_enabled') ?? true;
    } catch (_) {
      // Safe fallback
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

    // Built-in system audio / haptic feedback fallback ensuring zero missing assets crash
    try {
      switch (sfx) {
        case GameSfx.buttonTap:
          SystemSound.play(SystemSoundType.click);
          break;
        case GameSfx.ageUp:
        case GameSfx.achievement:
        case GameSfx.promotion:
        case GameSfx.wedding:
        case GameSfx.birth:
        case GameSfx.moneyGain:
          SystemSound.play(SystemSoundType.alert);
          break;
        default:
          SystemSound.play(SystemSoundType.click);
          break;
      }
    } catch (_) {}
  }

  void _triggerHaptic(GameSfx sfx) {
    try {
      switch (sfx) {
        case GameSfx.buttonTap:
          HapticFeedback.selectionClick();
          break;
        case GameSfx.ageUp:
          HapticFeedback.mediumImpact();
          break;
        case GameSfx.achievement:
        case GameSfx.promotion:
        case GameSfx.wedding:
        case GameSfx.birth:
          HapticFeedback.heavyImpact();
          break;
        case GameSfx.moneyGain:
        case GameSfx.moneyLoss:
          HapticFeedback.lightImpact();
          break;
        case GameSfx.sadEvent:
        case GameSfx.death:
          HapticFeedback.vibrate();
          break;
        case GameSfx.notification:
          HapticFeedback.selectionClick();
          break;
      }
    } catch (_) {}
  }
}
