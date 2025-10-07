# 文章プレビューアプリ 詳細設計書

## 1. システム全体構成

### 1.1 アーキテクチャパターン
**MVCパターン**を採用

```
┌─────────────────────────────────────┐
│           Presentation Layer         │
│         (View - UI Components)       │
│  - InputScreen                       │
│  - PreviewScreen                     │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│         Controller Layer             │
│   - TextController                   │
│     (状態管理・ビジネスロジック)        │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│           Model Layer                │
│   - TextData (データモデル)           │
│   - TextRepository (データ管理)       │
└─────────────────────────────────────┘
```

### 1.2 ディレクトリ構成

```
lib/
├── main.dart                    # アプリケーションエントリーポイント
├── models/                      # Model層
│   ├── text_data.dart          # データモデル
│   └── text_repository.dart    # データ管理クラス
├── controllers/                 # Controller層
│   └── text_controller.dart    # 状態管理・ロジック
└── views/                       # View層
    ├── input_screen.dart       # 入力画面
    ├── preview_screen.dart     # プレビュー画面
    └── widgets/                # 共通Widget
        └── character_count_display.dart  # 文字数表示Widget
```

---

## 2. Model層の詳細設計

### 2.1 TextData（データモデル）

#### 2.1.1 クラス概要
入力された文章データを保持するデータモデルクラス

#### 2.1.2 プロパティ詳細

| プロパティ名 | 型 | 説明 | 必須 |
|------------|---|------|-----|
| content | String | 入力された文章 | ✓ |
| characterCount | int | 文字数（空白含む） | ✓ |
| characterCountNoSpace | int | 文字数（空白除く） | ✓ |
| lineCount | int | 行数 | ✓ |
| createdAt | DateTime | 作成日時 | ✓ |

#### 2.1.3 提供するメソッド

| メソッド名 | 戻り値 | 説明 |
|-----------|--------|------|
| fromString(String text) | TextData | 文字列からTextDataインスタンスを生成するファクトリメソッド |
| toJson() | Map<String, dynamic> | JSON形式に変換 |
| fromJson(Map<String, dynamic> json) | TextData | JSONからインスタンスを生成するファクトリメソッド |
| copyWith({...}) | TextData | 一部プロパティを変更した新しいインスタンスを生成 |

### 2.2 TextRepository（データ管理クラス）

#### 2.2.1 クラス概要
テキストデータの管理と計算処理を担当するクラス

#### 2.2.2 プライベートフィールド

| フィールド名 | 型 | 説明 |
|------------|---|------|
| _currentText | String | 現在編集中のテキスト |

#### 2.2.3 公開Getter

| Getter名 | 戻り値 | 説明 |
|---------|--------|------|
| currentText | String | 現在のテキストを取得 |

#### 2.2.4 提供するメソッド

| メソッド名 | 引数 | 戻り値 | 説明 |
|-----------|------|--------|------|
| updateText | String text | void | 現在のテキストを更新 |
| calculateCharacterCount | String text | int | 文字数をカウント（空白含む） |
| calculateCharacterCountNoSpace | String text | int | 文字数をカウント（空白除く） |
| calculateLineCount | String text | int | 行数をカウント |
| createTextData | String text | TextData | TextDataインスタンスを生成 |
| clear | - | void | データをクリア |

#### 2.2.5 文字数カウントアルゴリズム

**空白を含む文字数**
- 文字列の長さをそのまま返す

**空白を除く文字数**
- 正規表現で全ての空白文字（スペース、タブ、改行）を削除
- 残った文字列の長さを返す

**行数**
- 空文字列の場合は0を返す
- 改行文字の出現回数 + 1を返す

---

## 3. Controller層の詳細設計

### 3.1 TextController（状態管理クラス）

#### 3.1.1 クラス概要
ViewとModelの仲介役として状態管理とビジネスロジックを担当
ChangeNotifierを継承し、状態変更をViewに通知する

#### 3.1.2 依存オブジェクト

| オブジェクト名 | 型 | 説明 |
|--------------|---|------|
| _repository | TextRepository | データ管理オブジェクト |

#### 3.1.3 公開Getter

| Getter名 | 戻り値 | 説明 |
|---------|--------|------|
| currentText | String | 現在のテキスト |
| characterCount | int | 文字数（空白含む） |
| characterCountNoSpace | int | 文字数（空白除く） |
| lineCount | int | 行数 |

#### 3.1.4 提供するメソッド

| メソッド名 | 引数 | 戻り値 | 説明 | 副作用 |
|-----------|------|--------|------|--------|
| updateText | String text | void | テキストを更新 | notifyListeners()を呼び出し |
| getTextData | - | TextData | 現在のテキストデータを取得 | なし |
| clearText | - | void | テキストをクリア | notifyListeners()を呼び出し |

#### 3.1.5 状態管理フロー

```
[ユーザー入力]
     ↓
updateText(text)
     ↓
Repository.updateText(text)
     ↓
notifyListeners()
     ↓
[Viewが再描画]
```

#### 3.1.6 状態管理の実装パターン

**Provider + ChangeNotifierを使用**
- main.dartでChangeNotifierProviderを設定
- View側では以下の使い分け：
  - 読み取り専用: context.watch<TextController>()
  - メソッド呼び出し専用: context.read<TextController>()

---

## 4. View層の詳細設計

### 4.1 InputScreen（入力画面）

#### 4.1.1 画面概要
ユーザーがテキストを入力し、プレビュー画面に遷移するための画面

#### 4.1.2 画面構成

```
AppBar
├── title: "文章プレビューアプリ"
│
Body (Column)
├── CharacterCountDisplay (文字数表示)
│   └── Text: "〇〇文字"
│
├── Expanded
│   └── Padding
│       └── TextField (入力エリア)
│           ├── 複数行入力対応
│           ├── プレースホルダー表示
│           └── 入力時にControllerを更新
│
└── Padding
    └── ElevatedButton (プレビューボタン)
        ├── text: "プレビュー"
        └── タップでプレビュー画面へ遷移
```

#### 4.1.3 レイアウト詳細

```
┌─────────────────────────────┐
│   文章プレビューアプリ        │  AppBar: 56px
├─────────────────────────────┤
│ 📝 文字数: 0文字             │  Height: 56px
│                             │  Padding: 16px
├─────────────────────────────┤
│                             │
│  [入力エリア]                │  Expanded
│   ここに文章を入力してください │  Padding: 16px
│                             │  Border: 1px solid #E0E0E0
│                             │  BorderRadius: 8px
│                             │
├─────────────────────────────┤
│      [プレビュー]             │  Height: 48px
│                             │  Margin: 16px
└─────────────────────────────┘  BorderRadius: 8px
```

#### 4.1.4 TextFieldの設定仕様

| プロパティ | 設定値 | 説明 |
|-----------|-------|------|
| controller | TextEditingController | テキスト内容の管理 |
| maxLines | null | 無制限の行数を許可 |
| keyboardType | TextInputType.multiline | 複数行入力用キーボード |
| decoration | InputDecoration | プレースホルダー、枠線などの装飾 |
| onChanged | コールバック関数 | 入力時にControllerのupdateTextを呼び出す |

#### 4.1.5 画面遷移処理の流れ

1. プレビューボタンがタップされる
2. Controllerから現在のTextDataを取得
3. Navigator.pushでPreviewScreenに遷移
4. TextDataを引数として渡す

#### 4.1.6 ライフサイクル管理

**initState**
- TextEditingControllerを初期化
- 必要に応じてControllerの初期値を設定

**dispose**
- TextEditingControllerを破棄してメモリリークを防止

### 4.2 PreviewScreen（プレビュー画面）

#### 4.2.1 画面概要
入力されたテキストを表示専用で閲覧する画面

#### 4.2.2 画面構成

```
AppBar
├── title: "プレビュー"
├── leading: BackButton（自動生成）
│
Body (Column)
├── CharacterCountDisplay (文字数表示)
│   └── Text: "〇〇文字"（固定値）
│
└── Expanded
    └── SingleChildScrollView
        └── Padding
            └── Text (プレビューエリア)
                └── textData.contentを表示
```

#### 4.2.3 レイアウト詳細

```
┌─────────────────────────────┐
│ ← プレビュー                 │  AppBar: 56px
├─────────────────────────────┤
│ 📝 文字数: 123文字           │  Height: 56px
│                             │  Padding: 16px
├─────────────────────────────┤
│                             │
│  入力された文章が             │  Expanded
│  ここに表示されます           │  Padding: 16px
│                             │  Scrollable
│                             │
│                             │
└─────────────────────────────┘
```

#### 4.2.4 コンストラクタ引数

| 引数名 | 型 | 必須 | 説明 |
|-------|---|------|------|
| textData | TextData | ✓ | 表示するテキストデータ |

#### 4.2.5 Textウィジェットの設定

| プロパティ | 設定値 | 説明 |
|-----------|-------|------|
| data | textData.content | 表示内容 |
| style | TextStyle | フォントサイズ16sp、通常ウェイト |
| textAlign | TextAlign.left | 左揃え |

#### 4.2.6 戻る動作

- AppBarの戻るボタン（自動生成）をタップ
- Navigator.pop()で前の画面に戻る
- 入力画面のデータは保持される

### 4.3 CharacterCountDisplay（文字数表示Widget）

#### 4.3.1 Widget概要
文字数を表示する再利用可能なウィジェット
入力画面とプレビュー画面の両方で使用

#### 4.3.2 コンストラクタ引数

| 引数名 | 型 | 必須 | デフォルト | 説明 |
|-------|---|------|----------|------|
| count | int? | ✗ | null | 表示する文字数（nullの場合はControllerから取得） |

#### 4.3.3 表示ロジック

**入力画面での使用**
- countを指定せずに使用
- Controllerから動的に文字数を取得
- 入力に応じてリアルタイムで更新

**プレビュー画面での使用**
- countにtextData.characterCountを指定
- 固定値を表示（更新なし）

#### 4.3.4 レイアウト構成

```
Container (背景色: グレー)
└── Row
    ├── Icon (テキストアイコン)
    ├── SizedBox (8px幅)
    └── Text ("文字数: XX文字")
```

#### 4.3.5 スタイル仕様

| 要素 | 設定 |
|------|------|
| Container padding | 16px（全方向） |
| Container color | Grey[200] |
| Icon | Icons.text_fields |
| Text fontSize | 16sp |
| Text fontWeight | Bold |

---

## 5. データフロー設計

### 5.1 入力時のデータフロー

```
[ユーザー入力]
     ↓
TextField.onChanged
     ↓
TextController.updateText(text)
     ↓
TextRepository.updateText(text)
     ↓
notifyListeners()
     ↓
Consumer/watch<TextController>
     ↓
CharacterCountDisplay再描画
```

**詳細説明**
1. ユーザーがTextFieldに文字を入力
2. onChangedコールバックが発火
3. ControllerのupdateTextメソッドが呼ばれる
4. Repositoryの内部状態が更新される
5. notifyListeners()でリスナーに通知
6. context.watch()しているWidgetが再描画
7. 新しい文字数が表示される

### 5.2 プレビュー遷移時のデータフロー

```
[プレビューボタンタップ]
     ↓
TextController.getTextData()
     ↓
TextRepository.createTextData(currentText)
     ↓
TextData生成（文字数計算含む）
     ↓
Navigator.push(PreviewScreen(textData))
     ↓
PreviewScreen表示
```

**詳細説明**
1. ユーザーがプレビューボタンをタップ
2. ControllerのgetTextDataメソッドを呼び出し
3. RepositoryがcurrentTextからTextDataを生成
4. 文字数、行数などを計算
5. 生成されたTextDataをPreviewScreenに渡す
6. Navigator.pushで画面遷移
7. PreviewScreenが表示される

### 5.3 画面遷移フロー

```
InputScreen
     │
     │ Navigator.push()
     ├──────────────────────────┐
     │                          │
     │                     PreviewScreen
     │                          │
     │ ←────────────────────────┤
     │      Navigator.pop()     │
     │
InputScreen（データ保持）
```

**状態管理**
- InputScreenのTextEditingControllerは破棄されない
- 画面遷移中もテキストデータは保持される
- 戻ってきた際に入力内容がそのまま残る

---

## 6. UI/UXデザイン仕様

### 6.1 カラーパレット

| 要素 | カラーコード | 用途 |
|------|-------------|------|
| Primary | #2196F3 (Blue) | AppBar、ボタン |
| Background | #FFFFFF (White) | 背景 |
| Surface | #F5F5F5 (Grey 100) | 文字数表示背景 |
| Text Primary | #212121 (Grey 900) | メインテキスト |
| Text Secondary | #757575 (Grey 600) | 補助テキスト |
| Border | #E0E0E0 (Grey 300) | 枠線 |

### 6.2 タイポグラフィ

| 要素 | フォントサイズ | ウェイト | 用途 |
|------|--------------|---------|------|
| AppBar Title | 20sp | Medium | 画面タイトル |
| Body Text | 16sp | Regular | 入力テキスト、プレビュー |
| Character Count | 16sp | Bold | 文字数表示 |
| Button Text | 16sp | Medium | ボタンラベル |
| Placeholder | 16sp | Regular | プレースホルダー |

### 6.3 スペーシング

| 要素 | 値 | 用途 |
|------|---|------|
| Padding Small | 8px | アイコンとテキスト間隔 |
| Padding Medium | 16px | 標準余白（画面端、要素間） |
| Padding Large | 24px | セクション間隔 |
| AppBar Height | 56px | AppBarの高さ |
| Button Height | 48px | ボタンの高さ |
| Character Count Height | 56px | 文字数表示エリアの高さ |

### 6.4 Border・角丸設定

| 要素 | 設定値 | 説明 |
|------|-------|------|
| TextField Border | 1px solid #E0E0E0 | 入力エリアの枠線 |
| TextField BorderRadius | 8px | 入力エリアの角丸 |
| Button BorderRadius | 8px | ボタンの角丸 |

### 6.5 アイコン

| 用途 | アイコン | サイズ |
|------|---------|-------|
| 文字数表示 | Icons.text_fields | 24px |
| 戻るボタン | Icons.arrow_back | 24px（標準） |

---

## 7. エラーハンドリング設計

### 7.1 想定されるエラーケース

| エラーケース | 発生条件 | 対処方法 | ユーザー体験 |
|------------|---------|---------|------------|
| 空文字でのプレビュー | 未入力でプレビューボタンをタップ | プレビュー画面に遷移して空のプレビューを表示 | エラーとしない（正常動作） |
| 大量テキスト | 100,000文字以上を入力 | そのまま処理（パフォーマンス低下の可能性） | 特に制限なし（オプションで警告） |
| 画面遷移失敗 | Navigatorエラー | try-catchで捕捉、SnackBarでエラー表示 | エラーメッセージ表示 |
| null参照 | 想定外のnull値 | null安全機能で防止 | 発生しない設計 |

### 7.2 バリデーション方針

**基本方針**
- 全ての入力を受け付ける（バリデーションエラーなし）
- 文字数制限なし
- 特殊文字、絵文字も許可

**理由**
- ユーザーの自由な入力を妨げない
- シンプルな仕様を維持
- 学習用途として適切

---

## 8. パフォーマンス最適化

### 8.1 最適化ポイント

| 項目 | 方法 | 効果 | 優先度 |
|------|------|------|--------|
| 文字数カウント | 入力時のみ計算（プレビュー画面では計算済みの値を使用） | CPU使用率削減 | 高 |
| Widget再構築 | Consumer/Selectorで範囲を限定 | 不要な再描画を防止 | 高 |
| TextField | TextEditingControllerで効率的に管理 | メモリ使用量削減 | 中 |
| スクロール | SingleChildScrollViewで必要な部分のみ描画 | メモリ使用量削減 | 中 |

### 8.2 大量テキスト対策

**想定使用状況**
- 平均入力文字数：10,000文字
- 最大想定文字数：50,000文字

**必須対策**
- デバウンス処理：入力停止後に文字数カウント更新
- 遅延時間：300ミリ秒
- 効果：連続入力時の負荷軽減
- 実装優先度：高

**パフォーマンス最適化**
- TextFieldの描画最適化
- 文字数カウントの非同期処理
- メモリ使用量の監視

**実装タイミング**
- 基本版から実装必須
- 10,000文字で快適な動作を保証

### 8.3 メモリ管理

**重要な破棄処理**
- TextEditingControllerのdispose
- Listenerの適切な解除
- 不要なオブジェクトの参照解放

**ベストプラクティス**
- StatefulWidgetのdisposeメソッドで必ず破棄
- ChangeNotifierのaddListener/removeListenerをペアで管理

---

## 9. テスト設計

### 9.1 テスト戦略

| テストレベル | 対象 | 目的 | カバレッジ目標 |
|------------|------|------|--------------|
| 単体テスト | Model、Controller | ロジックの正確性 | 80%以上 |
| Widgetテスト | View | UI動作の確認 | 主要パス100% |
| 統合テスト | 全体フロー | E2Eの動作確認 | 主要シナリオ100% |

### 9.2 Model層のテスト項目

#### TextDataのテスト

| テストケース | 入力 | 期待結果 |
|------------|------|---------|
| 通常の文字列 | "Hello" | content="Hello", count=5 |
| 日本語 | "こんにちは" | content="こんにちは", count=5 |
| 改行を含む | "Hello\nWorld" | content="Hello\nWorld", lineCount=2 |
| 空文字列 | "" | content="", count=0, lineCount=0 |
| 空白のみ | "   " | content="   ", count=3, countNoSpace=0 |

#### TextRepositoryのテスト

| テストケース | メソッド | 入力 | 期待結果 |
|------------|---------|------|---------|
| 文字数カウント | calculateCharacterCount | "test" | 4 |
| 空白除く文字数 | calculateCharacterCountNoSpace | "t e s t" | 4 |
| 行数カウント | calculateLineCount | "a\nb\nc" | 3 |
| データ更新 | updateText | "new text" | currentText="new text" |

### 9.3 Controller層のテスト項目

| テストケース | 操作 | 期待結果 |
|------------|------|---------|
| テキスト更新 | updateText("test") | currentText="test", リスナー通知 |
| 文字数取得 | characterCount | 正確な文字数が返る |
| データ取得 | getTextData() | TextDataインスタンスが返る |
| クリア | clearText() | currentText="", リスナー通知 |

### 9.4 View層のテスト項目

#### InputScreenのテスト

| テストケース | 操作 | 期待結果 |
|------------|------|---------|
| 初期表示 | 画面表示 | "文字数: 0文字"が表示される |
| テキスト入力 | "test"を入力 | "文字数: 4文字"に更新される |
| プレビューボタン | ボタンタップ | PreviewScreenに遷移する |
| 長文入力 | 10,000文字入力 | 正常に動作する |

#### PreviewScreenのテスト

| テストケース | 操作 | 期待結果 |
|------------|------|---------|
| 初期表示 | 画面表示 | 渡されたテキストが表示される |
| 文字数表示 | 画面表示 | 正確な文字数が表示される |
| 戻るボタン | 戻るボタンタップ | InputScreenに戻る |
| スクロール | 長文表示 | スクロール可能 |

### 9.5 統合テストシナリオ

#### シナリオ1: 基本フロー
1. アプリ起動
2. テキスト入力（"Test text"）
3. 文字数が"9文字"と表示されることを確認
4. プレビューボタンをタップ
5. プレビュー画面で"Test text"が表示されることを確認
6. 戻るボタンをタップ
7. 入力画面に戻り、"Test text"が保持されていることを確認

#### シナリオ2: 空文字プレビュー
1. アプリ起動
2. 何も入力せずプレビューボタンをタップ
3. プレビュー画面で空の状態が表示されることを確認
4. "文字数: 0文字"が表示されることを確認

#### シナリオ3: 複数回の編集とプレビュー
1. テキスト入力（"First"）
2. プレビュー表示
3. 戻る
4. テキスト追加（"First Second"）
5. プレビュー表示
6. 更新されたテキストが表示されることを確認

---

## 10. 実装順序

### 10.1 推奨開発フェーズ

```
Phase 1: Model層の実装
  □ TextDataクラスの実装
  □ TextRepositoryクラスの実装
  □ Model層の単体テスト作成・実行

Phase 2: Controller層の実装
  □ TextControllerクラスの実装
  □ Controller層の単体テスト作成・実行

Phase 3: View層の基本実装
  □ CharacterCountDisplayウィジェットの実装
  □ InputScreen（基本UI）の実装
  □ PreviewScreen（基本UI）の実装

Phase 4: 統合と画面遷移
  □ 画面遷移ロジックの実装
  □ データ受け渡しの実装
  □ Providerの設定（main.dart）
  □ 全体の動作確認

Phase 5: UI/UXの改善
  □ スタイリング（色、フォント、サイズ）
  □ レイアウト調整
  □ パディング・マージンの最適化
  □ アイコンの配置

Phase 6: テスト・デバッグ
  □ Widgetテストの作成・実行
  □ 統合テストの作成・実行
  □ 手動テスト（実機・エミュレータ）
  □ バグ修正・調整
```

### 10.2 各フェーズの所要時間（目安）

| Phase | 内容 | 所要時間 | 累計 |
|-------|------|---------|------|
| 1 | Model層 | 2時間 | 2時間 |
| 2 | Controller層 | 1時間 | 3時間 |
| 3 | View層基本 | 3時間 | 6時間 |
| 4 | 統合 | 2時間 | 8時間 |
| 5 | UI改善 | 2時間 | 10時間 |
| 6 | テスト | 2時間 | 12時間 |

**合計開発時間**: 約12時間（1.5日）

### 10.3 マイルストーン

| マイルストーン | 完了条件 | 日程目安 |
|--------------|---------|---------|
| M1: Model完成 | Model層のテストが全て通る | 0.5日目 |
| M2: Controller完成 | Controller層のテストが全て通る | 0.5日目 |
| M3: 基本UI完成 | 画面が表示される | 1日目 |
| M4: 機能完成 | 画面遷移とデータ受け渡しが動作 | 1.5日目 |
| M5: リリース準備 | 全テストが通り、UIが完成 | 2日目 |

---

## 11. 非機能要件の詳細

### 11.1 パフォーマンス要件

| 項目 | 要件 | 測定方法 |
|------|------|---------|
| 画面遷移速度 | 1秒以内 | タップから画面表示まで |
| 文字入力応答 | 100ms以内 | キー入力から画面更新まで |
| 大量テキスト処理 | 10,000文字でも快適 | 実機テスト |
| メモリ使用量 | 100MB以下 | Android Studio Profiler |
| アプリ起動時間 | 3秒以内 | コールドスタート |

### 11.2 互換性要件

| プラットフォーム | 最小バージョン | 推奨バージョン |
|----------------|--------------|--------------|
| iOS | 12.0 | 15.0以上 |
| Android | 6.0 (API 23) | 10.0 (API 29)以上 |
| Flutter SDK | 3.0.0 | 最新安定版 |
| Dart SDK | 3.0.0 | 最新安定版 |

### 11.3 ユーザビリティ要件

| 項目 | 要件 | 評価基準 |
|------|------|---------|
| 学習時間 | 初回使用で5分以内に理解 | ユーザーテスト |
| 操作性 | 直感的な画面遷移 | フィードバック |
| 可読性 | テキストが読みやすい | コントラスト比4.5:1以上 |
| レスポンシブ | 様々な画面サイズに対応 | 実機テスト |

### 11.4 保守性要件

| 項目 | 要件 |
|------|------|
| コードカバレッジ | 80%以上 |
| ドキュメント | 全クラス・メソッドにコメント |
| 命名規則 | Dart公式ガイドラインに準拠 |
| ファイル分割 | 1ファイル300行以下 |

---

## 12. セキュリティ・プライバシー

### 12.1 データ管理方針

| 項目 | 方針 |
|------|------|
| データ保存場所 | メモリ内のみ（永続化なし） |
| 外部通信 | なし（完全オフライン動作） |
| 個人情報 | 取り扱わない |
| 権限 | 特別な権限不要 |

### 12.2 将来の拡張時の考慮事項

**ローカルストレージ追加時**
- SharedPreferences使用
- 暗号化は不要（個人情報なし）
- ユーザーによるデータ削除機能

**クラウド同期追加時**
- HTTPS通信必須
- 認証機能の実装
- プライバシーポリシーの作成

---

## 13. 国際化・ローカライゼーション

### 13.1 対応言語

**初期バージョン**
- 日本語のみ

**将来対応（オプション）**
- 英語
- 中国語（簡体字・繁体字）

### 13.2 文字列リソース管理

| 画面 | 文字列 | 説明 |
|------|-------|------|
| InputScreen | "文章プレビューアプリ" | AppBarタイトル |
| InputScreen | "ここに文章を入力してください" | プレースホルダー |
| InputScreen | "プレビュー" | ボタンラベル |
| PreviewScreen | "プレビュー" | AppBarタイトル |
| 共通 | "文字数: {count}文字" | 文字数表示 |

### 13.3 国際化対応の実装方針

**基本版**
- ハードコーディング（日本語のみ）

**拡張版**
- flutter_localizationパッケージを使用
- ARBファイルで文字列管理
- 端末の言語設定に自動対応

---

## 14. 拡張性の設計

### 14.1 将来追加予定の機能

| 機能 | 優先度 | 実装難易度 | 説明 |
|------|-------|-----------|------|
| クリアボタン | 高 | 低 | 入力内容を一括削除 |
| コピー機能 | 高 | 低 | プレビュー内容をクリップボードにコピー |
| データ保存 | 中 | 中 | SharedPreferencesで自動保存 |
| フォント変更 | 中 | 低 | フォントサイズ・スタイル変更 |
| ダークモード | 中 | 中 | テーマ切り替え |
| 履歴管理 | 低 | 高 | 複数のテキストを管理 |
| エクスポート | 低 | 中 | テキストファイルとして出力 |

### 14.2 アーキテクチャの拡張性

**Model層の拡張**
- 複数TextDataを管理するListRepository
- カテゴリ分類機能
- タグ機能

**Controller層の拡張**
- 履歴管理Controller
- 設定管理Controller
- テーマ管理Controller

**View層の拡張**
- 設定画面の追加
- 履歴一覧画面の追加
- 検索機能画面の追加

---

## 15. 開発環境・ツール

### 15.1 必須ツール

| ツール | バージョン | 用途 |
|--------|-----------|------|
| Flutter SDK | 3.0.0以上 | 開発フレームワーク |
| Dart SDK | 3.0.0以上 | プログラミング言語 |
| Android Studio | 最新版 | IDE（推奨） |
| VS Code | 最新版 | IDE（代替） |
| Git | 2.x | バージョン管理 |

### 15.2 推奨プラグイン・拡張機能

**Android Studio**
- Flutter Plugin
- Dart Plugin

**VS Code**
- Flutter Extension
- Dart Extension
- Dart Code Metrics

### 15.3 使用パッケージ一覧

| パッケージ名 | バージョン | 用途 | 必須 |
|------------|-----------|------|-----|
| provider | ^6.1.1 | 状態管理 | ✓ |
| flutter_test | SDK付属 | テスト | ✓ |

---

## 16. デプロイメント

### 16.1 ビルド設定

**Android**
- minSdkVersion: 23
- targetSdkVersion: 33
- compileSdkVersion: 33

**iOS**
- Deployment Target: 12.0
- Swift Version: 5.0

### 16.2 アプリケーション情報

| 項目 | 値 |
|------|---|
| アプリ名 | 文章プレビューアプリ |
| バージョン | 1.0.0 |
| ビルド番号 | 1 |
| パッケージ名 | com.example.text_preview_app |

### 16.3 リリース前チェックリスト

```
□ 全テストが通過している
□ エラー・警告がない
□ 実機で動作確認済み
□ 複数の画面サイズで確認済み
□ パフォーマンス要件を満たしている
□ アプリアイコンが設定されている
□ アプリ名が正しく設定されている
□ バージョン番号が適切
□ 不要なログ出力が削除されている
□ デバッグコードが削除されている
```

---

## 17. ドキュメント管理

### 17.1 必要なドキュメント

| ドキュメント | 作成タイミング | 更新頻度 |
|------------|--------------|---------|
| 要件定義書 | プロジェクト開始時 | 要件変更時 |
| 詳細設計書（本書） | 設計フェーズ | 設計変更時 |
| API仕様書 | 実装フェーズ | コード変更時 |
| テスト仕様書 | テストフェーズ | テスト追加時 |
| ユーザーマニュアル | リリース前 | 機能追加時 |
| リリースノート | リリース時 | 毎リリース |

### 17.2 コードコメント規約

**クラスコメント**
- クラスの目的と責務を記述
- 使用例を記載（必要に応じて）

**メソッドコメント**
- メソッドの機能を簡潔に記述
- パラメータの説明
- 戻り値の説明
- 副作用があれば明記

**インラインコメント**
- 複雑なロジックに対してのみ記述
- Whyを説明（Whatではなく）

---

## 18. 品質保証

### 18.1 品質目標

| 指標 | 目標値 | 測定方法 |
|------|-------|---------|
| バグ密度 | 0.1個/KLOC以下 | バグトラッキング |
| テストカバレッジ | 80%以上 | カバレッジツール |
| ユーザー満足度 | 4.0/5.0以上 | アプリストアレビュー |
| クラッシュ率 | 0.1%以下 | クラッシュレポート |

### 18.2 品質チェック項目

**機能品質**
```
□ 全機能が仕様通り動作する
□ エッジケースで正常に動作する
□ エラーハンドリングが適切
□ データの整合性が保たれる
```

**性能品質**
```
□ パフォーマンス要件を満たす
□ メモリリークがない
□ バッテリー消費が適切
□ ネットワーク使用量が適切（N/A）
```

**使いやすさ品質**
```
□ UIが直感的
□ 操作がスムーズ
□ フィードバックが適切
□ アクセシビリティ対応
```

---

## 19. リスク管理

### 19.1 技術的リスク

| リスク | 発生確率 | 影響度 | 対策 |
|--------|---------|-------|------|
| パフォーマンス問題 | 中 | 中 | 最適化実装、デバウンス処理 |
| メモリリーク | 低 | 高 | 適切なdispose実装、テスト |
| 画面サイズ対応 | 低 | 中 | レスポンシブデザイン、実機テスト |
| Flutter SDK更新影響 | 低 | 中 | バージョン固定、定期アップデート |

### 19.2 スケジュールリスク

| リスク | 発生確率 | 影響度 | 対策 |
|--------|---------|-------|------|
| 実装遅延 | 中 | 中 | バッファ時間確保、優先度管理 |
| テスト時間不足 | 中 | 高 | 早期テスト開始、自動化 |
| 仕様変更 | 低 | 高 | 変更管理プロセス、柔軟な設計 |

---

## 20. 補足情報

### 20.1 用語集

| 用語 | 説明 |
|------|------|
| MVC | Model-View-Controllerアーキテクチャパターン |
| Provider | Flutterの状態管理パッケージ |
| ChangeNotifier | 変更通知機能を提供するクラス |
| Widget | Flutterの UI構成要素 |
| Navigator | 画面遷移を管理するクラス |
| StatefulWidget | 状態を持つWidget |
| StatelessWidget | 状態を持たないWidget |

### 20.2 参考資料

**公式ドキュメント**
- Flutter公式ドキュメント: https://flutter.dev/docs
- Dart言語仕様: https://dart.dev/guides
- Provider公式: https://pub.dev/packages/provider
- Material Design: https://material.io/design

**推奨書籍・記事**
- Flutter実践入門
- Dart言語プログラミング
- Flutter公式ブログ

### 20.3 問い合わせ先

**技術的な質問**
- プロジェクトリーダー: [担当者名]
- アーキテクト: [担当者名]

**仕様に関する質問**
- プロダクトオーナー: [担当者名]

---

## 21. 変更履歴

| バージョン | 日付 | 変更者 | 変更内容 |
|----------|------|-------|---------|
| 1.0 | 2025-10-02 | - | 初版作成 |

---

## 22. 承認

| 役割 | 氏名 | 承認日 | 署名 |
|------|------|-------|------|
| プロジェクトマネージャー | | | |
| アーキテクト | | | |
| テックリード | | | |

---

**以上、文章プレビューアプリ詳細設計書**