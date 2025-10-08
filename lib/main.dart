import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/text_controller.dart';
import 'views/input_screen.dart';

void main() {
  runApp(const TextPreviewApp());
}

class TextPreviewApp extends StatelessWidget {
  const TextPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TextController(),
      child: MaterialApp(
        title: '文章プレビューアプリ',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: const InputScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
