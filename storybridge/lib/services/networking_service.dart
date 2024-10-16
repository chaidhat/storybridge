import 'dart:typed_data';

import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mooc/consts.dart' as consts;
import 'package:mooc/services/error_service.dart' as error_service;
import 'package:file_picker/file_picker.dart';
import 'package:chunked_uploader/chunked_uploader.dart';
import 'package:dio/dio.dart';
import 'package:mooc/services/saving_telemetry_service.dart'
    as saving_telemetry_service;

String uriScheme = consts.getServerUriScheme();
String uriHost = consts.getServerUriHost();
int? uriPort = consts.getServerUriPort();

Future<Map<String, dynamic>> serverGet(
    String action, Map<String, String> queryParameters,
    {bool ignoreErrors = true}) async {
  saving_telemetry_service.indicateSaving();
  // add action to queries
  queryParameters["action"] = action;
  // form query
  final Uri requestUri = Uri(
    scheme: uriScheme,
    host: uriHost,
    port: uriPort,
  );
  // request query
  http.Response? response;
  try {
    response = await http.post(requestUri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(queryParameters));
  } catch (err) {
    print(err);
    saving_telemetry_service.indicateErrored();
    if (ignoreErrors) return {};
    throw error_service.ScholarityException("Something went wrong",
        description: "Cannot connect to the server.");
  }
  saving_telemetry_service.indicateSaved();

  print("${response.statusCode.toString()} ${queryParameters["action"]}");
  switch (response.statusCode) {
    case 200: // OK
      // take the response
      String resBodyStr = response.body;
      Map<String, dynamic> resBodyJson = jsonDecode(resBodyStr);
      return resBodyJson;
    case 400: // bad request  (client error)
      String resBodyStr = response.body;
      Map<String, dynamic> resBodyJson = jsonDecode(resBodyStr);
      saving_telemetry_service.indicateErrored();
      print("Error message: ${resBodyJson["message"]}");
      if (ignoreErrors) return {};
      throw error_service.ScholarityException(
        resBodyJson["message"],
        description: "400: Bad request, client error",
      );
    case 403: // forbidden    (user error)
      String resBodyStr = response.body;
      Map<String, dynamic> resBodyJson = jsonDecode(resBodyStr);
      if (ignoreErrors) return {};
      saving_telemetry_service.indicateErrored();
      if (resBodyJson["policy"] != null) {
        resBodyJson["errorData"]["policy"] = resBodyJson["policy"];
        throw error_service.ScholarityException(
            resBodyJson["errorData"]["message"],
            errorData: resBodyJson["errorData"],
            expandError: false);
      } else if (resBodyJson["message"] != null) {
        throw error_service.ScholarityException(resBodyJson["message"],
            expandError: false);
      } else {
        throw error_service.ScholarityException("Malformed error.",
            expandError: false);
      }
    case 500: // server error (server error)
      if (ignoreErrors) return {};
      saving_telemetry_service.indicateErrored();
      throw error_service.ScholarityException("Something went wrong",
          description: "500: Bad request, server error");
    default: // anything could happen
      if (ignoreErrors) return {};
      saving_telemetry_service.indicateErrored();
      throw error_service.ScholarityException("Something went wrong",
          description:
              "Can connect to server but received an unknown status code");
  }
}

bool compressing = false;
Map<String, dynamic> uploadStatus = {};
Future<Map<String, double?>> getContentUploadProgress(
    String contentDataId) async {
  if (compressing) {
    return {
      'progress': double.parse((await serverGet("getCompressionStatus",
          {'contentDataId': contentDataId}))['compressionStatus']),
      'isCompressing': 1
    };
  } else
    return {'progress': uploadStatus[contentDataId], 'isCompressing': 0};
}

Future<void> serverUploadContent(String contentDataId, PlatformFile file,
    Function() startedUploading) async {
  final Uri uploadUri = Uri(
    scheme: uriScheme,
    host: uriHost,
    port: uriPort,
    queryParameters: {
      "action": "uploadContent",
      "contentDataId": contentDataId,
      "fileExt": file.extension
    },
  );
  var uploader =
      ChunkedUploader(Dio(BaseOptions(baseUrl: uploadUri.toString())));

  bool isStartOfUpload = true;
  await uploader.upload(
      fileDataStream: file.readStream!,
      fileName: "${contentDataId}.${file.extension}",
      fileSize: file.size,
      path: '',
      maxChunkSize: 100000000, // 300 MB
      onUploadProgress: (progress) {
        // call startedUploading only on the first upload
        if (isStartOfUpload) {
          startedUploading();
          isStartOfUpload = false;
        }
        uploadStatus[contentDataId] = double.parse(progress.toStringAsFixed(3));
      });

  final Uri finishUri = Uri(
    scheme: uriScheme,
    host: uriHost,
    port: uriPort,
    queryParameters: {
      "action": "doneUploadContent",
      "contentDataId": contentDataId,
      "fileExt": file.extension
    },
  );
  compressing = true;
  await http.Request('POST', finishUri).send();

  uploadStatus.remove(contentDataId);
  compressing = false;
}

String getApiUrl() {
  return "$uriScheme://$uriHost${uriPort != null ? ":${uriPort}" : ""}";
}

Future<dynamic> serverUploadBytes(Uint8List image, String contentDataId) async {
  final Uri url = Uri(
    scheme: uriScheme,
    host: uriHost,
    port: uriPort,
    path: "/upload",
    queryParameters: {
      "action": "uploadContentBytes",
      "contentDataId": contentDataId,
      "fileExt": "png"
    },
  );
  var request = http.MultipartRequest("POST", url);
  request.files.add(http.MultipartFile.fromBytes("file", image,
      filename: contentDataId, contentType: MediaType("video", "mp4")));

  await request.send();
}
