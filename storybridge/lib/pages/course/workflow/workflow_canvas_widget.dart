// myPage class which creates a state on call
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/style/scholarity_colors.dart' as scholarity_color;
import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;

abstract class WorkflowNodeObject extends StatelessWidget {
  void loadData(dynamic data);
  dynamic saveData();
}

const Map<int, dynamic> workflowNodeTypeToObject = {
  0: {
    "workflowNodeTagType": WorkflowNodeTagType.Trigger,
    "text": "When audit form is created",
    "numberOfInputs": 0,
    "outputLabels": [""],
  },
  1: {
    "workflowNodeTagType": WorkflowNodeTagType.Condition,
    "text": "Wait for _____ to approve/reject.",
    "numberOfInputs": 1,
    "outputLabels": ["Rejected", "Approved"],
  },
  2: {
    "workflowNodeTagType": WorkflowNodeTagType.Condition,
    "text": "Wait for _____ to submit.",
    "numberOfInputs": 1,
    "outputLabels": [""],
  },
  3: {
    "workflowNodeTagType": WorkflowNodeTagType.Action,
    "text": "Email ____.",
    "numberOfInputs": 1,
    "outputLabels": [""],
  },
  4: {
    "workflowNodeTagType": WorkflowNodeTagType.Action,
    "text": "Set audit state to _____.",
    "numberOfInputs": 1,
    "outputLabels": [""],
  },
  5: {
    "workflowNodeTagType": WorkflowNodeTagType.Action,
    "text": "Share to ____ with permissions ____.",
    "numberOfInputs": 1,
    "outputLabels": [""],
  },
};

class Vertex {
  Offset position;
  bool isVisited = false;
  List<Offset>? path;
  Vertex(this.position, this.path);

  void copyPathFrom(Vertex v) {
    // note: v path must NOT be null
    if (v.path == null) {
      throw Exception("path of WorkflowVertex being copied is null");
    }
    path = [];
    for (int i = 0; i < v.path!.length; i++) {
      Offset o = v.path![i];
      path!.add(Offset(o.dx, o.dy));
    }
  }

  Vertex copy() {
    Vertex newVertex = Vertex(position, null);
    if (newVertex.path != null) {
      newVertex.copyPathFrom(this);
    }
    newVertex.isVisited = isVisited;
    return newVertex;
  }
}

class Line {
  Vertex vertex;
  bool isHorizontal;
  Line(this.vertex, this.isHorizontal);
}

class AuditWorkflowCanvasController {
  late final ScholsLayerController backgroundLayerController;
  late final ScholsLayerController masterLayerController;
  late final ScholsLayerController arrowDraggerLayerController;
  final List<WorkflowNode> workflowNodes;
  final List<WorkflowArrowSource> workflowArrowSources = [];
  final List<WorkflowArrowSink> workflowArrowSinks = [];
  final List<WorkflowNodeConnection> workflowNodeConnections = [];
  final int auditTemplateId;
  Function() onUpdateOverlays = () {
    throw Exception("must init onUpdateOverlays");
  };
  double? canvasOffsetX;
  double? canvasOffsetY;
  double? canvasWidth;
  double? canvasHeight;
  int debugStepSize = 10;
  bool isDebug = false;
  double verticalPadding = 20;
  double horizontalPadding = 10;
  double snapDistance = 50;

  AuditWorkflowCanvasController(
      {required this.workflowNodes, required this.auditTemplateId}) {
    backgroundLayerController = ScholsLayerController(canvasController: this);
    masterLayerController = ScholsLayerController(canvasController: this);
    arrowDraggerLayerController = ScholsLayerController(canvasController: this);
    load();
  }

// load networking_api_service.getWorkflow
  Future<void> load() async {
    Map<String, dynamic> response = await networking_api_service.getWorkflow(
        auditTemplateId: auditTemplateId);
    for (int i = 0; i < response["data"]["nodes"].length; i++) {
      var node = response["data"]["nodes"][i];
      int workflowNodeType = node["workflowNodetype"];
      var nodeData = jsonDecode(Uri.decodeComponent(node["data"]));
      workflowNodes.add(WorkflowNode(
          workflowNodeId: node["workflowNodeId"],
          x: nodeData["x"],
          y: nodeData["y"],
          numberOfInputs: workflowNodeTypeToObject[workflowNodeType]
              ["numberOfInputs"],
          workflowNodeTagType: workflowNodeTypeToObject[workflowNodeType]
              ["workflowNodeTagType"],
          outputLabels: workflowNodeTypeToObject[workflowNodeType]
              ["outputLabels"],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScholarityTextSmall(
                workflowNodeTypeToObject[workflowNodeType]["text"],
                textAlign: TextAlign.center,
              ),
            ],
          )));
    }
    for (int i = 0; i < response["data"]["connections"].length; i++) {
      var connection = response["data"]["connections"][i];
      WorkflowNode? sourceNode, sinkNode;
      for (int j = 0; j < workflowNodes.length; j++) {
        if (workflowNodes[j].workflowNodeId ==
            connection["sourceAuditWorkflowNodeId"]) {
          sourceNode = workflowNodes[j];
        }
        if (workflowNodes[j].workflowNodeId ==
            connection["sinkAuditWorkflowNodeId"]) {
          sinkNode = workflowNodes[j];
        }
      }
      if (sourceNode != null && sinkNode != null) {
        workflowNodeConnections.add(WorkflowNodeConnection(
            source: sourceNode,
            outputNumber: connection["sourceOutputNumber"],
            sink: sinkNode,
            inputNumber: connection["sinkInputNumber"]));
      }
    }
    drawDots();
    updateNodes();
  }

  void drawDots() {
    for (int i = 0; i < 2000; i += 30) {
      for (int j = 0; j < 2000; j += 30) {
        backgroundLayerController.addObjects(ScholsPainterPoint(
            x: i.toDouble(), y: j.toDouble(), color: const Color(0x20000000)));
      }
    }
  }

  Future<void> addNode(int workflowNodeType) async {
    Map<String, dynamic> response =
        await networking_api_service.createWorkflowNode(
            auditTemplateId: auditTemplateId,
            workflowNodeType: workflowNodeType,
            data: jsonEncode({"arguments": [], "x": 900, "y": 100}));
    workflowNodes.add(WorkflowNode(
        workflowNodeId: response["data"],
        x: 900,
        y: 100,
        numberOfInputs: workflowNodeTypeToObject[workflowNodeType]
            ["numberOfInputs"],
        workflowNodeTagType: workflowNodeTypeToObject[workflowNodeType]
            ["workflowNodeTagType"],
        outputLabels: workflowNodeTypeToObject[workflowNodeType]
            ["outputLabels"],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScholarityTextSmall(
              workflowNodeTypeToObject[workflowNodeType]["text"],
              textAlign: TextAlign.center,
            ),
          ],
        )));
    updateNodes();
  }

  void removeNode(int workflowNodeId) {
    for (var workflowNode in workflowNodes) {
      if (workflowNode.workflowNodeId == workflowNodeId) {
        // remove sources (nodes that it points to)
        for (int i = 0; i < workflowNodeConnections.length; i++) {
          if (workflowNodeConnections[i].source == workflowNode) {
            workflowNodeConnections.removeAt(i--);
          }
        }
        // remove sinks (nodes that points to it)
        for (int i = 0; i < workflowNodeConnections.length; i++) {
          if (workflowNodeConnections[i].sink == workflowNode) {
            workflowNodeConnections.removeAt(i--);
          }
        }
        workflowNodes.remove(workflowNode);
      }
    }
    networking_api_service.removeWorkflowNode(workflowNodeId: workflowNodeId);
    updateNodes();
  }

  void deleteArrow(WorkflowArrowSink sink) {
    for (WorkflowNodeConnection nodeConnection in workflowNodeConnections) {
      if (nodeConnection.sink == sink.node &&
          nodeConnection.inputNumber == sink.inputNumber) {
        networking_api_service.removeWorkflowConnection(
            sourceAuditWorkflowNodeId: nodeConnection.source.workflowNodeId,
            sinkAuditWorkflowNodeId: nodeConnection.sink.workflowNodeId);
        workflowNodeConnections.remove(nodeConnection);
        break;
      }
    }
    updateNodes();
  }

  void connectArrow() {
    // draw drag lines
    for (WorkflowArrowSource arrowSource in workflowArrowSources) {
      // is it being dragged rn?
      if (arrowSource.x != arrowSource.xOfDraggable ||
          arrowSource.y != arrowSource.yOfDraggable) {
        for (WorkflowArrowSink arrowSink in workflowArrowSinks) {
          // within range for snapping?
          if ((Offset(arrowSink.x, arrowSink.y) -
                      Offset(
                          arrowSource.xOfDraggable, arrowSource.yOfDraggable))
                  .distance <
              snapDistance) {
            // link them together
            networking_api_service.createWorkflowConnection(
              auditTemplateId: auditTemplateId,
              sinkAuditWorkflowNodeId: arrowSink.node.workflowNodeId,
              sinkInputNumber: arrowSink.inputNumber,
              sourceAuditWorkflowNodeId: arrowSource.node.workflowNodeId,
              sourceOutputNumber: arrowSource.outputNumber,
            );
            workflowNodeConnections.add(WorkflowNodeConnection(
                source: arrowSource.node,
                outputNumber: arrowSource.outputNumber,
                sink: arrowSink.node,
                inputNumber: arrowSink.inputNumber));
            updateNodes();
            return;
          }
        }
      }
    }
  }

  void updateArrowSources() {
    arrowDraggerLayerController.repaint();
    arrowDraggerLayerController.clearObjects();
    // draw drag lines
    for (WorkflowArrowSource arrowSource in workflowArrowSources) {
      // is it being dragged rn?
      if (arrowSource.x != arrowSource.xOfDraggable ||
          arrowSource.y != arrowSource.yOfDraggable) {
        bool drawToDragger = true;
        for (WorkflowArrowSink arrowSink in workflowArrowSinks) {
          // within range for snapping?
          if ((Offset(arrowSink.x, arrowSink.y) -
                      Offset(
                          arrowSource.xOfDraggable, arrowSource.yOfDraggable))
                  .distance <
              snapDistance) {
            drawNodeConnectedToNode(
                arrowSource.node,
                arrowSource.outputNumber,
                arrowSink.node,
                arrowSink.inputNumber,
                arrowDraggerLayerController);
            drawToDragger = false;
            break;
          }
        }
        if (drawToDragger) {
          arrowDraggerLayerController.drawPath([
            Offset(arrowSource.x, arrowSource.y),
            Offset(
                arrowSource.x,
                ((arrowSource.yOfDraggable - arrowSource.y) / 2) +
                    arrowSource.y),
            Offset(
                arrowSource.xOfDraggable,
                ((arrowSource.yOfDraggable - arrowSource.y) / 2) +
                    arrowSource.y),
            Offset(arrowSource.xOfDraggable, arrowSource.yOfDraggable),
          ]);
        }
      }
    }
  }

  void updateNodes() {
    masterLayerController.repaint();
    masterLayerController.clearObjects();
    workflowArrowSources.clear();
    workflowArrowSinks.clear();

    for (WorkflowNodeConnection nodeConnection in workflowNodeConnections) {
      drawNodeConnectedToNode(
          nodeConnection.source,
          nodeConnection.outputNumber,
          nodeConnection.sink,
          nodeConnection.inputNumber,
          masterLayerController);
    }
    // update position of arrow sources and sinks
    for (WorkflowNode nodeData in workflowNodes) {
      networking_api_service.changeWorkflowNode(
          workflowNodeId: nodeData.workflowNodeId,
          data:
              jsonEncode({"arguments": [], "x": nodeData.x, "y": nodeData.y}));

      for (int i = 0; i < nodeData.numberOfOutputs; i++) {
        bool isSource = false;
        for (WorkflowNodeConnection nodeConnection in workflowNodeConnections) {
          if (nodeConnection.source == nodeData &&
              nodeConnection.outputNumber == i) {
            isSource = true;
            break;
          }
        }
        workflowArrowSources.add(WorkflowArrowSource(
            node: nodeData,
            outputNumber: i,
            verticalPadding: verticalPadding,
            isSource: isSource));
      }
      for (int i = 0; i < nodeData.numberOfInputs; i++) {
        bool isSink = false;
        for (WorkflowNodeConnection nodeConnection in workflowNodeConnections) {
          if (nodeConnection.sink == nodeData &&
              nodeConnection.inputNumber == i) {
            isSink = true;
            break;
          }
        }
        workflowArrowSinks.add(WorkflowArrowSink(
            node: nodeData,
            inputNumber: i,
            verticalPadding: verticalPadding,
            isSink: isSink));
      }
    }
    updateArrowSources();
    onUpdateOverlays();
  }

  List<WorkflowOverlay> getWorkflowOverlays() {
    List<WorkflowOverlay> overlays = [];
    overlays.addAll(workflowNodes);
    overlays.addAll(workflowArrowSources);
    overlays.addAll(workflowArrowSinks);
    return overlays;
  }

  void drawNodeConnectedToNode(WorkflowNode startNode, int startNodeNumber,
      WorkflowNode endNode, int endNodeNumber, ScholsLayerController layer) {
    layer.drawPathBetweenVertices(
        Offset(
            startNode.x +
                (startNode.width / (startNode.numberOfOutputs.toDouble() + 1)) *
                    (startNodeNumber.toDouble() + 1),
            startNode.y + startNode.height),
        Offset(
            endNode.x +
                (endNode.width / (endNode.numberOfInputs.toDouble() + 1)) *
                    (endNodeNumber.toDouble() + 1),
            endNode.y));
  }
}

class AuditWorkflowCanvas extends StatefulWidget {
  final int auditTemplateId;
  const AuditWorkflowCanvas({Key? key, required this.auditTemplateId})
      : super(key: key);

  @override
  _AuditWorkflowCanvasState createState() => _AuditWorkflowCanvasState();
}

// myPage state
class _AuditWorkflowCanvasState extends State<AuditWorkflowCanvas> {
  GlobalKey key = GlobalKey();
  ScrollController hScroll = ScrollController(initialScrollOffset: 500);
  ScrollController vScroll = ScrollController(initialScrollOffset: 0);
  late final AuditWorkflowCanvasController canvasController;
  @override
  void initState() {
    super.initState();
    canvasController = AuditWorkflowCanvasController(
        workflowNodes: [], auditTemplateId: widget.auditTemplateId);
    init();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void init() async {
    await Future.delayed(const Duration(milliseconds: 500));
    canvasController.onUpdateOverlays = update;
    canvasController.masterLayerController.repaint();
    canvasController.updateNodes();
  }

  void update() {
    setState(() {});
  }

  void getOffsets() async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      RenderBox box = key.currentContext?.findRenderObject() as RenderBox;
      canvasController.canvasWidth = box.size.width;
      canvasController.canvasHeight = box.size.height;
      Offset position =
          box.localToGlobal(Offset.zero); //this is global position
      double x = position.dx; //this is y - I think it's what you want
      double y = position.dy; //this is y - I think it's what you want
      canvasController.canvasOffsetX = x;
      canvasController.canvasOffsetY = y;
    } catch (_) {
      return;
    }
    getOffsets();
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height - 100,
          child: SingleChildScrollView(
            controller: vScroll,
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              controller: hScroll,
              scrollDirection: Axis.horizontal,
              child: Container(
                key: key,
                child: Builder(builder: (context) {
                  getOffsets();
                  List<WorkflowOverlay> overlays =
                      canvasController.getWorkflowOverlays();
                  return SizedBox(
                    height: 2000,
                    width: 2000,
                    child: Scaffold(
                      backgroundColor: scholarity_color.backgroundDim,
                      body: Stack(
                        children: [
                          SizedBox(
                            height: 2000,
                            width: 2000,
                            child: CustomPaint(
                              painter: ScholsPainter(
                                paintController:
                                    canvasController.backgroundLayerController,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 2000,
                            width: 2000,
                            child: CustomPaint(
                              painter: ScholsPainter(
                                paintController:
                                    canvasController.masterLayerController,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 2000,
                            width: 2000,
                            child: CustomPaint(
                              painter: ScholsPainter(
                                paintController: canvasController
                                    .arrowDraggerLayerController,
                              ),
                            ),
                          ),
                          Stack(
                            children: List.generate(overlays.length, (int i) {
                              return overlays[i].draw(canvasController);
                            }),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
        PopupMenuButton(
          constraints: BoxConstraints.tightFor(width: 500),
          tooltip: "",
          // Callback that sets the selected popup menu item.
          itemBuilder: (BuildContext context) {
            List<PopupMenuEntry> output = [];
            for (int key in workflowNodeTypeToObject.keys) {
              output.add(
                PopupMenuItem(
                  onTap: () {
                    setState(() {
                      canvasController.addNode(key);
                    });
                  },
                  child: Row(
                    children: [
                      WorkflowNodeTag(
                        workflowNodeTagType: workflowNodeTypeToObject[key]
                            ["workflowNodeTagType"],
                      ),
                      const SizedBox(width: 20),
                      ScholarityTextBasic(
                          workflowNodeTypeToObject[key]["text"]),
                    ],
                  ),
                ),
              );
            }
            return output;
          },

          child: const SizedBox(
            width: 150,
            child: ScholarityButton(
              text: "Create Node",
              invertedColor: true,
            ),
          ),
        ),
      ],
    );
  }
}
