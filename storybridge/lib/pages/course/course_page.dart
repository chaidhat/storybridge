import 'package:flutter/material.dart';
import 'package:mooc/Storybridge.dart'; // Storybridge

import 'package:mooc/pages/course/course_editor_page.dart';
import 'package:mooc/pages/course/course_design_page.dart';
import 'package:mooc/pages/course/course_grades_page.dart';
import 'package:mooc/pages/course/sales_page.dart';
import 'package:mooc/pages/course/widgets/share_widget.dart';

import 'package:mooc/services/course_navigation_service.dart'
    as course_navigation_service;
import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/error_service.dart' as error_service;
import 'package:mooc/services/auth_service.dart' as auth_service;

// myPage class which creates a state on call
class CoursePage extends StatefulWidget {
  final int courseId;
  final int organizationId;
  final bool isAdminMode;
  const CoursePage(
      {Key? key,
      required this.courseId,
      required this.organizationId,
      required this.isAdminMode})
      : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<CoursePage> {
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
    if (widget.isAdminMode) {
      return _CoursePageAdmin(
        courseId: widget.courseId,
        organizationId: widget.organizationId,
      );
    } else {
      return _CoursePageStudent(
        courseId: widget.courseId,
        organizationId: widget.organizationId,
      );
    }
    // ignore: unused_local_variable
  }
}

class _CoursePageAdmin extends StatefulWidget {
  // members of MyWidget
  final int courseId;
  final int organizationId;

  // constructor
  const _CoursePageAdmin(
      {Key? key, required this.courseId, required this.organizationId})
      : super(key: key);

  @override
  State<_CoursePageAdmin> createState() => _CoursePageAdminState();
}

class _CoursePageAdminState extends State<_CoursePageAdmin> {
  // main build function
  @override
  Widget build(BuildContext context) {
    error_service.checkAlerts(context);
    return StorybridgeScaffold(
      forceDesktop: true,
      isTabRightAligned: true,
      hasAppbar: false,
      body: const [],
      tabPrefix: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: _CourseName(
          courseId: widget.courseId,
          isAdminMode: true,
        ),
      ),
      tabSuffix: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const StorybridgeSavingIndicator(),
            const SizedBox(width: 20),
            CourseShareWidget(
              courseId: widget.courseId,
            ),
          ],
        ),
      ),
      tabNames: [
        StorybridgeTabHeader(
            tabName: "Editor", tabIcon: Icons.construction_rounded),
        /*
        StorybridgeTabHeaders(
            tabName: "Analytics", tabIcon: Icons.school_rounded),
            */
        StorybridgeTabHeader(
            tabName: "Analytics", tabIcon: Icons.show_chart_rounded),
        StorybridgeTabHeader(tabName: "Sales", tabIcon: Icons.payment_rounded),
        StorybridgeTabHeader(
            tabName: "Settings", tabIcon: Icons.settings_rounded),
        /*
        StorybridgeTabHeaders(
            tabName: "Discussion", tabIcon: Icons.show_chart_rounded),
            */
      ],
      tabs: [
        CourseEditorPage(
          courseId: widget.courseId,
          organizationId: widget.organizationId,
          isAdminMode: true,
        ),
        CourseGradesForAdminsPage(
          courseId: widget.courseId,
        ),
        CourseSalesPage(courseId: widget.courseId),
        CourseDesignPage(courseId: widget.courseId),
      ],
    );
  }
}

class _CoursePageStudent extends StatelessWidget {
  // members of MyWidget
  final int courseId;
  final int organizationId;

  // constructor
  const _CoursePageStudent({
    Key? key,
    required this.courseId,
    required this.organizationId,
  }) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgeScaffold(
      hasAppbar: false,
      body: const [],
      tabPrefix: IntrinsicWidth(
        child: InkWell(
          hoverColor: Colors.transparent,
          onTap: () {
            course_navigation_service.goToFrontPage();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _CourseName(
              courseId: courseId,
              isAdminMode: false,
            ),
          ),
        ),
      ),
      tabSuffix: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          StorybridgeAccountIndicator(organizationId: organizationId),
        ],
      ),
      isTabRightAligned: true,
      tabNames: [
        StorybridgeTabHeader(
            tabName: "Course", tabIcon: Icons.collections_bookmark_rounded),
        StorybridgeTabHeader(tabName: "Grades", tabIcon: Icons.school_rounded),
        /*
        StorybridgeTabHeaders(
            tabName: "Discussion", tabIcon: Icons.school_rounded),
        StorybridgeTabHeaders(tabName: "Notes", tabIcon: Icons.article_rounded),
        */
      ],
      tabs: [
        CourseEditorPage(
          courseId: courseId,
          organizationId: organizationId,
          isAdminMode: false,
        ),
        auth_service.globalUser.token == null
            ? CourseGradesForFrontPage(courseId: courseId)
            : CourseGradesForStudentsPage(
                courseId: courseId,
              ),
      ],
    );
  }
}

class _CourseName extends StatefulWidget {
  final int courseId;
  final bool isAdminMode;
  const _CourseName({
    Key? key,
    required this.courseId,
    required this.isAdminMode,
  }) : super(key: key);

  @override
  _CourseNameState createState() => _CourseNameState();
}

class _CourseNameState extends State<_CourseName> {
  String _courseName = "";
  String _organizationName = "";
  int _organizationId = 0;
  ProfilePictureController profilePictureController =
      ProfilePictureController();

  Future<bool> loadCourseName() async {
    Map<String, dynamic> course =
        await networking_api_service.getCourse(courseId: widget.courseId);
    _organizationId = course["data"]["organizationId"];
    Map<String, dynamic> organization = await networking_api_service
        .getOrganization(organizationId: _organizationId);
    _courseName = Uri.decodeComponent(course["data"]["courseName"]);
    _organizationName =
        Uri.decodeComponent(organization["data"]["organizationName"]);

    return true;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return FutureBuilder(
        future: loadCourseName(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            double courseNameTextFontSize;

            // custom styling
            if (_courseName.length > 35) {
              courseNameTextFontSize = StorybridgeTextH2BStyle.fontSize! - 2;
            } else if (_courseName.length < 20) {
              courseNameTextFontSize = StorybridgeTextH2BStyle.fontSize! + 4;
            } else {
              courseNameTextFontSize = StorybridgeTextH2BStyle.fontSize!;
            }
            TextStyle courseNameStyle = TextStyle(
                color: StorybridgeTextH2BStyle.color,
                fontWeight: StorybridgeTextH2BStyle.fontWeight,
                fontSize: courseNameTextFontSize);

            return IntrinsicWidth(
              child: Row(
                children: [
                  InkWell(
                    hoverColor: Colors.transparent,
                    onTap: () {
                      Navigator.pushNamed(
                          context, "/organization?id=$_organizationId");
                    },
                    child: Row(
                      children: [
                        SizedBox(
                            height: 50,
                            child: ProfilePictureWidget(
                                controller: profilePictureController,
                                organizationId: _organizationId,
                                child: Builder(builder: (context) {
                                  if (!profilePictureController.hasPicture) {
                                    return IntrinsicWidth(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          StorybridgeTextBasic(
                                              _organizationName,
                                              style: StorybridgeTextH5Style),
                                          StorybridgeTextBasic(_courseName,
                                              style: courseNameStyle),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return StorybridgeTextBasic(_courseName,
                                        style: courseNameStyle);
                                  }
                                }))),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const StorybridgeBoxLoading(height: 25, width: 200);
          }
        });
  }
}
