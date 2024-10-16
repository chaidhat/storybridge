import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/services/auditing_service.dart' as auditing_service;

const widgetTypeAnswerButtons = "answerButtons";

class EditorWidgetAnswerButtons extends StatefulWidget implements EditorWidget {
  @override
  final bool reduceDropzoneSize = false;
  final AnswerButtonsController controller = AnswerButtonsController();

  @override
  late final EditorWidgetMetadata metadata;

  // constructor
  EditorWidgetAnswerButtons({Key? key, required this.editorWidgetData})
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
      controller.buttonsController.text = json["buttons"];
      controller.hasOtherField = json["hasOtherField"];
      controller.canMultiselect = json["canMultiselect"];
      controller.dataSource.deserialize(json["dataSource"]);
    } catch (_) {}
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
        {"valueName": "selectedOtherField", "valueType": "boolean"},
        {"valueName": "otherField", "valueType": "string"},
      ],
      "widgetType": widgetTypeAnswerButtons,
      "question": controller.questionController.text,
      "buttons": controller.buttonsController.text,
      "hasOtherField": controller.hasOtherField,
      "canMultiselect": controller.canMultiselect,
      "dataSource": controller.dataSource.serialize(),
    };
  }

  @override
  Widget? getToolbar() {
    return _Toolbar(
      controller: controller,
      organizationId: editorWidgetData.courseData.organizationId,
    );
  }

  @override
  State<EditorWidgetAnswerButtons> createState() =>
      _EditorWidgetAnswerButtonsState();
}

class _EditorWidgetAnswerButtonsState extends State<EditorWidgetAnswerButtons> {
  List<bool> _answers = [];
  ScholarityTextFieldController _otherFieldController =
      ScholarityTextFieldController();
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

  Future<void> _updateAuditData() async {
    var ans = await widget.controller.dataSource.getEncodedFromAnswers(
        _answers, widget.editorWidgetData.courseData.organizationId);
    auditing_service.setAuditDataAnswer(widget.controller.quid, {
      "answer": ans,
      "selectedOtherField": _selectedOtherField,
      "otherField": _otherFieldController.text
    });
  }

  Future<dynamic> _load() async {
    dynamic data =
        await auditing_service.getAuditDataAnswer(widget.controller.quid);
    if (data != null) {
      try {
        _answers = await widget.controller.dataSource.getAnswersFromEncoded(
            data["answer"], widget.editorWidgetData.courseData.organizationId);
      } catch (e) {
        for (int i = 0; i < data["answer"].length; i++) {
          _answers.add(data["answer"][i]);
        }
      }
      _selectedOtherField = data["selectedOtherField"];
      _otherFieldController.text = data["otherField"];
    }
    var dataSourceGetDropdowns = await widget.controller.dataSource
        .getDropdowns(widget.editorWidgetData.courseData.organizationId);
    return dataSourceGetDropdowns;
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
              widget.controller.questionController.text.isNotEmpty
                  ? ScholarityTextH2B(widget.controller.questionController.text)
                  : Container(),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Wrap(
                    crossAxisAlignment: WrapCrossAlignment.start,
                    children: List.generate(snapshot.data.length, (int i) {
                      return IntrinsicWidth(
                        child: ScholarityButton(
                            text: snapshot.data[i],
                            invertedColor:
                                i < _answers.length ? _answers[i] : false,
                            onPressed: () {
                              if (widget.controller.canMultiselect) {
                                // can multiselect, so add it to the list of selections
                                bool value = !(i < _answers.length
                                    ? _answers[i]
                                    : false);
                                if (i < _answers.length) {
                                  _answers[i] = value;
                                } else {
                                  while (i >= _answers.length) {
                                    _answers.add(false);
                                  }
                                  _answers[i] = value;
                                }
                              } else {
                                // can NOT multiselect, so clear the entire list and set only that to true
                                _answers = [];
                                while (i >= _answers.length) {
                                  _answers.add(false);
                                }
                                _answers[i] = true;
                              }
                              _updateAuditData();
                              setState(() {});
                            }),
                      );
                    })),
                !widget.controller.hasOtherField
                    ? Container()
                    : ScholarityCheckbox(
                        label: "Add additional information",
                        value: _selectedOtherField,
                        onChanged: (bool val) {
                          _selectedOtherField = val;
                          _updateAuditData();
                          setState(() {});
                        }),
                !_selectedOtherField
                    ? Container()
                    : ScholarityTextField(
                        label: "Please specify",
                        controller: _otherFieldController,
                        isEnabled: !widget.editorWidgetData.isAdminMode,
                      ),
              ]),
            ],
          );
        });
  }
}

class AnswerButtonsController {
  String quid = "";
  ScholarityTextFieldController questionController =
      ScholarityTextFieldController();
  ScholarityTextFieldController buttonsController =
      ScholarityTextFieldController();
  final DataSource dataSource = DataSource();
  bool hasOtherField = false;
  bool canMultiselect = false;
  Function onUpdate = () {};

  AnswerButtonsController() {
    questionController.addListener(() {
      onUpdate();
    });
    buttonsController.addListener(() {
      onUpdate();
    });
    dataSource.addListener(() {
      onUpdate();
    });
  }
}

class _AnswerButtonsSettings extends StatefulWidget {
  final AnswerButtonsController controller;
  final int organizationId;

  // constructor
  _AnswerButtonsSettings({
    Key? key,
    required this.controller,
    required this.organizationId,
  }) : super(key: key) {}

  @override
  State<_AnswerButtonsSettings> createState() => _AnswerButtonsSettingsState();
}

class _AnswerButtonsSettingsState extends State<_AnswerButtonsSettings> {
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
          DatasourceEditor(
            dataSource: widget.controller.dataSource,
            organizationId: widget.organizationId,
          ),
          ScholarityCheckbox(
              label: "Allow 'other' field",
              value: widget.controller.hasOtherField,
              onChanged: (bool val) {
                setState(() {
                  widget.controller.hasOtherField = val;
                  widget.controller.onUpdate();
                });
              }),
          ScholarityCheckbox(
              label: "Allow multiple selections",
              value: widget.controller.canMultiselect,
              onChanged: (bool val) {
                setState(() {
                  widget.controller.canMultiselect = val;
                  widget.controller.onUpdate();
                });
              }),
          const SizedBox(height: 30),
          ScholarityTextP("quid: ${widget.controller.quid}"),
          ScholarityButton(
            text: "Save",
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  // members of MyWidget
  final AnswerButtonsController controller;
  final int organizationId;

  // constructor
  const _Toolbar(
      {Key? key, required this.controller, required this.organizationId})
      : super(key: key);

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
              content: _AnswerButtonsSettings(
                controller: controller,
                organizationId: organizationId,
              ),
            ),
          ),
        );
      },
    );
  }
}
