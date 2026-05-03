import 'dart:math';
import 'package:flutter/material.dart';
import 'audio_manager.dart';
import 'char_constants.dart';

class CharLearnPage extends StatefulWidget {
  const CharLearnPage({super.key});

  @override
  State<CharLearnPage> createState() => _CharLearnPageState();
}

class _CharLearnPageState extends State<CharLearnPage>
    with SingleTickerProviderStateMixin {
  final AudioManager _audioManager = AudioManager();
  late Random _random;

  String _targetChar = '';
  String _targetPinyin = '';
  List<CharItem> _options = [];
  bool _showingResult = false;
  bool? _isCorrect;
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _celebrateAnimation;

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
    final ok = await _audioManager.init();
    print('TTS init success: $ok');
  }

  void _loadNextQuestion() {
    final chars = CharConstants.defaultChars;
    final targetIndex = _random.nextInt(chars.length);
    _targetChar = chars[targetIndex].char;
    _targetPinyin = chars[targetIndex].pinyin;

    final availableOptions = chars.where((c) => c.char != _targetChar).toList();
    availableOptions.shuffle(_random);

    _options = [
      chars[targetIndex],
      ...availableOptions.take(CharConstants.optionCount - 1),
    ];
    _options.shuffle(_random);

    _showingResult = false;
    _isCorrect = null;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speakTarget();
    });
  }

  Future<void> _speakTarget() async {
    await _audioManager.speak(_targetPinyin);
  }

  void _onSelectOption(CharItem item) {
    if (_showingResult) return;

    setState(() {
      _showingResult = true;
      _isCorrect = item.char == _targetChar;
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
              '听发音,选择正确的汉字',
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
                    children: _options.map((item) {
                      final isSelected = item.char == _targetChar;
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
                        child: _buildCharButton(item, bgColor),
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

  Widget _buildCharButton(CharItem item, Color? bgColor) {
    final colors = CharConstants.buttonColors;
    final colorIndex = _options.indexOf(item) % colors.length;

    return GestureDetector(
      onTap: () => _onSelectOption(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: CharConstants.buttonSize,
        height: CharConstants.buttonSize,
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
            item.char,
            style: TextStyle(
              fontSize: CharConstants.buttonFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}