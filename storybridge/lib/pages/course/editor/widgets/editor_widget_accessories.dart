import 'package:dotted_border/dotted_border.dart';

import 'package:flutter/material.dart';
import 'package:mooc/Storybridge.dart'; // Storybridge

import 'package:mooc/style/Storybridge_colors.dart' as Storybridge_color;

// myPage class which creates a state on call
class EditorWidgetTailer extends StatefulWidget {
  final Function(Map<String, dynamic> newWidget, bool isTop, int index)
      onAppendVertically;
  final int index;
  final bool reduceSize, isHidden;
  const EditorWidgetTailer(
      {Key? key,
      required this.onAppendVertically,
      required this.index,
      required this.isHidden,
      this.reduceSize = false})
      : super(key: key);

  @override
  EditorWidgetTailerState createState() => EditorWidgetTailerState();
}

// myPage state
class EditorWidgetTailerState extends State<EditorWidgetTailer> {
  bool _isBlank = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _isDraggedOverTop = false;

  void _setVal() {
    setState(() {});
  }

  void _onAccepted(EditorWidgetTemplate data) {
    Map<String, dynamic> newWidgetJson = data.getWidgetJson();

    // the widget is always at the bottom, because if there are no widgets, getIndex() returns -1
    widget.onAppendVertically(newWidgetJson, false, widget.index);
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    _isBlank = widget.index == -1; // if blank
    return DottedBorder(
      borderType: BorderType.RRect,
      color: _isBlank &&
              !widget.reduceSize /* reduce size also omits the dotted border */
          ? Storybridge_color.borderColor
          : Colors.transparent,
      strokeWidth: 1,
      dashPattern: const [8, 4],
      radius: _isBlank ? const Radius.circular(12) : Radius.zero,
      padding: _isBlank ? const EdgeInsets.all(6) : EdgeInsets.zero,
      strokeCap: StrokeCap.round,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            (_isBlank || widget.reduceSize) && !widget.isHidden
                ? const Center(
                    child: StorybridgeTextH5(
                        "Drag & Drop widgets from the right side into here"))
                : Container(),
            Stack(
              children: [
                _isDraggedOverTop
                    ? const EditorWidgetDropIndicator()
                    : Container(),
                DragTarget<EditorWidgetTemplate>(
                  builder: (
                    BuildContext context,
                    List<dynamic> accepted,
                    List<dynamic> rejected,
                  ) {
                    return Container(
                        color: Colors.transparent,
                        height: widget.isHidden
                            ? 0
                            : (!widget.reduceSize ? 300 : 100));
                  },
                  onMove: (_) {
                    if (!_isDraggedOverTop) {
                      _isDraggedOverTop = true;
                      _setVal();
                    }
                  },
                  onLeave: (_) {
                    if (_isDraggedOverTop) {
                      _isDraggedOverTop = false;
                      _setVal();
                    }
                  },
                  onAccept: (EditorWidgetTemplate data) {
                    _isDraggedOverTop = false;
                    _setVal();
                    _onAccepted(data);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditorWidgetDropIndicator extends StatelessWidget {
  // constructor
  const EditorWidgetDropIndicator({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        height: 5,
        decoration: BoxDecoration(
            color: Storybridge_color.StorybridgeAccent,
            borderRadius: BorderRadius.circular(2.5)),
      ),
    );
  }
}
