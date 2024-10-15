import 'package:flutter/material.dart';
import 'package:mooc/pages/course/editor/widgets/editor_widgets.dart';

const widgetTypeSpacer = "spacer";

class EditorWidgetSpacer extends StatelessWidget implements EditorWidget {
  // constructor
  EditorWidgetSpacer({Key? key, required this.editorWidgetData})
      : super(key: key);
  @override
  final bool reduceDropzoneSize = false;

  @override
  final EditorWidgetData editorWidgetData;

  @override
  late final EditorWidgetMetadata metadata;

  // serialization
  @override
  void loadFromJson(Map<String, dynamic> json) {
    metadata = getMetadata(json, editorWidgetData);
    ;
  }

  @override
  void onCreate() {}

  @override
  void onRemove() {}

  @override
  Map<String, dynamic> saveToJson() {
    return {
      "metadata": metadata.encode(),
      "widgetType": widgetTypeSpacer,
    };
  }

  @override
  Widget? getToolbar() {
    return null;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Container(height: 50);
  }
}
