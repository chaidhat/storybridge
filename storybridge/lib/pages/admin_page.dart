import 'package:flutter/material.dart';
import 'package:mooc/storybridge.dart';

import 'package:mooc/pages/auth_page.dart';

import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/networking_service.dart' as networking_service;
import 'package:mooc/services/error_service.dart' as error_service;
import 'package:mooc/services/auth_service.dart' as auth_service;

// myPage class which creates a state on call
class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<AdminPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _checkIsLoggedIn() async {
    try {
      await networking_api_service.adminPing();
      return true;
    } on error_service.StorybridgeException catch (error) {
      if (error.message == "Invalid admin token.") {
        Navigator.pushNamed(context, '/admin-auth');
        return true;
      } else {
        return false;
      }
    }
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
              tabNames: [
                StorybridgeTabHeader(
                  tabName: "Server Status",
                  tabIcon: Icons.search,
                ),
                StorybridgeTabHeader(
                  tabName: "Server Post",
                  tabIcon: Icons.search,
                ),
                StorybridgeTabHeader(
                    tabName: "Db Query", tabIcon: Icons.search),
                StorybridgeTabHeader(tabName: "Db Get", tabIcon: Icons.search),
                StorybridgeTabHeader(
                    tabName: "Formulas", tabIcon: Icons.search),
                StorybridgeTabHeader(tabName: "Design", tabIcon: Icons.search),
              ],
              tabs: [
                _AdminStatusPage(),
                _AdminPostPage(),
                _AdminQueryPage(),
                _AdminLookupPage(),
                _AdminFormulasPage(),
                _AdminDesignPage(),
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

class _AdminStatusPage extends StatefulWidget {
  const _AdminStatusPage({
    Key? key,
  }) : super(key: key);

  @override
  _AdminStatusPageState createState() => _AdminStatusPageState();
}

// myPage state
class _AdminStatusPageState extends State<_AdminStatusPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  int? _ping;

  Future<bool> _pingServer() async {
    try {
      int start = DateTime.now().millisecondsSinceEpoch;
      await networking_api_service.adminPing();
      int end = DateTime.now().millisecondsSinceEpoch;
      _ping = end - start;
      return true;
    } on error_service.StorybridgeException catch (error) {
      if (error.message == "Invalid admin token.") {
        Navigator.pushNamed(context, '/admin-auth');
        return true;
      } else {
        return false;
      }
    }
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgeTabPage(body: [
      FutureBuilder(
          future: _pingServer(),
          builder: (context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: snapshot.data! ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  StorybridgeTextP(
                      "Server status: ${snapshot.data! ? "OK" : "NO CONNECTION"}\n"
                      "Server ping: ${_ping ?? "N/A"} [ms]\n"
                      "Timestamp: ${DateTime.now()}\n"),
                ],
              );
            } else {
              return const StorybridgePageLoading();
            }
          }),
    ]);
  }
}

class _AdminLookupPage extends StatefulWidget {
  const _AdminLookupPage({
    Key? key,
  }) : super(key: key);

  @override
  _AdminLookupPageState createState() => _AdminLookupPageState();
}

// myPage state
class _AdminLookupPageState extends State<_AdminLookupPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Widget> _getDb() async {
    try {
      Map<String, dynamic> response = await networking_api_service.adminGetDb();
      List<Widget> outputWidgets = [];
      response.forEach((key, value) {
        outputWidgets.add(_JsonDropdown(keyName: key, data: response[key]));
      });
      return Column(
        children: [
          const StorybridgeTextP(
              "IMPORTANT: if a new backend table is created, please declare its id name in admin.js in TABLE_ID_MAP."),
          Column(children: outputWidgets),
        ],
      );
    } catch (_) {}

    return Container();
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgeTabPage(body: [
      FutureBuilder(
          future: _getDb(),
          builder: (context, AsyncSnapshot<Widget> snapshot) {
            if (snapshot.hasData) {
              return snapshot.data!;
            } else {
              return const StorybridgePageLoading();
            }
          }),
    ]);
  }
}

class _JsonDropdown extends StatefulWidget {
  final String keyName;
  final data;

  const _JsonDropdown({
    Key? key,
    required this.keyName,
    required this.data,
  }) : super(key: key);

  @override
  State<_JsonDropdown> createState() => _JsonDropdownState();
}

class _JsonDropdownState extends State<_JsonDropdown> {
  bool _isDropped = false;
  // main build function
  @override
  Widget build(BuildContext context) {
    if (!_isDropped) {
      return InkWell(
          onTap: () {
            setState(() {
              //print(widget.data.toString());
              _isDropped = true;
            });
          },
          child: widget.data.runtimeType == Map
              ? StorybridgeTextP("${widget.keyName}: {...}")
              : StorybridgeTextP("${widget.keyName}: [...]"));
    } else {
      List<Widget> outputWidgets = [];
      // if its a map
      if (widget.data.runtimeType == Map) {
        widget.data.forEach((key, value) {
          outputWidgets.add(_JsonDropdown(keyName: key, data: value));
        });
      } else {
        for (int i = 0; i < widget.data.length; i++) {
          outputWidgets.add(StorybridgeTextP("{"));
          widget.data[i].forEach((key, value) {
            // it's a value
            if (value.runtimeType != Map && value.runtimeType != List) {
              outputWidgets.add(Padding(
                padding: const EdgeInsets.only(left: 32),
                child: StorybridgeTextP(
                    "${key}: ${Uri.decodeComponent(value.toString())}"),
              ));
            } else {
              outputWidgets.add(Padding(
                padding: const EdgeInsets.only(left: 32),
                child: _JsonDropdown(keyName: key, data: value),
              ));
            }
          });
          outputWidgets.add(StorybridgeTextP("}"));
        }
        // it's a list
      }

      return Container(
        color: Colors.black12,
        child: InkWell(
          onTap: () {
            setState(() {
              _isDropped = false;
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StorybridgeTextP("${widget.keyName}: ["),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: outputWidgets,
                ),
              ),
              const StorybridgeTextP("]"),
            ],
          ),
        ),
      );
    }
  }
}

class AdminAuthPage extends StatelessWidget {
  final int?
      organizationId; // if not provided, this means that Storybridge is the organization (used for appbar)
  final String? redirectToUrl;

  const AdminAuthPage({Key? key, this.organizationId, this.redirectToUrl})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return AuthPageWrapper(child: _AdminAuthWidget());
  }
}

class _AdminAuthWidget extends StatefulWidget {
  // constructor
  const _AdminAuthWidget({Key? key}) : super(key: key);

  @override
  State<_AdminAuthWidget> createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<_AdminAuthWidget> {
  bool _loginMode = false;

  @override
  void initState() {
    super.initState();
  }

  void swapPages() {
    setState(() {
      _loginMode = !_loginMode;
    });
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return const IntrinsicHeight(
      child: StorybridgePadding(
        thick: true,
        child: SizedBox(
          width: 370,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                StorybridgeLoginHeader(),
                SizedBox(height: 50),
                _AuthLoginWidget()
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// myPage class which creates a state on call
class _AuthLoginWidget extends StatefulWidget {
  const _AuthLoginWidget({
    Key? key,
  }) : super(key: key);

  @override
  _AuthLoginWidgetState createState() => _AuthLoginWidgetState();
}

// myPage state
class _AuthLoginWidgetState extends State<_AuthLoginWidget> {
  final _tokenController = StorybridgeTextFieldController();
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<bool> login() async {
    try {
      String adminToken = _tokenController.text;
      auth_service.loginAdmin(auth_service.Token(adminToken));
      await networking_api_service.adminPing();
      Navigator.pushNamed(context, '/admin');
    } on error_service.StorybridgeException catch (e) {
      setState(() {
        _tokenController.errorText = e.message;
      });
    }
    return false;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const StorybridgeTextH3("Admin Login"),
        const StorybridgeTextP(
            "This is for admin login only. Regular users please log in at https://storybridge.io/#/login."),
        const SizedBox(height: 10),
        StorybridgeTextField(
          label: "Token",
          controller: _tokenController,
          isPragmaticField: true,
          isPasswordField: true,
        ),
        const SizedBox(height: 5),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: IntrinsicWidth(
                child: StorybridgeButton(
                    text: "Login",
                    verticalOnlyPadding: true,
                    onPressed: () async {
                      setState(() {
                        _isLoggingIn = true;
                      });
                      await login();
                      setState(() {
                        _isLoggingIn = false;
                      });
                    },
                    invertedColor: true,
                    loading: _isLoggingIn),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AdminQueryPage extends StatefulWidget {
  const _AdminQueryPage({
    Key? key,
  }) : super(key: key);

  @override
  _AdminQueryPageState createState() => _AdminQueryPageState();
}

// myPage state
class _AdminQueryPageState extends State<_AdminQueryPage> {
  String _responseText = "";
  List<dynamic> _responseData = [];
  final _dbKeyController = StorybridgeTextFieldController();
  final _dbQueryController = StorybridgeTextFieldController();
  bool _isCalling = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _callDb() async {
    try {
      Map<String, dynamic> response = await networking_api_service.adminCallDb(
          query: _dbQueryController.text, dbKey: _dbKeyController.text);
      _responseText = response.toString();
      try {
        _responseData = response["data"];
        _responseText = "";
      } catch (e) {
        print(e);
      }
    } on error_service.StorybridgeException catch (e) {
      setState(() {
        _responseText = e.message.toString();
      });
    }
    return false;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgeTabPage(body: [
      const SizedBox(height: 30),
      StorybridgeTextField(
        label: "ADMIN_DB_KEY",
        controller: _dbKeyController,
        isPasswordField: true,
        isPragmaticField: true,
      ),
      StorybridgeTextField(
        label: "DB Query",
        controller: _dbQueryController,
        isPragmaticField: true,
      ),
      StorybridgeButton(
          text: "Call",
          verticalOnlyPadding: true,
          onPressed: () async {
            setState(() {
              _isCalling = true;
            });
            await _callDb();
            setState(() {
              _isCalling = false;
            });
          },
          invertedColor: true,
          loading: _isCalling),
      const StorybridgeBox(
        useAltStyle: true,
        child: SelectableText("Hints\n"
            "SELECT * FROM ___ LIMIT 3\n"
            "SELECT * FROM ___ ORDER BY ____ DESC LIMIT 3\n"
            "UPDATE ___ SET a = 3 WHERE b = 2\n"
            "ALTER TABLE ___ ADD column_name data_type\n"
            "ALTER TABLE ___ DROP COLUMN column_name\n"
            "ALTER TABLE ___ RENAME COLUMN old_name TO new_name\n"
            "ALTER TABLE ___ MODIFY column_name data_type\n"),
      ),
      const SizedBox(height: 20),
      (_responseText != "") ? StorybridgeTextP(_responseText) : Container(),
      (_responseData.length != 0)
          ? StorybridgeTable(data: _responseData)
          : Container(),
    ]);
  }
}

class _AdminPostPage extends StatefulWidget {
  const _AdminPostPage({
    Key? key,
  }) : super(key: key);

  @override
  _AdminPostPageState createState() => _AdminPostPageState();
}

// myPage state
class _AdminPostPageState extends State<_AdminPostPage> {
  String _responseText = "";
  List<dynamic> _responseData = [];
  final _actionController = StorybridgeTextFieldController();
  final List<_QueryData> _queryData = [_QueryData("", "")];
  bool _isCalling = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _post() async {
    try {
      String token = networking_api_service.getToken();
      Map<String, String> queries = {};
      queries["token"] = token;
      for (_QueryData qd in _queryData) {
        queries[qd.key.text] = qd.value.text;
      }
      Map<String, dynamic> response =
          await networking_service.serverGet(_actionController.text, queries);
      _responseData = response["data"];
    } on error_service.StorybridgeException catch (e) {
      setState(() {
        _responseText = e.message.toString();
      });
    }
    return false;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgeTabPage(body: [
      const SizedBox(height: 30),
      StorybridgeTextField(
        label: "Action",
        controller: _actionController,
        isPragmaticField: true,
      ),
      const StorybridgeTextH2B("Queries"),
      _QueryWidget(
        data: _queryData,
      ),
      const SizedBox(height: 30),
      StorybridgeButton(
          text: "Post",
          verticalOnlyPadding: true,
          onPressed: () async {
            setState(() {
              _isCalling = true;
            });
            await _post();
            setState(() {
              _isCalling = false;
            });
          },
          invertedColor: true,
          loading: _isCalling),
      const SizedBox(height: 20),
      (_responseText != "") ? StorybridgeTextP(_responseText) : Container(),
      (_responseData.length != 0)
          ? StorybridgeTable(data: _responseData)
          : Container(),
    ]);
  }
}

class _QueryData {
  StorybridgeTextFieldController key = StorybridgeTextFieldController();
  StorybridgeTextFieldController value = StorybridgeTextFieldController();
  _QueryData(String key, String value) {
    this.key.text = key;
    this.value.text = value;
  }
}

class _QueryWidget extends StatefulWidget {
  final StorybridgeTextFieldController date = StorybridgeTextFieldController();
  final List<_QueryData> data;

  // constructor
  _QueryWidget({Key? key, required this.data}) : super(key: key) {}

  @override
  State<_QueryWidget> createState() => _QueryWidgetState();
}

class _QueryWidgetState extends State<_QueryWidget> {
  Future<void> _addCheckinThing(int i) async {
    setState(() {
      widget.data.insert(i + 1, _QueryData("", ""));
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
      padding: const EdgeInsets.only(top: 18),
      child: Column(
          children: List.generate(widget.data.length, (int i) {
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 10),
              constraints: const BoxConstraints(maxWidth: 150),
              child: StorybridgeTextField(
                label: "key",
                controller: widget.data[i].key,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 10),
              constraints: const BoxConstraints(maxWidth: 250),
              child: StorybridgeTextField(
                label: "value",
                controller: widget.data[i].value,
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
    );
  }
}

class _AdminFormulasPage extends StatefulWidget {
  const _AdminFormulasPage({
    Key? key,
  }) : super(key: key);

  @override
  _AdminFormulasPageState createState() => _AdminFormulasPageState();
}

// myPage state
class _AdminFormulasPageState extends State<_AdminFormulasPage> {
  String _responseText = "";
  List<dynamic> _responseData = [];
  final _dbQueryController = StorybridgeTextFieldController();
  bool _isCalling = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _callDb() async {
    try {
      Map<String, dynamic> response = await networking_api_service
          .executeFormula(formula: _dbQueryController.text);
      _responseText = response.toString();
      try {
        _responseData = response["data"];
        _responseText = "";
      } catch (e) {
        print(e);
      }
    } on error_service.StorybridgeException catch (e) {
      setState(() {
        _responseText = e.message.toString();
      });
    }
    return false;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgeTabPage(body: [
      const SizedBox(height: 30),
      StorybridgeTextField(
        label: "Formula",
        controller: _dbQueryController,
        isPragmaticField: true,
      ),
      StorybridgeButton(
          text: "Execute",
          verticalOnlyPadding: true,
          onPressed: () async {
            setState(() {
              _isCalling = true;
            });
            await _callDb();
            setState(() {
              _isCalling = false;
            });
          },
          invertedColor: true,
          loading: _isCalling),
      const SizedBox(height: 20),
      (_responseText != "") ? StorybridgeTextP(_responseText) : Container(),
      (_responseData.length != 0)
          ? StorybridgeTable(data: _responseData)
          : Container(),
    ]);
  }
}

class _AdminDesignPage extends StatefulWidget {
  const _AdminDesignPage({
    Key? key,
  }) : super(key: key);

  @override
  _AdminDesignPageState createState() => _AdminDesignPageState();
}

// myPage state
class _AdminDesignPageState extends State<_AdminDesignPage> {
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
      const SizedBox(height: 30),
      const StorybridgeTextH2("StorybridgeTextH2 - Header 2"),
      const SizedBox(height: 30),
      const StorybridgeTextH2B("StorybridgeTextH2B - Header 2, small"),
      const SizedBox(height: 30),
      const StorybridgeTextH3("StorybridgeTextH3 - Header 3"),
      const SizedBox(height: 30),
      const StorybridgeTextH3(
        "StorybridgeTextH3 - Header 3",
        bracketText: "Bracket text",
      ),
      const SizedBox(height: 30),
      const StorybridgeTextH4("StorybridgeTextH4 - Header 4"),
      const SizedBox(height: 30),
      const StorybridgeTextH5("StorybridgeTextH5 - Header 5"),
      const SizedBox(height: 30),
      const StorybridgeTextH5("StorybridgeTextH5 - Header 5 Red", red: true),
      const SizedBox(height: 30),
      const StorybridgeTextH5("StorybridgeTextH5 - Header 5 Bold", bold: true),
      const SizedBox(height: 30),
      const StorybridgeTextH5("StorybridgeTextH5 - Header 5 Dim", dim: true),
      const SizedBox(height: 30),
      const StorybridgeTextP("StorybridgeTextP - Paragraph"),
      const SizedBox(height: 30),
      const StorybridgeTextP(
        "StorybridgeTextP - Paragraph dim",
        isDim: true,
      ),
      const SizedBox(height: 30),
      const StorybridgeDivider(),
      const SizedBox(height: 30),
      StorybridgeButton(
        text: "StorybridgeButton",
        onPressed: () {},
      ),
      const SizedBox(height: 30),
      StorybridgeButton(
        text: "StorybridgeButton, inverted color",
        invertedColor: true,
        onPressed: () {},
      ),
      const SizedBox(height: 30),
      StorybridgeButton(
        text: "StorybridgeButton, darkened background",
        darkenBackground: true,
        onPressed: () {},
      ),
      const SizedBox(height: 30),
      StorybridgeButton(
        text: "StorybridgeButton, lightened background",
        lightenBackground: true,
        onPressed: () {},
      ),
      const SizedBox(height: 30),
      StorybridgeButton(
        text: "StorybridgeButton, loading",
        loading: true,
        onPressed: () {},
      ),
      const SizedBox(height: 30),
      StorybridgeIconButton(
        icon: Icons.abc_rounded,
        onPressed: () {},
      ),
      const SizedBox(height: 30),
      StorybridgeIconButton(
        icon: Icons.abc_rounded,
        useAltStyle: true,
        onPressed: () {},
      ),
      const SizedBox(height: 30),
      StorybridgeIconButton(
        icon: Icons.abc_rounded,
      ),
      const SizedBox(height: 30),
      const StorybridgeTile(
        child: StorybridgeTextP("StorybridgeTile"),
      ),
      const SizedBox(height: 30),
      const StorybridgeTile(
        hasShadows: true,
        child: StorybridgeTextP("StorybridgeTile, with shadows"),
      ),
      const SizedBox(height: 30),
      const StorybridgeTile(
        useAltStyle: true,
        child: StorybridgeTextP("StorybridgeTile, alternative style"),
      ),
      const SizedBox(height: 30),
      const StorybridgeBox(
        child: StorybridgeTextP("StorybridgeBox"),
      ),
      const SizedBox(height: 30),
      const StorybridgeBox(
        useAltStyle: true,
        child: StorybridgeTextP("StorybridgeBox, alternative style"),
      ),
      const SizedBox(height: 30),
      Column(
        children: [
          Container(
            color: Colors.red,
            width: 100,
            height: 50,
            child: const StorybridgeTextP("Hello"),
          ),
          Container(
            color: Colors.red,
            width: 100,
            height: 50,
            child: const StorybridgeTextP("Hello"),
          ),
        ],
      )
    ]);
  }
}
