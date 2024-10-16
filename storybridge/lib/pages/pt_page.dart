import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'dart:convert' show utf8;

import 'package:file_picker/file_picker.dart';
import 'package:html_parser_plus/html_parser_plus.dart';

import 'package:flutter/material.dart';
import 'package:mooc/storybridge.dart'; // Storybridge

import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;

const List<String> _PUMPS = [
  "WFH",
  "Pump1",
];

// myPage class which creates a state on call
class PtPage extends StatefulWidget {
  const PtPage({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<PtPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _checkIsLoggedIn() async {
    return true;
    /*
    try {
      //Map<String, dynamic> response = await networking_api_service.adminPing();
      return true;
    } on error_service.StorybridgeException catch (error) {
      if (error.message == "Invalid admin token.") {
        Navigator.pushNamed(context, '/admin-auth');
        return true;
      } else {
        return false;
      }
    }
    */
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return FutureBuilder(
        future: _checkIsLoggedIn(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            return StorybridgeScaffold(
              hasAppbar: false,
              body: [],
              tabPrefix: StorybridgeTextP("PT Fleet Tracker"),
              tabNames: [
                StorybridgeTabHeader(
                    tabName: "Driver - daily check in", tabIcon: Icons.search),
                StorybridgeTabHeader(
                    tabName: "Car Status", tabIcon: Icons.search),
                StorybridgeTabHeader(
                    tabName: "Car List", tabIcon: Icons.search),
                StorybridgeTabHeader(
                    tabName: "Driver List", tabIcon: Icons.search),
                StorybridgeTabHeader(
                    tabName: "Plan List", tabIcon: Icons.search),
              ],
              tabs: [
                _PtDriverCheckinPage(),
                _PtCarStatusPage(),
                _PtCarListPage(),
                _PtDriverListPage(),
                _PtFlightplanListPage(),
              ],
            );
          } else {
            return Container(
                color: Colors.white,
                child:
                    const Center(child: StorybridgeTextP("Pinging server...")));
          }
        });
  }
}

class _PtDriverCheckinPage extends StatefulWidget {
  const _PtDriverCheckinPage({
    Key? key,
  }) : super(key: key);

  @override
  _PtDriverCheckinPageState createState() => _PtDriverCheckinPageState();
}

// myPage state
class _PtDriverCheckinPageState extends State<_PtDriverCheckinPage> {
  List<String> _licensePlates = [];

  Future<void> _createFlightplan() async {
    /*
    await networking_api_service.createFleetFlightplan(
        fleetCarId: 0,
        userId: 0,
        origin: "a",
        destination: "b",
        remark: "",
        fleetCompanyId: 1);
        */
  }

  Future<bool> _load() async {
    /*
    Map<String, dynamic> response =
        await networking_api_service.getFleetCars(fleetCompanyId: 1);
    _fleetCarIds.clear();
    _licensePlates.clear();
    for (var car in response["data"]) {
      _fleetCarIds.add(car["fleetCarId"]);
      _licensePlates.add(Uri.decodeComponent(car["licensePlate"]));
    }
    */
    return true;
  }

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
    return StorybridgeTabPage(body: [
      FutureBuilder<bool>(
          future: _load(),
          builder: (context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const StorybridgePageLoading();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Column(children: [
                  _PtDriverCheckinWidget(
                      cars: _licensePlates,
                      data: [_PtDriverCheckinData("WFH", "")])
                ]),
                StorybridgeButton(
                  text: "Submit",
                  onPressed: () {
                    _createFlightplan();
                  },
                )
              ],
            );
          })
    ]);
  }
}

class _PtCarStatusPage extends StatefulWidget {
  const _PtCarStatusPage({
    Key? key,
  }) : super(key: key);

  @override
  _PtCarStatusPageState createState() => _PtCarStatusPageState();
}

String pad(int numIdents) {
  String indent = "";
  for (int l = 0; l < numIdents; l++) {
    indent += " ";
  }
  return indent;
}

bool isNumeric(String s) {
  try {
    double.parse(s);
    return true;
  } catch (_) {
    return false;
  }
}

bool isDate(String? n) {
  if (n == null || n.length < 5) return false;
  return (n[1] == "2" && n[2] == "0" && isNumeric(n[3]) && isNumeric(n[4]));
}

// myPage state
class _PtCarStatusPageState extends State<_PtCarStatusPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<_PtDriverListData> data = [];

  void uploadGPS() async {
    try {
      data = [];
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      Uint8List? fileData = result?.files.first.bytes;
      if (fileData != null) {
        String htmlString = utf8.decode(fileData);
        final parser = HtmlParser();
        var node = parser.parse(htmlString);
        // trust the process
        // this is fucked
        var node2 = node.xpathNode?.children[1].children[0].children[0]
            .children[2].children[0].children[0].children[0].children;
        if (node2 != null) {
          int i = 0;
          for (var n in node2) {
            // find gpsStart
            if (isDate(n.text!)) {
              String gpsEnd = "";
              String gpsDistance = "";

              // find gpsEnd
              int j = i + 1;
              while (j < node2.length && !(isDate(node2[j].text!))) {
                j++;
              }
              j -= 2;
              if (j >= 0 && j < node2.length) {
                gpsEnd = node2[j].children[2].children[0].attributes["title"]!;
              }
              j++;
              if (j >= 0 && j < node2.length) {
                gpsDistance = node2[j].children[1].text!;
              }

              // upload
              data.add(_PtDriverListData(
                  date: n.text!,
                  gpsStart:
                      node2[i + 1].children[2].children[0].attributes["title"]!,
                  gpsEnd: gpsEnd,
                  gpsDistance: gpsDistance,
                  maxFleet: "0",
                  driver1Loc: "Pump1",
                  driver2Loc: "WFH",
                  remarks: ""));
            }
            i++;
          }
        }
      }
      setState(() {});
    } catch (e, stacktrace) {
      print(e);
      print(stacktrace);
    }
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgeTabPage(hasVeryReducedPadding: true, body: [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            StorybridgeButton(
              padding: false,
              text: "Upload GPS",
              onPressed: () {
                uploadGPS();
              },
            ),
            const StorybridgeTextH2("2ฒฬ-6128"),
            const SizedBox(height: 60),
            const Row(
              children: [
                SizedBox(width: 150, child: StorybridgeTextH2B("Date")),
                SizedBox(width: 20),
                SizedBox(width: 300, child: StorybridgeTextH2B("GPS")),
                SizedBox(width: 20),
                SizedBox(width: 150, child: StorybridgeTextH2B("GPS Distance")),
                SizedBox(width: 150, child: StorybridgeTextH2B("Max Fleet")),
                SizedBox(width: 20),
                SizedBox(width: 150, child: StorybridgeTextH2B("Driver 1")),
                SizedBox(width: 150, child: StorybridgeTextH2B("Driver 2")),
              ],
            ),
            const SizedBox(height: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(data.length, (int i) {
                return _PtDriverListWidget(data: data[i]);
              }),
            ),
          ],
        ),
      )
    ]);
  }
}

class _PtDriverCheckinData {
  StorybridgeTextFieldController location = StorybridgeTextFieldController();
  StorybridgeTextFieldController remark = StorybridgeTextFieldController();
  _PtDriverCheckinData(String location, String remark) {
    this.location.text = location;
    this.remark.text = remark;
  }
}

class _PtDriverCheckinWidget extends StatefulWidget {
  final List<String> cars;
  final List<_PtDriverCheckinData> data;

  // constructor
  _PtDriverCheckinWidget({Key? key, required this.cars, required this.data})
      : super(key: key) {}

  @override
  State<_PtDriverCheckinWidget> createState() => _PtDriverCheckinWidgetState();
}

class _PtDriverCheckinWidgetState extends State<_PtDriverCheckinWidget> {
  final StorybridgeTextFieldController _car = StorybridgeTextFieldController();
  Future<void> _addCheckinThing(int i) async {
    setState(() {
      widget.data.insert(i + 1, _PtDriverCheckinData("", ""));
    });
  }

  Future<void> _deleteCheckinThing(int i) async {
    setState(() {
      if (widget.data.length > 1) {
        widget.data.removeAt(i);
      }
    });
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StorybridgeTextH2B("Check-in"),
          const SizedBox(height: 20),
          StorybridgeBox(
            useAltStyle: true,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StorybridgeDatePicker(
                    label: "Date Start",
                    date: DateTime.now(),
                  ),
                  const SizedBox(height: 28),
                  StorybridgeDropdown(
                      label: "car",
                      controller: _car,
                      dropdownTypes: widget.cars),
                  const SizedBox(height: 28),
                  Column(
                      children: List.generate(widget.data.length, (int i) {
                    return Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 28),
                          child: StorybridgeDropdown(
                              label: "location",
                              controller: widget.data[i].location,
                              dropdownTypes: _PUMPS),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 10),
                          width: 250,
                          child: StorybridgeTextField(
                            label: "remark",
                            controller: widget.data[i].remark,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, bottom: 28),
                          child: StorybridgeIconButton(
                            icon: Icons.close,
                            onPressed: () {
                              _deleteCheckinThing(i);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10, bottom: 28),
                          child: StorybridgeIconButton(
                            icon: Icons.add,
                            onPressed: () {
                              _addCheckinThing(i);
                            },
                          ),
                        ),
                      ],
                    );
                  })),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PtDriverListData {
  String date,
      gpsStart,
      gpsEnd,
      gpsDistance,
      maxFleet,
      driver1Loc,
      driver2Loc,
      remarks;
  _PtDriverListData(
      {required this.date,
      required this.gpsStart,
      required this.gpsEnd,
      required this.gpsDistance,
      required this.maxFleet,
      required this.driver1Loc,
      required this.driver2Loc,
      required this.remarks});
}

class _PtDriverListWidget extends StatelessWidget {
  final _PtDriverListData data;

  // constructor
  const _PtDriverListWidget({Key? key, required this.data}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: StorybridgeTextH2B(data.date),
          ),
          const SizedBox(width: 20),
          _StorybridgeCell(
            child: StorybridgeTextP(data.gpsStart),
          ),
          _StorybridgeCell(
            child: StorybridgeTextP(data.gpsEnd),
          ),
          const SizedBox(width: 20),
          _StorybridgeCell(
            child: StorybridgeTextP(data.gpsDistance),
          ),
          _StorybridgeCell(
            child: StorybridgeTextP(data.maxFleet),
          ),
          const SizedBox(width: 20),
          _StorybridgeCell(
            child: StorybridgeTextP(data.driver1Loc),
          ),
          _StorybridgeCell(
            child: StorybridgeTextP(data.driver2Loc),
          ),
          const SizedBox(width: 20),
          _StorybridgeCell(
            width: 300,
            child: StorybridgeTextP(data.remarks),
          ),
        ],
      ),
    );
  }
}

class _StorybridgeCell extends StatelessWidget {
  // members of MyWidget
  final Widget child;
  final double width;

  // constructor
  const _StorybridgeCell({Key? key, required this.child, this.width = 150})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.only(right: 8, top: 8),
        child: StorybridgeTile(
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: child,
                ))),
      ),
    );
  }
}

String _generateDates(int daysAgo) {
  DateTime now = DateTime.now();
  now = now.subtract(Duration(days: daysAgo));
  return DateFormat('dd-MM-yyyy').format(now);
}

class _PtCarListPage extends StatefulWidget {
  const _PtCarListPage({
    Key? key,
  }) : super(key: key);

  @override
  _PtCarListPageState createState() => _PtCarListPageState();
}

// myPage state
class _PtCarListPageState extends State<_PtCarListPage> {
  bool _isLoadingAddCar = false;
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
    Map<String, dynamic> response =
        await networking_api_service.getFleetCars(fleetCompanyId: 1);
    return response["data"];
    */
  }

  Future<dynamic> _createCar() async {
    /*
    Map<String, dynamic> response =
        await networking_api_service.createFleetCar(fleetCompanyId: 1);
    setState(() {});
    return response["data"];
    */
  }

  Future<dynamic> _changeCar(int fleetCarId, dynamic carData) async {
    /*
    Map<String, dynamic> response = await networking_api_service.changeFleetCar(
        fleetCarId: fleetCarId,
        fleetCompanyId: carData["fleetCompanyId"],
        licensePlate: carData["licensePlate"],
        model: carData["model"]);
        */
    setState(() {});
    //return response["data"];
  }

  Future<dynamic> _removeCar(int fleetCarId) async {
    Map<String, dynamic> response =
        await networking_api_service.removeFleetCar(fleetCarId: fleetCarId);
    setState(() {});
    return response["data"];
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgeTabPage(hasVeryReducedPadding: true, body: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Row(
            children: [
              const StorybridgeTextH2("Car List"),
              Expanded(
                child: Container(),
              ),
              StorybridgeButton(
                text: "Add Car",
                icon: Icons.directions_car_rounded,
                loading: _isLoadingAddCar,
                padding: false,
                onPressed: () async {
                  setState(() {
                    _isLoadingAddCar = true;
                  });
                  await _createCar();
                  setState(() {
                    _isLoadingAddCar = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
          FutureBuilder(
              future: _load(),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  return StorybridgeTable(
                    data: snapshot.data,
                    displayHeaders: ["licensePlate", "model"],
                    onEdit: (var pk, dynamic data, int i) {
                      _changeCar(pk, data);
                    },
                    onDelete: (var pk, dynamic data, int i) {
                      _removeCar(pk);
                    },
                  );
                } else {
                  return const StorybridgePageLoading();
                }
              }),
        ],
      )
    ]);
  }
}

class _PtDriverListPage extends StatefulWidget {
  const _PtDriverListPage({
    Key? key,
  }) : super(key: key);

  @override
  _PtDriverListPageState createState() => _PtDriverListPageState();
}

// myPage state
class _PtDriverListPageState extends State<_PtDriverListPage> {
  bool _isLoadingAddCar = false;
  int organizationId = -1;
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
    Map<String, dynamic> response =
        await networking_api_service.getFleetAllUserData(fleetCompanyId: 1);
    Map<String, dynamic> response2 =
        await networking_api_service.getFleetCompany(fleetCompanyId: 1);
    organizationId = response2["data"][0]["organizationId"];
    return response["data"];
    */
  }

  Future<dynamic> _createDriver() async {
    StorybridgeTextFieldController newDriverEmailController =
        StorybridgeTextFieldController();
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => StorybridgeAlertDialogWrapper(
                child: StorybridgeAlertDialog(
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const StorybridgeTextH2B("Create Driver"),
                      const SizedBox(height: 20),
                      StorybridgeTextField(
                        label: "Email",
                        controller: newDriverEmailController,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          StorybridgeButton(
                            padding: false,
                            text: "Save",
                            invertedColor: true,
                            onPressed: () async {
                              /*
                              Map<String, dynamic> response =
                                  await networking_api_service
                                      .createFleetUserData(
                                fleetCompanyId: 1,
                                email: newDriverEmailController.text,
                                firstName: "Firstname",
                                lastName: "Lastname",
                              );
                              */
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
                  ),
                ),
              ),
            )));
  }

  Future<dynamic> _changeDriver(int fleetUserDataId, dynamic driverData) async {
    try {
      await networking_api_service.changeFleetUserData(
          fleetUserDataId: driverData["fleetUserDataId"],
          userId: driverData["userId"],
          email: driverData["email"],
          firstName: driverData["firstName"],
          lastName: driverData["lastName"],
          fleetCompanyId: driverData["fleetCompanyId"],
          nickname: driverData["nickname"],
          workplace: driverData["workplace"],
          employeeId: driverData["employeeId"],
          fleetUserType: driverData["fleetUserType"]);
    } catch (e) {
      print(e);
    }
    setState(() {});
    //return response["data"];
  }

  Future<dynamic> _removeDriver(int fleetUserDataId) async {
    print(fleetUserDataId);
    Map<String, dynamic> response = await networking_api_service
        .removeFleetUserData(fleetUserDataId: fleetUserDataId);
    setState(() {});
    return response["data"];
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgeTabPage(hasVeryReducedPadding: true, body: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Row(
            children: [
              const StorybridgeTextH2("Driver List"),
              Expanded(child: Container()),
              StorybridgeButton(
                text: "Go to Login",
                onPressed: () {
                  Navigator.pushNamed(
                      context, "/login?id=${organizationId.toString()}");
                },
              ),
              StorybridgeButton(
                text: "Add Driver",
                loading: _isLoadingAddCar,
                icon: Icons.person_rounded,
                onPressed: () async {
                  setState(() {
                    _isLoadingAddCar = true;
                  });
                  await _createDriver();
                  setState(() {
                    _isLoadingAddCar = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
          FutureBuilder(
              future: _load(),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  return StorybridgeTable(
                    data: snapshot.data,
                    pkName: "fleetUserDataId",
                    displayHeaders: [
                      "email",
                      "firstName",
                      "lastName",
                      "nickname",
                      "workplace",
                      "employeeId"
                    ],
                    onEdit: (var pk, dynamic data, int i) {
                      _changeDriver(pk, data);
                    },
                    onDelete: (var pk, dynamic data, int i) {
                      _removeDriver(pk);
                    },
                  );
                } else {
                  return const StorybridgePageLoading();
                }
              }),
        ],
      )
    ]);
  }
}

class _PtFlightplanListPage extends StatefulWidget {
  const _PtFlightplanListPage({
    Key? key,
  }) : super(key: key);

  @override
  _PtFlightplanListPageState createState() => _PtFlightplanListPageState();
}

// myPage state
class _PtFlightplanListPageState extends State<_PtFlightplanListPage> {
  bool _isLoadingAddCar = false;

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
    Map<String, dynamic> response =
        await networking_api_service.getFleetFlightplans(fleetCompanyId: 1);
        */
  }

  Future<dynamic> _createFlightplan() async {
    /*
    Map<String, dynamic> response =
        await networking_api_service.createFleetFlightplan(
            fleetCompanyId: 1,
            userId: 1,
            fleetCarId: 0,
            origin: "",
            destination: "",
            remark: "");
            */
    setState(() {});
    //return response["data"];
  }

  Future<dynamic> _removeFlightplan(int fleetFlightplanId) async {
    Map<String, dynamic> response = await networking_api_service
        .removeFleetFlightplan(fleetFlightplanId: fleetFlightplanId);
    setState(() {});
    return response["data"];
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgeTabPage(hasVeryReducedPadding: true, body: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          Row(
            children: [
              const StorybridgeTextH2("Plan List"),
              Expanded(child: Container()),
              StorybridgeButton(
                text: "Add Plan",
                loading: _isLoadingAddCar,
                padding: false,
                icon: Icons.pages_rounded,
                onPressed: () async {
                  setState(() {
                    _isLoadingAddCar = true;
                  });
                  await _createFlightplan();
                  setState(() {
                    _isLoadingAddCar = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 30),
          FutureBuilder(
              future: _load(),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  return StorybridgeTable(
                    data: snapshot.data,
                    onDelete: (var pk, dynamic data, int i) {
                      _removeFlightplan(pk);
                    },
                  );
                } else {
                  return const StorybridgePageLoading();
                }
              }),
        ],
      )
    ]);
  }
}
