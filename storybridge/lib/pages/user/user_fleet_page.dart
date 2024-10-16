import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/style/scholarity_colors.dart'
    as scholarity_color; // Scholarity
import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/geo_service.dart' as geo_service;
import 'package:mooc/services/error_service.dart' as error_service;

// myPage class which creates a state on call
class UserFleetPage extends StatefulWidget {
  final int userId;
  final int organizationId;
  const UserFleetPage(
      {Key? key, required this.userId, required this.organizationId})
      : super(key: key);

  @override
  _UserFleetPageState createState() => _UserFleetPageState();
}

// myPage state
class _UserFleetPageState extends State<UserFleetPage> {
  List<dynamic> _carData = [];
  List<dynamic> _locationData = [];
  final _FleetFlightplanData _flightplanData = _FleetFlightplanData();
  bool _isLocked = false;
  bool _isLoaded = false;

  Future<dynamic> _load() async {
    geo_service.determinePosition();
    if (!_isLoaded) {
      _carData.clear();
      _locationData.clear();

      Map<String, dynamic> responseFlightplan =
          await networking_api_service.getFleetFlightplanFromUserToday(
              userId: widget.userId, timezone: "Asia/Jakarta");
      if (responseFlightplan["data"].length > 0) {
        _isLocked = true;
        _flightplanData.deserializeWaypointData(
            responseFlightplan["data"][0]["waypoints"]);
        //_flightplanData.dayMode.text = responseFlightplan["data"][0]["dayMode"];
        /*
        _flightplanData.selectedFleetCarId =
            responseFlightplan["data"][0]["fleetCarId"];
        _flightplanData.fleetCar.text =
            Uri.decodeComponent(responseFlightplan["data"][0]["licensePlate"]);
            */
      } else {
        _flightplanData.waypointData.add(_FleetWaypointData(
            location: "",
            car: "",
            remark: "",
            selectedFleetLocationId: null,
            selectedFleetCarId: null,
            waypointId: null));
      }
      Map<String, dynamic> responseCars = await networking_api_service
          .getFleetCars(organizationId: widget.organizationId);
      _carData = responseCars["data"];
      Map<String, dynamic> responseLocations = await networking_api_service
          .getFleetLocations(organizationId: widget.organizationId);
      _locationData = responseLocations["data"];
      _isLoaded = true;
    }
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

  Future<dynamic> _submitFlightplan() async {
    Map<String, dynamic> response =
        await networking_api_service.createFleetFlightplan(
      userId: widget.userId,
      organizationId: widget.organizationId,
    );
    int fleetFlightplanId = response["data"];
    _flightplanData.saveWaypointData(fleetFlightplanId);
    return true;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return ScholarityTabPage(body: [
      FutureBuilder(
          future: _load(),
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return Column(children: [
                _FleetFlightplanWidget(
                  carData: _carData,
                  locationData: _locationData,
                  isLocked: _isLocked,
                  flightplanData: _flightplanData,
                  onUpdate: () {
                    setState(() {});
                  },
                ),
                _isLocked
                    ? ScholarityButton(
                        text: "Edit",
                        invertedColor: true,
                        onPressed: () {
                          setState(() {
                            _isLocked = false;
                          });
                        },
                      )
                    : ScholarityButton(
                        text: "Submit",
                        invertedColor: true,
                        onPressed: () async {
                          await _submitFlightplan();
                          setState(() {
                            _isLocked = true;
                          });
                        },
                      )
              ]);
            } else {
              return const ScholarityPageLoading();
            }
          })
    ]);
  }
}

class _FleetFlightplanData {
  int selectedFleetCarId = 0;
  final List<_FleetWaypointData> waypointData = [];
  _FleetFlightplanData();

  Future<void> deserializeWaypointData(List<dynamic> data) async {
    try {
      if (data.isEmpty) {
        waypointData.add(_FleetWaypointData(
            location: "",
            car: "",
            remark: "",
            selectedFleetLocationId: null,
            selectedFleetCarId: null,
            waypointId: null));
      } else {
        for (int i = 0; i < data.length; i++) {
          var waypoint = data[i];
          waypointData.add(_FleetWaypointData(
            location: Uri.decodeComponent(waypoint["locationName"] ?? ""),
            car: Uri.decodeComponent(waypoint["licensePlate"] ?? ""),
            remark: waypoint["remark"],
            selectedFleetLocationId: waypoint["fleetLocationId"],
            selectedFleetCarId: waypoint["fleetCarId"],
            waypointId: waypoint["fleetWaypointId"],
          ));
        }
      }
    } catch (e) {
      waypointData.add(_FleetWaypointData(
          location: "",
          car: "",
          remark: "",
          selectedFleetLocationId: null,
          selectedFleetCarId: null,
          waypointId: null));
      throw Exception("fatal: bad waypointData for flight plan.");
    }
  }

  Future<void> saveWaypointData(int fleetFlightplanId) async {
    int i = 0;
    for (_FleetWaypointData fwd in waypointData) {
      if (fwd.selectedFleetLocationId == null ||
          fwd.selectedFleetLocationId == null) {
        continue; // skip non specified locations
      }
      await networking_api_service.createFleetWaypoint(
        fleetCarId: fwd.selectedFleetCarId!,
        fleetLocationId: fwd.selectedFleetLocationId!,
        fleetFlightplanId: fleetFlightplanId,
        remark: fwd.remark.text,
        waypointOrder: i++,
      );
    }
  }
}

class _FleetWaypointData {
  ScholarityTextFieldController location = ScholarityTextFieldController();
  ScholarityTextFieldController car = ScholarityTextFieldController();
  ScholarityTextFieldController remark = ScholarityTextFieldController();
  int? selectedFleetLocationId;
  int? selectedFleetCarId;
  int? waypointId;
  bool isCheckedIn = false, isCheckedOut = false;
  String? timeCheckIn, timeCheckOut;
  _FleetWaypointData(
      {required String location,
      required String car,
      required String remark,
      this.selectedFleetLocationId,
      this.selectedFleetCarId,
      this.waypointId}) {
    this.location.text = location;
    this.car.text = car;
    this.remark.text = remark;
  }
}

class _FleetFlightplanWidget extends StatefulWidget {
  final List<dynamic> carData;
  final List<dynamic> locationData;
  final _FleetFlightplanData flightplanData;
  final Function() onUpdate;
  final bool isLocked;

  // constructor
  _FleetFlightplanWidget({
    Key? key,
    required this.carData,
    required this.flightplanData,
    required this.locationData,
    required this.isLocked,
    required this.onUpdate,
  }) : super(key: key) {}

  @override
  State<_FleetFlightplanWidget> createState() => _FleetFlightplanWidgetState();
}

class _FleetFlightplanWidgetState extends State<_FleetFlightplanWidget> {
  Future<void> _insertWaypoint(int i) async {
    setState(() {
      widget.flightplanData.waypointData.insert(
          i + 1,
          _FleetWaypointData(
              location: "",
              car: "",
              remark: "",
              selectedFleetLocationId: null,
              selectedFleetCarId: null,
              waypointId: null));
    });
  }

  Future<void> _removeWaypoint(int i) async {
    setState(() {
      if (widget.flightplanData.waypointData.length > 1) {
        widget.flightplanData.waypointData.removeAt(i);
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
          const SizedBox(width: 500),
          const ScholarityTextH2B("Date"),
          ScholarityDatePicker(
            label: "",
            date: DateTime.now(),
            isEnabled: false,
          ),
          const SizedBox(height: 28),
          const ScholarityTextH2B("Itinerary"),
          const SizedBox(height: 10),
          Column(
              children: List.generate(widget.flightplanData.waypointData.length,
                  (int i) {
            if (widget.isLocked) {
              return _FleetWaypointWidgetUser(
                isSelected: false,
                waypointData: widget.flightplanData.waypointData[i],
                onUpdate: widget.onUpdate,
              );
            } else {
              return _FleetWaypointWidgetAdmin(
                removeWaypoint: () {
                  _removeWaypoint(i);
                },
                insertWaypoint: () {
                  _insertWaypoint(i);
                },
                waypointData: widget.flightplanData.waypointData[i],
                locationData: widget.locationData,
                carData: widget.carData,
              );
            }
          })),
        ],
      ),
    );
  }
}

class ScholarityWeatherWidget extends StatelessWidget {
  // members of MyWidget
  final double lat, lon;

  // constructor
  const ScholarityWeatherWidget(
      {Key? key, required this.lat, required this.lon})
      : super(key: key);

  Future<dynamic> _load() async {
    Map<String, dynamic> response =
        await networking_api_service.forecastWeather(lat: lat, lon: lon);
    return response["data"];
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _load(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (!snapshot.hasData) {
            return const ScholarityBoxLoading(width: 500, height: 100);
          }
          return ScholarityTile(
              useAltStyle: true,
              child: _ScholarityWeatherBodyWidget(weatherData: snapshot.data));
        });
  }
}

class FleetLocationWeatherWidget extends StatefulWidget {
  // members of MyWidget
  final int? fleetLocationId;

  // constructor
  const FleetLocationWeatherWidget({Key? key, required this.fleetLocationId})
      : super(key: key);

  @override
  State<FleetLocationWeatherWidget> createState() =>
      _FleetLocationWeatherWidgetState();
}

class _FleetLocationWeatherWidgetState
    extends State<FleetLocationWeatherWidget> {
  Future<dynamic> _load() async {
    if (widget.fleetLocationId != null) {
      Map<String, dynamic> response =
          await networking_api_service.forecastWeatherForFleetLocation(
              fleetLocationId: widget.fleetLocationId!);
      return response["data"];
    }
    return 0;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: SizedBox(
        height: 48,
        width: 90,
        child: FutureBuilder(
            future: _load(),
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              if (!snapshot.hasData) {
                return const ScholarityBoxLoading(width: 50, height: 50);
              }
              if (snapshot.data == 0) {
                return Container();
              }
              return InkWell(
                onTap: () {
                  setState(() {
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) =>
                            ScholarityAlertDialogWrapper(
                                child: ScholarityAlertDialog(
                                    content: IntrinsicHeight(
                              child: _ScholarityWeatherBodyWidget(
                                weatherData: snapshot.data,
                              ),
                            ))));
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: Image.asset(
                          "assets/images/weather/${snapshot.data["weatherCurrent"]["weather"]["icon"]["raw"]}.png"),
                    ),
                    const SizedBox(width: 5),
                    ScholarityTextP(
                        "${snapshot.data["weatherCurrent"]["weather"]["temp"]["cur"].round()}˚C")
                  ],
                ),
              );
            }),
      ),
    );
  }
}

class _ScholarityWeatherBodyWidget extends StatelessWidget {
  // members of MyWidget
  final dynamic weatherData;

  // constructor
  const _ScholarityWeatherBodyWidget({Key? key, required this.weatherData})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return ScholarityPadding(
        child: SizedBox(
      width: 800,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: Image.asset(
                          "assets/images/weather/${weatherData["weatherCurrent"]["weather"]["icon"]["raw"]}.png"),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScholarityTextH2B(
                            "${weatherData["weatherCurrent"]["weather"]["temp"]["cur"]}˚C"),
                        ScholarityTextP(weatherData["weatherCurrent"]["weather"]
                            ["description"]),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 100),
                Row(
                  children: List.generate(weatherData["weatherForecast"].length,
                      (int i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 50,
                            width: 50,
                            child: Image.asset(
                                "assets/images/weather/${weatherData["weatherForecast"][i]["weather"]["icon"]["raw"]}.png"),
                          ),
                          ScholarityTextH2B(
                              "${weatherData["weatherForecast"][i]["weather"]["temp"]["cur"].round()}˚C"),
                          ScholarityTextP(
                              "${(weatherData["weatherForecast"][i]["weather"]["pop"] * 100).round()}%"),
                          ScholarityTextP(
                              "${DateTime.parse(weatherData["weatherForecast"][i]["dt"]).toLocal().hour}:00"),
                        ],
                      ),
                    );
                  }),
                )
              ],
            ),
            const Align(
                alignment: Alignment.bottomLeft,
                child: ScholarityTextP("Data provided by OpenWeather.",
                    isDim: true))
          ],
        ),
      ),
    ));
  }
}

class _FleetWaypointWidgetUser extends StatefulWidget {
  // members of MyWidget
  final _FleetWaypointData waypointData;
  final Function onUpdate;
  final bool isSelected;

  // constructor
  const _FleetWaypointWidgetUser({
    Key? key,
    required this.waypointData,
    required this.isSelected,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<_FleetWaypointWidgetUser> createState() =>
      _FleetWaypointWidgetUserState();
}

class _FleetWaypointWidgetUserState extends State<_FleetWaypointWidgetUser> {
  bool _isLoadingCheckIn = false;
  void _checkIn() async {
    setState(() {
      _isLoadingCheckIn = true;
    });
    try {
      Position location = await geo_service.determinePosition();
      await networking_api_service.checkinAtLocation(
        fleetWaypointId: widget.waypointData.waypointId!,
        myLat: location.latitude,
        myLon: location.longitude,
      );
    } on error_service.ScholarityException catch (e) {
      setState(() {
        error_service.alert(error_service.Alert(
            title: "Location Error",
            description: e.message.toString(),
            buttonName: "OK",
            allowCancel: true,
            callback: (_) async {}));
      });
    }
    setState(() {
      _isLoadingCheckIn = false;
    });
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    error_service.checkAlerts(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: widget.isSelected
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: scholarity_color.scholarityAccent, width: 2))
            : null,
        child: ScholarityTile(
          useAltStyle: true,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ScholarityTextH2B("Location"),
                          const SizedBox(height: 10),
                          IntrinsicWidth(
                            child: Row(
                              children: [
                                ScholarityTextP(
                                    widget.waypointData.location.text),
                                FleetLocationWeatherWidget(
                                    fleetLocationId: widget
                                        .waypointData.selectedFleetLocationId),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ScholarityTextH2B("Vehicle"),
                        const SizedBox(height: 10),
                        SizedBox(
                            height: 48,
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: ScholarityTextP(
                                    widget.waypointData.car.text))),
                      ],
                    )),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ScholarityTextH2B("Comment"),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 48,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: ScholarityTextP(
                                  widget.waypointData.remark.text.isNotEmpty
                                      ? widget.waypointData.remark.text
                                      : "---"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    ScholarityButton(
                      padding: false,
                      invertedColor: true,
                      icon: Icons.track_changes_rounded,
                      text: "Check In",
                      loading: _isLoadingCheckIn,
                      onPressed: () {
                        _checkIn();
                      },
                    ),
                    const SizedBox(width: 20),
                    ScholarityTextP("Checked in as of")
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FleetWaypointWidgetAdmin extends StatefulWidget {
  // members of MyWidget
  final _FleetWaypointData waypointData;
  final dynamic locationData, carData;
  final Function() removeWaypoint, insertWaypoint;

  // constructor
  const _FleetWaypointWidgetAdmin({
    Key? key,
    required this.waypointData,
    required this.locationData,
    required this.removeWaypoint,
    required this.insertWaypoint,
    required this.carData,
  }) : super(key: key);

  @override
  State<_FleetWaypointWidgetAdmin> createState() =>
      _FleetWaypointWidgetAdminState();
}

class _FleetWaypointWidgetAdminState extends State<_FleetWaypointWidgetAdmin> {
  // main build function
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ScholarityTile(
        useAltStyle: true,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10, right: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ScholarityTextH2B("Location"),
                        const SizedBox(height: 10),
                        IntrinsicWidth(
                          child: Row(
                            children: [
                              ScholarityTableDropdown(
                                  width: 150,
                                  advancedHeaders: [
                                    ScholarityTableHeader(
                                        key: "locationName", label: "Location"),
                                    ScholarityTableHeader(
                                        key: "subdistrict",
                                        label: "Subdistrict"),
                                    ScholarityTableHeader(
                                        key: "district", label: "District"),
                                    ScholarityTableHeader(
                                        key: "province", label: "Province"),
                                  ],
                                  onSubmit: (dynamic pk) {
                                    setState(() {
                                      widget.waypointData
                                          .selectedFleetLocationId = pk;
                                    });
                                  },
                                  controller: widget.waypointData.location,
                                  data: widget.locationData),
                              FleetLocationWeatherWidget(
                                  fleetLocationId: widget
                                      .waypointData.selectedFleetLocationId),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 10, right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ScholarityTextH2B("Vehicle"),
                          const SizedBox(height: 10),
                          ScholarityTableDropdown(
                              width: 250,
                              advancedHeaders: [
                                ScholarityTableHeader(
                                    key: "licensePlate", label: "Location"),
                                ScholarityTableHeader(
                                    key: "model", label: "Model"),
                              ],
                              onSubmit: (dynamic pk) {
                                setState(() {
                                  widget.waypointData.selectedFleetCarId = pk;
                                });
                              },
                              controller: widget.waypointData.car,
                              data: widget.carData),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SizedBox(
                      width: 400,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ScholarityTextH2B("Comment"),
                          const SizedBox(height: 10),
                          ScholarityTextField(
                            label: "Comment",
                            controller: widget.waypointData.remark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  ScholarityIconButton(
                    useAltStyle: true,
                    icon: Icons.close,
                    onPressed: () {
                      widget.removeWaypoint();
                    },
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  ScholarityIconButton(
                    useAltStyle: true,
                    icon: Icons.add,
                    onPressed: () {
                      widget.insertWaypoint();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
