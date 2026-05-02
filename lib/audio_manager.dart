import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final FlutterTts _tts = FlutterTts();
  String? _cacheDir;

  Future<void> init() async {
    await _tts.setLanguage('zh-CN');
    await _tts.setSpeechRate(0.4);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.2);

    final dir = await getTemporaryDirectory();
    _cacheDir = dir.path;
  }

  Future<String> _getAudioDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final audioDir = Directory(p.join(dir.path, 'custom_audio'));
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir.path;
  }

  Future<String> getAudioPath(String letter) async {
    final audioDir = await _getAudioDir();
    return p.join(audioDir, '$letter.m4a');
  }

  Future<bool> _hasAsset(String letter) async {
    try {
      await rootBundle.load('assets/audio/$letter.m4a');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> hasCustomAudio(String letter) async {
    final hasAsset = await _hasAsset(letter);
    if (hasAsset) return true;

    final path = await getAudioPath(letter);
    return File(path).existsSync();
  }

  Future<void> _copyAssetToCache(String letter) async {
    if (_cacheDir == null) return;

    final cacheFile = File(p.join(_cacheDir!, '$letter.m4a'));
    if (await cacheFile.exists()) return;

    final data = await rootBundle.load('assets/audio/$letter.m4a');
    await cacheFile.writeAsBytes(data.buffer.asUint8List());
  }

  Future<void> speak(String letter) async {
    final hasAsset = await _hasAsset(letter);
    if (hasAsset) {
      await _copyAssetToCache(letter);
      final path = p.join(_cacheDir!, '$letter.m4a');
      await _tts.speak(path);
    } else {
      final hasLocal = await hasCustomAudio(letter);
      if (hasLocal) {
        final path = await getAudioPath(letter);
        await _tts.speak(path);
      } else {
        await _tts.speak(letter);
      }
    }
  }

  Future<void> deleteCustomAudio(String letter) async {
    final path = await getAudioPath(letter);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  void dispose() {
    _tts.stop();
  }
}