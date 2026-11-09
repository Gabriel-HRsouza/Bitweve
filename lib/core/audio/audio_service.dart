import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

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
  purchase,
  menuOpen,
  error,
  mission,
  pickup,
  alarm,
  match,
  cellDoor,
  party,
  swipe,
}

/// Serviço de áudio do jogo: efeitos (pool polifônico) + música de fundo em loop.
/// Todos os arquivos de áudio são sintetizados pelo próprio projeto
/// (tools/generate_sfx.py e tools/generate_audio_v2.py) — sem licenças de terceiros.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _sfxEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;
  double _master = 0.9;
  double _musicVol = 0.45;
  double _sfxVol = 0.85;

  bool get sfxEnabled => _sfxEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  Future<void> setSfxEnabled(bool value) async {
    _sfxEnabled = value;
  }

  Future<void> setMusicEnabled(bool value) async {
    _musicEnabled = value;
    if (_musicEnabled) {
      await startMusic();
    } else {
      await stopMusic();
    }
  }

  Future<void> setVibrationEnabled(bool value) async {
    _vibrationEnabled = value;
  }

  static const int _poolSize = 6;
  final List<AudioPlayer> _pool = [];
  int _poolIndex = 0;
  AudioPlayer? _music;
  bool _initialized = false;
  bool _musicStarted = false;
  bool _musicWanted = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      for (int i = 0; i < _poolSize; i++) {
        final player = AudioPlayer();
        await player.setPlayerMode(PlayerMode.lowLatency);
        await player.setReleaseMode(ReleaseMode.stop);
        _pool.add(player);
      }
      final music = AudioPlayer();
      await music.setReleaseMode(ReleaseMode.loop);
      _music = music;
    } catch (_) {
      // Plataforma sem suporte a áudio (ex.: testes) — segue silencioso.
    }
    if (_musicWanted) startMusic();
  }

  void applySettings({
    required bool sfxEnabled,
    required bool musicEnabled,
    required bool vibrationEnabled,
    required double masterVolume,
    required double musicVolume,
    required double sfxVolume,
  }) {
    _sfxEnabled = sfxEnabled;
    _vibrationEnabled = vibrationEnabled;
    _master = masterVolume.clamp(0.0, 1.0);
    _musicVol = musicVolume.clamp(0.0, 1.0);
    _sfxVol = sfxVolume.clamp(0.0, 1.0);
    final musicChanged = _musicEnabled != musicEnabled;
    _musicEnabled = musicEnabled;
    if (musicChanged) {
      musicEnabled ? startMusic() : stopMusic();
    } else {
      _safe(() => _music?.setVolume(_effectiveMusic));
    }
  }

  double get _effectiveMusic => (_master * _musicVol * 0.6).clamp(0.0, 1.0);
  double get _effectiveSfx => (_master * _sfxVol).clamp(0.0, 1.0);

  Future<void> startMusic() async {
    _musicWanted = true;
    if (!_musicEnabled || _music == null) return;
    try {
      await _music!.setVolume(_effectiveMusic);
      if (_musicStarted) {
        await _music!.resume();
      } else {
        await _music!.play(AssetSource('audio/music_loop.wav'), volume: _effectiveMusic);
        _musicStarted = true;
      }
    } catch (_) {}
  }

  Future<void> stopMusic() async {
    try {
      await _music?.pause();
    } catch (_) {}
  }

  void playSfx(GameSfx sfx) {
    if (_vibrationEnabled) _triggerHaptic(sfx);
    if (!_sfxEnabled || _pool.isEmpty || _effectiveSfx <= 0) return;
    final asset = _assetFor(sfx);
    final player = _pool[_poolIndex];
    _poolIndex = (_poolIndex + 1) % _pool.length;
    _safe(() async {
      await player.stop();
      await player.play(AssetSource(asset), volume: _effectiveSfx * _gainFor(sfx));
    });
  }

  void _safe(Function() fn) {
    try {
      final r = fn();
      if (r is Future) r.catchError((_) {});
    } catch (_) {}
  }

  double _gainFor(GameSfx sfx) {
    switch (sfx) {
      case GameSfx.buttonTap:
      case GameSfx.menuOpen:
        return 0.55;
      case GameSfx.notification:
      case GameSfx.pickup:
      case GameSfx.swipe:
        return 0.7;
      default:
        return 1.0;
    }
  }

  String _assetFor(GameSfx sfx) {
    switch (sfx) {
      case GameSfx.buttonTap:
        return 'audio/button_tap.wav';
      case GameSfx.ageUp:
        return 'audio/age_up.wav';
      case GameSfx.screenTransition:
        return 'audio/screen_transition.wav';
      case GameSfx.positiveEvent:
      case GameSfx.birth:
        return 'audio/positive_event.wav';
      case GameSfx.negativeEvent:
        return 'audio/negative_event.wav';
      case GameSfx.achievement:
      case GameSfx.wedding:
        return 'audio/achievement.wav';
      case GameSfx.promotion:
        return 'audio/promotion.wav';
      case GameSfx.moneyGain:
        return 'audio/money_gain.wav';
      case GameSfx.moneyLoss:
        return 'audio/money_loss.wav';
      case GameSfx.lotteryWin:
        return 'audio/lottery_win.wav';
      case GameSfx.death:
        return 'audio/death.wav';
      case GameSfx.purchase:
        return 'audio/purchase.wav';
      case GameSfx.notification:
        return 'audio/notification.wav';
      case GameSfx.menuOpen:
        return 'audio/menu_open.wav';
      case GameSfx.error:
        return 'audio/error.wav';
      case GameSfx.mission:
        return 'audio/mission.wav';
      case GameSfx.pickup:
        return 'audio/pickup.wav';
      case GameSfx.alarm:
        return 'audio/alarm.wav';
      case GameSfx.match:
        return 'audio/match.wav';
      case GameSfx.cellDoor:
        return 'audio/cell_door.wav';
      case GameSfx.party:
        return 'audio/party.wav';
      case GameSfx.swipe:
        return 'audio/swipe.wav';
    }
  }

  void _triggerHaptic(GameSfx sfx) {
    try {
      switch (sfx) {
        case GameSfx.buttonTap:
        case GameSfx.screenTransition:
        case GameSfx.menuOpen:
        case GameSfx.notification:
        case GameSfx.positiveEvent:
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
        case GameSfx.mission:
          HapticFeedback.heavyImpact();
          break;
        case GameSfx.moneyGain:
        case GameSfx.moneyLoss:
        case GameSfx.purchase:
          HapticFeedback.lightImpact();
          break;
        case GameSfx.negativeEvent:
        case GameSfx.death:
        case GameSfx.error:
        case GameSfx.alarm:
        case GameSfx.cellDoor:
          HapticFeedback.vibrate();
          break;
        case GameSfx.pickup:
        case GameSfx.swipe:
          HapticFeedback.selectionClick();
          break;
        case GameSfx.match:
        case GameSfx.party:
          HapticFeedback.heavyImpact();
          break;
      }
    } catch (_) {}
  }
}
