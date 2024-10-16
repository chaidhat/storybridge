import 'package:video_player/video_player.dart';

import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/services/video_player_service.dart'
    as video_player_service;

// myPage class which creates a state on call
class ScholarityVideoPlayer extends StatefulWidget {
  final Uri videoUrl;
  final bool isSkippable;
  final Function()? onVideoEnd;
  const ScholarityVideoPlayer(
      {Key? key,
      required this.videoUrl,
      this.isSkippable = true,
      this.onVideoEnd})
      : super(key: key);

  @override
  _ScholarityVideoPlayerState createState() => _ScholarityVideoPlayerState();
}

// myPage state
class _ScholarityVideoPlayerState extends State<ScholarityVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      widget.videoUrl,
      closedCaptionFile: _loadCaptions(),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
    video_player_service.registerVideoController(_controller);

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(false);
    _controller.initialize();
    _controller.addListener(() async {
      //FocusNode _focusNode = Focus.of(context);

      bool isPlaying = _controller.value.isPlaying;
      if (wasPlaying != isPlaying) {
        // when it starts playing
        FocusNode focusNode = Focus.of(context);
        focusNode.requestFocus();
      }
      wasPlaying = isPlaying;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    video_player_service.deregisterVideoController(_controller);
  }

  Future<ClosedCaptionFile> _loadCaptions() async {
    final String fileContents = await DefaultAssetBundle.of(context)
        .loadString('assets/bumble_bee_captions.vtt');
    return WebVTTCaptionFile(
        fileContents); // For vtt files, use WebVTTCaptionFile
  }

  bool wasPlaying = false;
  // main build function
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _controller.value.isInitialized
          ? _controller.value.aspectRatio
          : 4 / 3,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          VideoPlayer(_controller),
          /*ClosedCaption(text: _controller.value.caption.text),*/
          _ControlsOverlay(controller: _controller),
          ScholarityVideoProgressIndicator(
            controller: _controller,
            isSkippable: widget.isSkippable,
            onVideoEnd: widget.onVideoEnd,
          ),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key? key, required this.controller})
      : super(key: key);

  static const List<double> _examplePlaybackRates = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (double speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<double>>[
                for (final double speed in _examplePlaybackRates)
                  PopupMenuItem<double>(
                    value: speed,
                    child: ScholarityTextBasic('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: ScholarityTextBasic('${controller.value.playbackSpeed}x',
                  style: const TextStyle(color: Colors.grey)),
            ),
          ),
        ),
      ],
    );
  }
}
