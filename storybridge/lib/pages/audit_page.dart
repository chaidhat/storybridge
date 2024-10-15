import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_column.dart';
import 'package:mooc/Storybridge.dart'; // Storybridge

import 'package:flutter/scheduler.dart';

import 'package:mooc/services/course_navigation_service.dart'
    as course_navigation_service;
import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/error_service.dart' as error_service;
import 'package:mooc/services/auditing_service.dart' as auditing_service;
import 'package:signature/signature.dart';

class AuditPage extends StatefulWidget {
  final int auditId;
  final bool isAdminMode;
  final int startingTab;
  const AuditPage(
      {Key? key,
      required this.auditId,
      required this.isAdminMode,
      required this.startingTab})
      : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<AuditPage> {
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
      return _AuditPageAdmin(
        auditTemplateId: widget.auditId,
        startingTab: widget.startingTab,
      );
    } else {
      return _AuditPageStudent(
        auditTaskId: widget.auditId,
        startingTab: widget.startingTab,
      );
    }
    // ignore: unused_local_variable
  }
}

class _AuditPageStudent extends StatelessWidget {
  // members of MyWidget
  final int auditTaskId;
  final int startingTab;

  // constructor
  const _AuditPageStudent({
    Key? key,
    required this.auditTaskId,
    required this.startingTab,
  }) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgeScaffold(
      hasAppbar: false,
      body: const [],
      startingTab: startingTab,
      tabPrefix: IntrinsicWidth(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: _AuditName(
            auditTaskId: auditTaskId,
            isAdminMode: false,
          ),
        ),
      ),
      isTabRightAligned: true,
      /*
      tabSuffix: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(),
          ),
          StorybridgeButton(
            icon: Icons.share_rounded,
            text: "Share",
            invertedColor: true,
          ),
        ],
      ),
      */
      tabNames: [
        StorybridgeTabHeader(
            tabName: "Audit", tabIcon: Icons.collections_bookmark_rounded),
        StorybridgeTabHeader(
            tabName: "Permissions",
            tabIcon: Icons.collections_bookmark_rounded),
      ],
      tabs: [
        _AuditTaskPage(auditTaskId: auditTaskId),
        _AuditTaskPermissionsPage(auditTaskId: auditTaskId),
      ],
    );
  }
}

class _AuditPageAdmin extends StatelessWidget {
  // members of MyWidget
  final int auditTemplateId;
  final int startingTab;

  // constructor
  const _AuditPageAdmin({
    Key? key,
    required this.auditTemplateId,
    required this.startingTab,
  }) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgeScaffold(
      hasAppbar: false,
      startingTab: startingTab,
      body: const [],
      tabPrefix: IntrinsicWidth(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: _AuditName(
            auditTemplateId: auditTemplateId,
            isAdminMode: false,
          ),
        ),
      ),
      tabSuffix: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          StorybridgeSavingIndicator(),
          //StorybridgeAccountIndicator(organizationId: organizationId),
        ],
      ),
      isTabRightAligned: true,
      tabNames: [
        StorybridgeTabHeader(
            tabName: "Audit", tabIcon: Icons.collections_bookmark_rounded),
        StorybridgeTabHeader(
            tabName: "Workflow", tabIcon: Icons.collections_bookmark_rounded),
        StorybridgeTabHeader(
            tabName: "Settings", tabIcon: Icons.collections_bookmark_rounded),
        /*
        StorybridgeTabHeaders(
            tabName: "Discussion", tabIcon: Icons.school_rounded),
        StorybridgeTabHeaders(tabName: "Notes", tabIcon: Icons.article_rounded),
        */
      ],
      tabs: [
        _AuditTemplatePage(auditTemplateId: auditTemplateId),
        _AuditWorkflowPage(auditTemplateId: auditTemplateId),
        AuditSettingsPage(
          auditTemplateId: auditTemplateId,
        )
      ],
    );
  }
}

class _AuditTemplatePage extends StatelessWidget {
  // members of MyWidget
  final int auditTemplateId;

  // constructor
  const _AuditTemplatePage({Key? key, required this.auditTemplateId})
      : super(key: key);

  Future<dynamic> _load() async {
    await auditing_service.setAuditTemplateId(auditTemplateId, true);
    return true;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _load(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData) {
            return StorybridgeTabPage(sideBar: [], body: [
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: StorybridgePageLoading(),
              )
            ]);
          }
          return AuditEditorPage(
              auditTemplateId: auditTemplateId,
              auditTaskId: null,
              isAdminMode: true);
        });
  }
}

class _AuditTaskPage extends StatefulWidget {
  // members of MyWidget
  final int auditTaskId;

  // constructor
  const _AuditTaskPage({Key? key, required this.auditTaskId}) : super(key: key);

  @override
  State<_AuditTaskPage> createState() => _AuditTaskPageState();
}

class _AuditTaskPageState extends State<_AuditTaskPage> {
  bool _errored = false;
  Future<dynamic> _load() async {
    if (_errored) {
      return;
    }
    try {
      await auditing_service.setAuditTaskId(widget.auditTaskId);
    } on error_service.StorybridgeException catch (e) {
      _errored = true;
      setState(() {
        error_service.alert(error_service.Alert(
            title: e.message,
            description: e.description ?? "",
            buttonName: "Go back",
            allowCancel: false,
            callback: (_) {
              Navigator.pop(context);
            }));
      });
    }
    var data = auditing_service.getAuditData();
    await auditing_service.setAuditTemplateId(data["auditTemplateId"], false);
    return data;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    error_service.checkAlerts(context);
    return FutureBuilder(
        future: _load(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return StorybridgeTabPage(sideBar: [], body: [
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: StorybridgePageLoading(),
              )
            ]);
          }
          return AuditEditorPage(
              auditTemplateId: snapshot.data["auditTemplateId"],
              auditTaskId: widget.auditTaskId,
              isAdminMode: false);
        });
  }
}

class AuditEditorPage extends StatefulWidget {
  final int auditTemplateId;
  final int? auditTaskId;
  final bool isAdminMode;
  const AuditEditorPage(
      {required this.auditTemplateId,
      required this.isAdminMode,
      required this.auditTaskId,
      Key? key})
      : super(key: key);

  @override
  _AuditEditorPageState createState() => _AuditEditorPageState();
}

// myPage state
class _AuditEditorPageState extends State<AuditEditorPage>
    implements course_navigation_service.CourseNavigationFrontPageElement {
  final ScrollController _scrollController = ScrollController();

  @override
  void onUpdateFrontPage(bool isFrontPage) {
    try {
      setState(() {});
    } catch (_) {}
  }

  @override
  void initState() {
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
        sideBar: [
          _AuditSidebar(
            auditTemplateId: widget.auditTemplateId,
            isAdminMode: widget.isAdminMode,
          )
        ],
        hasRightSideBarPadding: false,
        rightSideBar: widget.isAdminMode ? [AuditEditorDragSidebar()] : null,
        body: [
          _AuditViewer(
            scrollController: _scrollController,
            isAdminMode: widget.isAdminMode,
            auditTaskId: widget.auditTaskId,
            auditTemplateId: widget.auditTemplateId,
          ),
        ]);
  }
}

// myPage class which creates a state on call
class _AuditViewer extends StatefulWidget {
  final int auditTemplateId;
  final bool isAdminMode;
  final ScrollController scrollController;
  final int? auditTaskId;
  const _AuditViewer(
      {Key? key,
      required this.auditTemplateId,
      required this.isAdminMode,
      required this.auditTaskId,
      required this.scrollController})
      : super(key: key);

  @override
  _AuditViewerState createState() => _AuditViewerState();
}

// myPage state
class _AuditViewerState extends State<_AuditViewer>
    implements
        course_navigation_service.CourseNavigationElement,
        auditing_service.AuditTemplateElement {
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
  void onAuditChangePage(String pageId) {
    setState(() {});
  }

  @override
  void initState() {
    course_navigation_service.registerViewer(this);
    auditing_service.auditTemplateViewer = this;
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
        return AuditorEditorViewerPage(
          scrollController: widget.scrollController,
          auditTemplateId: widget.auditTemplateId,
          auditTaskId: widget.auditTaskId,
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

class AuditorEditorViewerPage extends StatefulWidget {
  final course_navigation_service.CourseData courseData;
  final int auditTemplateId;
  final int? auditTaskId;
  final ScrollController scrollController;
  final bool isAdminMode;

  const AuditorEditorViewerPage(
      {Key? key,
      required this.courseData,
      required this.auditTemplateId,
      required this.auditTaskId,
      required this.isAdminMode,
      required this.scrollController})
      : super(key: key);
  @override
  _AuditorEditorViewerPageState createState() =>
      _AuditorEditorViewerPageState();
}

class _AuditorEditorViewerPageState extends State<AuditorEditorViewerPage> {
  final _courseElementNameController = StorybridgeTextFieldController();
  int _updatesQueued = 0;
  int _statusLabelGroupId = 0;
  dynamic _status;
  String? _nextPageId;

  // fancy late keyword by https://stackoverflow.com/a/68273324
  late EditorWidgetColumn _stemEditorWidget = EditorWidgetColumn(
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

  void _onUpdate() async {
    _updatesQueued++;
    if (_updatesQueued > 1) {
      return; // turn away new updates until update is finished
    }

    _updatesQueued = 0;
    if (widget.isAdminMode) {
      try {
        auditing_service.setAuditTemplatePageData(
            widget.auditTemplateId, _stemEditorWidget.saveToJson());
      } on error_service.StorybridgeException catch (e) {
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
    /*
    */
  }

  void _changeCourseElementName() async {
    auditing_service.renameAuditTemplatePage(
      widget.auditTemplateId,
      auditing_service.getSelectedAuditTemplatePageId(widget.auditTemplateId)!,
      _courseElementNameController.text,
    );
    _onUpdate();
  }

  Future<bool> _loadData() async {
    try {
      if (widget.auditTaskId != null) {
        Map<String, dynamic> auditTaskData = await networking_api_service
            .getAuditTask(auditTaskId: widget.auditTaskId!);
        _status = auditTaskData["data"][0]["status"];
      }
      Map<String, dynamic> data = await auditing_service
          .getAuditTemplatePageData(widget.auditTemplateId, widget.isAdminMode);
      _statusLabelGroupId = auditing_service
          .getAuditTemplateStatusLabelGroupId(widget.auditTemplateId);
      _stemEditorWidget = EditorWidgetColumn(
        editorWidgetData: EditorWidgetData(
          onUpdate: _onUpdate,
          courseData: widget.courseData,
          isAdminMode: widget.isAdminMode,
          z: 0,
        ),
      );
      _courseElementNameController.text = data["pageName"];
      _stemEditorWidget.loadFromJson(data["data"]);
      widget.scrollController.jumpTo(0);

      // get next page
      var response = await auditing_service.getAuditTemplateHierarchyData(
          widget.auditTemplateId, widget.isAdminMode);
      for (int i = 0; i < response.length; i++) {
        if (response[i]["pageId"] ==
            auditing_service
                .getSelectedAuditTemplatePageId(widget.auditTemplateId)) {
          try {
            _nextPageId = response[i + 1]["pageId"];
          } catch (_) {}
        }
      }
    } catch (_) {
      setState(() {
        error_service.alert(error_service.Alert(
            title: 'Error parsing course element data',
            description:
                "This bug has automatically been logged. We apologize for this error. Please try closing & reopening this website.",
            buttonName: "Go back",
            callback: (_) {
              Navigator.pop(context);
            }));
      });
    }
    return true;
  }

  Future<void> _changeAuditTaskLabelId(List<int> labelIds) async {
    if (widget.auditTaskId != null) {
      await networking_api_service.changeAuditTaskStatus(
          auditTaskId: widget.auditTaskId!,
          status: jsonEncode({"selectedLabels": labelIds}));
    }
  }

  @override
  Widget build(BuildContext context) {
    error_service.checkAlerts(context);
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
                            child: Row(
                              children: [
                                Expanded(
                                  child: StorybridgeEditableText(
                                    enabled: widget.isAdminMode,
                                    style: StorybridgeTextH2Style,
                                    controller: _courseElementNameController,
                                    onSubmit: _changeCourseElementName,
                                  ),
                                ),
                                widget.auditTaskId != null
                                    ? StorybridgeLabels(
                                        labelGroupId: _statusLabelGroupId,
                                        selectedLabels: _status,
                                        canEdit: true,
                                        onUpdate: (labelId) async {
                                          await _changeAuditTaskLabelId(
                                              labelId);
                                          setState(() {});
                                        },
                                      )
                                    : Container(),
                              ],
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
                          _nextPageId != null
                              ? StorybridgeButton(
                                  text: "Next page",
                                  invertedColor: true,
                                  onPressed: () async {
                                    if (_nextPageId != null) {
                                      setState(() {
                                        auditing_service
                                            .setSelectedAuditTemplatePageId(
                                                widget.auditTemplateId,
                                                _nextPageId!);
                                      });
                                    }
                                  },
                                )
                              : (widget.auditTaskId != null
                                  ? _SubmitButton(
                                      auditTaskId: widget.auditTaskId!)
                                  : Container()),
                        ],
                      )
                    : const StorybridgePageLoading(),
              ],
            ),
          );
        });
  }
}

// myPage class which creates a state on call
class AuditSettingsPage extends StatefulWidget {
  final int auditTemplateId;
  const AuditSettingsPage({Key? key, required this.auditTemplateId})
      : super(key: key);

  @override
  _AuditSettingsPageState createState() => _AuditSettingsPageState();
}

// myPage state
class _AuditSettingsPageState extends State<AuditSettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _deleteAuditTemplate() async {
    setState(() {
      error_service.alert(error_service.Alert(
          title: "Delete this audit template?",
          description:
              "Are you sure you want to delete this audit template? All data will be lost forever.",
          buttonName: "DELETE",
          allowCancel: true,
          callback: (_) async {
            Map<String, dynamic> response = await networking_api_service
                .getAuditTemplate(auditTemplateId: widget.auditTemplateId);
            int organizationId = response["data"][0]["organizationId"];
            await networking_api_service.removeAuditTemplate(
                auditTemplateId: widget.auditTemplateId);
            Navigator.pushNamed(
                context, "/organization/audits?id=$organizationId");
          }));
    });
  }

  void _changeCourseLiveness(bool isLive) async {}

  // main build function
  @override
  Widget build(BuildContext context) {
    error_service.checkAlerts(context);
    return StorybridgeTabPage(body: [
      const SizedBox(height: 40),
      const StorybridgeTextH2("General Settings"),
      const SizedBox(height: 60),
      StorybridgeSettingButton(
          loadValue: () async {
            Map<String, dynamic> response = await networking_api_service
                .getAuditTemplate(auditTemplateId: widget.auditTemplateId);
            return Uri.decodeComponent(
                response["data"][0]["auditTemplateName"]);
          },
          saveValue: (String newName) async {
            Map<String, dynamic> response = await networking_api_service
                .getAuditTemplate(auditTemplateId: widget.auditTemplateId);
            response["data"][0]["auditTemplateName"] = newName;
            await networking_api_service.changeAuditTemplate(
              auditTemplateId: response["data"][0]["auditTemplateId"],
              auditTemplateName: newName,
              auditTemplateDescription: Uri.decodeComponent(
                  response["data"][0]["auditTemplateDescription"]),
              auditTemplateData:
                  Uri.decodeComponent(response["data"][0]["auditTemplateData"]),
            );
          },
          name: "Audit Template Name"),
      const StorybridgeDescriptor(
        name: "Course Files",
      ),
      _AuditTemplateFilesViewer(auditTemplateId: widget.auditTemplateId),
      StorybridgeButton(
        text: "Delete Audit Template",
        lightenBackground: true,
        onPressed: _deleteAuditTemplate,
      )
    ]);
  }
}

class _AuditName extends StatefulWidget {
  final int? auditTemplateId;
  final int? auditTaskId;
  final bool isAdminMode;
  const _AuditName({
    Key? key,
    this.auditTemplateId,
    this.auditTaskId,
    required this.isAdminMode,
  }) : super(key: key);

  @override
  _AuditNameState createState() => _AuditNameState();
}

class _AuditNameState extends State<_AuditName> {
  String _auditTemplateName = "";
  String _organizationName = "";
  int _organizationId = 0;
  ProfilePictureController profilePictureController =
      ProfilePictureController();

  Future<bool> loadCourseName() async {
    int auditTemplateId;
    if (widget.auditTemplateId != null) {
      auditTemplateId = widget.auditTemplateId!;
    } else {
      if (widget.auditTaskId != null) {
        Map<String, dynamic> task = await networking_api_service.getAuditTask(
            auditTaskId: widget.auditTaskId!);
        auditTemplateId = task["data"][0]["auditTemplateId"];
      } else {
        return false; // error!
      }
    }
    Map<String, dynamic> audit = await networking_api_service.getAuditTemplate(
        auditTemplateId: auditTemplateId);
    _organizationId = audit["data"][0]["organizationId"];
    Map<String, dynamic> organization = await networking_api_service
        .getOrganization(organizationId: _organizationId);
    _auditTemplateName =
        Uri.decodeComponent(audit["data"][0]["auditTemplateName"]);
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
            if (_auditTemplateName.length > 35) {
              courseNameTextFontSize = StorybridgeTextH2BStyle.fontSize! - 2;
            } else if (_auditTemplateName.length < 20) {
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
                          context, "/organization/audits?id=$_organizationId");
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
                                          StorybridgeTextBasic(
                                              _auditTemplateName,
                                              style: courseNameStyle),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return StorybridgeTextBasic(
                                        _auditTemplateName,
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

class _AuditSidebar extends StatefulWidget {
  final int auditTemplateId;
  final bool isAdminMode;
  const _AuditSidebar(
      {Key? key, required this.auditTemplateId, required this.isAdminMode})
      : super(key: key);

  @override
  _AuditSidebarState createState() => _AuditSidebarState();
}

// myPage state
class _AuditSidebarState extends State<_AuditSidebar>
    implements auditing_service.AuditTemplateElement {
  List<dynamic> _data = [];

  @override
  void initState() {
    super.initState();
    auditing_service.auditTemplateHierarchy = this;
  }

  @override
  void onAuditChangePage(String pageId) {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _addPage() {
    auditing_service.addAuditTemplatePage(widget.auditTemplateId);
  }

  Future<dynamic> _load() async {
    _data = await auditing_service.getAuditTemplateHierarchyData(
        widget.auditTemplateId, widget.isAdminMode);
    return true;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    error_service.checkAlerts(context);
    return FutureBuilder(
        future: _load(),
        builder: (context, snapshot) {
          return Column(
            children: [
              const SizedBox(height: 80),
              Column(
                children: List.generate(_data.length, (int i) {
                  return StorybridgeHoverButton(
                    enabled: widget.isAdminMode,
                    button: PopupEditElementButton(
                      onPressed: (EditElementTypes item) {
                        switch (item) {
                          case EditElementTypes.rename:
                            setState(() {
                              error_service.alert(error_service.Alert(
                                  title: 'Rename "${_data[i]["pageName"]}"',
                                  description: "Please enter a new name",
                                  buttonName: "OK",
                                  prefillInputText: _data[i]["pageName"],
                                  acceptInput: true,
                                  callback: (String input) async {
                                    auditing_service.renameAuditTemplatePage(
                                        widget.auditTemplateId,
                                        _data[i]["pageId"],
                                        input);
                                    course_navigation_service.reloadAll();
                                  }));
                            });
                            break;
                          case EditElementTypes.move:
                            break;
                          case EditElementTypes.delete:
                            setState(() {
                              error_service.alert(error_service.Alert(
                                  title: 'Delete "${_data[i]["pageName"]}"?',
                                  description:
                                      "Are you sure you wish to permanently delete ${_data[i]["pageName"]}?\nAll data will be lost forever.",
                                  buttonName: "DELETE",
                                  acceptInput: false,
                                  callback: (String input) async {
                                    auditing_service.deleteAuditTemplatePage(
                                        widget.auditTemplateId,
                                        _data[i]["pageId"]);
                                  }));
                            });
                            break;
                        }
                      },
                    ),
                    child: StorybridgeSideBarButton(
                        icon: Icons.article_rounded,
                        label: _data[i]["pageName"],
                        selected:
                            auditing_service.getSelectedAuditTemplatePageId(
                                    widget.auditTemplateId) ==
                                _data[i]["pageId"],
                        onPressed: () {
                          setState(() {
                            auditing_service.setSelectedAuditTemplatePageId(
                                widget.auditTemplateId, _data[i]["pageId"]);
                          });
                        }),
                  );
                }),
              ),
              widget.isAdminMode
                  ? StorybridgeButton(
                      text: "Add Page",
                      onPressed: () {
                        _addPage();
                      },
                    )
                  : Container(),
            ],
          );
        });
  }
}

class _AuditWorkflowPage extends StatefulWidget {
  final int auditTemplateId;
  const _AuditWorkflowPage({Key? key, required this.auditTemplateId})
      : super(key: key);

  @override
  _AuditWorkflowPageState createState() => _AuditWorkflowPageState();
}

// myPage state
class _AuditWorkflowPageState extends State<_AuditWorkflowPage> {
  Future<dynamic> _load() async {
    /*
    Map<String, dynamic> response =
        await networking_api_service.getUserFiles(userId: widget.userId);
    _totalSize = response["data"]["totalSize"];
    return response["data"]["data"];
    */
    return true;
  }

  Future<dynamic> _createCoordinatorGroup() async {
    setState(() {});
    //return response["data"];
  }

  Future<dynamic> _removeImage(var pk, var data) async {
    await networking_api_service.removeImage(imageId: data["imageId"]);
    setState(() {});
  }

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
    return StorybridgeTabPage(
        disableScroll: true,
        hasVeryReducedPadding: true,
        body: [
          FutureBuilder(
              future: _load(),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  return AuditWorkflowCanvas(
                    auditTemplateId: widget.auditTemplateId,
                  );
                } else {
                  return const StorybridgePageLoading();
                }
              })
        ]);
  }
}

class _AuditTemplateFilesViewer extends StatefulWidget {
  final int auditTemplateId;
  const _AuditTemplateFilesViewer({Key? key, required this.auditTemplateId})
      : super(key: key);

  @override
  _AuditTemplateFilesViewerState createState() =>
      _AuditTemplateFilesViewerState();
}

// myPage state
class _AuditTemplateFilesViewerState extends State<_AuditTemplateFilesViewer> {
  double? _totalSize;
  Future<dynamic> _load() async {
    Map<String, dynamic> response = await networking_api_service
        .getAuditTemplateFiles(auditTemplateId: widget.auditTemplateId);
    _totalSize = response["data"]["totalSize"];
    return response["data"]["data"];
  }

  Future<dynamic> _removeImage(int imageId) async {
    await networking_api_service.removeImage(imageId: imageId);
    setState(() {});
  }

  Future<dynamic> _removeVideo(int videoId) async {
    await networking_api_service.removeVideo(videoId: videoId);
    setState(() {});
  }

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
    // ignore: unused_local_variable
    return FutureBuilder(
        future: _load(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData) {
            return const StorybridgeBoxLoading(height: 200, width: 300);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StorybridgeTextP(
                  "Total Size: ${_totalSize?.round() ?? "unknown"} MB"),
              StorybridgeTable(
                  maxItemsPerPage: 5,
                  pkName: "contentDataId",
                  onDelete: null,
                  /*(var pk, var data, int i) {
                    if (data["imageId"] != null) {
                      _removeImage(data["imageId"]);
                    } else if (data["videoId"] != null) {
                      _removeVideo(data["videoId"]);
                    }
                  },*/
                  data: snapshot.data),
            ],
          );
        });
  }
}

class _AuditTaskPermissionsPage extends StatefulWidget {
  // members of MyWidget
  final int auditTaskId;

  // constructor
  const _AuditTaskPermissionsPage({Key? key, required this.auditTaskId})
      : super(key: key);

  @override
  State<_AuditTaskPermissionsPage> createState() =>
      _AuditTaskPermissionsPageState();
}

class _AuditTaskPermissionsPageState extends State<_AuditTaskPermissionsPage> {
  Future<dynamic> _load() async {
    Map<String, dynamic> response = await networking_api_service
        .getAuditPrivilegesForAuditTask(auditTaskId: widget.auditTaskId);
    return response["data"];
  }

  void _assignUser() {
    StorybridgeShowDialog(
        context: context,
        builder: (BuildContext context) => _AuditTaskPermissionAssignPopup(
              auditTaskId: widget.auditTaskId,
              onUpdate: () {
                setState(() {});
              },
            ));
    setState(() {});
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgeTabPage(hasVeryReducedPadding: true, body: [
      const SizedBox(height: 50),
      FutureBuilder(
          future: _load(),
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StorybridgeTextH2("Permissions"),
                  Row(
                    children: [
                      Expanded(
                        child: Container(),
                      ),
                      StorybridgeButton(
                        invertedColor: true,
                        icon: Icons.sync_alt_rounded,
                        text: "Assign user",
                        onPressed: () {
                          _assignUser();
                        },
                      ),
                    ],
                  ),
                  Center(
                    child: StorybridgeTable(
                      advancedHeaders: [
                        StorybridgeTableHeader(key: "name", label: "Name"),
                        StorybridgeTableHeader(key: "email", label: "Email"),
                        StorybridgeTableHeader(
                          key: "canEdit",
                          label: "Can\nedit?",
                          type: StorybridgeTableHeaderType.boolean,
                          width: 90,
                        ),
                        StorybridgeTableHeader(
                          key: "canComment",
                          label: "Can comment?",
                          type: StorybridgeTableHeaderType.boolean,
                          width: 90,
                        ),
                        StorybridgeTableHeader(
                          key: "isOwner",
                          label: "Is\nowner?",
                          type: StorybridgeTableHeaderType.boolean,
                          width: 90,
                        ),
                        StorybridgeTableHeader(
                          key: "dateCreated",
                          label: "Date assigned",
                          type: StorybridgeTableHeaderType.datetime,
                        ),
                        StorybridgeTableHeader(
                          key: "dateSubmitted",
                          label: "Date submitted",
                          type: StorybridgeTableHeaderType.datetime,
                        ),
                        StorybridgeTableHeader(
                          key: "submitVerb",
                          label: "Verdict",
                        ),
                      ],
                      onDelete: (_, dynamic data, _2) async {
                        await networking_api_service.removeAuditPrivilege(
                            auditPrivilegeId: data["auditPrivilegeId"]);
                        setState(() {});
                      },
                      data: snapshot.data,
                    ),
                  ),
                ],
              );
            } else {
              return const StorybridgePageLoading();
            }
          })
    ]);
  }
}

// myPage class which creates a state on call
class _AuditTaskPermissionAssignPopup extends StatefulWidget {
  final int auditTaskId;
  final Function onUpdate;
  const _AuditTaskPermissionAssignPopup(
      {Key? key, required this.auditTaskId, required this.onUpdate})
      : super(key: key);

  @override
  _AuditTaskPermissionAssignPopupState createState() =>
      _AuditTaskPermissionAssignPopupState();
}

// myPage state
class _AuditTaskPermissionAssignPopupState
    extends State<_AuditTaskPermissionAssignPopup> {
  final List<String> _users = [];
  final Map<String, int> _userToId = {};
  StorybridgeTextFieldController userController =
      StorybridgeTextFieldController();
  StorybridgeTextFieldController _submitModeController =
      StorybridgeTextFieldController();
  int userId = 0;

  bool canEdit = false;
  bool canComment = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<dynamic> _load() async {
    // get users from organization
    Map<String, dynamic> auditTaskReponse = await networking_api_service
        .getAuditTask(auditTaskId: widget.auditTaskId);
    Map<String, dynamic> auditTemplateReseponse =
        await networking_api_service.getAuditTemplate(
            auditTemplateId: auditTaskReponse["data"][0]["auditTemplateId"]);
    Map<String, dynamic> responseUsers =
        await networking_api_service.getUserFromOrganizationId(
            organizationId: auditTemplateReseponse["data"][0]
                ["organizationId"]);
    for (var user in responseUsers["data"]) {
      String key = Uri.decodeComponent(
          "${user["email"]} - ${user["firstName"]} ${user["lastName"]}");
      _users.add(key);
      _userToId[key] = user["userId"];
    }
    return true;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    List<String> submitModeDescriptors = [
      "User can submit",
      "User can approve or reject"
    ];
    _submitModeController.text = submitModeDescriptors[0];
    // ignore: unused_local_variable
    return StorybridgeAlertDialogWrapper(
        child: StorybridgeAlertDialog(
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: FutureBuilder(
              future: _load(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (!snapshot.hasData) {
                  return const StorybridgeBoxLoading(height: 100, width: 300);
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const StorybridgeTextH2B("Assign user to audit"),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 300,
                      child: StorybridgeDropdown(
                          label: "User",
                          controller: userController,
                          dropdownTypes: _users),
                    ),
                    const StorybridgeTextP(
                        "Note: Once assigned, this user will be able to view this audit."),
                    StorybridgeCheckbox(
                        label: "User can edit",
                        value: canEdit,
                        onChanged: (bool newValue) {
                          setState(() {
                            canEdit = newValue;
                          });
                        }),
                    StorybridgeCheckbox(
                        label: "User can comment",
                        value: canComment,
                        onChanged: (bool newValue) {
                          setState(() {
                            canComment = newValue;
                          });
                        }),
                    StorybridgeDropdown(
                        label: "Submit Mode",
                        controller: _submitModeController,
                        dropdownTypes: submitModeDescriptors),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        StorybridgeButton(
                          padding: false,
                          text: "Assign",
                          invertedColor: true,
                          onPressed: () async {
                            int? userId = _userToId[userController.text];
                            int? submitMode;
                            for (int i = 0;
                                i < submitModeDescriptors.length;
                                i++) {
                              if (submitModeDescriptors[i] ==
                                  _submitModeController.text) {
                                submitMode = i;
                              }
                            }
                            if (submitMode == null) {
                              throw Exception("submitMode not identified");
                            }

                            if (userId != null) {
                              await networking_api_service.createAuditPrivilege(
                                userId: userId,
                                auditTaskId: widget.auditTaskId,
                                canEdit: canEdit,
                                canComment: canComment,
                                submitMode: submitMode,
                              );
                            }
                            widget.onUpdate();
                            setState(() {});
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 10),
                        StorybridgeButton(
                            padding: false,
                            text: "Cancel",
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      ],
                    ),
                  ],
                );
              }),
        ),
      ),
    ));
  }
}

class _SubmitButton extends StatefulWidget {
  // members of MyWidget
  final int auditTaskId;

  // constructor
  const _SubmitButton({Key? key, required this.auditTaskId}) : super(key: key);

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  Future<dynamic> _load() async {
    Map<String, dynamic> response = await networking_api_service
        .getAuditPrivilegeForUserAndAuditTask(auditTaskId: widget.auditTaskId);
    return response["data"][0];
  }

  void _submit(String submitVerb) {
    StorybridgeShowDialog(
      context: context,
      builder: (BuildContext context) => StorybridgeAlertDialogWrapper(
        child: StorybridgeAlertDialog(
          content: _SubmitButtonPopup(
            auditTaskId: widget.auditTaskId,
            submitVerb: submitVerb,
          ),
        ),
      ),
    );
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgeTile(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder(
            future: _load(),
            builder: (context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return StorybridgeBoxLoading(height: 50, width: 150);
              }
              switch (snapshot.data["submitMode"]) {
                case 0:
                  return StorybridgeButton(
                    text: "Submit",
                    icon: Icons.done_all_rounded,
                    invertedColor: true,
                    onPressed: () {
                      _submit("Submit");
                    },
                  );
                case 1:
                default:
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StorybridgeButton(
                        text: "Approve",
                        invertedColor: true,
                        icon: Icons.check_rounded,
                        onPressed: () {
                          _submit("Approve");
                        },
                      ),
                      StorybridgeButton(
                        text: "Reject",
                        invertedColor: true,
                        icon: Icons.close_rounded,
                        onPressed: () {
                          _submit("Reject");
                        },
                      ),
                    ],
                  );
              }
            }),
      ),
    );
  }
}

class _SubmitButtonPopup extends StatefulWidget {
  final String submitVerb;
  final int auditTaskId;

  // constructor
  const _SubmitButtonPopup({
    Key? key,
    required this.submitVerb,
    required this.auditTaskId,
  }) : super(key: key);

  @override
  State<_SubmitButtonPopup> createState() => _SubmitButtonPopupState();
}

class _SubmitButtonPopupState extends State<_SubmitButtonPopup> {
  bool _startedDrawingSignature = false;
  bool _loadingSubmitting = false;
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
    exportPenColor: Colors.black,
  );

  void _startDrawing() {
    setState(() {
      _startedDrawingSignature = true;
    });
  }

  void _submit() async {
    setState(() {
      _loadingSubmitting = true;
    });
    List<dynamic> points = [];
    for (int i = 0; i < _controller.points.length; i++) {
      points.add([
        _controller.points[i].offset.dx,
        _controller.points[i].offset.dy,
      ]);
    }
    await networking_api_service.submitAuditPrivilege(
        auditTaskId: widget.auditTaskId,
        submitData: jsonEncode({
          "submitVerb": widget.submitVerb.toLowerCase(),
          "signatureData": points
        }));
    setState(() {
      _loadingSubmitting = false;
    });
    Navigator.pop(context);
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    _controller.onDrawStart = _startDrawing;
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StorybridgeIconButton(
              icon: Icons.close,
              onPressed: () {
                Navigator.pop(context);
              }),
          const SizedBox(height: 10),
          StorybridgeTextH2B("${widget.submitVerb} - Signature Required"),
          const StorybridgeTextP(
              "Please sign in the grey area below using your trackpad/screen."),
          const SizedBox(height: 30),
          StorybridgeTextP(
              "I hereby ${widget.submitVerb.toLowerCase()} this form.\nSigned,"),
          const SizedBox(height: 10),
          //SIGNATURE CANVAS
          SizedBox(
            width: 300,
            height: 200,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: Signature(
                key: const Key('signature'),
                controller: _controller,
                height: 300,
                backgroundColor: Colors.grey[300]!,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _startedDrawingSignature
              ? Row(
                  children: [
                    StorybridgeButton(
                      padding: false,
                      loading: _loadingSubmitting,
                      text: widget.submitVerb,
                      invertedColor: true,
                      onPressed: (() {
                        _submit();
                      }),
                    ),
                    const SizedBox(width: 10),
                    StorybridgeButton(
                      padding: false,
                      loading: _loadingSubmitting,
                      text: "Clear",
                      onPressed: (() {
                        setState(() {
                          _startedDrawingSignature = false;
                        });
                        _controller.clear();
                      }),
                    ),
                  ],
                )
              : const SizedBox(
                  height: 50,
                  child: StorybridgeTextP("Please sign in grey area"))
        ],
      ),
    );
  }
}

class _AuditTaskSummaryPage extends StatefulWidget {
  // members of MyWidget
  final int auditTaskId;

  // constructor
  const _AuditTaskSummaryPage({Key? key, required this.auditTaskId})
      : super(key: key);

  @override
  State<_AuditTaskSummaryPage> createState() => _AuditTaskSummaryPageState();
}

class _AuditTaskSummaryPageState extends State<_AuditTaskSummaryPage> {
  Future<dynamic> _load() async {
    Map<String, dynamic> response = await networking_api_service
        .getAuditPrivilegesForAuditTask(auditTaskId: widget.auditTaskId);
    return response["data"];
  }

  void _assignUser() {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => _AuditTaskPermissionAssignPopup(
              auditTaskId: widget.auditTaskId,
              onUpdate: () {
                setState(() {});
              },
            ));
    setState(() {});
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    int data = 2;
    return StorybridgeTabPage(hasVeryReducedPadding: true, body: [
      const SizedBox(height: 50),
      FutureBuilder(
          future: _load(),
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            if (!snapshot.hasData) {
              return const StorybridgePageLoading();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StorybridgeTextH2("Summary"),
                const SizedBox(height: 20),
                StorybridgeLineChart(x: data),
                const StorybridgeBox(
                  useAltStyle: true,
                  child: StorybridgePadding(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StorybridgeTextP("# of Non compliancies"),
                        StorybridgeTextH2("20"),
                        SizedBox(height: 30),
                        StorybridgeTextP("# of NC Priority A"),
                        StorybridgeTextH2("5"),
                        SizedBox(height: 30),
                        StorybridgeTextP("# of forms per department"),
                        StorybridgeTextH2("50"),
                      ],
                    ),
                  ),
                )
              ],
            );
          })
    ]);
  }
}
