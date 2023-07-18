import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart' as editor;
import 'package:html2md/html2md.dart' as html2md;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = editor.HtmlEditorController(processNewLineAsBr: false);
  final _toolBarButtons = const [
    editor.StyleButtons(),
    editor.FontButtons(
      underline: false,
      subscript: false,
      superscript: false,
    ),
    editor.ListButtons(listStyles: false),
    editor.InsertButtons(
      video: false,
      audio: false,
    ),
    // ! This ones are not supported in markdown
    // editor.ColorButtons(),
    // editor.ParagraphButtons(),
    // editor.FontSettingButtons(),
  ];

  String text = 'It is empty';

  editor.HtmlToolbarOptions _getToolBarOptions(BuildContext context) {
    return editor.HtmlToolbarOptions(
      buttonBorderWidth: 0.0,
      dropdownBoxDecoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      dropdownItemHeight: 50.0,
      gridViewHorizontalSpacing: 0.0,
      renderBorder: true,
      renderSeparatorWidget: false,
      textStyle: Theme.of(context).textTheme.bodyMedium,
      toolbarType: editor.ToolbarType.nativeGrid,
      defaultToolbarButtons: _toolBarButtons,
    );
  }

  Widget _buildPreviewText() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(8.0),
        width: double.infinity,
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: SelectableText(text),
        ),
      ),
    );
  }

  Widget _buildReloadButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: FilledButton(
        onPressed: () async {
          final html = await _controller.getText();
          text = html2md.convert(html);
          if (mounted) {
            setState(() {});
          }
        },
        child: const Text('reload'),
      ),
    );
  }

  Widget _buildTextEditor(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        primaryColor: Colors.blue,
        toggleButtonsTheme: const ToggleButtonsThemeData(
          fillColor: Colors.white,
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 300.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.grey,
          ),
        ),
        child: editor.HtmlEditor(
          controller: _controller,
          htmlEditorOptions: const editor.HtmlEditorOptions(
            characterLimit: 1000,
            darkMode: false,
            hint: "Type here your text",
          ),
          htmlToolbarOptions: _getToolBarOptions(context),
          otherOptions: const editor.OtherOptions(
            height: 400,
          ),
          callbacks: editor.Callbacks(onChangeContent: (String? html) {
            if (html != null) {
              text = html2md.convert(html);
              if (mounted) {
                setState(() {});
              }
            }
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HTML Editor in Flutter"),
        backgroundColor: Colors.deepPurple.shade100,
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildTextEditor(context),
            const SizedBox(height: 40),
            _buildPreviewText(),
          ],
        ),
      ),
    );
  }
}
