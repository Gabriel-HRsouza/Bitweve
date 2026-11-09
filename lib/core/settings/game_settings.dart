import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../audio/audio_service.dart';
import '../i18n/strings.dart';

@immutable
class GameSettings {
  final bool musicEnabled;
  final bool sfxEnabled;
  final bool vibrationEnabled;
  final double masterVolume;
  final double musicVolume;
  final double sfxVolume;
  final bool animationsEnabled;
  final bool reduceMotion;
  final ThemeMode themeMode;
  final String language; // 'pt' | 'en'
  final bool notificationsEnabled;
  final double textScale;
  final bool highContrast;

  const GameSettings({
    this.musicEnabled = true,
    this.sfxEnabled = true,
    this.vibrationEnabled = true,
    this.masterVolume = 0.9,
    this.musicVolume = 0.45,
    this.sfxVolume = 0.85,
    this.animationsEnabled = true,
    this.reduceMotion = false,
    this.themeMode = ThemeMode.dark,
    this.language = 'pt',
    this.notificationsEnabled = true,
    this.textScale = 1.0,
    this.highContrast = false,
  });

  /// Verdadeiro quando animações decorativas devem rodar.
  bool get motionOn => animationsEnabled && !reduceMotion;

  GameSettings copyWith({
    bool? musicEnabled,
    bool? sfxEnabled,
    bool? vibrationEnabled,
    double? masterVolume,
    double? musicVolume,
    double? sfxVolume,
    bool? animationsEnabled,
    bool? reduceMotion,
    ThemeMode? themeMode,
    String? language,
    bool? notificationsEnabled,
    double? textScale,
    bool? highContrast,
  }) {
    return GameSettings(
      musicEnabled: musicEnabled ?? this.musicEnabled,
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      masterVolume: masterVolume ?? this.masterVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      textScale: textScale ?? this.textScale,
      highContrast: highContrast ?? this.highContrast,
    );
  }
}

class SettingsNotifier extends Notifier<GameSettings> {
  static const _p = 'bitweve_';

  @override
  GameSettings build() {
    _load();
    return const GameSettings();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final s = GameSettings(
        musicEnabled: prefs.getBool('${_p}music_enabled') ?? true,
        sfxEnabled: prefs.getBool('${_p}sfx_enabled') ?? true,
        vibrationEnabled: prefs.getBool('${_p}vibration_enabled') ?? true,
        masterVolume: prefs.getDouble('${_p}master_volume') ?? 0.9,
        musicVolume: prefs.getDouble('${_p}music_volume') ?? 0.45,
        sfxVolume: prefs.getDouble('${_p}sfx_volume') ?? 0.85,
        animationsEnabled: prefs.getBool('${_p}animations') ?? true,
        reduceMotion: prefs.getBool('${_p}reduce_motion') ?? false,
        themeMode: ThemeMode.values[(prefs.getInt('${_p}theme_mode') ?? ThemeMode.dark.index)
            .clamp(0, ThemeMode.values.length - 1)],
        language: prefs.getString('${_p}language') ?? 'pt',
        notificationsEnabled: prefs.getBool('${_p}notifications') ?? true,
        textScale: prefs.getDouble('${_p}text_scale') ?? 1.0,
        highContrast: prefs.getBool('${_p}high_contrast') ?? false,
      );
      state = s;
      _apply(s);
    } catch (_) {
      _apply(state);
    }
  }

  void _apply(GameSettings s) {
    Tr.lang = s.language;
    AudioService().applySettings(
      sfxEnabled: s.sfxEnabled,
      musicEnabled: s.musicEnabled,
      vibrationEnabled: s.vibrationEnabled,
      masterVolume: s.masterVolume,
      musicVolume: s.musicVolume,
      sfxVolume: s.sfxVolume,
    );
  }

  Future<void> update(GameSettings Function(GameSettings s) change) async {
    final next = change(state);
    state = next;
    _apply(next);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('${_p}music_enabled', next.musicEnabled);
      await prefs.setBool('${_p}sfx_enabled', next.sfxEnabled);
      await prefs.setBool('${_p}vibration_enabled', next.vibrationEnabled);
      await prefs.setDouble('${_p}master_volume', next.masterVolume);
      await prefs.setDouble('${_p}music_volume', next.musicVolume);
      await prefs.setDouble('${_p}sfx_volume', next.sfxVolume);
      await prefs.setBool('${_p}animations', next.animationsEnabled);
      await prefs.setBool('${_p}reduce_motion', next.reduceMotion);
      await prefs.setInt('${_p}theme_mode', next.themeMode.index);
      await prefs.setString('${_p}language', next.language);
      await prefs.setBool('${_p}notifications', next.notificationsEnabled);
      await prefs.setDouble('${_p}text_scale', next.textScale);
      await prefs.setBool('${_p}high_contrast', next.highContrast);
    } catch (_) {
      // Ambiente sem armazenamento (ex.: testes) — mantém em memória.
    }
  }

  Future<void> resetToDefaults() => update((_) => const GameSettings());
}

final settingsProvider = NotifierProvider<SettingsNotifier, GameSettings>(SettingsNotifier.new);

/// Atalho para widgets: animações decorativas ligadas?
extension MotionX on WidgetRef {
  bool get motionOn {
    final s = watch(settingsProvider);
    return s.motionOn;
  }
}
