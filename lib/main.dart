import 'package:flutter/material.dart';
import 'package:poc_html_editor/app_theme.dart';
import 'package:poc_html_editor/screens/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HTML editor POC',
      theme: AppTheme.theme,
      home: const HomePage(),
    );
  }
}
