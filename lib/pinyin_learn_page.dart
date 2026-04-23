import 'dart:math';
import 'package:flutter/material.dart';
import 'audio_manager.dart';
import 'constants.dart';

class PinyinLearnPage extends StatefulWidget {
  const PinyinLearnPage({super.key});

  @override
  State<PinyinLearnPage> createState() => _PinyinLearnPageState();
}

class _PinyinLearnPageState extends State<PinyinLearnPage>
    with SingleTickerProviderStateMixin {
  final AudioManager _audioManager = AudioManager();
  late Random _random;

  String _targetLetter = '';
  List<String> _options = [];
  bool _showingResult = false;
  bool? _isCorrect;
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _celebrateAnimation;

  Map<String, bool> _customAudioMap = {};

  @override
  void initState() {
    super.initState();
    _random = Random();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 24)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_animationController);

    _celebrateAnimation = Tween<double>(begin: 1, end: 1.3)
        .chain(CurveTween(curve: Curves.easeOutBack))
        .animate(_animationController);

    _initAudio();
    _loadNextQuestion();
  }

  Future<void> _initAudio() async {
    await _audioManager.init();
    await _loadCustomAudioStatus();
  }

  Future<void> _loadCustomAudioStatus() async {
    for (final letter in PinyinConstants.letters) {
      _customAudioMap[letter] = await _audioManager.hasCustomAudio(letter);
    }
    if (mounted) setState(() {});
  }

  void _loadNextQuestion() {
    final letters = PinyinConstants.letters;
    final targetIndex = _random.nextInt(letters.length);
    _targetLetter = letters[targetIndex];

    final availableOptions =
        letters.where((l) => l != _targetLetter).toList();
    availableOptions.shuffle(_random);

    _options = [
      _targetLetter,
      ...availableOptions.take(PinyinConstants.optionCount - 1),
    ];
    _options.shuffle(_random);

    _showingResult = false;
    _isCorrect = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakTarget();
    });
  }

  Future<void> _speakTarget() async {
    await _audioManager.speak(_targetLetter);
  }

  void _onSelectOption(String letter) {
    if (_showingResult) return;

    setState(() {
      _showingResult = true;
      _isCorrect = letter == _targetLetter;
    });

    if (_isCorrect!) {
      _audioManager.speak('答对了');
      _animationController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _animationController.reset();
            _loadNextQuestion();
          }
        });
      });
    } else {
      _audioManager.speak('再试一次');
      _animationController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _animationController.reset();
            setState(() {
              _showingResult = false;
              _isCorrect = null;
            });
          }
        });
      });
    }
  }

  Future<void> _deleteRecording(String letter) async {
    await _audioManager.deleteCustomAudio(letter);
    _customAudioMap[letter] = false;
    if (mounted) setState(() {});
  }

  void _showInfoDialog(String letter) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('关于 "$letter" '),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_customAudioMap[letter] == true) ...[
                  const Icon(Icons.check_circle, color: Colors.green, size: 30),
                  const Text('已有自定义录音'),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () async {
                      await _deleteRecording(letter);
                      setDialogState(() {});
                      setState(() {});
                    },
                    child: const Text('删除录音'),
                  ),
                ] else ...[
                  const Text('长按拼音按钮可录音'),
                  const SizedBox(height: 10),
                  const Text(
                    '(录音功能开发中...)',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _audioManager.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              '听录音,选择正确的拼音',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _speakTarget,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.volume_up, color: Colors.white, size: 28),
                  SizedBox(width: 8),
                  Text(
                    '点击播放发音',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ],
              ),
            ),
            const Spacer(),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isCorrect == true ? _celebrateAnimation.value : 1.0,
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: _options.map((letter) {
                      final isSelected = letter == _targetLetter;
                      Color? bgColor;
                      if (_showingResult) {
                        if (isSelected) {
                          bgColor = const Color(0xFF00B894);
                        } else if (_isCorrect == false) {
                          bgColor = Colors.grey[400];
                        }
                      }
                      return Transform.translate(
                        offset: Offset(
                          _isCorrect == false && _showingResult
                              ? sin(_shakeAnimation.value) * 10
                              : 0,
                          0,
                        ),
                        child: _buildLetterButton(letter, bgColor),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildLetterButton(String letter, Color? bgColor) {
    final colors = PinyinConstants.buttonColors;
    final colorIndex = _options.indexOf(letter) % colors.length;
    final hasCustom = _customAudioMap[letter] == true;

    return GestureDetector(
      onTap: () => _onSelectOption(letter),
      onLongPress: () => _showInfoDialog(letter),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: PinyinConstants.buttonSize,
            height: PinyinConstants.buttonSize,
            decoration: BoxDecoration(
              color: bgColor ?? colors[colorIndex],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (bgColor ?? colors[colorIndex]).withAlpha(100),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: PinyinConstants.buttonFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (hasCustom)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}