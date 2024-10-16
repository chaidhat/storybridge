import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_column.dart';

import 'package:mooc/services/course_navigation_service.dart'
    as course_navigation_service;
import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/error_service.dart' as error_service;

class CourseEditorViewerPage extends StatefulWidget {
  final course_navigation_service.CourseData courseData;
  final ScrollController scrollController;
  final bool isAdminMode;

  const CourseEditorViewerPage(
      {Key? key,
      required this.courseData,
      required this.isAdminMode,
      required this.scrollController})
      : super(key: key);
  @override
  _CourseEditorVideoPageState createState() => _CourseEditorVideoPageState();
}

class _CourseEditorVideoPageState extends State<CourseEditorViewerPage> {
  final _courseElementNameController = ScholarityTextFieldController();
  Map<String, dynamic> _data = {};
  // fancy late keyword by https://stackoverflow.com/a/68273324
  late final EditorWidgetColumn _stemEditorWidget = EditorWidgetColumn(
    editorWidgetData: EditorWidgetData(
      onUpdate: _onUpdate,
      courseData: widget.courseData,
      isAdminMode: widget.isAdminMode,
      z: 0,
    ),
  );

  @override
  void initState() {
    super.initState();
    _courseElementNameController.text = Uri.decodeComponent(
        widget.courseData.getSelectedCourseElement().courseElementName);
  }

  @override
  void dispose() {
    super.dispose();
  }

  int _updatesQueued = 0;

  void _onUpdate() async {
    _updatesQueued++;
    if (_updatesQueued > 1) {
      return; // turn away new updates until update is finished
    }

    _data = _stemEditorWidget.saveToJson();
    if (widget.isAdminMode) {
      try {
        await networking_api_service.changeCourseElementData(
            courseElementId:
                widget.courseData.getSelectedCourseElement().courseElementId,
            data: jsonEncode(_data));
      } on error_service.ScholarityException catch (e) {
        if (e.message == "assigner has insufficient permission") {
          setState(() {
            error_service.alert(error_service.Alert(
                title: "You have been logged out.",
                description:
                    "You have logged in on another tab or device. Please do not use more than one device at the same time. Please login again.",
                buttonName: "Log in",
                allowCancel: false,
                callback: (_) {
                  Navigator.of(context).pushNamed("/login?redirect=true");
                }));
          });
        }
      }
    }

    if (_updatesQueued > 1) {
      // this means that there are still updates queued!
      _updatesQueued = 0;
      _onUpdate();
    }
    _updatesQueued = 0;
  }

  void _changeCourseElementName() async {
    course_navigation_service.renameCourseElement(
        courseElementId:
            widget.courseData.getSelectedCourseElement().courseElementId,
        newName: _courseElementNameController.text);
  }

  Future<bool> _loadData() async {
    Map<String, dynamic> response =
        await networking_api_service.getCourseElement(
            courseElementId:
                widget.courseData.getSelectedCourseElement().courseElementId);
    String responseData = Uri.decodeComponent(response["data"][0]["data"]);
    widget.scrollController.jumpTo(0);
    try {
      _data = jsonDecode(responseData);
    } catch (_) {
      setState(() {
        error_service.alert(error_service.Alert(
            title: 'Error parsing course element data',
            description:
                "This bug has automatically been logged. We apologize for this error. Please try closing & reopening this website.",
            buttonName: "Dismiss",
            callback: (_) {}));
      });
    }
    _stemEditorWidget.loadFromJson(_data);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _loadData(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          error_service.checkAlerts(context);
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 80),
                snapshot.hasData
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: ScholarityEditableText(
                              enabled: widget.isAdminMode,
                              style: scholarityTextH2Style,
                              controller: _courseElementNameController,
                              onSubmit: _changeCourseElementName,
                            ),
                          ),
                          /*
                          // TODO: temporaily disabled this
                          widget.courseData.selectedCourseSectionNo !=
                                  0 // hide widgets if front page
                              ? AiWidget(
                                  courseElementId: widget.courseData
                                      .getSelectedCourseElement()
                                      .courseElementId,
                                )
                              : Container(),
                              */
                          _stemEditorWidget,
                        ],
                      )
                    : const ScholarityPageLoading(),
              ],
            ),
          );
        });
  }
}
