import 'dart:math';

import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart' as editor;
import 'package:html2md/html2md.dart' as html2md;

import 'package:markdown_widgets/markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:poc_html_editor/app_theme.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

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

  String _initialText = '''## Cupcake lorem ipsum

* * *

Sweet roll candy canes **_jujubes [chocolate](http://google.com)_** bar ~~jelly beans cake~~. Marshmallow sweet roll chocolate cake jujubes tart lemon drops pastry cake powder.  

*   Brownie
*   halvah
*   jujubes with **[link](http://google.com)**

> "This is a very interesting Quotation: Chocolate bar cake caramels."''';
  bool _showMarkdownPreview = false;
  String _text = 'It is empty';

  @override
  void initState() {
    super.initState();
    _initialText = md.markdownToHtml(
      _initialText,
      extensionSet: md.ExtensionSet.gitHubFlavored,
    );
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
      // textStyle: HyperionTextStyle.t7_medium,
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
          child: AnimatedCrossFade(
            crossFadeState: _showMarkdownPreview
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 100),
            firstChild: MediaMarkdownBody(
              _text,
              onLinkTap: (Uri url) {
                url_launcher.launchUrl(url);
              },
              styleSheet: AppTheme.getMarkdownStyleSheet(context),
            ),
            secondChild: SelectableText(_text),
          ),
        ),
      ),
    );
  }

  Center _buildSwitchButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FlutterSwitch(
          activeColor: Colors.deepPurple,
          activeText: "Preview",
          borderRadius: 30.0,
          height: 40.0,
          inactiveColor: Colors.deepPurple.shade400,
          inactiveText: "Markdown",
          padding: 8.0,
          showOnOff: true,
          toggleSize: 25.0,
          value: _showMarkdownPreview,
          valueFontSize: 15.0,
          width: 130.0,
          onToggle: (value) {
            if (mounted) {
              setState(
                () {
                  _showMarkdownPreview = value;
                },
              );
            }
          },
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
              _text = html2md.convert(
                html,
                styleOptions: {
                  'headingStyle': 'atx',
                  'codeBlockStyle': 'fenced',
                },
              );
              if (mounted) {
                setState(() {});
              }
            }
          },
          onInit: () {
            /// Set it to take all the available space in the webview.
            /// To avoid having two scroll bars at the right.
            _controller.setFullScreen();
            if (mounted) {
              setState(() {});
            }
          },
        ),
        controller: _controller,
        htmlEditorOptions: editor.HtmlEditorOptions(
          autoAdjustHeight: false,
          // characterLimit: 1000,
          initialText: _initialText,
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
            _buildSwitchButton(),
            _buildPreviewText(),
          ],
        ),
      ),
    );
  }
}
