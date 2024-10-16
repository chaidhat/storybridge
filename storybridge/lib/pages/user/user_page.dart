import 'package:mooc/pages/user/user_audit_page.dart';
import 'package:mooc/pages/user/user_files_page.dart';
import 'package:mooc/pages/user/user_fleet_page.dart';
import 'package:mooc/pages/user/user_settings_page.dart';
import 'package:mooc/pages/user/user_support_page.dart';

import 'package:flutter/material.dart';
import 'package:mooc/storybridge.dart'; // Storybridge

import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/auth_service.dart' as auth_service;

import 'user_courses_page.dart';

// myPage class which creates a state on call
class UserPage extends StatefulWidget {
  final int userId;
  final bool isForceAdmin;
  final int startingTab;
  const UserPage({
    Key? key,
    required this.userId,
    required this.isForceAdmin,
    this.startingTab = 0,
  }) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

// myPage state
class _UserPageState extends State<UserPage> {
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
    auth_service.AuthUserData? authUserData =
        auth_service.globalUser.getAuthUserData();
    bool isUserViewer = true;

    if (authUserData != null) {
      isUserViewer = authUserData.userId != widget.userId;
    }

    if (isUserViewer && !widget.isForceAdmin) {
      // ignore: unused_local_variable
      return _UserViewerPage(userId: widget.userId);
    } else {
      return _UserOwnerPage(
        userId: widget.userId,
        startingTab: widget.startingTab,
      );
      // ignore: unused_local_variable
    }
  }
}

// myPage class which creates a state on call
class _UserViewerPage extends StatefulWidget {
  final int userId;
  const _UserViewerPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserViewerPageState createState() => _UserViewerPageState();
}

// myPage state
class _UserViewerPageState extends State<_UserViewerPage> {
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
    return StorybridgeScaffold(
      hasAppbar: false,
      body: [],
      tabNames: [
        StorybridgeTabHeader(
            tabName: "Profile", tabIcon: Icons.stacked_line_chart_rounded),
      ],
      tabs: [
        UserSettingsPage(userId: widget.userId, isOwner: false),
      ],
    );
  }
}

// myPage class which creates a state on call
class _UserOwnerPage extends StatefulWidget {
  final int userId;
  final int startingTab;
  const _UserOwnerPage(
      {Key? key, required this.userId, required this.startingTab})
      : super(key: key);

  @override
  _UserOwnerPageState createState() => _UserOwnerPageState();
}

// myPage state
class _UserOwnerPageState extends State<_UserOwnerPage> {
  StorybridgeTabHeader myFleetTab = StorybridgeTabHeader(
      tabIcon: Icons.abc, tabName: "Flight plan", isVisible: false);
  @override
  void initState() {
    super.initState();
    getFleetDriverStatus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  int getOrganizationId() {
    auth_service.AuthUserData? authUserData =
        auth_service.globalUser.getAuthUserData();
    int organizationId = authUserData!.organizationId;
    if (organizationId == 0) {
      List<dynamic> organizationPriv = authUserData.organizationPrivilegeData;
      organizationId = organizationPriv[0]["organizationId"];
    }
    return organizationId;
  }

  void getFleetDriverStatus() async {
    Map<String, dynamic> response = await networking_api_service
        .isUserFleetDriver(organizationId: getOrganizationId());
    if (response["data"]) {
      myFleetTab.isVisible = true;
      myFleetTab.onUpdate!();
    }
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgeScaffold(
        startingTab: widget.startingTab,
        hasAppbar: false,
        body: [],
        tabPrefix: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: OrganizationName(
            organizationId: getOrganizationId(),
            isAdminMode: true,
          ),
        ),
        tabSuffix: Row(
          children: [
            Expanded(child: Container()),
            StorybridgeAccountIndicator(organizationId: getOrganizationId()),
          ],
        ),
        tabs: [
          UserSettingsPage(
            userId: widget.userId,
            isOwner: true,
          ),
          UserFleetPage(
              userId: widget.userId, organizationId: getOrganizationId()),
          UserCoursesPage(userId: widget.userId),
          UserAuditsPage(userId: widget.userId),
          UserFilesPage(userId: widget.userId),
          UserSupportPage(userId: widget.userId),
        ],
        tabNames: [
          StorybridgeTabHeader(
              tabName: "Profile", tabIcon: Icons.stacked_line_chart_rounded),
          myFleetTab,
          StorybridgeTabHeader(
              tabName: "My courses", tabIcon: Icons.stacked_line_chart_rounded),
          StorybridgeTabHeader(
              tabName: "My audits", tabIcon: Icons.stacked_line_chart_rounded),
          StorybridgeTabHeader(
              tabName: "My files", tabIcon: Icons.stacked_line_chart_rounded),
          StorybridgeTabHeader(
              tabName: "Support", tabIcon: Icons.stacked_line_chart_rounded),
        ]);
  }
}

class OrganizationName extends StatefulWidget {
  final int organizationId;
  final bool isAdminMode;
  const OrganizationName({
    Key? key,
    required this.organizationId,
    required this.isAdminMode,
  }) : super(key: key);

  @override
  _OrganizationNameState createState() => _OrganizationNameState();
}

class _OrganizationNameState extends State<OrganizationName> {
  String _organizationName = "";
  ProfilePictureController profilePictureController =
      ProfilePictureController();

  Future<bool> loadCourseName() async {
    Map<String, dynamic> organization = await networking_api_service
        .getOrganization(organizationId: widget.organizationId);
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
            if (_organizationName.length > 35) {
              courseNameTextFontSize = storybridgeTextH2BStyle.fontSize! - 2;
            } else if (_organizationName.length < 20) {
              courseNameTextFontSize = storybridgeTextH2BStyle.fontSize! + 4;
            } else {
              courseNameTextFontSize = storybridgeTextH2BStyle.fontSize!;
            }
            TextStyle courseNameStyle = TextStyle(
                color: storybridgeTextH2BStyle.color,
                fontWeight: storybridgeTextH2BStyle.fontWeight,
                fontSize: courseNameTextFontSize);

            return IntrinsicWidth(
              child: Row(
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onTap: () {
                      Navigator.pushNamed(
                          context, "/organization?id=${widget.organizationId}");
                    },
                    child: Row(
                      children: [
                        SizedBox(
                            height: 50,
                            child: ProfilePictureWidget(
                              controller: profilePictureController,
                              organizationId: widget.organizationId,
                              child: Builder(builder: (context) {
                                if (!profilePictureController.hasPicture) {
                                  return StorybridgeTextBasic(_organizationName,
                                      style: courseNameStyle);
                                } else {
                                  return Container();
                                }
                              }),
                            )),
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
