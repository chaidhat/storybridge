import 'package:flutter/material.dart';
import 'package:mooc/storybridge.dart'; // Storybridge

const widgetTypeHeader = "header";

class EditorWidgetHeader extends StatelessWidget implements EditorWidget {
  // constructor
  EditorWidgetHeader({Key? key, required this.editorWidgetData})
      : super(key: key);
  @override
  final bool reduceDropzoneSize = false;

  @override
  final EditorWidgetData editorWidgetData;

  @override
  late final EditorWidgetMetadata metadata;

  final StorybridgeTextFieldController _controller =
      StorybridgeTextFieldController();

  // serialization
  @override
  void loadFromJson(Map<String, dynamic> json) {
    metadata = getMetadata(json, editorWidgetData);
    ;
    _controller.text = json["text"];
  }

  @override
  Map<String, dynamic> saveToJson() {
    return {
      "metadata": metadata.encode(),
      "widgetType": widgetTypeHeader,
      "text": _controller.text,
    };
  }

  @override
  void onCreate() {}

  @override
  void onRemove() {}

  @override
  Widget? getToolbar() {
    return null;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgeEditableText(
      enabled: editorWidgetData.isAdminMode,
      controller: _controller,
      onSubmit: () {
        editorWidgetData.onUpdate();
      },
      style: storybridgeTextH4Style,
    );
  }
}
