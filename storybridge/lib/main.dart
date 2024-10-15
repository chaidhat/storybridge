import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

/// An example of using the plugin, controlling lifecycle and playback of the
/// video.

//import 'package:video_player/video_player.dart';
//import 'package:mooc/style/widgets/video_player/video_progress_indicator.dart';
import 'package:mooc/route.dart';
import 'package:mooc/style/Storybridge_colors.dart' as Storybridge_color;

import 'package:mooc/services/error_service.dart' as error_service;
import 'package:mooc/services/translation_service.dart' as translation_service;
import 'package:mooc/services/camera_service.dart' as camera_service;

Future<void> main() async {
  translation_service.getStorageLanguage();
  camera_service.initCameraEnvironment();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Storybridge', // name decided on 23/05/2022
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            // Status bar color
            statusBarColor: Colors.white,

            // Status bar brightness (optional)
            statusBarIconBrightness:
                Brightness.dark, // For Android (dark icons)
            statusBarBrightness: Brightness.light, // For iOS (dark icons)
          ),
        ),
        fontFamily: "Inter",
        primarySwatch: Storybridge_color.createMaterialColor(
            Storybridge_color.StorybridgeAccent),
        scaffoldBackgroundColor: Storybridge_color.backgroundDim,
        visualDensity: VisualDensity
            .adaptivePlatformDensity, /*scaffoldBackgroundColor: const Color(0xFF161b22)*/
      ),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
      navigatorKey:
          error_service.navigatorKey, // Setting a global key for error service
    ),
  );
}
