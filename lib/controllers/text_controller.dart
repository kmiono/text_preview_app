import 'package:flutter/foundation.dart';
import '../models/text_data.dart';
import '../models/text_repository.dart';

class TextController extends ChangeNotifier {
  final TextRepository _repository = TextRepository();

  String get currentText => _repository.currentText;

  int get characterCount => _repository.calculateCharacterCount(currentText);

  int get characterCountNoSpace =>
      _repository.calculateCharacterCountNoSpace(currentText);

  void updateText(String text) {
    _repository.updateText(text);
    notifyListeners();
  }

  TextData getTextData() {
    return _repository.createTextData(currentText);
  }

  void clearText() {
    _repository.updateText('');
    notifyListeners();
  }
}
