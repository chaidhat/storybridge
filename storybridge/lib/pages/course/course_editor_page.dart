import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mooc/pages/course/editor/course_editor_viewer_page.dart';

import 'package:mooc/services/course_navigation_service.dart'
    as course_navigation_service;

import 'package:mooc/style/storybridge_appbar.dart';

import 'package:mooc/pages/course/editor/course_editor_sidebar_page.dart';
import 'package:mooc/pages/course/editor/course_editor_drag_page.dart';

// myPage class which creates a state on call
class CourseEditorPage extends StatefulWidget {
  final int courseId;
  final int organizationId;
  final bool isAdminMode;
  const CourseEditorPage(
      {required this.courseId,
      required this.organizationId,
      required this.isAdminMode,
      Key? key})
      : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<CourseEditorPage>
    implements course_navigation_service.CourseNavigationFrontPageElement {
  bool _isFrontPage = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void onUpdateFrontPage(bool isFrontPage) {
    try {
      setState(() {
        _isFrontPage = isFrontPage;
      });
    } catch (_) {}
  }

  @override
  void initState() {
    course_navigation_service.setCourseId(
        widget.courseId, widget.organizationId, widget.isAdminMode);
    course_navigation_service.registerFrontPageElement(this);
    super.initState();
  }

  @override
  void dispose() {
    course_navigation_service.deregisterFrontPageElement(this);
    super.dispose();
  }

  final StorybridgeTabPageController _tabPageController =
      StorybridgeTabPageController();
  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgeTabPage(
        scrollController: _scrollController,
        tabPageController: _tabPageController,
        hasReducedPadding: true,
        sideBar: !_isFrontPage || widget.isAdminMode
            ? [
                EditorHierarchy(
                  tabPageController: _tabPageController,
                  isAdminMode: widget.isAdminMode,
                )
              ]
            : null,
        hasRightSideBarPadding: false,
        rightSideBar: widget.isAdminMode
            ? [
                EditorDragSidebar(
                  isOnFrontPage: _isFrontPage,
                )
              ]
            : null,
        body: [
          _CourseViewer(
            scrollController: _scrollController,
            isAdminMode: widget.isAdminMode,
            courseId: widget.courseId,
          ),
        ]);
  }
}

// myPage class which creates a state on call
class _CourseViewer extends StatefulWidget {
  final int courseId;
  final bool isAdminMode;
  final ScrollController scrollController;
  const _CourseViewer(
      {Key? key,
      required this.courseId,
      required this.isAdminMode,
      required this.scrollController})
      : super(key: key);

  @override
  _CourseViewerState createState() => _CourseViewerState();
}

// myPage state
class _CourseViewerState extends State<_CourseViewer>
    implements course_navigation_service.CourseNavigationElement {
  course_navigation_service.CourseData? _courseData;
  bool _isDisposed = false;

  @override
  void onNewData(course_navigation_service.CourseData? courseData) {
    if (!_isDisposed) {
      try {
        setState(() {
          _courseData = courseData;
        });
      } catch (_) {}
    }
  }

  @override
  void onLoad() {}

  @override
  void initState() {
    course_navigation_service.registerViewer(this);
    super.initState();
  }

  @override
  void dispose() {
    course_navigation_service.deregisterViewer();
    _isDisposed = true;
    super.dispose();
  }

  // the code needs to reset a widget before returning it.
  // To do this, we must first load a Container() in between widget loadings.
  // Otherwise, if the loading returns the same widget, it will not init state again.
  Future<void> _load() async {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  bool _isLoaded = false;
  // main build function
  @override
  Widget build(BuildContext context) {
    _isLoaded = !_isLoaded;
    if (_isLoaded) {
      // ignore: unused_local_variable
      if (_courseData != null) {
        return CourseEditorViewerPage(
          scrollController: widget.scrollController,
          isAdminMode: widget.isAdminMode,
          courseData: _courseData!,
        );
      } else {
        return const Padding(
          padding: EdgeInsets.only(top: 80.0),
          child: StorybridgePageLoading(),
        );
      }
    } else {
      _load();
      return Container();
    }
  }
}
