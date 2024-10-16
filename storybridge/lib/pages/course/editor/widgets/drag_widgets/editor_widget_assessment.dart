import 'dart:convert';
import 'dart:math';

import 'package:dotted_border/dotted_border.dart';

import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/pages/course/editor/widgets/editor_widgets.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_column.dart';

import 'package:mooc/style/scholarity_colors.dart' as scholarity_color;
import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/error_service.dart' as error_service;
import 'package:mooc/services/course_navigation_service.dart'
    as course_navigation_service;

// myPage class which creates a state on call
const widgetTypeAssessment = "assessment";

// ignore: unused_field
enum _AccountActions { a }

/*

DOCUMENTAITON FOR ALL ASSESSMENT DATA STORAGE CAN BE FOUND IN DOCS
    /docs/readme-assessment-standard.txt

*/

class _AssessmentMetaData {
  int weighting = 0;
  int minGrade = 0;

  void setDefaultValues() {
    weighting = 100;
    minGrade = 60;
  }
}

// ignore: must_be_immutable
class EditorWidgetAssessment extends StatefulWidget implements EditorWidget {
  late List<EditorWidgetColumn> _columns = [];
  late String _auid;
  late bool _isInitialized;
  Map<String, dynamic>? _assessmentData;
  final _AssessmentMetaData _assessmentMetaData = _AssessmentMetaData();

  @override
  late EditorWidgetMetadata metadata;

  bool _isBeingCreated = false;
  @override
  final bool reduceDropzoneSize = true;

  // constructor
  EditorWidgetAssessment({Key? key, required this.editorWidgetData})
      : super(key: key);
  @override
  final EditorWidgetData editorWidgetData;

  // serialization
  @override
  void loadFromJson(Map<String, dynamic> json) {
    metadata = getMetadata(json, editorWidgetData);
    ;
    _auid = json["auid"];
    _isInitialized = json["isInitialized"] == "true";
  }

  @override
  Map<String, dynamic> saveToJson() {
    //"data": _column.saveToJson(),
    // if assessmentData has not yet been loaded
    if (_assessmentData != null) {
      int i = 0;
      for (EditorWidgetColumn column in _columns) {
        _assessmentData!["questions"][i++]["questionData"] =
            column.saveToJson();
      }
      if (editorWidgetData.isAdminMode) {
        networking_api_service.updateAssessment(
          auid: _auid,
          assessmentData: jsonEncode(_assessmentData),
          weighting: _assessmentMetaData.weighting,
          passingPercentage: _assessmentMetaData.minGrade,
        );
      }
    }

    return {
      "metadata": metadata.encode(),
      "widgetType": widgetTypeAssessment,
      "auid": _auid.toString(),
      "isInitialized": _isInitialized.toString()
    };
  }

  @override
  State<EditorWidgetAssessment> createState() => _EditorWidgetAssessmentState();

  @override
  void onCreate() async {
    _isBeingCreated = true;
    await Future.delayed(const Duration(seconds: 1));
    _assessmentData = {
      "questions": [
        {
          "quid": Random().nextInt(9999999).toString(),
          "questionType": "multipleChoice",
          "questionData": {"widgetType": widgetTypeColumn, "children": []},
          "questionAnswerData": {
            "choices": [
              "Click here to edit text",
              "Click here to edit text",
              "Click here to edit text",
              "Click here to edit text",
            ],
            "correctAnswers": [
              "false",
              "false",
              "false",
              "false",
            ]
          }
        }
      ]
    };

    _assessmentMetaData.setDefaultValues();

    Map<String, dynamic> response =
        await networking_api_service.createAssessment(
            courseElementId: editorWidgetData.courseData
                .getSelectedCourseElement()
                .courseElementId,
            weighting: _assessmentMetaData.weighting,
            passingPercentage: _assessmentMetaData.minGrade,
            assessmentData: jsonEncode(_assessmentData));
    _auid = response["auid"];
    _isInitialized = true;
    _isBeingCreated = false;
    editorWidgetData.onUpdate();
  }

  @override
  void onRemove() async {
    await networking_api_service.removeAssessment(auid: _auid);
  }

  @override
  Widget? getToolbar() {
    return null;
  }
}

class _EditorWidgetAssessmentState extends State<EditorWidgetAssessment> {
  bool _isLoaded = false;
  bool _hasUserBegunTest = false;
  Map<String, dynamic>? _answerData;

  ScholarityTextFieldController weightingController =
      ScholarityTextFieldController();
  ScholarityTextFieldController minGradeController =
      ScholarityTextFieldController();
  final _ScholarityAssessmentWidgetController _assessmentWidgetController =
      _ScholarityAssessmentWidgetController();

  Future<bool> _loadAssessment() async {
    if (_isLoaded) return true;
    _isLoaded = true;

    // wait until it is finished being created
    while (widget._isBeingCreated) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
    Map<String, dynamic> questionResponse =
        await networking_api_service.getAssessment(auid: widget._auid);

    // parse the question data
    String assessmentDataStr =
        Uri.decodeComponent(questionResponse["data"]["assessmentData"]);
    Map<String, dynamic> assessmentData = jsonDecode(assessmentDataStr);
    widget._assessmentData = assessmentData;

    // set the assessment settings
    widget._assessmentMetaData.weighting =
        questionResponse["data"]["weighting"] ?? 0;
    widget._assessmentMetaData.minGrade =
        questionResponse["data"]["passingPercentage"] ?? 0;

    Map<String, dynamic> answerResponse = await networking_api_service
        .getAssessmentTaskFromAssessment(auid: widget._auid);

    // user hasn't begun test if no answer task was ever made for this test
    _hasUserBegunTest = answerResponse.isNotEmpty;

    if (_hasUserBegunTest) {
      String answerDataStr =
          Uri.decodeComponent(answerResponse["data"]["data"]);
      Map<String, dynamic> answerData = jsonDecode(answerDataStr);
      _answerData = answerData;
    }

    setState(() {
      List<dynamic> questions = assessmentData["questions"];
      widget._columns = [];
      for (int i = 0; i < questions.length; i++) {
        widget._columns.add(EditorWidgetColumn(
          editorWidgetData: widget.editorWidgetData,
          reduceTailerSize: true,
        ));
        Map<String, dynamic> questionData = questions[i]["questionData"];
        widget._columns[i].loadFromJson(questionData);
      }
    });

    return true;
  }

  void _reorderQuestion(int initialQuestionNum, int finalQuestionNum) {
    setState(() {
      List<dynamic> questions = widget._assessmentData!["questions"];

      var question = questions[initialQuestionNum];
      var column = widget._columns[initialQuestionNum];

      questions.removeAt(initialQuestionNum);
      widget._columns.removeAt(initialQuestionNum);

      questions.insert(finalQuestionNum, question);
      widget._columns.insert(finalQuestionNum, column);

      // update it
      widget._assessmentData!["questions"] = questions;
      widget.editorWidgetData.onUpdate();
      _assessmentWidgetController.questionNumber = finalQuestionNum;
    });
  }

  void _deleteQuestion(int questionNum) {
    setState(() {
      List<dynamic> questions = widget._assessmentData!["questions"];

      questions.removeAt(questionNum);
      widget._columns.removeAt(questionNum);

      // update it
      widget._assessmentData!["questions"] = questions;
      widget.editorWidgetData.onUpdate();
      _assessmentWidgetController.questionNumber = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: scholarity_color.borderColor),
          borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              top: 16,
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined,
                      size: 30, color: scholarity_color.darkGrey),
                  const SizedBox(width: 10),
                  const ScholarityTextH2B("Assessment")
                ],
              ),
            ),
          ),
          FutureBuilder(
              future: _loadAssessment(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                // if loading
                if (!snapshot.hasData) {
                  return const Column(
                    children: [
                      ScholarityBoxLoading(height: 50, width: 500),
                      ScholarityBoxLoading(height: 50, width: 500),
                      ScholarityBoxLoading(height: 50, width: 500),
                      ScholarityBoxLoading(height: 50, width: 500),
                    ],
                  );
                }
                // if user has not begun test
                if (!widget.editorWidgetData.isAdminMode &&
                    !_hasUserBegunTest) {
                  return _ScholarityAssessmentFront(
                    auid: widget._auid,
                    onUpdate: () => setState(() {
                      _isLoaded = false;
                    }),
                  );
                }

                return Stack(
                  children: [
                    _ScholarityAssessment(
                      isAdminMode: widget.editorWidgetData.isAdminMode,
                      auid: widget._auid,
                      columns: widget._columns,
                      questionData: widget._assessmentData!["questions"],
                      editorWidgetData: widget.editorWidgetData,
                      answerData: _answerData,
                      onUpdate: widget.editorWidgetData.onUpdate,
                      controller: _assessmentWidgetController,
                    ),
                    !widget.editorWidgetData.isAdminMode
                        ? Container()
                        : Align(
                            alignment: Alignment.topRight,
                            child: _ScholarityAssessmentMore(
                              assessmentWidgetController:
                                  _assessmentWidgetController,
                              assessmentData: widget._assessmentData!,
                              auid: widget._auid,
                              assessmentMetaData: widget._assessmentMetaData,
                              onReorderQuestion: _reorderQuestion,
                              onDeleteQuestion: _deleteQuestion,
                            ))
                  ],
                );
              }),
        ],
      ),
    );
  }
}

class _AssessmentMoreSettings extends StatelessWidget {
  // members of MyWidget
  final ScholarityTextFieldController weightingController =
      ScholarityTextFieldController();
  final ScholarityTextFieldController minGradeController =
      ScholarityTextFieldController();
  final String auid;
  final Map<String, dynamic> assessmentData;
  final _AssessmentMetaData assessmentMetaData;

  // constructor
  _AssessmentMoreSettings({
    Key? key,
    required this.assessmentMetaData,
    required this.auid,
    required this.assessmentData,
  }) : super(key: key) {
    weightingController.text = assessmentMetaData.weighting.toString();
    minGradeController.text = assessmentMetaData.minGrade.toString();
  }

  void _saveWeightingParam() {
    assessmentMetaData.weighting = int.parse(weightingController.text);
    _saveParams();
  }

  void _saveMinGradeParam() {
    assessmentMetaData.minGrade = int.parse(minGradeController.text);
    _saveParams();
  }

  void _saveParams() async {
    await networking_api_service.updateAssessment(
      auid: auid,
      assessmentData: jsonEncode(assessmentData),
      weighting: assessmentMetaData.weighting,
      passingPercentage: assessmentMetaData.minGrade,
    );
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScholarityIconButton(
            icon: Icons.close,
            onPressed: () {
              Navigator.pop(context);
            }),
        const SizedBox(height: 30),
        const ScholarityTextH2B("Minimum Passing Percentage"),
        const ScholarityTextP(
            "If a student scores above this percentage, they will be counted\nas passing the assessment. Otherwise, they will be counted as failing."),
        const SizedBox(height: 10),
        ScholaritySettingButton(
            isSmall: true,
            loadValue: () async {
              return minGradeController.text;
            },
            saveValue: (value) async {
              // verify that this valid
              int val;
              try {
                val = int.parse(value);
                if (val > 100) {
                  throw 0;
                }
                if (val <= 0) {
                  throw 0;
                }
              } catch (_) {
                throw error_service.ScholarityException("0-100");
              }

              // set and save
              minGradeController.text = value;
              _saveMinGradeParam();
            },
            name: "min grade"),
        const ScholarityTextH2B("Relative Weighting of Assessment"),
        const ScholarityTextP(
            "The weighting of the assessment relative to other assessments'\nweightings."),
        const SizedBox(height: 10),
        ScholaritySettingButton(
            isSmall: true,
            loadValue: () async {
              return weightingController.text;
            },
            saveValue: (value) async {
              // verify that this valid
              int val;
              try {
                val = int.parse(value);
                if (val <= 0) {
                  throw 0;
                }
              } catch (_) {
                throw error_service.ScholarityException("number");
              }

              // set and save
              weightingController.text = value;
              _saveWeightingParam();
            },
            name: "weighting"),
        const ScholarityTextH2B("Assessment Data"),
        const ScholarityTextP(
            "Copy and paste assessment questions to another page."),
        const SizedBox(height: 10),
        Row(
          children: [
            Tooltip(
              message: "copy",
              child: ScholarityIconButton(
                icon: Icons.copy_rounded,
                onPressed: () {},
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Tooltip(
                message: "paste",
                child: ScholarityIconButton(
                  icon: Icons.paste_rounded,
                  onPressed: () async {
                    //final clipboardData =
                    //await Clipboard.getData(Clipboard.kTextPlain);
                  },
                ))
          ],
        )
      ],
    );
  }
}

class _ScholarityAssessmentWidgetController {
  int questionNumber = 0;
}

class _ScholarityAssessment extends StatefulWidget {
  // members of MyWidget
  final bool isAdminMode;
  final String auid;
  final List<EditorWidget> columns;
  final List<dynamic> questionData;
  final EditorWidgetData editorWidgetData;
  final Map<String, dynamic>? answerData;
  final void Function() onUpdate;
  final _ScholarityAssessmentWidgetController controller;

  // constructor
  const _ScholarityAssessment({
    Key? key,
    required this.isAdminMode,
    required this.auid,
    required this.columns,
    required this.questionData,
    required this.editorWidgetData,
    required this.answerData,
    required this.onUpdate,
    required this.controller,
  }) : super(key: key);

  @override
  State<_ScholarityAssessment> createState() => _ScholarityAssessmentState();
}

class _ScholarityAssessmentState extends State<_ScholarityAssessment> {
  // main build function
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16),
          child: Row(
            children: [
              const ScholarityTextH2B("Question"),
              const SizedBox(width: 5),
              ScholarityTextH2B(
                  "${widget.controller.questionNumber + 1}/${widget.questionData.length}"),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: widget.isAdminMode ? 16 : 0),
          child: DottedBorder(
              borderType: BorderType.RRect,
              color: widget.isAdminMode
                  ? scholarity_color.borderColor
                  : Colors.transparent,
              strokeWidth: 1,
              dashPattern: const [8, 4],
              radius:
                  widget.isAdminMode ? const Radius.circular(12) : Radius.zero,
              strokeCap: StrokeCap.round,
              child: widget.columns[widget.controller.questionNumber]),
        ),
        _ScholarityAnswerMultipleChoice(
          questionAnswerData:
              widget.questionData[widget.controller.questionNumber]
                  ["questionAnswerData"],
          quid: widget.questionData[widget.controller.questionNumber]["quid"],
          auid: widget.auid,
          answerData: widget.answerData,
          onAdminUpdate: () {
            widget.onUpdate();
          },
          isAdminMode: widget.isAdminMode,
        ),
        const SizedBox(height: 30),
        Stack(
          children: [
            widget.controller.questionNumber != 0
                ? ScholarityButton(
                    text: "Previous Question",
                    lightenBackground: true,
                    onPressed: () {
                      setState(() {
                        widget.controller.questionNumber--;
                      });
                    },
                  )
                : Container(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(),
                    ),
                    const ScholarityTextH5("Question"),
                    const SizedBox(width: 3),
                    ScholarityTextH5(
                        "${widget.controller.questionNumber + 1}/${widget.questionData.length}"),
                    Expanded(
                      child: Container(),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: IntrinsicWidth(
                child: widget.controller.questionNumber !=
                        widget.questionData.length - 1
                    ? ScholarityButton(
                        text: "Next Question",
                        onPressed: () {
                          setState(() {
                            widget.controller.questionNumber++;
                          });
                        },
                      )
                    : !widget.isAdminMode
                        ? Container()
                        : ScholarityButton(
                            text: "Create New Question",
                            onPressed: () {
                              widget.questionData.add({
                                "quid": Random().nextInt(9999999).toString(),
                                "questionType": "multipleChoice",
                                "questionData": {
                                  "widgetType": widgetTypeColumn,
                                  "children": []
                                },
                                "questionAnswerData": {
                                  "choices": [
                                    "Click here to edit text",
                                    "Click here to edit text",
                                    "Click here to edit text",
                                    "Click here to edit text",
                                  ],
                                  "correctAnswers": [
                                    "false",
                                    "false",
                                    "false",
                                    "false",
                                  ]
                                }
                              });
                              widget.columns.add(EditorWidgetColumn(
                                editorWidgetData: widget.editorWidgetData,
                                reduceTailerSize: true,
                              ));
                              widget.controller.questionNumber++;
                              setState(() {
                                widget.onUpdate();
                              });
                            },
                          ),
              ),
            ),
          ],
        )
      ],
    );
  }
}

// myPage class which creates a state on call
class _ScholarityAnswerMultipleChoice extends StatefulWidget {
  final void Function() onAdminUpdate;
  final String auid;
  final String quid;
  final Map<String, dynamic> questionAnswerData;
  final Map<String, dynamic>? answerData;
  final bool isAdminMode;
  const _ScholarityAnswerMultipleChoice(
      {Key? key,
      required this.onAdminUpdate,
      required this.quid,
      required this.auid,
      required this.questionAnswerData,
      required this.answerData,
      required this.isAdminMode})
      : super(key: key);

  @override
  _ScholarityAnswerMultipleChoiceState createState() =>
      _ScholarityAnswerMultipleChoiceState();
}

// myPage state
class _ScholarityAnswerMultipleChoiceState
    extends State<_ScholarityAnswerMultipleChoice> {
  int? _selectedUserChoice;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> updateAnswer() async {
    // update the answer
    if (widget.answerData != null) {
      // find the answer
      List<dynamic> answers = widget.answerData!["answers"];
      int index = -1;
      for (int i = 0; i < answers.length; i++) {
        if (answers[i]["quid"] == widget.quid) {
          index = i;
        }
      }
      bool foundAnswerEntry = index != -1;

      // change it
      if (foundAnswerEntry) {
        // found an entry, just change it
        if (_selectedUserChoice != null) {
          answers[index]["answer"] = _selectedUserChoice;
        } else {
          answers.removeAt(index);
        }
      } else {
        if (_selectedUserChoice != null) {
          // didn't find an entry, create a new one for this question
          answers.add({
            "answer": _selectedUserChoice,
            "quid": widget.quid,
          });
        }
      }
      await networking_api_service.updateAssessmentTaskFromAssessment(
          auid: widget.auid, data: jsonEncode(widget.answerData));
      course_navigation_service.reloadHierarchy();
    }
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // load the answer
    if (widget.answerData != null && !widget.isAdminMode) {
      // find the answer
      List<dynamic> answers = widget.answerData!["answers"];
      int index = -1;
      for (int i = 0; i < answers.length; i++) {
        if (answers[i]["quid"] == widget.quid) {
          index = i;
        }
      }
      bool foundAnswerForQuid = index != -1;

      // use it
      if (foundAnswerForQuid) {
        _selectedUserChoice = answers[index]["answer"];
      } else {
        _selectedUserChoice = null;
      }
    }
    List<dynamic> choices = widget.questionAnswerData["choices"];
    List<dynamic> correctAnswers = widget.questionAnswerData["correctAnswers"];
    return Column(
      children: List.generate(choices.length, (int i) {
        return _ScholarityRadio(
          label: choices[i],
          value: choices[i],
          isSelected: _selectedUserChoice == i,
          isCorrectAnswer: correctAnswers[i] == "true",
          onCorrectAnswerChanged: (bool newIsCorrectAnswer) {
            setState(() {
              widget.questionAnswerData["correctAnswers"][i] =
                  newIsCorrectAnswer ? "true" : "false";
              widget.onAdminUpdate();
            });
          },
          onNameChanged: (String newName) {
            widget.questionAnswerData["choices"][i] = newName;
            widget.onAdminUpdate();
          },
          onChanged: (String? value) async {
            if (_selectedUserChoice != i) {
              _selectedUserChoice = i;
            } else {
              _selectedUserChoice = null;
            }
            await updateAnswer();
            setState(() {});
          },
          isAdminMode: widget.isAdminMode,
        );
      }),
    );
  }
}

class _ScholarityRadio extends StatelessWidget {
  // members of MyWidget
  final String label;
  final bool isSelected;
  final String value;
  final bool isCorrectAnswer;
  final void Function(bool newIsCorrectAnswer) onCorrectAnswerChanged;
  final ValueChanged<String> onChanged;
  final bool isAdminMode;
  final void Function(String newName) onNameChanged;
  final ScholarityTextFieldController textController =
      ScholarityTextFieldController();

  // constructor
  _ScholarityRadio({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.value,
    required this.onChanged,
    required this.isCorrectAnswer,
    required this.onCorrectAnswerChanged,
    required this.isAdminMode,
    required this.onNameChanged,
  }) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    textController.text = label;
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (!isAdminMode) {
                onChanged(value);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                  color: isSelected
                      ? scholarity_color.scholarityAccentBackground
                      : scholarity_color.background,
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: <Widget>[
                    Radio<String>(
                      groupValue: isSelected ? value : null,
                      value: value,
                      onChanged: (String? newValue) {
                        if (!isAdminMode) {
                          onChanged(newValue!);
                        }
                      },
                    ),
                    const SizedBox(width: 10),
                    !isAdminMode
                        ? Expanded(child: ScholarityTextH5(label))
                        : Expanded(
                            child: ScholarityEditableText(
                                controller: textController,
                                onSubmit: () {
                                  onNameChanged(textController.text);
                                },
                                style: scholarityTextH5Style),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
        !isAdminMode
            ? Container()
            : Expanded(
                child: Row(
                  children: [
                    Checkbox(
                      value: isCorrectAnswer,
                      onChanged: (bool? value) {
                        onCorrectAnswerChanged(value!);
                      },
                    ),
                    const ScholarityTextH5("Is correct answer?"),
                  ],
                ),
              ),
      ],
    );
  }
}

class _ScholarityAssessmentFront extends StatefulWidget {
  // members of MyWidget
  final String auid;
  final void Function() onUpdate;

  // constructor
  const _ScholarityAssessmentFront(
      {Key? key, required this.auid, required this.onUpdate})
      : super(key: key);

  @override
  State<_ScholarityAssessmentFront> createState() =>
      _ScholarityAssessmentFrontState();
}

class _ScholarityAssessmentFrontState
    extends State<_ScholarityAssessmentFront> {
  bool _isLoading = false;
  // main build function
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScholarityTextH2B(
                "This is a graded assessment where you are given questions.\nPlease click button below to begin.",
              ),
              const SizedBox(height: 10),
              ScholarityButton(
                verticalOnlyPadding: true,
                text: "Begin Assessment",
                loading: _isLoading,
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  await networking_api_service
                      .createAssessmentTaskFromAssessment(
                          auid: widget.auid, data: jsonEncode({"answers": []}));
                  setState(() {
                    _isLoading = false;
                    widget.onUpdate();
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _ScholarityAssessmentFinished extends StatelessWidget {
  // constructor
  const _ScholarityAssessmentFinished({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 300,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
          child: ScholarityTextH2B(
            "Your assessment has now been submitted.",
          ),
        ),
      ),
    );
  }
}

class _ScholarityAssessmentMore extends StatefulWidget {
  // members of MyWidget
  final _ScholarityAssessmentWidgetController assessmentWidgetController;

  final _AssessmentMetaData assessmentMetaData;
  final String auid;
  final Map<String, dynamic> assessmentData;
  final void Function(int initialQuestionNum, int finalQuestionNum)
      onReorderQuestion;
  final void Function(int questionNumber) onDeleteQuestion;

  // constructor
  const _ScholarityAssessmentMore(
      {Key? key,
      required this.assessmentWidgetController,
      required this.assessmentMetaData,
      required this.auid,
      required this.assessmentData,
      required this.onReorderQuestion,
      required this.onDeleteQuestion})
      : super(key: key);

  @override
  State<_ScholarityAssessmentMore> createState() =>
      _ScholarityAssessmentMoreState();
}

class _ScholarityAssessmentMoreState extends State<_ScholarityAssessmentMore> {
  // main build function
  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
        child: PopupMenuButton<_AccountActions>(
            child: ScholarityIconButton(
              icon: Icons.tune_rounded,
              isEnabled: true,
            ),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<_AccountActions>(
                  onTap: () {
                    setState(() {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) =>
                            ScholarityAlertDialogWrapper(
                          child: ScholarityAlertDialog(
                            content: _AssessmentMoreReorderQuestion(
                              assessmentWidgetController:
                                  widget.assessmentWidgetController,
                              numberOfQuestions:
                                  widget.assessmentData["questions"].length,
                              onReorderQuestion: widget.onReorderQuestion,
                            ),
                          ),
                        ),
                      );
                    });
                  },
                  child: const ScholarityTextBasic('Reorder Question'),
                ),
                PopupMenuItem<_AccountActions>(
                  onTap: () {
                    setState(() {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) =>
                            ScholarityAlertDialogWrapper(
                          child: ScholarityAlertDialog(
                            content: _AssessmentMoreDeleteQuestion(
                              assessmentWidgetController:
                                  widget.assessmentWidgetController,
                              onDeleteQuestion: widget.onDeleteQuestion,
                            ),
                          ),
                        ),
                      );
                    });
                  },
                  child: const ScholarityTextBasic('Delete Question'),
                ),
                PopupMenuItem<_AccountActions>(
                  onTap: () {
                    setState(() {
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) =>
                            ScholarityAlertDialogWrapper(
                          child: ScholarityAlertDialog(
                            content: _AssessmentMoreSettings(
                              assessmentMetaData: widget.assessmentMetaData,
                              auid: widget.auid,
                              assessmentData: widget.assessmentData,
                            ),
                          ),
                        ),
                      );
                    });
                  },
                  child: const ScholarityTextBasic('Settings'),
                ),
              ];
            }));
  }
}

class _AssessmentMoreReorderQuestion extends StatelessWidget {
  final ScholarityTextFieldController _controller =
      ScholarityTextFieldController();
  final _ScholarityAssessmentWidgetController assessmentWidgetController;
  final int numberOfQuestions;
  final void Function(int initialQuestionNum, int finalQuestionNum)
      onReorderQuestion;
  // constructor
  _AssessmentMoreReorderQuestion(
      {Key? key,
      required this.assessmentWidgetController,
      required this.numberOfQuestions,
      required this.onReorderQuestion})
      : super(key: key) {
    _controller.text =
        (assessmentWidgetController.questionNumber + 1).toString();
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScholarityIconButton(
            icon: Icons.close,
            onPressed: () {
              Navigator.pop(context);
            }),
        const SizedBox(height: 10),
        const ScholarityTextH2B("Reorder Question"),
        const ScholarityTextP(
            "Move this question to a different place in this assessment."),
        const SizedBox(height: 20),
        Builder(builder: (context) {
          List<String> dropdowns = [];
          for (int i = 1; i <= numberOfQuestions; i++) {
            dropdowns.add(i.toString());
          }
          return ScholarityDropdown(
            label: "Move to",
            controller: _controller,
            dropdownTypes: dropdowns,
          );
        }),
        const SizedBox(height: 20),
        ScholarityButton(
          padding: false,
          text: "Move",
          onPressed: () {
            onReorderQuestion(assessmentWidgetController.questionNumber,
                int.parse(_controller.text) - 1);
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}

class _AssessmentMoreDeleteQuestion extends StatelessWidget {
  final ScholarityTextFieldController _controller =
      ScholarityTextFieldController();
  final _ScholarityAssessmentWidgetController assessmentWidgetController;
  final void Function(int questionNumber) onDeleteQuestion;
  // constructor
  _AssessmentMoreDeleteQuestion(
      {Key? key,
      required this.assessmentWidgetController,
      required this.onDeleteQuestion})
      : super(key: key) {
    _controller.text =
        (assessmentWidgetController.questionNumber + 1).toString();
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScholarityIconButton(
            icon: Icons.close,
            onPressed: () {
              Navigator.pop(context);
            }),
        const SizedBox(height: 10),
        ScholarityTextH2B(
            "Delete Question #${assessmentWidgetController.questionNumber + 1}"),
        const ScholarityTextP(
            "Are you sure you want to permanently delete this question?"),
        const SizedBox(height: 20),
        ScholarityButton(
          padding: false,
          text: "Delete",
          onPressed: () {
            onDeleteQuestion(assessmentWidgetController.questionNumber);
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
