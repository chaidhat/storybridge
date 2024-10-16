import 'dart:math';

import 'package:flutter/material.dart'; // Flutter
import 'package:fl_chart/fl_chart.dart';
import 'package:mooc/storybridge.dart';
import 'package:mooc/style/storybridge_colors.dart' as storybridge_color;

// myPage class which creates a state on call
class StorybridgeLineChart extends StatefulWidget {
  final int x;
  const StorybridgeLineChart({Key? key, required this.x}) : super(key: key);

  @override
  StorybridgeLineChartState createState() => StorybridgeLineChartState();
}

// myPage state
class StorybridgeLineChartState extends State<StorybridgeLineChart> {
  final StorybridgeTextFieldController _dateRangeSelector =
      StorybridgeTextFieldController();
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
    return SizedBox(
      width: 500,
      height: 400,
      child: StorybridgeTile(
        child: StorybridgePadding(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StorybridgeTextP("PT Work Flow"),
                    StorybridgeTextH2B("New Users"),
                  ],
                ),
                Expanded(child: Container()),
                StorybridgeDropdown(
                  controller: _dateRangeSelector,
                  label: "Date range",
                  dropdownTypes: const [
                    "Custom",
                    "Today",
                    "Yesterday",
                    "This Week",
                    "Last Week",
                    "Last 7 days",
                    "Last 14 days",
                    "Last 30 days",
                    "Last 60 days",
                    "Last 90 days",
                    "Quarter to date",
                    "Last 12 months",
                    "This year (Year to date)",
                    "Last year",
                  ],
                ),
                const SizedBox(width: 10),
                StorybridgeIconButton(
                  icon: Icons.settings_outlined,
                  onPressed: () {},
                ),
              ],
            ),
            Flexible(child: LineChartSample2()),
          ],
        )),
      ),
    );
  }
}

// myPage class which creates a state on call
class StorybridgePieChart extends StatefulWidget {
  final int x;
  const StorybridgePieChart({Key? key, required this.x}) : super(key: key);

  @override
  StorybridgePieChartState createState() => StorybridgePieChartState();
}

// myPage state
class StorybridgePieChartState extends State<StorybridgePieChart> {
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
    return SizedBox(
      width: 500,
      height: 400,
      child: StorybridgeTile(
        child: StorybridgePadding(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StorybridgeTextP("PT Work Flow"),
                    StorybridgeTextH2B("New Users"),
                  ],
                ),
                Expanded(child: Container()),
                StorybridgeIconButton(
                  icon: Icons.settings_outlined,
                  onPressed: () {},
                ),
              ],
            ),
            Flexible(child: PieChartSample2()),
          ],
        )),
      ),
    );
  }
}

// myPage class which creates a state on call
class StorybridgeNumberChart extends StatefulWidget {
  final int x;
  const StorybridgeNumberChart({Key? key, required this.x}) : super(key: key);

  @override
  StorybridgeNumberChartState createState() => StorybridgeNumberChartState();
}

// myPage state
class StorybridgeNumberChartState extends State<StorybridgeNumberChart> {
  final StorybridgeTextFieldController _dateRangeSelector =
      StorybridgeTextFieldController();
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
    return SizedBox(
      width: 240,
      height: 200,
      child: StorybridgeTile(
        child: StorybridgePadding(
            child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StorybridgeTextP("PT Work Flow"),
                    StorybridgeTextH2B("New Users"),
                  ],
                ),
                Expanded(child: Container()),
                StorybridgeIconButton(
                  icon: Icons.settings_outlined,
                  onPressed: () {
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) =>
                            StorybridgeNumberChartPopup(
                              onUpdate: () {
                                setState(() {});
                              },
                            ));
                  },
                ),
              ],
            ),
            Align(
                alignment: Alignment.bottomLeft,
                child: StorybridgeTextH2("25")),
          ],
        )),
      ),
    );
  }
}

class LineChartSample2 extends StatefulWidget {
  const LineChartSample2({super.key});

  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

List<FlSpot> getData() {
  List<FlSpot> output = [];
  double d = 2;
  for (double i = 0; i < 10; i += 0.5) {
    d = (Random().nextDouble()) * 5;
    output.add(FlSpot(i, d));
  }
  return output;
}

class _LineChartSample2State extends State<LineChartSample2> {
  bool showAvg = false;
  List<Color> gradientColors = [
    storybridge_color.auditBlue,
    storybridge_color.background,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),
      child: LineChart(
        mainData(),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    switch (value.toInt()) {
      case 2:
        text = const StorybridgeTextP('MAR');
        break;
      case 5:
        text = const StorybridgeTextP('MAR');
        break;
      case 8:
        text = const StorybridgeTextP('MAR');
        break;
      default:
        text = const Text('', style: style);
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 1:
        text = '10K';
        break;
      case 3:
        text = '30k';
        break;
      case 5:
        text = '50k';
        break;
      default:
        return Container();
    }

    return StorybridgeTextP(text, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBorder: BorderSide(color: storybridge_color.borderColor),
          tooltipBgColor: storybridge_color.background,
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((LineBarSpot touchedSpot) {
              final textStyle = storybridgeTextPStyle;
              return LineTooltipItem(
                  "${touchedSpot.x}\n${touchedSpot.y}", textStyle);
            }).toList();
          },
        ),
        getTouchedSpotIndicator:
            (LineChartBarData barData, List<int> spotIndexes) {
          return spotIndexes.map((spotIndex) {
            final spot = barData.spots[spotIndex];
            if (spot.x == 0 || spot.x == 6) {
              return null;
            }
            return TouchedSpotIndicatorData(
              FlLine(
                color: storybridge_color.auditBlue,
                strokeWidth: 2,
              ),
              FlDotData(
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: storybridge_color.auditBlue,
                  );
                },
              ),
            );
          }).toList();
        },
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: storybridge_color.borderColor,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.transparent,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: 0,
      maxX: 10,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: getData(),
          color: storybridge_color.auditBlue,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class PieChartSample2 extends StatefulWidget {
  const PieChartSample2({super.key});

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: showingSections(),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Indicator(color: Colors.blue, text: "HSE", isSquare: false),
              Indicator(color: Colors.blue, text: "Cargo", isSquare: false),
            ],
          )
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 16.0;
      final radius = isTouched ? 120.0 : 100.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            borderSide: BorderSide(
                color: storybridge_color.background,
                width: 2,
                strokeAlign: BorderSide.strokeAlignOutside),
            color: storybridge_color.auditBlue,
            value: 40,
            title: '40%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: storybridge_color.black,
            ),
          );
        case 1:
          return PieChartSectionData(
            borderSide: BorderSide(
                color: storybridge_color.background,
                width: 2,
                strokeAlign: BorderSide.strokeAlignOutside),
            color: storybridge_color.auditBlue.withAlpha(100),
            value: 30,
            title: '30%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: storybridge_color.black,
            ),
          );
        case 2:
          return PieChartSectionData(
            borderSide: BorderSide(
                color: storybridge_color.background,
                width: 2,
                strokeAlign: BorderSide.strokeAlignOutside),
            color: storybridge_color.auditBlue.withAlpha(50),
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: storybridge_color.black,
            ),
          );
        case 3:
          return PieChartSectionData(
            borderSide: BorderSide(
                color: storybridge_color.background,
                width: 2,
                strokeAlign: BorderSide.strokeAlignOutside),
            color: storybridge_color.auditBlue.withAlpha(200),
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: storybridge_color.black,
            ),
          );
        default:
          throw Error();
      }
    });
  }
}

class Indicator extends StatelessWidget {
  const Indicator({
    super.key,
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor,
  });
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        )
      ],
    );
  }
}

class StorybridgeNumberChartPopup extends StatefulWidget {
  final Function onUpdate;
  const StorybridgeNumberChartPopup({Key? key, required this.onUpdate})
      : super(key: key);

  @override
  StorybridgeNumberChartPopupState createState() =>
      StorybridgeNumberChartPopupState();
}

// myPage state
class StorybridgeNumberChartPopupState
    extends State<StorybridgeNumberChartPopup> {
  final List<String> _auditTemplates = [];
  final Map<String, int> _auditTemplateNameToId = {};
  StorybridgeTextFieldController templateController =
      StorybridgeTextFieldController();
  int userId = 0;

  bool canEdit = false;
  bool canComment = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<dynamic> _load() async {
    /*
    // get users from organization
    Map<String, dynamic> response = await networking_api_service
        .getAuditTemplates(organizationId: widget.organizationId);
    for (int i = 0; i < response["data"].length; i++) {
      String auditTemplateName =
          Uri.decodeComponent(response["data"][i]["auditTemplateName"]);
      _auditTemplates.add(auditTemplateName);
      _auditTemplateNameToId[auditTemplateName] =
          response["data"][i]["auditTemplateId"];
    }
    return response["data"];
    */
    return true;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return StorybridgeAlertDialogWrapper(
        child: StorybridgeAlertDialog(
      content: SingleChildScrollView(
        child: SizedBox(
          width: 500,
          child: FutureBuilder(
              future: _load(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (!snapshot.hasData) {
                  return const StorybridgeBoxLoading(height: 100, width: 300);
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const StorybridgeTextH2B("Chart settings"),
                    const SizedBox(height: 20),
                    StorybridgeDropdown(
                      label: "Data Source",
                      dropdownTypes: [
                        "Number of logins",
                        "Number of audits",
                        "Data types",
                        "Numerical Answers",
                      ],
                      controller: templateController,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        StorybridgeButton(
                          padding: false,
                          text: "Set",
                          invertedColor: true,
                          onPressed: () async {
                            _auditTemplateNameToId[templateController.text]!;
                            widget.onUpdate();
                            setState(() {});
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 10),
                        StorybridgeButton(
                            padding: false,
                            text: "Cancel",
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      ],
                    ),
                  ],
                );
              }),
        ),
      ),
    ));
  }
}
