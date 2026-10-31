import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Loops the bundled siren while a broadcast is live.
///
/// Playback is best effort: browsers can block audio and headless test runs
/// have no audio plugin, so failures are reported to the debug console instead
/// of breaking the alert flow.
class AlertSiren {
  static const double _volume = 0.9;

  AudioPlayer? _player;
  bool _muted = false;

  bool get isMuted => _muted;

  Future<void> start() async {
    try {
      final player = _player ??= AudioPlayer();
      await player.setReleaseMode(ReleaseMode.loop);
      await player.setVolume(_muted ? 0 : _volume);
      await player.play(AssetSource('sounds/alert_siren.wav'));
    } catch (error) {
      debugPrint('Alert siren unavailable: $error');
    }
  }

  /// Silences the siren while keeping the alert running.
  ///
  /// Volume is used rather than pause so unmuting picks the loop back up in
  /// sync instead of restarting it.
  Future<void> setMuted(bool muted) async {
    _muted = muted;
    try {
      await _player?.setVolume(muted ? 0 : _volume);
    } catch (error) {
      debugPrint('Alert siren could not change volume: $error');
    }
  }

  Future<void> stop() async {
    try {
      await _player?.stop();
    } catch (error) {
      debugPrint('Alert siren could not be stopped: $error');
    }
  }

  Future<void> dispose() async {
    await stop();
    final player = _player;
    _player = null;
    try {
      await player?.dispose();
    } catch (error) {
      debugPrint('Alert siren could not be disposed: $error');
    }
  }
}
