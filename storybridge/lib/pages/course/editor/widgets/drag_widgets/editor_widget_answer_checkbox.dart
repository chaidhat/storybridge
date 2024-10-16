import 'package:flutter/material.dart';
import 'package:mooc/storybridge.dart'; // Storybridge

import 'package:mooc/services/auditing_service.dart' as auditing_service;

const widgetTypeAnswerCheckbox = "answerCheckbox";

class EditorWidgetAnswerCheckbox extends StatefulWidget
    implements EditorWidget {
  @override
  final bool reduceDropzoneSize = false;
  final _AnswerCheckboxController _controller = _AnswerCheckboxController();

  @override
  late final EditorWidgetMetadata metadata;

  // constructor
  EditorWidgetAnswerCheckbox({Key? key, required this.editorWidgetData})
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
      _controller.checkboxesController.text = json["checkboxes"];
      _controller.hasOtherField = json["hasOtherField"];
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
        {"valueName": "answer", "valueType": "object"},
        {"valueName": "selectedOtherField", "valueType": "boolean"},
        {"valueName": "otherField", "valueType": "string"},
      ],
      "widgetType": widgetTypeAnswerCheckbox,
      "question": _controller.questionController.text,
      "checkboxes": _controller.checkboxesController.text,
      "hasOtherField": _controller.hasOtherField,
    };
  }

  @override
  Widget? getToolbar() {
    return _Toolbar(
      controller: _controller,
    );
  }

  @override
  State<EditorWidgetAnswerCheckbox> createState() =>
      _EditorWidgetAnswerCheckboxState();
}

class _EditorWidgetAnswerCheckboxState
    extends State<EditorWidgetAnswerCheckbox> {
  List<bool> _answers = [];
  StorybridgeTextFieldController _otherFieldController =
      StorybridgeTextFieldController();
  bool _selectedOtherField = false;
  void updateQuestion() {
    widget.editorWidgetData.onUpdate();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _otherFieldController.addListener(() {
      _updateAuditData();
    });
  }

  void _updateAuditData() {
    auditing_service.setAuditDataAnswer(widget._controller.quid, {
      "answer": _answers,
      "selectedOtherField": _selectedOtherField,
      "otherField": _otherFieldController.text
    });
  }

  Future<dynamic> _load() async {
    dynamic data =
        await auditing_service.getAuditDataAnswer(widget._controller.quid);
    if (data != null) {
      _answers = [];
      try {
        for (int i = 0; i < data["answer"].length; i++) {
          _answers.add(data["answer"][i]);
        }
        _selectedOtherField = data["selectedOtherField"];
        _otherFieldController.text = data["otherField"];
      } catch (e) {}
    }
    return true;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    widget._controller.onUpdate = updateQuestion;
    return FutureBuilder(
        future: _load(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData) {
            return StorybridgeBoxLoading(height: 60, width: 270);
          }
          var data = auditing_service
              .parseCommaData(widget._controller.checkboxesController.text);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              !widget._controller.questionController.text.isEmpty
                  ? StorybridgeTextH2B(
                      widget._controller.questionController.text)
                  : Container(),
              Column(
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(data.length, (int i) {
                        return StorybridgeCheckbox(
                            label: data[i],
                            value: i < _answers.length ? _answers[i] : false,
                            onChanged: (bool? value) {
                              if (i < _answers.length) {
                                _answers[i] = value ?? false;
                              } else {
                                while (i >= _answers.length) {
                                  _answers.add(false);
                                }
                                _answers[i] = value ?? false;
                              }
                              _updateAuditData();
                              setState(() {});
                            });
                      })),
                  !widget._controller.hasOtherField
                      ? Container()
                      : StorybridgeCheckbox(
                          label: "Other (please specify)",
                          value: _selectedOtherField,
                          onChanged: (bool val) {
                            _selectedOtherField = val;
                            _updateAuditData();
                            setState(() {});
                          }),
                  !_selectedOtherField
                      ? Container()
                      : StorybridgeTextField(
                          label: "Please specify",
                          controller: _otherFieldController,
                          isEnabled: !widget.editorWidgetData.isAdminMode,
                        ),
                ],
              ),
            ],
          );
        });
  }
}

class _AnswerCheckboxController {
  String quid = "";
  StorybridgeTextFieldController questionController =
      StorybridgeTextFieldController();
  StorybridgeTextFieldController checkboxesController =
      StorybridgeTextFieldController();
  bool hasOtherField = false;
  Function onUpdate = () {};

  _AnswerCheckboxController() {
    questionController.addListener(() {
      onUpdate();
    });
    checkboxesController.addListener(() {
      onUpdate();
    });
  }
}

class _AnswerCheckboxSettings extends StatefulWidget {
  final _AnswerCheckboxController controller;

  // constructor
  _AnswerCheckboxSettings({
    Key? key,
    required this.controller,
  }) : super(key: key) {}

  @override
  State<_AnswerCheckboxSettings> createState() =>
      _AnswerCheckboxSettingsState();
}

class _AnswerCheckboxSettingsState extends State<_AnswerCheckboxSettings> {
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
              controller: widget.controller.questionController,
            ),
          ),
          const StorybridgeTextP("Please separate selections with a comma"),
          SizedBox(
            height: 110,
            child: StorybridgeTextField(
              isLarge: true,
              label: "Checkboxes, separated by commas",
              hintText: "alice, bob, charlie",
              controller: widget.controller.checkboxesController,
            ),
          ),
          StorybridgeCheckbox(
              label: "Allow 'other' field",
              value: widget.controller.hasOtherField,
              onChanged: (bool val) {
                setState(() {
                  widget.controller.hasOtherField = val;
                  widget.controller.onUpdate();
                });
              }),
          const SizedBox(height: 30),
          StorybridgeTextP("quid: ${widget.controller.quid}"),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  // members of MyWidget
  final _AnswerCheckboxController controller;

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
              content: _AnswerCheckboxSettings(
                controller: controller,
              ),
            ),
          ),
        );
      },
    );
  }
}
