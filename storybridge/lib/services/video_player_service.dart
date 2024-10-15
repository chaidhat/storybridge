import 'package:video_player/video_player.dart';

List<VideoPlayerController> _videoPlayerControllers = [];
void onNavigationChange() {
  for (VideoPlayerController vpc in _videoPlayerControllers) {
    vpc.pause();
  }
}

void registerVideoController(VideoPlayerController vpc) {
  _videoPlayerControllers.add(vpc);
}

void deregisterVideoController(VideoPlayerController vpc) {
  _videoPlayerControllers.remove(vpc);
}
