import 'dart:math';

import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart' as editor;
import 'package:html2md/html2md.dart' as html2md;
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:hyperion_components/hyperion_components.dart';
import 'package:markdown_widgets/markdown.dart';
import 'package:markdown/markdown.dart' as md;

class MarkdownEditor extends StatefulWidget {
  const MarkdownEditor({
    this.initialText,
    super.key,
    required this.onChange,
  });

  final String? initialText;
  final void Function(String value) onChange;

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
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

  late String? _initialText = widget.initialText;

  @override
  void initState() {
    super.initState();
    if (_initialText != null) {
      _initialText = md.markdownToHtml(
        _initialText!,
        extensionSet: md.ExtensionSet.gitHubFlavored,
      );
    }
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
      toolbarType: editor.ToolbarType.nativeGrid,
      onButtonPressed: (type, status, updateStatus) =>
          _onButtonPressed(type, status, updateStatus),
    );
  }

  Future<bool> _onButtonPressed(
    ButtonType type,
    bool? status,
    Function? updateStatus,
  ) async {
    bool continueWithInternalHandler = true;
    if (type == ButtonType.link) {
      final initialText = await _controller.getSelectedTextWeb();
      _buildLinkDialog(initialText);

      continueWithInternalHandler = false;
    }

    return continueWithInternalHandler;
  }

  Future<void> _buildLinkDialog(String initialText) async {
    final text = TextEditingController();
    final url = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      barrierColor: const Color.fromRGBO(0, 36, 61, 0.8),
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData.light(),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 24.0,
                ),
                scrollable: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                title: Text(
                  'Add link',
                  style: HyperionTextStyle.t6_heavy,
                ),
                content: SizedBox(
                  width: 300.0,
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Text to display',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        HyperionTextField(
                          autofocus: true,
                          controller: text,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Text',
                          ),
                          initialValue: initialText,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'URL',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        HyperionTextField(
                          controller: url,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'URL',
                          ),
                          validators: [
                            Validation.urlValidator,
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: HyperionButton.secondary(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            label: 'Cancel',
                          ),
                        ),
                        HyperionButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              _controller.insertLink(
                                text.text.isEmpty ? url.text : text.text,
                                url.text,
                                false,
                              );
                              Navigator.of(context).pop();
                            }
                          },
                          label: 'Save',
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
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

  @override
  Widget build(BuildContext context) {
    final height = (MediaQuery.sizeOf(context).height - 180.0) / 2;

    return _buildEditorBorder(
      child: editor.HtmlEditor(
        callbacks: editor.Callbacks(
          onChangeContent: (String? html) {
            String text = '';
            if (html != null) {
              text = html2md.convert(
                html,
                styleOptions: {
                  'headingStyle': 'atx',
                  'codeBlockStyle': 'fenced',
                },
              );
            }
            widget.onChange(text);
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
}
