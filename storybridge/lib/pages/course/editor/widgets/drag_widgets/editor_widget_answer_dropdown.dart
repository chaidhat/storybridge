import 'package:flutter/material.dart';
import 'package:mooc/Storybridge.dart'; // Storybridge

import 'package:mooc/services/auditing_service.dart' as auditing_service;

const widgetTypeAnswerDropdown = "answerDropdown";

class EditorWidgetAnswerDropdown extends StatefulWidget
    implements EditorWidget {
  @override
  final bool reduceDropzoneSize = false;
  final AnswerDropdownController controller = AnswerDropdownController();

  @override
  late final EditorWidgetMetadata metadata;

  // constructor
  EditorWidgetAnswerDropdown({Key? key, required this.editorWidgetData})
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
      controller.dropdownController.text =
          json["dropdown"]; // backwards compatibility
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
        {"valueName": "answer", "valueType": "string"},
      ],
      "widgetType": widgetTypeAnswerDropdown,
      "question": controller.questionController.text,
      "dropdown": controller.dropdownController.text, // backwards compatibility
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
  State<EditorWidgetAnswerDropdown> createState() =>
      _EditorWidgetAnswerDropdownState();
}

class _EditorWidgetAnswerDropdownState
    extends State<EditorWidgetAnswerDropdown> {
  StorybridgeTextFieldController answerController =
      StorybridgeTextFieldController();
  void updateQuestion() {
    widget.editorWidgetData.onUpdate();
    setState(() {});
  }

  Map<String, int> _dropdownTypes = {};
  int? _selectedIndex;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _save() async {
    // encode answerController text to something the auditing service would be happy about.
    List<bool> input = [];
    for (int i = 0; i < _dropdownTypes.length; i++) {
      input.add(false);
    }
    if (_selectedIndex != null) {
      input[_selectedIndex!] = true;
    }
    var ans = await widget.controller.dataSource.getEncodedFromAnswers(
        input, widget.editorWidgetData.courseData.organizationId);
    auditing_service
        .setAuditDataAnswer(widget.controller.quid, {"answer": ans});
  }

  Future<dynamic> _load() async {
    // get dropdowns
    List<String> dropdownTypesUncleaned = await widget.controller.dataSource
        .getDropdowns(widget.editorWidgetData.courseData.organizationId);
    _dropdownTypes.clear();
    for (int i = 0; i < dropdownTypesUncleaned.length; i++) {
      _dropdownTypes[dropdownTypesUncleaned[i]] = i;
    }

    // parse answer
    dynamic data =
        await auditing_service.getAuditDataAnswer(widget.controller.quid);
    if (data != null) {
      try {
        List<bool> input = await widget.controller.dataSource
            .getAnswersFromEncoded(data["answer"],
                widget.editorWidgetData.courseData.organizationId);
        answerController.text = "";
        _selectedIndex = null;
        for (int i = 0; i < input.length; i++) {
          if (input[i]) {
            answerController.text = dropdownTypesUncleaned[i];
            _selectedIndex = i;
            break;
          }
        }
      } catch (e) {
        answerController.text = "";
        _selectedIndex = null;
      }
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
            return const StorybridgeBoxLoading(height: 60, width: 270);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.controller.questionController.text.isNotEmpty
                  ? StorybridgeTextH2B(
                      widget.controller.questionController.text)
                  : Container(),
              SizedBox(
                height: 50,
                child: OverflowBox(
                  alignment: Alignment.topCenter,
                  maxHeight: double.infinity,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: StorybridgeDropdown(
                      controller: answerController,
                      label: "",
                      mappedDropdownTypes: _dropdownTypes,
                      onSubmit: (a) {
                        _selectedIndex = a;
                        _save();
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }
}

class AnswerDropdownController {
  String quid = "";
  StorybridgeTextFieldController questionController =
      StorybridgeTextFieldController();
  StorybridgeTextFieldController dropdownController =
      StorybridgeTextFieldController();
  final DataSource dataSource = DataSource();
  Function onUpdate = () {};

  AnswerDropdownController() {
    questionController.addListener(() {
      onUpdate();
    });
    dataSource.addListener(() {
      onUpdate();
    });
  }
}

class _AnswerDropdownSettings extends StatefulWidget {
  final AnswerDropdownController controller;
  final int organizationId;

  const _AnswerDropdownSettings({
    Key? key,
    required this.controller,
    required this.organizationId,
  }) : super(key: key);

  @override
  State<_AnswerDropdownSettings> createState() =>
      _AnswerDropdownSettingsState();
}

class _AnswerDropdownSettingsState extends State<_AnswerDropdownSettings> {
  Future<dynamic> _load() async {
    return true;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _load(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return const StorybridgeBoxLoading(height: 300, width: 500);
          }
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
                DatasourceEditor(
                  dataSource: widget.controller.dataSource,
                  organizationId: widget.organizationId,
                ),
                const SizedBox(height: 30),
                StorybridgeTextP("quid: ${widget.controller.quid}"),
              ],
            ),
          );
        });
  }
}

class _Toolbar extends StatelessWidget {
  // members of MyWidget
  final AnswerDropdownController controller;
  final int organizationId;

  // constructor
  const _Toolbar(
      {Key? key, required this.controller, required this.organizationId})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgeButton(
      text: "Edit question",
      invertedColor: true,
      padding: false,
      onPressed: () {
        StorybridgeShowDialog(
          context: context,
          builder: (BuildContext context) => StorybridgeAlertDialogWrapper(
            child: StorybridgeAlertDialog(
              content: _AnswerDropdownSettings(
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
