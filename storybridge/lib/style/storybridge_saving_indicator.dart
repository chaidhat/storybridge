import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mooc/style/storybridge_colors.dart' as storybridge_color;
import 'package:mooc/services/saving_telemetry_service.dart'
    as saving_telemetry_service;

// myPage class which creates a state on call
class StorybridgeSavingIndicator extends StatefulWidget {
  const StorybridgeSavingIndicator({Key? key}) : super(key: key);

  @override
  _StorybridgeSavingIndicatorState createState() =>
      _StorybridgeSavingIndicatorState();
}

// myPage state
class _StorybridgeSavingIndicatorState
    extends State<StorybridgeSavingIndicator> {
  saving_telemetry_service.SaveState saveState =
      saving_telemetry_service.SaveState.notSaved;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 500),
        (Timer t) => checkForNewSharedLists());
  }

  void checkForNewSharedLists() {
    if (saving_telemetry_service.saveState != saveState) {
      setState(() {
        saveState = saving_telemetry_service.saveState;
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity:
            saveState == saving_telemetry_service.SaveState.notSaved ? 0 : 1,
        child: Builder(builder: (context) {
          switch (saveState) {
            case saving_telemetry_service.SaveState.notSaved:
              return Container();
            case saving_telemetry_service.SaveState.saving:
              return Tooltip(
                message: "Saving...",
                child: Icon(Icons.cloud_sync_rounded,
                    color: storybridge_color.grey),
              );
            case saving_telemetry_service.SaveState.saved:
              return Tooltip(
                message: "Saved to cloud",
                child: Icon(Icons.cloud_done_outlined,
                    color: storybridge_color.grey),
              );
            case saving_telemetry_service.SaveState.errored:
              return Tooltip(
                message: "Error whilst saving",
                child: Icon(Icons.warning_rounded,
                    color: storybridge_color.storybridgeAccent),
              );
          }
        }));
  }
}
