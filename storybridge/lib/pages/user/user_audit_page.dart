import 'package:flutter/material.dart';
import 'package:mooc/pages/organization/organization_auditing_page.dart';
import 'package:mooc/storybridge.dart'; // Storybridge

import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/auth_service.dart' as auth_service;

// myPage class which creates a state on call
class UserAuditsPage extends StatefulWidget {
  final int userId;
  const UserAuditsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserAuditsPageState createState() => _UserAuditsPageState();
}

// myPage state
class _UserAuditsPageState extends State<UserAuditsPage> {
  late int _organizationId;
  Future<dynamic> _load() async {
    auth_service.AuthUserData? authUserData =
        auth_service.globalUser.getAuthUserData();
    _organizationId = authUserData!.organizationId;
    if (_organizationId == 0) {
      List<dynamic> organizationPriv = authUserData.organizationPrivilegeData;
      _organizationId = organizationPriv[0]["organizationId"];
    }

    Map<String, dynamic> response = await networking_api_service
        .getAuditPrivilegesForUserId(userId: widget.userId);
    return response["data"];
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

  Future<void> _createAuditTask() async {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AuditTaskNewPopup(
              organizationId: _organizationId,
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
    return StorybridgeTabPage(hasVeryReducedPadding: true, body: [
      const SizedBox(height: 50),
      FutureBuilder(
          future: _load(),
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  const SizedBox(height: 20),
                  StorybridgeButton(
                      text: "New",
                      invertedColor: true,
                      verticalOnlyPadding: true,
                      onPressed: () async {
                        await _createAuditTask();
                      }),
                  Center(
                    child: StorybridgeTable(
                      advancedHeaders: [
                        StorybridgeTableHeader(
                            key: "auditTaskId", label: "ID", width: 80),
                        StorybridgeTableHeader(
                            key: "auditTemplateName",
                            label: "Template name",
                            width: 300),
                        StorybridgeTableHeader(
                          key: "canEdit",
                          label: "Can edit?",
                          type: StorybridgeTableHeaderType.boolean,
                        ),
                        StorybridgeTableHeader(
                          key: "canComment",
                          label: "Can comment?",
                          type: StorybridgeTableHeaderType.boolean,
                        ),
                        StorybridgeTableHeader(
                          key: "isOwner",
                          label: "Is owner?",
                          type: StorybridgeTableHeaderType.boolean,
                        ),
                        StorybridgeTableHeader(
                            key: "dateCreated",
                            label: "Date created",
                            type: StorybridgeTableHeaderType.datetime),
                        StorybridgeTableHeader(
                            key: "dateModified",
                            label: "Date modified",
                            type: StorybridgeTableHeaderType.datetime),
                      ],
                      onView: (_, dynamic data, _2) {
                        Navigator.pushNamed(
                            context, "/audit?id=${data["auditTaskId"]}");
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
