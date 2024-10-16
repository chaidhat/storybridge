import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;

// myPage class which creates a state on call
class OrganizationPeoplePage extends StatefulWidget {
  final int organizationId;
  const OrganizationPeoplePage({Key? key, required this.organizationId})
      : super(key: key);

  @override
  _OrganizationPeoplePageState createState() => _OrganizationPeoplePageState();
}

// myPage state
class _OrganizationPeoplePageState extends State<OrganizationPeoplePage> {
  final ScholarityTabPageController _tabPageController =
      ScholarityTabPageController();
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
    return ScholarityTabPage(
        tabPageController: _tabPageController,
        hasVeryReducedPadding: true,
        sideBar: [
          const SizedBox(height: 80),
          ScholaritySideBarButton(
              label: "Users",
              icon: Icons.people_outlined,
              onPressed: () {
                // hide mobile sidebar
                _tabPageController.mobileShowSidebar = false;
                _tabPageController.update();

                setState(() {
                  _selectedPage = 0;
                });
              },
              selected: _selectedPage == 0),
          ScholaritySideBarButton(
              label: "Teachers",
              icon: Icons.school_outlined,
              onPressed: () {
                // hide mobile sidebar
                _tabPageController.mobileShowSidebar = false;
                _tabPageController.update();

                setState(() {
                  _selectedPage = 1;
                });
              },
              selected: _selectedPage == 1),
          const ScholarityDivider(),
          ScholaritySideBarButton(
              label: "Coordinator Groups",
              icon: Icons.workspaces_rounded,
              onPressed: () {
                // hide mobile sidebar
                _tabPageController.mobileShowSidebar = false;
                _tabPageController.update();

                setState(() {
                  _selectedPage = 2;
                });
              },
              selected: _selectedPage == 2),
          ScholaritySideBarButton(
              label: "Coordinators",
              icon: Icons.workspaces_outline,
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
          const SizedBox(height: 40),
          Builder(builder: (context) {
            switch (_selectedPage) {
              case 0:
                return _OrganizationPeopleStudentPage(
                  organizationId: widget.organizationId,
                );
              case 1:
                return _OrganizationPeopleTeacherPage(
                  organizationId: widget.organizationId,
                );
              case 2:
                return _OrganizationPeopleCoordinatorGroupPage(
                  organizationId: widget.organizationId,
                );
              case 3:
              default:
                return _OrganizationPeopleCoordinatorPage(
                  organizationId: widget.organizationId,
                );
            }
          })
        ]);
  }
}

// myPage class which creates a state on call
class _OrganizationPeopleStudentPage extends StatefulWidget {
  final int organizationId;
  const _OrganizationPeopleStudentPage({Key? key, required this.organizationId})
      : super(key: key);

  @override
  _OrganizationPeopleStudentPageState createState() =>
      _OrganizationPeopleStudentPageState();
}

// myPage state
class _OrganizationPeopleStudentPageState
    extends State<_OrganizationPeopleStudentPage> {
  Map<String, dynamic> _extraUserDataFields = {};
  List<String> _extraUserDataFieldHeaders = [];
  Future<dynamic> _getExtraUserDataFields() async {
    Map<String, dynamic> response2 = await networking_api_service
        .getOrganization(organizationId: widget.organizationId);

    var extraUserDataFieldsJson = response2["data"]["extraUserDataFields"];
    try {
      _extraUserDataFields =
          jsonDecode(Uri.decodeComponent(extraUserDataFieldsJson));
    } catch (e) {
      _extraUserDataFields = {"data": []};
    }
    _extraUserDataFieldHeaders.clear();
    for (var extraUserDataField in _extraUserDataFields["data"]) {
      _extraUserDataFieldHeaders.add(extraUserDataField["fieldName"]);
    }
  }

  Future<dynamic> _load() async {
    Map<String, dynamic> response = await networking_api_service
        .getUserFromOrganizationId(organizationId: widget.organizationId);
    await _getExtraUserDataFields();
    return response["data"];
  }

  Future<dynamic> _editStudentFields() async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) =>
          _OrganizationPagePeopleStudentFieldsPopup(
        organizationId: widget.organizationId,
        data: _extraUserDataFields,
      ),
    );
    await _getExtraUserDataFields();
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
    return FutureBuilder(
        future: _load(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            List<ScholarityTableHeader> headers = [
              ScholarityTableHeader(key: "email", label: "Email", width: 300),
              ScholarityTableHeader(key: "firstName", label: "First name"),
              ScholarityTableHeader(key: "lastName", label: "Last name"),
              ScholarityTableHeader(
                  key: "coordinatorGrouoName", label: "Group"),
            ];
            for (String v in _extraUserDataFieldHeaders) {
              String label = v;
              if (v == "jobTitle") {
                label = "job title";
              } else if (v == "employeeId") {
                label = "employee id";
              }
              headers.add(ScholarityTableHeader(key: v, label: label));
            }
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(),
                    ),
                    ScholarityButton(
                      icon: Icons.edit_rounded,
                      text: "Edit student fields",
                      onPressed: () {
                        _editStudentFields();
                      },
                    ),
                    OrganizationAuthShareWidget(
                      organizationId: widget.organizationId,
                    ),
                    /*
                    ScholarityButton(
                      invertedColor: true,
                      icon: Icons.add,
                      text: "Pre-Register Students",
                      onPressed: () {},
                    ),
                    */
                  ],
                ),
                ScholarityTable(
                  data: snapshot.data,
                  advancedHeaders: headers,
                  onView: (dynamic pk, dynamic data, int index) {
                    Navigator.pushNamed(context, '/user?id=${data["userId"]}');
                  },
                  extraButtons: [
                    ScholarityTableButton(
                        buttonText: "Edit",
                        onPressed: (dynamic pk, dynamic data) {
                          Navigator.pushNamed(context,
                              '/user/profile?id=${data["userId"]}&admin');
                        })
                  ],
                ),
              ],
            );
          } else {
            return const ScholarityPageLoading();
          }
        });
  }
}

class _OrganizationPeopleTeacherPage extends StatefulWidget {
  final int organizationId;
  const _OrganizationPeopleTeacherPage({Key? key, required this.organizationId})
      : super(key: key);

  @override
  _OrganizationPeopleTeacherPageState createState() =>
      _OrganizationPeopleTeacherPageState();
}

class _OrganizationPeopleTeacherPageState
    extends State<_OrganizationPeopleTeacherPage> {
  Future<dynamic> _load() async {
    Map<String, dynamic> response =
        await networking_api_service.getOrganizationPrivilegesForOrganization(
            organizationId: widget.organizationId);
    return response["data"];
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
    return FutureBuilder(
        future: _load(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: ScholarityTable(
                data: snapshot.data,
                advancedHeaders: [
                  ScholarityTableHeader(
                      key: "email", label: "Email", width: 300),
                  ScholarityTableHeader(key: "firstName", label: "First name"),
                  ScholarityTableHeader(key: "lastName", label: "Last name"),
                  ScholarityTableHeader(
                      key: "canAnalyzeAll",
                      label: "Can analyze?",
                      type: ScholarityTableHeaderType.boolean,
                      width: 80),
                  ScholarityTableHeader(
                      key: "canEditAll",
                      label: "Can edit?",
                      type: ScholarityTableHeaderType.boolean,
                      width: 80),
                  ScholarityTableHeader(
                      key: "canTeachAll",
                      label: "Can teach?",
                      type: ScholarityTableHeaderType.boolean,
                      width: 80),
                  ScholarityTableHeader(
                      key: "isAdmin",
                      label: "Is admin?",
                      type: ScholarityTableHeaderType.boolean,
                      width: 80),
                  ScholarityTableHeader(
                      key: "isOwner",
                      label: "Is owner?",
                      type: ScholarityTableHeaderType.boolean,
                      width: 80),
                ],
              ),
            );
          } else {
            return const ScholarityPageLoading();
          }
        });
  }
}

class _OrganizationPeopleCoordinatorGroupPage extends StatefulWidget {
  final int organizationId;
  const _OrganizationPeopleCoordinatorGroupPage(
      {Key? key, required this.organizationId})
      : super(key: key);

  @override
  _OrganizationPeopleCoordinatorGroupPageState createState() =>
      _OrganizationPeopleCoordinatorGroupPageState();
}

class _OrganizationPeopleCoordinatorGroupPageState
    extends State<_OrganizationPeopleCoordinatorGroupPage> {
  Future<dynamic> _load() async {
    Map<String, dynamic> response = await networking_api_service
        .getCoordinatorGroups(organizationId: widget.organizationId);
    return response["data"];
  }

  Future<dynamic> _createCoordinatorGroup() async {
    Map<String, dynamic> response =
        await networking_api_service.createCoordinatorGroup(
            organizationId: widget.organizationId,
            email: "",
            coordinatorGroupName: "Untitled Coordinator Group");
    setState(() {});
    return response["data"];
  }

  Future<dynamic> _changeCoordinatorGroup(int pk, dynamic data) async {
    Map<String, dynamic> response =
        await networking_api_service.changeCoordinatorGroup(
      coordinatorGroupId: data["coordinatorGroupId"],
      coordinatorGroupName: data["coordinatorGroupName"],
      email: data["notificationEmail"],
    );
    setState(() {});
    return response["data"];
  }

  Future<dynamic> _removeCoordinatorGroup(int pk) async {
    Map<String, dynamic> response = await networking_api_service
        .removeCoordinatorGroup(coordinatorGroupId: pk);
    setState(() {});
    return response["data"];
  }

  void _openStudentsForCoordinatorGroup(int coordinatorGroupId, dynamic data) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) =>
            _OrganizationPeopleCoordinatorGroupsStudentPopup(
              coordinatorGroupId: data["coordinatorGroupId"],
              organizationId: widget.organizationId,
              coordinatorGroupName: data["coordinatorGroupName"],
            ));
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
    return FutureBuilder(
        future: _load(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(),
                    ),
                    ScholarityButton(
                      invertedColor: true,
                      icon: Icons.add,
                      text: "Add Coordinator Group",
                      onPressed: () async {
                        await _createCoordinatorGroup();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ScholarityTable(
                    data: snapshot.data,
                    advancedHeaders: [
                      ScholarityTableHeader(
                          key: "coordinatorGroupName", label: "Group name"),
                      ScholarityTableHeader(
                          key: "notificationEmail", label: "Email"),
                    ],
                    onView: (var pk, dynamic data, int i) {
                      _openStudentsForCoordinatorGroup(pk, data);
                    },
                    onEdit: (var pk, dynamic data, int i) {
                      _changeCoordinatorGroup(pk, data);
                    },
                    onDelete: (var pk, dynamic data, int i) {
                      _removeCoordinatorGroup(pk);
                    },
                  ),
                ),
              ],
            );
          } else {
            return const ScholarityPageLoading();
          }
        });
  }
}

class _OrganizationPeopleCoordinatorPage extends StatefulWidget {
  final int organizationId;
  const _OrganizationPeopleCoordinatorPage(
      {Key? key, required this.organizationId})
      : super(key: key);

  @override
  _OrganizationPeopleCoordinatorPageState createState() =>
      _OrganizationPeopleCoordinatorPageState();
}

class _OrganizationPeopleCoordinatorPageState
    extends State<_OrganizationPeopleCoordinatorPage> {
  final List<String> _coordinatorGroups = [];
  final Map<String, int> _coordinatorGroupsToId = {};
  final List<String> _users = [];
  final Map<String, int> _userToId = {};
  Future<dynamic> _load() async {
    _coordinatorGroups.clear();
    _users.clear();
    _coordinatorGroupsToId.clear();
    _userToId.clear();
    Map<String, dynamic> responseCoordGroups = await networking_api_service
        .getCoordinatorGroups(organizationId: widget.organizationId);
    for (var group in responseCoordGroups["data"]) {
      String key =
          "${group["coordinatorGroupId"]} - ${Uri.decodeComponent(group["coordinatorGroupName"])}";
      _coordinatorGroups.add(key);
      _coordinatorGroupsToId[key] = group["coordinatorGroupId"];
    }
    Map<String, dynamic> responseUsers = await networking_api_service
        .getUserFromOrganizationId(organizationId: widget.organizationId);
    for (var user in responseUsers["data"]) {
      String key = Uri.decodeComponent(
          "${user["email"]} - ${user["firstName"]} ${user["lastName"]}");
      _users.add(key);
      _userToId[key] = user["userId"];
    }

    Map<String, dynamic> response = await networking_api_service
        .getCoordinatorPrivileges(organizationId: widget.organizationId);
    return response["data"];
  }

  Future<dynamic> _assignCoordinator() async {
    ScholarityTextFieldController coordinatorGroupController =
        ScholarityTextFieldController();
    ScholarityTextFieldController userController =
        ScholarityTextFieldController();
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => ScholarityAlertDialogWrapper(
                child: ScholarityAlertDialog(
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const ScholarityTextH2B(
                          "Assign Coordinator to Coordinator Group"),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 300,
                        child: ScholarityDropdown(
                            label: "Coordinator",
                            controller: userController,
                            dropdownTypes: _users),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 300,
                        child: ScholarityDropdown(
                            label: "Coordinator Group",
                            controller: coordinatorGroupController,
                            dropdownTypes: _coordinatorGroups),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          ScholarityButton(
                            padding: false,
                            text: "Assign",
                            invertedColor: true,
                            onPressed: () async {
                              int? userId = _userToId[userController.text];
                              int? coordinateGroupId = _coordinatorGroupsToId[
                                  coordinatorGroupController.text];

                              if (userId == null || coordinateGroupId == null) {
                                return;
                              }

                              await networking_api_service
                                  .assignCoordinatorToCoordinatorGroup(
                                userId: userId,
                                coordinatorGroupId: coordinateGroupId,
                              );
                              setState(() {});
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(width: 10),
                          ScholarityButton(
                              padding: false,
                              text: "Cancel",
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )));
    setState(() {});
  }

  Future<dynamic> _deassignCoordinator(int pk, dynamic data) async {
    Map<String, dynamic> response =
        await networking_api_service.deassignCoordinatorFromCoordinatorGroup(
            userId: data["userId"],
            coordinatorGroupId: data["coordinatorGroupId"]);
    setState(() {});
    return response["data"];
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
    return FutureBuilder(
        future: _load(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(),
                    ),
                    ScholarityButton(
                      invertedColor: true,
                      icon: Icons.sync_alt_rounded,
                      text: "Assign Coordinators",
                      onPressed: () async {
                        await _assignCoordinator();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ScholarityTable(
                    data: snapshot.data,
                    onDelete: (var pk, dynamic data, int i) {
                      _deassignCoordinator(pk, data);
                    },
                    advancedHeaders: [
                      ScholarityTableHeader(
                          key: "coordinatorGroupName", label: "Group name"),
                      ScholarityTableHeader(key: "email", label: "Email"),
                      ScholarityTableHeader(
                          key: "firstName", label: "First name"),
                      ScholarityTableHeader(
                          key: "lastName", label: "Last name"),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const ScholarityPageLoading();
          }
        });
  }
}

class _OrganizationPeopleCoordinatorGroupsStudentPopup extends StatefulWidget {
  // members of MyWidget
  final int coordinatorGroupId;
  final int organizationId;
  final String coordinatorGroupName;
  const _OrganizationPeopleCoordinatorGroupsStudentPopup(
      {Key? key,
      required this.coordinatorGroupId,
      required this.organizationId,
      required this.coordinatorGroupName})
      : super(key: key);

  @override
  State<_OrganizationPeopleCoordinatorGroupsStudentPopup> createState() =>
      _OrganizationPeopleCoordinatorGroupsStudentPopupState();
}

class _OrganizationPeopleCoordinatorGroupsStudentPopupState
    extends State<_OrganizationPeopleCoordinatorGroupsStudentPopup> {
  final List<String> _users = [];

  final Map<String, int> _userToId = {};

  Future<dynamic> _load() async {
    Map<String, dynamic> response =
        await networking_api_service.getUserFromCoordinatorGroupId(
            coordinatorGroupId: widget.coordinatorGroupId);
    Map<String, dynamic> responseUsers = await networking_api_service
        .getUserFromOrganizationId(organizationId: widget.organizationId);
    for (var user in responseUsers["data"]) {
      String key = Uri.decodeComponent(
          "${user["email"]} - ${user["firstName"]} ${user["lastName"]}");
      _users.add(key);
      _userToId[key] = user["userId"];
    }
    return response["data"];
  }

  Future<dynamic> _assignUser() async {
    ScholarityTextFieldController userController =
        ScholarityTextFieldController();
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => ScholarityAlertDialogWrapper(
                child: ScholarityAlertDialog(
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      ScholarityTextH2B(
                          "Assign student to ${Uri.decodeComponent(widget.coordinatorGroupName)}"),
                      const SizedBox(height: 20),
                      ScholarityDropdown(
                        label: "Email",
                        dropdownTypes: _users,
                        controller: userController,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          ScholarityButton(
                            padding: false,
                            text: "Save",
                            invertedColor: true,
                            onPressed: () async {
                              int? userId = _userToId[userController.text];
                              if (userId == null) {
                                return;
                              }
                              await networking_api_service
                                  .assignUserToCoordinatorGroup(
                                      userId: userId,
                                      coordinatorGroupId:
                                          widget.coordinatorGroupId);
                              setState(() {});
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(width: 10),
                          ScholarityButton(
                              padding: false,
                              text: "Cancel",
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )));
    return;
  }

  Future<dynamic> _deassignUser(int userId) async {
    await networking_api_service.deassignUserFromCoordinatorGroup(
        userId: userId);
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return ScholarityAlertDialogWrapper(
        child: ScholarityAlertDialog(
      content: SingleChildScrollView(
        child: SizedBox(
          width: 800,
          child: FutureBuilder(
              future: _load(),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (!snapshot.hasData) {
                  return const ScholarityBoxLoading(height: 50, width: 200);
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScholarityIconButton(
                        icon: Icons.close,
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ScholarityTextH2B(
                            "Students For ${Uri.decodeComponent(widget.coordinatorGroupName)}"),
                        Expanded(child: Container()),
                        ScholarityButton(
                          text: "Assign User",
                          icon: Icons.sync_alt_rounded,
                          invertedColor: true,
                          onPressed: () async {
                            await _assignUser();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ScholarityTable(
                        data: snapshot.data,
                        advancedHeaders: [
                          ScholarityTableHeader(key: "email", label: "Email"),
                          ScholarityTableHeader(key: "email", label: "Email"),
                          ScholarityTableHeader(
                              key: "firstName", label: "First name"),
                          ScholarityTableHeader(
                              key: "lastName", label: "Last name"),
                        ],
                        onDelete: (var pk, dynamic va, int i) {
                          setState(() {
                            _deassignUser(va["userId"]);
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }),
        ),
      ),
    ));
  }
}

class _OrganizationPagePeopleStudentFieldsPopup extends StatefulWidget {
  final int organizationId;
  final Map<String, dynamic> data;
  const _OrganizationPagePeopleStudentFieldsPopup(
      {Key? key, required this.organizationId, required this.data})
      : super(key: key);

  @override
  _OrganizationPagePeopleStudentFieldsPopupState createState() =>
      _OrganizationPagePeopleStudentFieldsPopupState();
}

// myPage state
class _OrganizationPagePeopleStudentFieldsPopupState
    extends State<_OrganizationPagePeopleStudentFieldsPopup> {
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
    return ScholarityAlertDialogWrapper(
        child: ScholarityAlertDialog(
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const ScholarityTextH2B("Edit Student Fields"),
              Row(
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  ScholarityButton(
                    icon: Icons.add,
                    invertedColor: true,
                    text: "Add Student Fields",
                    onPressed: () {
                      setState(() {
                        widget.data["data"].add({
                          "fieldName": "",
                          "fieldType": "",
                        });
                      });
                    },
                  ),
                ],
              ),
              ScholarityTable(
                onEdit: (var pk, var data, int i) {
                  setState(() {
                    widget.data["data"][i]["fieldName"] = data["fieldName"];
                    widget.data["data"][i]["fieldType"] = data["fieldType"];
                  });
                },
                onDelete: (var pk, var data, int i) {
                  setState(() {
                    widget.data["data"].removeAt(i);
                  });
                },
                advancedHeaders: [
                  ScholarityTableHeader(key: "fieldName", label: "Field name"),
                  ScholarityTableHeader(
                    key: "fieldType",
                    label: "Field type",
                    type: ScholarityTableHeaderType.dropdown,
                    dropdownList: ["Text", "External Certificate"],
                  ),
                ],
                data: widget.data["data"],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ScholarityButton(
                    padding: false,
                    text: "Save",
                    invertedColor: true,
                    onPressed: () async {
                      await networking_api_service
                          .setOrganizationExtraUserDataFields(
                              organizationId: widget.organizationId,
                              eudFields: jsonEncode(widget.data));
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 10),
                  ScholarityButton(
                      padding: false,
                      text: "Cancel",
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
