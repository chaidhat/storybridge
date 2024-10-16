import 'package:flutter/material.dart';
import 'package:mooc/storybridge.dart'; // Storybridge

import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/networking_service.dart' as networking_service;

const widgetTypeImage = "image";

class _EditorWidgetImageController {
  int imageId = 0;
  bool isInitialized = false;
}

class _Image {
  String contentDataId;
  bool isUploaded, isUploading;
  _Image({
    required this.contentDataId,
    required this.isUploaded,
    required this.isUploading,
  });
}

class EditorWidgetImage extends StatefulWidget implements EditorWidget {
  @override
  final bool reduceDropzoneSize = false;
  // constructor
  EditorWidgetImage({Key? key, required this.editorWidgetData})
      : super(key: key);
  @override
  final EditorWidgetData editorWidgetData;

  @override
  late final EditorWidgetMetadata metadata;

  final StorybridgeTextFieldController _altTextcontroller =
      StorybridgeTextFieldController();

  final _EditorWidgetImageController controller =
      _EditorWidgetImageController();

  @override
  State<EditorWidgetImage> createState() => _EditorWidgetImageState();

  // serialization
  @override
  void loadFromJson(Map<String, dynamic> json) {
    metadata = getMetadata(json, editorWidgetData);
    ;
    _altTextcontroller.text = json["altText"];
    controller.imageId = int.parse(json["imageId"]);
    controller.isInitialized = json["isInitialized"] == "true";
  }

  @override
  Map<String, dynamic> saveToJson() {
    return {
      "metadata": metadata.encode(),
      "widgetType": widgetTypeImage,
      "altText": _altTextcontroller.text,
      "imageId": controller.imageId.toString(),
      "isInitialized": controller.isInitialized.toString(),
    };
  }

  @override
  void onCreate() {}

  @override
  void onRemove() {}

  @override
  Widget? getToolbar() {
    return null;
  }
}

class _EditorWidgetImageState extends State<EditorWidgetImage> {
  _Image? _image;
  Future<bool> loadData() async {
    Map<String, dynamic> response = await networking_api_service.getImage(
        imageId: widget.controller.imageId);
    _image = _Image(
      contentDataId: response["data"]["contentDataId"],
      isUploaded: response["data"]["isUploaded"]["data"][0] == 1,
      isUploading: response["data"]["isUploading"]["data"][0] == 1,
    );
    widget.controller.isInitialized = true;
    return true;
  }

  Future<void> onImageUploading(int imageId) async {
    widget.controller.imageId = imageId;
    widget.controller.isInitialized = true;
    widget.editorWidgetData.onUpdate();
    setState(() {});
  }

  Future<void> onImageUploaded() async {
    widget.editorWidgetData.onUpdate();
    setState(() {});
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    if (!widget.controller.isInitialized &&
        !widget.editorWidgetData.isAdminMode) {
      // hide unuploaded videos
      return Container();
    }
    // ignore: unused_local_variable
    return widget.controller.isInitialized
        ? FutureBuilder(
            future: loadData(),
            builder: (context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                if (!_image!.isUploading) {
                  return Image.network(
                      '${networking_service.getApiUrl()}?action=downloadImage&contentDataId=${_image!.contentDataId}');
                } else {
                  return StorybridgeContentUploadProgess(
                    contentDataId: _image!.contentDataId,
                    onVideoUploaded: onImageUploaded,
                  );
                }
              } else {
                return const Center(
                    child: StorybridgeBoxLoading(height: 580, width: 760));
              }
            })
        : StorybridgeContentUploader(
            contentType: StorybridgeContentType.image,
            onContentUploading: onImageUploading,
            onContentUploaded: onImageUploaded,
            courseId: widget.editorWidgetData.courseData.courseId,
            courseElementId: widget.editorWidgetData.courseData
                .getSelectedCourseElement()
                .courseElementId,
            organizationId: widget.editorWidgetData.courseData.organizationId);
  }
}

class _StorybridgeLinkSetting extends StatelessWidget {
  // members of MyWidget
  final StorybridgeTextFieldController linkController;
  final Function() onSave;

  // constructor
  const _StorybridgeLinkSetting({
    Key? key,
    required this.linkController,
    required this.onSave,
  }) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StorybridgeIconButton(
            icon: Icons.close,
            onPressed: () {
              Navigator.pop(context);
            }),
        const SizedBox(height: 30),
        const StorybridgeTextH2B("Send to Link"),
        const StorybridgeTextP(
            "Please enter the url below of where you want to send the student to"),
        const SizedBox(height: 10),
        Column(
          children: [
            SizedBox(
                child: StorybridgeTextField(
                    controller: linkController, label: "URL")),
            StorybridgeButton(
              padding: false,
              text: "save",
              onPressed: () {
                onSave();
                Navigator.pop(context);
              },
            )
          ],
        ),
      ],
    );
  }
}
