import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/Storybridge.dart'; // Storybridge

import 'package:flutter/scheduler.dart';

import 'package:mooc/pages/auth_page.dart';
import 'package:mooc/services/auth_service.dart' as auth_service;

// myPage class which creates a state on call
class StorybridgeAccountIndicator extends StatefulWidget {
  final bool isAdminMode;
  final int?
      organizationId; // if not provided, this means that Storybridge is the organization (used for appbar)
  const StorybridgeAccountIndicator(
      {Key? key, this.isAdminMode = false, required this.organizationId})
      : super(key: key);

  @override
  _StorybridgeAccountIndicatorState createState() =>
      _StorybridgeAccountIndicatorState();
}

// myPage state
class _StorybridgeAccountIndicatorState
    extends State<StorybridgeAccountIndicator> {
  bool _isLoggedIn = false;
  String _name = "";
  int _userId = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> loadUser() async {
    auth_service.AuthUserData? userData =
        auth_service.globalUser.getAuthUserData();
    if (userData != null) {
      _isLoggedIn = true;
      _name = userData.firstName;
      _userId = userData.userId;
    } else {
      _isLoggedIn = false;
    }
    return true;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadUser(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          if (_isLoggedIn) {
            return _AuthenticatedIndicator(name: _name, userId: _userId);
          } else {
            return _UnauthenticatedIndicator(
              organizationId: widget.organizationId,
            );
          }
        });
  }
}

class _AuthenticatedIndicator extends StatelessWidget {
  // members of MyWidget
  final String name;
  final int userId;

  // constructor
  const _AuthenticatedIndicator(
      {Key? key, required this.name, required this.userId})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgeButton(
      lightenBackground: true,
      onPressed: () {},
      padding: false,
      child: Theme(
        data: Theme.of(context).copyWith(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent),
        child: PopupMenuButton(
            offset: const Offset(0, 40),
            child: Container(
              height: 45,
              padding: const EdgeInsets.all(1.0),
              child: Row(
                children: [
                  StorybridgeTextH5(name),
                  const SizedBox(width: 10),
                  ProfilePictureWidget(
                    isSquare: true,
                    userId: userId,
                  ),
                ],
              ),
            ),
            itemBuilder: (BuildContext context) {
              List<PopupMenuEntry> output = [
                PopupMenuItem(
                  onTap: () {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context)
                          .pushNamed("/user/profile?id=${userId}");
                    });
                  },
                  child: const StorybridgeTextBasic("Profile"),
                ),
                PopupMenuItem(
                  onTap: () {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context)
                          .pushNamed("/user/my-courses?id=${userId}");
                    });
                  },
                  child: const StorybridgeTextBasic("My Courses"),
                ),
                PopupMenuItem(
                  onTap: () {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context)
                          .pushNamed("/user/my-audits?id=${userId}");
                    });
                  },
                  child: const StorybridgeTextBasic("My Audits"),
                ),
                PopupMenuItem(
                  onTap: () {
                    auth_service.globalUser.logout();
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context).pushNamed("/reload");
                    });
                  },
                  child: const StorybridgeTextBasic("Logout"),
                ),
              ];
              return output;
            }),
      ),
    );
  }
}

class _UnauthenticatedIndicator extends StatefulWidget {
  final int?
      organizationId; // if not provided, this means that Storybridge is the organization (used for appbar)
  // constructor
  const _UnauthenticatedIndicator({Key? key, required this.organizationId})
      : super(key: key);

  @override
  State<_UnauthenticatedIndicator> createState() =>
      _UnauthenticatedIndicatorState();
}

class _UnauthenticatedIndicatorState extends State<_UnauthenticatedIndicator> {
  // main build function
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StorybridgeButton(
          onPressed: () {
            setState(() {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) =>
                    StorybridgeAlertDialogWrapper(
                  child: StorybridgeAlertDialog(
                    content: AuthWidget(
                      startWithLoginMode: false,
                      organizationId: widget.organizationId,
                    ),
                  ),
                ),
              );
            });
          },
          lightenBackground: true,
          padding: false,
          text: "Sign in",
        ),
      ],
    );
  }
}
