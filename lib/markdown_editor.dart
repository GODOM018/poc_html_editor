import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:html_editor_enhanced/html_editor.dart' as editor;
import 'package:hyperion_components/hyperion_components.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:markdown_widgets/markdown.dart';
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
    this.buildSaveButton,
    this.buttonsColor = Colors.blue,
    this.color = Colors.grey,
    this.controller,
    this.dialogPadding,
    this.dialogTitlePadding,
    this.enabled = true,
    this.initialValue = '',
    this.label = '',
    this.textStyle,
    this.validators,
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

  // TODO: suppor enabled or disabe editor
  /// Disable or enable the edition of the Markdown Text Field
  final bool enabled;

  /// Display an initial value in Markdown Text Field
  final String initialValue;

  // TODO: support label
  /// Display a label in Markdown Text Field
  final String label;

  /// Callback used to retrieve the markdown and html text in parent's Widget
  /// The function that will be executed when the text changes.
  final void Function({
    String? html,
    String? markdown,
  }) onChange;

  // TODO: support text style
  /// Overrides input text style
  final TextStyle? textStyle;

  // TODO: support validators
  /// Add validators to the MarkdownTextInput.
  final String? Function(String? value)? validators;

  @override
  State<MarkdownEditor> createState() => _MarkdownEditorState();
}

class _MarkdownEditorState extends State<MarkdownEditor> {
  late final List<MarkdownType> _actions = widget.actions;
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

  String? _initialText;
  final _linkScript = """
function isLink() {
    if (window.getSelection().toString !== '') {
      const selection = window.getSelection().getRangeAt(0)
      if (selection) {
        if (selection.startContainer.parentNode.tagName === 'A'
        || selection.endContainer.parentNode.tagName === 'A') {
          return true
        } else { return false }
      } else { return false }
    }
  }
function getSelectedLink(){
  const selection= window.getSelection().getRangeAt(0)
  
  return selection.startContainer.parentNode.href
}

function getSelectedText(){
  const selection= window.getSelection().getRangeAt(0)

  return selection.endContainer.parentNode.innerHTML
}

var isLinkSelected= isLink();

var getSelection= getSelectedLink();

window.parent.postMessage(
  JSON.stringify(
    {
      "type": "toDart: isLinkSelected", 
      "isLinkSelected": isLinkSelected,
    }
  ), 
  "*"
);  

window.parent.postMessage(
  JSON.stringify(
    {
      "type": "toDart: getSelection", 
      "text": getSelectedText(),
      "link": getSelectedLink()
     
    }
  ), 
  "*"
);  
""";

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
    }
    widget.onChange(
      html: html,
      markdown: markdown,
    );
  }

  void _onInitEditor() {
    /// Set it to take all the available space in the webview.
    /// To avoid having two scroll bars at the right.
    _controller.setFullScreen();

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

    if (isLinkSelected) {
      _currentActiveToggle.add(MarkdownType.link);
      await _editLink();
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _editLink() async {
    final Map<String, dynamic> scriptResponseSelection =
        await _controller.evaluateJavascriptWeb(
      "getSelection",
      hasReturnValue: true,
    );
    String link = scriptResponseSelection['link'] ?? '';
    link = link.endsWith('/') ? link.substring(0, link.length - 1) : link;
    final String linkText = scriptResponseSelection['text'] ?? '';
    final wholeHTML = await _controller.getText();

    final editedLink = await _showEditLinkDialog(
      link: link,
      text: linkText,
    );
    final anchor = RegExp(r'<\s*a[^>]*>(.*?)<\s*/\s*a>');
    final editedHTML = wholeHTML.splitMapJoin(
      anchor,
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
          // TODO: unify text styles
          textStyle: HyperionTextStyle.t6_heavy,
          setResult: (String value) => result = value,
        ),
      ),
      context: context,
    );

    return result;
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
            fillColor: Colors.white,
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
              color: Colors.white,
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

  Widget _buildEditorBorder({required Widget child}) {
    return Theme(
      data: ThemeData.light().copyWith(
        primaryColor: Colors.blue,
      ),
      child: Container(
        decoration: ShapeDecoration(
          color: widget.enabled ? Colors.white : const Color(0xffe6edef),
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(4.0),
            ),
            side: BorderSide(
              color: widget.color,
            ),
          ),
        ),
        padding: const EdgeInsets.only(
          top: HyperionPadding.xlarge + HyperionIconSize.medium,
        ),
        child: child,
      ),
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
          // onChangeContent: (String? html) => _onChangeContent(html),
          // onInit: () => _onInitEditor(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = (MediaQuery.sizeOf(context).height - 180.0) / 2;

    return Stack(
      alignment: Alignment.topLeft,
      children: [
        _buildEditorBorder(
          child: editor.HtmlEditor(
            callbacks: editor.Callbacks(
              onChangeContent: _onChangeContent,
              onInit: _onInitEditor,
            ),
            controller: _controller,
            htmlEditorOptions: editor.HtmlEditorOptions(
              autoAdjustHeight: false,
              characterLimit: widget.charactersLimit,
              initialText: _initialText,
              darkMode: false,
              hint: "Type here your text",
              customOptions: "popover: {link:    []},",
              webInitialScripts: UnmodifiableListView(
                [
                  editor.WebScript(
                    name: 'isLinkSelected',
                    script: _linkScript,
                  ),
                ],
              ),
            ),
            htmlToolbarOptions: _getToolBarOptions(context),
            otherOptions: editor.OtherOptions(
              height: max(300.0, height),
            ),
          ),
        ),
        _buildToolbar(),
      ],
    );
  }
}
