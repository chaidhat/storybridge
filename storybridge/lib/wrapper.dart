import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mooc/pages/loading_page.dart';
import 'package:mooc/services/auth_service.dart' as auth_service;
import 'package:mooc/services/error_service.dart' as error_service;

// myPage class which creates a state on call
class Wrapper extends StatefulWidget {
  final Widget goToPage;
  final bool needsAuthentication;
  final int? assertOrganizationId;
  final String? goToStringIfNotAuthenticated;
  const Wrapper(
    this.goToPage, {
    Key? key,
    this.needsAuthentication = false,
    this.assertOrganizationId,
    this.goToStringIfNotAuthenticated,
  }) : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<Wrapper> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> fetch() async {
    if (!auth_service.globalUser.isLoggedIn()) {
      // try to log in based on token from localStorage
      try {
        await auth_service.globalUser.tryLogin();
      } on error_service.ScholarityException catch (error) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          error_service.reportError(error, context);
        });
      }
    }

    // perform further authentication checks (is user part of org, course, etc)
    auth_service.AuthUserData? userData =
        auth_service.globalUser.getAuthUserData();

    if (userData != null) {
      bool pass = true;

      // find if user has privilege for organizationId
      if (widget.assertOrganizationId != null) {
        bool doesUserHaveOrgPriv = false;
        List<dynamic> organizationPrivilegeData =
            userData.organizationPrivilegeData;
        for (int i = 0; i < organizationPrivilegeData.length; i++) {
          int organizationId = organizationPrivilegeData[i]["organizationId"];
          if (widget.assertOrganizationId == organizationId) {
            doesUserHaveOrgPriv = true;
            break;
          }
        }
        // if user isn't given an OrgPriv or initially assigned to organization
        bool isUserInitiallyAssignedToOrg =
            userData.organizationId == widget.assertOrganizationId;
        if (!doesUserHaveOrgPriv && !isUserInitiallyAssignedToOrg) {
          pass = false;
        }
      }

      if (!pass) {
        // log the user out as they are not supposed to be on that page
        auth_service.globalUser.logout();
        return false; // did not pass further authentication checks
      }
    }

    // return whether the token is valid or note
    return auth_service.globalUser.isLoggedIn();
  }

  Future<void> assertChecks() async {}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: fetch(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            bool isLoggedIn = snapshot.data!;
            if (isLoggedIn || !widget.needsAuthentication) {
              return widget.goToPage;
            } else {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushNamed(
                    widget.goToStringIfNotAuthenticated ??
                        "/login?redirect=true");
              });
              return const LoadingPage();
            }
          } else {
            return const LoadingPage();
          }
        });
  }
}
