import 'package:flutter/material.dart';
import 'package:mooc/Storybridge.dart'; // Storybridge

import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/course_service.dart' as course_service;
import 'package:mooc/services/error_service.dart' as error_service;
import 'package:mooc/services/certificate_service.dart' as certificate_service;
import 'package:mooc/services/auth_service.dart' as auth_service;

// myPage class which creates a state on call
class CourseDesignPage extends StatefulWidget {
  final int courseId;
  const CourseDesignPage({required this.courseId, Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<CourseDesignPage> {
  final int _selectedPage = 0;
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
    return StorybridgeTabPage(body: [
      Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: Builder(builder: (context) {
          switch (_selectedPage) {
            case 0:
              return CourseSettingsGeneralPage(courseId: widget.courseId);
          }
          return Container();
        }),
      )
    ]);
  }
}

// myPage class which creates a state on call
class CourseSettingsGeneralPage extends StatefulWidget {
  final int courseId;
  const CourseSettingsGeneralPage({Key? key, required this.courseId})
      : super(key: key);

  @override
  _CourseSettingsGeneralPageState createState() =>
      _CourseSettingsGeneralPageState();
}

// myPage state
class _CourseSettingsGeneralPageState extends State<CourseSettingsGeneralPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _deleteCourse() async {
    setState(() {
      error_service.alert(error_service.Alert(
          title: "Delete This Course?",
          description:
              "Are you sure you want to delete this course? All data will be lost forever.",
          buttonName: "DELETE",
          allowCancel: true,
          callback: (_) async {
            Map<String, dynamic> response = await networking_api_service
                .getCourse(courseId: widget.courseId);
            int organizationId = response["data"]["organizationId"];
            await networking_api_service.removeCourse(
                courseId: widget.courseId);
            course_service.sendToOrgPage(context,
                organizationId: organizationId);
          }));
    });
  }

  void _changeCourseLiveness(bool isLive) async {}

  // main build function
  @override
  Widget build(BuildContext context) {
    error_service.checkAlerts(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const StorybridgeTextH2("General Settings"),
      const SizedBox(height: 60),
      const StorybridgeDescriptor(
        name: "Course Name",
      ),
      StorybridgeSettingButton(
        name: "Course Name",
        loadValue: () async {
          Map<String, dynamic> course =
              await networking_api_service.getCourse(courseId: widget.courseId);
          return Uri.decodeComponent(course["data"]["courseName"]);
        },
        saveValue: (String value) async {
          networking_api_service.setCourseName(
              courseId: widget.courseId, courseName: value);
          course_service.sendToCoursePage(context, courseId: widget.courseId);
        },
      ),
      const StorybridgeDescriptor(
        name: "Certificate Design",
      ),
      const SizedBox(height: 15),
      _CertificateSettings(courseId: widget.courseId),
      const StorybridgeDivider(),
      const StorybridgeDescriptor(
        name: "Course Files",
      ),
      _CourseFilesViewer(courseId: widget.courseId),
      const StorybridgeDivider(),
      const StorybridgeDescriptor(
        name: "Course Control",
      ),
      StorybridgeSettingCheckbox(
        name: "Course Live",
        loadValue: () async {
          Map<String, dynamic> course =
              await networking_api_service.getCourse(courseId: widget.courseId);
          return course["data"]["isLive"]["data"][0] == 1;
        },
        saveValue: (bool value) async {
          networking_api_service.setCourseLiveness(
              courseId: widget.courseId, isLive: value);
        },
        trueText: "Hide Course from Students",
        falseText: "Publish Course to Students",
      ),
      StorybridgeButton(
        text: "Delete Course",
        lightenBackground: true,
        onPressed: _deleteCourse,
      )
    ]);
  }
}

class _CertificateSettings extends StatefulWidget {
  final int courseId;
  const _CertificateSettings({Key? key, required this.courseId})
      : super(key: key);

  @override
  _CertificateSettingsState createState() => _CertificateSettingsState();
}

// myPage state
class _CertificateSettingsState extends State<_CertificateSettings> {
  bool _isLoadingCert = false;
  bool _isLoadingPass = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final StorybridgeTextFieldController _dateOfTrainingController =
      StorybridgeTextFieldController();
  final StorybridgeTextFieldController _signeeNameController =
      StorybridgeTextFieldController();
  final StorybridgeTextFieldController _signeePositionController =
      StorybridgeTextFieldController();

  Future<bool> _load() async {
    certificate_service.CertificateData certificateData =
        await certificate_service.getCertificateData(widget.courseId);
    _dateOfTrainingController.text = certificateData.dateOfTraining!;
    _signeeNameController.text = certificateData.signeeName!;
    _signeePositionController.text = certificateData.signeePosition!;
    return true;
  }

  Future<void> _save() async {
    certificate_service.CertificateData certificateData =
        certificate_service.CertificateData();
    certificateData.dateOfTraining = _dateOfTrainingController.text;
    certificateData.signeeName = _signeeNameController.text;
    certificateData.signeePosition = _signeePositionController.text;
    await certificate_service.updateCertificateData(
        widget.courseId, certificateData);
  }

  void _previewCertificate() async {
    setState(() {
      _isLoadingCert = true;
    });
    await _save();
    await certificate_service
        .printCertficate(certificate_service.CertificateUserInput(
      name: "นาย ปลอดภัย ไว้ก่อน",
      courseId: widget.courseId,
      jobTitle: "วิศวกร",
      company: "บจก. ABC",
      userId: 0,
    ));
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoadingCert = false;
    });
  }

  void _previewPassport() async {
    setState(() {
      _isLoadingPass = true;
    });
    await _save();

    // get profile picture
    int? profilePictureImageId, userId;
    auth_service.AuthUserData? authUserData =
        auth_service.globalUser.getAuthUserData();
    if (authUserData != null) {
      Map<String, dynamic> response =
          await networking_api_service.getUser(userId: authUserData.userId);
      profilePictureImageId = response["data"]["profilePictureImageId"];
      userId = authUserData.userId;
    }
    bool hasPicture = profilePictureImageId != null;

    await certificate_service
        .printPassport(certificate_service.CertificateUserInput(
      name: "นาย ปลอดภัย ไว้ก่อน",
      profilePictureImageId: hasPicture ? profilePictureImageId : 0,
      courseId: widget.courseId,
      jobTitle: "วิศวกร",
      company: "บจก. ABC",
      userId: userId != null ? userId : 5,
    ));
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoadingPass = false;
    });
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return FutureBuilder(
        future: _load(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            return Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      StorybridgeTextField(
                        label: "Training Date",
                        isConstricted: false,
                        isLarge: false,
                        controller: _dateOfTrainingController,
                      ),
                      StorybridgeTextField(
                        label: "Signed By",
                        isConstricted: false,
                        isLarge: false,
                        controller: _signeeNameController,
                      ),
                      StorybridgeTextField(
                        label: "Position of Signer",
                        isConstricted: false,
                        isLarge: false,
                        controller: _signeePositionController,
                      ),
                      StorybridgeButton(
                        padding: false,
                        text: "Save",
                        onPressed: _save,
                      ),
                      const SizedBox(height: 20),
                      StorybridgeButton(
                        padding: false,
                        text: "Preview Certificate",
                        onPressed: _previewCertificate,
                        loading: _isLoadingCert,
                      ),
                      const SizedBox(height: 20),
                      StorybridgeButton(
                        padding: false,
                        text: "Preview Passport",
                        onPressed: _previewPassport,
                        loading: _isLoadingPass,
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
                Expanded(child: Container()),
              ],
            );
          } else {
            return Row(
              children: [
                const Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      StorybridgeBoxLoading(height: 60, width: 270),
                      StorybridgeBoxLoading(height: 60, width: 270),
                      StorybridgeBoxLoading(height: 60, width: 270),
                      SizedBox(height: 60),
                    ],
                  ),
                ),
                Expanded(child: Container()),
              ],
            );
          }
        });
  }
}

// myPage class which creates a state on call
class _CourseFilesViewer extends StatefulWidget {
  final int courseId;
  const _CourseFilesViewer({Key? key, required this.courseId})
      : super(key: key);

  @override
  _CourseFilesViewerState createState() => _CourseFilesViewerState();
}

// myPage state
class _CourseFilesViewerState extends State<_CourseFilesViewer> {
  double? _totalSize;
  Future<dynamic> _load() async {
    Map<String, dynamic> response =
        await networking_api_service.getCourseFiles(courseId: widget.courseId);
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
