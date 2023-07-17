import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart' as editor;
import 'package:html2md/html2md.dart' as html2md;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _controller = editor.HtmlEditorController();

  String text = 'It is empty';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HTML editor POC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("HTML Editor in Flutter"),
          backgroundColor: Colors.deepPurple.shade100,
        ),
        body: Container(
          padding: const EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            children: [
              editor.HtmlEditor(
                controller: _controller,
                htmlEditorOptions: const editor.HtmlEditorOptions(
                  hint: "Type you Text here",
                ),
                htmlToolbarOptions: const editor.HtmlToolbarOptions(
                  toolbarType: editor.ToolbarType.nativeGrid,
                ),
                otherOptions: const editor.OtherOptions(
                  height: 400,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              SelectableText(text),
              const SizedBox(
                height: 40,
              ),
              FilledButton(
                onPressed: () async {
                  final html = await _controller.getText();
                  text = html2md.convert(html);
                  if (mounted) {
                    setState(() {});
                  }
                },
                child: const Text('reload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
