import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:flutter/scheduler.dart';

import 'package:mooc/pages/auth_page.dart';
import 'package:mooc/services/auth_service.dart' as auth_service;

// myPage class which creates a state on call
class ScholarityAccountIndicator extends StatefulWidget {
  final bool isAdminMode;
  final int?
      organizationId; // if not provided, this means that Scholarity is the organization (used for appbar)
  const ScholarityAccountIndicator(
      {Key? key, this.isAdminMode = false, required this.organizationId})
      : super(key: key);

  @override
  _ScholarityAccountIndicatorState createState() =>
      _ScholarityAccountIndicatorState();
}

// myPage state
class _ScholarityAccountIndicatorState
    extends State<ScholarityAccountIndicator> {
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
    return ScholarityButton(
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
                  ScholarityTextH5(name),
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
                  child: const ScholarityTextBasic("Profile"),
                ),
                PopupMenuItem(
                  onTap: () {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context)
                          .pushNamed("/user/my-courses?id=${userId}");
                    });
                  },
                  child: const ScholarityTextBasic("My Courses"),
                ),
                PopupMenuItem(
                  onTap: () {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context)
                          .pushNamed("/user/my-audits?id=${userId}");
                    });
                  },
                  child: const ScholarityTextBasic("My Audits"),
                ),
                PopupMenuItem(
                  onTap: () {
                    auth_service.globalUser.logout();
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(context).pushNamed("/reload");
                    });
                  },
                  child: const ScholarityTextBasic("Logout"),
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
      organizationId; // if not provided, this means that Scholarity is the organization (used for appbar)
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
        ScholarityButton(
          onPressed: () {
            setState(() {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) => ScholarityAlertDialogWrapper(
                  child: ScholarityAlertDialog(
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
