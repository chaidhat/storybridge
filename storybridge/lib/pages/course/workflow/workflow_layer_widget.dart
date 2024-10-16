import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:mooc/pages/course/workflow/workflow_canvas_widget.dart';
import 'package:mooc/pages/course/workflow/workflow_overlay_widgets.dart';
import 'dart:math';

import 'package:mooc/style/storybridge_colors.dart' as storybridge_color;

enum Direction { up, right, down, left }

class ScholsPainter extends CustomPainter {
  ScholsLayerController paintController;
  ScholsPainter({required this.paintController})
      : super(repaint: paintController.getListenable());

  @override
  void paint(Canvas canvas, Size size) {
    //580*648
    if (size.width > 1.0 && size.height > 1.0) {
      paintController.logicSize = size;
    }
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    for (ScholsPainterObject painterObject in paintController.objects) {
      painterObject.draw(canvas, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class ScholsPainterObject {
  late ScholsLayerController
      layerController; // this MUST be init by the layer controller when creating an instance of this
  ScholsPainterObject();
  void draw(Canvas canvas, Paint paint) {}
}

class ScholsPainterPoint extends ScholsPainterObject {
  double x = 0;
  double y = 0;
  Color color;
  ScholsPainterPoint({required this.x, required this.y, required this.color})
      : super();

  @override
  void draw(Canvas canvas, Paint paint) {
    paint.color = color;
    canvas.drawCircle(
        Offset(layerController.getAxisX(x), layerController.getAxisY(y)),
        layerController.getAxisBoth(1.5),
        paint);
  }
}

class ScholsPainterLine extends ScholsPainterObject {
  double x0 = 0;
  double y0 = 0;
  double x1 = 0;
  double y1 = 0;
  ScholsPainterLine({
    required this.x0,
    required this.y0,
    required this.x1,
    required this.y1,
  }) : super();

  @override
  void draw(Canvas canvas, Paint paint) {
    paint.color = layerController.style.lineColour;
    paint.strokeWidth = layerController.style.lineStrokeWidth;
    canvas.drawLine(
        Offset(layerController.getAxisX(x0), layerController.getAxisY(y0)),
        Offset(layerController.getAxisX(x1), layerController.getAxisY(y1)),
        paint);
  }
}

class ScholsPainterArc extends ScholsPainterObject {
  Offset pointA;
  Offset pointB;
  double startAngle;
  double sweepAngle;
  bool isBackground;
  ScholsPainterArc(
      {required this.pointA,
      required this.pointB,
      required this.startAngle,
      required this.sweepAngle,
      this.isBackground = false})
      : super();

  @override
  void draw(Canvas canvas, Paint paint) {
    if (!isBackground) {
      paint.color = layerController.style.lineColour;
    } else {
      paint.color = storybridge_color.backgroundDim;
    }
    paint.strokeWidth = layerController.style.lineStrokeWidth;
    canvas.drawArc(
        Rect.fromPoints(pointA, pointB), startAngle, sweepAngle, true, paint);
  }
}

class ScholsPainterDownArrow extends ScholsPainterObject {
  double x = 0;
  double y = 0;
  double size = 0;
  ScholsPainterDownArrow({
    required this.x,
    required this.y,
    required this.size,
  }) : super();

  @override
  void draw(Canvas canvas, Paint paint) {
    paint.color = layerController.style.lineColour;
    paint.strokeWidth = layerController.style.lineStrokeWidth;
    canvas.drawLine(
        Offset(layerController.getAxisX(x - size),
            layerController.getAxisY(y - size)),
        Offset(layerController.getAxisX(x), layerController.getAxisY(y)),
        paint);
    canvas.drawLine(
        Offset(layerController.getAxisX(x + size),
            layerController.getAxisY(y - size)),
        Offset(layerController.getAxisX(x), layerController.getAxisY(y)),
        paint);
  }
}

class ScholsPainterUpArrow extends ScholsPainterObject {
  double x = 0;
  double y = 0;
  double size = 0;
  ScholsPainterUpArrow({
    required this.x,
    required this.y,
    required this.size,
  }) : super();

  @override
  void draw(Canvas canvas, Paint paint) {
    paint.color = layerController.style.lineColour;
    paint.strokeWidth = layerController.style.lineStrokeWidth;
    canvas.drawLine(
        Offset(layerController.getAxisX(x - size),
            layerController.getAxisY(y + size)),
        Offset(layerController.getAxisX(x), layerController.getAxisY(y)),
        paint);
    canvas.drawLine(
        Offset(layerController.getAxisX(x + size),
            layerController.getAxisY(y + size)),
        Offset(layerController.getAxisX(x), layerController.getAxisY(y)),
        paint);
  }
}

class ScholsLayerStyle {
  final double arcRadius;
  final double lineStrokeWidth;
  late Color lineColour;
  ScholsLayerStyle({
    this.arcRadius = 24,
    this.lineStrokeWidth = 2,
    Color? lineColour,
  }) {
    if (lineColour == null) {
      this.lineColour = storybridge_color.darkGrey;
    } else {
      this.lineColour = lineColour;
    }
  }
}

class ScholsLayerController {
  List<ScholsPainterObject> objects = [];
  AuditWorkflowCanvasController canvasController;
  final ScholsLayerStyle style = ScholsLayerStyle();
  ScholsLayerController({required this.canvasController});

  final _updateTick = ValueNotifier<bool>(false);
  Listenable getListenable() {
    return _updateTick;
  }

  void repaint() {
    print("repainting...");
    _updateTick.value = !_updateTick.value;
  }

  //logic size in device
  Size? _logicalSize;
  set logicSize(Size size) => _logicalSize = size;

  //@param w is the design w;
  double getAxisX(double w) {
    return (w * _logicalSize!.width) / canvasController.canvasWidth!;
  }

// the y direction
  double getAxisY(double h) {
    return (h * _logicalSize!.height) / canvasController.canvasHeight!;
  }

  // diagonal direction value with design size s.
  double getAxisBoth(double s) {
    return s *
        sqrt((_logicalSize!.width * _logicalSize!.width +
                _logicalSize!.height * _logicalSize!.height) /
            (canvasController.canvasWidth! * canvasController.canvasWidth! +
                canvasController.canvasHeight! *
                    canvasController.canvasHeight!));
  }

  void clearObjects() {
    objects.clear();
  }

  void addObjects(ScholsPainterObject newObj) {
    newObj.layerController = this;
    objects.add(newObj);
  }

  void drawPath(List<Offset> path) {
    if (path.isEmpty) {
      return;
    }
    Offset? prevPoint;
    for (int i = 0; i < path.length; i++) {
      Offset p = path[i];
      if (prevPoint == null) {
        prevPoint = p;
        continue;
      }
      double marginX = 0, marginY = 0;
      double marginMultiplier = 1;
      if (prevPoint.dx == p.dx) {
        marginY = style.arcRadius;
        if (prevPoint.dy < p.dy) {
          marginMultiplier = -1;
        }
      }
      if (prevPoint.dy == p.dy) {
        marginX = style.arcRadius;
        if (prevPoint.dx < p.dx) {
          marginMultiplier = -1;
        }
      }
      double marginStartMultiplier = 0;
      double marginEndMultiplier = 0;
      /*
      double marginStartMultiplier = 1;
      double marginEndMultiplier = 1;
      if (i == 1) {
        marginStartMultiplier = 0;
      }
      if (i == path.length - 1) {
        marginEndMultiplier = 0;
      }
      if (futurePoint != null) {
        // L
        Direction? prevDirection;
        if (prevPoint.dx > p.dx) {
          prevDirection = Direction.right;
        } else if (prevPoint.dx < p.dx) {
          prevDirection = Direction.left;
        } else if (prevPoint.dy > p.dy) {
          prevDirection = Direction.down;
        } else if (prevPoint.dy < p.dy) {
          prevDirection = Direction.up;
        }
        Direction? futureDirection;
        if (futurePoint.dx > p.dx) {
          futureDirection = Direction.right;
        } else if (futurePoint.dx < p.dx) {
          futureDirection = Direction.left;
        } else if (futurePoint.dy > p.dy) {
          futureDirection = Direction.down;
        } else if (futurePoint.dy < p.dy) {
          futureDirection = Direction.up;
        }
        if (prevDirection == null || futureDirection == null) {
          continue;
        }
        // | UD, DU
        else if ((futureDirection == Direction.down &&
                prevDirection == Direction.up) ||
            (futureDirection == Direction.up &&
                prevDirection == Direction.down)) {
          addObjects(ScholsPainterLine(
            x0: p.dx,
            y0: p.dy - style.arcRadius / 2,
            x1: p.dx,
            y1: p.dy + style.arcRadius / 2,
          ));
        }
        //└ RU, UR
        else if ((futureDirection == Direction.right &&
                prevDirection == Direction.up) ||
            (futureDirection == Direction.up &&
                prevDirection == Direction.right)) {
          addObjects(ScholsPainterArc(
            pointA: p +
                Offset(-style.lineStrokeWidth / 2, style.lineStrokeWidth / 2),
            pointB: p +
                Offset(style.arcRadius + style.lineStrokeWidth / 2,
                    -style.arcRadius - style.lineStrokeWidth / 2),
            startAngle: pi / 2,
            sweepAngle: pi / 2,
          ));
          addObjects(ScholsPainterArc(
            pointA: p +
                Offset(style.lineStrokeWidth / 2, -style.lineStrokeWidth / 2),
            pointB: p + Offset(style.arcRadius, -style.arcRadius),
            startAngle: pi / 2,
            sweepAngle: pi / 2,
            isBackground: true,
          ));
        }
        //┘ LU, UL
        else if ((futureDirection == Direction.left &&
                prevDirection == Direction.up) ||
            (futureDirection == Direction.up &&
                prevDirection == Direction.left)) {
          addObjects(ScholsPainterArc(
            pointA: p +
                Offset(style.lineStrokeWidth / 2, style.lineStrokeWidth / 2),
            pointB: p +
                Offset(-style.arcRadius - style.lineStrokeWidth / 2,
                    -style.arcRadius - style.lineStrokeWidth / 2),
            startAngle: 0,
            sweepAngle: pi / 2,
          ));
          addObjects(ScholsPainterArc(
              pointA: p +
                  Offset(
                      -style.lineStrokeWidth / 2, -style.lineStrokeWidth / 2),
              pointB: p + Offset(-style.arcRadius, -style.arcRadius),
              startAngle: 0,
              sweepAngle: pi / 2,
              isBackground: true));
        }
        //┐ LD, DL
        else if ((futureDirection == Direction.left &&
                prevDirection == Direction.down) ||
            (futureDirection == Direction.down &&
                prevDirection == Direction.left)) {
          addObjects(ScholsPainterArc(
            pointA: p +
                Offset(style.lineStrokeWidth / 2, -style.lineStrokeWidth / 2),
            pointB: p +
                Offset(-style.arcRadius - style.lineStrokeWidth / 2,
                    style.arcRadius + style.lineStrokeWidth / 2),
            startAngle: 3 * pi / 2,
            sweepAngle: pi / 2,
          ));
          addObjects(ScholsPainterArc(
              pointA: p +
                  Offset(-style.lineStrokeWidth / 2, style.lineStrokeWidth / 2),
              pointB: p + Offset(-style.arcRadius, style.arcRadius),
              startAngle: 3 * pi / 2,
              sweepAngle: pi / 2,
              isBackground: true));
        }
        //┌ DR, RD
        else if ((futureDirection == Direction.right &&
                prevDirection == Direction.down) ||
            (futureDirection == Direction.down &&
                prevDirection == Direction.right)) {
          addObjects(ScholsPainterArc(
            pointA: p +
                Offset(-style.lineStrokeWidth / 2, -style.lineStrokeWidth / 2),
            pointB: p +
                Offset(style.arcRadius + style.lineStrokeWidth / 2,
                    style.arcRadius + style.lineStrokeWidth / 2),
            startAngle: pi,
            sweepAngle: pi / 2,
          ));
          addObjects(ScholsPainterArc(
              pointA: p +
                  Offset(style.lineStrokeWidth / 2, style.lineStrokeWidth / 2),
              pointB: p + Offset(style.arcRadius, style.arcRadius),
              startAngle: pi,
              sweepAngle: pi / 2,
              isBackground: true));
        }
      }
          */
      addObjects(ScholsPainterLine(
        x0: prevPoint.dx -
            marginX * marginMultiplier * 0.5 * marginStartMultiplier,
        y0: prevPoint.dy -
            marginY * marginMultiplier * 0.5 * marginStartMultiplier,
        x1: p.dx + marginX * marginMultiplier * 0.5 * marginEndMultiplier,
        y1: p.dy + marginY * marginMultiplier * 0.5 * marginEndMultiplier,
      ));

      // if last line in the path
      if (i == path.length - 1) {
        // draw arrow
        if (prevPoint.dy < p.dy) {
          addObjects(ScholsPainterDownArrow(
            x: p.dx,
            y: p.dy,
            size: 10,
          ));
        } else {
          addObjects(ScholsPainterUpArrow(
            x: p.dx,
            y: p.dy,
            size: 10,
          ));
        }
      }
      prevPoint = p;
    }
  }

  void drawPathBetweenVertices(Offset startVertex, Offset endVertex,
      {bool ignoreCollisions = false}) {
    bool found = false;
    List<Vertex> vertices = findAllIntersectionsVertices(endVertex);
    Queue<Line> lines = Queue();
    lines.addLast(Line(
        Vertex(Offset(startVertex.dx, startVertex.dy), [
          Offset(
              startVertex.dx, startVertex.dy - canvasController.verticalPadding)
        ]),
        true));
    int steps = 0;
    while (!found && lines.isNotEmpty) {
      Line l = lines.removeFirst();
      l.vertex.isVisited = true;
      // notate the location
      if (canvasController.isDebug) {
        addObjects(ScholsPainterPoint(
            x: l.vertex.position.dx,
            y: l.vertex.position.dy,
            color: Colors.red));
      }
      // check if found
      if (l.vertex.position.dy == endVertex.dy &&
          l.vertex.position.dx == endVertex.dx) {
        found = true;
        l.vertex.path!.add(l.vertex.position);
        l.vertex.path!.add(
            l.vertex.position + Offset(0, canvasController.verticalPadding));
        drawPath(l.vertex.path!);
        break;
      }
      // perform BFS for near search
      if (l.isHorizontal) {
        List<Vertex> horizontalVertices =
            findAllVerticesOnHorizontalLine(vertices, l.vertex, endVertex);
        for (Vertex v in horizontalVertices) {
          if (!isThisLineIntersectingNode(l.vertex.position, v.position) ||
              ignoreCollisions) {
            lines.addLast(Line(v, false));
            if (steps > canvasController.debugStepSize) {
              if (canvasController.isDebug) {
                addObjects(ScholsPainterPoint(
                    x: v.position.dx,
                    y: v.position.dy,
                    color: Colors.lightGreen));
              }
            }
          } else {
            if (steps > canvasController.debugStepSize) {
              if (canvasController.isDebug) {
                addObjects(ScholsPainterPoint(
                    x: v.position.dx, y: v.position.dy, color: Colors.green));
              }
            }
          }
        }
      } else {
        List<Vertex> verticalVertices =
            findAllVerticesOnVerticalLine(vertices, l.vertex, endVertex);
        for (Vertex v in verticalVertices) {
          if (!isThisLineIntersectingNode(l.vertex.position, v.position) ||
              ignoreCollisions) {
            lines.addLast(Line(v, true));
            if (steps > canvasController.debugStepSize) {
              if (canvasController.isDebug) {
                addObjects(ScholsPainterPoint(
                    x: v.position.dx,
                    y: v.position.dy,
                    color: Colors.lightGreen));
              }
            }
          } else {
            if (steps > canvasController.debugStepSize) {
              if (canvasController.isDebug) {
                addObjects(ScholsPainterPoint(
                    x: v.position.dx, y: v.position.dy, color: Colors.green));
              }
            }
          }
        }
      }
      if (steps > 500) {
        break; // too many calculations.
      }
      // debug step ahead
      if (steps > canvasController.debugStepSize && canvasController.isDebug) {
        l.vertex.path!.add(l.vertex.position);
        if (canvasController.isDebug) {
          addObjects(ScholsPainterPoint(
              x: l.vertex.position.dx,
              y: l.vertex.position.dy,
              color: Colors.orange));
          drawPath(l.vertex.path!);
        }
        break;
      }
      steps++;
    }
    if (!found && !ignoreCollisions) {
      drawPathBetweenVertices(startVertex, endVertex, ignoreCollisions: true);
    }
  }

  bool isThisLineIntersectingNode(Offset start, Offset end) {
    for (WorkflowNode n in canvasController.workflowNodes) {
      // if within
      if (start.dx > n.x &&
          start.dx < (n.x + n.width) &&
          start.dy > n.y &&
          start.dy < (n.y + n.height)) {
        return true;
      }
      // if within
      if (end.dx > n.x &&
          end.dx < (n.x + n.width) &&
          end.dy > n.y &&
          end.dy < (n.y + n.height)) {
        return true;
      }
      if (start.dx > n.x && start.dx < (n.x + n.width)) {
        // horizontal line
        if (start.dy <= n.y && end.dy >= (n.y + n.height)) {
          return true;
        }
        if (end.dy <= n.y && start.dy >= (n.y + n.height)) {
          return true;
        }
        // OK
      }
      if (start.dy > n.y && start.dy < (n.y + n.height)) {
        // horizontal line
        if (start.dx <= n.x && end.dx >= (n.x + n.width)) {
          return true;
        }
        if (end.dx <= n.x && start.dx >= (n.x + n.width)) {
          return true;
        }
        // OK
      }
    }
    return false;
  }

  List<Vertex> findAllVerticesOnVerticalLine(
      List<Vertex> vertices, Vertex srcVertex, Offset destVertex) {
    List<Vertex> output = [];
    for (Vertex vertex in vertices) {
      if (vertex.position.dx == srcVertex.position.dx) {
        if (!vertex.isVisited) {
          output.add(vertex.copy());
        }
      }
    }
    output.sort((a, b) {
      if ((a.position.dy - destVertex.dy).abs() >
          (b.position.dy - destVertex.dy).abs()) {
        return 1;
      } else {
        return -1;
      }
    });
    for (Vertex v in output) {
      v.copyPathFrom(srcVertex);
      v.path!.add(Offset(srcVertex.position.dx, srcVertex.position.dy));
    }
    return output;
  }

  List<Vertex> findAllVerticesOnHorizontalLine(
      List<Vertex> vertices, Vertex srcVertex, Offset destVertex) {
    List<Vertex> output = [];
    for (Vertex vertex in vertices) {
      if (vertex.position.dy == srcVertex.position.dy) {
        if (!vertex.isVisited) {
          output.add(vertex.copy());
        }
      }
    }
    output.sort((a, b) {
      if ((a.position.dx - destVertex.dx).abs() >
          (b.position.dx - destVertex.dx).abs()) {
        return 1;
      } else {
        return -1;
      }
    });
    for (Vertex v in output) {
      v.copyPathFrom(srcVertex);
      v.path!.add(Offset(srcVertex.position.dx, srcVertex.position.dy));
    }
    return output;
  }

  List<Vertex> findAllIntersectionsVertices(Offset endVertex) {
    List<double> verticalLines = [];
    List<double> horizontalLines = [];
    List<Vertex> intersections = [];
    verticalLines.add(endVertex.dx);
    horizontalLines.add(endVertex.dy);
    for (WorkflowNode node in canvasController.workflowNodes) {
      verticalLines.add(node.x);
      verticalLines.add(node.x + node.width);
      horizontalLines.add(node.y);
      horizontalLines.add(node.y + node.height);
    }
    for (double vLine in verticalLines) {
      for (double hLine in horizontalLines) {
        intersections.add(Vertex(Offset(vLine, hLine), null));
        if (canvasController.isDebug) {
          addObjects(
              ScholsPainterPoint(x: vLine, y: hLine, color: Colors.blue));
        }
      }
    }
    return intersections;
  }
}
