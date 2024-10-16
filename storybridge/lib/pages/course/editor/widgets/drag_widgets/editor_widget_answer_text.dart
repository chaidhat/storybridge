import 'package:flutter/material.dart';
import 'package:mooc/storybridge.dart'; // Storybridge

import 'package:mooc/services/auditing_service.dart' as auditing_service;
import 'package:mooc/style/storybridge_colors.dart' as storybridge_color;

const widgetTypeAnswerText = "answerText";

class EditorWidgetAnswerText extends StatefulWidget implements EditorWidget {
  @override
  final bool reduceDropzoneSize = false;
  final _AnswerTextController controller = _AnswerTextController();

  @override
  late final EditorWidgetMetadata metadata;

  // constructor
  EditorWidgetAnswerText({Key? key, required this.editorWidgetData})
      : super(key: key);
  @override
  final EditorWidgetData editorWidgetData;

  // serialization
  @override
  void loadFromJson(Map<String, dynamic> json) {
    metadata = getMetadata(json, editorWidgetData);
    ;
    try {
      controller.quid = json["quid"];
      controller.questionController.text = json["question"];
      controller.answerHintController.text = json["answerHint"];
      controller.isLargeField = json["isLargeField"] == "true";
      controller.isNumericalField = json["isNumericalField"] == "true";
      controller.validationRegexController.text = json["validationRegex"];
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
        {"valueName": "answer", "valueType": "string"},
      ],
      "widgetType": widgetTypeAnswerText,
      "question": controller.questionController.text,
      "answerHint": controller.answerHintController.text,
      "isLargeField": controller.isLargeField.toString(),
      "isNumericalField": controller.isNumericalField.toString(),
      "validationRegex": controller.validationRegexController.text,
    };
  }

  @override
  Widget? getToolbar() {
    return _Toolbar(
      controller: controller,
    );
  }

  @override
  State<EditorWidgetAnswerText> createState() => _EditorWidgetAnswerTextState();
}

class _EditorWidgetAnswerTextState extends State<EditorWidgetAnswerText> {
  StorybridgeTextFieldController answerController =
      StorybridgeTextFieldController();
  void updateQuestion() {
    widget.editorWidgetData.onUpdate();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    String oldAnswerControllerText = answerController.text;
    answerController.addListener(() {
      if (widget.controller.isNumericalField) {
        try {
          double.parse(answerController.text);
        } catch (_) {
          answerController.text = oldAnswerControllerText;
        }
      }
      oldAnswerControllerText = answerController.text;
      auditing_service.setAuditDataAnswer(
          widget.controller.quid, {"answer": answerController.text});
    });
  }

  Future<dynamic> _load() async {
    dynamic data =
        await auditing_service.getAuditDataAnswer(widget.controller.quid);
    if (data != null) {
      answerController.text = data["answer"];
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
            return StorybridgeBoxLoading(height: 60, width: 270);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              !widget.controller.questionController.text.isEmpty
                  ? StorybridgeTextH2B(
                      widget.controller.questionController.text)
                  : Container(),
              Row(
                children: [
                  Flexible(
                    child: Container(
                      constraints: !widget.controller.isLargeField
                          ? const BoxConstraints(maxWidth: 300)
                          : null,
                      height: !widget.controller.isLargeField ? null : 110,
                      child: SizedBox(
                        height: 50,
                        child: OverflowBox(
                          alignment: Alignment.topCenter,
                          maxHeight: double.infinity,
                          child: widget.controller.autofillFormulaController
                                  .text.isEmpty
                              ? StorybridgeTextField(
                                  controller: answerController,
                                  label: widget
                                      .controller.answerHintController.text,
                                  isLarge: widget.controller.isLargeField,
                                  isEnabled:
                                      !widget.editorWidgetData.isAdminMode,
                                )
                              : const StorybridgeTile(
                                  useAltStyle: true,
                                  child: Center(
                                      child: StorybridgeTextP(
                                          "This will be autofilled."))),
                        ),
                      ),
                    ),
                  ),
                  widget.controller.isNumericalField
                      ? Tooltip(
                          message: "This input is numerical",
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Icon(Icons.numbers_rounded,
                                color: storybridge_color.lightGrey),
                          ),
                        )
                      : Container()
                ],
              ),
            ],
          );
        });
  }
}

class _AnswerTextController {
  String quid = "";
  StorybridgeTextFieldController questionController =
      StorybridgeTextFieldController();
  StorybridgeTextFieldController answerHintController =
      StorybridgeTextFieldController();
  StorybridgeTextFieldController autofillFormulaController =
      StorybridgeTextFieldController();
  StorybridgeTextFieldController validationRegexController =
      StorybridgeTextFieldController();
  bool isLargeField = false;
  bool isNumericalField = false;
  Function onUpdate = () {};

  _AnswerTextController() {
    questionController.addListener(() {
      onUpdate();
    });
    answerHintController.addListener(() {
      onUpdate();
    });
    autofillFormulaController.addListener(() {
      onUpdate();
    });
    validationRegexController.addListener(() {
      onUpdate();
    });
  }
}

class _AnswerTextSettings extends StatefulWidget {
  final _AnswerTextController controller;

  // constructor
  _AnswerTextSettings({
    Key? key,
    required this.controller,
  }) : super(key: key) {}

  @override
  State<_AnswerTextSettings> createState() => _AnswerTextSettingsState();
}

class _AnswerTextSettingsState extends State<_AnswerTextSettings> {
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
          StorybridgeTextField(
            label: "Answer Label",
            controller: widget.controller.answerHintController,
          ),
          StorybridgeCheckbox(
              label: "Large text field",
              value: widget.controller.isLargeField,
              onChanged: (bool? val) {
                setState(() {
                  widget.controller.isLargeField = val!;
                  widget.controller.onUpdate();
                });
              }),
          StorybridgeCheckbox(
              label: "Is numerical?",
              value: widget.controller.isNumericalField,
              onChanged: (bool? val) {
                setState(() {
                  widget.controller.isNumericalField = val!;
                  widget.controller.onUpdate();
                });
              }),
          const SizedBox(height: 10),
          /*
          const StorybridgeTextH2B("Autofill"),
          const SizedBox(height: 10),
          StorybridgeFormulaField(
              controller: widget.controller.autofillFormulaController),
          const StorybridgeTextH2B("Advanced Settings"),
          const SizedBox(height: 10),
          StorybridgeTextField(
            label: "Validation Regex",
          ),
              */
          const SizedBox(height: 30),
          StorybridgeTextP("quid: ${widget.controller.quid}"),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  // members of MyWidget
  final _AnswerTextController controller;

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
              content: _AnswerTextSettings(
                controller: controller,
              ),
            ),
          ),
        );
      },
    );
  }
}
