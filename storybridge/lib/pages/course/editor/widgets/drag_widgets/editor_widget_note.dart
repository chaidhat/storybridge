import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mooc/storybridge.dart'; // Storybridge

import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:mooc/style/storybridge_colors.dart' as storybridge_color;

const widgetTypeNote = "note";

// ignore: must_be_immutable
class EditorWidgetNote extends StatefulWidget implements EditorWidget {
  // constructor
  EditorWidgetNote({Key? key, required this.editorWidgetData})
      : super(key: key);
  @override
  final bool reduceDropzoneSize = false;

  @override
  late final EditorWidgetMetadata metadata;
  @override
  final EditorWidgetData editorWidgetData;

  @override
  State<EditorWidgetNote> createState() => _EditorWidgetNoteState();

  final FocusNode focusNode = FocusNode();
  late quill.QuillController controller = quill.QuillController.basic();
  final BackgroundColorController backgroundColorController =
      BackgroundColorController();

  // serialization
  @override
  void loadFromJson(Map<String, dynamic> json) {
    metadata = getMetadata(json, editorWidgetData);
    List<dynamic> myJSON;
    String text = json["text"];
    try {
      myJSON = jsonDecode(text);
      controller = quill.QuillController(
          document: quill.Document.fromJson(myJSON),
          selection: const TextSelection.collapsed(offset: 0));
    } catch (_) {
      String myJSONStr = '[{"insert": ${jsonEncode("$text\n")}}]';
      myJSON = jsonDecode(myJSONStr);
      controller = quill.QuillController(
          document: quill.Document.fromJson(myJSON),
          selection: const TextSelection.collapsed(offset: 0));
    }
    try {
      backgroundColorController.backgroundColor.text = json["backgroundColor"];
    } catch (_) {}
  }

  @override
  Map<String, dynamic> saveToJson() {
    String text = jsonEncode(controller.document.toDelta().toJson());
    return {
      "metadata": metadata.encode(),
      "widgetType": widgetTypeNote,
      "text": text,
      "backgroundColor": backgroundColorController.backgroundColor.text
    };
  }

  @override
  void onCreate() {}

  @override
  void onRemove() {}

  @override
  Widget? getToolbar() {
    return _Toolbar(
      controller: controller,
      backgroundColorController: backgroundColorController,
      getFocus: () {
        focusNode.requestFocus();
      },
    );
  }
}

class _EditorWidgetNoteState extends State<EditorWidgetNote> {
  @override
  void initState() {
    super.initState();
    _formatDarkMode();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _updateQuestion() {
    widget.editorWidgetData.onUpdate();
    _formatDarkMode();

    setState(() {});
  }

  void _formatDarkMode() {
    if (storybridge_color.isWhite(
        widget.backgroundColorController.backgroundColor.text.toColor()!)) {
      if (storybridge_color.getIsDarkMode()) {
        widget.controller.formatText(0, widget.controller.document.length,
            quill.Attribute.fromKeyValue('color', 'white'));
      } else {
        widget.controller.formatText(0, widget.controller.document.length,
            quill.Attribute.fromKeyValue('color', 'black'));
      }
    } else {
      widget.controller.formatText(
          0,
          widget.controller.document.length,
          quill.Attribute.fromKeyValue('color',
              "#${storybridge_color.getTextColor(widget.backgroundColorController.backgroundColor.text.toColor()!).toHexString()}"));
    }
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    widget.backgroundColorController.onUpdate = _updateQuestion;
    return StorybridgeTile(
        color: widget.backgroundColorController.backgroundColor.text.toColor()!,
        child: StorybridgePadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.tips_and_updates_outlined,
                  color: storybridge_color.getTextColor(widget
                      .backgroundColorController.backgroundColor.text
                      .toColor()!)),
              const SizedBox(height: 10),
              Focus(
                focusNode: widget.focusNode,
                child: StorybridgeEditableText(
                  enabled: widget.editorWidgetData.isAdminMode,
                  richController: widget.controller,
                  onSubmit: () {
                    widget.editorWidgetData.onUpdate();
                  },
                  style: storybridgeTextPRedStyle,
                ),
              ),
            ],
          ),
        ));
  }
}

// myPage class which creates a state on call
class _Toolbar extends StatefulWidget {
  final quill.QuillController controller;
  final Function() getFocus;
  final BackgroundColorController backgroundColorController;
  const _Toolbar(
      {Key? key,
      required this.controller,
      required this.backgroundColorController,
      required this.getFocus})
      : super(key: key);

  @override
  _ToolbarState createState() => _ToolbarState();
}

// myPage state
class _ToolbarState extends State<_Toolbar> {
  bool showMoreOptions = false;
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
    bool isBold = false;
    for (quill.Style style in widget.controller.getAllSelectionStyles()) {
      isBold = isBold || (style.attributes["bold"]?.value ?? false);
    }
    bool isItalic = false;
    for (quill.Style style in widget.controller.getAllSelectionStyles()) {
      isItalic = isItalic || (style.attributes["italic"]?.value ?? false);
    }
    bool isUnderline = false;
    for (quill.Style style in widget.controller.getAllSelectionStyles()) {
      isUnderline =
          isUnderline || (style.attributes["underline"]?.value ?? false);
    }
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          StorybridgeIconButton(
              icon: Icons.format_bold_rounded,
              useAltStyle: isBold,
              onPressed: () {
                widget.controller.formatSelection(isBold
                    ? quill.Attribute.clone(quill.Attribute.bold, null)
                    : quill.Attribute.bold);
                setState(() {
                  isBold = !isBold;
                });
              }),
          const SizedBox(width: 4),
          StorybridgeIconButton(
              icon: Icons.format_italic_rounded,
              useAltStyle: isItalic,
              onPressed: () {
                widget.controller.formatSelection(isItalic
                    ? quill.Attribute.clone(quill.Attribute.italic, null)
                    : quill.Attribute.italic);
                setState(() {
                  isItalic = !isItalic;
                });
              }),
          const SizedBox(width: 4),
          StorybridgeIconButton(
              icon: Icons.format_underline_rounded,
              useAltStyle: isUnderline,
              onPressed: () {
                widget.controller.formatSelection(isUnderline
                    ? quill.Attribute.clone(quill.Attribute.underline, null)
                    : quill.Attribute.underline);
                setState(() {
                  isUnderline = !isUnderline;
                });
              }),
          const SizedBox(width: 20),
          StorybridgeColorPickerIcon(
            controller: widget.backgroundColorController.backgroundColor,
          ),
          /*
          const SizedBox(width: 4),
          !showMoreOptions
              ? StorybridgeIconButton(
                  icon: Icons.more_horiz,
                  onPressed: () {
                    setState(() {
                      widget.getFocus();
                      showMoreOptions = !showMoreOptions;
                    });
                  })
              : Row(children: [
                  const SizedBox(width: 26),
                  StorybridgeIconButton(
                      icon: Icons.text_decrease_rounded,
                      onPressed: () {
                        widget.controller.formatSelection(isUnderline!
                            ? quill.Attribute.clone(
                                quill.Attribute.underline, null)
                            : quill.Attribute.underline);
                        setState(() {
                          isUnderline = !isUnderline;
                        });
                      }),
                  const SizedBox(width: 4),
                  StorybridgeIconButton(
                      icon: Icons.text_increase_rounded,
                      onPressed: () {
                        widget.controller.formatSelection(isUnderline!
                            ? quill.Attribute.clone(
                                quill.Attribute.underline, null)
                            : quill.Attribute.underline);
                        setState(() {
                          isUnderline = !isUnderline;
                        });
                      }),
                ]),
        */
        ]);
  }
}

class BackgroundColorController {
  StorybridgeTextFieldController backgroundColor =
      StorybridgeTextFieldController();
  Function onUpdate = () {};
  BackgroundColorController() {
    backgroundColor.text = "FFFFFF";
    backgroundColor.addListener(() {
      onUpdate();
    });
  }
}
