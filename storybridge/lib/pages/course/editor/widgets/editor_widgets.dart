import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_answer_buttons.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_answer_checkbox.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_answer_datetime.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_answer_dropdown.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_answer_fileupload.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_answer_text.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_file.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_uploadarea.dart';

import 'package:mooc/services/course_navigation_service.dart'
    as course_navigation_service;

import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_column.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_text.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_header.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_note.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_spacer.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_button.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_assessment.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_image.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_link_button.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_video.dart';

Map<String, EditorWidget Function(EditorWidgetData)> editorWidgetTypeHash = {
  widgetTypeColumn: (EditorWidgetData d) => EditorWidgetColumn(
        editorWidgetData: d,
      ),
  widgetTypeText: (EditorWidgetData d) => EditorWidgetText(
        editorWidgetData: d,
      ),
  widgetTypeHeader: (EditorWidgetData d) =>
      EditorWidgetHeader(editorWidgetData: d),
  widgetTypeNote: (EditorWidgetData d) => EditorWidgetNote(
        editorWidgetData: d,
      ),
  widgetTypeSpacer: (EditorWidgetData d) => EditorWidgetSpacer(
        editorWidgetData: d,
      ),
  widgetTypeVideo: (EditorWidgetData d) => EditorWidgetVideo(
        editorWidgetData: d,
      ),
  widgetTypeButton: (EditorWidgetData d) => EditorWidgetButton(
        editorWidgetData: d,
      ),
  widgetTypeAssessment: (EditorWidgetData d) => EditorWidgetAssessment(
        editorWidgetData: d,
      ),
  widgetTypeLinkButton: (EditorWidgetData d) => EditorWidgetLinkButton(
        editorWidgetData: d,
      ),
  widgetTypeImage: (EditorWidgetData d) => EditorWidgetImage(
        editorWidgetData: d,
      ),
  widgetTypeFile: (EditorWidgetData d) => EditorWidgetFile(
        editorWidgetData: d,
      ),
  widgetTypeUploadarea: (EditorWidgetData d) => EditorWidgetUploadarea(
        editorWidgetData: d,
      ),
  widgetTypeAnswerText: (EditorWidgetData d) => EditorWidgetAnswerText(
        editorWidgetData: d,
      ),
  widgetTypeAnswerDropdown: (EditorWidgetData d) => EditorWidgetAnswerDropdown(
        editorWidgetData: d,
      ),
  widgetTypeAnswerCheckbox: (EditorWidgetData d) => EditorWidgetAnswerCheckbox(
        editorWidgetData: d,
      ),
  widgetTypeAnswerDatetime: (EditorWidgetData d) => EditorWidgetAnswerDatetime(
        editorWidgetData: d,
      ),
  widgetTypeAnswerButtons: (EditorWidgetData d) => EditorWidgetAnswerButtons(
        editorWidgetData: d,
      ),
  widgetTypeAnswerFileupload: (EditorWidgetData d) =>
      EditorWidgetAnswerFileupload(
        editorWidgetData: d,
      ),
};

// these are handled by EditorWidgetWrappers
// it decreases the size of the dropzone so that widgets can be dropped INTO the widget
const List<String> reducedDropzoneEditorWidgetTypes = [widgetTypeAssessment];

EditorWidget getEditorWidgetFromJson(
    Map<String, dynamic> json, EditorWidgetData editorWidgetData) {
  String widgetType = json["widgetType"];
  if (!editorWidgetTypeHash.containsKey(widgetType)) {
    throw Exception("FATAL: UNKNOWN WIDGET TYPE $widgetType");
  }
  EditorWidget blankEditorWidget =
      editorWidgetTypeHash[widgetType]!(editorWidgetData);
  blankEditorWidget.loadFromJson(json);
  return blankEditorWidget;
}

EditorWidgetMetadata getMetadata(
    Map<String, dynamic> json, EditorWidgetData editorWidgetData) {
  // get metadata
  EditorWidgetMetadata metadata = EditorWidgetMetadata(editorWidgetData);
  try {
    if (json["metadata"] != null) {
      metadata.decode(json["metadata"]);
      return metadata;
    } else {
      throw Exception();
    }
  } catch (_) {
    // for backwards compatibility, incase there is no wuid
    return metadata;
  }
}

class EditorWidgetMetadata {
  late String wuid;
  late String showIfs;
  late EditorWidgetData editorWidgetData;
  EditorWidgetMetadata(this.editorWidgetData) {
    wuid = Random().nextInt(9999999).toString();
    showIfs = "";
  }

  void decode(Map<String, dynamic> json) {
    try {
      wuid = json["wuid"];
      showIfs = json["showIfs"];
    } catch (_) {
      throw Exception("Metadata malformed!");
    }
  }

  Map<String, dynamic> encode() {
    return {"wuid": wuid, "showIfs": showIfs};
  }
}

abstract class EditorWidget extends Widget {
  EditorWidget({Key? key, required this.editorWidgetData}) : super(key: key);

  final EditorWidgetData editorWidgetData;
  final bool? reduceDropzoneSize = null;
  late final EditorWidgetMetadata metadata;

  void loadFromJson(Map<String, dynamic> json);
  Map<String, dynamic> saveToJson();
  void onCreate();
  void onRemove();
  Widget? getToolbar();
}

class EditorWidgetData {
  final course_navigation_service.CourseData courseData;
  final void Function() onUpdate;
  final bool isAdminMode;
  int z;

  EditorWidgetData clone() {
    return EditorWidgetData(
      onUpdate: onUpdate,
      courseData: courseData,
      isAdminMode: isAdminMode,
      z: z,
    );
  }

  EditorWidgetData({
    required this.onUpdate,
    required this.courseData,
    required this.isAdminMode,
    required this.z,
  });
}
