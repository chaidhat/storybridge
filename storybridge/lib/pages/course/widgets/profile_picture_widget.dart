import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:mooc/Storybridge.dart'; // Storybridge

import 'package:mooc/services/networking_service.dart' as networking_service;
import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/style/Storybridge_colors.dart' as Storybridge_color;
import 'package:mooc/services/camera_service.dart' as camera_service;

// myPage class which creates a state on call
class ProfilePictureSelectorWidget extends StatefulWidget {
  final int? organizationId;
  final int? userId;
  const ProfilePictureSelectorWidget(
      {Key? key, this.organizationId, this.userId})
      : super(key: key);

  @override
  _ProfilePictureSelectorWidgetState createState() =>
      _ProfilePictureSelectorWidgetState();
}

// myPage state
class _ProfilePictureSelectorWidgetState
    extends State<ProfilePictureSelectorWidget> {
  bool _isLoading = false;
  late int _imageId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _uploadProfilePicture() async {
    const List<String> supportedImgExts = [
      'png',
      'jpg',
      'jpeg',
    ];
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: supportedImgExts,
        withReadStream: true,
        withData: false);

    if (result != null) {
      setState(() {
        _isLoading = true;
      });

      if (widget.organizationId != null) {
        int imageId = await networking_api_service.createImage(
            courseId: 0,
            courseElementId: 0,
            auditTaskId:
                0); // course id = 0 to signify it doesn't belong to a course
        Map<String, dynamic> response =
            await networking_api_service.getImage(imageId: imageId);
        String contentDataId = response["data"]["contentDataId"];
        PlatformFile file = result.files.single;
        networking_service
            .serverUploadContent(contentDataId, file, () {})
            .then((_) async {
          await networking_api_service.setOrganizationProfilePictureImageId(
              organizationId: widget.organizationId!,
              profilePictureImageId: imageId);
          setState(() {
            _isLoading = false;
          });
          return;
        });
      } else if (widget.userId != null) {
        int imageId = await networking_api_service.createImageForUser(
          userId: widget.userId!,
        ); // course id = 0 to signify it doesn't belong to a course
        Map<String, dynamic> response =
            await networking_api_service.getImage(imageId: imageId);
        String contentDataId = response["data"]["contentDataId"];
        PlatformFile file = result.files.single;
        networking_service
            .serverUploadContent(contentDataId, file, () {})
            .then((_) async {
          await networking_api_service.setProfilePictureImageId(
              userId: widget.userId!, profilePictureImageId: imageId);
          setState(() {
            _isLoading = false;
          });
          return;
        });
      } else {}
    }
  }

  void _takePhoto() async {
    if (widget.userId != null) {
      await camera_service.initCameras();
      // ignore: use_build_context_synchronously
      showDialog<String>(
          context: context,
          builder: (BuildContext context) => StorybridgeAlertDialogWrapper(
                  child: StorybridgeAlertDialog(
                      content: camera_service.TakePictureScreen(
                onPictureTaken: () async {
                  _imageId = await networking_api_service.createImageForUser(
                    userId: widget.userId!,
                  ); // course id = 0 to signify it doesn't belong to a course
                  Map<String, dynamic> response =
                      await networking_api_service.getImage(imageId: _imageId);
                  String contentDataId = response["data"]["contentDataId"];
                  return contentDataId;
                },
                onDone: (() async {
                  await networking_api_service.setProfilePictureImageId(
                      userId: widget.userId!, profilePictureImageId: _imageId);
                  setState(() {
                    _isLoading = false;
                  });
                }),
              ))));
    }
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return Column(
      children: [
        !_isLoading
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      ProfilePictureWidget(
                        isSquare: widget.userId != null,
                        hasBorder: true,
                        organizationId: widget.organizationId,
                        userId: widget.userId,
                      ),
                    ],
                  ),
                ),
              )
            : const StorybridgeBoxLoading(height: 200, width: 200),
        !_isLoading
            ? (widget.userId != null
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: IntrinsicWidth(
                      child: PopupMenuButton(
                          child: const StorybridgeButton(
                            text: "Change Profile Picture",
                            onPressed: null,
                          ),
                          itemBuilder: (BuildContext context) {
                            return [
                              PopupMenuItem(
                                onTap: () {
                                  _uploadProfilePicture();
                                },
                                child: const StorybridgeTextBasic(
                                    'Upload Picture'),
                              ),
                              PopupMenuItem(
                                onTap: () {
                                  _takePhoto();
                                },
                                child: const StorybridgeTextBasic('Take photo'),
                              ),
                            ];
                          }),
                    ),
                  )
                : StorybridgeButton(
                    text: "Upload Picture",
                    onPressed: () {
                      _uploadProfilePicture();
                    },
                  ))
            : const StorybridgeBoxLoading(height: 70, width: 300),
      ],
    );
  }
}

class ProfilePictureController {
  bool hasPicture = false;
}

// myPage class which creates a state on call
class ProfilePictureWidget extends StatefulWidget {
  final int? organizationId;
  final int? userId;
  final bool hasBorder;
  final bool isSquare;
  final Widget? child;
  final ProfilePictureController? controller;
  const ProfilePictureWidget({
    Key? key,
    this.organizationId,
    this.userId,
    this.isSquare = false,
    this.hasBorder = false,
    this.child,
    this.controller,
  }) : super(key: key);

  @override
  _ProfilePictureWidgetState createState() => _ProfilePictureWidgetState();
}

// myPage state
class _ProfilePictureWidgetState extends State<ProfilePictureWidget> {
  int? _profilePictureImageId;
  bool _hasPicture = false;
  String? _imageContentDataId;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _loadImage() async {
    if (widget.organizationId != null) {
      // get the image id from the organization
      Map<String, dynamic> response = await networking_api_service
          .getOrganization(organizationId: widget.organizationId!);
      _profilePictureImageId = response["data"]["profilePictureImageId"];
      _hasPicture =
          _profilePictureImageId != null && _profilePictureImageId != 0;

      // now load the content behind that imageId
      if (_hasPicture) {
        Map<String, dynamic> imageData = await networking_api_service.getImage(
            imageId: _profilePictureImageId!);
        _imageContentDataId = imageData["data"]["contentDataId"];
      }
      return true;
    } else if (widget.userId != null) {
      // get the image id from the organization
      Map<String, dynamic> response =
          await networking_api_service.getUser(userId: widget.userId!);
      _profilePictureImageId = response["data"]["profilePictureImageId"];
      _hasPicture =
          _profilePictureImageId != null && _profilePictureImageId != 0;

      // now load the content behind that imageId
      if (_hasPicture) {
        Map<String, dynamic> imageData = await networking_api_service.getImage(
            imageId: _profilePictureImageId!);
        _imageContentDataId = imageData["data"]["contentDataId"];
      }
      return true;
    }
    return false;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return FutureBuilder(
        future: _loadImage(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            if (widget.controller != null) {
              widget.controller!.hasPicture = _hasPicture;
            }
            return Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Container(
                    height: 80,
                    constraints: const BoxConstraints(maxWidth: 150),
                    decoration: widget.hasBorder
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Storybridge_color.borderColor,
                            ))
                        : null,
                    child: Builder(builder: (context) {
                      Widget w = ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _hasPicture
                              ? Image.network(
                                  '${networking_service.getApiUrl()}?action=downloadImage&contentDataId=$_imageContentDataId',
                                  fit: !widget.isSquare
                                      ? BoxFit.fitWidth
                                      : BoxFit.cover,
                                )
                              : Image(
                                  fit: BoxFit.fitWidth,
                                  image: AssetImage(widget.userId != null
                                      ? "assets/images/default_user_profile_picture.jpg"
                                      : "assets/images/default_organization_profile_picture.png")));
                      if (!widget.isSquare) {
                        return w;
                      } else {
                        return AspectRatio(aspectRatio: 1, child: w);
                      }
                    }),
                  ),
                ),
                widget.child != null ? const SizedBox(width: 20) : Container(),
                widget.child != null ? widget.child! : Container(),
              ],
            );
          } else {
            return const StorybridgeBoxLoading(height: 10, width: 10);
          }
        });
  }
}
