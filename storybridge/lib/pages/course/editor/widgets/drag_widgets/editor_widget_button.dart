import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity
import 'package:mooc/style/scholarity_colors.dart' as scholarity_color;

import 'package:mooc/pages/auth_page.dart';

import 'package:mooc/services/auth_service.dart' as auth_service;
import 'package:mooc/services/course_navigation_service.dart'
    as course_navigation_service;
import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;

const widgetTypeButton = "button";

class EditorWidgetButton extends StatelessWidget implements EditorWidget {
  // constructor
  EditorWidgetButton({Key? key, required this.editorWidgetData})
      : super(key: key);

  @override
  late final EditorWidgetMetadata metadata;

  @override
  final EditorWidgetData editorWidgetData;
  @override
  final bool reduceDropzoneSize = false;

  final ScholarityTextFieldController _controller =
      ScholarityTextFieldController();

  // serialization
  @override
  void loadFromJson(Map<String, dynamic> json) {
    metadata = getMetadata(json, editorWidgetData);
    ;
    _controller.text = json["text"];
  }

  @override
  Map<String, dynamic> saveToJson() {
    return {
      "metadata": metadata.encode(),
      "widgetType": widgetTypeButton,
      "text": _controller.text,
    };
  }

  @override
  void onCreate() {}

  @override
  void onRemove() {}

  @override
  Widget? getToolbar() {
    return null;
  }

  bool _checkIfUserEnrolled() {
    if (editorWidgetData.isAdminMode) {
      return true; // show enroll now
    }
    auth_service.AuthUserData? userData =
        auth_service.globalUser.getAuthUserData();
    if (userData != null) {
      List<dynamic> courseSubscriptionData = userData.courseSubscriptionData;
      for (int i = 0; i < courseSubscriptionData.length; i++) {
        int courseId = courseSubscriptionData[i]["courseId"];
        if (editorWidgetData.courseData.courseId == courseId) {
          return false; // show resume course
        }
      }
    }
    return true; // show enroll now
  }

  Future<bool> _enrollNow(BuildContext context) async {
    if (!editorWidgetData.isAdminMode) {
      // check if user is logged in, if not log them in
      auth_service.AuthUserData? userData =
          auth_service.globalUser.getAuthUserData();
      bool isLoggedIn = userData != null;
      if (!isLoggedIn) {
        await showDialog<String>(
          context: context,
          builder: (BuildContext context) => ScholarityAlertDialogWrapper(
            child: ScholarityAlertDialog(
              content: AuthWidget(
                startWithLoginMode: false,
                organizationId: editorWidgetData.courseData.organizationId,
              ),
            ),
          ),
        );
      }

      // check if user is successfully logged in
      userData = auth_service.globalUser.getAuthUserData();
      // check if login is successful
      bool loginSuccess = userData != null;
      if (!loginSuccess) {
        return false;
      }

      if (_courseSalesData.price != 0) {
        /*
        await showDialog<String>(
          context: context,
          builder: (BuildContext context) => ScholarityAlertDialogWrapper(
            child: ScholarityAlertDialog(
              content: _PaymentWelcomeWidget(
                  courseSalesData: _courseSalesData,
                  link: _courseSalesData.checkoutSessionUrl),
            ),
          ),
        );
        */
        if (_courseSalesData.checkoutSessionUrl != null) {
          launchUrl(Uri.parse(_courseSalesData.checkoutSessionUrl!));
          return false;
        }
      } else {
        // subscribe to course
        await networking_api_service.subscribeToCourse(
            courseId: editorWidgetData.courseData.courseId);
      }
    }

    // find the first course element after the front page
    List<course_navigation_service.CourseSection> courseHierarchy =
        editorWidgetData.courseData.courseHierarchy;
    course_navigation_service.CourseSection firstCourseSection =
        courseHierarchy[1];
    course_navigation_service.CourseElement firstElement =
        firstCourseSection.courseElements[0];

    // go to the first page
    course_navigation_service.goToPage(firstElement.courseElementId);
    return true;
  }

  final _CourseSalesData _courseSalesData = _CourseSalesData();

  Future<bool> _getCourseSalesData() async {
    Map<String, dynamic> response = await networking_api_service
        .getCourseSalesSettings(courseId: editorWidgetData.courseData.courseId);
    _courseSalesData.price = (response["data"]["coursePrice"] / 100) ?? 0;
    _courseSalesData.currencyCode =
        response["data"]["coursePriceCurrencyCode"] ?? "";
    _courseSalesData.productName = response["data"]["courseProductName"] ?? "";
    _courseSalesData.productDescription =
        response["data"]["courseProductDescription"] ?? "";
    _courseSalesData.checkoutSessionUrl = response["data"]["checkoutSessionUrl"]
            ["isValid"]
        ? response["data"]["checkoutSessionUrl"]["url"]
        : null;
    return true;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    bool isUserEnrolled = _checkIfUserEnrolled();

    if (isUserEnrolled) {
      return FutureBuilder(
          future: _getCourseSalesData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData) {
              return _NotEnrolledWidget(
                courseSalesData: _courseSalesData,
                onEnroll: () => _enrollNow(context),
              );
            } else {
              return const ScholarityTile(
                  child: ScholarityPadding(
                      child: ScholarityBoxLoading(height: 80, width: 200)));
            }
          });
    } else {
      return ScholarityButton(
        text: "Resume Course",
        onPressed: () {
          // find the first course element after the front page
          List<course_navigation_service.CourseSection> courseHierarchy =
              editorWidgetData.courseData.courseHierarchy;
          course_navigation_service.CourseSection firstCourseSection =
              courseHierarchy[1];
          course_navigation_service.CourseElement firstElement =
              firstCourseSection.courseElements[0];

          // go to the first page
          course_navigation_service.goToPage(firstElement.courseElementId);
        },
        verticalOnlyPadding: true,
      );
    }
    /*
    return ScholarityEditableText(
      enabled: editorWidgetData.isAdminMode,
      controller: _controller,
      onSubmit: () {
        editorWidgetData.onUpdate();
      },
      style: scholarityTextPStyle,
    );
    */
  }
}

class _CourseSalesData {
  double price = 0;
  String currencyCode = "";
  String productName = "";
  String productDescription = "";
  String? checkoutSessionUrl = "";
}

class _NotEnrolledWidget extends StatelessWidget {
  // members of MyWidget
  final _CourseSalesData courseSalesData;
  final Future<bool> Function() onEnroll;

  // constructor
  const _NotEnrolledWidget(
      {Key? key, required this.courseSalesData, required this.onEnroll})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    NumberFormat numberFormat = NumberFormat.decimalPattern('hi');
    return Align(
      alignment: Alignment.centerLeft,
      child: ScholarityTile(
        child: ScholarityPadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              courseSalesData.price != 0
                  ? Text(
                      "${courseSalesData.currencyCode.toUpperCase()} ${numberFormat.format(courseSalesData.price)}",
                      style: TextStyle(
                          color: scholarity_color.black,
                          fontFamily: scholarityTextH2BStyle.fontFamily,
                          fontWeight: scholarityTextPStyle.fontWeight,
                          fontSize: 25),
                    )
                  : Container(),
              courseSalesData.price != 0
                  ? const ScholarityDivider()
                  : Container(),
              courseSalesData.price != 0
                  ? ScholarityTextP(courseSalesData.productDescription)
                  : Container(),
              courseSalesData.price != 0
                  ? const SizedBox(height: 20)
                  : Container(),
              ScholarityButton(
                padding: false,
                onPressed: () async {
                  await onEnroll();
                },
                invertedColor: true,
                verticalOnlyPadding: true,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 64),
                  child: ScholarityTextBasic("Read now",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: scholarityTextH2BStyle.fontFamily,
                          fontWeight: scholarityTextPStyle.fontWeight,
                          fontSize: scholarityTextH2BStyle.fontSize)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentWelcomeWidget extends StatelessWidget {
  // members of MyWidget

  final _CourseSalesData courseSalesData;
  final String link;

  // constructor
  const _PaymentWelcomeWidget(
      {Key? key, required this.courseSalesData, required this.link})
      : super(key: key);

  void _goToLink(BuildContext context) {
    String url = link;
    launchUrl(Uri.parse(url));
    Navigator.pop(context);
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: ScholarityPadding(
        child: SizedBox(
          width: 370,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const ScholarityTextH2B("Checkout"),
              const SizedBox(height: 10),
              ScholarityTextH4(courseSalesData.productName),
              const SizedBox(height: 20),
              const ScholarityTextP(
                  "Thank you for choosing to enroll in our course! We partner with Stripe to bring you effortless payment of your story."),
              const SizedBox(height: 50),
              Row(
                children: [
                  const Expanded(child: ScholarityTextH2B("Total:")),
                  Expanded(
                    child: ScholarityTextH2B(
                        "${courseSalesData.currencyCode.toUpperCase()} ${courseSalesData.price}"),
                  ),
                ],
              ),
              const ScholarityDivider(),
              ScholarityButton(
                  padding: false,
                  onPressed: () => _goToLink(context),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      Text("Checkout with Stripe",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: scholarity_color.scholarityAccent)),
                      const SizedBox(width: 30),
                      Icon(Icons.arrow_forward_rounded,
                          color: scholarity_color.scholarityAccent)
                    ]),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
