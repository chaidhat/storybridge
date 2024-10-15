import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mooc/Storybridge.dart'; // Storybridge

import 'package:mooc/style/Storybridge_colors.dart' as Storybridge_color;

abstract class WorkflowOverlay {
  Widget draw(AuditWorkflowCanvasController canvasController);
}

class WorkflowNodeConnection {
  WorkflowNode source;
  int outputNumber;
  WorkflowNode sink;
  int inputNumber;
  WorkflowNodeConnection(
      {required this.source,
      required this.outputNumber,
      required this.sink,
      required this.inputNumber});
}

enum WorkflowNodeTagType { Action, Trigger, Condition }

class WorkflowNode implements WorkflowOverlay {
  int workflowNodeId;
  int numberOfInputs;
  late int numberOfOutputs;
  final List<String> outputLabels;
  final Widget child;
  double x, y;
  double width = 300, height = 140;
  final WorkflowNodeTagType workflowNodeTagType;
  WorkflowNode({
    required this.workflowNodeId,
    required this.x,
    required this.y,
    required this.outputLabels,
    required this.child,
    required this.workflowNodeTagType,
    this.numberOfInputs = 1,
  }) {
    numberOfOutputs = outputLabels.length;
  }

  @override
  Widget draw(AuditWorkflowCanvasController canvasController) {
    return WorkflowNodeWidget(
        workflowNodeId: workflowNodeId,
        canvasController: canvasController,
        workflowNode: this,
        outputLabels: outputLabels,
        child: Center(child: child));
  }
}

class WorkflowArrowSource implements WorkflowOverlay {
  double x = 0, y = 0;
  double xOfDraggable = 0, yOfDraggable = 0;
  WorkflowNode node;
  int outputNumber;
  double verticalPadding;
  bool isHighlighted = false;
  bool isSource;
  WorkflowArrowSource({
    required this.node,
    required this.outputNumber,
    required this.verticalPadding,
    required this.isSource,
  }) {
    x = node.x + (node.width / (node.numberOfOutputs + 1) * (outputNumber + 1));
    y = node.y + node.height - verticalPadding;
    xOfDraggable = x;
    yOfDraggable = y;
  }
  @override
  Widget draw(AuditWorkflowCanvasController canvasController) {
    return WorkflowArrowSourceWidget(
      canvasController: canvasController,
      workflowArrowSource: this,
      isSource: isSource,
    );
  }
}

class WorkflowArrowSink implements WorkflowOverlay {
  double x = 0, y = 0;
  WorkflowNode node;
  int inputNumber;
  double verticalPadding;
  bool isHighlighted = false;
  bool isSink;
  WorkflowArrowSink(
      {required this.node,
      required this.inputNumber,
      required this.verticalPadding,
      required this.isSink}) {
    x = node.x + (node.width / (node.numberOfInputs + 1) * (inputNumber + 1));
    y = node.y + verticalPadding;
  }
  @override
  Widget draw(AuditWorkflowCanvasController canvasController) {
    return WorkflowArrowSinkWidget(
      canvasController: canvasController,
      workflowArrowSink: this,
      isSink: isSink,
    );
  }
}

// myPage class which creates a state on call
class WorkflowNodeWidget extends StatefulWidget {
  final AuditWorkflowCanvasController canvasController;
  final WorkflowNode workflowNode;
  final Widget child;
  final List<String> outputLabels;
  final int workflowNodeId;
  const WorkflowNodeWidget({
    Key? key,
    required this.canvasController,
    required this.workflowNode,
    required this.child,
    required this.outputLabels,
    required this.workflowNodeId,
  }) : super(key: key);

  @override
  _WorkflowNodeWidgetState createState() => _WorkflowNodeWidgetState();
}

// myPage state
class _WorkflowNodeWidgetState extends State<WorkflowNodeWidget> {
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
    // ignore: unused_local_variable
    return Positioned(
      left: widget.workflowNode.x,
      top: widget.workflowNode.y,
      child: Draggable(
        childWhenDragging: Opacity(
          opacity: 0.5,
          child: Container(
            width: widget.workflowNode.width,
            height: widget.workflowNode.height,
            padding: EdgeInsets.symmetric(
              horizontal: widget.canvasController.horizontalPadding,
              vertical: widget.canvasController.verticalPadding,
            ),
            child: WorkflowNodeWidgetBody(
              canvasController: widget.canvasController,
              workflowNodeId: widget.workflowNodeId,
              width: widget.workflowNode.width,
              height: widget.workflowNode.height,
              isBeingDragged: false,
              outputLabels: widget.outputLabels,
              workflowNodeType: widget.workflowNode.workflowNodeTagType,
              child: widget.child,
            ),
          ),
        ),
        onDragUpdate: (DragUpdateDetails dragDetails) {},
        onDragEnd: (dragDetails) {
          setState(() {
            widget.workflowNode.x = dragDetails.offset.dx -
                (widget.canvasController.canvasOffsetX ?? 0);
            // if applicable, don't forget offsets like app/status bar
            widget.workflowNode.y = dragDetails.offset.dy -
                (widget.canvasController.canvasOffsetY ?? 0);
            widget.canvasController.updateNodes();
          });
        },
        feedback: Container(
          height: widget.workflowNode.height,
          width: widget.workflowNode.width,
          padding: EdgeInsets.symmetric(
            horizontal: widget.canvasController.horizontalPadding,
            vertical: widget.canvasController.verticalPadding,
          ),
          child: Material(
            child: WorkflowNodeWidgetBody(
              canvasController: widget.canvasController,
              workflowNodeId: widget.workflowNodeId,
              width: widget.workflowNode.width,
              height: widget.workflowNode.height,
              outputLabels: widget.outputLabels,
              isBeingDragged: true,
              workflowNodeType: widget.workflowNode.workflowNodeTagType,
              child: widget.child,
            ),
          ),
        ),
        child: Container(
          width: widget.workflowNode.width,
          height: widget.workflowNode.height,
          padding: EdgeInsets.symmetric(
            horizontal: widget.canvasController.horizontalPadding,
            vertical: widget.canvasController.verticalPadding,
          ),
          child: WorkflowNodeWidgetBody(
            canvasController: widget.canvasController,
            workflowNodeId: widget.workflowNodeId,
            width: widget.workflowNode.width,
            height: widget.workflowNode.height,
            isBeingDragged: false,
            outputLabels: widget.outputLabels,
            workflowNodeType: widget.workflowNode.workflowNodeTagType,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// myPage class which creates a state on call
class WorkflowArrowSourceWidget extends StatefulWidget {
  final AuditWorkflowCanvasController canvasController;
  final WorkflowArrowSource workflowArrowSource;
  final bool isSource;
  const WorkflowArrowSourceWidget(
      {Key? key,
      required this.canvasController,
      required this.workflowArrowSource,
      required this.isSource})
      : super(key: key);

  @override
  _WorkflowArrowSourceWidgetState createState() =>
      _WorkflowArrowSourceWidgetState();
}

const double arrowSourceSize = 15;

// myPage state
class _WorkflowArrowSourceWidgetState extends State<WorkflowArrowSourceWidget> {
  double _dragX = 0;
  double _dragY = 0;
  bool _isHovered = false;
  bool _isDragged = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onHoverChanged({required bool enabled}) {
    setState(() {
      _isHovered = enabled;
    });
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    _dragX = widget.workflowArrowSource.x;
    _dragY = widget.workflowArrowSource.y;
    return Positioned(
      left: widget.workflowArrowSource.x - max(arrowSourceSize * 0.5, 20),
      top: widget.workflowArrowSource.y - (arrowSourceSize * 0.5),
      child: Column(
        children: [
          Draggable(
            onDragStarted: () {
              setState(() {
                _isDragged = true;
              });
            },
            onDragUpdate: (details) {
              _dragX += details.delta.dx;
              _dragY += details.delta.dy;
              widget.workflowArrowSource.xOfDraggable = _dragX;
              widget.workflowArrowSource.yOfDraggable = _dragY;
              widget.canvasController.updateArrowSources();
            },
            onDragEnd: ((details) {
              setState(() {
                _isDragged = false;
              });
              widget.canvasController.connectArrow();
              widget.workflowArrowSource.xOfDraggable =
                  widget.workflowArrowSource.x;
              widget.workflowArrowSource.yOfDraggable =
                  widget.workflowArrowSource.y;
              _dragX = widget.workflowArrowSource.x;
              _dragY = widget.workflowArrowSource.y;
              widget.canvasController.updateArrowSources();
            }),
            feedback: Container(),
            child: MouseRegion(
                onEnter: (PointerEnterEvent event) =>
                    _onHoverChanged(enabled: true),
                onExit: (PointerExitEvent event) =>
                    _onHoverChanged(enabled: false),
                child: Container(
                  height: arrowSourceSize,
                  width: arrowSourceSize,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: widget.isSource
                              ? Storybridge_color.borderColor
                              : Colors.transparent,
                          width: 1),
                      color: widget.isSource
                          ? Storybridge_color.background
                          : Colors.blue[100]),
                )),
          ),
          Opacity(
              opacity:
                  widget.isSource ? 0 : (_isHovered && !_isDragged ? 0.5 : 0.1),
              child: Icon(Icons.arrow_downward_rounded,
                  color: Storybridge_color.black, size: 40)),
        ],
      ),
    );
  }
}

class WorkflowNodeWidgetBody extends StatelessWidget {
  // members of MyWidget
  final Widget child;
  final WorkflowNodeTagType workflowNodeType;
  final AuditWorkflowCanvasController canvasController;
  final bool isBeingDragged;
  final double width, height;
  final List<String> outputLabels;
  final int workflowNodeId;

  // constructor
  const WorkflowNodeWidgetBody({
    Key? key,
    required this.child,
    required this.width,
    required this.height,
    required this.isBeingDragged,
    required this.outputLabels,
    required this.workflowNodeType,
    required this.workflowNodeId,
    required this.canvasController,
  }) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          border: Border.all(color: Storybridge_color.borderColor, width: 1),
          borderRadius: BorderRadius.circular(8),
          color: Storybridge_color.background,
          boxShadow:
              isBeingDragged ? const [Storybridge_color.highShadow] : const [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Stack(children: [
            StorybridgePadding(child: child),
            Align(
                alignment: Alignment.topRight,
                child: Opacity(
                  opacity: 0.1,
                  child: PopupMenuButton(
                    tooltip: "",
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(
                          onTap: () {
                            canvasController.removeNode(workflowNodeId);
                          },
                          child: const StorybridgeTextBasic("Delete"),
                        ),
                      ];
                    },
                    child: Icon(Icons.more_vert_rounded,
                        color: Storybridge_color.black),
                  ),
                )),
            Align(
                alignment: Alignment.topLeft,
                child: WorkflowNodeTag(
                  workflowNodeTagType: workflowNodeType,
                )),
            Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  width: width - 100,
                  child: Row(
                      children: List.generate(outputLabels.length, (int i) {
                    return Expanded(
                        child: StorybridgeTextSmall(
                      outputLabels[i],
                      textAlign: TextAlign.center,
                    ));
                  })),
                )),
          ]),
        ));
  }
}

class WorkflowArrowSinkWidget extends StatefulWidget {
  // members of MyWidget
  final AuditWorkflowCanvasController canvasController;
  final WorkflowArrowSink workflowArrowSink;
  final bool isSink;

  // constructor
  const WorkflowArrowSinkWidget(
      {Key? key,
      required this.canvasController,
      required this.workflowArrowSink,
      required this.isSink})
      : super(key: key);

  @override
  State<WorkflowArrowSinkWidget> createState() =>
      _WorkflowArrowSinkWidgetState();
}

class _WorkflowArrowSinkWidgetState extends State<WorkflowArrowSinkWidget> {
  bool _isHovered = false;

  void _onHoverChanged({required bool enabled}) {
    setState(() {
      _isHovered = enabled;
    });
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: widget.workflowArrowSink.x - max(arrowSourceSize * 0.5, 20),
        top: widget.workflowArrowSink.y - (arrowSourceSize * 0.5) - 40,
        child: MouseRegion(
          onEnter: (PointerEnterEvent event) => _onHoverChanged(enabled: true),
          onExit: (PointerExitEvent event) => _onHoverChanged(enabled: false),
          child: InkWell(
            onTap: () {
              widget.canvasController.deleteArrow(widget.workflowArrowSink);
            },
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Column(
              children: [
                widget.isSink
                    ? Opacity(
                        opacity: _isHovered ? 1 : 0,
                        child: Icon(Icons.close_rounded,
                            color: _isHovered
                                ? Colors.red
                                : Storybridge_color.black,
                            size: 40))
                    : Opacity(
                        opacity: 0.1,
                        child: Icon(Icons.arrow_downward,
                            color: Storybridge_color.black, size: 40)),
                Container(
                    height: arrowSourceSize,
                    width: arrowSourceSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color:
                              widget.isSink ? Colors.transparent : Colors.blue,
                          width: 2),
                    )),
              ],
            ),
          ),
        ));
  }
}

class WorkflowNodeTag extends StatelessWidget {
  // members of MyWidget
  final WorkflowNodeTagType workflowNodeTagType;

  // constructor
  const WorkflowNodeTag({Key? key, required this.workflowNodeTagType})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    switch (workflowNodeTagType) {
      case WorkflowNodeTagType.Action:
        return const WorkflowNodeActionTag();
      case WorkflowNodeTagType.Trigger:
        return const WorkflowNodeTriggerTag();
      case WorkflowNodeTagType.Condition:
      default:
        return const WorkflowNodeConditionTag();
    }
  }
}

class WorkflowNodeActionTag extends StatelessWidget {
  // constructor
  const WorkflowNodeActionTag({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.orange.withAlpha(30)),
      child: const Padding(
        padding: EdgeInsets.only(top: 4, left: 4, bottom: 4, right: 12),
        child: IntrinsicWidth(
          child: Row(
            children: [
              Icon(Icons.bolt_rounded, size: 20, color: Colors.orange),
              SizedBox(
                width: 3,
              ),
              StorybridgeTextBasic("Action",
                  style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkflowNodeTriggerTag extends StatelessWidget {
  // constructor
  const WorkflowNodeTriggerTag({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.green.withAlpha(30)),
      child: const Padding(
        padding: EdgeInsets.only(top: 4, left: 4, bottom: 4, right: 12),
        child: IntrinsicWidth(
          child: Row(
            children: [
              Icon(Icons.play_circle_outline, size: 20, color: Colors.green),
              SizedBox(
                width: 3,
              ),
              StorybridgeTextBasic("Trigger",
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkflowNodeConditionTag extends StatelessWidget {
  // constructor
  const WorkflowNodeConditionTag({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.purple.withAlpha(30)),
      child: const Padding(
        padding: EdgeInsets.only(top: 4, left: 4, bottom: 4, right: 12),
        child: IntrinsicWidth(
          child: Row(
            children: [
              Icon(Icons.timer_outlined, size: 20, color: Colors.purple),
              SizedBox(
                width: 3,
              ),
              StorybridgeTextBasic("Wait",
                  style: TextStyle(
                      color: Colors.purple,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
