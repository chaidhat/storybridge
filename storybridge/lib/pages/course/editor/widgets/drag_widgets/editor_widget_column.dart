import 'package:flutter/material.dart';
import 'package:mooc/pages/course/editor/widgets/editor_widget_accessories.dart';
import 'package:mooc/pages/course/editor/widgets/editor_widget_wrapper.dart';
import 'package:mooc/pages/course/editor/widgets/editor_widgets.dart';

// myPage class which creates a state on call
const widgetTypeColumn = "column";

// ignore: must_be_immutable
class EditorWidgetColumn extends StatefulWidget implements EditorWidget {
  @override
  final EditorWidgetData editorWidgetData;
  final List<EditorWidgetWrapper> children = [];
  @override
  final bool reduceDropzoneSize = false;
  final bool reduceTailerSize; // used ONLY for column

  @override
  late EditorWidgetMetadata metadata;

  EditorWidgetColumn(
      {Key? key, required this.editorWidgetData, this.reduceTailerSize = false})
      : super(key: key);

  void Function(Map<String, dynamic>, bool, int)? onAppendVertically;
  void Function(int)? onRemoveVertically;

  void _onAppendVerticallyCallback(Map<String, dynamic> a, bool b, int c) {
    onAppendVertically!(a, b, c);
    editorWidgetData.onUpdate();
  }

  void _onRemoveVerticallyCallback(int a) {
    onRemoveVertically!(a);
    editorWidgetData.onUpdate();
  }

  // serialization
  @override
  void loadFromJson(Map<String, dynamic> json) {
    metadata = getMetadata(json, editorWidgetData);
    ;
    children.clear();
    for (int i = 0; i < json["children"].length; i++) {
      // copy the editorWidgetData
      EditorWidgetData newEditorWidgetData = editorWidgetData.clone();
      newEditorWidgetData.z = editorWidgetData.z + 1;

      EditorWidgetWrapper newEditorWidget = EditorWidgetWrapper(
        isAdminMode: editorWidgetData.isAdminMode,
        onAppendVertically: _onAppendVerticallyCallback,
        onRemoveVertically: _onRemoveVerticallyCallback,
        child:
            getEditorWidgetFromJson(json["children"][i], newEditorWidgetData),
      );
      newEditorWidget.index = i;
      children.add(newEditorWidget);
    }
  }

  @override
  Map<String, dynamic> saveToJson() {
    Map<String, dynamic> json = {};
    json["widgetType"] = widgetTypeColumn;
    json["children"] = [];
    json["metadata"] = metadata.encode();
    for (int i = 0; i < children.length; i++) {
      json["children"].add(children[i].child.saveToJson());
    }
    return json;
  }

  @override
  void onCreate() {}

  @override
  void onRemove() {}

  @override
  Widget? getToolbar() {
    return null;
  }

  @override
  _EditorWidgetColumnState createState() => _EditorWidgetColumnState();
}

@override
void onCreate() {}

@override
void onRemove() {}

// myPage state
class _EditorWidgetColumnState extends State<EditorWidgetColumn> {
  @override
  void initState() {
    super.initState();
    widget.onAppendVertically = _onAppendVertically;
    widget.onRemoveVertically = _onRemoveVertically;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onAppendVertically(
      Map<String, dynamic> newWidgetJson, bool isTop, int index) {
    if (!isTop) index++;
    if (index > widget.children.length) index--; // move back if at the end
    // copy the editorWidgetData
    EditorWidgetData newEditorWidgetData = widget.editorWidgetData.clone();
    newEditorWidgetData.z = widget.editorWidgetData.z + 1;

    // tell the editor widget it is getting created
    EditorWidget editorWidget =
        getEditorWidgetFromJson(newWidgetJson, newEditorWidgetData);
    editorWidget.onCreate();

    EditorWidgetWrapper newEditorWidget = EditorWidgetWrapper(
      isAdminMode: widget.editorWidgetData.isAdminMode,
      onAppendVertically: _onAppendVertically,
      onRemoveVertically: _onRemoveVertically,
      index: index,
      child: editorWidget,
    );
    widget.children.insert(index, newEditorWidget);

    // move the other indexes back
    for (int i = index + 1; i < widget.children.length; i++) {
      widget.children[i].index = widget.children[i].index! + 1;
    }
    widget.editorWidgetData.onUpdate();
    setState(() {});
  }

  void _onRemoveVertically(int index) {
    // tell the editor widget that it is getting removed
    EditorWidget editorWidget = widget.children[index].child;
    editorWidget.onRemove();

    widget.children.removeAt(index);
    // move the other indexes back
    for (int i = index; i < widget.children.length; i++) {
      widget.children[i].index = widget.children[i].index! - 1;
    }
    widget.editorWidgetData.onUpdate();
    setState(() {});
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(children: widget.children),
        EditorWidgetTailer(
          index: widget.children.length - 1,
          reduceSize: widget.reduceTailerSize,
          isHidden: !widget.editorWidgetData.isAdminMode,
          onAppendVertically: _onAppendVertically,
        )
      ],
    );
  }
}
