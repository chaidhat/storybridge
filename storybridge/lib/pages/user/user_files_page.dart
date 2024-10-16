import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;

// myPage class which creates a state on call
class UserFilesPage extends StatefulWidget {
  final int userId;
  const UserFilesPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserFilesPageState createState() => _UserFilesPageState();
}

// myPage state
class _UserFilesPageState extends State<UserFilesPage> {
  Future<dynamic> _load() async {
    Map<String, dynamic> response =
        await networking_api_service.getUserFiles(userId: widget.userId);
    return response["data"]["data"];
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
    return ScholarityTabPage(hasVeryReducedPadding: true, body: [
      const SizedBox(height: 50),
      FutureBuilder(
          future: _load(),
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: ScholarityTable(
                      data: snapshot.data,
                      onDelete: (var pk, dynamic data, int i) {
                        _removeImage(pk, data);
                      },
                    ),
                  ),
                ],
              );
            } else {
              return const ScholarityPageLoading();
            }
          })
    ]);
  }
}
