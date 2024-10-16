import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/style/scholarity_colors.dart' as scholarity_color;
import 'package:url_launcher/url_launcher.dart';

const widgetTypeLinkButton = "link_button";

class EditorWidgetLinkButton extends StatelessWidget implements EditorWidget {
  // constructor
  EditorWidgetLinkButton({Key? key, required this.editorWidgetData})
      : super(key: key);
  @override
  final bool reduceDropzoneSize = false;

  @override
  final EditorWidgetData editorWidgetData;

  @override
  late final EditorWidgetMetadata metadata;

  final ScholarityTextFieldController _controller =
      ScholarityTextFieldController();
  final ScholarityTextFieldController _linkController =
      ScholarityTextFieldController();

  // serialization
  @override
  void loadFromJson(Map<String, dynamic> json) {
    metadata = getMetadata(json, editorWidgetData);
    ;
    _controller.text = json["text"];
    _linkController.text = json["link"];
  }

  @override
  Map<String, dynamic> saveToJson() {
    return {
      "metadata": metadata.encode(),
      "widgetType": widgetTypeLinkButton,
      "text": _controller.text,
      "link": _linkController.text,
    };
  }

  @override
  void onCreate() {}

  @override
  void onRemove() {}

  @override
  Widget? getToolbar() {
    return null;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return ScholarityButton(
        padding: false,
        child: Align(
            alignment: Alignment.center,
            child: IntrinsicWidth(
                child: Container(
                    padding: !editorWidgetData.isAdminMode
                        ? const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 12)
                        : const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16),
                    child: ScholarityEditableText(
                        enabled: editorWidgetData.isAdminMode,
                        controller: _controller,
                        onSubmit: () {},
                        style: scholarityTextH5RedStyle)))),
        onPressed: () {
          if (!editorWidgetData.isAdminMode) {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => ScholarityAlertDialogWrapper(
                child: ScholarityAlertDialog(
                  content: _ScholarityLinkPopup(
                    linkController: _linkController,
                  ),
                ),
              ),
            );
          } else {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => ScholarityAlertDialogWrapper(
                child: ScholarityAlertDialog(
                  content: _ScholarityLinkSetting(
                    linkController: _linkController,
                    onSave: () {
                      editorWidgetData.onUpdate();
                    },
                  ),
                ),
              ),
            );
          }
        });
  }
}

class _ScholarityLinkSetting extends StatelessWidget {
  // members of MyWidget
  final ScholarityTextFieldController linkController;
  final Function() onSave;

  // constructor
  const _ScholarityLinkSetting({
    Key? key,
    required this.linkController,
    required this.onSave,
  }) : super(key: key);

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
        const ScholarityTextH2B("Send to Link"),
        const ScholarityTextP(
            "Please enter the url below of where you want to send the student to"),
        const SizedBox(height: 10),
        Column(
          children: [
            SizedBox(
                child: ScholarityTextField(
                    controller: linkController, label: "URL")),
            ScholarityButton(
              padding: false,
              text: "save",
              onPressed: () {
                onSave();
                Navigator.pop(context);
              },
            )
          ],
        ),
      ],
    );
  }
}

class _ScholarityLinkPopup extends StatelessWidget {
  // members of MyWidget
  final ScholarityTextFieldController linkController;

  // constructor
  const _ScholarityLinkPopup({
    Key? key,
    required this.linkController,
  }) : super(key: key);

  void _goToLink() {
    String url = linkController.text;
    launchUrl(Uri.parse(url));
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ScholarityButton(
                padding: false,
                onPressed: _goToLink,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    Text(linkController.text,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: scholarity_color.scholarityAccent)),
                    const SizedBox(width: 30),
                    Icon(Icons.arrow_forward_rounded,
                        color: scholarity_color.scholarityAccent)
                  ]),
                )),
            const SizedBox(width: 10),
          ],
        ),
        const SizedBox(height: 20),
        const ScholarityTextP(
            "You will be sent to this link.\nMake sure you don't click on any suspicious links."),
        const SizedBox(height: 20),
        ScholarityButton(
          padding: false,
          invertedColor: true,
          text: "Go to link",
          onPressed: _goToLink,
        )
      ],
    );
  }
}
