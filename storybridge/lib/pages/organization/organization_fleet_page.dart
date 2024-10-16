import 'dart:html' as html;
import 'package:excel/excel.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/error_service.dart' as error_service;

// myPage class which creates a state on call
class OrganizationFleetPage extends StatefulWidget {
  final int organizationId;
  const OrganizationFleetPage({Key? key, required this.organizationId})
      : super(key: key);

  @override
  _OrganizationFleetPageState createState() => _OrganizationFleetPageState();
}

// myPage state
class _OrganizationFleetPageState extends State<OrganizationFleetPage> {
  final ScholarityTabPageController _tabPageController =
      ScholarityTabPageController();
  int _selectedPage = 0;

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
    return ScholarityTabPage(
        hasVeryReducedPadding: true,
        tabPageController: _tabPageController,
        sideBar: [
          const SizedBox(height: 80),
          ScholaritySideBarButton(
              label: "Today's summary",
              icon: Icons.wb_sunny_outlined,
              onPressed: () {
                // hide mobile sidebar
                _tabPageController.mobileShowSidebar = false;
                _tabPageController.update();

                html.window.history.pushState(null, 'home',
                    "#/organization/fleet/today?id=${widget.organizationId}");
                setState(() {
                  _selectedPage = 0;
                });
              },
              selected: _selectedPage == 0),
          ScholaritySideBarButton(
              label: "Multisearch",
              icon: Icons.analytics_outlined,
              onPressed: () {
                // hide mobile sidebar
                _tabPageController.mobileShowSidebar = false;
                _tabPageController.update();

                html.window.history.pushState(null, 'home',
                    "#/organization/fleet/multisearch?id=${widget.organizationId}");
                setState(() {
                  _selectedPage = 1;
                });
              },
              selected: _selectedPage == 1),
          const ScholarityDivider(),
          ScholaritySideBarButton(
              label: "Vehicles",
              icon: Icons.local_shipping_outlined,
              onPressed: () {
                // hide mobile sidebar
                _tabPageController.mobileShowSidebar = false;
                _tabPageController.update();

                html.window.history.pushState(null, 'home',
                    "#/organization/fleet/vehicles?id=${widget.organizationId}");
                setState(() {
                  _selectedPage = 2;
                });
              },
              selected: _selectedPage == 2),
          ScholaritySideBarButton(
              label: "Drivers",
              icon: Icons.face_rounded,
              onPressed: () {
                // hide mobile sidebar
                _tabPageController.mobileShowSidebar = false;
                _tabPageController.update();

                html.window.history.pushState(null, 'home',
                    "#/organization/fleet/drivers?id=${widget.organizationId}");
                setState(() {
                  _selectedPage = 3;
                });
              },
              selected: _selectedPage == 3),
          ScholaritySideBarButton(
              label: "Locations",
              icon: Icons.location_on_outlined,
              onPressed: () {
                // hide mobile sidebar
                _tabPageController.mobileShowSidebar = false;
                _tabPageController.update();

                html.window.history.pushState(null, 'home',
                    "#/organization/fleet/locations?id=${widget.organizationId}");
                setState(() {
                  _selectedPage = 4;
                });
              },
              selected: _selectedPage == 4),
          const ScholarityDivider(),
          ScholaritySideBarButton(
              label: "GPS Integration",
              icon: Icons.track_changes_rounded,
              onPressed: () {
                // hide mobile sidebar
                _tabPageController.mobileShowSidebar = false;
                _tabPageController.update();

                html.window.history.pushState(null, 'home',
                    "#/organization/fleet/gps?id=${widget.organizationId}");
                setState(() {
                  _selectedPage = 5;
                });
              },
              selected: _selectedPage == 5),
          ScholaritySideBarButton(
              label: "Max Fleet Fuel",
              icon: Icons.local_gas_station_rounded,
              onPressed: () {
                // hide mobile sidebar
                _tabPageController.mobileShowSidebar = false;
                _tabPageController.update();

                html.window.history.pushState(null, 'home',
                    "#/organization/fleet/fuel?id=${widget.organizationId}");
                setState(() {
                  _selectedPage = 6;
                });
              },
              selected: _selectedPage == 6),
        ],
        body: [
          Builder(builder: (context) {
            switch (_selectedPage) {
              case 0:
                return _OrganizationFleetTodayPage(
                  organizationId: widget.organizationId,
                );
              case 1:
                return _OrganizationFleetDataPage(
                  organizationId: widget.organizationId,
                );
              case 2:
                return _OrganizationFleetVehiclesPage(
                  organizationId: widget.organizationId,
                );
              case 3:
                return _OrganizationFleetDriversPage(
                  organizationId: widget.organizationId,
                  controller: _OrganizationFleetDriversController(),
                );
              case 4:
              default:
                return _OrganizationFleetLocationsPage(
                  organizationId: widget.organizationId,
                );
            }
          })
        ]);
  }
}

// myPage class which creates a state on call
class _OrganizationFleetVehiclesPage extends StatefulWidget {
  final int organizationId;
  const _OrganizationFleetVehiclesPage({
    Key? key,
    required this.organizationId,
  }) : super(key: key);

  @override
  _OrganizationFleetVehiclesPageState createState() =>
      _OrganizationFleetVehiclesPageState();
}

// myPage state
class _OrganizationFleetVehiclesPageState
    extends State<_OrganizationFleetVehiclesPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<dynamic>> _load() async {
    Map<String, dynamic> response = await networking_api_service.getFleetCars(
        organizationId: widget.organizationId);
    return response["data"];
  }

  Future<dynamic> _createCar() async {
    Map<String, dynamic> response = await networking_api_service.createFleetCar(
        organizationId: widget.organizationId);
    setState(() {});
    return response["data"];
  }

  Future<dynamic> _changeCar(int fleetCarId, dynamic carData) async {
    await networking_api_service.changeFleetCar(
        fleetCarId: fleetCarId,
        organizationId: widget.organizationId,
        licensePlate: carData["licensePlate"],
        model: carData["model"]);
    setState(() {});
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
    return FutureBuilder(
        future: _load(),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return const ScholarityPageLoading();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Container()),
                  ScholarityButton(
                      text: "New",
                      invertedColor: true,
                      verticalOnlyPadding: true,
                      onPressed: () async {
                        await _createCar();
                      }),
                ],
              ),
              const SizedBox(height: 8),
              ScholarityTable(
                  advancedHeaders: [
                    ScholarityTableHeader(
                        key: "licensePlate", label: "License plate"),
                    ScholarityTableHeader(
                        width: 300, key: "model", label: "Vehicle model"),
                  ],
                  onEdit: (var pk, dynamic data, int i) {
                    _changeCar(pk, data);
                  },
                  onDelete: (var pk, dynamic data, int i) {
                    _removeCar(pk);
                  },
                  data: snapshot.data!)
            ],
          );
        });
  }
}

class _OrganizationFleetDriversController {
  int? driverUserId;
}

// myPage class which creates a state on call
class _OrganizationFleetDriversPage extends StatefulWidget {
  final int organizationId;
  final _OrganizationFleetDriversController controller;
  const _OrganizationFleetDriversPage(
      {Key? key, required this.organizationId, required this.controller})
      : super(key: key);

  @override
  _OrganizationFleetDriversPageState createState() =>
      _OrganizationFleetDriversPageState();
}

// myPage state
class _OrganizationFleetDriversPageState
    extends State<_OrganizationFleetDriversPage> {
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
    if (widget.controller.driverUserId == null) {
      return _OrganizationFleetDriversAllPage(
          organizationId: widget.organizationId,
          controller: widget.controller,
          onUpdate: () {
            setState(() {});
          });
    }
    return _OrganizationFleetDriversHistoryPage(
        controller: widget.controller,
        onUpdate: () {
          setState(() {});
        });
  }
}

// myPage class which creates a state on call
class _OrganizationFleetDriversAllPage extends StatefulWidget {
  final int organizationId;
  final _OrganizationFleetDriversController controller;
  final void Function() onUpdate;
  const _OrganizationFleetDriversAllPage({
    Key? key,
    required this.organizationId,
    required this.controller,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _OrganizationFleetDriversAllPageState createState() =>
      _OrganizationFleetDriversAllPageState();
}

// myPage state
class _OrganizationFleetDriversAllPageState
    extends State<_OrganizationFleetDriversAllPage> {
  final List<String> _users = [];
  final Map<String, int> _userToId = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<dynamic>> _load() async {
    Map<String, dynamic> response = await networking_api_service
        .getFleetDrivers(organizationId: widget.organizationId);
    // get privileges
    Map<String, dynamic> responsePrivs =
        await networking_api_service.getOrganizationPrivilegesForOrganization(
            organizationId: widget.organizationId);
    for (var user in responsePrivs["data"]) {
      String key = Uri.decodeComponent(
          "${user["email"]} - ${user["firstName"]} ${user["lastName"]}");
      _users.add(key);
      _userToId[key] = user["userId"];
    }
    // get users
    Map<String, dynamic> responseUsers = await networking_api_service
        .getUserFromOrganizationId(organizationId: widget.organizationId);
    for (var user in responseUsers["data"]) {
      String key = Uri.decodeComponent(
          "${user["email"]} - ${user["firstName"]} ${user["lastName"]}");
      _users.add(key);
      _userToId[key] = user["userId"];
    }
    return response["data"];
  }

  Future<dynamic> _createDriver() async {
    ScholarityTextFieldController userController =
        ScholarityTextFieldController();
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => ScholarityAlertDialogWrapper(
                child: ScholarityAlertDialog(
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const ScholarityTextH2B("Assign user as driver"),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 300,
                        child: ScholarityDropdown(
                            label: "User",
                            controller: userController,
                            dropdownTypes: _users),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          ScholarityButton(
                            padding: false,
                            text: "Assign",
                            invertedColor: true,
                            onPressed: () async {
                              int? userId = _userToId[userController.text];
                              if (userId == null) {
                                return;
                              }

                              await networking_api_service.createFleetDriver(
                                  userId: userId,
                                  organizationId: widget.organizationId);

                              setState(() {});
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(width: 10),
                          ScholarityButton(
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
    setState(() {});
  }

  Future<dynamic> _removeDriver(int fleetDriverId) async {
    Map<String, dynamic> response = await networking_api_service
        .removeFleetDriver(fleetDriverId: fleetDriverId);
    setState(() {});
    return response["data"];
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _load(),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return const ScholarityPageLoading();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Container()),
                  ScholarityButton(
                      icon: Icons.sync_alt_rounded,
                      text: "Assign",
                      invertedColor: true,
                      onPressed: () async {
                        await _createDriver();
                      }),
                  OrganizationAuthShareWidget(
                    organizationId: widget.organizationId,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ScholarityTable(
                  advancedHeaders: [
                    ScholarityTableHeader(key: "email", label: "Email"),
                    ScholarityTableHeader(
                        key: "firstName", label: "First name"),
                    ScholarityTableHeader(key: "lastName", label: "Last name"),
                  ],
                  onView: (dynamic pk, dynamic data, int index) {
                    Navigator.pushNamed(context, '/user?id=${data["userId"]}');
                  },
                  extraButtons: [
                    ScholarityTableButton(
                        buttonText: "History",
                        onPressed: (dynamic pk, dynamic data) {
                          widget.controller.driverUserId = data["userId"];
                          widget.onUpdate();
                        }),
                  ],
                  onDelete: (var pk, dynamic data, int i) {
                    _removeDriver(pk);
                  },
                  data: snapshot.data!)
            ],
          );
        });
  }
}

// myPage class which creates a state on call
class _OrganizationFleetLocationsPage extends StatefulWidget {
  final int organizationId;
  const _OrganizationFleetLocationsPage({
    Key? key,
    required this.organizationId,
  }) : super(key: key);

  @override
  _OrganizationFleetLocationsPageState createState() =>
      _OrganizationFleetLocationsPageState();
}

// myPage state
class _OrganizationFleetLocationsPageState
    extends State<_OrganizationFleetLocationsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<dynamic>> _load() async {
    Map<String, dynamic> response = await networking_api_service
        .getFleetLocations(organizationId: widget.organizationId);
    return response["data"];
  }

  Future<dynamic> _createLocation() async {
    ScholarityTextFieldController locationNameController =
        ScholarityTextFieldController();
    ScholarityTextFieldController gpsController =
        ScholarityTextFieldController();
    ScholarityTextFieldController subdistrictController =
        ScholarityTextFieldController();
    ScholarityTextFieldController districtController =
        ScholarityTextFieldController();
    ScholarityTextFieldController provinceController =
        ScholarityTextFieldController();
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => ScholarityAlertDialogWrapper(
                child: ScholarityAlertDialog(
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const ScholarityTextH2B("Add Location"),
                      const SizedBox(height: 20),
                      SizedBox(
                          width: 300,
                          child: ScholarityTextField(
                            label: "Location Name",
                            controller: locationNameController,
                          )),
                      SizedBox(
                          width: 300,
                          child: ScholarityTextField(
                              label: "GPS", controller: gpsController)),
                      SizedBox(
                          width: 300,
                          child: ScholarityTextField(
                              label: "Subdistrict",
                              controller: subdistrictController)),
                      SizedBox(
                          width: 300,
                          child: ScholarityTextField(
                              label: "District",
                              controller: districtController)),
                      SizedBox(
                          width: 300,
                          child: ScholarityTextField(
                              label: "Province",
                              controller: provinceController)),
                      const ScholarityTextP(
                          "Note: Please enter GPS as decimals. (e.g. 20.250000,99.850000)"),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          ScholarityButton(
                            padding: false,
                            text: "Add",
                            invertedColor: true,
                            onPressed: () async {
                              try {
                                List<String> gpsCoords =
                                    gpsController.text.split(",");
                                double lat = double.parse(gpsCoords[0]);
                                double lon = double.parse(gpsCoords[1]);
                                await networking_api_service
                                    .createFleetLocation(
                                        locationName:
                                            locationNameController.text,
                                        locationAddress: "{}",
                                        latitude: lat,
                                        longitude: lon,
                                        subdistrict: subdistrictController.text,
                                        district: subdistrictController.text,
                                        province: provinceController.text,
                                        organizationId: widget.organizationId);
                              } catch (e) {
                                setState(() {
                                  gpsController.text = "error!";
                                });
                                return;
                              }
                              setState(() {});
                              Navigator.pop(context);
                            },
                          ),
                          const SizedBox(width: 10),
                          ScholarityButton(
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
    setState(() {});
  }

  Future<dynamic> _removeLocation(int fleetLocationId) async {
    Map<String, dynamic> response = await networking_api_service
        .removeFleetLocation(fleetLocationId: fleetLocationId);
    setState(() {});
    return response["data"];
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    error_service.checkAlerts(context);
    return FutureBuilder(
        future: _load(),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return const ScholarityPageLoading();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Container()),
                ScholarityButton(
                    text: "New",
                    invertedColor: true,
                    onPressed: () async {
                      await _createLocation();
                    }),
                ScholarityButton(
                    text: "Upload Station View",
                    icon: Icons.upload_rounded,
                    onPressed: () async {
                      setState(() {
                        showDialog<String>(
                            context: context,
                            builder: (BuildContext context) =>
                                _UploadStationViewPopup(
                                    organizationId: widget.organizationId));
                      });
                    })
              ]),
              const SizedBox(height: 8),
              ScholarityTable(
                  advancedHeaders: [
                    ScholarityTableHeader(
                        key: "locationName", label: "Location name"),
                    ScholarityTableHeader(
                        key: "subdistrict", label: "Subdistrict"),
                    ScholarityTableHeader(key: "district", label: "District"),
                    ScholarityTableHeader(key: "province", label: "Province"),
                    ScholarityTableHeader(key: "longitude", label: "Longitude"),
                    ScholarityTableHeader(key: "latitude", label: "Latitude"),
                  ],
                  onDelete: (var pk, dynamic data, int i) {
                    _removeLocation(pk);
                  },
                  data: snapshot.data!)
            ],
          );
        });
  }
}

class _UploadStationViewPopup extends StatefulWidget {
  final int organizationId;
  const _UploadStationViewPopup({Key? key, required this.organizationId})
      : super(key: key);

  @override
  _UploadStationViewPopupState createState() => _UploadStationViewPopupState();
}

// myPage state
class _UploadStationViewPopupState extends State<_UploadStationViewPopup> {
  bool _isOnVerifyPage = true;
  bool _isOnFailedPage = false;
  bool _isOnSuccessPage = false;
  double _progress = 0;
  String _progressString = "loading";
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<dynamic> _uploadSingleStation(String locationValue, String gpsValue,
      String subdistrict, String district, String province) async {
    print("$locationValue -> $gpsValue");
    try {
      List<String> gpsCoords = gpsValue.split(",");
      double lat = double.parse(gpsCoords[0]);
      double lon = double.parse(gpsCoords[1]);
      await networking_api_service.createFleetLocation(
          locationName: locationValue,
          locationAddress: "{}",
          latitude: lat,
          longitude: lon,
          subdistrict: subdistrict,
          district: district,
          province: province,
          organizationId: widget.organizationId);
    } catch (e) {
      print("error: $locationValue -> $gpsValue");
      return;
    }
  }

  void _uploadStationView() async {
    FilePickerResult? pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );
    setState(() {
      _isOnVerifyPage = false;
      _progress = 0.05;
      _progressString = "uploading...";
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (pickedFile == null) {
      Navigator.pop(context);
      return;
    }
    var bytes = pickedFile.files.single.bytes;
    setState(() {
      _progress = 0.3;
      _progressString = "decoding (takes 1-2 minutes)...";
    });
    await Future.delayed(const Duration(milliseconds: 500));
    var excel = Excel.decodeBytes(bytes!);
    setState(() {
      _progress = 0.5;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    bool foundStationPage = false;
    var table = excel.tables.keys.first;
    // this is the first time loading this, so remove all locations
    if (!foundStationPage) {
      await networking_api_service.removeAllFleetLocation(
          organizationId: widget.organizationId);
    }
    foundStationPage = true;

    final int maxRows = excel.tables[table]!.maxRows;
    // start at row 4
    for (int i = 3; i < maxRows; i++) {
      var row = excel.tables[table]!.rows[i];
      //String? locationValue, gpsValue, subdistrict, district, province;

      // extract location data from column locationNameColumn
      String? location = row[0]?.value.toString();
      String? subdistrict = row[1]?.value.toString();
      String? district = row[2]?.value.toString();
      String? province = row[3]?.value.toString();
      String? gps = row[4]?.value.toString();
      if (location == "null" && gps == "null") {
        break; // done
      }
      if (location != null &&
          gps != null &&
          subdistrict != null &&
          district != null &&
          province != null) {
        await _uploadSingleStation(
            location, gps, subdistrict, district, province);
        setState(() {
          _progressString =
              "Uploading $i/$maxRows (${(_progress * 1000).round() / 10}%)...";
          _progress = (i.toDouble() / maxRows.toDouble());
        });
      }
    }
    setState(() {
      _isOnSuccessPage = true;
    });
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return ScholarityAlertDialogWrapper(
        child: ScholarityAlertDialog(
      content: SingleChildScrollView(
        child: SizedBox(
          width: 300,
          child: Builder(builder: (context) {
            if (_isOnVerifyPage) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const ScholarityTextH2B("Dangerous Operation"),
                  const SizedBox(height: 20),
                  const ScholarityTextP(
                      "This action will overwrite all existing pumps, are you sure you want to do this?"),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ScholarityButton(
                        padding: false,
                        text: "Clear & upload new",
                        onPressed: () {
                          _uploadStationView();
                        },
                      ),
                      const SizedBox(width: 10),
                      ScholarityButton(
                          padding: false,
                          invertedColor: true,
                          text: "Cancel",
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ],
                  )
                ],
              );
            }
            if (_isOnFailedPage) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const ScholarityTextH2B("Operation Failed."),
                  const SizedBox(height: 20),
                  const ScholarityTextP(
                      "Invalid format, please contact support."),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ScholarityButton(
                          padding: false,
                          invertedColor: true,
                          text: "Cancel",
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ],
                  )
                ],
              );
            }
            if (_isOnSuccessPage) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const ScholarityTextH2B("Operation Succeeded."),
                  const SizedBox(height: 20),
                  const ScholarityTextP("Please reload the page."),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ScholarityButton(
                          padding: false,
                          invertedColor: true,
                          text: "Dismiss",
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    ],
                  )
                ],
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScholarityTextH2B(
                    "Please wait, it could take a while..."),
                const SizedBox(height: 20),
                const ScholarityTextP("DO NOT CLOSE THE PAGE."),
                const SizedBox(height: 20),
                ScholarityTextP(_progressString),
                const SizedBox(height: 10),
                ScholarityProgressIndicator(
                  progress: _progress,
                ),
              ],
            );
          }),
        ),
      ),
    ));
  }
}

// myPage class which creates a state on call
class _OrganizationFleetDriversHistoryPage extends StatefulWidget {
  final _OrganizationFleetDriversController controller;
  final void Function() onUpdate;
  const _OrganizationFleetDriversHistoryPage(
      {Key? key, required this.controller, required this.onUpdate})
      : super(key: key);

  @override
  _OrganizationFleetDriversHistoryPageState createState() =>
      _OrganizationFleetDriversHistoryPageState();
}

// myPage state
class _OrganizationFleetDriversHistoryPageState
    extends State<_OrganizationFleetDriversHistoryPage> {
  String _name = "";
  Future<dynamic> _load() async {
    Map<String, dynamic> response =
        await networking_api_service.getFleetFlightplanFromUser(
            userId: widget.controller.driverUserId!, timezone: "Asia/Jakarta");
    Map<String, dynamic> responseUser = await networking_api_service.getUser(
        userId: widget.controller.driverUserId!);
    _name =
        "${responseUser["data"]["firstName"]} ${responseUser["data"]["lastName"]}";
    return response["data"];
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
    // ignore: unused_local_variable
    return Column(children: [
      const SizedBox(height: 50),
      FutureBuilder(
          future: _load(),
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScholarityTextH2(Uri.decodeComponent(_name)),
                  const SizedBox(height: 25),
                  ScholarityTable(
                    useAltStyle: true,
                    advancedHeaders: [
                      ScholarityTableHeader(
                        key: "date",
                        label: "Date filed",
                        type: ScholarityTableHeaderType.datetime,
                      ),
                      ScholarityTableHeader(
                        key: "dayMode",
                        label: "Activity",
                      ),
                      ScholarityTableHeader(
                        key: "licensePlate",
                        label: "Vehicle",
                      ),
                      ScholarityTableHeader(
                        key: "locationNames",
                        label: "Locations",
                      ),
                      ScholarityTableHeader(
                        key: "remark",
                        label: "Remarks",
                      ),
                    ],
                    data: snapshot.data,
                  ),
                ],
              );
            } else {
              return const ScholarityPageLoading();
            }
          })
    ]);
  }
}

// myPage class which creates a state on call
class _OrganizationFleetDataPage extends StatefulWidget {
  final int organizationId;
  const _OrganizationFleetDataPage({
    Key? key,
    required this.organizationId,
  }) : super(key: key);

  @override
  _OrganizationFleetDataPageState createState() =>
      _OrganizationFleetDataPageState();
}

// myPage state
class _OrganizationFleetDataPageState
    extends State<_OrganizationFleetDataPage> {
  late DateTime _searchDateBegin;
  late DateTime _searchDateEnd;
  @override
  void initState() {
    super.initState();
    _searchDateBegin = DateTime.now();
    _searchDateEnd = DateTime.now();
    _searchDateBegin = _searchDateBegin.subtract(const Duration(days: 365));
    _searchDateEnd = _searchDateEnd.add(const Duration(days: 1));
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<dynamic>> _load() async {
    Map<String, dynamic> response =
        await networking_api_service.getAllWaypointsForOrganization(
      organizationId: widget.organizationId,
      searchDateBegin: _searchDateBegin,
      searchDateEnd: _searchDateEnd,
      timezone: "Asia/Jakarta",
    );
    return response["data"];
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          ScholarityDatePicker(
              label: "Start date",
              date: _searchDateBegin,
              onChanged: (DateTime newDate) {
                setState(() {
                  _searchDateBegin = newDate;
                });
              }),
          const SizedBox(width: 10),
          ScholarityDatePicker(
              label: "End date",
              date: _searchDateEnd,
              onChanged: (DateTime newDate) {
                setState(() {
                  _searchDateEnd = newDate;
                });
              })
        ]),
        const SizedBox(height: 10),
        FutureBuilder(
            future: _load(),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (!snapshot.hasData) {
                return const ScholarityPageLoading();
              }
              return ScholarityTable(advancedHeaders: [
                ScholarityTableHeader(
                    key: "date",
                    label: "Date",
                    type: ScholarityTableHeaderType.datetime),
                ScholarityTableHeader(width: 300, key: "name", label: "Name"),
                ScholarityTableHeader(key: "licensePlate", label: "Vehicle"),
                ScholarityTableHeader(key: "locationName", label: "Location"),
              ], data: snapshot.data!);
            }),
      ],
    );
  }
}

class _OrganizationFleetTodayController {
  int pageNumber = 0;
}

// myPage class which creates a state on call
class _OrganizationFleetTodayPage extends StatefulWidget {
  final int organizationId;
  const _OrganizationFleetTodayPage({
    Key? key,
    required this.organizationId,
  }) : super(key: key);

  @override
  _OrganizationFleetTodayPageState createState() =>
      _OrganizationFleetTodayPageState();
}

// myPage state
class _OrganizationFleetTodayPageState
    extends State<_OrganizationFleetTodayPage> {
  final _OrganizationFleetTodayController controller =
      _OrganizationFleetTodayController();
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
    return Column(
      children: [
        const SizedBox(height: 10),
        const ProductFleetWidget(),
        Row(children: [
          ScholarityButton(
            invertedColor: controller.pageNumber == 0,
            text: "Drivers",
            onPressed: () {
              setState(() {
                controller.pageNumber = 0;
              });
            },
          ),
          ScholarityButton(
            invertedColor: controller.pageNumber == 1,
            text: "Vehicles",
            onPressed: () {
              setState(() {
                controller.pageNumber = 1;
              });
            },
          ),
        ]),
        const SizedBox(height: 10),
        Builder(builder: (BuildContext context) {
          switch (controller.pageNumber) {
            case 0:
              return _OrganizationFleetTodayDriverWidget(
                  organizationId: widget.organizationId);
            case 1:
            default:
              return _OrganizationFleetTodayVehicleWidget(
                  organizationId: widget.organizationId);
          }
        }),
      ],
    );
  }
}

class _OrganizationFleetTodayDriverWidget extends StatelessWidget {
  // members of MyWidget
  final int organizationId;
  final List<ScholarityTableHeader> _headers = [];

  // constructor
  _OrganizationFleetTodayDriverWidget({Key? key, required this.organizationId})
      : super(key: key);

  Future<List<dynamic>> _load() async {
    Map<String, dynamic> response =
        await networking_api_service.getTodayDrivers(
      organizationId: organizationId,
      timezone: "Asia/Jakarta",
    );

    _headers.clear();
    _headers.add(ScholarityTableHeader(key: "name", label: "Name", width: 300));
    int maxItineraryLength = response["data"]["maxItineraryLength"];
    for (int i = 0; i < maxItineraryLength; i++) {
      _headers.add(ScholarityTableHeader(
          key: i.toString(), label: "location #$i", width: 200));
    }
    return response["data"]["data"];
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _load(),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return const ScholarityPageLoading();
          }
          return ScholarityTable(
              useAltStyle: true,
              advancedHeaders: _headers,
              data: snapshot.data!);
        });
  }
}

class _OrganizationFleetTodayVehicleWidget extends StatelessWidget {
  // members of MyWidget
  final int organizationId;
  final List<ScholarityTableHeader> _headers = [];

  // constructor
  _OrganizationFleetTodayVehicleWidget({Key? key, required this.organizationId})
      : super(key: key);

  Future<List<dynamic>> _load() async {
    Map<String, dynamic> response = await networking_api_service.getTodayCars(
      organizationId: organizationId,
      timezone: "Asia/Jakarta",
    );

    _headers.clear();
    _headers.add(ScholarityTableHeader(
        key: "licensePlate", label: "Vehicle", width: 300));
    int maxItineraryLength = response["data"]["maxItineraryLength"];
    for (int i = 0; i < maxItineraryLength; i++) {
      _headers.add(ScholarityTableHeader(
          key: i.toString(), label: "location #$i", width: 200));
    }
    return response["data"]["data"];
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _load(),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return const ScholarityPageLoading();
          }
          return ScholarityTable(
              useAltStyle: true,
              advancedHeaders: _headers,
              data: snapshot.data!);
        });
  }
}
