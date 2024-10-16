import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mooc/storybridge.dart'; // Storybridge

import 'package:mooc/style/storybridge_colors.dart' as storybridge_color;

import 'package:mooc/services/snackbar_service.dart' as snackbar_service;

// myPage class which creates a state on call
class CourseShareWidget extends StatefulWidget {
  final int courseId;
  const CourseShareWidget({Key? key, required this.courseId}) : super(key: key);

  @override
  _CourseShareWidgetState createState() => _CourseShareWidgetState();
}

// myPage state
class _CourseShareWidgetState extends State<CourseShareWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _goToCourse() {
    Navigator.pushNamed(context, "/course?id=${widget.courseId}");
    /*
    launchUrl(
        Uri.parse("https://storybridge.io/app/#/course?id=${widget.courseId}"));
    course_navigation_service.goToFrontPage();
        */
    /*
    course_service.sendToCoursePage(context,
        courseId: widget.courseId, isAdminMode: false);
        */
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgeButton(
      text: "Share",
      icon: Icons.rocket_launch_rounded,
      invertedColor: true,
      onPressed: () {
        setState(() {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => StorybridgeAlertDialogWrapper(
              child: StorybridgeAlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Icon(Icons.rocket_launch_rounded,
                        color: storybridge_color.darkGrey, size: 40),
                    const SizedBox(height: 20),
                    const StorybridgeTextH2B("Link to your story page"),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        StorybridgeButton(
                            padding: false,
                            onPressed: _goToCourse,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(children: [
                                StorybridgeTextBasic(
                                    "https://storybridge.lat/app/#/course?id=${widget.courseId}",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: storybridge_color
                                            .storybridgeAccent)),
                                const SizedBox(width: 30),
                                Icon(Icons.arrow_forward_rounded,
                                    color: storybridge_color.storybridgeAccent)
                              ]),
                            )),
                        const SizedBox(width: 20),
                        StorybridgeButton(
                            padding: false,
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(
                                  text:
                                      "https://storybridge.lat/app/#/course?id=${widget.courseId}"));

                              snackbar_service.showSnackbar(
                                  context, "Link copied to clipboard.");
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Icon(Icons.copy_rounded,
                                  color: storybridge_color.storybridgeAccent),
                            )),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const StorybridgeTextP(
                        "Congratulations!\nPlease click the link above to go to your story.\n\nYou can share this link with your reader for\nthem to view the reader."),
                    const SizedBox(height: 50),
                    Row(
                      children: [
                        StorybridgeButton(
                          padding: false,
                          text: "Go to your story!",
                          invertedColor: true,
                          onPressed: () {
                            _goToCourse();
                          },
                        ),
                        const SizedBox(width: 15),
                        StorybridgeButton(
                          padding: false,
                          text: "Dismiss",
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    /*
                    const StorybridgeTextH2B("Relevant settings:"),
                    const SizedBox(height: 10),
                    const StorybridgeTextH2B("Who can modify/teach course"),
                    const SizedBox(height: 10),
                    StorybridgeButton(
                      padding: false,
                      text: "Manage",
                      lightenBackground: true,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 20),
                    const StorybridgeTextH2B("Who can view your course"),
                    const SizedBox(height: 10),
                    StorybridgeButton(
                      padding: false,
                      text: "Manage",
                      lightenBackground: true,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 50),
                    StorybridgeButton(
                      padding: false,
                      text: "Change your domain",
                      lightenBackground: true,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 10),
                    StorybridgeButton(
                      padding: false,
                      text: "Dismiss",
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    */
                  ],
                ),
              ),
            ),
          );
        });
      },
      padding: false,
    );
  }
}

class OrganizationAuthShareWidget extends StatefulWidget {
  final int organizationId;
  const OrganizationAuthShareWidget({Key? key, required this.organizationId})
      : super(key: key);

  @override
  _OrganizationAuthShareWidgetState createState() =>
      _OrganizationAuthShareWidgetState();
}

// myPage state
class _OrganizationAuthShareWidgetState
    extends State<OrganizationAuthShareWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _goToCourse() {
    Navigator.pushNamed(context, "/login?id=${widget.organizationId}");
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgeButton(
      icon: Icons.link_rounded,
      text: "Get login/register link",
      invertedColor: true,
      onPressed: () {
        setState(() {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => StorybridgeAlertDialogWrapper(
              child: StorybridgeAlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Icon(Icons.rocket_launch_rounded,
                        color: storybridge_color.darkGrey, size: 40),
                    const SizedBox(height: 20),
                    const StorybridgeTextH2B(
                        "Link to your organization login page"),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        StorybridgeButton(
                            padding: false,
                            onPressed: _goToCourse,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(children: [
                                StorybridgeTextBasic(
                                    "https://storybridge.lat/app/#/login?id=${widget.organizationId}",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: storybridge_color
                                            .storybridgeAccent)),
                                const SizedBox(width: 30),
                                Icon(Icons.arrow_forward_rounded,
                                    color: storybridge_color.storybridgeAccent)
                              ]),
                            )),
                        const SizedBox(width: 20),
                        StorybridgeButton(
                            padding: false,
                            onPressed: () async {
                              await Clipboard.setData(ClipboardData(
                                  text:
                                      "https://storybridge.lat/app/#/login?id=${widget.organizationId}"));

                              snackbar_service.showSnackbar(
                                  context, "Link copied to clipboard.");
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Icon(Icons.copy_rounded,
                                  color: storybridge_color.storybridgeAccent),
                            )),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const StorybridgeTextP(
                        "Link for users to register or log into your organization."),
                    const SizedBox(height: 50),
                    Row(
                      children: [
                        StorybridgeButton(
                          padding: false,
                          text: "Copy link",
                          invertedColor: true,
                          onPressed: () {
                            _goToCourse();
                          },
                        ),
                        const SizedBox(width: 15),
                        StorybridgeButton(
                          padding: false,
                          text: "Dismiss",
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
      padding: false,
    );
  }
}
