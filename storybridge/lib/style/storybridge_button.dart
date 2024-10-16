import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/storybridge.dart'; // Storybridge

import 'package:mooc/style/storybridge_colors.dart' as storybridge_color;
import 'package:mooc/services/error_service.dart' as error_service;
import 'package:mooc/services/translation_service.dart' as translation_service;

class StorybridgeButton extends StatelessWidget {
  // members of MyWidget
  final String text;
  final Function()? onPressed;
  final bool invertedColor, darkenBackground, lightenBackground;
  final bool verticalOnlyPadding;
  final bool padding;
  final bool loading;
  final IconData? icon;
  final Widget? child;

  // constructor
  const StorybridgeButton({
    this.text = "",
    Key? key,
    this.onPressed,
    this.invertedColor = false,
    this.darkenBackground = false,
    this.lightenBackground = false,
    this.verticalOnlyPadding = false,
    this.padding = true,
    this.loading = false,
    this.child,
    this.icon,
  }) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    bool isTextRed = !invertedColor ? (!loading) : (loading);
    return Row(
      children: [
        Padding(
          padding: padding
              ? EdgeInsets.symmetric(
                  vertical: 8.0, horizontal: (verticalOnlyPadding ? 0.0 : 8.0))
              : EdgeInsets.zero,
          child: TextButton(
              onPressed: onPressed,
              style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all<Color>(
                      storybridge_color.background),
                  backgroundColor: !invertedColor
                      ? (!darkenBackground
                          ? (!lightenBackground
                              ? MaterialStateProperty.all<Color>(
                                  storybridge_color.storybridgeAccentBackground)
                              : MaterialStateProperty.all<Color>(
                                  storybridge_color.background))
                          : MaterialStateProperty.all<Color>(
                              storybridge_color.storybridgeAccentLight))
                      : MaterialStateProperty.all<Color>(
                          storybridge_color.storybridgeAccent),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ))),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      icon != null
                          ? Padding(
                              padding: const EdgeInsets.only(left: 8, right: 0),
                              child: Icon(
                                icon,
                                color: isTextRed
                                    ? storybridge_color.storybridgeAccent
                                    : storybridge_color.background,
                                size: 22,
                              ),
                            )
                          : Container(),
                      child ??
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: icon == null ? 10 : 8,
                                vertical: 11),
                            child: Text(
                              translation_service.translate(text),
                              style: isTextRed
                                  ? storybridgeTextH5RedStyle
                                  : storybridgeTextH5WhiteStyle,
                            ),
                          ),
                    ],
                  ),
                  loading
                      ? StorybridgeLoading(white: invertedColor)
                      : Container(),
                ],
              )),
        ),
      ],
    );
  }
}

class StorybridgeIconButton extends StatelessWidget {
  // members of MyWidget
  final IconData icon;
  final Function()? onPressed;
  late final bool isEnabled;
  final bool isGrabbable;
  final bool useAltStyle;

  // constructor
  StorybridgeIconButton(
      {Key? key,
      required this.icon,
      this.onPressed,
      bool? isEnabled,
      this.useAltStyle = false,
      this.isGrabbable = false})
      : super(key: key) {
    if (isEnabled == null) {
      this.isEnabled = onPressed != null;
    } else {
      this.isEnabled = isEnabled;
    }
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: TextButton(
          onPressed: !(isGrabbable || onPressed == null)
              ? () {
                  onPressed!();
                }
              : null,
          style: ButtonStyle(
              mouseCursor: MaterialStateProperty.all<MouseCursor>(!isGrabbable
                  ? SystemMouseCursors.click
                  : SystemMouseCursors.grab),
              backgroundColor: !useAltStyle
                  ? (isEnabled
                      ? MaterialStateProperty.all<Color>(
                          storybridge_color.storybridgeAccentBackground)
                      : MaterialStateProperty.all<Color>(
                          storybridge_color.backgroundDim))
                  : MaterialStateProperty.all<Color>(
                      storybridge_color.storybridgeAccent),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ))),
          child: Icon(icon,
              color: !useAltStyle
                  ? (isEnabled
                      ? storybridge_color.storybridgeAccent
                      : storybridge_color.borderColor)
                  : storybridge_color.background,
              size: 22)),
    );
  }
}

class StorybridgeSettingButton extends StatefulWidget {
  // members of MyWidget
  final String name;
  final bool isSmall;
  final Future<String> Function() loadValue;
  final Future<void> Function(String value) saveValue;
  final bool isLarge;

  // constructor
  StorybridgeSettingButton(
      {Key? key,
      required this.loadValue,
      required this.saveValue,
      required this.name,
      this.isLarge = false,
      this.isSmall = false})
      : super(key: key);

  @override
  State<StorybridgeSettingButton> createState() =>
      _StorybridgeSettingButtonState();
}

class _StorybridgeSettingButtonState extends State<StorybridgeSettingButton> {
  bool _loaded = false;
  final StorybridgeTextFieldController _valueController =
      StorybridgeTextFieldController();

  Future<bool> _loadValue() async {
    if (_loaded) return true;
    _valueController.text = await widget.loadValue();
    _loaded = true;
    return true;
  }

  void _saveValue() async {
    setState(() {
      _valueController.clearError();
    });
    try {
      await widget.saveValue(_valueController.text);
    } on error_service.StorybridgeException catch (e) {
      setState(() {
        _valueController.errorText = e.message;
      });
    }
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _loadValue(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              snapshot.hasData
                  ? Expanded(
                      flex: widget.isLarge ? 1 : 0,
                      child: Container(
                        constraints: !widget.isSmall
                            ? null
                            : const BoxConstraints(maxWidth: 200),
                        child: StorybridgeTextField(
                          label: widget.name,
                          isConstricted: !widget.isLarge,
                          isLarge: widget.isLarge,
                          controller: _valueController,
                        ),
                      ),
                    )
                  : const StorybridgeBoxLoading(height: 60, width: 270),
              StorybridgeButton(
                text: "Save",
                onPressed: _saveValue,
              )
            ],
          );
        });
  }
}

class StorybridgeSettingCheckbox extends StatefulWidget {
  // members of MyWidget
  final String name;
  final Future<bool> Function() loadValue;
  final Future<void> Function(bool value) saveValue;
  final String falseText;
  final String trueText;

  // constructor
  StorybridgeSettingCheckbox({
    Key? key,
    required this.loadValue,
    required this.saveValue,
    required this.name,
    required this.falseText,
    required this.trueText,
  }) : super(key: key);

  @override
  State<StorybridgeSettingCheckbox> createState() =>
      _StorybridgeSettingCheckboxState();
}

class _StorybridgeSettingCheckboxState
    extends State<StorybridgeSettingCheckbox> {
  bool _loaded = false;
  late bool _value;

  Future<bool> _loadValue() async {
    if (_loaded) return true;
    _value = await widget.loadValue();
    _loaded = true;
    return true;
  }

  void _toggleValue() async {
    setState(() {
      _value = !_value;
    });
    await widget.saveValue(_value);
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _loadValue(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              snapshot.hasData
                  ? StorybridgeButton(
                      text: _value ? widget.trueText : widget.falseText,
                      onPressed: _toggleValue,
                    )
                  : const StorybridgeBoxLoading(height: 60, width: 270),
            ],
          );
        });
  }
}
