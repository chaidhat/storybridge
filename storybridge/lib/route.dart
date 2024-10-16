import 'package:flutter/material.dart';
import 'package:mooc/storybridge.dart'; // Storybridge

import 'package:flutter/scheduler.dart';
import 'package:mooc/pages/admin_page.dart';
import 'package:mooc/pages/audit_page.dart';
import 'package:mooc/pages/loading_page.dart';
import 'package:mooc/pages/payment_page.dart';
import 'package:mooc/pages/pt_page.dart';
import 'package:mooc/pages/user/user_page.dart';
import 'package:mooc/wrapper.dart';
import 'package:mooc/pages/auth_page.dart';
import 'package:mooc/pages/course/course_page.dart';
import 'package:mooc/pages/organization/organization_page.dart';
import 'package:mooc/pages/organization_register_page.dart';

import 'package:mooc/services/auth_service.dart' as auth_service;
import 'package:mooc/services/error_service.dart' as error_service;
import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/video_player_service.dart'
    as video_player_service;
import 'package:mooc/style/storybridge_colors.dart' as storybridge_color;

Uri? previousUri;

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    editorWidgetForceHideOverlay(); // hide overlay, just to be safe.
    Uri uri = Uri.parse(settings.name!);
    print("loading ${uri.toString()}");
    video_player_service.onNavigationChange();

    if (settings.name == "/reload") {
      return MaterialPageRoute(
          settings: settings,
          builder: (context) => _ReloadPage(previousUri: previousUri!));
    } else if (uri.queryParameters["redirect"] == "true") {
      // do not save previous url if you need to jump
    } else {
      previousUri = uri;
    }

    // Handle '/'
    if (settings.name == '/') {
      return MaterialPageRoute(
          settings: settings,
          builder: (context) => const Wrapper(
                HomePage(),
                needsAuthentication: false,
              ));
    }

    if (uri.pathSegments.first == 'login') {
      String? organizationIdStr = uri.queryParameters["id"];
      String? shouldRedirectStr = uri.queryParameters["redirect"];
      int? organizationId;
      bool shouldRedirect = false;

      if (shouldRedirectStr == "true") {
        shouldRedirect = true;
      }

      bool isQueryProvided = organizationIdStr != null;
      if (isQueryProvided) {
        organizationId = int.parse(organizationIdStr);
      }

      return MaterialPageRoute(
          settings: settings,
          builder: (context) => Wrapper(AuthLoginPage(
                organizationId: organizationId,
                redirectToUrl: shouldRedirect ? previousUri.toString() : null,
              )));
    }

    if (uri.pathSegments.first == 'register') {
      String? organizationIdStr = uri.queryParameters["id"];
      String? shouldRedirectStr = uri.queryParameters["redirect"];
      int? organizationId;
      bool shouldRedirect = false;

      if (shouldRedirectStr == "true") {
        shouldRedirect = true;
      }

      bool isQueryProvided = organizationIdStr != null;
      if (isQueryProvided) {
        organizationId = int.parse(organizationIdStr);
      }

      return MaterialPageRoute(
          settings: settings,
          builder: (context) => Wrapper(AuthRegisterPage(
                organizationId: organizationId,
                redirectToUrl: shouldRedirect ? previousUri.toString() : null,
              )));
    }

    if (uri.pathSegments.first == 'organization') {
      // TODO: needs wrapper to confirm user is authenticated
      String? organizationIdStr = uri.queryParameters["id"];
      int organizationId;

      try {
        organizationId = int.parse(organizationIdStr!);
      } catch (_) {
        return MaterialPageRoute(
            settings: settings,
            builder: (context) => ErrorPage(
                error: error_service.StorybridgeException("invalid URL",
                    description: "a query was expected but not provided")));
      }

      int startingTab = 0;
      if (uri.pathSegments.length >= 2) {
        switch (uri.pathSegments[1]) {
          case "courses":
            startingTab = 0;
            break;
          case "audits":
            startingTab = 1;
            break;
          case "fleet":
            startingTab = 2;
            break;
          case "people":
            startingTab = 3;
            break;
          case "sales":
            startingTab = 4;
            break;
          case "settings":
            startingTab = 5;
            break;
        }
      }

      return MaterialPageRoute(
          settings: settings,
          builder: (context) => Wrapper(
                OrganizationPage(
                  organizationId: organizationId,
                  startingTab: startingTab,
                ),
              ));
    }

    if (uri.pathSegments.first == 'user') {
      // TODO: needs wrapper to confirm user is authenticated
      String? userIdStr = uri.queryParameters["id"];
      int userId;
      String? isAdminModeStr = uri.queryParameters["admin"];
      bool isAdminMode = isAdminModeStr != null;

      int startingTab = 0;
      if (uri.pathSegments.length >= 2) {
        switch (uri.pathSegments[1]) {
          case "profile":
            startingTab = 0;
            break;
          case "flightplan":
            startingTab = 1;
            break;
          case "my-courses":
            startingTab = 2;
            break;
          case "my-audits":
            startingTab = 3;
            break;
          case "my-files":
            startingTab = 4;
            break;
          case "help-center":
            startingTab = 5;
            break;
        }
      }

      try {
        userId = int.parse(userIdStr!);
      } catch (_) {
        return MaterialPageRoute(
            settings: settings,
            builder: (context) => ErrorPage(
                error: error_service.StorybridgeException("invalid URL",
                    description: "a query was expected but not provided")));
      }

      return MaterialPageRoute(
          settings: settings,
          builder: (context) => Wrapper(
                UserPage(
                  startingTab: startingTab,
                  userId: userId,
                  isForceAdmin: isAdminMode,
                ),
              ));
    }

/*
    if (uri.pathSegments.first == 'organization-register') {
      return MaterialPageRoute(
          settings: settings,
          builder: (context) => const Wrapper(
                OrganizationRegisterPage(),
                needsAuthentication: true,
              ));
    }
    */

    if (uri.pathSegments.first == 'course') {
      String? courseIdStr = uri.queryParameters["id"];
      String? isAdminModeStr = uri.queryParameters["admin"];
      int courseId;
      bool isAdminMode = isAdminModeStr != null;

      try {
        courseId = int.parse(courseIdStr!);
      } catch (_) {
        return MaterialPageRoute(
            settings: settings,
            builder: (context) => ErrorPage(
                error: error_service.StorybridgeException("invalid URL",
                    description: "a query was expected but not provided")));
      }

      return MaterialPageRoute(
          settings: settings,
          builder: (context) => FutureBuilder<int>(
              future: () async {
                // get organizationId from courseId
                Map<String, dynamic> course =
                    await networking_api_service.getCourse(courseId: courseId);
                int organizationId = course["data"]["organizationId"];
                return organizationId;
              }.call(),
              builder: (context, AsyncSnapshot<int> snapshot) {
                if (snapshot.hasData) {
                  int organizationId = snapshot.data!;
                  return Wrapper(
                    CoursePage(
                      courseId: courseId,
                      organizationId: organizationId,
                      isAdminMode: isAdminMode,
                    ),
                    needsAuthentication: isAdminMode,
                    assertOrganizationId: organizationId,
                    goToStringIfNotAuthenticated: "/course?id=${courseIdStr}",
                  );
                } else {
                  return const LoadingPage();
                }
              }));
    }

    if (uri.pathSegments.first == 'checkout') {
      String? planStr = uri.queryParameters["plan"];
      int plan = 0;

      try {
        plan = int.parse(planStr!);
      } catch (_) {
        return MaterialPageRoute(
            settings: settings,
            builder: (context) => ErrorPage(
                error: error_service.StorybridgeException("invalid URL",
                    description: "a query was expected but not provided")));
      }

      return MaterialPageRoute(
          settings: settings,
          builder: (context) => Wrapper(
                PaymentCheckoutPage(
                  plan: plan,
                ),
                needsAuthentication: true,
              ));
    }

    if (uri.pathSegments.first == 'account-setup') {
      String? organizationIdStr = uri.queryParameters["id"];
      int organizationId;

      try {
        organizationId = int.parse(organizationIdStr!);
      } catch (_) {
        return MaterialPageRoute(
            settings: settings,
            builder: (context) => ErrorPage(
                error: error_service.StorybridgeException("invalid URL",
                    description: "a query was expected but not provided")));
      }
      return MaterialPageRoute(
          settings: settings,
          builder: (context) => Wrapper(OrganizationRegisterPage(
                organizationId: organizationId,
              )));
    }

    if (uri.pathSegments.first == 'portal') {
      String? token = uri.queryParameters["token"];

      if (token == null) {
        return MaterialPageRoute(
            settings: settings,
            builder: (context) => ErrorPage(
                error: error_service.StorybridgeException("invalid URL",
                    description: "a query was expected but not provided")));
      } else {
        return MaterialPageRoute(
            settings: settings,
            builder: (context) => FutureBuilder(
                future: _handlePortal(token),
                builder: (BuildContext context, AsyncSnapshot<int?> snapshot) {
                  if (snapshot.hasData) {
                    int? organizationId = snapshot.data;
                    if (organizationId == null) {
                      return ErrorPage(
                          error: error_service.StorybridgeException(
                              "User does not belong to any organization.",
                              description:
                                  "Please contact support at https://storybridge.io/contact"));
                    }
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context)
                          .pushNamed("/organization?id=$organizationId");
                    });
                  }
                  return const Align(
                      alignment: Alignment.topLeft,
                      child: StorybridgeTextP("Logging you in"));
                }));
      }
    }

    if (uri.pathSegments.first == 'admin-auth') {
      return MaterialPageRoute(
          settings: settings, builder: (context) => Wrapper(AdminAuthPage()));
    }
    if (uri.pathSegments.first == 'admin') {
      return MaterialPageRoute(
          settings: settings, builder: (context) => Wrapper(AdminPage()));
    }
    if (uri.pathSegments.first == 'fleet') {
      return MaterialPageRoute(
          settings: settings, builder: (context) => Wrapper(PtPage()));
    }
    if (uri.pathSegments.first == 'auditing-template') {
      String? courseIdStr = uri.queryParameters["id"];
      int courseId;

      try {
        courseId = int.parse(courseIdStr!);
      } catch (_) {
        return MaterialPageRoute(
            settings: settings,
            builder: (context) => ErrorPage(
                error: error_service.StorybridgeException("invalid URL",
                    description: "a query was expected but not provided")));
      }

      int startingTab = 0;
      if (uri.pathSegments.length >= 2) {
        switch (uri.pathSegments[1]) {
          case "audit":
            startingTab = 0;
            break;
          case "workflow":
            startingTab = 1;
            break;
          case "settings":
            startingTab = 2;
            break;
        }
      }

      return MaterialPageRoute(
          settings: settings,
          builder: (context) => Wrapper(AuditPage(
                auditId: courseId,
                isAdminMode: true,
                startingTab: startingTab,
              )));
    }
    if (uri.pathSegments.first == 'audit') {
      String? courseIdStr = uri.queryParameters["id"];
      int courseId;

      try {
        courseId = int.parse(courseIdStr!);
      } catch (_) {
        return MaterialPageRoute(
            settings: settings,
            builder: (context) => ErrorPage(
                error: error_service.StorybridgeException("invalid URL",
                    description: "a query was expected but not provided")));
      }

      return MaterialPageRoute(
          settings: settings,
          builder: (context) => Wrapper(AuditPage(
                auditId: courseId,
                isAdminMode: false,
                startingTab: 0,
              )));
    }

    return MaterialPageRoute(
        settings: settings,
        builder: (context) => ErrorPage(
            error: error_service.StorybridgeException("404",
                description: "page not found.")));
  }
}

Future<int?> _handlePortal(String token) async {
  await auth_service.globalUser.portalLogin(token);
  // check if user is initially assigned to organization (has orgId already)
  bool isUserInitiallyAssignedToOrg = false;
  auth_service.AuthUserData? userData =
      auth_service.globalUser.getAuthUserData();
  if (userData != null) {
    isUserInitiallyAssignedToOrg = userData.organizationId != 0;
  }

  if (isUserInitiallyAssignedToOrg) {
    // if user is initally assigned, then go to that organization
    return userData!.organizationId;
  } else {
    // find first organizationId, if user has no organization, then go to register
    Map<String, dynamic> response =
        await networking_api_service.getOrganizations();
    // bring to create a new organization
    if (response["data"].length == 0) {
      // user does not have any organizations
      return null;
    } else {
      return response["data"][0]["organizationId"];
    }
  }
}

class ErrorPage extends StatelessWidget {
  // members of MyWidget
  final error_service.StorybridgeException error;

  // constructor
  const ErrorPage({Key? key, required this.error}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: storybridge_color.backgroundDim,
        child: Center(
          child: SizedBox(
            width: 500,
            child: StorybridgeTile(
              child: StorybridgePadding(
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.sentiment_dissatisfied_rounded,
                          size: 50),
                      const SizedBox(height: 20),
                      StorybridgeTextH2B("Error: ${error.message}"),
                      const SizedBox(height: 20),
                      StorybridgeTextP(error.description ?? ""),
                      const SizedBox(height: 30),
                      StorybridgeButton(
                        padding: false,
                        text: "go back to login",
                        onPressed: () {
                          Navigator.pushNamed(context, "/login");
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// myPage class which creates a state on call
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<HomePage> {
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
    //course_service.sendToOrgPage(context);
    return const AuthLoginPage();
  }
}

// myPage class which creates a state on call
class _ReloadPage extends StatefulWidget {
  final Uri previousUri;
  const _ReloadPage({Key? key, required this.previousUri}) : super(key: key);

  @override
  _ReloadPageState createState() => _ReloadPageState();
}

// myPage state
class _ReloadPageState extends State<_ReloadPage> {
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
    SchedulerBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushNamed(widget.previousUri.toString());
    });
    return Container();
  }
}
