import 'package:text_preview_app/models/text_data.dart';

class TextRepository {
  String _currentText = '';

  String get currentText => _currentText;

  void updateText(String text) {
    _currentText = text;
  }

  int calculateCharacterCount(String text) {
    return text.length;
  }

  int calculateCharacterCountNoSpace(String text) {
    return text.replaceAll(RegExp(r'\s'), '').length;
  }

  TextData createTextData(String text) {
    return TextData(
      content: text,
      characterCount: calculateCharacterCount(text),
      characterCountNoSpace: calculateCharacterCountNoSpace(text),
      createdAt: DateTime.now(),
    );
  }
}
