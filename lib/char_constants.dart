import 'package:flutter/material.dart';

class CharConstants {
  static const List<CharItem> defaultChars = [
    CharItem(char: '一', pinyin: 'yī'),
    CharItem(char: '二', pinyin: 'èr'),
    CharItem(char: '三', pinyin: 'sān'),
    CharItem(char: '四', pinyin: 'sì'),
    CharItem(char: '五', pinyin: 'wǔ'),
    CharItem(char: '六', pinyin: 'liù'),
    CharItem(char: '七', pinyin: 'qī'),
    CharItem(char: '八', pinyin: 'bā'),
    CharItem(char: '九', pinyin: 'jiǔ'),
    CharItem(char: '十', pinyin: 'shí'),
  ];

  static const int optionCount = 4;

  static const double buttonSize = 100.0;
  static const double buttonFontSize = 56.0;

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
}

class CharItem {
  final String char;
  final String pinyin;

  const CharItem({required this.char, required this.pinyin});
}