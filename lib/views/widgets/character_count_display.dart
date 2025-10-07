import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/text_controller.dart';

class CharacterCountDisplay extends StatelessWidget {
  final int? count;

  const CharacterCountDisplay({super.key, this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Row(
        children: [
          const Icon(Icons.text_fields, size: 24),
          const SizedBox(width: 16),
          Text(
            '文字数: ${_getCharacterCount(context)}文字',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  int _getCharacterCount(BuildContext context) {
    if (count != null) {
      return count!;
    }
    return context.watch<TextController>().characterCount;
  }
}
