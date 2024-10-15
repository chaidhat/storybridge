import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart'; // Flutter

import 'package:mooc/style/Storybridge_colors.dart' as Storybridge_color;

class StorybridgeVideoProgressIndicator extends StatefulWidget {
  final VideoPlayerController controller;
  final bool isSkippable;
  final Function()? onVideoEnd;
  StorybridgeVideoProgressIndicator(
      {Key? key,
      required this.controller,
      required this.isSkippable,
      this.onVideoEnd})
      : super(key: key);

  @override
  _StorybridgeVideoProgressIndicatorState createState() =>
      _StorybridgeVideoProgressIndicatorState();
}

class _StorybridgeVideoProgressIndicatorState
    extends State<StorybridgeVideoProgressIndicator> {
  double _sliderSize = 0;
  double _sliderPositionValue = 0;
  double _sliderBufferedValue = 0;
  double _sliderLockedValue = 0;
  int _videoDuration = 1;
  bool _isBeingDragged = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(updateSeeker);
    if (widget.isSkippable) {
      _sliderLockedValue = 1;
    } else {
      _sliderLockedValue = 0;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(updateSeeker);
    super.dispose();
  }

  Future<void> updateSeeker() async {
    if (!widget.isSkippable && !_isBeingDragged) {
      _sliderLockedValue = max(_sliderPositionValue, _sliderLockedValue);
    }
    if (!widget.controller.value.isInitialized) return;
    _videoDuration = widget.controller.value.duration.inSeconds;
    setState(() {
      int videoPosition = widget.controller.value.position.inSeconds;
      _sliderPositionValue = videoPosition / _videoDuration;
      if (_sliderPositionValue == 1) {
        if (widget.onVideoEnd != null) {
          widget.onVideoEnd!();
        }
      }
      List<DurationRange> bufferedSections = widget.controller.value.buffered;
      for (DurationRange i in bufferedSections) {
        // if the track is current being played at the moment
        if (videoPosition > i.start.inSeconds &&
            videoPosition < i.end.inSeconds) {
          _sliderBufferedValue = i.end.inSeconds / _videoDuration;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 200),
        tween: Tween<double>(begin: 0, end: _sliderSize),
        curve: Curves.ease,
        builder: (BuildContext _, double animMouseHover, Widget? __) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(maxHeight: 50),
              child: MouseRegion(
                onEnter: (PointerEnterEvent _) {
                  setState(() {
                    _sliderSize = 1;
                  });
                },
                onExit: (PointerExitEvent _) {
                  setState(() {
                    if (!_isBeingDragged) {
                      _sliderSize = 0;
                    }
                  });
                },
                child: Stack(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                          disabledInactiveTrackColor: const Color(0xFFFFFFFF),
                          disabledActiveTrackColor: const Color(0x20FF0000),
                          trackHeight: animMouseHover * 5 + 5,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 0)),
                      child: Slider(
                        value: _sliderLockedValue,
                        onChanged: null,
                      ),
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                          thumbColor: Colors.white,
                          activeTrackColor: const Color(0x55FFFFFF),
                          inactiveTrackColor: Colors.transparent,
                          trackHeight: animMouseHover * 5 + 5,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 0)),
                      child: Slider(
                        value: _sliderBufferedValue,
                        onChanged: (double value) {},
                      ),
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                          inactiveTrackColor: Colors.transparent,
                          thumbColor: Storybridge_color.StorybridgeAccent,
                          trackHeight: animMouseHover * 5 + 5,
                          thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: animMouseHover * 10)),
                      child: Slider(
                        value: _sliderPositionValue,
                        onChanged: (double value) {
                          setState(() {
                            _sliderPositionValue = value;
                          });
                        },
                        onChangeStart: (double _) {
                          _isBeingDragged = true;
                          setState(() {
                            _sliderSize = 1;
                          });
                        },
                        onChangeEnd: (double _) {
                          _isBeingDragged = false;
                          setState(() {
                            _sliderSize = 0;
                          });
                          setState(() {
                            if (!widget.isSkippable) {
                              _sliderPositionValue =
                                  min(_sliderLockedValue, _sliderPositionValue);
                            }
                            if (!widget.controller.value.isInitialized) {
                              return;
                            }
                            widget.controller.seekTo(Duration(
                                seconds: (_sliderPositionValue * _videoDuration)
                                    .round()));
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
