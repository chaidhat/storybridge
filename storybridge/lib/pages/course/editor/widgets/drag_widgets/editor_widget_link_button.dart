import 'package:flutter/material.dart';
import 'package:mooc/storybridge.dart'; // Storybridge

import 'package:mooc/style/storybridge_colors.dart' as storybridge_color;
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

  final StorybridgeTextFieldController _controller =
      StorybridgeTextFieldController();
  final StorybridgeTextFieldController _linkController =
      StorybridgeTextFieldController();

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
    return StorybridgeButton(
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
                    child: StorybridgeEditableText(
                        enabled: editorWidgetData.isAdminMode,
                        controller: _controller,
                        onSubmit: () {},
                        style: storybridgeTextH5RedStyle)))),
        onPressed: () {
          if (!editorWidgetData.isAdminMode) {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => StorybridgeAlertDialogWrapper(
                child: StorybridgeAlertDialog(
                  content: _StorybridgeLinkPopup(
                    linkController: _linkController,
                  ),
                ),
              ),
            );
          } else {
            showDialog<String>(
              context: context,
              builder: (BuildContext context) => StorybridgeAlertDialogWrapper(
                child: StorybridgeAlertDialog(
                  content: _StorybridgeLinkSetting(
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

class _StorybridgeLinkSetting extends StatelessWidget {
  // members of MyWidget
  final StorybridgeTextFieldController linkController;
  final Function() onSave;

  // constructor
  const _StorybridgeLinkSetting({
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
        StorybridgeIconButton(
            icon: Icons.close,
            onPressed: () {
              Navigator.pop(context);
            }),
        const SizedBox(height: 30),
        const StorybridgeTextH2B("Send to Link"),
        const StorybridgeTextP(
            "Please enter the url below of where you want to send the student to"),
        const SizedBox(height: 10),
        Column(
          children: [
            SizedBox(
                child: StorybridgeTextField(
                    controller: linkController, label: "URL")),
            StorybridgeButton(
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

class _StorybridgeLinkPopup extends StatelessWidget {
  // members of MyWidget
  final StorybridgeTextFieldController linkController;

  // constructor
  const _StorybridgeLinkPopup({
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
            StorybridgeButton(
                padding: false,
                onPressed: _goToLink,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    Text(linkController.text,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: storybridge_color.storybridgeAccent)),
                    const SizedBox(width: 30),
                    Icon(Icons.arrow_forward_rounded,
                        color: storybridge_color.storybridgeAccent)
                  ]),
                )),
            const SizedBox(width: 10),
          ],
        ),
        const SizedBox(height: 20),
        const StorybridgeTextP(
            "You will be sent to this link.\nMake sure you don't click on any suspicious links."),
        const SizedBox(height: 20),
        StorybridgeButton(
          padding: false,
          invertedColor: true,
          text: "Go to link",
          onPressed: _goToLink,
        )
      ],
    );
  }
}
