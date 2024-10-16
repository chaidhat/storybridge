import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mooc/storybridge.dart'; // Storybridge

import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_answer_buttons.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_answer_checkbox.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_answer_datetime.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_answer_dropdown.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_answer_fileupload.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_answer_text.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_image.dart';
import 'package:mooc/services/error_service.dart' as error_service;

import 'package:mooc/pages/course/editor/widgets/editor_widget_icons.dart';

import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_text.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_header.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_note.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_spacer.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_video.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_button.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_assessment.dart';
import 'package:mooc/pages/course/editor/widgets/drag_widgets/editor_widget_link_button.dart';

// myPage class which creates a state on call
class EditorDragSidebar extends StatefulWidget {
  final bool isOnFrontPage;
  const EditorDragSidebar({Key? key, required this.isOnFrontPage})
      : super(key: key);

  @override
  _EditorDragSidebarState createState() => _EditorDragSidebarState();
}

// myPage state
class _EditorDragSidebarState extends State<EditorDragSidebar> {
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 40),
      widget.isOnFrontPage ? const _FrontPageWidgets() : Container(),
      const _GeneralWidgets()
    ]);
  }
}

class _GeneralWidgets extends StatelessWidget {
  // constructor
  const _GeneralWidgets({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: StorybridgeTextH2B("Drag & Drop Widgets"),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Wrap(
            children: [
              EditorDraggableWidgetIcon(
                  icon: Icons.videocam_rounded,
                  name: "Video",
                  editorWidget: EditorWidgetTemplate(
                      getWidgetJson: () => {
                            "widgetType": widgetTypeVideo,
                            "videoId": "0",
                            "isInitialized": "false"
                          })),
              EditorDraggableWidgetIcon(
                  icon: Icons.image_outlined,
                  name: "Image",
                  editorWidget: EditorWidgetTemplate(
                      getWidgetJson: () => {
                            "widgetType": widgetTypeImage,
                            "altText": "Alternative Text",
                            "imageId": "0",
                            "isInitialized": "false"
                          })),
              EditorDraggableWidgetIcon(
                  icon: Icons.notes_rounded,
                  name: "Text",
                  editorWidget: EditorWidgetTemplate(
                      getWidgetJson: () => {
                            "widgetType": widgetTypeText,
                            "text":
                                "Click to edit this text. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam dictum diam id nunc hendrerit, nec sollicitudin lacus tincidunt. Phasellus faucibus efficitur ornare. Nulla rhoncus magna ut arcu consectetur, at condimentum dolor rutrum. Sed id molestie enim, quis fermentum tellus. Donec dictum pellentesque metus vel pretium. Fusce nec lorem id turpis mattis accumsan eget sit amet lacus. Aenean egestas ligula vel lorem finibus elementum. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc pharetra rhoncus erat elementum faucibus. Aliquam egestas dui tempor nisi malesuada scelerisque.",
                          })),
              EditorDraggableWidgetIcon(
                  icon: Icons.text_fields_rounded,
                  name: "Header",
                  editorWidget: EditorWidgetTemplate(
                      getWidgetJson: () => {
                            "widgetType": widgetTypeHeader,
                            "text": "Click to edit header",
                          })),
              EditorDraggableWidgetIcon(
                  icon: Icons.border_outer_rounded,
                  name: "Spacer",
                  editorWidget: EditorWidgetTemplate(
                      getWidgetJson: () => {
                            "widgetType": widgetTypeSpacer,
                          })),
              EditorDraggableWidgetIcon(
                  icon: Icons.article_outlined,
                  name: "Notice",
                  editorWidget: EditorWidgetTemplate(
                      getWidgetJson: () => {
                            "widgetType": widgetTypeNote,
                            "text": "Click to edit note",
                          })),
              EditorDraggableWidgetIcon(
                  icon: Icons.exit_to_app_rounded,
                  name: "Button",
                  editorWidget: EditorWidgetTemplate(
                      getWidgetJson: () => {
                            "widgetType": widgetTypeLinkButton,
                            "text": "Click to edit button",
                            "link": "https://",
                          })),
              /*
              EditorDraggableWidgetIcon(
                  icon: Icons.file_copy_outlined,
                  name: "File",
                  editorWidget: EditorWidgetTemplate(
                      getWidgetJson: () => {
                            "widgetType": widgetTypeFile,
                          })),
              EditorDraggableWidgetIcon(
                  icon: Icons.upload_file_outlined,
                  name: "Upload Area",
                  editorWidget: EditorWidgetTemplate(
                      getWidgetJson: () => {
                            "widgetType": widgetTypeUploadarea,
                          })),
                          */
              const SizedBox(height: 200),
              //const _SuggestNewPage(),
            ],
          ),
        ),
      ],
    );
  }
}

class _FrontPageWidgets extends StatelessWidget {
  // constructor
  const _FrontPageWidgets({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: StorybridgeTextH2B("Front Page Widgets"),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Wrap(
            children: [
              EditorDraggableWidgetIcon(
                  icon: Icons.exit_to_app_rounded,
                  name: "Read Widget",
                  editorWidget: EditorWidgetTemplate(
                      getWidgetJson: () => {
                            "widgetType": widgetTypeButton,
                            "text": "button",
                          })),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// myPage class which creates a state on call
class _SuggestNewPage extends StatefulWidget {
  const _SuggestNewPage({Key? key}) : super(key: key);

  @override
  _SuggestNewPageState createState() => _SuggestNewPageState();
}

// myPage state
class _SuggestNewPageState extends State<_SuggestNewPage> {
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
    error_service.checkAlerts(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTapDown: (_) {
          error_service.alert(error_service.Alert(
              title: "Suggest a New Widget",
              description:
                  "Since Storybridge is very new, we are excited to hear what widget or feature you would like to see in the program!\n\nPlease describe your suggestion in two-three sentences.\nNote: submissions are anonymous.",
              buttonName: "SUBMIT",
              isLarge: true,
              acceptInput: true,
              callback: (String input) async {
                error_service.alert(error_service.Alert(
                    title: "Thank you!",
                    description:
                        "Thank you very much for suggesting a feature! Every so often, we look at all the feature suggestions and, depending on its popularity and complexity, try to implement it into Storybridge.",
                    buttonName: "Dismiss",
                    callback: (String input) async {
                      setState(() {});
                    }));
                setState(() {});
              }));
          setState(() {});
        },
        child: const EditorWidgetIcon(
          icon: Icons.tips_and_updates_outlined,
          name: "Suggest New",
          isWhiteButton: true,
        ),
      ),
    );
  }
}

class AuditEditorDragSidebar extends StatefulWidget {
  const AuditEditorDragSidebar({Key? key}) : super(key: key);

  @override
  _AuditEditorDragSidebarState createState() => _AuditEditorDragSidebarState();
}

// myPage state
class _AuditEditorDragSidebarState extends State<AuditEditorDragSidebar> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: StorybridgeTextH2B("Question Widgets"),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Wrap(
            children: [
              EditorDraggableWidgetIcon(
                  icon: Icons.notes_rounded,
                  name: "Text",
                  editorWidget: EditorWidgetTemplate(
                      getWidgetJson: () => {
                            "widgetType": widgetTypeText,
                            "text":
                                "Click to edit this text. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam dictum diam id nunc hendrerit, nec sollicitudin lacus tincidunt. Phasellus faucibus efficitur ornare. Nulla rhoncus magna ut arcu consectetur, at condimentum dolor rutrum. Sed id molestie enim, quis fermentum tellus. Donec dictum pellentesque metus vel pretium. Fusce nec lorem id turpis mattis accumsan eget sit amet lacus. Aenean egestas ligula vel lorem finibus elementum. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc pharetra rhoncus erat elementum faucibus. Aliquam egestas dui tempor nisi malesuada scelerisque.",
                          })),
              EditorDraggableWidgetIcon(
                  icon: Icons.text_fields_rounded,
                  name: "Header",
                  editorWidget: EditorWidgetTemplate(
                      getWidgetJson: () => {
                            "widgetType": widgetTypeHeader,
                            "text": "Click to edit header",
                          })),
              EditorDraggableWidgetIcon(
                  icon: Icons.border_outer_rounded,
                  name: "Spacer",
                  editorWidget: EditorWidgetTemplate(
                      getWidgetJson: () => {
                            "widgetType": widgetTypeSpacer,
                          })),
              EditorDraggableWidgetIcon(
                  icon: Icons.article_outlined,
                  name: "Notice",
                  editorWidget: EditorWidgetTemplate(
                      getWidgetJson: () => {
                            "widgetType": widgetTypeNote,
                            "text": "Click to edit note",
                          })),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: StorybridgeTextH2B("Answer Widgets"),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Wrap(
            children: [
              EditorDraggableWidgetIcon(
                  icon: Icons.keyboard_outlined,
                  name: "Text Field",
                  editorWidget: EditorWidgetTemplate(
                      getWidgetJson: () => {
                            "widgetType": widgetTypeAnswerText,
                            "quid": Random().nextInt(9999999).toString(),
                            "question": "question",
                            "answerHint": "",
                            "isLargeField": "false",
                            "validationRegex": "",
                          })),
              EditorDraggableWidgetIcon(
                  icon: Icons.expand_circle_down_outlined,
                  name: "Dropdown",
                  editorWidget: EditorWidgetTemplate(
                      getWidgetJson: () => {
                            "widgetType": widgetTypeAnswerDropdown,
                            "quid": Random().nextInt(9999999).toString(),
                            "question": "question",
                            "dropdowns": "A,B,C",
                          })),
              EditorDraggableWidgetIcon(
                  icon: Icons.check_box_outlined,
                  name: "Checkbox",
                  editorWidget: EditorWidgetTemplate(
                      getWidgetJson: () => {
                            "widgetType": widgetTypeAnswerCheckbox,
                            "quid": Random().nextInt(9999999).toString(),
                            "question": "question",
                            "checkboxes": "A,B,C",
                            "hasOtherField": false,
                          })),
              EditorDraggableWidgetIcon(
                  icon: Icons.splitscreen_rounded,
                  name: "Buttons",
                  editorWidget: EditorWidgetTemplate(
                      getWidgetJson: () => {
                            "widgetType": widgetTypeAnswerButtons,
                            "quid": Random().nextInt(9999999).toString(),
                            "question": "question",
                            "buttons": "Yes, No, N/A",
                            "hasOtherField": false,
                            "canMultiselect": false,
                          })),
              EditorDraggableWidgetIcon(
                  icon: Icons.calendar_month_outlined,
                  name: "Date Time",
                  editorWidget: EditorWidgetTemplate(
                      getWidgetJson: () => {
                            "widgetType": widgetTypeAnswerDatetime,
                            "quid": Random().nextInt(9999999).toString(),
                            "question": "question",
                            "datetimeMode": "show date and time",
                            "autofillMode": "none",
                          })),
              EditorDraggableWidgetIcon(
                  icon: Icons.attach_file_rounded,
                  name: "File Upload",
                  editorWidget: EditorWidgetTemplate(
                      getWidgetJson: () => {
                            "widgetType": widgetTypeAnswerFileupload,
                            "quid": Random().nextInt(9999999).toString(),
                            "question": "question",
                            "dropdowns": "A,B,C",
                          })),
              const SizedBox(height: 200),
            ],
          ),
        ),
      ],
    );
  }
}
