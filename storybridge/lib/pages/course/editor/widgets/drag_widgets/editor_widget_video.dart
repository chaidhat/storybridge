import 'package:flutter/material.dart';
import 'package:mooc/Storybridge.dart'; // Storybridge

import 'package:mooc/style/Storybridge_colors.dart' as Storybridge_color;
import 'package:mooc/pages/course/widgets/video_player.dart';

import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/networking_service.dart' as networking_service;
import 'package:mooc/services/course_navigation_service.dart'
    as course_navigation_service;

const widgetTypeVideo = "video";

class _EditorWidgetVideoController {
  int videoId = 0;
  bool isInitialized = false;
}

class _Video {
  int duration;
  String contentDataId;
  bool isUploaded, isUploading;
  _Video({
    required this.duration,
    required this.contentDataId,
    required this.isUploaded,
    required this.isUploading,
  });
}

// myPage class which creates a state on call
class EditorWidgetVideo extends StatefulWidget implements EditorWidget {
  EditorWidgetVideo({Key? key, required this.editorWidgetData})
      : super(key: key);
  final _EditorWidgetVideoController controller =
      _EditorWidgetVideoController();
  @override
  final bool reduceDropzoneSize = false;

  @override
  final EditorWidgetData editorWidgetData;

  @override
  late final EditorWidgetMetadata metadata;

  // serialization
  @override
  void loadFromJson(Map<String, dynamic> json) {
    metadata = getMetadata(json, editorWidgetData);
    ;
    controller.videoId = int.parse(json["videoId"]);
    controller.isInitialized = json["isInitialized"] == "true";
  }

  @override
  Map<String, dynamic> saveToJson() {
    return {
      "metadata": metadata.encode(),
      "widgetType": widgetTypeVideo,
      "videoId": controller.videoId.toString(),
      "isInitialized": controller.isInitialized.toString(),
    };
  }

  @override
  void onCreate() {}

  @override
  void onRemove() {
    if (controller.isInitialized) {
      networking_api_service.removeVideo(videoId: controller.videoId);
    }
  }

  @override
  Widget? getToolbar() {
    return null;
  }

  @override
  _EditorWidgetVideoState createState() => _EditorWidgetVideoState();
}

// myPage state
class _EditorWidgetVideoState extends State<EditorWidgetVideo> {
  _Video? _video;
  bool? _isRead;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> loadData() async {
    Map<String, dynamic> response = await networking_api_service.getVideo(
        videoId: widget.controller.videoId);
    _video = _Video(
      duration: response["data"]["duration"],
      contentDataId: response["data"]["contentDataId"],
      isUploaded: response["data"]["isUploaded"]["data"][0] == 1,
      isUploading: response["data"]["isUploading"]["data"][0] == 1,
    );
    widget.controller.isInitialized = true;
    Map<String, dynamic> response2 = await networking_api_service
        .getIsVideoRead(videoId: widget.controller.videoId);
    _isRead = response2["data"];
    return true;
  }

  Future<void> onVideoUploading(int videoId) async {
    widget.controller.videoId = videoId;
    widget.controller.isInitialized = true;
    widget.editorWidgetData.onUpdate();
    setState(() {});
  }

  Future<void> onVideoUploaded() async {
    widget.editorWidgetData.onUpdate();
    setState(() {});
  }

  Future<void> _markAsRead() async {
    await networking_api_service.markVideoTaskAsRead(
        videoId: widget.controller.videoId);
    setState(() {
      course_navigation_service.reloadHierarchy();
      _isRead = !_isRead!;
    });
  }

  Future<void> _markAsUnread() async {
    await networking_api_service.markVideoTaskAsUnread(
        videoId: widget.controller.videoId);
    setState(() {
      course_navigation_service.reloadHierarchy();
      _isRead = !_isRead!;
    });
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
                if (!_video!.isUploading) {
                  return Column(
                    children: [
                      _WidgetVideoPlayer(
                          isSkippable: _isRead!,
                          onVideoEnd: () {
                            _markAsRead();
                          },
                          contentDataId: _video!.contentDataId),
                      const SizedBox(height: 20),
                      (!_isRead!
                          ? ((!widget.editorWidgetData.isAdminMode)
                              ? Container()
                              : StorybridgeButton(
                                  text: "mark as read",
                                  padding: false,
                                  invertedColor: true,
                                  icon: Icons.visibility_rounded,
                                  onPressed: () {
                                    _markAsRead();
                                  },
                                ))
                          : Wrap(
                              children: [
                                Icon(Icons.check,
                                    color: Storybridge_color.StorybridgeAccent),
                                const SizedBox(width: 20),
                                const StorybridgeTextP(
                                    "You have finished watching this video."),
                                const SizedBox(width: 20),
                                !widget.editorWidgetData.isAdminMode
                                    ? Container()
                                    : StorybridgeButton(
                                        text: "mark as unread",
                                        onPressed: () {
                                          _markAsUnread();
                                        },
                                      ),
                              ],
                            ))
                    ],
                  );
                } else {
                  return StorybridgeContentUploadProgess(
                    contentDataId: _video!.contentDataId,
                    onVideoUploaded: onVideoUploaded,
                  );
                }
              } else {
                return const Center(
                    child: StorybridgeBoxLoading(height: 580, width: 760));
              }
            })
        : StorybridgeContentUploader(
            contentType: StorybridgeContentType.video,
            onContentUploading: onVideoUploading,
            onContentUploaded: onVideoUploaded,
            courseId: widget.editorWidgetData.courseData.courseId,
            courseElementId: widget.editorWidgetData.courseData
                .getSelectedCourseElement()
                .courseElementId,
            organizationId: widget.editorWidgetData.courseData.organizationId);
  }
}

// myPage class which creates a state on call
class _WidgetVideoPlayer extends StatefulWidget {
  final String contentDataId;
  final bool isSkippable;
  final Function()? onVideoEnd;
  const _WidgetVideoPlayer(
      {Key? key,
      required this.contentDataId,
      required this.isSkippable,
      required this.onVideoEnd})
      : super(key: key);

  @override
  _WidgetVideoPlayerState createState() => _WidgetVideoPlayerState();
}

// myPage state
class _WidgetVideoPlayerState extends State<_WidgetVideoPlayer> {
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
    return StorybridgeVideoPlayer(
        isSkippable: widget.isSkippable,
        onVideoEnd: widget.onVideoEnd,
        videoUrl: Uri.parse(
            "${networking_service.getApiUrl()}?action=downloadVideo&contentDataId=${widget.contentDataId}"));
  }
}
