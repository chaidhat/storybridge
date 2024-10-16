import 'dart:async';
import 'package:image/image.dart' as img;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/services/networking_service.dart' as networking_service;

late CameraDescription globalCamera;

Future<void> initCameraEnvironment() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();
}

Future<void> initCameras() async {
  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;
  globalCamera = firstCamera;
  await Future.delayed(const Duration(seconds: 1));
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  final Future<String> Function() onPictureTaken;
  final void Function() onDone;

  const TakePictureScreen({
    super.key,
    required this.onPictureTaken,
    required this.onDone,
  });

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      globalCamera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      height: 500,
      child: Scaffold(
        appBar: AppBar(title: const ScholarityTextBasic('Take a picture')),
        // You must wait until the controller is initialized before displaying the
        // camera preview. Use a FutureBuilder to display a loading spinner until the
        // controller has finished initializing.
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && !_loading) {
              // If the Future is complete, display the preview.
              return CameraPreview(_controller);
            } else {
              // Otherwise, display a loading indicator.
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          // Provide an onPressed callback.
          onPressed: () async {
            // Take the Picture in a try / catch block. If anything goes wrong,
            // catch the error.
            try {
              setState(() {
                _loading = true;
              });
              // Ensure that the camera is initialized.
              await _initializeControllerFuture;

              // Attempt to take a picture and get the file `image`
              // where it was saved.
              final image = await _controller.takePicture();
              String contentDataId = await widget.onPictureTaken();

              if (!context.mounted) return;

              final imgBytes = await image.readAsBytes();

              img.Image _img = img.decodeImage(imgBytes)!;
              final jpgBytes = img.encodeJpg(_img);

              await networking_service.serverUploadBytes(
                  jpgBytes, contentDataId);

/*
              for (int i = 0; i < jpgBytes.length; i++) {
                out += String.fromCharCode(jpgBytes[i]);
              }
              await networking_api_service.uploadContentBytes(
                contentDataId: widget.contentDataId,
                fileData: out,
                fileExt: "jpg",
              );
              */
              widget.onDone();
              Navigator.pop(context);
            } catch (e) {
              // If an error occurs, log the error to the console.
              print(e);
            }
          },
          child: const Icon(Icons.camera_alt),
        ),
      ),
    );
  }
}
