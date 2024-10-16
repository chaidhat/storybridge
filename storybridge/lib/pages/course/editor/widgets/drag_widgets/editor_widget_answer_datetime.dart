import 'package:flutter/material.dart';
import 'package:mooc/storybridge.dart'; // Storybridge

import 'package:mooc/services/auditing_service.dart' as auditing_service;

const widgetTypeAnswerDatetime = "answerDatetime";

class EditorWidgetAnswerDatetime extends StatefulWidget
    implements EditorWidget {
  @override
  final bool reduceDropzoneSize = false;
  final _AnswerDatetimeController _controller = _AnswerDatetimeController();

  @override
  late final EditorWidgetMetadata metadata;

  // constructor
  EditorWidgetAnswerDatetime({Key? key, required this.editorWidgetData})
      : super(key: key);
  @override
  final EditorWidgetData editorWidgetData;

  // serialization
  @override
  void loadFromJson(Map<String, dynamic> json) {
    metadata = getMetadata(json, editorWidgetData);
    ;
    try {
      _controller.quid = json["quid"];
      _controller.questionController.text = json["question"];
      _controller.datetimeMode.text = json["datetimeMode"];
      _controller.autofillMode.text = json["autofillMode"];
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
      "quid": _controller.quid,
      "answerFormat": [
        {"valueName": "date", "valueType": "datetime"},
        {"valueName": "time", "valueType": "datetime"},
      ],
      "widgetType": widgetTypeAnswerDatetime,
      "question": _controller.questionController.text,
      "datetimeMode": _controller.datetimeMode.text,
      "autofillMode": _controller.autofillMode.text,
    };
  }

  @override
  Widget? getToolbar() {
    return _Toolbar(
      controller: _controller,
    );
  }

  @override
  State<EditorWidgetAnswerDatetime> createState() =>
      _EditorWidgetAnswerDatetimeState();
}

class _EditorWidgetAnswerDatetimeState
    extends State<EditorWidgetAnswerDatetime> {
  DateTime dateController = DateTime.now();
  TimeOfDay timeController = TimeOfDay.now();
  void updateQuestion() {
    widget.editorWidgetData.onUpdate();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  Future<dynamic> _load() async {
    dynamic data =
        await auditing_service.getAuditDataAnswer(widget._controller.quid);
    if (data != null) {
      try {
        dateController = DateTime.parse(data["date"]);
        String s = data["time"];
        timeController = TimeOfDay(
            hour: int.parse(
                s.split(":")[0].substring(s.split(":")[0].length - 2)),
            minute: int.parse(s.split(":")[1].substring(0, 2)));
      } catch (e) {}
    }
    return true;
  }

  void _updateAuditData() {
    auditing_service.setAuditDataAnswer(widget._controller.quid,
        {"date": dateController.toString(), "time": timeController.toString()});
    setState(() {});
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    widget._controller.onUpdate = updateQuestion;
    return FutureBuilder(
        future: _load(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData) {
            return const StorybridgeBoxLoading(height: 60, width: 270);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              !widget._controller.questionController.text.isEmpty
                  ? StorybridgeTextH2B(
                      widget._controller.questionController.text)
                  : Container(),
              SizedBox(
                height: 50,
                child: Row(
                  children: [
                    ((widget._controller.datetimeMode.text ==
                                "show date and time" ||
                            widget._controller.datetimeMode.text ==
                                "show date only")
                        ? Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: StorybridgeDatePicker(
                              label: "",
                              date: dateController,
                              onChanged: (DateTime newDate) {
                                dateController = newDate;
                                _updateAuditData();
                              },
                            ),
                          )
                        : Container()),
                    ((widget._controller.datetimeMode.text ==
                                "show date and time" ||
                            widget._controller.datetimeMode.text ==
                                "show time only")
                        ? StorybridgeTimePicker(
                            label: "",
                            tod: timeController,
                            onChanged: (TimeOfDay newTod) {
                              timeController = newTod;
                              _updateAuditData();
                            },
                          )
                        : Container()),
                  ],
                ),
              ),
            ],
          );
        });
  }
}

class _AnswerDatetimeController {
  String quid = "";
  StorybridgeTextFieldController questionController =
      StorybridgeTextFieldController();
  StorybridgeTextFieldController datetimeMode =
      StorybridgeTextFieldController();
  StorybridgeTextFieldController autofillMode =
      StorybridgeTextFieldController();
  Function onUpdate = () {};

  _AnswerDatetimeController() {
    questionController.addListener(() {
      onUpdate();
    });
    datetimeMode.addListener(() {
      onUpdate();
    });
    autofillMode.addListener(() {
      onUpdate();
    });
  }
}

class _AnswerDatetimeSettings extends StatelessWidget {
  final _AnswerDatetimeController controller;

  // constructor
  _AnswerDatetimeSettings({
    Key? key,
    required this.controller,
  }) : super(key: key) {}

  // main build function
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StorybridgeIconButton(
              icon: Icons.close,
              onPressed: () {
                Navigator.pop(context);
              }),
          const SizedBox(height: 10),
          const StorybridgeTextH2B("Question Settings"),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            child: StorybridgeTextField(
              isLarge: true,
              label: "Question",
              controller: controller.questionController,
            ),
          ),
          StorybridgeDropdown(
            label: "Pick",
            dropdownTypes: const [
              "show date and time",
              "show date only",
              "show time only"
            ],
            controller: controller.datetimeMode,
          ),
          const SizedBox(height: 30),
          StorybridgeDropdown(
            label: "Autofill",
            dropdownTypes: const [
              "none",
              "automatically set to date created",
              "automatically set to date submitted",
            ],
            controller: controller.autofillMode,
          ),
          const SizedBox(height: 30),
          StorybridgeTextP("quid: ${controller.quid}"),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  // members of MyWidget
  final _AnswerDatetimeController controller;

  // constructor
  const _Toolbar({Key? key, required this.controller}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgeButton(
      text: "Edit question",
      invertedColor: true,
      padding: false,
      onPressed: () {
        storybridgeShowDialog(
          context: context,
          builder: (BuildContext context) => StorybridgeAlertDialogWrapper(
            child: StorybridgeAlertDialog(
              content: _AnswerDatetimeSettings(
                controller: controller,
              ),
            ),
          ),
        );
      },
    );
  }
}
