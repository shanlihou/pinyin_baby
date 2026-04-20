import 'package:flutter/material.dart';

class PinyinConstants {
  static const List<String> letters = [
    'a', 'o', 'e', 'i', 'u', 'ü',
    'b', 'p', 'm', 'f',
    'd', 't', 'n', 'l',
    'g', 'k', 'h',
    'j', 'q', 'x',
    'zh', 'ch', 'sh', 'r',
    'z', 'c', 's',
    'y', 'w'
  ];

  static const int optionCount = 4;
  
  static const List<Color> buttonColors = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFE66D),
    Color(0xFF95E1D3),
    Color(0xFFF38181),
    Color(0xFFAA96DA),
    Color(0xFFFCBF49),
    Color(0xFF2EC4B6),
  ];

  static const double buttonSize = 100.0;
  static const double buttonFontSize = 48.0;
}
