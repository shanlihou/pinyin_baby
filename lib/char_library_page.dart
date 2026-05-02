import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'char_constants.dart';

class CharLibraryPage extends StatefulWidget {
  const CharLibraryPage({super.key});

  @override
  State<CharLibraryPage> createState() => _CharLibraryPageState();
}

class _CharLibraryPageState extends State<CharLibraryPage> {
  final TextEditingController _charController = TextEditingController();
  final TextEditingController _pinyinController = TextEditingController();

  @override
  void dispose() {
    _charController.dispose();
    _pinyinController.dispose();
    super.dispose();
  }

  Future<bool> _hasAsset(String pinyin) async {
    try {
      await rootBundle.load('assets/audio/$pinyin.m4a');
      return true;
    } catch (_) {
      return false;
    }
  }

  void _addChar() {
    if (_charController.text.isEmpty || _pinyinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入汉字和拼音')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('功能开发中：汉字已保存到本地')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        title: const Text('词库设置'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _charController,
                          decoration: const InputDecoration(
                            labelText: '汉字',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _pinyinController,
                          decoration: const InputDecoration(
                            labelText: '拼音',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _addChar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      '添加汉字',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: CharConstants.defaultChars.length,
                itemBuilder: (context, index) {
                  final item = CharConstants.defaultChars[index];
                  return FutureBuilder<bool>(
                    future: _hasAsset(item.pinyin),
                    builder: (context, snapshot) {
                      final hasAudio = snapshot.data ?? false;
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: hasAudio
                                ? const Color(0xFF00B894)
                                : const Color(0xFF6C5CE7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              item.char,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        title: Text('汉字: ${item.char}'),
                        subtitle: Text('拼音: ${item.pinyin}'),
                        trailing: Icon(
                          hasAudio ? Icons.volume_up : Icons.volume_off,
                          color: hasAudio ? Colors.green : Colors.grey,
                        ),
                      );
                    },
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