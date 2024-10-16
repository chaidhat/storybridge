import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/style/scholarity_colors.dart' as scholarity_color;

class EditorWidgetTemplate {
  final Map<String, dynamic> Function() getWidgetJson;
  const EditorWidgetTemplate({required this.getWidgetJson});
}

class EditorDraggableWidgetIcon extends StatelessWidget {
  final IconData icon;
  final String name;
  final EditorWidgetTemplate editorWidget;

  // constructor
  const EditorDraggableWidgetIcon({
    Key? key,
    required this.icon,
    required this.name,
    required this.editorWidget,
  }) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Draggable<EditorWidgetTemplate>(
        data: editorWidget,
        dragAnchorStrategy: childDragAnchorStrategy,
        feedback: Material(
          child: EditorWidgetIcon(
            isGrabbed: true,
            icon: icon,
            name: name,
          ),
        ),
        child: EditorWidgetIcon(
          icon: icon,
          name: name,
        ));
  }
}

class EditorWidgetIcon extends StatelessWidget {
  final bool isGrabbed;
  final IconData icon;
  final String name;
  final bool isWhiteButton;
  // constructor
  const EditorWidgetIcon({
    Key? key,
    required this.icon,
    required this.name,
    this.isWhiteButton = false,
    this.isGrabbed = false,
  }) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          isWhiteButton ? SystemMouseCursors.click : SystemMouseCursors.grab,
      child: Opacity(
        opacity: isGrabbed ? 0.8 : 1,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            width: 127,
            height: 80,
            decoration: BoxDecoration(
                boxShadow: isGrabbed ? [scholarity_color.highShadow] : null,
                color: !isWhiteButton
                    ? scholarity_color.backgroundDim
                    : scholarity_color.background,
                border: Border.all(color: scholarity_color.borderColor),
                borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Stack(
                children: [
                  Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child:
                            Icon(icon, size: 27, color: scholarity_color.grey),
                      )),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: ScholarityTextH5(name)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
