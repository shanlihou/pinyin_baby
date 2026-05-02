import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'audio_manager.dart';
import 'char_constants.dart';

class CharAlphabetPage extends StatefulWidget {
  const CharAlphabetPage({super.key});

  @override
  State<CharAlphabetPage> createState() => _CharAlphabetPageState();
}

class _CharAlphabetPageState extends State<CharAlphabetPage> {
  final AudioManager _audioManager = AudioManager();
  final Map<String, bool> _hasAudio = {};

  @override
  void initState() {
    super.initState();
    _loadAudioStatus();
  }

  Future<bool> _hasAsset(String pinyin) async {
    try {
      await rootBundle.load('assets/audio/$pinyin.m4a');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _loadAudioStatus() async {
    for (final item in CharConstants.defaultChars) {
      _hasAudio[item.pinyin] = await _hasAsset(item.pinyin);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        title: const Text('汉字表'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '点击汉字播放发音',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: CharConstants.defaultChars.length,
                itemBuilder: (context, index) {
                  final item = CharConstants.defaultChars[index];
                  final hasAudio = _hasAudio[item.pinyin] ?? false;

                  return GestureDetector(
                    onTap: () => _audioManager.speak(item.pinyin),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: hasAudio
                            ? const Color(0xFF00B894)
                            : const Color(0xFF6C5CE7),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: (hasAudio
                                    ? const Color(0xFF00B894)
                                    : const Color(0xFF6C5CE7))
                                .withAlpha(80),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              item.char,
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (hasAudio)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.volume_up,
                                  color: Colors.green,
                                  size: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}