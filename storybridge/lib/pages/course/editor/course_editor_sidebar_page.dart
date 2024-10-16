import 'package:flutter/material.dart';
import 'package:mooc/storybridge.dart'; // Storybridge

import 'package:mooc/services/course_navigation_service.dart'
    as course_navigation_service;
import 'package:mooc/services/error_service.dart' as error_service;
import 'package:mooc/style/storybridge_colors.dart' as storybridge_color;

class EditorHierarchy extends StatefulWidget {
  final bool isAdminMode;
  final StorybridgeTabPageController tabPageController;
  const EditorHierarchy({
    Key? key,
    required this.isAdminMode,
    required this.tabPageController,
  }) : super(key: key);

  @override
  _EditorHierarchyState createState() => _EditorHierarchyState();
}

class _EditorHierarchyState extends State<EditorHierarchy>
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
    course_navigation_service.registerHierarchy(this);
    super.initState();
  }

  @override
  void dispose() {
    course_navigation_service.deregisterHierarchy();
    _isDisposed = true;
    super.dispose();
  }

  void _editElementButton(
      EditElementTypes item, int courseSectionId, int courseElementId) {
    switch (item) {
      case EditElementTypes.rename:
        setState(() {
          int i = 0, j = 0;
          while (_courseData!.courseHierarchy[i].courseSectionId !=
              courseSectionId) {
            i++;
          }
          while (_courseData!
                  .courseHierarchy[i].courseElements[j].courseElementId !=
              courseElementId) {
            j++;
          }
          String courseElementName = Uri.decodeComponent(_courseData!
              .courseHierarchy[i].courseElements[j].courseElementName);

          error_service.alert(error_service.Alert(
              title: 'Rename "$courseElementName"',
              description: "Please enter a new name",
              buttonName: "OK",
              prefillInputText: courseElementName,
              acceptInput: true,
              callback: (String input) async {
                await course_navigation_service.renameCourseElement(
                    courseElementId: courseElementId, newName: input);
                course_navigation_service.reloadAll();
              }));
        });
        break;
      case EditElementTypes.move:
        setState(() {});
        break;
      case EditElementTypes.delete:
        setState(() {
          int i = 0, j = 0;
          while (_courseData!.courseHierarchy[i].courseSectionId !=
              courseSectionId) {
            i++;
          }
          while (_courseData!
                  .courseHierarchy[i].courseElements[j].courseElementId !=
              courseElementId) {
            j++;
          }
          String courseElementName = Uri.decodeComponent(_courseData!
              .courseHierarchy[i].courseElements[j].courseElementName);

          error_service.alert(error_service.Alert(
              title: 'Delete "$courseElementName"?',
              description:
                  "Are you sure you wish to permanently delete $courseElementName?\nAll data will be lost forever.",
              buttonName: "DELETE",
              acceptInput: false,
              callback: (String input) async {
                course_navigation_service.removeCourseElement(
                    courseElementId: courseElementId);
              }));
        });
        break;
    }
  }

  void _editSectionButton(_EditSectionTypes item, int courseSectionId) {
    switch (item) {
      case _EditSectionTypes.rename:
        setState(() {
          int i = 0;
          while (_courseData!.courseHierarchy[i].courseSectionId !=
              courseSectionId) {
            i++;
          }
          String courseSectionName = Uri.decodeComponent(
              _courseData!.courseHierarchy[i].courseSectionName);

          error_service.alert(error_service.Alert(
              title: 'Rename "$courseSectionName"',
              description: "Please enter a new name",
              buttonName: "OK",
              prefillInputText: courseSectionName,
              acceptInput: true,
              callback: (String input) async {
                course_navigation_service.renameCourseSection(
                    courseSectionId: courseSectionId, newName: input);
              }));
        });
        break;
      case _EditSectionTypes.move:
        setState(() {});
        break;
      case _EditSectionTypes.delete:
        setState(() {
          int i = 0;
          while (_courseData!.courseHierarchy[i].courseSectionId !=
              courseSectionId) {
            i++;
          }
          String courseSectionName = Uri.decodeComponent(
              _courseData!.courseHierarchy[i].courseSectionName);

          error_service.alert(error_service.Alert(
              title: 'Delete "$courseSectionName"?',
              description:
                  "Are you sure you wish to permanently delete $courseSectionName?\nAll data will be lost forever.",
              buttonName: "DELETE",
              acceptInput: false,
              callback: (String input) async {
                course_navigation_service.removeCourseSection(
                    courseSectionId: courseSectionId);
              }));
        });
        break;
    }
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    error_service.checkAlerts(context);

    // ignore: unused_local_variable
    if (_courseData == null) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 80),
          StorybridgeBoxLoading(height: 40, width: 280),
          StorybridgeBoxLoading(height: 40, width: 280),
          StorybridgeBoxLoading(height: 40, width: 280),
          StorybridgeBoxLoading(height: 40, width: 280),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 80),
        Column(
          children: List.generate(_courseData!.courseHierarchy.length, (int i) {
            /*
                  * SIDEBAR TOP
                  */

            if (i == 0) {
              return widget.isAdminMode
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: StorybridgeSideBarButton(
                          icon: Icons.home_rounded,
                          label: "Front Page",
                          isSpecial: true,
                          selected: _courseData!.selectedCourseSectionNo == 0,
                          onPressed: () {
                            // hide mobile sidebar
                            widget.tabPageController.mobileShowSidebar = false;
                            widget.tabPageController.update();

                            course_navigation_service.goToPage(_courseData!
                                .courseHierarchy[0]
                                .courseElements[0]
                                .courseElementId);
                            setState(() {});
                          }),
                    )
                  : Container();
            }

            /*
                  * SIDEBAR BOTTOM
                  */
            course_navigation_service.CourseSection courseSection =
                _courseData!.courseHierarchy[i];
            return StorybridgeHoverButton(
              enabled: widget.isAdminMode,
              button: _PopupEditSectionButton(
                onPressed: (_EditSectionTypes item) {
                  _editSectionButton(item, courseSection.courseSectionId);
                },
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.only(left: 10),
                iconColor: storybridge_color.grey,
                initiallyExpanded: i == _courseData!.selectedCourseSectionNo ||
                    (i == 1 &&
                        _courseData!.selectedCourseSectionNo ==
                            0) /* if front page is selected, show first course */,
                title: SizedBox(
                  width: 200,
                  child: StorybridgeTextH5(
                      Uri.decodeComponent(courseSection.courseSectionName),
                      red: false),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                              courseSection.courseElements.length, (int j) {
                            course_navigation_service.CourseElement
                                courseElement = courseSection.courseElements[j];
                            String courseElementName =
                                courseElement.courseElementName;
                            IconData courseElementIcon = Icons.help;
                            switch (courseElement.courseElementType) {
                              case 0:
                                courseElementIcon = Icons.videocam_rounded;
                                break;
                              case 1:
                                courseElementIcon = Icons.article_rounded;
                                break;
                              case 2:
                                courseElementIcon = Icons.school_rounded;
                                break;
                            }

                            // safely decode the element name
                            String decodedCourseElementName = "???";
                            try {
                              decodedCourseElementName =
                                  Uri.decodeComponent(courseElementName);
                            } catch (_) {}

                            return StorybridgeHoverButton(
                              enabled: widget.isAdminMode,
                              button: PopupEditElementButton(
                                onPressed: (EditElementTypes item) {
                                  _editElementButton(
                                      item,
                                      courseSection.courseSectionId,
                                      courseElement.courseElementId);
                                },
                              ),
                              child: StorybridgeSideBarButton(
                                  icon: courseElementIcon,
                                  isDisabled: courseElement.isLocked &&
                                      !widget.isAdminMode,
                                  label: decodedCourseElementName,
                                  selected: i ==
                                          _courseData!
                                              .selectedCourseSectionNo &&
                                      j == _courseData!.selectedCourseElementNo,
                                  onPressed: () {
                                    // hide mobile sidebar
                                    widget.tabPageController.mobileShowSidebar =
                                        false;
                                    widget.tabPageController.update();

                                    course_navigation_service.goToPage(
                                        _courseData!.courseHierarchy[i]
                                            .courseElements[j].courseElementId);
                                    setState(() {});
                                  }),
                            );
                          }),
                        ),
                        widget.isAdminMode
                            ? _PopupAddElementButton(onPressed: () {
                                course_navigation_service.addCourseElement(
                                    courseSectionId:
                                        courseSection.courseSectionId);
                              })
                            : Container(),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        widget.isAdminMode
            ? StorybridgeButton(
                text: "Add Section",
                onPressed: () async {
                  await course_navigation_service.addCourseSection();
                  setState(() {});
                },
              )
            : Container()
      ],
    );
    //} else {
    //return const StorybridgeLoading();
    //}
  }
}

class _PopupAddElementButton extends StatelessWidget {
  // members of MyWidget
  final Function() onPressed;

  // constructor
  const _PopupAddElementButton({Key? key, required this.onPressed})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgeButton(
      text: "Add Page",
      onPressed: () {
        onPressed();
      },
    );
  }
}

// This is the type used by the popup menu below.
enum EditElementTypes { rename, move, delete }

class PopupEditElementButton extends StatelessWidget {
  // members of MyWidget
  final Function(EditElementTypes) onPressed;

  // constructor
  const PopupEditElementButton({Key? key, required this.onPressed})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: PopupMenuButton<EditElementTypes>(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.black26),
          tooltip: "Edit",
          // Callback that sets the selected popup menu item.
          onSelected: onPressed,
          itemBuilder: (BuildContext context) =>
              <PopupMenuEntry<EditElementTypes>>[
                PopupMenuItem<EditElementTypes>(
                  onTap: () {
                    onPressed(EditElementTypes.rename);
                  },
                  child: const StorybridgeTextBasic('Rename'),
                ),
                /*
                const PopupMenuItem<_EditElementTypes>(
                  value: _EditElementTypes.move,
                  child: Text('Move'),
                ),
                */
                PopupMenuItem<EditElementTypes>(
                  value: EditElementTypes.delete,
                  onTap: () {
                    onPressed(EditElementTypes.delete);
                  },
                  child: const StorybridgeTextBasic('Delete'),
                ),
              ]),
    );
  }
}

// This is the type used by the popup menu below.
enum _EditSectionTypes { rename, move, delete }

class _PopupEditSectionButton extends StatelessWidget {
  // members of MyWidget
  final Function(_EditSectionTypes) onPressed;

  // constructor
  const _PopupEditSectionButton({Key? key, required this.onPressed})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_EditSectionTypes>(
        icon: const Icon(Icons.more_vert_rounded, color: Colors.black26),
        tooltip: "Edit",
        // Callback that sets the selected popup menu item.
        itemBuilder: (BuildContext context) =>
            <PopupMenuEntry<_EditSectionTypes>>[
              PopupMenuItem<_EditSectionTypes>(
                onTap: () {
                  onPressed(_EditSectionTypes.rename);
                },
                child: const StorybridgeTextBasic('Rename'),
              ),
              /*
              const PopupMenuItem<_EditSectionTypes>(
                value: _EditSectionTypes.move,
                child: Text('Move'),
              ),
              */
              PopupMenuItem<_EditSectionTypes>(
                onTap: () {
                  onPressed(_EditSectionTypes.delete);
                },
                child: const StorybridgeTextBasic('Delete'),
              ),
            ]);
  }
}
