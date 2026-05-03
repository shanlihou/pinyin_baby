import 'package:flutter_tts/flutter_tts.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final FlutterTts _tts = FlutterTts();

  Future<bool> init() async {
    try {
      await _tts.setLanguage('zh-CN');
      await _tts.setSpeechRate(0.4);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.2);
      print('TTS init success');
      return true;
    } catch (e) {
      print('TTS init error: $e');
      return false;
    }
  }

  Future<void> speak(String text) async {
    print('TTS speak: $text');
    await _tts.speak(text);
  }

  void dispose() {
    _tts.stop();
  }
}
