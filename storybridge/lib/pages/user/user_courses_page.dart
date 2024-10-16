import 'package:flutter/material.dart';
import 'package:mooc/storybridge.dart'; // Storybridge

import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;

// myPage class which creates a state on call
class UserCoursesPage extends StatefulWidget {
  final int userId;
  const UserCoursesPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserCoursesPageState createState() => _UserCoursesPageState();
}

// myPage state
class _UserCoursesPageState extends State<UserCoursesPage> {
  Future<dynamic> _load() async {
    Map<String, dynamic> response = await networking_api_service
        .getCourseSubscriptionsForUserId(userId: widget.userId);
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
                  Center(
                    child: StorybridgeTable(
                      advancedHeaders: [
                        StorybridgeTableHeader(
                            key: "courseName",
                            label: "Course name",
                            width: 500),
                        StorybridgeTableHeader(
                            key: "dateSubscribed",
                            label: "Date subscribed",
                            type: StorybridgeTableHeaderType.datetime,
                            width: 200),
                      ],
                      onView: (_, dynamic data, _2) {
                        Navigator.pushNamed(
                            context, "/course?id=${data["courseId"]}");
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
