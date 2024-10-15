import 'package:flutter/material.dart';
import 'package:mooc/services/auth_service.dart' as auth_service;
import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;

void sendToOrgPage(BuildContext context, {int? organizationId}) async {
  // if organizationId not given, user wants to find first organization
  if (organizationId == null) {
    // check if user is initially assigned to organization (has orgId already)
    bool isUserInitiallyAssignedToOrg = false;
    auth_service.AuthUserData? userData =
        auth_service.globalUser.getAuthUserData();
    if (userData != null) {
      isUserInitiallyAssignedToOrg = userData.organizationId != 0;
    }

    if (isUserInitiallyAssignedToOrg) {
      // if user is initally assigned, then go to that organization
      organizationId = userData!.organizationId;
      return;
    } else {
      // find first organizationId, if user has no organization, then go to register
      Map<String, dynamic> response =
          await networking_api_service.getOrganizations();
      // bring to create a new organization
      if (response["data"].length == 0) {
        // user does not have any organizations
        Map<String, dynamic> data = await networking_api_service
            .createOrganization(organizationName: "Untitled Organization");

        await auth_service.globalUser.tryLogin();
        organizationId = data["organizationId"];
      } else {
        organizationId = response["data"][0]["organizationId"];
      }
    }
  }

  Navigator.of(context).pushNamed("/organization?id=$organizationId");
}

void sendToCoursePage(BuildContext context,
    {int? courseId, int? organizationId, bool isAdminMode = true}) async {
  // if courseId not given, user wants to create a new course
  courseId ??= await networking_api_service.createCourse(
      organizationId: organizationId!);

  // create new course
  String courseQuery = "course?id=$courseId";
  String adminQuery = isAdminMode ? "&admin" : "";
  Navigator.of(context).pushNamed("/$courseQuery$adminQuery");
}
