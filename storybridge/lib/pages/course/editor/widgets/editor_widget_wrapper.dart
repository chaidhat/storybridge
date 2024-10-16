import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/services/focus_service.dart';
import 'package:mooc/style/scholarity_colors.dart' as scholarity_color;
import 'package:mooc/services/saving_telemetry_service.dart'
    as saving_telemetry_service;
import 'package:mooc/services/showif_service.dart' as showif_service;

// myPage class which creates a state on call
// ignore: must_be_immutable
class EditorWidgetWrapper extends StatefulWidget {
  final EditorWidget child;
  int? index;
  final bool isAdminMode;
  final Function(Map<String, dynamic> newWidget, bool isTop, int index)?
      onAppendVertically;
  final Function(int index)? onRemoveVertically;
  Function()? onShowOverlay;
  Function()? onHideOverlay;
  EditorWidgetWrapper({
    Key? key,
    required this.child,
    this.index,
    required this.onAppendVertically,
    required this.onRemoveVertically,
    required this.isAdminMode,
  }) : super(key: key);

  @override
  _EditorWidgetWrapperState createState() => _EditorWidgetWrapperState();
}

// myPage state
class _EditorWidgetWrapperState extends State<EditorWidgetWrapper> {
  OverlayEntry? _entry;
  bool _isEntryShowing = false;
  bool _isDragging = false;
  bool _isOverlayWanted = false;
  final ScholarityFocusNode _focusNode = ScholarityFocusNode();
  final LayerLink _layerLink = LayerLink();
  late final _EditorWidgetWrapperDropzonesController dropzoneController =
      _EditorWidgetWrapperDropzonesController(setVal: () {
    setState(() {});
  });

  @override
  void initState() {
    // this is to make showing dialog safer (overlays are hidden)
    widget.onShowOverlay = _showOverlay;
    widget.onHideOverlay = _hideOverlay;
    super.initState();
  }

  @override
  void dispose() {
    _hideOverlay();
    super.dispose();
  }

  void _showOverlay() {
    _globalWrapper =
        widget; // this is to make showing dialog safer (overlays are hidden)
    _isOverlayWanted = true;
    if (_isEntryShowing) return;
    OverlayState? overlay = Overlay.of(context);
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;
    //Offset offset = renderBox.localToGlobal(Offset.zero);

    _entry = OverlayEntry(
        builder: (BuildContext context) => _EditorWidgetWrapperOverlay(
              isAdminMode: widget.isAdminMode,
              size: size,
              link: _layerLink,
              onDragStart: () {
                setState(() {
                  _isDragging = true;
                });
              },
              onDragEnd: () {
                setState(() {
                  _isDragging = false;
                  _focusNode.unfocus();
                  _hideOverlay();
                });
              },
              onMove: () {},
              onMoveGetWidgetJson: () {
                setState(() {
                  _isDragging = false;
                  _focusNode.unfocus();
                  _hideOverlay();
                });
                Map<String, dynamic> childJson = widget.child.saveToJson();
                widget.onRemoveVertically!(widget.index!);
                return childJson;
              },
              onRemove: () {
                widget.onRemoveVertically!(widget.index!);
                _focusNode.unfocus();
                _hideOverlay();
              },
              onShowAutomations: () {
                scholarityShowDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      ScholarityAlertDialogWrapper(
                    child: ScholarityAlertDialog(
                      content: EditorWidgetMetadataPopup(
                        controller: EditorWidgetMetadataController(
                          editorWidgetData: widget.child.editorWidgetData,
                          metadata: widget.child.metadata,
                          auditTemplateId: 10,
                        ),
                      ),
                    ),
                  ),
                );
              },
              initFocus: () {
                _focusNode.requestFocus();
              },
              child: widget.child,
            ));
    overlay.insert(_entry!);
    _isEntryShowing = true;
  }

  void _hideOverlay() async {
    _isOverlayWanted = false;
    await Future.delayed(const Duration(milliseconds: 200));
    if (_isOverlayWanted) {
      return; // the overlay has been double clicked, so it still wants to be shown.
    }
    if (_entry != null) {
      _entry!.remove();
      _entry = null;
      _isEntryShowing = false;
    }
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    if (!widget.isAdminMode) {
      return _EditorWidgetWrapperChild(
        isAdminMode: widget.isAdminMode,
        hasFocus: false,
        isGreyedOut: false,
        child: widget.child,
      );
    }
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        children: [
          Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  dropzoneController.isDraggedOverTop
                      ? const EditorWidgetDropIndicator()
                      : Container(),
                  /*
                  *
                  */
                  ScholarityFocus(
                      scholarityFocusNode: _focusNode,
                      z: widget.child.editorWidgetData.z,
                      onFocusChange: (bool hasFocus) {
                        if (hasFocus) {
                          saving_telemetry_service.indicateNotSaved();
                          _showOverlay();
                        } else {
                          saving_telemetry_service.indicateSaving();
                          _hideOverlay();
                        }
                      },
                      builder: ScholarityFocusBuilder(
                          builder: (BuildContext context, bool isFocused) {
                        return _EditorWidgetWrapperChild(
                          isAdminMode: widget.isAdminMode,
                          isGreyedOut: _isDragging,
                          hasFocus: isFocused,
                          child: widget.child,
                        );
                      })),
                  /*
                  *
                  */
                  dropzoneController.isDraggedOverBottom
                      ? const EditorWidgetDropIndicator()
                      : Container(),
                ],
              ),
              _EditorWidgetWrapperDropzones(
                controller: dropzoneController,
                onAccepted: (bool isTop, EditorWidgetTemplate data) {
                  Map<String, dynamic> newWidgetJson = data.getWidgetJson();
                  setState(() {
                    _isDragging = false;
                    widget.onAppendVertically!(
                        newWidgetJson, isTop, widget.index!);
                  });
                },
                isReduced: widget.child.reduceDropzoneSize!,
              )
            ],
          ),
        ],
      ),
    );
  }
}

// myPage class which creates a state on call
class _EditorWidgetWrapperOverlay extends StatefulWidget {
  // members of MyWidget
  final Map<String, dynamic> Function() onMoveGetWidgetJson;
  final void Function() onMove,
      onRemove,
      onShowAutomations,
      onDragStart,
      onDragEnd,
      initFocus;
  final Size size;
  final bool isAdminMode;
  final LayerLink link;
  final EditorWidget child;

  // constructor
  const _EditorWidgetWrapperOverlay(
      {Key? key,
      required this.size,
      required this.link,
      required this.onMoveGetWidgetJson,
      required this.onMove,
      required this.onRemove,
      required this.onShowAutomations,
      required this.onDragStart,
      required this.onDragEnd,
      required this.initFocus,
      required this.isAdminMode,
      required this.child})
      : super(key: key);

  @override
  _EditorWidgetWrapperOverlayState createState() =>
      _EditorWidgetWrapperOverlayState();
}

// myPage state
class _EditorWidgetWrapperOverlayState
    extends State<_EditorWidgetWrapperOverlay> {
  bool _isDragging = false;
  @override
  void initState() {
    super.initState();
    widget.initFocus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Positioned(
        width: widget.size.width,
        child: CompositedTransformFollower(
          link: widget.link,
          offset: const Offset(0, -60),
          child: Opacity(
            opacity: !_isDragging ? 1 : 0,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    boxShadow: const [scholarity_color.shadow],
                    color: scholarity_color.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: scholarity_color.borderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: IntrinsicWidth(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Draggable<EditorWidgetTemplate>(
                            onDragStarted: () {
                              widget.onDragStart();
                              _isDragging = true;
                            },
                            onDraggableCanceled: (_, _second) {
                              widget.onDragEnd();
                              _isDragging = false;
                            },
                            data: EditorWidgetTemplate(
                                getWidgetJson: widget.onMoveGetWidgetJson),
                            feedback: Opacity(
                              opacity: 0.8,
                              child: Container(
                                decoration: const BoxDecoration(
                                    boxShadow: [scholarity_color.highShadow]),
                                child: Material(
                                  child: _EditorWidgetWrapperChild(
                                    isAdminMode: widget.isAdminMode,
                                    hasFocus: true,
                                    child: widget.child,
                                  ),
                                ),
                              ),
                            ),
                            child: !_isDragging
                                ? ScholarityIconButton(
                                    icon: Icons.open_with_rounded,
                                    isGrabbable: true,
                                    onPressed: widget.onMove)
                                : Container(),
                          ),
                          const SizedBox(width: 4),
                          !_isDragging
                              ? ScholarityIconButton(
                                  icon: Icons.delete_outline_rounded,
                                  onPressed: widget.onRemove)
                              : Container(),
                          const SizedBox(width: 4),
                          !_isDragging
                              ? ScholarityIconButton(
                                  icon: Icons.visibility_outlined,
                                  onPressed: widget.onShowAutomations)
                              : Container(),
                          widget.child.getToolbar() != null
                              ? const SizedBox(
                                  width: 30,
                                )
                              : Container(),
                          widget.child.getToolbar() ?? Container(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class _EditorWidgetWrapperDropzonesController {
  bool isDraggedOverTop = false;
  bool isDraggedOverBottom = false;

  void Function() setVal;
  _EditorWidgetWrapperDropzonesController({required this.setVal});
}

class _EditorWidgetWrapperDropzones extends StatelessWidget {
  // members of MyWidget
  final _EditorWidgetWrapperDropzonesController controller;
  final void Function(bool isTop, EditorWidgetTemplate data) onAccepted;
  final bool? isReduced;

  // constructor
  const _EditorWidgetWrapperDropzones(
      {Key? key,
      required this.controller,
      required this.onAccepted,
      required this.isReduced})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    if (isReduced == null) {
      throw "isReduced (should I reduce the dropzone size from 50% to something smaller?) must be defined for EditorWidget!";
    }
    return Positioned.fill(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          Expanded(
              child: DragTarget<EditorWidgetTemplate>(
            builder: (
              BuildContext context,
              List<dynamic> accepted,
              List<dynamic> rejected,
            ) {
              return Container();
            },
            onMove: (_) {
              if (!controller.isDraggedOverTop) {
                controller.isDraggedOverTop = true;
                controller.setVal();
              }
            },
            onLeave: (_) {
              if (controller.isDraggedOverTop) {
                controller.isDraggedOverTop = false;
                controller.setVal();
              }
            },
            onAccept: (EditorWidgetTemplate data) {
              controller.isDraggedOverTop = false;
              controller.setVal();
              onAccepted(true, data);
            },
          )),
          isReduced!
              ? Flexible(
                  flex: controller.isDraggedOverTop ||
                          controller.isDraggedOverBottom
                      ? 5
                      : 6,
                  child: Container())
              : Container(),
          Expanded(
              child: DragTarget<EditorWidgetTemplate>(
            builder: (
              BuildContext context,
              List<dynamic> accepted,
              List<dynamic> rejected,
            ) {
              return Container();
            },
            onMove: (_) {
              if (!controller.isDraggedOverBottom) {
                controller.isDraggedOverBottom = true;
                controller.setVal();
              }
            },
            onLeave: (_) {
              if (controller.isDraggedOverBottom) {
                controller.isDraggedOverBottom = false;
                controller.setVal();
              }
            },
            onAccept: (EditorWidgetTemplate data) {
              controller.isDraggedOverBottom = false;
              controller.setVal();
              onAccepted(false, data);
            },
          )),
        ]));
  }
}

class _EditorWidgetWrapperChild extends StatelessWidget {
  // members of MyWidget
  final bool isAdminMode;
  final EditorWidget child;
  final bool hasFocus, isGreyedOut;

  // constructor
  const _EditorWidgetWrapperChild(
      {Key? key,
      required this.isAdminMode,
      required this.child,
      required this.hasFocus,
      this.isGreyedOut = false})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: !isGreyedOut ? 1 : 0.3,
      child: AnimatedContainer(
        constraints: const BoxConstraints(
            maxWidth: scholarity_color.scholarityHolderMaxWidthNotPadded),
        duration: const Duration(milliseconds: 200),
        curve: Curves.ease,
        decoration: BoxDecoration(
            color: scholarity_color.background,
            border: Border.all(
              color: hasFocus
                  ? scholarity_color.scholarityAccent
                  : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Material(
              color: scholarity_color.background,
              child: _ShowIfWrapper(isAdminMode: isAdminMode, child: child)),
        ),
      ),
    );
  }
}

// this is to make showing dialog safer (overlays are hidden)
EditorWidgetWrapper? _globalWrapper;

// this is to make showing dialog safer (overlays are hidden)
void _editorWidgetForceShowOverlay() {
  if (_globalWrapper != null) {
    if (_globalWrapper!.onShowOverlay != null) {
      _globalWrapper?.onShowOverlay!();
    }
  }
}

// this is to make showing dialog safer (overlays are hidden)
// this is also called when routing to new page
void editorWidgetForceHideOverlay() {
  if (_globalWrapper != null) {
    if (_globalWrapper!.onHideOverlay != null) {
      _globalWrapper?.onHideOverlay!();
    }
  }
}

// this is to make showing dialog safer (overlays are hidden)
void scholarityShowDialog(
    {required BuildContext context,
    required Widget Function(BuildContext) builder}) async {
  editorWidgetForceHideOverlay();
  await showDialog<String>(
    context: context,
    builder: builder,
  );
  _editorWidgetForceShowOverlay();
}

class _ShowIfWrapper extends StatefulWidget {
  // members of MyWidget
  final EditorWidget child;
  final bool isAdminMode;

  // constructor
  const _ShowIfWrapper(
      {Key? key, required this.child, required this.isAdminMode})
      : super(key: key);

  @override
  State<_ShowIfWrapper> createState() => _ShowIfWrapperState();
}

class _ShowIfWrapperState extends State<_ShowIfWrapper> {
  showif_service.ShowIfController? controller;
  @override
  void initState() {
    controller =
        showif_service.getShowIfController(widget.child.metadata.showIfs);
    controller!.addListener(onUpdate);
    super.initState();
  }

  void onUpdate(bool newValue) async {
    setState(() {});
    await Future.delayed(const Duration(seconds: 1));
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600),
        tween: Tween<double>(
            begin: 0, end: controller!.isShowing || widget.isAdminMode ? 1 : 0),
        curve: Curves.ease,
        builder: (BuildContext _, double anim, Widget? __) {
          return Opacity(opacity: anim, child: widget.child);
        });
  }
}
