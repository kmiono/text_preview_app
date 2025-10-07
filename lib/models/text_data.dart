class TextData {
  final String content;
  final int characterCount;
  final int characterCountNoSpace;
  final DateTime createdAt; // 追加

  TextData({
    required this.content,
    required this.characterCount,
    required this.characterCountNoSpace,
    required this.createdAt, // 追加
  });

  /// 文字列からTextDataインスタンスを生成するファクトリメソッド
  factory TextData.fromString(String text) {
    final now = DateTime.now();
    return TextData(
      content: text,
      characterCount: text.length,
      characterCountNoSpace: text.replaceAll(RegExp(r'\s'), '').length,
      createdAt: now,
    );
  }

  factory TextData.fromJson(Map<String, dynamic> json) {
    return TextData(
      content: json['content'],
      characterCount: json['characterCount'],
      characterCountNoSpace: json['characterCountNoSpace'],
      createdAt: DateTime.parse(json['createdAt']), // 追加
    );
  }

  /// JSON形式に変換
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'characterCount': characterCount,
      'characterCountNoSpace': characterCountNoSpace,
      'createdAt': createdAt.toIso8601String(), // 追加
    };
  }

  /// 一部プロパティを変更した新しいインスタンスを生成
  TextData copyWith({
    String? content,
    int? characterCount,
    int? characterCountNoSpace,
    DateTime? createdAt, // 追加
  }) {
    return TextData(
      content: content ?? this.content,
      characterCount: characterCount ?? this.characterCount,
      characterCountNoSpace:
          characterCountNoSpace ?? this.characterCountNoSpace,
      createdAt: createdAt ?? this.createdAt, // 追加
    );
  }
}
