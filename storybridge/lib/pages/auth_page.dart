import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/services/auth_service.dart' as auth_service;
import 'package:mooc/services/error_service.dart' as error_service;
import 'package:mooc/services/course_service.dart' as course_service;
import 'package:mooc/services/analytics_service.dart' as analytics_service;
import 'package:mooc/services/translation_service.dart' as translation_service;
import 'package:url_launcher/url_launcher.dart';

class AuthLoginPage extends StatelessWidget {
  final int?
      organizationId; // if not provided, this means that Scholarity is the organization (used for appbar)
  final String? redirectToUrl;

  const AuthLoginPage({Key? key, this.organizationId, this.redirectToUrl})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return AuthPageWrapper(
        child: AuthWidget(
      startWithLoginMode: true,
      organizationId: organizationId,
      isPopup: false,
      redirectToUrl: redirectToUrl,
    ));
  }
}

class AuthRegisterPage extends StatelessWidget {
  final int?
      organizationId; // if not provided, this means that Scholarity is the organization (used for appbar)
  final String? redirectToUrl;

  const AuthRegisterPage({Key? key, this.organizationId, this.redirectToUrl})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return AuthPageWrapper(
        child: AuthWidget(
      startWithLoginMode: false,
      organizationId: organizationId,
      isPopup: false,
      redirectToUrl: redirectToUrl,
    ));
  }
}

class AuthPageWrapper extends StatelessWidget {
  // members of MyWidget
  final Widget child;

  // constructor
  const AuthPageWrapper({Key? key, required this.child}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: const translation_service.LanguageFab(),
      body: Center(
        child: IntrinsicWidth(
          child: ScholarityTile(
            width: 470,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class AuthWidget extends StatefulWidget {
  // members of MyWidget
  final bool startWithLoginMode;
  final int?
      organizationId; // if not provided, this means that Scholarity is the organization (used for appbar)
  final bool isPopup;
  final String? redirectToUrl;

  // constructor
  const AuthWidget(
      {Key? key,
      this.organizationId,
      required this.startWithLoginMode,
      this.isPopup = true,
      this.redirectToUrl})
      : super(key: key);

  @override
  State<AuthWidget> createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  bool _loginMode = false;

  @override
  void initState() {
    _loginMode = widget.startWithLoginMode;
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
    return IntrinsicHeight(
      child: ScholarityPadding(
        thick: true,
        child: SizedBox(
          width: 370,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                widget.organizationId != null
                    ? CustomLoginHeader(organizationId: widget.organizationId!)
                    : const ScholarityLoginHeader(),
                const SizedBox(height: 50),
                _loginMode
                    ? _AuthLoginWidget(
                        organizationId: widget.organizationId,
                        changePage: swapPages,
                        isPopup: widget.isPopup,
                        redirectToUrl: widget.redirectToUrl,
                      )
                    : _AuthRegisterWidget(
                        organizationId: widget.organizationId,
                        changePage: swapPages,
                        isPopup: widget.isPopup,
                      )
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
  final int?
      organizationId; // if not provided, this means that Scholarity is the organization (used for appbar)
  final void Function() changePage;
  final bool isPopup;
  final String? redirectToUrl;
  const _AuthLoginWidget(
      {Key? key,
      this.organizationId,
      required this.changePage,
      this.isPopup = true,
      this.redirectToUrl})
      : super(key: key);

  @override
  _AuthLoginWidgetState createState() => _AuthLoginWidgetState();
}

// myPage state
class _AuthLoginWidgetState extends State<_AuthLoginWidget> {
  final _emailController = ScholarityTextFieldController();
  final _passwordController = ScholarityTextFieldController();
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<bool> login() async {
    String username = _emailController.text;
    String password = _passwordController.text;
    setState(() {
      _emailController.clearError();
      _passwordController.clearError();
    });
    try {
      await auth_service.globalUser.login(
        username: username,
        password: password,
        organizationId: widget.organizationId,
      );
      return true;
    } on error_service.ScholarityException catch (err) {
      switch (err.errorData?["authErrorType"]) {
        case "email":
        case "general":
          setState(() {
            _emailController.errorText = err.errorData?["message"];
          });
          break;
        case "password":
          setState(() {
            _passwordController.errorText = err.errorData?["message"];
          });
          break;
        default:
          setState(() {
            _emailController.errorText = "Something went wrong.";
          });
          break;
      }
      return false;
    }
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const ScholarityTextH3("Log into existing account"),
        const SizedBox(height: 5),
        ScholarityTextField(
          label: "Email",
          controller: _emailController,
          isPragmaticField: true,
        ),
        ScholarityTextField(
          label: "Password",
          controller: _passwordController,
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
                child: ScholarityButton(
                    text: "Login",
                    verticalOnlyPadding: true,
                    onPressed: () async {
                      try {
                        setState(() {
                          _isLoggingIn = true;
                        });
                        bool success = await login();
                        setState(() {
                          _isLoggingIn = false;
                        });
                        if (success) {
                          if (widget.redirectToUrl != null) {
                            Navigator.pushNamed(context, widget.redirectToUrl!);
                            return;
                          } else if (widget.isPopup) {
                            Navigator.pushNamed(context, '/reload');
                          } else {
                            if (widget.organizationId != null) {
                              // send to user page!
                              Navigator.pushNamed(context,
                                  "/user?id=${auth_service.globalUser.getAuthUserData()!.userId}");
                              return;
                            }
                            course_service.sendToOrgPage(context);
                          }
                        }
                      } on error_service.ScholarityException catch (error) {
                        setState(() {
                          _isLoggingIn = false;
                        });
                        error_service.reportError(error, context);
                      }
                    },
                    invertedColor: true,
                    loading: _isLoggingIn),
              ),
            ),
            IntrinsicWidth(
              child: ScholarityButton(
                verticalOnlyPadding: true,
                text: "Create a new account",
                onPressed: () {
                  if (widget.organizationId == null) {
                    launchUrl(Uri.parse("https://scholarity.io/pricing"));
                    return;
                  }
                  widget.changePage();
                  /*
                  Navigator.pushNamed(
                      context,
                      '/register' +
                          (widget.organizationId != null
                              ? "?id=${widget.organizationId}"
                              : ""));
                              */
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// myPage class which creates a state on call
class _AuthRegisterWidget extends StatefulWidget {
  final int?
      organizationId; // if not provided, this means that Scholarity is the organization (used for appbar)
  final void Function() changePage;
  final bool isPopup;
  const _AuthRegisterWidget({
    Key? key,
    this.organizationId,
    required this.changePage,
    this.isPopup = true,
  }) : super(key: key);

  @override
  _AuthRegisterWidgetState createState() => _AuthRegisterWidgetState();
}

// myPage state
class _AuthRegisterWidgetState extends State<_AuthRegisterWidget> {
  final ScholarityTextFieldController _emailController =
      ScholarityTextFieldController();
  final ScholarityTextFieldController _passwordController =
      ScholarityTextFieldController();
  final ScholarityTextFieldController _fullNameController =
      ScholarityTextFieldController();
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<bool> register() async {
    setState(() {
      _emailController.clearError();
      _passwordController.clearError();
      _fullNameController.clearError();
    });

    // parse the names
    List<String> names = _fullNameController.text.split(' ');
    String firstName = "", lastName = "";
    if (names.length > 1) {
      firstName = names[0];
      // last names are all the names after the first one.
      for (int i = 1; i < names.length; i++) {
        lastName += "${names[i]} ";
      }
      lastName = lastName.substring(0, lastName.length - 1);
    } else {
      firstName = _fullNameController.text;
    }

    try {
      await auth_service.globalUser.register(
        username: _emailController.text,
        password: _passwordController.text,
        email: _emailController.text,
        firstName: firstName,
        lastName: lastName,
        organizationId: widget.organizationId,
      );
      return true;
    } on error_service.ScholarityException catch (err) {
      switch (err.errorData?["authErrorType"]) {
        case "name":
        case "general":
          setState(() {
            _fullNameController.errorText = err.errorData?["message"];
          });
          break;
        case "email":
          setState(() {
            _emailController.errorText = err.errorData?["message"];
          });
          break;
        case "password":
          setState(() {
            _passwordController.errorText = err.errorData?["message"];
          });
          break;
        default:
          setState(() {
            _fullNameController.errorText = "Something went wrong.";
          });
          break;
      }
      return false;
    }
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    analytics_service.reportAnalyticsOnLoadRegisterPage();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ScholarityTextH3("Create a free account"),
        const SizedBox(height: 10),
        ScholarityTextField(
          label: "Full name",
          controller: _fullNameController,
          isPragmaticField: true,
        ),
        ScholarityTextField(
          label: "Email",
          controller: _emailController,
          isPragmaticField: true,
        ),
        ScholarityTextField(
          label: "Password",
          controller: _passwordController,
          isPragmaticField: true,
          isPasswordField: true,
        ),
        Wrap(
          children: [
            Padding(
                padding: const EdgeInsets.only(right: 20),
                child: IntrinsicWidth(
                  child: ScholarityButton(
                    text: "Register",
                    verticalOnlyPadding: true,
                    onPressed: () async {
                      try {
                        setState(() {
                          _isRegistering = true;
                        });
                        bool success = await register();
                        setState(() {
                          _isRegistering = false;
                        });
                        if (success) {
                          if (widget.isPopup) {
                            Navigator.pushNamed(context, '/reload');
                          } else {
                            if (widget.organizationId != null) {
                              // send to user page!
                              Navigator.pushNamed(context,
                                  "/user?id=${auth_service.globalUser.getAuthUserData()!.userId}");
                              return;
                            }
                            course_service.sendToOrgPage(context);
                          }
                        }
                      } on error_service.ScholarityException catch (error) {
                        error_service.reportError(error, context);
                      }
                    },
                    invertedColor: true,
                    loading: _isRegistering,
                  ),
                )),
            IntrinsicWidth(
              child: ScholarityButton(
                verticalOnlyPadding: true,
                text: "Log into existing account",
                onPressed: () async {
                  widget.changePage();
                  /*
                  Navigator.pushNamed(
                      context,
                      '/login' +
                          (widget.organizationId != null
                              ? "?id=${widget.organizationId}"
                              : ""));
                              */
                },
                loading: _isRegistering,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        InkWell(
          onTap: () {
            launchUrl(Uri.parse("https://scholarity.io/privacy"));
          },
          child: const ScholarityTextP(
            "I accept Scholarity's Terms of Use and Privacy Notice.\nBy creating an account, you agree to those terms.",
            isDim: true,
          ),
        ),
      ],
    );
  }
}
