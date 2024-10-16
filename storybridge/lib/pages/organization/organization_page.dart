import 'package:flutter/material.dart';
import 'package:mooc/storybridge.dart'; // Storybridge

import 'package:mooc/pages/organization/organization_people_page.dart';
import 'package:mooc/pages/organization/organization_course_page.dart';
import 'package:mooc/pages/organization/organization_sales_page.dart';
import 'package:mooc/pages/organization/organization_settings_page.dart';
import 'package:mooc/pages/organization/organization_auditing_page.dart';
import 'package:mooc/pages/organization/organization_fleet_page.dart';

import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/auth_service.dart' as auth_service;

// myPage class which creates a state on call
class OrganizationPage extends StatefulWidget {
  final int organizationId;
  final int startingTab;
  const OrganizationPage(
      {Key? key, required this.organizationId, required this.startingTab})
      : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<OrganizationPage> {
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
    auth_service.AuthUserData? authUserData =
        auth_service.globalUser.getAuthUserData();
    bool isAdmin = false;
    if (authUserData != null) {
      for (var organizationPrivilege
          in authUserData.organizationPrivilegeData) {
        if (organizationPrivilege["organizationId"] == widget.organizationId) {
          isAdmin = true;
        }
      }
    }
    if (!isAdmin) {
      return _OrganizationStudentPage(organizationId: widget.organizationId);
    } else {
      return _OrganizationAdminPage(
        organizationId: widget.organizationId,
        startingTab: widget.startingTab,
      );
    }
  }
}

class _OrganizationStudentPage extends StatelessWidget {
  final int organizationId;
  final List<Map<String, dynamic>> _courses = [];
  _OrganizationStudentPage({Key? key, required this.organizationId})
      : super(key: key);

  Future<String> _loadOrgName() async {
    Map<String, dynamic> response = await networking_api_service
        .getOrganization(organizationId: organizationId);
    return Uri.decodeComponent(response["data"]["organizationName"]);
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return StorybridgeScaffold(
      hasAppbar: false,
      body: [
        const SizedBox(height: 20),
        FutureBuilder(
            future: _loadOrgName(),
            builder: (context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return Row(
                  children: [
                    ProfilePictureWidget(organizationId: organizationId),
                    const SizedBox(width: 20),
                    StorybridgeTextH2B(snapshot.data ?? ""),
                  ],
                );
              } else {
                return const StorybridgeBoxLoading(height: 70, width: 300);
              }
            }),
        const SizedBox(height: 10),
      ],
      tabNames: [
        StorybridgeTabHeader(
            tabName: "Stories", tabIcon: Icons.collections_bookmark_rounded),
      ],
      tabs: [
        OrganizationCoursesStudentPage(
          courses: _courses,
          organizationId: organizationId,
        ),
      ],
    );
  }
}

// myPage class which creates a state on call
class _OrganizationAdminPage extends StatelessWidget {
  final int organizationId;
  final List<Map<String, dynamic>> _courses = [];
  final int startingTab;
  _OrganizationAdminPage(
      {Key? key, required this.organizationId, required this.startingTab})
      : super(key: key);

  Future<String> _loadOrgName() async {
    Map<String, dynamic> response = await networking_api_service
        .getOrganization(organizationId: organizationId);
    return Uri.decodeComponent(response["data"]["organizationName"]);
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return StorybridgeScaffold(
      startingTab: startingTab,
      hasAppbar: false,
      tabSuffix: Row(
        children: [
          Expanded(child: Container()),
          const Padding(
            padding: EdgeInsets.only(right: 20),
            child: StorybridgeAccountIndicator(organizationId: 0),
          ),
        ],
      ),
      body: [
        const SizedBox(height: 20),
        FutureBuilder(
            future: _loadOrgName(),
            builder: (context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return Row(
                  children: [
                    ProfilePictureWidget(organizationId: organizationId),
                    const SizedBox(width: 20),
                    StorybridgeTextH2B(snapshot.data ?? ""),
                  ],
                );
              } else {
                return const StorybridgeBoxLoading(height: 70, width: 300);
              }
            }),
        const SizedBox(height: 10),
      ],
      tabNames: [
        StorybridgeTabHeader(
            tabName: "Stories", tabIcon: Icons.collections_bookmark_rounded),
        StorybridgeTabHeader(
            tabName: "Sales", tabIcon: Icons.stacked_line_chart_rounded),
        StorybridgeTabHeader(
            tabName: "Settings", tabIcon: Icons.stacked_line_chart_rounded),
        /*
        StorybridgeTabHeaders(
            tabName: "Design", tabIcon: Icons.stacked_line_chart_rounded),
        StorybridgeTabHeaders(tabName: "Analytics", tabIcon: Icons.groups),
        StorybridgeTabHeaders(
            tabName: "Settings", tabIcon: Icons.stacked_line_chart_rounded),
            */
      ],
      tabs: [
        OrganizationCoursesAdminPage(
          courses: _courses,
          organizationId: organizationId,
        ),
        OrganizationSalesPage(organizationId: organizationId),
        OrganizationSettingsPage(organizationId: organizationId),
      ],
    );
  }
}
