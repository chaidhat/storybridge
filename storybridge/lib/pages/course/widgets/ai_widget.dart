import 'package:animated_text_kit/animated_text_kit.dart';

import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;

// myPage class which creates a state on call
class AiWidget extends StatefulWidget {
  final int courseElementId;
  const AiWidget({Key? key, required this.courseElementId}) : super(key: key);

  @override
  _AiWidgetState createState() => _AiWidgetState();
}

// myPage state
class _AiWidgetState extends State<AiWidget> {
  bool _hasOpenedSummary = false;
  bool _hasOpenedQuestion = false;
  final List<_ChatData> _chatData = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              children: [
                IntrinsicWidth(
                  child: ScholarityButton(
                    invertedColor: _hasOpenedQuestion,
                    text: !_hasOpenedQuestion
                        ? "Ask the AI a question"
                        : "Hide the AI question",
                    icon: Icons.live_help_outlined,
                    onPressed: () {
                      _hasOpenedQuestion = !_hasOpenedQuestion;
                      _hasOpenedSummary = false;
                      setState(() {});
                    },
                  ),
                ),
                IntrinsicWidth(
                  child: ScholarityButton(
                    invertedColor: _hasOpenedSummary,
                    text: !_hasOpenedSummary
                        ? "See AI Summary"
                        : "Hide AI Summary",
                    icon: Icons.tips_and_updates_outlined,
                    onPressed: () {
                      _hasOpenedSummary = !_hasOpenedSummary;
                      _hasOpenedQuestion = false;
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            _hasOpenedQuestion
                ? _AIQuestionWidget(
                    courseElementId: widget.courseElementId,
                    chatData: _chatData,
                  )
                : Container(),
            _hasOpenedSummary
                ? _AISummaryWidget(
                    courseElementId: widget.courseElementId,
                  )
                : Container(),
          ],
        ));
  }
}

// myPage class which creates a state on call
class _AISummaryWidget extends StatefulWidget {
  final int courseElementId;
  const _AISummaryWidget({Key? key, required this.courseElementId})
      : super(key: key);

  @override
  _AISummaryWidgetState createState() => _AISummaryWidgetState();
}

// myPage state
class _AISummaryWidgetState extends State<_AISummaryWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String> _getAiCourseElementSummary() async {
    Map<String, dynamic> data = await networking_api_service
        .getAiCourseElementSummary(courseElementId: widget.courseElementId);
    return data["data"];
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ScholarityTile(
        child: ScholarityPadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScholarityTextH2B("AI Generated Summary"),
              const SizedBox(height: 10),
              FutureBuilder(
                  future: _getAiCourseElementSummary(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return const ScholarityPageLoading(
                        useAltStyle: true,
                      );
                    } else {
                      return _ChatWidget(
                        data: _ChatData(comment: snapshot.data, isAi: true),
                        isTextAnimated: true,
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

// myPage class which creates a state on call
class _AIQuestionWidget extends StatefulWidget {
  final int courseElementId;
  final List<_ChatData> chatData;
  const _AIQuestionWidget(
      {Key? key, required this.courseElementId, required this.chatData})
      : super(key: key);

  @override
  _AIQuestionWidgetState createState() => _AIQuestionWidgetState();
}

// myPage state
class _AIQuestionWidgetState extends State<_AIQuestionWidget> {
  final ScholarityTextFieldController _controller =
      ScholarityTextFieldController();
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _submitQuestion() async {
    _isLoading = true;
    String question = _controller.text;
    _controller.text = "";
    widget.chatData.add(_ChatData(comment: question, isAi: false));
    setState(() {});
    Map<String, dynamic> data =
        await networking_api_service.askAiCourseElementQuestion(
            question: question, courseElementId: widget.courseElementId);
    setState(() {
      widget.chatData.add(_ChatData(comment: data["data"], isAi: true));
      _isLoading = false;
    });
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ScholarityTile(
        child: ScholarityPadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScholarityTextH2B(
                  "Ask the AI a question about this course"),
              const SizedBox(height: 10),
              Column(
                  children: List.generate(widget.chatData.length, (int i) {
                // animate the text only if its the last element
                return _ChatWidget(
                  data: widget.chatData[i],
                  isTextAnimated: i == widget.chatData.length - 1,
                );
              })),
              const SizedBox(height: 10),
              Builder(builder: (BuildContext context) {
                if (_isLoading) {
                  return const ScholarityPageLoading(
                    useAltStyle: true,
                  );
                } else {
                  return Column(
                    children: [
                      ScholarityTextField(
                        label: "Question",
                        controller: _controller,
                      ),
                      ScholarityButton(
                        text: "Ask",
                        invertedColor: true,
                        padding: false,
                        onPressed: _submitQuestion,
                      ),
                    ],
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatWidget extends StatelessWidget {
  // members of MyWidget
  final _ChatData data;
  final bool isTextAnimated;

  // constructor
  const _ChatWidget({Key? key, required this.data, this.isTextAnimated = false})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: SizedBox(
                width: 40,
                height: 40,
                child: Image(
                    image: data.isAi
                        ? const AssetImage('assets/images/ai_icon.png')
                        : const AssetImage('assets/images/user_icon.png'))),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScholarityTextH2B(data.isAi ? "Scholarity AI" : "You"),
                AnimatedTextKit(
                  totalRepeatCount: 1,
                  animatedTexts: [
                    TyperAnimatedText(
                      data.comment,
                      speed: isTextAnimated
                          ? const Duration(milliseconds: 10)
                          : const Duration(milliseconds: 0),
                      textStyle: scholarityTextPStyle,
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ChatData {
  String comment;
  bool isAi;
  _ChatData({required this.comment, required this.isAi});
}
