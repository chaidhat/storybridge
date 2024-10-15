import 'package:mooc/services/networking_service.dart' as networking_service;
import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

final Storage _localStorage = window.localStorage;
final AuthUser globalUser = AuthUser();

Token? _adminToken;
Token? getAdminToken() {
  if (_adminToken == null) {
    // attempt to get admin token from local storage
    if (_localStorage['adminToken'] != null) {
      _adminToken = Token(_localStorage['adminToken']!);
    }
  }
  return _adminToken;
}

void loginAdmin(Token adminToken) {
  _adminToken = adminToken;
  _localStorage['adminToken'] = adminToken.token;
}

class Token {
  final String token;
  Token(this.token);
}

class AuthUserData {
  int userId;
  String username, email, firstName, lastName;
  int organizationId;
  List<dynamic> organizationPrivilegeData,
      coursePrivilegeData,
      courseSubscriptionData;
  AuthUserData({
    required this.userId,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.organizationId,
    required this.organizationPrivilegeData,
    required this.coursePrivilegeData,
    required this.courseSubscriptionData,
  });
}

class AuthUser {
  Token? token;
  AuthUser({this.token});
  AuthUserData? _authUserData;

  Future<void> tryLogin() async {
    // load the token and other data via local cookies.
    // if success

    // pull token from local
    String authTokenSaved = _localStorage['token'] ?? "";
    if (authTokenSaved != "") {
      token =
          Token(authTokenSaved); // recieve the token (user is now logged in)
      try {
        await _getUserFromToken(); // get auth user data info from token
      } catch (_) {
        // make sure that token has not changed
        if (token != Token(authTokenSaved)) {
          //token = null;
          // TODO: uncomment this.
        }
        //token = null; // reset the token, as it is invalid
        rethrow; // failed to get data
      }
    }
  }

  void _saveToLocal() {
    _localStorage['token'] = token?.token ?? "";
  }

  AuthUserData? getAuthUserData() {
    // processing code is redundant as the data is now always fetched in wrapper
    return _authUserData;
  }

  // TODO: void the token after login.
  Future<void> portalLogin(String newToken) async {
    token = Token(newToken);
    await _getUserFromToken();
  }

  Future<void> _getUserFromToken() async {
    try {
      Map<String, dynamic> response = await networking_service.serverGet(
          "getUserFromToken", {"token": token!.token},
          ignoreErrors: false);
      if (response != {}) {
        _authUserData = AuthUserData(
          userId: response["userId"],
          username: response["username"],
          email: response["email"],
          firstName: Uri.decodeComponent(response["firstName"]),
          lastName: Uri.decodeComponent(response["lastName"]),
          organizationId: response["organizationId"],
          organizationPrivilegeData: response["organizationPrivilegeData"],
          coursePrivilegeData: response["coursePrivilegeData"],
          courseSubscriptionData: response["courseSubscriptionData"],
        );
      }
    } catch (_) {
      rethrow;
    }
  }

  bool isLoggedIn() {
    return _authUserData != null;
  }

  Future<void> login(
      {required String username,
      required String password,
      int? organizationId}) async {
    try {
      // Await the http get response, then decode the json-formatted response.
      Map<String, dynamic> response = await networking_service.serverGet(
          "login",
          {
            "username": username,
            "password": password,
            "organizationId": organizationId?.toString() ?? "0"
          },
          ignoreErrors: false);
      token = Token(response["token"]);
      // email, firstName and lastName are included from the server on login
      await _getUserFromToken();
      _saveToLocal();
    } catch (_) {
      rethrow;
    }
  }

  void logout() {
    try {
      // Await the http get response, then decode the json-formatted response.
      networking_api_service.logoutUser();
      token = null;
      _authUserData = null;
      _saveToLocal();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> register(
      {required String username,
      required String password,
      required String email,
      required String firstName,
      required String lastName,
      int? organizationId}) async {
    try {
      // Await the http get response, then decode the json-formatted response.
      Map<String, dynamic> response = await networking_service.serverGet(
          "register",
          {
            "username": username,
            "password": password,
            "email": email,
            "firstName": firstName,
            "lastName": lastName,
            "organizationId": organizationId?.toString() ?? "0",
          },
          ignoreErrors: false);
      token = Token(response["token"]);

      await _getUserFromToken();
      _saveToLocal();
    } catch (_) {
      rethrow;
    }
  }
}
