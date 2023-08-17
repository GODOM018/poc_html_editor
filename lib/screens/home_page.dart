import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter/material.dart';
import 'package:hyperion_components/hyperion_components.dart';
import 'package:markdown_widgets/markdown.dart';
import 'package:poc_html_editor/app_theme.dart';
import 'package:poc_html_editor/markdown_editor.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:validation/validation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _initialText = '';
  // 'The text contains a [link](http://google.com) to test the active toggles.';
  // '# Header 1\n\n## Header 2\n\n### Header 3\n\n#### Header 4\n\n##### Header 5\n\n###### Header 6\n[link](http://google.com)';
  bool _showMarkdownPreview = false;
  String _text = 'It is empty';

  Widget _buildCancelButton({
    String? label,
    required void Function() onPressed,
  }) {
    return HyperionButton.secondary(
      label: label ?? 'Cancel',
      onPressed: onPressed,
    );
  }

  Widget _buildDialogTextField({
    bool? autofocus,
    bool? enabled,
    required IconData icon,
    String? initialValue,
    required String label,
    void Function(String value)? onChanged,
    ValueValidator? validator,
  }) {
    return HyperionTextField(
      autofocus: autofocus ?? false,
      decoration: InputDecoration(
        label: Text(label),
        prefixIcon: Icon(
          icon,
          color: HyperionColor.grey600,
        ),
      ),
      enabled: enabled ?? true,
      initialValue: initialValue,
      onChanged: onChanged,
      validators: validator != null ? [validator] : [],
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

  Widget _buildSaveButton({required void Function() onPressed}) {
    return HyperionButton(
      label: 'Save',
      onPressed: onPressed,
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
            MarkdownEditor(
              buttonsColor: HyperionColor.slate700,
              buildDialogTextField: _buildDialogTextField,
              buildCancelButton: _buildCancelButton,
              buildSaveButton: _buildSaveButton,
              color: HyperionColor.grey600,
              initialValue: _initialText,
              label: "Type here your text",
              onChange: ({String? html, String? markdown}) {
                _text = markdown ?? '';
                if (mounted) {
                  setState(() {});
                }
              },
            ),
            _buildSwitchButton(),
            _buildPreviewText(),
          ],
        ),
      ),
    );
  }
}
