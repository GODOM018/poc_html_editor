import 'dart:math';

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
  final _toolBarButtons = const [
    editor.StyleButtons(),
    editor.FontButtons(
      subscript: false,
      superscript: false,
      underline: false,
    ),
    editor.ListButtons(
      listStyles: false,
    ),
    editor.InsertButtons(
      audio: false,
      video: false,
    ),
    editor.OtherButtons(
      codeview: true, //only for testing purposes
      fullscreen: false,
      help: false,
    ),
    // ! This ones are not supported in markdown
    // editor.ColorButtons(),
    // editor.ParagraphButtons(),
    // editor.FontSettingButtons(),
  ];

  String text = 'It is empty';

  @override
  void initState() {
    super.initState();
  }

  editor.HtmlToolbarOptions _getToolBarOptions(BuildContext context) {
    return editor.HtmlToolbarOptions(
      buttonBorderWidth: 0.0,
      defaultToolbarButtons: _toolBarButtons,
      dropdownBoxDecoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade300,
        ),
        color: Colors.white,
      ),
      dropdownItemHeight: 50.0,
      gridViewHorizontalSpacing: 0.0,
      renderBorder: true,
      renderSeparatorWidget: false,
      textStyle: Theme.of(context).textTheme.bodyMedium,
      toolbarType: editor.ToolbarType.nativeGrid,
    );
  }

  Widget _buildEditorBorder({required Widget child}) {
    return Theme(
      data: ThemeData.light().copyWith(
        primaryColor: Colors.blue,
        toggleButtonsTheme: const ToggleButtonsThemeData(
          fillColor: Colors.white,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
          ),
          color: Colors.white,
        ),
        child: child,
      ),
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

  Widget _buildTextEditor(BuildContext context) {
    final height = (MediaQuery.sizeOf(context).height - 180.0) / 2;

    return _buildEditorBorder(
      child: editor.HtmlEditor(
        callbacks: editor.Callbacks(
          onChangeContent: (String? html) {
            if (html != null) {
              text = html2md.convert(
                html,
                styleOptions: {
                  'headingStyle': 'atx',
                },
              );
              if (mounted) {
                setState(() {});
              }
            }
          },
          onInit: () {
            /// Set it to take all the available space in the webview.
            _controller.setFullScreen();
            if (mounted) {
              setState(() {});
            }
          },
        ),
        controller: _controller,
        htmlEditorOptions: const editor.HtmlEditorOptions(
          autoAdjustHeight: false,
          // characterLimit: 1000,
          darkMode: false,
          hint: "Type here your text",
        ),
        htmlToolbarOptions: _getToolBarOptions(context),
        otherOptions: editor.OtherOptions(
          height: max(300.0, height),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade100,
        title: const Text("HTML Editor in Flutter"),
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
