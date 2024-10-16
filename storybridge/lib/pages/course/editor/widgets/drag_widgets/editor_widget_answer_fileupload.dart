import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/services/auditing_service.dart' as auditing_service;
import 'package:mooc/style/scholarity_colors.dart' as scholarity_color;
import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/networking_service.dart' as networking_service;
import 'package:url_launcher/url_launcher.dart';

const widgetTypeAnswerFileupload = "answerFileupload";

class EditorWidgetAnswerFileupload extends StatefulWidget
    implements EditorWidget {
  @override
  final bool reduceDropzoneSize = false;
  final _AnswerFileuploadController controller = _AnswerFileuploadController();

  @override
  late final EditorWidgetMetadata metadata;

  // constructor
  EditorWidgetAnswerFileupload({Key? key, required this.editorWidgetData})
      : super(key: key);
  @override
  final EditorWidgetData editorWidgetData;

  // serialization
  @override
  void loadFromJson(Map<String, dynamic> json) {
    metadata = getMetadata(json, editorWidgetData);
    try {
      controller.quid = json["quid"];
      controller.questionController.text = json["question"];
      controller.fileExtensions.text = json["fileExtensions"];
      controller.allowMultipleFiles = json["allowMultipleFiles"];
    } catch (e) {}
  }

  @override
  void onCreate() {}

  @override
  void onRemove() {}

  @override
  Map<String, dynamic> saveToJson() {
    return {
      "metadata": metadata.encode(),
      "quid": controller.quid,
      "answerFormat": [
        {"valueName": "answer", "valueType": "object"},
      ],
      "widgetType": widgetTypeAnswerFileupload,
      "question": controller.questionController.text,
      "fileExtensions": controller.fileExtensions.text,
      "allowMultipleFiles": controller.allowMultipleFiles,
    };
  }

  @override
  Widget? getToolbar() {
    return _Toolbar(
      controller: controller,
    );
  }

  @override
  State<EditorWidgetAnswerFileupload> createState() =>
      _EditorWidgetAnswerFileuploadState();
}

class _EditorWidgetAnswerFileuploadState
    extends State<EditorWidgetAnswerFileupload> {
  FileUploadDisplayerController fileUploadDisplayerController =
      FileUploadDisplayerController();
  void updateQuestion() {
    widget.editorWidgetData.onUpdate();
    setState(() {});
  }

  Future<dynamic> _save() async {
    String uploadedFilenames =
        fileUploadDisplayerController.getUploadedFilenames();
    String uploadedImageIds =
        fileUploadDisplayerController.getUploadedImageIds();
    auditing_service.setAuditDataAnswer(widget.controller.quid, {
      "uploadedFilenames": uploadedFilenames,
      "uploadedImageIds": uploadedImageIds,
    });
  }

  Future<dynamic> _load() async {
    dynamic data =
        await auditing_service.getAuditDataAnswer(widget.controller.quid);
    if (data != null) {
      fileUploadDisplayerController.set(
          data["uploadedFilenames"], data["uploadedImageIds"]);
    }
    return true;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    widget.controller.onUpdate = updateQuestion;
    return FutureBuilder(
        future: _load(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData) {
            return const ScholarityBoxLoading(height: 60, width: 270);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              !widget.controller.questionController.text.isEmpty
                  ? ScholarityTextH2B(widget.controller.questionController.text)
                  : Container(),
              FileUploadDisplayer(
                  fileExtensions: widget.controller.fileExtensions.text,
                  allowMultipleFiles: widget.controller.allowMultipleFiles,
                  controller: fileUploadDisplayerController,
                  isAdminMode: widget.editorWidgetData.isAdminMode,
                  onUpdate: () async {
                    await _save();
                  })
            ],
          );
        });
  }
}

class _AnswerFileuploadController {
  String quid = "";
  ScholarityTextFieldController questionController =
      ScholarityTextFieldController();
  ScholarityTextFieldController fileExtensions =
      ScholarityTextFieldController();
  bool allowMultipleFiles = false;
  Function onUpdate = () {};

  _AnswerFileuploadController() {
    questionController.addListener(() {
      onUpdate();
    });
    fileExtensions.addListener(() {
      onUpdate();
    });
  }
}

class _AnswerFileuploadSettings extends StatefulWidget {
  final _AnswerFileuploadController controller;

  // constructor
  _AnswerFileuploadSettings({
    Key? key,
    required this.controller,
  }) : super(key: key) {}

  @override
  State<_AnswerFileuploadSettings> createState() =>
      _AnswerFileuploadSettingsState();
}

class _AnswerFileuploadSettingsState extends State<_AnswerFileuploadSettings> {
  // main build function
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScholarityIconButton(
              icon: Icons.close,
              onPressed: () {
                Navigator.pop(context);
              }),
          const SizedBox(height: 10),
          const ScholarityTextH2B("Question Settings"),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            child: ScholarityTextField(
              isLarge: true,
              label: "Question",
              controller: widget.controller.questionController,
            ),
          ),
          SizedBox(
            height: 110,
            child: ScholarityTextField(
              isLarge: true,
              label: "Allow File Extensions",
              hintText:
                  "(e.g. png, jpg). Leave blank to allow for all file extensions",
              controller: widget.controller.fileExtensions,
            ),
          ),
          ScholarityCheckbox(
              label: "Allow multiple files",
              value: widget.controller.allowMultipleFiles,
              onChanged: (bool val) {
                setState(() {
                  widget.controller.allowMultipleFiles = val;
                  widget.controller.onUpdate();
                });
              }),
          const SizedBox(height: 30),
          ScholarityTextP("quid: ${widget.controller.quid}"),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  // members of MyWidget
  final _AnswerFileuploadController controller;

  // constructor
  const _Toolbar({Key? key, required this.controller}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return ScholarityButton(
      text: "Edit question",
      invertedColor: true,
      padding: false,
      onPressed: () {
        scholarityShowDialog(
          context: context,
          builder: (BuildContext context) => ScholarityAlertDialogWrapper(
            child: ScholarityAlertDialog(
              content: _AnswerFileuploadSettings(
                controller: controller,
              ),
            ),
          ),
        );
      },
    );
  }
}

// myPage class which creates a state on call
class FileUploadDisplayer extends StatefulWidget {
  final String fileExtensions;
  final bool allowMultipleFiles;
  final FileUploadDisplayerController controller;
  final Function() onUpdate;
  final bool isAdminMode;
  const FileUploadDisplayer({
    Key? key,
    required this.fileExtensions,
    required this.allowMultipleFiles,
    required this.controller,
    required this.onUpdate,
    required this.isAdminMode,
  }) : super(key: key);

  @override
  _FileUploadDisplayerState createState() => _FileUploadDisplayerState();
}

class FileUploadDisplayerController {
  final List<FileUploadDisplayerFile> files = [];
  FileUploadDisplayerController();
  void set(String uploadedFilenames, String uploadedImageIds) {
    if (uploadedFilenames.isEmpty && uploadedImageIds.isEmpty) {
      return;
    }
    List<String> filenames = uploadedFilenames.split(",");
    List<String> imageIds = uploadedImageIds.split(",");
    if (filenames.length != imageIds.length) {
      throw Exception("filename and imageId not the same length!");
    }
    files.clear();
    for (int i = 0; i < filenames.length; i++) {
      if (imageIds[i] != "null") {
        files.add(FileUploadDisplayerFile(
            filename: filenames[i],
            imageId: int.parse(imageIds[i]),
            isUploading: false));
      }
    }
  }

  String getUploadedFilenames() {
    List<String> output = [];
    for (FileUploadDisplayerFile file in files) {
      output.add(file.filename);
    }
    return output.join(",");
  }

  String getUploadedImageIds() {
    List<String> output = [];
    for (FileUploadDisplayerFile file in files) {
      output.add(file.imageId.toString());
    }
    return output.join(",");
  }
}

class FileUploadDisplayerFile {
  final String filename;
  int? imageId;
  String? contentDataId;
  bool isUploading;
  FileUploadDisplayerFile({
    required this.filename,
    required this.imageId,
    required this.isUploading,
  }) {
    _load();
  }

  Future<void> _load() async {
    if (imageId != null) {
      Map<String, dynamic> response =
          await networking_api_service.getImage(imageId: imageId!);
      contentDataId = response["data"]["contentDataId"];
    }
  }

  Future<void> remove() async {
    if (isUploading || imageId == null) {
      return; // cannot remove while uploading.
    }
    await networking_api_service.removeImage(imageId: imageId!);
  }

  Future<void> download() async {
    if (isUploading || contentDataId == null) {
      return;
    }
    launchUrl(Uri.parse(
        "${networking_service.getApiUrl()}/?action=downloadImage&contentDataId=${contentDataId!}"));
  }
}

// myPage state
class _FileUploadDisplayerState extends State<FileUploadDisplayer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _uploadFiles() async {
    List<String> data = auditing_service.parseCommaData(widget.fileExtensions);
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: data.isNotEmpty ? data : null,
        withReadStream: true,
        allowMultiple: widget.allowMultipleFiles,
        withData: false);
    if (result != null) {
      for (PlatformFile file in result.files) {
        FileUploadDisplayerFile fileUploadDisplayerFile =
            FileUploadDisplayerFile(
                filename: Uri.encodeComponent(file.name),
                imageId: null,
                isUploading: true);
        widget.controller.files.add(fileUploadDisplayerFile);
        _uploadFile(file, fileUploadDisplayerFile);
      }
      setState(() {});
    }
  }

  Future<void> _uploadFile(PlatformFile file,
      FileUploadDisplayerFile fileUploadDisplayerFile) async {
    int? auditTaskId = auditing_service.getAuditTaskId();
    if (auditTaskId != null && !widget.isAdminMode) {
      // can upload
      int imageId = await networking_api_service.createImage(
          courseId: 0, courseElementId: 0, auditTaskId: auditTaskId);
      fileUploadDisplayerFile.imageId = imageId;
      Map<String, dynamic> response =
          await networking_api_service.getImage(imageId: imageId);
      String contentDataId = response["data"]["contentDataId"];
      fileUploadDisplayerFile.contentDataId = contentDataId;
      networking_service
          .serverUploadContent(contentDataId, file, () {})
          .then((_) async {
        setState(() {
          // done
          fileUploadDisplayerFile.isUploading = false;
          widget.onUpdate();
          setState(() {});
        });
        return;
      });
    } else {
      // is admin, can't actually upload
      await Future.delayed(const Duration(seconds: 1));
      // done
      fileUploadDisplayerFile.isUploading = false;
      widget.onUpdate();
      setState(() {});
    }
  }

  Future<void> _removeFile(int index) async {
    FileUploadDisplayerFile file = widget.controller.files[index];
    await file.remove();
    setState(() {
      widget.controller.files.removeAt(index);
      widget.onUpdate();
    });
  }

  Future<void> _downloadFile(int index) async {
    FileUploadDisplayerFile file = widget.controller.files[index];
    if (file.isUploading) {
      return; // cannot remove while uploading.
    }
    file.download();
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    if (widget.controller.files.isNotEmpty) {
      return Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      List.generate(widget.controller.files.length, (int i) {
                    FileUploadDisplayerFile file = widget.controller.files[i];
                    return ScholarityHoverButton(
                      button: !file.isUploading
                          ? ScholarityIconButton(
                              icon: Icons.close,
                              onPressed: () async {
                                // delete if not is uploading
                                _removeFile(i);
                              },
                            )
                          : Container(),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 50),
                        child: InkWell(
                          onTap: () {
                            // download if not is uploading
                            if (!widget.isAdminMode) {
                              _downloadFile(i);
                            } else {
                              showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      _FileCannotBeDownloadedForAuditTemplates());
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(
                                    !file.isUploading
                                        ? Icons.description_rounded
                                        : Icons.sync_rounded,
                                    color: scholarity_color.scholarityAccent),
                                const SizedBox(width: 10),
                                Container(
                                    constraints:
                                        const BoxConstraints(maxWidth: 200),
                                    child: ScholarityTextP(
                                        Uri.decodeComponent(file.filename))),
                                const SizedBox(width: 30),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 10),
              !widget.allowMultipleFiles
                  ? Container()
                  : ScholarityIconButton(
                      icon: Icons.add,
                      onPressed: () {
                        _uploadFiles();
                      },
                    ),
            ],
          ),
        ],
      );
    } else {
      return ScholarityButton(
          icon: Icons.attach_file_rounded,
          invertedColor: true,
          text: "File Upload",
          onPressed: () async {
            _uploadFiles();
          });
    }
  }
}

class _FileCannotBeDownloadedForAuditTemplates extends StatelessWidget {
  // constructor
  const _FileCannotBeDownloadedForAuditTemplates({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return ScholarityAlertDialogWrapper(
      child: ScholarityAlertDialog(
        title: const ScholarityTextH2B("Cannot download file in test mode"),
        content: SizedBox(
          height: 150,
          width: 300,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const ScholarityTextP(
                "Please create an audit report to actually download the file."),
            Expanded(child: Container()),
            Row(
              children: [
                ScholarityButton(
                    text: "Dismiss",
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ],
            )
          ]),
        ),
      ),
    );
  }
}
