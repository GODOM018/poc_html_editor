import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:markdown_widgets/markdown.dart';
import 'package:validation/validation.dart';

class LinkDialog extends StatefulWidget {
  const LinkDialog({
    this.buildCancelButton,
    this.buildDialogTextField,
    this.buildSaveButton,
    this.dialogPadding,
    this.dialogTitlePadding,
    this.initialText,
    super.key,
    this.link,
    required this.setResult,
    required this.textStyle,
  });

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
  final Widget Function({required void Function() onPressed})? buildSaveButton;
  final EdgeInsets? dialogPadding;
  final EdgeInsets? dialogTitlePadding;
  final String? initialText;
  final String? link;
  final void Function(String value) setResult;
  final TextStyle textStyle;

  @override
  State<LinkDialog> createState() => _LinkDialogState();
}

class _LinkDialogState extends State<LinkDialog> {
  final _dialogFormKey = GlobalKey<FormState>();

  late String _link = widget.link ?? '';
  late String _linkText = widget.initialText ?? '';
  String _result = '';

  bool get isLinkCreation => widget.link == null;

  void _onCancelButtonPress(BuildContext dialogContext) {
    _link = '';
    _linkText = '';
    if (mounted) {
      setState(() {});
    }
    Navigator.pop(dialogContext);
  }

  void _onLinkFieldChanged(String value) {
    _link = value;
    if (mounted) {
      setState(() {});
    }
  }

  bool _onLinkSave({
    required BuildContext context,
  }) {
    var saved = false;

    if (_dialogFormKey.currentState!.validate()) {
      final linkData = <String, String>{
        'text': _linkText,
        'link': _link,
      };
      _link = '';
      _linkText = '';
      if (mounted) {
        setState(() {});
      }
      _result = json.encode(linkData);
      saved = true;
    }

    return saved;
  }

  void _onLinkTextFieldChanged(String value) {
    _linkText = value;
    if (mounted) {
      setState(() {});
    }
  }

  void _onRemoveButtonPress(BuildContext dialogContext) {
    _link = '';
    _linkText = '';
    if (mounted) {
      setState(() {});
    }
    widget.setResult('[]()');
    Navigator.pop(dialogContext);
  }

  Widget _buildCancelButton({required BuildContext context}) {
    Widget result;

    if (widget.buildCancelButton != null) {
      result = widget.buildCancelButton!(
        onPressed: () {
          _onCancelButtonPress(context);
        },
      );
    } else {
      result = _buildDialogButton(
        rightPadding: 0,
        child: InkWell(
          onTap: () {
            _onCancelButtonPress(context);
          },
          child: const Center(
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    return result;
  }

  Widget _buildDialogActions(BuildContext context) {
    return Padding(
      padding: widget.dialogPadding ??
          const EdgeInsets.only(
            bottom: 32.0,
          ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLinkCreation) ...[
            _buildCancelButton(context: context),
            const SizedBox(
              width: 24.0,
            ),
          ],
          if (!isLinkCreation) ...[
            _buildRemoveButton(context: context),
            const SizedBox(
              width: 24.0,
            ),
          ],
          _buildSaveButton(
            onPressed: () {
              final saved = _onLinkSave(
                context: context,
              );

              if (saved) {
                Navigator.pop(context);
                widget.setResult(_result);
              }
            },
          ),
        ],
      ),
    );
  }

  Container _buildDialogButton({
    required Widget child,
    required double rightPadding,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        color: const Color(0xff35618d),
      ),
      height: 40.0,
      margin: EdgeInsets.only(
        bottom: 20.0,
        right: rightPadding,
      ),
      width: 100.0,
      child: child,
    );
  }

  InputDecoration _buildDialogInputDecoration({
    required IconData icon,
    required String label,
  }) {
    return InputDecoration(
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        gapPadding: 0.0,
      ),
      focusColor: Colors.grey,
      label: Text(label),
      prefixIcon: Icon(
        icon,
        color: const Color(0xff798e99),
      ),
    );
  }

  Widget _buildDialogInputs({required BuildContext context}) {
    final themeData = Theme.of(context);

    return Theme(
      data: themeData.copyWith(
        inputDecorationTheme: InputDecorationTheme(
          errorStyle: widget.textStyle.copyWith(
            color: Colors.red,
          ),
        ),
      ),
      child: Form(
        key: _dialogFormKey,
        child: Column(
          children: [
            _buildTextFieldLinkText(),
            const SizedBox(height: 24.0),
            _buildTextfieldLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoveButton({required BuildContext context}) {
    Widget result;

    if (widget.buildCancelButton != null) {
      result = widget.buildCancelButton!(
        label: 'Remove',
        onPressed: () {
          _onRemoveButtonPress(context);
        },
      );
    } else {
      result = _buildDialogButton(
        rightPadding: 0,
        child: InkWell(
          onTap: () {
            _onRemoveButtonPress(context);
          },
          child: const Center(
            child: Text(
              'Remove',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    return result;
  }

  Widget _buildSaveButton({required void Function() onPressed}) {
    Widget result;

    if (widget.buildSaveButton != null) {
      result = widget.buildSaveButton!(onPressed: onPressed);
    } else {
      result = _buildDialogButton(
        rightPadding: 20.0,
        child: InkWell(
          onTap: onPressed,
          child: const Center(
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    return result;
  }

  Widget _buildTextfieldLink() {
    Widget result;

    if (widget.buildDialogTextField != null) {
      result = widget.buildDialogTextField!(
        autofocus: true,
        enabled: true,
        icon: Icons.link_rounded,
        initialValue: _link,
        label: 'Link',
        onChanged: _onLinkFieldChanged,
        validator: Validation.urlValidator,
      );
    } else {
      result = TextFormField(
        autofocus: true,
        decoration: _buildDialogInputDecoration(
          icon: Icons.link_rounded,
          label: 'Link',
        ),
        initialValue: _link,
        onChanged: _onLinkFieldChanged,
        validator: Validation.validateUrl,
      );
    }

    return result;
  }

  Widget _buildTextFieldLinkText() {
    Widget result;

    if (widget.buildDialogTextField != null) {
      result = widget.buildDialogTextField!(
        enabled: !isLinkCreation,
        icon: Icons.format_color_text_rounded,
        initialValue: _linkText,
        label: 'Text',
        onChanged: _onLinkTextFieldChanged,
      );
    } else {
      result = TextFormField(
        enabled: !isLinkCreation,
        decoration: _buildDialogInputDecoration(
          icon: Icons.format_color_text_rounded,
          label: 'Text',
        ),
        initialValue: _linkText,
        onChanged: _onLinkTextFieldChanged,
      );
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(),
      child: StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            actions: [
              _buildDialogActions(context),
            ],
            backgroundColor: Colors.white,
            content: Container(
              constraints: const BoxConstraints(
                maxHeight: 150.0,
                minWidth: 480.0,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 64.0,
              ),
              child: _buildDialogInputs(
                context: context,
              ),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            title: Stack(
              alignment: Alignment.topLeft,
              children: [
                Center(
                  child: Padding(
                    padding: widget.dialogTitlePadding ??
                        const EdgeInsets.only(
                          bottom: 8.0,
                          top: 50.0,
                        ),
                    child: Text(
                      isLinkCreation ? 'Add Link' : 'Edit Link',
                      style: const TextStyle(
                        color: Color(0xff00233c),
                        fontSize: 28.0,
                        fontWeight: FontWeight.w700,
                        height: 1.7,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _onCancelButtonPress(context),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Color(0xff00233c),
                    size: 28.0,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
