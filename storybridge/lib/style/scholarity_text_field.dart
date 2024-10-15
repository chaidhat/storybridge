import 'dart:math' as maths;

import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/Storybridge.dart'; // Storybridge

import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:mooc/style/Storybridge_colors.dart' as Storybridge_color;
import 'package:mooc/services/translation_service.dart' as translation_service;

const List<String> MONTH_HASH = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
];

class StorybridgeTextFieldController extends TextEditingController {
  String? errorText;
  void clearError() {
    errorText = null;
  }
}

class StorybridgeTextFieldFocusNode {
  FocusNode? focusNode;
}

class StorybridgeTextField extends StatelessWidget {
  // members of MyWidget
  final String label;
  final bool isPragmaticField;
  final bool isPasswordField;
  final bool isLarge;
  final bool isConstricted;
  final StorybridgeTextFieldController? controller;
  final StorybridgeTextFieldFocusNode focusNodeController =
      StorybridgeTextFieldFocusNode();
  final bool isEnabled;
  final String? hintText;

  // constructor
  StorybridgeTextField({
    Key? key,
    required this.label,
    this.isPragmaticField = false,
    this.isPasswordField = false,
    this.isLarge = false,
    this.isConstricted = false,
    this.isEnabled = true,
    this.hintText,
    this.controller,
  }) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SizedBox(
        height: 77,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints:
                  isConstricted ? const BoxConstraints(maxWidth: 300) : null,
              padding: isConstricted
                  ? const EdgeInsets.symmetric(horizontal: 8)
                  : null,
              child: TextFormField(
                controller: controller,
                focusNode: focusNodeController.focusNode,
                maxLines: !isLarge ? 1 : 3,
                autofocus: true,
                autocorrect: !isPragmaticField,
                enableSuggestions: !isPragmaticField,
                obscureText: isPasswordField,
                enabled: isEnabled,
                style: StorybridgeTextPStyle,
                cursorColor: Storybridge_color.black,
                decoration: InputDecoration(
                  hintText: hintText,
                  filled: true,
                  fillColor: Storybridge_color.background,
                  focusColor: Storybridge_color.StorybridgeAccent,
                  labelText: translation_service.translate(label),
                  labelStyle: StorybridgeTextPDimStyle,
                  focusedBorder: OutlineInputBorder(
                    // width: 0.0 produces a thin "hairline" border
                    borderSide: BorderSide(
                        color: Storybridge_color.StorybridgeAccent, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    // width: 0.0 produces a thin "hairline" border
                    borderSide: BorderSide(
                        color: Storybridge_color.borderColor, width: 1.0),
                  ),
                  disabledBorder: OutlineInputBorder(
                    // width: 0.0 produces a thin "hairline" border
                    borderSide: BorderSide(
                        color: Storybridge_color.borderColor, width: 1.0),
                  ),
                  prefixIcon: controller?.errorText == null
                      ? null // if errorText is null, then no icon is needed
                      : Icon(Icons.warning_rounded,
                          color: Storybridge_color.StorybridgeAccent),
                ),
              ),
            ),
            TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                tween: Tween<double>(
                    begin: 0, end: controller?.errorText == null ? 0 : 10.0),
                curve: Curves.ease,
                builder: (BuildContext _, double anim, Widget? __) {
                  return Padding(
                    padding: EdgeInsets.only(
                        left: 10.0 + 20 * (maths.sin(anim) * (1 / (anim + 1))),
                        top: 2),
                    child: Text(
                        translation_service
                            .translate(controller?.errorText ?? ""),
                        style: TextStyle(
                          color: Storybridge_color.StorybridgeAccent,
                          fontSize: 13,
                        )),
                  );
                }),
          ],
        ),
      ),
    );
  }
}

// myPage class which creates a state on call
class StorybridgeEditableText extends StatefulWidget {
  // members of MyWidget
  final void Function() onSubmit;
  final StorybridgeTextFieldController? controller;
  final quill.QuillController? richController;
  final TextStyle style;
  final bool enabled;
  final bool avoidLineBreaks;
  const StorybridgeEditableText(
      {Key? key,
      required this.onSubmit,
      this.controller,
      this.richController,
      required this.style,
      this.enabled = true,
      this.avoidLineBreaks =
          true}) // this prevents the thai newline bug from occuring, unless specified otherwise
      : super(key: key);

  @override
  _StorybridgeEditableTextState createState() =>
      _StorybridgeEditableTextState();
}

// myPage state
class _StorybridgeEditableTextState extends State<StorybridgeEditableText> {
  final FocusNode _focus = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focus.hasFocus) {
      widget.onSubmit();
    }
  }

  // force no tabs, new lines or carriage returns
  void _forceNoLinebreaks() {
    if (widget.controller != null) {
      widget.controller!.text =
          widget.controller!.text.replaceAll(RegExp(r'[\t\n\r]+'), '');
    }
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    if (widget.richController == null) {
      if (widget.avoidLineBreaks) _forceNoLinebreaks();
      // not rich text, use regular controller
      if (widget.enabled) {
        return TextFormField(
          onChanged: (_) {
            if (widget.avoidLineBreaks) _forceNoLinebreaks();
          },
          controller: widget.controller,
          focusNode: _focus,
          style: widget.style,
          enabled: widget.enabled,
          maxLines: null,
          minLines: null,
          decoration: const InputDecoration(
            isDense: true,
            isCollapsed: true,
            border: InputBorder.none,
          ),
        );
      } else {
        return Align(
          alignment: Alignment.centerLeft,
          child: SelectableText(
            translation_service.translate(widget.controller!.text),
            style: widget.style,
            maxLines: null,
          ),
        );
      }
    } else {
      // rich text, use rich controller
      return quill.QuillEditor(
        focusNode: _focus,
        scrollController: _scrollController,
        scrollable: false,
        padding: EdgeInsets.zero,
        autoFocus: false,
        expands: false,
        controller: widget.richController!,
        readOnly: !widget.enabled, // true for view only mode
      );
    }
  }
}

// myPage class which creates a state on call
class SwappableTextField extends StatefulWidget {
  final Widget textWidget;
  final StorybridgeTextField textFieldWidget;
  final Function onSubmit;
  const SwappableTextField(
      {Key? key,
      required this.textWidget,
      required this.textFieldWidget,
      required this.onSubmit})
      : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<SwappableTextField> {
  bool editMode = false;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focus.hasFocus) {
      widget.onSubmit();
      setState(() {
        editMode = false;
      });
    }
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    if (editMode) {
      return InkWell(child: widget.textFieldWidget);
    } else {
      return InkWell(
          onTap: () {
            setState(() {
              editMode = true;
              widget.textFieldWidget.focusNodeController.focusNode = _focus;
            });
          },
          child: MouseRegion(
              cursor: SystemMouseCursors.text, child: widget.textWidget));
    }
    // ignore: unused_local_variable
  }
}

// myPage class which creates a state on call
class StorybridgeDropdown extends StatefulWidget {
  final List<String>? dropdownTypes;
  final Map<String, dynamic>? mappedDropdownTypes;
  final String label;
  final bool isEnabled;
  final StorybridgeTextFieldController? controller;
  final void Function(dynamic value)? onSubmit;
  final double? width;
  const StorybridgeDropdown({
    Key? key,
    required this.label,
    this.dropdownTypes,
    this.mappedDropdownTypes,
    this.isEnabled = true,
    this.onSubmit,
    this.controller,
    this.width,
  }) : super(key: key);

  @override
  _StorybridgeDropdownState createState() => _StorybridgeDropdownState();
}

// myPage state
class _StorybridgeDropdownState extends State<StorybridgeDropdown> {
  String selectedIcon = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuEntry> typeEntries = [];
    if (widget.dropdownTypes != null && widget.mappedDropdownTypes == null) {
      for (final String item in widget.dropdownTypes!) {
        typeEntries.add(
          DropdownMenuEntry(value: item, label: item),
        );
      }
    } else if (widget.dropdownTypes == null &&
        widget.mappedDropdownTypes != null) {
      for (String key in widget.mappedDropdownTypes!.keys) {
        typeEntries.add(
          DropdownMenuEntry(
              value: widget.mappedDropdownTypes![key], label: key),
        );
      }
    } else {
      throw Exception(
          "StorybridgeDropdown: either mappedDropdownTypes or dropdownTypes should be null.");
    }

    // ignore: unused_local_variable
    return DropdownMenu<dynamic>(
      width: widget.width,
      enableFilter: false,
      requestFocusOnTap: false,
      enabled: widget.isEnabled,
      textStyle: StorybridgeTextPStyle,
      label: Text(translation_service.translate(widget.label)),
      controller: widget.controller,
      dropdownMenuEntries: typeEntries,
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: StorybridgeTextPDimStyle,
        filled: true,
        fillColor: Storybridge_color.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15.0),
        focusedBorder: OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide: BorderSide(
              color: Storybridge_color.StorybridgeAccent, width: 2.0),
        ),
        disabledBorder: OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide:
              BorderSide(color: Storybridge_color.borderColor, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderSide:
              BorderSide(color: Storybridge_color.borderColor, width: 1.0),
        ),
      ),
      onSelected: widget.onSubmit,
    );
  }
}

class StorybridgeCheckbox extends StatefulWidget {
  // members of MyWidget
  final String label;
  final bool value;
  final Function(bool value) onChanged;

  // constructor
  const StorybridgeCheckbox(
      {Key? key,
      required this.label,
      required this.value,
      required this.onChanged})
      : super(key: key);

  @override
  State<StorybridgeCheckbox> createState() => _StorybridgeCheckboxState();
}

class _StorybridgeCheckboxState extends State<StorybridgeCheckbox> {
  void _switch() {
    bool val = !widget.value;
    widget.onChanged(val);
    return;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          activeColor: Storybridge_color.black,
          checkColor: Storybridge_color.background,
          value: widget.value,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2.0),
          ),
          side: MaterialStateBorderSide.resolveWith(
            (states) => BorderSide(color: Storybridge_color.black, width: 2),
          ),
          onChanged: (bool? val) {
            _switch();
          },
        ),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: InkWell(
              hoverColor: Colors.transparent,
              onTap: () {
                _switch();
              },
              child: StorybridgeTextP(widget.label)),
        ),
      ],
    );
  }
}

class StorybridgeDatePicker extends StatefulWidget {
  final String label;
  final Function(DateTime)? onChanged;
  final bool isEnabled;
  StorybridgeDatePicker(
      {super.key,
      required this.label,
      required this.date,
      this.isEnabled = true,
      this.onChanged});
  final DateTime date;

  @override
  State<StorybridgeDatePicker> createState() => _StorybridgeDatePickerState();
}

/// RestorationProperty objects can be used because of RestorationMixin.
class _StorybridgeDatePickerState extends State<StorybridgeDatePicker> {
  // In this example, the restoration ID for the mixin is passed in through
  // the [StatefulWidget]'s constructor.

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: widget.date,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2100));
    if (picked != null && picked != widget.date) {
      setState(() {
        if (widget.onChanged != null) {
          widget.onChanged!(picked);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.label.isNotEmpty ? StorybridgeTextP(widget.label) : Container(),
        SizedBox(
          width: 200,
          child: StorybridgeTile(
            child: InkWell(
              hoverColor: Colors.transparent,
              onTap: widget.isEnabled
                  ? () {
                      _showDatePicker();
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    StorybridgeTextP(
                      "${MONTH_HASH[widget.date.month - 1]} ${widget.date.day}, ${widget.date.year}",
                    ),
                    Expanded(child: Container()),
                    StorybridgeIconButton(
                      icon: Icons.calendar_month_rounded,
                      onPressed: widget.isEnabled
                          ? () {
                              _showDatePicker();
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class StorybridgeTimePicker extends StatefulWidget {
  final String label;
  final Function(TimeOfDay)? onChanged;
  StorybridgeTimePicker(
      {Key? key, required this.label, required this.tod, this.onChanged})
      : super(key: key);
  final TimeOfDay tod;

  @override
  _StorybridgeTimePickerState createState() => _StorybridgeTimePickerState();
}

// myPage state
class _StorybridgeTimePickerState extends State<StorybridgeTimePicker> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: widget.tod,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (widget.onChanged != null) {
          widget.onChanged!(picked);
        }
      });
    }
  }

  String formatTime(TimeOfDay tod) {
    String hh = tod.hour.toString();
    if (hh.length == 1) {
      hh = "0$hh";
    }
    String mm = tod.minute.toString();
    if (mm.length == 1) {
      mm = "0$mm";
    }

    return "$hh:$mm";
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.label.isNotEmpty ? StorybridgeTextP(widget.label) : Container(),
        SizedBox(
          width: 120,
          height: 48,
          child: StorybridgeTile(
            child: InkWell(
              hoverColor: Colors.transparent,
              onTap: () {
                _showTimePicker();
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    StorybridgeTextP(formatTime(widget.tod)),
                    Expanded(child: Container()),
                    StorybridgeIconButton(
                      icon: Icons.schedule_rounded,
                      onPressed: () {
                        _showTimePicker();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class StorybridgeAlertDialog extends StatelessWidget {
  // members of MyWidget
  final Widget content;
  final Widget? title;
  final List<Widget>? actions;

  // constructor
  const StorybridgeAlertDialog(
      {Key? key, required this.content, this.title, this.actions})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: Storybridge_color.background,
        contentPadding: EdgeInsets.zero,
        content: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Storybridge_color.borderColor)),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title ?? Container(),
                  content,
                ],
              ),
            )),
        actions: actions);
  }
}
