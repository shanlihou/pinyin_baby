import 'package:flutter/material.dart';
import 'constants.dart';

class AlphabetPage extends StatefulWidget {
  const AlphabetPage({super.key});

  @override
  State<AlphabetPage> createState() => _AlphabetPageState();
}

class _AlphabetPageState extends State<AlphabetPage> {
  final Map<String, bool> _hasCustomAudio = {};
  String? _recordingLetter;
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        title: const Text('拼音字母表'),
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
                '点击字母可录音',
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
                itemCount: PinyinConstants.letters.length,
                itemBuilder: (context, index) {
                  final letter = PinyinConstants.letters[index];
                  final hasCustom = _hasCustomAudio[letter] ?? false;

                  return GestureDetector(
                    onTap: () => _showRecordDialog(letter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: hasCustom
                            ? const Color(0xFF00B894)
                            : const Color(0xFF6C5CE7),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: (hasCustom
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
                              letter,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (_recordingLetter == letter && _isRecording)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red.withAlpha(150),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.mic,
                                    color: Colors.white,
                                    size: 30,
                                  ),
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

  void _showRecordDialog(String letter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('字母 "$letter" '),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('录音功能开发中...'),
            const SizedBox(height: 10),
            const Text(
              '需要先安装录音插件',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}