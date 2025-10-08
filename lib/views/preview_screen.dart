import 'package:flutter/material.dart';
import '../models/text_data.dart';
import 'widgets/character_count_display.dart';

class PreviewScreen extends StatelessWidget {
  final TextData textData;
  const PreviewScreen({super.key, required this.textData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プレビュー'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          CharacterCountDisplay(count: textData.characterCount),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                textData.content,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
