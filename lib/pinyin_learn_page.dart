import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'constants.dart';

class PinyinLearnPage extends StatefulWidget {
  const PinyinLearnPage({super.key});

  @override
  State<PinyinLearnPage> createState() => _PinyinLearnPageState();
}

class _PinyinLearnPageState extends State<PinyinLearnPage>
    with SingleTickerProviderStateMixin {
  late FlutterTts _flutterTts;
  late Random _random;

  String _targetLetter = '';
  List<String> _options = [];
  bool _showingResult = false;
  bool? _isCorrect;
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _celebrateAnimation;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _random = Random();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 24,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_animationController);

    _celebrateAnimation = Tween<double>(begin: 1, end: 1.3)
        .chain(CurveTween(curve: Curves.easeOutBack))
        .animate(_animationController);

    _initTts();
    _loadNextQuestion();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('zh-CN');
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.2);
  }

  void _loadNextQuestion() {
    final letters = PinyinConstants.letters;
    final targetIndex = _random.nextInt(letters.length);
    _targetLetter = letters[targetIndex];

    final availableOptions = letters.where((l) => l != _targetLetter).toList();
    availableOptions.shuffle(_random);

    _options = [
      _targetLetter,
      ...availableOptions.take(PinyinConstants.optionCount - 1),
    ];
    _options.shuffle(_random);

    _showingResult = false;
    _isCorrect = null;

    _speakTarget();
  }

  Future<void> _speakTarget() async {
    await _flutterTts.speak(_targetLetter);
  }

  void _onSelectOption(String letter) {
    if (_showingResult) return;

    setState(() {
      _showingResult = true;
      _isCorrect = letter == _targetLetter;
    });

    if (_isCorrect!) {
      _flutterTts.speak('答对了');
      _animationController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _animationController.reset();
            _loadNextQuestion();
          }
        });
      });
    } else {
      _flutterTts.speak('再试一次');
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

  @override
  void dispose() {
    _flutterTts.stop();
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
              '听录音，选择正确的拼音',
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
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

    return GestureDetector(
      onTap: () => _onSelectOption(letter),
      child: AnimatedContainer(
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
    );
  }
}
