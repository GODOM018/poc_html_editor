import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart' as editor;
import 'package:html2md/html2md.dart' as html2md;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = editor.HtmlEditorController();
  String text = 'It is empty';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
