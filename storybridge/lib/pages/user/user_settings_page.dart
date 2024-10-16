import 'dart:convert';
import 'package:pdfx/pdfx.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:mooc/storybridge.dart'; // Storybridge

import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/auth_service.dart' as auth_service;
import 'package:mooc/style/storybridge_colors.dart' as storybridge_color;
import 'package:mooc/services/networking_service.dart' as networking_service;
import 'package:mooc/services/error_service.dart' as error_service;

// myPage class which creates a state on call
class UserSettingsPage extends StatefulWidget {
  final int userId;
  final bool isOwner;
  const UserSettingsPage(
      {Key? key, required this.userId, required this.isOwner})
      : super(key: key);

  @override
  _UserSettingsPageState createState() => _UserSettingsPageState();
}

abstract class FieldWidget {
  String fieldName;
  FieldWidget({required this.fieldName, required String data});
  Widget getEditableWidget();
  Widget getLockedWidget();
  String getData();
}

class _FieldTextWidget extends FieldWidget {
  String fieldName;
  StorybridgeTextFieldController _controller = StorybridgeTextFieldController();
  _FieldTextWidget({required this.fieldName, required String data})
      : super(fieldName: fieldName, data: data) {
    _controller.text = Uri.decodeComponent(data);
  }

  @override
  Widget getEditableWidget() {
    String labelOut = fieldName;
    if (labelOut == "telephone") {
      labelOut = "Reader Level";
    }
    if (labelOut == "jobTitle") {
      labelOut = "Interests";
    }
    if (labelOut == "company") {
      labelOut = "Gender";
    }
    if (labelOut == "employeeId") {
      labelOut = "Age Group";
    }
    return _StorybridgeSettingField(
      children: [
        StorybridgeDescriptor(name: labelOut),
        StorybridgeTextField(
          label: labelOut,
          controller: _controller,
        ),
      ],
    );
  }

  @override
  Widget getLockedWidget() {
    return _StorybridgeSettingField(
      children: [
        StorybridgeDescriptor(name: fieldName),
        StorybridgeTextP(
          _controller.text,
        ),
      ],
    );
  }

  @override
  String getData() {
    return _controller.text;
  }
}

class _FieldExternalCertificateWidget extends FieldWidget {
  String fieldName;
  StorybridgeTextFieldController _expiryDate = StorybridgeTextFieldController();
  int userId;
  final _StorybridgeFileUploadData _fileData = _StorybridgeFileUploadData();
  _FieldExternalCertificateWidget(
      {required this.fieldName, required String data, required this.userId})
      : super(fieldName: fieldName, data: data) {
    try {
      var externalCertificate = jsonDecode(Uri.decodeComponent(data));
      _expiryDate.text = externalCertificate["expiryDate"];
      _fileData.imageId = externalCertificate["imageId"];
    } catch (e) {
      _expiryDate.text = "";
      _fileData.imageId = null;
    }
  }

  @override
  Widget getEditableWidget() {
    return Column(
      children: [
        StorybridgeDescriptor(name: fieldName),
        StorybridgeTile(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                _StorybridgeFileUploadWidget(userId: userId, data: _fileData),
                const SizedBox(width: 20),
                StorybridgeDatePicker(
                    label: "Expiry Date", date: DateTime.now()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget getLockedWidget() {
    return Container();
  }

  @override
  String getData() {
    return jsonEncode(
        {"expiryDate": _expiryDate.text, "imageId": _fileData.imageId});
  }
}

// myPage state
class _UserSettingsPageState extends State<UserSettingsPage> {
  final StorybridgeTextFieldController _emailController =
      StorybridgeTextFieldController();
  final StorybridgeTextFieldController _fullNameController =
      StorybridgeTextFieldController();
  final List<FieldWidget> _eudControllers = [];
  final _PDPAData _pdpaData = _PDPAData();
  String _userId = "";
  String _organizationId = "";
  bool _loadingSaveUser = false;

  Future<bool> _load() async {
    Map<String, dynamic> response =
        await networking_api_service.getUser(userId: widget.userId);
    var user = response["data"];
    _userId = user["userId"].toString();
    int organizationId = user["organizationId"];
    _organizationId = organizationId.toString();

    var eudFields;
    if (organizationId != 0) {
      Map<String, dynamic> responseOrg = await networking_api_service
          .getOrganization(organizationId: organizationId);
      var org = responseOrg["data"];
      if (org["extraUserDataFields"] != null) {
        eudFields =
            jsonDecode(Uri.decodeComponent(org["extraUserDataFields"]))["data"];
      } else {
        eudFields = [];
      }
    } else {
      eudFields = [
        {"fieldName": "telephone", "fieldType": "Text"},
        {"fieldName": "jobTitle", "fieldType": "Text"},
        {"fieldName": "company", "fieldType": "Text"},
        {"fieldName": "employeeId", "fieldType": "Text"},
        {"fieldName": "PDPA", "fieldType": "PDPA"},
      ];
    }
    /*
    //_organizationId = user["organizationId"].toString();
    */
    _emailController.text = Uri.decodeComponent(user["email"]);
    _fullNameController.text =
        "${Uri.decodeComponent(user["firstName"])} ${Uri.decodeComponent(user["lastName"])}";
    _eudControllers.clear();
    for (String key in user["extraUserData"].keys) {
      // special fields
      if (key == "PDPA") {
        _pdpaData.isAccepted = user["extraUserData"][key] == "true";
        continue;
      }
      // regular fields
      for (int i = 0; i < eudFields.length; i++) {
        if (eudFields[i]["fieldName"] == key) {
          switch (eudFields[i]["fieldType"]) {
            case "External Certificate":
              _FieldExternalCertificateWidget field =
                  _FieldExternalCertificateWidget(
                      fieldName: key,
                      data: user["extraUserData"][key],
                      userId: int.parse(_userId));
              _eudControllers.add(field);
              break;
            case "Text":
            default:
              _FieldTextWidget field = _FieldTextWidget(
                  fieldName: key, data: user["extraUserData"][key]);
              _eudControllers.add(field);
              break;
          }
          break;
        }
      }
    }
    auth_service.globalUser.tryLogin();
    return true;
  }

  Future<dynamic> _saveUser() async {
    setState(() {
      _loadingSaveUser = true;
    });
    // parse the names
    List<String> names = _fullNameController.text.split(' ');
    String firstName = "", lastName = "";
    if (names.length > 1) {
      firstName = names[0];
      // last names are all the names after the first one.
      for (int i = 1; i < names.length; i++) {
        lastName += "${names[i]} ";
      }
      lastName = lastName.substring(0, lastName.length - 1);
    } else {
      firstName = _fullNameController.text;
    }

    Map<String, dynamic> eud = {};
    for (var e in _eudControllers) {
      eud[e.fieldName] = e.getData();
    }
    eud["PDPA"] = _pdpaData.isAccepted.toString();

    await networking_api_service.changeUser(
        userId: widget.userId,
        username: _emailController.text,
        email: _emailController.text,
        firstName: firstName,
        lastName: lastName,
        eud: jsonEncode(eud));
    setState(() {
      _loadingSaveUser = false;
    });
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
    return StorybridgeTabPage(body: [
      const SizedBox(height: 40),
      FutureBuilder(
          future: _load(),
          builder: (context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const StorybridgePageLoading();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const StorybridgeDescriptor(name: "Profile Photo"),
                widget.isOwner
                    ? ProfilePictureSelectorWidget(userId: widget.userId)
                    : ProfilePictureWidget(
                        userId: widget.userId,
                        hasBorder: true,
                      ),
                Wrap(
                    crossAxisAlignment: WrapCrossAlignment.start,
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    children: [
                      _LockableSettingWidget(
                          controller: _emailController,
                          label: "Email",
                          isLocked: !widget.isOwner),
                      _LockableSettingWidget(
                          controller: _fullNameController,
                          label: "Full Name",
                          isLocked: !widget.isOwner),
                    ]),
                widget.isOwner
                    ? StorybridgeButton(
                        text: "Save",
                        loading: _loadingSaveUser,
                        invertedColor: true,
                        onPressed: () async {
                          await _saveUser();
                        },
                      )
                    : Container(),
                _eudControllers.isNotEmpty
                    ? const StorybridgeDivider(isLarge: true)
                    : Container(),
                _eudControllers.isNotEmpty
                    ? Wrap(
                        crossAxisAlignment: WrapCrossAlignment.start,
                        alignment: WrapAlignment.start,
                        runAlignment: WrapAlignment.start,
                        children:
                            List.generate(_eudControllers.length, (int i) {
                          return widget.isOwner
                              ? _eudControllers[i].getEditableWidget()
                              : _eudControllers[i].getLockedWidget();
                        }))
                    : Container(),
                _eudControllers.isNotEmpty
                    ? const SizedBox(height: 30)
                    : Container(),
                widget.isOwner && _eudControllers.isNotEmpty
                    ? StorybridgeButton(
                        text: "Save",
                        loading: _loadingSaveUser,
                        invertedColor: true,
                        onPressed: () async {
                          await _saveUser();
                        },
                      )
                    : Container(),
                widget.isOwner
                    ? const StorybridgeDivider(isLarge: true)
                    : Container(),
                widget.isOwner
                    ? const StorybridgeDescriptor(
                        name: "Password", description: "")
                    : Container(),
                widget.isOwner
                    ? _PasswordChanger(userId: widget.userId)
                    : Container(),
                const StorybridgeDivider(isLarge: true),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  alignment: WrapAlignment.start,
                  runAlignment: WrapAlignment.start,
                  children: [
                    _StorybridgeSettingField(
                      children: [
                        const StorybridgeDescriptor(name: "User ID"),
                        StorybridgeTextP(_userId)
                      ],
                    ),
                    _StorybridgeSettingField(
                      children: [
                        const StorybridgeDescriptor(name: "Organization ID"),
                        StorybridgeTextP(_organizationId)
                      ],
                    ),
                  ],
                ),
              ],
            );
          })
    ]);
  }
}

class _LockableSettingWidget extends StatelessWidget {
  // members of MyWidget
  final StorybridgeTextFieldController controller;
  final String label;
  final bool isLocked;

  // constructor
  const _LockableSettingWidget(
      {Key? key,
      required this.controller,
      required this.label,
      required this.isLocked})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    String lockedText = controller.text == "" ? "-" : controller.text;
    return _StorybridgeSettingField(
      children: [
        StorybridgeDescriptor(name: label),
        isLocked
            ? StorybridgeTextP(lockedText)
            : StorybridgeTextField(
                label: label,
                controller: controller,
              )
      ],
    );
  }
}

class _StorybridgeSettingField extends StatelessWidget {
  // members of MyWidget
  final List<Widget> children;

  // constructor
  const _StorybridgeSettingField({Key? key, required this.children})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ),
    );
  }
}

class _PasswordChanger extends StatefulWidget {
  final int userId;
  const _PasswordChanger({Key? key, required this.userId}) : super(key: key);

  @override
  _PasswordChangerState createState() => _PasswordChangerState();
}

// myPage state
class _PasswordChangerState extends State<_PasswordChanger> {
  bool _clickedChanged = false;
  StorybridgeTextFieldController _oldPasswordController =
      StorybridgeTextFieldController();
  StorybridgeTextFieldController _newPasswordController =
      StorybridgeTextFieldController();
  StorybridgeTextFieldController _confirmNewPasswordController =
      StorybridgeTextFieldController();
  bool _isLoadingPassword = false;
  bool _isPasswordSet = false;

  Future<void> _setPassword() async {
    setState(() {
      _isLoadingPassword = true;
    });
    _oldPasswordController.clearError();
    _newPasswordController.clearError();
    _confirmNewPasswordController.clearError();

    if (_newPasswordController.text != _confirmNewPasswordController.text) {
      _confirmNewPasswordController.errorText =
          "Please retype your new password.";
    }
    try {
      await networking_api_service.changeUserPassword(
          oldPassword: _oldPasswordController.text,
          newPassword: _newPasswordController.text);
      setState(() {
        _isPasswordSet = true;
      });
    } on error_service.StorybridgeException catch (err) {
      switch (err.errorData?["authErrorType"]) {
        case "oldPassword":
        case "general":
          _oldPasswordController.errorText = err.errorData?["message"];
          break;
        case "newPassword":
          _newPasswordController.errorText = err.errorData?["message"];
          break;
      }
    }
    setState(() {
      _isLoadingPassword = false;
    });
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
    if (!_clickedChanged) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: StorybridgeButton(
          text: "Change Password",
          padding: false,
          onPressed: () {
            setState(() {
              _clickedChanged = true;
            });
          },
        ),
      );
    } else {
      if (_isPasswordSet) {
        return const StorybridgeTextP("Password successfully changed.");
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          StorybridgeTextField(
              label: "Old Password",
              isConstricted: true,
              isPasswordField: true,
              controller: _oldPasswordController),
          StorybridgeTextField(
              label: "New Password",
              isConstricted: true,
              isPasswordField: true,
              controller: _newPasswordController),
          StorybridgeTextField(
              label: "Retype New Password",
              isConstricted: true,
              isPasswordField: true,
              controller: _confirmNewPasswordController),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: StorybridgeButton(
              text: "Set",
              loading: _isLoadingPassword,
              invertedColor: true,
              onPressed: () async {
                await _setPassword();
              },
            ),
          ),
        ],
      );
    }
  }
}

class _StorybridgeFileUploadData {
  int? imageId;
}

// myPage class which creates a state on call
class _StorybridgeFileUploadWidget extends StatefulWidget {
  final _StorybridgeFileUploadData data;
  final int userId;
  const _StorybridgeFileUploadWidget(
      {Key? key, required this.data, required this.userId})
      : super(key: key);

  @override
  _StorybridgeFileUploadWidgetState createState() =>
      _StorybridgeFileUploadWidgetState();
}

// myPage state
class _StorybridgeFileUploadWidgetState
    extends State<_StorybridgeFileUploadWidget> {
  bool _isUploading = false;
  String? _contentDataId;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.data.imageId != null) {
      print("imageid ${widget.data.imageId}");
      Map<String, dynamic> response =
          await networking_api_service.getImage(imageId: widget.data.imageId!);
      print(response);
      _contentDataId = response["data"]["contentDataId"];
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void upload(FilePickerResult result) async {
    setState(() {
      _isUploading = true;
    });
    int contentId;
    contentId =
        await networking_api_service.createImageForUser(userId: widget.userId);
    widget.data.imageId = contentId;
    Map<String, dynamic> response =
        await networking_api_service.getImage(imageId: contentId);

    String contentDataId = response["data"]["contentDataId"];
    PlatformFile file = result.files.single;

    await networking_service
        .serverUploadContent(contentDataId, file, () => {})
        .then((_) {
      //widget.onContentUploaded();
    });
    setState(() {
      _isUploading = false;
    });
  }

  Future<dynamic> _selectUpload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      withReadStream: true,
    );
    if (result != null) {
      setState(() {
        upload(result);
      });
    }
  }

  void _download() {
    if (_contentDataId != null) {
      launchUrl(Uri.parse(
          "${networking_service.getApiUrl()}/?action=downloadImage&contentDataId=${_contentDataId}"));
    }
  }

  Future<dynamic> _delete() async {
    await networking_api_service.removeImage(imageId: widget.data.imageId!);
    setState(() {
      widget.data.imageId = null;
    });
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    print(widget.data);
    if (widget.data.imageId == null) {
      return StorybridgeButton(
        invertedColor: true,
        text: "Upload File",
        loading: _isUploading,
        icon: Icons.attachment_rounded,
        onPressed: () {
          _selectUpload();
        },
      );
    } else {
      return Row(
        children: [
          StorybridgeButton(
              padding: false,
              text: "Download",
              onPressed: () {
                _download();
              },
              icon: Icons.download_rounded),
          const SizedBox(width: 10),
          StorybridgeIconButton(
            icon: Icons.close,
            onPressed: () {
              _delete();
            },
          ),
        ],
      );
    }
  }
}

class _PDPAData {
  bool isAccepted = false;
}

class _PDPAWidget extends StatefulWidget {
  // members of MyWidget
  final _PDPAData data;
  final Function() onChanged;
  final bool isOwner;

  // constructor
  const _PDPAWidget(
      {Key? key,
      required this.data,
      required this.onChanged,
      required this.isOwner})
      : super(key: key);

  @override
  State<_PDPAWidget> createState() => _PDPAWidgetState();
}

class _PDPAWidgetState extends State<_PDPAWidget> {
  void _showPDPA() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => _PDPAPopup(
                pdfController: PdfControllerPinch(
                  viewportFraction: 0.5,
                  document: PdfDocument.openAsset('PT-PDPA.pdf'),
                ),
                onAccepted: () {
                  setState(() {
                    widget.data.isAccepted = true;
                    widget.onChanged();
                  });
                },
                onRejected: () {
                  setState(() {
                    widget.data.isAccepted = false;
                    widget.onChanged();
                  });
                },
              )),
    );
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        widget.isOwner
            ? Padding(
                padding: const EdgeInsets.only(right: 10),
                child: StorybridgeButton(
                  text: "View PDPA",
                  onPressed: () {
                    _showPDPA();
                  },
                ),
              )
            : Container(),
        widget.data.isAccepted
            ? const Row(
                children: [
                  Icon(Icons.check),
                  SizedBox(width: 5),
                  StorybridgeTextP("PDPA accepted"),
                ],
              )
            : Row(
                children: [
                  Icon(Icons.close_rounded,
                      color: storybridge_color.storybridgeAccent),
                  const SizedBox(width: 5),
                  const StorybridgeTextP("PDPA not accepted yet"),
                ],
              ),
      ],
    );
  }
}

class _PDPAPopup extends StatefulWidget {
  final Function() onAccepted;
  final Function() onRejected;
  final PdfControllerPinch pdfController;
  // constructor
  const _PDPAPopup({
    Key? key,
    required this.onAccepted,
    required this.onRejected,
    required this.pdfController,
  }) : super(key: key);

  @override
  State<_PDPAPopup> createState() => _PDPAPopupState();
}

class _PDPAPopupState extends State<_PDPAPopup> {
  bool _hasFullyRead = false;
// Simple Pdf view with one render of page (loose quality on zoom)
  @override
  Widget build(BuildContext context) {
    return StorybridgeScaffold(
      hasAppbar: false,
      tabNames: [StorybridgeTabHeader(tabName: "a", tabIcon: Icons.close)],
      body: const [],
      tabs: [
        Container(
          color: storybridge_color.background,
          child: Align(
            alignment: Alignment.center,
            child: StorybridgeHolder(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StorybridgeIconButton(
                        icon: Icons.close,
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    const SizedBox(height: 10),
                    Expanded(
                      child: StorybridgeTile(
                        useAltStyle: true,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: SizedBox(
                            child: PdfViewPinch(
                              onPageChanged: (int pageNum) {
                                if (pageNum ==
                                    widget.pdfController.pagesCount!) {
                                  setState(() {
                                    _hasFullyRead = true;
                                  });
                                }
                              },
                              backgroundDecoration:
                                  const BoxDecoration(color: Colors.grey),
                              scrollDirection: Axis.vertical,
                              controller: widget.pdfController,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const StorybridgeTextP("Do you accept the PDPA?"),
                    const SizedBox(height: 20),
                    _hasFullyRead
                        ? Row(
                            children: [
                              StorybridgeButton(
                                padding: false,
                                invertedColor: true,
                                text: "Accept",
                                onPressed: () {
                                  widget.onAccepted();
                                  Navigator.pop(context);
                                },
                              ),
                              const SizedBox(width: 10),
                              StorybridgeButton(
                                padding: false,
                                text: "Reject",
                                onPressed: () {
                                  widget.onRejected();
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          )
                        : Container(),
                    _hasFullyRead
                        ? Container()
                        : const StorybridgeTextP(
                            "Please scroll down to bottom page before accepting."),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
