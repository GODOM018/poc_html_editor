import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:html_editor_enhanced/html_editor.dart' as editor;
import 'package:hyperion_components/hyperion_components.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:markdown_widgets/markdown.dart';
import 'package:poc_html_editor/js_script.dart';
import 'package:poc_html_editor/widgets/link_dialog.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:validation/validation.dart';

class MarkdownEditor extends StatefulWidget {
  const MarkdownEditor({
    this.actions = const [
      MarkdownType.bold,
      MarkdownType.italic,
      MarkdownType.strikethrough,
      MarkdownType.link,
      MarkdownType.title,
      MarkdownType.list,
    ],
    this.charactersLimit,
    super.key,
    required this.onChange,
    this.buildCancelButton,
    this.buildDialogTextField,
    this.buildErrorDisclaimer,
    this.buildSaveButton,
    this.buttonsColor = Colors.blue,
    this.color = Colors.grey,
    this.controller,
    this.dialogPadding,
    this.dialogTitlePadding,
    this.enabled = true,
    this.errorColor = Colors.red,
    this.initialValue = '',
    this.label = '',
    this.validator,
  });

  /// Actions the editor will handle
  final List<MarkdownType> actions;

  final Widget Function({
    String? label,
    required void Function() onPressed,
  })? buildCancelButton;

  final Widget Function({
    bool? autofocus,
    bool? enabled,
    required IconData icon,
    String? initialValue,
    required String label,
    void Function(String value)? onChanged,
    ValueValidator? validator,
  })? buildDialogTextField;

  final Widget Function({
    String errorMessage,
  })? buildErrorDisclaimer;

  final Widget Function({
    required void Function() onPressed,
  })? buildSaveButton;

  /// Overrides markdown controls color
  final Color buttonsColor;

  /// The maximum of characters that can be display in the input
  final int? charactersLimit;

  /// Overrides the color of the input border
  final Color color;

  /// Pass your own controller
  final editor.HtmlEditorController? controller;

  final EdgeInsets? dialogPadding;

  final EdgeInsets? dialogTitlePadding;

  /// Disable or enable the edition of the Markdown Text Field
  final bool enabled;

  /// Color used in the error disclaimer
  final Color errorColor;

  /// Display an initial value in Markdown Text Field
  final String initialValue;

  /// Display a label in Markdown Text Field (hint text)
  final String label;

  /// Callback used to retrieve the markdown and html text in parent's Widget
  /// The function that will be executed when the text changes.
  final void Function({
    String? html,
    String? markdown,
  }) onChange;

  /// Add validators to the MarkdownTextInput.
  final String? Function(String? value)? validator;

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  late final List<MarkdownType> _actions = widget.actions;
  final RegExp _anchorRegExp = RegExp(r'<\s*a[^>]*>(.*?)<\s*/\s*a>');
  late final _controller = widget.controller ?? editor.HtmlEditorController();
  final List<MarkdownType?> _currentActiveToggle = [];
  final _toolBarButtons = const [
    // if any type is given will add by default styles buttons,
    // so a type of buttons is added but with every one set in false.
    editor.ColorButtons(
      foregroundColor: false,
      highlightColor: false,
    ),
  ];

  String? _errorMessage;
  String? _initialText;

  @override
  void initState() {
    super.initState();
    _initialText = widget.initialValue;
    if (_initialText != null) {
      _initialText = md.markdownToHtml(
        _initialText!,
        extensionSet: md.ExtensionSet.gitHubFlavored,
      );
    }
  }

  Future<void> _editLink({
    required String link,
    required String linkText,
  }) async {
    // TODO: add latch executor

    final wholeHTML = await _controller.getText();

    final editedLink = await _showEditLinkDialog(
      link: link,
      text: linkText,
    );

    final editedHTML = wholeHTML.splitMapJoin(
      _anchorRegExp, // Matches with every anchor in the text
      onMatch: (matches) {
        String result = matches[0] ?? '';
        final currentSelectedLink = '<a href="$link">$linkText</a>';
        if (currentSelectedLink == result) {
          if (editedLink == '[]()') {
            // removes the link formatting
            result = linkText;
            _currentActiveToggle.remove(MarkdownType.link);
          } else if (editedLink.isNotEmpty) {
            final Map<String, dynamic> linkData = json.decode(editedLink);
            final text = linkData['text'];
            final url = linkData['link'];
            // modifies the link;
            result = '<a href="$url">$text</a>';
          }
        }

        return result;
      },
    );
    _controller.setText(editedHTML);
  }

  editor.HtmlToolbarOptions _getToolBarOptions(BuildContext context) {
    return const editor.HtmlToolbarOptions(
      toolbarPosition: editor.ToolbarPosition.custom,
      //required to place toolbar anywhere!
    );
  }

  void _onChangeContent(String? html) {
    String? markdown;
    if (html != null) {
      markdown = html2md.convert(
        html,
        styleOptions: {
          'headingStyle': 'atx',
          'codeBlockStyle': 'fenced',
        },
      );
      _removeInvalidLinks(html);
    }
    widget.onChange(
      html: html,
      markdown: markdown,
    );

    // Execute validators
    if (widget.validator != null) {
      _errorMessage = widget.validator!(markdown);
    }
  }

  void _onFocus() {
    if (_controller.characterCount == 0) {
      _controller.execCommand('fontName', argument: 'Avenir');
    }
  }

  void _onInitEditor() {
    /// Set it to take all the available space in the webview.
    /// To avoid having two scroll bars at the right.
    _controller.setFullScreen();
    if (!widget.enabled) {
      _controller.disable();
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onLinkButtonPressed() async {
    final initialText = await _controller.getSelectedTextWeb();
    final result = await _showEditLinkDialog(text: initialText);

    if (result.isNotEmpty) {
      final Map<String, dynamic> linkData = json.decode(result);
      final text = linkData['text'];
      final url = linkData['link'];

      _controller.insertLink(
        text.isEmpty ? url : text,
        url,
        false,
      );
    } else {
      _currentActiveToggle.remove(MarkdownType.link);
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _onTogglePressed(int index) {
    final toggle = _actions[index];
    final isActive = _currentActiveToggle.contains(toggle);

    switch (toggle) {
      case MarkdownType.bold:
        _controller.execCommand('bold');
        break;
      case MarkdownType.italic:
        _controller.execCommand('italic');
        break;
      case MarkdownType.strikethrough:
        _controller.execCommand('strikeThrough');
        break;
      case MarkdownType.title:
        isActive
            ? _controller.execCommand('formatBlock', argument: 'p')
            : _controller.execCommand('formatBlock', argument: 'h3');
        break;
      case MarkdownType.list:
        _controller.execCommand('insertUnorderedList');
        break;
      case MarkdownType.link:
        _onLinkButtonPressed();
        break;
      default:
    }

    if (mounted) {
      setState(
        () {
          isActive
              ? _currentActiveToggle.remove(toggle)
              : _currentActiveToggle.add(toggle);
        },
      );
    }
  }

  /// In some cases links with empty text but with tags are added.
  /// But this kind of links aren't desired, so they're identified and removed.
  ///
  /// For instance: This link should be removed
  /// ```dart
  /// '<a href="http://google.com"><b><br></b></a>'
  /// ```
  void _removeInvalidLinks(String html) {
    final editedHTML = html.splitMapJoin(
      _anchorRegExp, // Matches with every anchor in the text
      onMatch: (matches) {
        String result = matches[0] ?? '';

        if (result.contains('<br>')) {
          result = '';
        }

        return result;
      },
    );

    if (editedHTML != html) {
      _controller.setText(editedHTML);
    }
  }

  Future<String> _showEditLinkDialog({
    String? link,
    required String text,
  }) async {
    var result = '';

    await showDialog(
      barrierColor: const Color.fromRGBO(0, 36, 61, 0.8),
      builder: (dialogContext) => PointerInterceptor(
        child: LinkDialog(
          buildCancelButton: widget.buildCancelButton,
          buildDialogTextField: widget.buildDialogTextField,
          buildSaveButton: widget.buildSaveButton,
          dialogPadding: widget.dialogPadding,
          dialogTitlePadding: widget.dialogTitlePadding,
          initialText: text,
          link: link,
          onClose: () => _controller.setFocus(),
          textStyle: HyperionTextStyle.t6_heavy,
          setResult: (String value) => result = value,
        ),
      ),
      context: context,
    );

    return result;
  }

  void _updateActiveToggles(editor.EditorSettings editorSetting) async {
    _currentActiveToggle.clear();

    if (editorSetting.isBold) {
      _currentActiveToggle.add(MarkdownType.bold);
    }
    if (editorSetting.isItalic) {
      _currentActiveToggle.add(MarkdownType.italic);
    }
    if (editorSetting.isStrikethrough) {
      _currentActiveToggle.add(MarkdownType.strikethrough);
    }
    if (editorSetting.isUl) {
      _currentActiveToggle.add(MarkdownType.list);
    }

    final html = editorSetting.parentElement;
    final isTitle = html == 'h1' ||
        html == 'h2' ||
        html == 'h3' ||
        html == 'h4' ||
        html == 'h5' ||
        html == 'h6';

    if (isTitle) {
      _currentActiveToggle.add(MarkdownType.title);
    }

    /// Call script which checks whether a link is selected or not.
    final Map<String, dynamic> scriptResponse =
        await _controller.evaluateJavascriptWeb(
      "isLinkSelected",
      hasReturnValue: true,
    );

    final bool isLinkSelected = scriptResponse['isLinkSelected'] ?? false;
    final int? nodeTextIndex = scriptResponse['textIndex'];
    if (isLinkSelected) {
      _currentActiveToggle.add(MarkdownType.link);

      final selectedText = await _controller.getSelectedTextWeb();
      if (selectedText.isEmpty) {
        // Only allow the edition of the link on popover.
        // Avoid showing the dialog when a text with links is selected.
        /// Call script which gets the href and the text of the anchor tag
        final Map<String, dynamic> scriptResponseSelection =
            await _controller.evaluateJavascriptWeb(
          "getSelectedLinkParts",
          hasReturnValue: true,
        );

        String link = scriptResponseSelection['link'] ?? '';
        link = link.endsWith('/') ? link.substring(0, link.length - 1) : link;
        final String linkText = scriptResponseSelection['text'] ?? '';

        /// Avoid calling the dialog when the selection includes the whole text
        /// or when the end selection index matches with the end of the link.
        final isCorrect = !_anchorRegExp.hasMatch(linkText) &&
            linkText.length != nodeTextIndex;
        if (isCorrect) {
          await _editLink(
            link: link,
            linkText: linkText,
          );
        }
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  List<Widget> _buildCustomToggles() {
    final children = <Widget>[];
    final selectedStatus = <bool>[];

    for (final action in _actions) {
      children.add(
        Icon(
          action.icon,
        ),
      );
      selectedStatus.add(
        _currentActiveToggle.contains(action),
      );
    }

    return [
      Theme(
        data: ThemeData.light().copyWith(
          toggleButtonsTheme: ToggleButtonsThemeData(
            fillColor: widget.enabled ? Colors.white : Colors.grey,
            highlightColor: const Color(0xffacd4e7),
            hoverColor: const Color(0xffe1eef4),
            selectedColor: widget.buttonsColor,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: widget.color,
              ),
              color: widget.enabled ? Colors.white : Colors.grey.shade300,
              shape: BoxShape.rectangle,
            ),
            height: 50,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) => ToggleButtons(
                constraints: BoxConstraints.expand(
                  width: (constraints.maxWidth - (_actions.length + 1)) /
                      _actions.length,
                ),
                direction: Axis.horizontal,
                isSelected: selectedStatus,
                onPressed: widget.enabled ? _onTogglePressed : null,
                children: children,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  editor.HtmlEditor _buildEditor({
    required BuildContext context,
    required double height,
  }) {
    return editor.HtmlEditor(
      callbacks: editor.Callbacks(
        onChangeContent: _onChangeContent,
        onFocus: _onFocus,
        onInit: _onInitEditor,
        onPaste: () => _controller.evaluateJavascriptWeb('setStyle'),
      ),
      controller: _controller,
      htmlEditorOptions: editor.HtmlEditorOptions(
        autoAdjustHeight: false,
        characterLimit: widget.charactersLimit,
        customOptions: "popover: {link: []},",
        darkMode: false,
        filePath: 'summernote.html',
        hint: widget.label,
        initialText: _initialText,
        webInitialScripts: UnmodifiableListView(
          [
            editor.WebScript(
              name: 'isLinkSelected',
              script: JsScript.isLinkScript,
            ),
            editor.WebScript(
              name: 'getSelectedLinkParts',
              script: JsScript.getSelectedLinkParts,
            ),
            editor.WebScript(
              name: 'setStyle',
              script: JsScript.setStyleScript,
            ),
          ],
        ),
      ),
      htmlToolbarOptions: _getToolBarOptions(context),
      otherOptions: editor.OtherOptions(
        height: max(300.0, height),
      ),
    );
  }

  Widget _buildEditorBorder({required Widget child}) {
    Widget result;

    result = Theme(
      data: ThemeData.light().copyWith(
        primaryColor: Colors.blue,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(
          Radius.circular(4.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: widget.enabled ? Colors.white : Colors.grey.shade300,
            border: _errorMessage?.isNotEmpty == true
                ? Border(
                    bottom: BorderSide(
                      color: widget.errorColor,
                      width: 2.0,
                    ),
                    left: BorderSide(
                      color: widget.color,
                    ),
                    right: BorderSide(
                      color: widget.color,
                    ),
                    top: BorderSide(
                      color: widget.color,
                    ),
                  )
                : Border.all(
                    color: widget.color,
                  ),
          ),
          child: child,
        ),
      ),
    );

    return result;
  }

  Widget _buildErrorDisclaimer() {
    return widget.buildErrorDisclaimer != null
        ? widget.buildErrorDisclaimer!(errorMessage: _errorMessage!)
        : Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: widget.errorColor,
              ),
              Text(
                _errorMessage!,
                style: TextStyle(color: widget.errorColor),
              )
            ],
          );
  }

  Widget _buildToolbar() {
    return LayoutBuilder(
      builder: (context, constraints) => editor.ToolbarWidget(
        controller: _controller,
        htmlToolbarOptions: editor.HtmlToolbarOptions(
          buttonBorderWidth: 0.0,
          gridViewVerticalSpacing: 0.0,
          customToolbarButtons: _buildCustomToggles(),
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
          toolbarPosition: editor.ToolbarPosition.custom,
          toolbarType: editor.ToolbarType.nativeGrid,
        ),
        callbacks: editor.Callbacks(
          onChangeSelection: _updateActiveToggles,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = (MediaQuery.sizeOf(context).height - 200) / 2;

    return Column(
      children: [
        _buildEditorBorder(
          child: Column(
            children: [
              _buildToolbar(),
              _buildEditor(
                context: context,
                height: height,
              ),
            ],
          ),
        ),
        if (_errorMessage?.isNotEmpty == true) _buildErrorDisclaimer(),
      ],
    );
  }
}
