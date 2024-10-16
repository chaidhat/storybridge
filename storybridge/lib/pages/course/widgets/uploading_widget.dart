import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/style/scholarity_colors.dart' as scholarity_color;
import 'package:mooc/services/networking_service.dart' as networking_service;
import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/error_service.dart' as error_service;

enum ScholarityContentType { video, image }

// myPage class which creates a state on call
class ScholarityContentUploader extends StatefulWidget {
  final Function(int) onContentUploading;
  final Function() onContentUploaded;
  final int courseId, courseElementId, organizationId;
  final ScholarityContentType contentType;
  const ScholarityContentUploader(
      {Key? key,
      required this.onContentUploading,
      required this.onContentUploaded,
      required this.courseId,
      required this.courseElementId,
      required this.organizationId,
      required this.contentType})
      : super(key: key);

  @override
  _ScholarityContentUploaderState createState() =>
      _ScholarityContentUploaderState();
}

// myPage state
class _ScholarityContentUploaderState extends State<ScholarityContentUploader> {
  FilePickerResult? _result;
  bool _isCreatingContent = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void uploadVideo() async {
    setState(() {
      _isCreatingContent = true;
    });
    int contentId;
    Map<String, dynamic> response;
    switch (widget.contentType) {
      case ScholarityContentType.video:
        contentId = await networking_api_service.createVideo(
            courseId: widget.courseId, courseElementId: widget.courseElementId);
        response = await networking_api_service.getVideo(videoId: contentId);
        break;
      case ScholarityContentType.image:
        contentId = await networking_api_service.createImage(
            courseId: widget.courseId,
            courseElementId: widget.courseElementId,
            auditTaskId: 0);
        response = await networking_api_service.getImage(imageId: contentId);
        break;
    }

    String contentDataId = response["data"]["contentDataId"];
    PlatformFile file = _result!.files.single;

    networking_service
        .serverUploadContent(
            contentDataId, file, () => widget.onContentUploading(contentId))
        .then((_) {
      print("done uploading");
      widget.onContentUploaded();
    });
  }

  void selectFiles() async {
    switch (widget.contentType) {
      case ScholarityContentType.video:
        const List<String> supported_video_exts = [
          'mp4',
          'mkv',
          'flv',
          'ogv',
          'mov',
          'qt',
          'wmv',
          'mpg',
          'mpeg',
          'm2v',
          'mpv',
          'm4v'
        ];
        _result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: supported_video_exts,
            withReadStream: true,
            withData: false);
        PlatformFile file = _result!.files.single;

        /*
        int paymentTier = (await networking_api_service.getOrganization(
            organizationId: widget.organizationId))['data']['paymentTier'];
        */
        const int file_limit_GB = 10000;
        double file_size_GB = file.size / 1000000000;

        if (!supported_video_exts.contains(file.extension)) {
          //The file is not a video or isn't a supported type of video, do not select this file
          setState(() {
            error_service.alert(error_service.Alert(
                title: "Video type not supported",
                description:
                    "The .${file.extension} extension is not supported. Supported video extensions: .${supported_video_exts.join(', .')}",
                buttonName: "Return",
                callback: (_) {}));
          });
          _result = null;
        } else if (file_size_GB > file_limit_GB) {
          //File size is too big, do not upload
          setState(() {
            error_service.alert(error_service.Alert(
                title: "Video is too big",
                description:
                    "The uploaded file is ${file_size_GB} GB which exceeds your ${file_limit_GB} GB limit",
                buttonName: "Return",
                callback: (_) {}));
          });
          _result = null;
        }
        break;
      case ScholarityContentType.image:
        const List<String> supported_img_exts = [
          'png',
          'jpg',
          'jpeg',
          'jpe',
          'gif',
          'webp',
          'tiff',
          'raw',
          'heif',
          'heic',
          'jp2'
        ];
        _result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: supported_img_exts,
            withReadStream: true,
            withData: false);
        if (!supported_img_exts.contains(_result!.files.single.extension)) {
          //The file is not an image or isn't a supported type of image, do not select this file
          setState(() {
            error_service.alert(error_service.Alert(
                title: "Image type not supported",
                description:
                    "The .${_result!.files.single.extension} extension is not supported. Supported image extensions: .${supported_img_exts.join(', .')}",
                buttonName: "Return",
                callback: (_) {}));
          });
          _result = null;
        }
        break;
    }

    if (_result != null) {
      setState(() {
        uploadVideo();
      });
    }
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    error_service.checkAlerts(context);
    return Container(
        decoration: BoxDecoration(
            color: scholarity_color.backgroundDim,
            border: Border.all(color: scholarity_color.borderColor),
            borderRadius: BorderRadius.circular(8.0)),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: !_isCreatingContent
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Icon(Icons.file_upload_outlined,
                        size: 100, color: scholarity_color.grey),
                    const SizedBox(height: 10),
                    _result == null
                        ? ScholarityTextH2B(
                            "Upload Your ${widget.contentType == ScholarityContentType.image ? "Image" : "Video"}")
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.file_copy_rounded,
                                  color: scholarity_color.grey),
                              const SizedBox(width: 5),
                              ScholarityTextH2B(_result!.names.first!),
                            ],
                          ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _result != null
                            ? ScholarityButton(
                                text: "Upload",
                                invertedColor: true,
                                onPressed: uploadVideo,
                              )
                            : Container(),
                        ScholarityButton(
                          text:
                              _result == null ? "Select File" : "Reselect File",
                          darkenBackground: true,
                          onPressed: selectFiles,
                          padding: false,
                        )
                      ],
                    ),
                  ],
                )
              : const ScholarityLoading(),
        ));
  }
}

// myPage class which creates a state on call
class ScholarityContentUploadProgess extends StatefulWidget {
  final String contentDataId;
  final Function() onVideoUploaded;

  const ScholarityContentUploadProgess(
      {Key? key, required this.contentDataId, required this.onVideoUploaded})
      : super(key: key);

  @override
  _ScholarityContentUploadProgessState createState() =>
      _ScholarityContentUploadProgessState();
}

// myPage state
class _ScholarityContentUploadProgessState
    extends State<ScholarityContentUploadProgess> {
  bool _stillGo = true;
  double _videoProgress = 0;
  bool _isCompressing = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _stillGo = false;
    super.dispose();
  }

  Future<void> updateProgressBar() async {
    Map<String, double?> uploadProgress =
        await networking_service.getContentUploadProgress(widget.contentDataId);
    _isCompressing = (uploadProgress['isCompressing']! == 1) ? true : false;
    setState(() {
      if (uploadProgress['progress'] != null)
        _videoProgress = uploadProgress['progress']! * 100;
      else
        widget.onVideoUploaded();
    });
    setState(() {});
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 100)).then(
      (_) {
        if (_stillGo) updateProgressBar();
      },
    );
    return Container(
        decoration: BoxDecoration(
            color: scholarity_color.backgroundDim,
            border: Border.all(color: scholarity_color.borderColor),
            borderRadius: BorderRadius.circular(8.0)),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.file_upload_outlined,
                  size: 100, color: scholarity_color.grey),
              const SizedBox(height: 10),
              ScholarityTextH2B(
                  "${(_isCompressing) ? 'Compressing' : 'Uploading'} ${_videoProgress.round()}%..."),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: SizedBox(
                    height: 20,
                    child: LinearProgressIndicator(
                        color: scholarity_color.scholarityAccent,
                        backgroundColor: scholarity_color.scholarityAccentLight,
                        value: _videoProgress / 100)),
              )
            ],
          ),
        ));
  }
}
