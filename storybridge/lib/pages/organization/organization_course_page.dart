import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/payment_service.dart' as payment_service;
import 'package:mooc/services/course_service.dart' as course_service;

class OrganizationCoursesStudentPage extends StatefulWidget {
  final List<Map<String, dynamic>> courses;
  final int organizationId;
  const OrganizationCoursesStudentPage({
    Key? key,
    required this.courses,
    required this.organizationId,
  }) : super(key: key);

  @override
  _OrganizationCoursesStudentPageState createState() =>
      _OrganizationCoursesStudentPageState();
}

// myPage state
class _OrganizationCoursesStudentPageState
    extends State<OrganizationCoursesStudentPage> {
  @override
  void initState() {
    widget.courses.clear();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _loadCourses() async {
    await networking_api_service.getOrganization(
        organizationId: widget.organizationId);

    Map<String, dynamic> response2 = await networking_api_service.getCourses(
        organizationId: widget.organizationId);
    for (int i = 0; i < response2["data"].length; i++) {
      widget.courses.add(response2["data"][i]);
    }
    return true;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return ScholarityTabPage(body: [
      const SizedBox(height: 50),
      FutureBuilder(
          future: _loadCourses(),
          builder: (context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.courses.isEmpty
                      ? const _NewCoursePromptWidget()
                      : Container(),
                  Column(
                      children: List.generate(widget.courses.length, (int i) {
                    return _OrganizationTileWidget(
                        isAdmin: false,
                        courseId: widget.courses[i]["courseId"],
                        courseName: Uri.decodeComponent(
                            widget.courses[i]["courseName"]));
                  })),
                ],
              );
            } else {
              return const ScholarityPageLoading();
            }
          }),
      Container(),
    ]);
  }
}

// myPage class which creates a state on call
class OrganizationCoursesAdminPage extends StatefulWidget {
  final List<Map<String, dynamic>> courses;
  final int organizationId;
  const OrganizationCoursesAdminPage({
    Key? key,
    required this.courses,
    required this.organizationId,
  }) : super(key: key);

  @override
  _OrganizationCoursesAdminPageState createState() =>
      _OrganizationCoursesAdminPageState();
}

// myPage state
class _OrganizationCoursesAdminPageState
    extends State<OrganizationCoursesAdminPage> {
  late payment_service.PaymentTier _paymentTier;
  @override
  void initState() {
    widget.courses.clear();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _loadCourses() async {
    Map<String, dynamic> response = await networking_api_service
        .getOrganization(organizationId: widget.organizationId);
    _paymentTier =
        payment_service.PaymentTier.values[response["data"]["paymentTier"]];

    Map<String, dynamic> response2 = await networking_api_service.getCourses(
        organizationId: widget.organizationId);
    for (int i = 0; i < response2["data"].length; i++) {
      widget.courses.add(response2["data"][i]);
    }
    return true;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return ScholarityTabPage(body: [
      const SizedBox(height: 20),
      const ProductCoursesWidget(),
      const SizedBox(height: 20),
      FutureBuilder(
          future: _loadCourses(),
          builder: (context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    child: ScholarityButton(
                        icon: Icons.add_rounded,
                        text: "New",
                        invertedColor: true,
                        verticalOnlyPadding: true,
                        onPressed: () async {
                          if (widget.courses.length <
                              payment_service
                                  .paymentTierCourseMax[_paymentTier]!) {
                            course_service.sendToCoursePage(context,
                                organizationId: widget.organizationId);
                          } else {
                            await showDialog<String>(
                                context: context,
                                builder: (BuildContext context) =>
                                    _PaymentWallAlertDialog(
                                      paymentTier: _paymentTier,
                                    ));
                          }
                        }),
                  ),
                  const SizedBox(height: 8),
                  widget.courses.isEmpty
                      ? const _NewCoursePromptWidget()
                      : Container(),
                  Column(
                      children: List.generate(widget.courses.length, (int i) {
                    return _OrganizationTileWidget(
                        isAdmin: true,
                        courseId: widget.courses[i]["courseId"],
                        courseName: Uri.decodeComponent(
                            widget.courses[i]["courseName"]));
                  })),
                ],
              );
            } else {
              return const ScholarityPageLoading();
            }
          }),
      Container(),
    ]);
  }
}

class _PaymentWallAlertDialog extends StatelessWidget {
  final payment_service.PaymentTier paymentTier;
  // constructor
  const _PaymentWallAlertDialog({Key? key, required this.paymentTier})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return ScholarityAlertDialogWrapper(
      child: ScholarityAlertDialog(
        title: const ScholarityTextH2B("You've reached your tier limit"),
        content: SizedBox(
          height: 200,
          width: 300,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ScholarityTextP(
                "Your plan (${payment_service.paymentTierName[paymentTier]!}) only allows\n"
                "for only ${payment_service.paymentTierCourseMax[paymentTier]!.toString()} "
                "courses to be created.\n\n"
                "Please upgrade your plan to continue to create courses."),
            Expanded(child: Container()),
            Row(
              children: [
                ScholarityButton(
                    text: "Dismiss",
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                ScholarityButton(
                    text: "Upgrade plan",
                    invertedColor: true,
                    onPressed: () {
                      payment_service.launchPaymentPricingPage();
                      Navigator.pop(context);
                    })
              ],
            )
          ]),
        ),
      ),
    );
  }
}

class _OrganizationTileWidget extends StatelessWidget {
  // members of MyWidget
  final int courseId;
  final String courseName;
  final bool isAdmin;

  // constructor
  const _OrganizationTileWidget(
      {Key? key,
      required this.courseId,
      required this.courseName,
      required this.isAdmin})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return ScholarityPadding(
        verticalOnly: true,
        child: ScholarityTile(
          child: InkWell(
            onTap: () {
              course_service.sendToCoursePage(context,
                  courseId: courseId, isAdminMode: isAdmin);
            },
            child: ScholarityPadding(
              child: SizedBox(
                height: 70,
                child: ScholarityTextH2B(courseName),
              ),
            ),
          ),
        ));
  }
}

class _NewCoursePromptWidget extends StatelessWidget {
  // constructor
  const _NewCoursePromptWidget({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 32),
      child: ScholarityTextH4("↑ Click this to create!"),
    );
  }
}
