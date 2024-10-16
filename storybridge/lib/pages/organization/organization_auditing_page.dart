import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mooc/storybridge.dart'; // Storybridge

import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;

// myPage class which creates a state on call
class OrganizationAuditingPage extends StatefulWidget {
  final int organizationId;
  const OrganizationAuditingPage({Key? key, required this.organizationId})
      : super(key: key);

  @override
  _OrganizationAuditingPageState createState() =>
      _OrganizationAuditingPageState();
}

// myPage state
class _OrganizationAuditingPageState extends State<OrganizationAuditingPage> {
  final StorybridgeTabPageController _tabPageController =
      StorybridgeTabPageController();
  int _selectedPage = 0;

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
        hasVeryReducedPadding: true,
        tabPageController: _tabPageController,
        sideBar: [
          const SizedBox(height: 80),
          StorybridgeSideBarButton(
              label: "Dashboards",
              icon: Icons.analytics_outlined,
              onPressed: () {
                // hide mobile sidebar
                _tabPageController.mobileShowSidebar = false;
                _tabPageController.update();

                setState(() {
                  _selectedPage = 0;
                });
              },
              selected: _selectedPage == 0),
          const StorybridgeDivider(),
          StorybridgeSideBarButton(
              label: "Audit templates",
              icon: Icons.assignment_outlined,
              onPressed: () {
                // hide mobile sidebar
                _tabPageController.mobileShowSidebar = false;
                _tabPageController.update();

                setState(() {
                  _selectedPage = 1;
                });
              },
              selected: _selectedPage == 1),
          StorybridgeSideBarButton(
              label: "Audits",
              icon: Icons.assignment_turned_in_outlined,
              onPressed: () {
                // hide mobile sidebar
                _tabPageController.mobileShowSidebar = false;
                _tabPageController.update();

                setState(() {
                  _selectedPage = 2;
                });
              },
              selected: _selectedPage == 2),
          const StorybridgeDivider(),
          StorybridgeSideBarButton(
              label: "Data types",
              icon: Icons.category_outlined,
              onPressed: () {
                // hide mobile sidebar
                _tabPageController.mobileShowSidebar = false;
                _tabPageController.update();

                setState(() {
                  _selectedPage = 3;
                });
              },
              selected: _selectedPage == 3),
        ],
        body: [
          Builder(builder: (context) {
            switch (_selectedPage) {
              case 0:
                return _OrganizationAuditingDashboardPage(
                  organizationId: widget.organizationId,
                );
              case 1:
                return _OrganizationAuditingTemplatesPage(
                  organizationId: widget.organizationId,
                );
              case 2:
                return _OrganizationAuditingTasksPage(
                  organizationId: widget.organizationId,
                );
              case 3:
              default:
                return _OrganizationAuditingAllLabelsPage(
                  organizationId: widget.organizationId,
                );
            }
          })
        ]);
  }
}

// myPage class which creates a state on call
class _OrganizationAuditingTemplatesPage extends StatefulWidget {
  final int organizationId;
  const _OrganizationAuditingTemplatesPage({
    Key? key,
    required this.organizationId,
  }) : super(key: key);

  @override
  _OrganizationAuditingTemplatesPageState createState() =>
      _OrganizationAuditingTemplatesPageState();
}

// myPage state
class _OrganizationAuditingTemplatesPageState
    extends State<_OrganizationAuditingTemplatesPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<dynamic>> _load() async {
    Map<String, dynamic> response = await networking_api_service
        .getAuditTemplates(organizationId: widget.organizationId);
    return response["data"];
  }

  Future<void> _createAuditTemplate() async {
    await networking_api_service.createAuditTemplate(
        auditTemplateName: "Untitled Template",
        auditTemplateDescription: "",
        organizationId: widget.organizationId,
        auditTemplateData: '{"pages": ['
            '{'
            '"pageId": "${Random().nextInt(9999999).toString()}",'
            '"pageName": "page 1",'
            '"data": {"widgetType":"column", "children":[]}'
            '}'
            ']}');
    setState(() {
      _load();
    });
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 20),
      FutureBuilder(
          future: _load(),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.hasData) {
              return StorybridgeHolder(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      child: StorybridgeButton(
                          icon: Icons.add_rounded,
                          text: "New",
                          invertedColor: true,
                          verticalOnlyPadding: true,
                          onPressed: () async {
                            await _createAuditTemplate();
                          }),
                    ),
                    const SizedBox(height: 8),
                    snapshot.data!.isEmpty
                        ? const _NewAuditPromptWidget()
                        : Container(),
                    Column(
                        children: List.generate(snapshot.data!.length, (int i) {
                      return _OrganizationAuditWidget(
                          isAdmin: true,
                          auditTemplateId: snapshot.data![i]["auditTemplateId"],
                          courseName: Uri.decodeComponent(
                              snapshot.data![i]["auditTemplateName"]));
                    })),
                  ],
                ),
              );
            } else {
              return const StorybridgePageLoading();
            }
          }),
      Container(),
    ]);
  }
}

class _NewAuditPromptWidget extends StatelessWidget {
  // constructor
  const _NewAuditPromptWidget({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 32),
      child: StorybridgeTextH4("Click 'new' to create!"),
    );
  }
}

class _OrganizationAuditWidget extends StatelessWidget {
  // members of MyWidget
  final int auditTemplateId;
  final String courseName;
  final bool isAdmin;

  // constructor
  const _OrganizationAuditWidget(
      {Key? key,
      required this.auditTemplateId,
      required this.courseName,
      required this.isAdmin})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgePadding(
        verticalOnly: true,
        child: StorybridgeTile(
          child: InkWell(
            onTap: () {
              // open the template editor
              Navigator.of(context)
                  .pushNamed("/auditing-template?id=$auditTemplateId");
            },
            child: StorybridgePadding(
              child: SizedBox(
                height: 70,
                child: StorybridgeTextH2B(courseName),
              ),
            ),
          ),
        ));
  }
}

// myPage class which creates a state on call
class _OrganizationAuditingTasksPage extends StatefulWidget {
  final int organizationId;
  const _OrganizationAuditingTasksPage({
    Key? key,
    required this.organizationId,
  }) : super(key: key);

  @override
  _OrganizationAuditingTasksPageState createState() =>
      _OrganizationAuditingTasksPageState();
}

// myPage state
class _OrganizationAuditingTasksPageState
    extends State<_OrganizationAuditingTasksPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<dynamic>> _load() async {
    Map<String, dynamic> response = await networking_api_service.getAuditTasks(
        organizationId: widget.organizationId);
    return response["data"];
  }

  Future<void> _createAuditTask() async {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AuditTaskNewPopup(
              organizationId: widget.organizationId,
              onUpdate: () {
                setState(() {});
              },
            ));
    setState(() {
      _load();
    });
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 20),
      FutureBuilder(
          future: _load(),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Container()),
                      StorybridgeButton(
                          icon: Icons.add_rounded,
                          text: "New",
                          invertedColor: true,
                          verticalOnlyPadding: true,
                          onPressed: () async {
                            await _createAuditTask();
                          }),
                    ],
                  ),
                  const SizedBox(height: 8),
                  snapshot.data!.isEmpty
                      ? const _NewAuditPromptWidget()
                      : Container(),
                  StorybridgeTable(
                    data: snapshot.data!,
                    advancedHeaders: [
                      StorybridgeTableHeader(
                          key: "auditTaskId", label: "ID", width: 80),
                      StorybridgeTableHeader(
                          key: "auditTemplateName",
                          label: "Template type",
                          width: 200),
                      StorybridgeTableHeader(
                          key: "status",
                          label: "Status",
                          type: StorybridgeTableHeaderType.label),
                      StorybridgeTableHeader(
                          key: "dateCreated",
                          label: "Date created",
                          type: StorybridgeTableHeaderType.datetime),
                      StorybridgeTableHeader(
                          key: "dateModified",
                          label: "Date modified",
                          type: StorybridgeTableHeaderType.datetime),
                    ],
                    onDelete: (dynamic pk, dynamic data, int index) async {
                      await networking_api_service.removeAuditTask(
                          auditTaskId: pk);
                      setState(() {
                        _load();
                      });
                    },
                    onView: (dynamic pk, dynamic data, int index) {
                      Navigator.of(context).pushNamed("/audit?id=$pk");
                    },
                  )
                ],
              );
            } else {
              return const StorybridgePageLoading();
            }
          }),
      Container(),
    ]);
  }
}

// myPage class which creates a state on call
class AuditTaskNewPopup extends StatefulWidget {
  final int organizationId;
  final Function onUpdate;
  const AuditTaskNewPopup(
      {Key? key, required this.organizationId, required this.onUpdate})
      : super(key: key);

  @override
  _AuditTaskNewPopupState createState() => _AuditTaskNewPopupState();
}

// myPage state
class _AuditTaskNewPopupState extends State<AuditTaskNewPopup> {
  final List<String> _auditTemplates = [];
  final Map<String, int> _auditTemplateNameToId = {};
  StorybridgeTextFieldController templateController =
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
    Map<String, dynamic> response = await networking_api_service
        .getAuditTemplates(organizationId: widget.organizationId);
    for (int i = 0; i < response["data"].length; i++) {
      String auditTemplateName =
          Uri.decodeComponent(response["data"][i]["auditTemplateName"]);
      _auditTemplates.add(auditTemplateName);
      _auditTemplateNameToId[auditTemplateName] =
          response["data"][i]["auditTemplateId"];
    }
    return response["data"];
  }

  // main build function
  @override
  Widget build(BuildContext context) {
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
                    const StorybridgeTextH2B("Create new audit"),
                    const SizedBox(height: 20),
                    StorybridgeDropdown(
                      label: "Template",
                      dropdownTypes: _auditTemplates,
                      controller: templateController,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        StorybridgeButton(
                          padding: false,
                          text: "Create",
                          invertedColor: true,
                          onPressed: () async {
                            int auditTemplateId = _auditTemplateNameToId[
                                templateController.text]!;
                            await networking_api_service.createAuditTask(
                              auditTaskName: "Untitled Task",
                              auditTaskDescription: "",
                              auditTemplateId: auditTemplateId,
                              auditTaskData: '{"data": {}}',
                              status: '{"selectedLabels": []}',
                            );
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

class _OrganizationAuditingAllLabelsController {
  int? labelGroupId;
}

class _OrganizationAuditingAllLabelsPage extends StatefulWidget {
  final int organizationId;
  final _OrganizationAuditingAllLabelsController controller =
      _OrganizationAuditingAllLabelsController();
  _OrganizationAuditingAllLabelsPage({Key? key, required this.organizationId})
      : super(key: key);

  @override
  _OrganizationAudtingAllLabelsPageState createState() =>
      _OrganizationAudtingAllLabelsPageState();
}

// myPage state
class _OrganizationAudtingAllLabelsPageState
    extends State<_OrganizationAuditingAllLabelsPage> {
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
    if (widget.controller.labelGroupId == null) {
      return _OrganizationAuditingLabelGroupsPage(
          organizationId: widget.organizationId,
          controller: widget.controller,
          onUpdate: () {
            setState(() {});
          });
    }
    return _OrganizationAuditingLabelsPage(
        controller: widget.controller,
        onUpdate: () {
          setState(() {});
        });
  }
}

// myPage class which creates a state on call
class _OrganizationAuditingLabelGroupsPage extends StatefulWidget {
  final int organizationId;
  final _OrganizationAuditingAllLabelsController controller;
  final Function() onUpdate;
  const _OrganizationAuditingLabelGroupsPage({
    Key? key,
    required this.organizationId,
    required this.controller,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _OrganizationAuditingLabelGroupsPageState createState() =>
      _OrganizationAuditingLabelGroupsPageState();
}

// myPage state
class _OrganizationAuditingLabelGroupsPageState
    extends State<_OrganizationAuditingLabelGroupsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<dynamic>> _load() async {
    Map<String, dynamic> response = await networking_api_service.getLabelGroups(
        organizationId: widget.organizationId);

    // add asterisks to system owned (undeletable) label groups
    for (int i = 0; i < response["data"].length; i++) {
      if (response["data"][i]["canUserDelete"] != null &&
          response["data"][i]["canUserDelete"]["data"][0] == 0) {
        response["data"][i]["labelGroupName"] = Uri.encodeComponent(
            "${Uri.decodeComponent(response["data"][i]["labelGroupName"])}*");
      }
    }

    return response["data"];
  }

  Future<void> _createLabelGroup() async {
    await networking_api_service.createLabelGroup(
      labelGroupName: "",
      organizationId: widget.organizationId,
      isMultichoiceAllowed: false,
      canUserDelete: true,
    );
    setState(() {
      _load();
    });
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 20),
      FutureBuilder(
          future: _load(),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.hasData) {
              return StorybridgeHolder(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Container()),
                        StorybridgeButton(
                            icon: Icons.add_rounded,
                            text: "New",
                            invertedColor: true,
                            verticalOnlyPadding: true,
                            onPressed: () async {
                              await _createLabelGroup();
                            }),
                      ],
                    ),
                    const SizedBox(height: 8),
                    StorybridgeTable(
                      data: snapshot.data!,
                      advancedHeaders: [
                        StorybridgeTableHeader(
                            key: "labelGroupName", label: "Data type group"),
                        StorybridgeTableHeader(
                          key: "isMultichoiceAllowed",
                          label: "Multiple choice?",
                          type: StorybridgeTableHeaderType.boolean,
                        ),
                      ],
                      onEdit: (dynamic pk, dynamic data, int index) async {
                        await networking_api_service.changeLabelGroup(
                          labelGroupId: pk,
                          labelGroupName: data["labelGroupName"],
                          isMultichoiceAllowed: true,
                        );
                        setState(() {
                          _load();
                        });
                      },
                      onDelete: (dynamic pk, dynamic data, int index) async {
                        await networking_api_service.removeLabelGroup(
                            labelGroupId: pk);
                        setState(() {
                          _load();
                        });
                      },
                      onView: (dynamic pk, dynamic data, int index) {
                        widget.controller.labelGroupId = pk;
                        widget.onUpdate();
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: StorybridgeTextP(
                          "*Special custom list, owned by system."),
                    )
                  ],
                ),
              );
            } else {
              return const StorybridgePageLoading();
            }
          }),
      Container(),
    ]);
  }
}

// myPage class which creates a state on call
class _OrganizationAuditingLabelsPage extends StatefulWidget {
  final _OrganizationAuditingAllLabelsController controller;
  final Function() onUpdate;
  const _OrganizationAuditingLabelsPage({
    Key? key,
    required this.controller,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _OrganizationAuditingLabelsPageState createState() =>
      _OrganizationAuditingLabelsPageState();
}

// myPage state
class _OrganizationAuditingLabelsPageState
    extends State<_OrganizationAuditingLabelsPage> {
  String _labelGroupName = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<dynamic>> _load() async {
    Map<String, dynamic> response = await networking_api_service.getLabels(
        labelGroupId: widget.controller.labelGroupId!);
    Map<String, dynamic> responseLabelGroup = await networking_api_service
        .getLabelGroup(labelGroupId: widget.controller.labelGroupId!);
    _labelGroupName = responseLabelGroup["data"][0]["labelGroupName"];

    return response["data"];
  }

  Future<void> _createLabel() async {
    await networking_api_service.createLabel(
        color: "FFFFFF",
        labelName: "New option",
        labelDescription: "",
        labelGroupId: widget.controller.labelGroupId!);
    setState(() {});
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 20),
      FutureBuilder(
          future: _load(),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.hasData) {
              return StorybridgeHolder(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 20),
                        StorybridgeTextH2(Uri.decodeComponent(_labelGroupName)),
                        Expanded(child: Container()),
                        StorybridgeButton(
                            icon: Icons.add_rounded,
                            text: "New",
                            invertedColor: true,
                            verticalOnlyPadding: true,
                            onPressed: () async {
                              await _createLabel();
                            }),
                      ],
                    ),
                    const SizedBox(height: 8),
                    StorybridgeTable(
                      data: snapshot.data!,
                      advancedHeaders: [
                        StorybridgeTableHeader(
                            key: "preview",
                            label: "Data type",
                            type: StorybridgeTableHeaderType.label),
                        StorybridgeTableHeader(
                          key: "labelDescription",
                          label: "Description",
                          width: 300,
                        ),
                      ],
                      onView: (dynamic pk, dynamic data, int index) async {
                        storybridgeShowDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              StorybridgeAlertDialogWrapper(
                            child: StorybridgeAlertDialog(
                              content: _LabelEditorPopup(
                                data: data,
                                onSaved: () {
                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                        );
                      },
                      onDelete: (dynamic pk, dynamic data, int index) async {
                        await networking_api_service.removeLabel(labelId: pk);
                        setState(() {
                          _load();
                        });
                      },
                    )
                  ],
                ),
              );
            } else {
              return const StorybridgePageLoading();
            }
          }),
      Container(),
    ]);
  }
}

class _LabelEditorPopup extends StatefulWidget {
  final dynamic data;
  final void Function() onSaved;

  // constructor
  _LabelEditorPopup({
    required this.data,
    required this.onSaved,
    Key? key,
  }) : super(key: key);

  @override
  State<_LabelEditorPopup> createState() => _LabelEditorPopupState();
}

class _LabelEditorPopupState extends State<_LabelEditorPopup> {
  StorybridgeTextFieldController labelName = StorybridgeTextFieldController();
  StorybridgeTextFieldController labelDescription =
      StorybridgeTextFieldController();
  StorybridgeTextFieldController labelColor = StorybridgeTextFieldController();
  @override
  void initState() {
    super.initState();
    labelName.text = Uri.decodeComponent(widget.data["labelName"]);
    labelDescription.text =
        Uri.decodeComponent(widget.data["labelDescription"]);
    labelColor.text = Uri.decodeComponent(widget.data["color"]);
  }

  void _save() async {
    await networking_api_service.changeLabel(
        labelId: widget.data["labelId"],
        color: labelColor.text,
        labelName: labelName.text,
        labelDescription: labelDescription.text);
    widget.onSaved();
    Navigator.pop(context);
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
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
          const StorybridgeTextH2B("Edit data type"),
          const SizedBox(height: 10),
          StorybridgeTextField(
            label: "Data type name",
            controller: labelName,
          ),
          StorybridgeColorPicker(controller: labelColor),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: StorybridgeTextField(
              isLarge: true,
              label: "Description",
              controller: labelDescription,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              StorybridgeButton(
                padding: false,
                text: "Save",
                invertedColor: true,
                onPressed: () {
                  _save();
                },
              ),
              const SizedBox(width: 10),
              StorybridgeButton(
                padding: false,
                text: "Cancel",
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          )
        ],
      ),
    );
  }
}

class _OrganizationAuditingDashboardPage extends StatefulWidget {
  final int organizationId;
  const _OrganizationAuditingDashboardPage(
      {Key? key, required this.organizationId})
      : super(key: key);

  @override
  _OrganizationAuditingDashboardPageState createState() =>
      _OrganizationAuditingDashboardPageState();
}

// myPage state
class _OrganizationAuditingDashboardPageState
    extends State<_OrganizationAuditingDashboardPage> {
  final Map<String, int> _auditTemplateNamesToAuditTemplateId = {};
  final StorybridgeTextFieldController _auditTemplateController =
      StorybridgeTextFieldController();
  int? _auditTemplateId;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _load() async {
    Map<String, dynamic> response = await networking_api_service
        .getAuditTemplates(organizationId: widget.organizationId);
    _auditTemplateNamesToAuditTemplateId.clear();
    for (int i = 0; i < response["data"].length; i++) {
      var obj = response["data"][i];
      _auditTemplateNamesToAuditTemplateId[
              Uri.decodeComponent(obj["auditTemplateName"])] =
          obj["auditTemplateId"];
    }
    if (_auditTemplateNamesToAuditTemplateId.isNotEmpty) {
      _auditTemplateId ??= _auditTemplateNamesToAuditTemplateId.values.first;
      _auditTemplateNamesToAuditTemplateId.forEach((key, value) {
        if (value == _auditTemplateId) {
          _auditTemplateController.text = key;
        }
      });
    }
    return response["data"];
  }

  Future<bool> _loadAuditTemplateData() async {
    return true;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return FutureBuilder(
        future: _load(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const StorybridgePageLoading();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const ProductAuditWidget(),
              const SizedBox(height: 20),
              /*
              StorybridgeDropdown(
                label: "Audit template",
                controller: _auditTemplateController,
                mappedDropdownTypes: _auditTemplateNamesToAuditTemplateId,
              ),
              */
              StorybridgeButton(
                icon: Icons.add_rounded,
                text: "New Graph",
                onPressed: () {},
              ),
              const SizedBox(height: 20),
              FutureBuilder(
                  future: _loadAuditTemplateData(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return const StorybridgePageLoading();
                    }
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        const StorybridgeLineChart(x: 2),
                        const StorybridgePieChart(x: 2),
                        const StorybridgeNumberChart(x: 2),
                        const StorybridgeNumberChart(x: 2),
                        const StorybridgePieChart(x: 2),
                        const StorybridgeNumberChart(x: 2),
                      ],
                    );
                  }),
            ],
          );
        });
  }
}
