import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/error_service.dart' as error_service;
import 'package:mooc/services/certificate_service.dart' as certificate_service;
import 'package:mooc/services/auth_service.dart' as auth_service;
import 'package:mooc/style/scholarity_colors.dart' as scholarity_color;

// helper function
int _getWeightingTotal(List<dynamic> data) {
  double weightingTotal = 0;
  for (int i = 0; i < data.length; i++) {
    List<dynamic> courseElements = data[i]["children"];
    for (int j = 0; j < courseElements.length; j++) {
      List<dynamic> assessments = courseElements[j]["assessments"];
      for (int k = 0; k < assessments.length; k++) {
        weightingTotal += assessments[k]["weighting"];
      }
    }
  }
  return weightingTotal.round();
}

double _niceRound(double val) {
  if (!val.isFinite) {
    return -1;
  }
  return (val * 10).round() / 10;
}

// myPage class which creates a state on call
class CourseGradesForAdminsPage extends StatefulWidget {
  final int courseId;
  const CourseGradesForAdminsPage({required this.courseId, Key? key})
      : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<CourseGradesForAdminsPage> {
  int _selectedPage = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final ScholarityTabPageController _tabPageController =
      ScholarityTabPageController();
  // main build function
  @override
  Widget build(BuildContext context) {
    return ScholarityTabPage(
        hasVeryReducedPadding: true,
        tabPageController: _tabPageController,
        sideBar: [
          const SizedBox(height: 80),
          ScholaritySideBarButton(
              label: "Assessments",
              icon: Icons.quiz_rounded,
              onPressed: () {
                // hide mobile sidebar
                _tabPageController.mobileShowSidebar = false;
                _tabPageController.update();

                setState(() {
                  _selectedPage = 0;
                });
              },
              selected: _selectedPage == 0),
          ScholaritySideBarButton(
              label: "Students",
              icon: Icons.people_rounded,
              onPressed: () {
                // hide mobile sidebar
                _tabPageController.mobileShowSidebar = false;
                _tabPageController.update();

                setState(() {
                  _selectedPage = 1;
                });
              },
              selected: _selectedPage == 1)
        ],
        body: [
          Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: Builder(builder: (context) {
              switch (_selectedPage) {
                case 0:
                  return CourseGradesAssessmentsPage(
                    courseId: widget.courseId,
                  );
                case 1:
                  return CourseGradesStudentsPage(
                    courseId: widget.courseId,
                    controller: _CourseGradesStudentsController(),
                  );
              }
              return Container();
            }),
          )
        ]);
  }
}

// myPage class which creates a state on call
class CourseGradesForFrontPage extends StatefulWidget {
  final int courseId;
  const CourseGradesForFrontPage({required this.courseId, Key? key})
      : super(key: key);

  @override
  _CourseGradesForFrontPageState createState() =>
      _CourseGradesForFrontPageState();
}

// myPage state
class _CourseGradesForFrontPageState extends State<CourseGradesForFrontPage> {
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
    return ScholarityTabPage(body: [
      Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: Builder(builder: (context) {
          return CourseGradesFrontAssessmentsPage(
            courseId: widget.courseId,
          );
        }),
      )
    ]);
  }
}

// myPage class which creates a state on call
class CourseGradesForStudentsPage extends StatefulWidget {
  final int courseId;
  const CourseGradesForStudentsPage({Key? key, required this.courseId})
      : super(key: key);

  @override
  _CourseGradesForStudentsPageState createState() =>
      _CourseGradesForStudentsPageState();
}

// myPage state
class _CourseGradesForStudentsPageState
    extends State<CourseGradesForStudentsPage> {
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
    _CourseGradesStudentsController controller =
        _CourseGradesStudentsController();
    controller.isAdminMode = false;
    return ScholarityTabPage(sideBar: null, body: [
      Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: Builder(builder: (context) {
          return _CourseGradesStudentsStatisticsPage(
              courseId: widget.courseId, controller: controller);
        }),
      )
    ]);
  }
}

// myPage class which creates a state on call
class CourseGradesAssessmentsPage extends StatefulWidget {
  final int courseId;
  const CourseGradesAssessmentsPage({Key? key, required this.courseId})
      : super(key: key);

  @override
  _CourseGradesAssessmentsPageState createState() =>
      _CourseGradesAssessmentsPageState();
}

// myPage state
class _CourseGradesAssessmentsPageState
    extends State<CourseGradesAssessmentsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<dynamic>> _load() async {
    Map<String, dynamic> response =
        await networking_api_service.getAllAssessmentsForCourse(
            courseId: widget.courseId, omitStudentGrades: false);
    return response["data"];
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    error_service.checkAlerts(context);

    return ScholarityHolder(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const ScholarityTextH2("Assessments"),
        const SizedBox(height: 25),
        const ScholarityTextP(
            "These are all assessments which have to be completed in this course."),
        const SizedBox(height: 60),
        FutureBuilder(
            future: _load(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              // if loading
              if (!snapshot.hasData) {
                return const Column(
                  children: [
                    ScholarityBoxLoading(height: 50, width: 500),
                    ScholarityBoxLoading(height: 50, width: 500),
                    ScholarityBoxLoading(height: 50, width: 500),
                    ScholarityBoxLoading(height: 50, width: 500),
                  ],
                );
              }

              List<dynamic> assessmentCourseHierarchy = snapshot.data;
              int weightingTotal =
                  _getWeightingTotal(assessmentCourseHierarchy);
              return _AssessmentList(
                assessmentCourseHierarchy: assessmentCourseHierarchy,
                weightingTotal: weightingTotal,
                omitStudentGrades: false,
              );
            }),
      ]),
    );
  }
}

class CourseGradesFrontAssessmentsPage extends StatefulWidget {
  final int courseId;
  const CourseGradesFrontAssessmentsPage({Key? key, required this.courseId})
      : super(key: key);

  @override
  _CourseGradesFrontAssessmentsPageState createState() =>
      _CourseGradesFrontAssessmentsPageState();
}

// myPage state
class _CourseGradesFrontAssessmentsPageState
    extends State<CourseGradesFrontAssessmentsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<dynamic>> _load() async {
    Map<String, dynamic> response =
        await networking_api_service.getAllAssessmentsForCourse(
            courseId: widget.courseId, omitStudentGrades: true);
    return response["data"];
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    error_service.checkAlerts(context);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const ScholarityTextH2("Assessments"),
      const SizedBox(height: 25),
      const ScholarityTextP(
          "These are all assessments which have to be completed in this course."),
      const SizedBox(height: 60),
      FutureBuilder(
          future: _load(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            // if loading
            if (!snapshot.hasData) {
              return const Column(
                children: [
                  ScholarityBoxLoading(height: 50, width: 500),
                  ScholarityBoxLoading(height: 50, width: 500),
                  ScholarityBoxLoading(height: 50, width: 500),
                  ScholarityBoxLoading(height: 50, width: 500),
                ],
              );
            }

            List<dynamic> assessmentCourseHierarchy = snapshot.data;
            int weightingTotal = _getWeightingTotal(assessmentCourseHierarchy);
            return _AssessmentList(
              assessmentCourseHierarchy: assessmentCourseHierarchy,
              weightingTotal: weightingTotal,
              omitStudentGrades: true,
            );
          }),
    ]);
  }
}

// myPage class which creates a state on call
class _AssessmentList extends StatefulWidget {
  final List<dynamic> assessmentCourseHierarchy;
  final int weightingTotal;
  final bool omitStudentGrades;
  const _AssessmentList(
      {Key? key,
      required this.assessmentCourseHierarchy,
      required this.weightingTotal,
      required this.omitStudentGrades})
      : super(key: key);

  @override
  _AssessmentListState createState() => _AssessmentListState();
}

// myPage state
class _AssessmentListState extends State<_AssessmentList> {
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
    return Column(
      children: List.generate(widget.assessmentCourseHierarchy.length, (int i) {
        String courseSectionName = Uri.decodeComponent(
            widget.assessmentCourseHierarchy[i]["courseSectionName"]);
        List<dynamic> courseElements =
            widget.assessmentCourseHierarchy[i]["children"];

        return ExpansionTile(
            initiallyExpanded: true,
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ScholarityTextH2B(courseSectionName),
            ),
            childrenPadding: const EdgeInsets.all(8.0),
            children: List.generate(courseElements.length, (int j) {
              String courseElementName =
                  Uri.decodeComponent(courseElements[j]["courseElementName"]);
              List<dynamic> assessments = courseElements[j]["assessments"];

              return Column(
                  children: List.generate(assessments.length, (int j) {
                String assessmentName = courseElementName;
                if (assessments.length > 1) {
                  assessmentName += "\nAssessment ${j + 1}";
                }
                double? percentOfCorrectAnswers;
                if (!widget.omitStudentGrades) {
                  int totalNotAnsweredAnswers =
                      assessments[j]["totalNotAnsweredAnswers"];
                  int totalCorrectAnswers =
                      assessments[j]["totalCorrectAnswers"];
                  int totalIncorrectAnswers =
                      assessments[j]["totalIncorrectAnswers"];
                  int sumOfAnswers = totalCorrectAnswers +
                      totalIncorrectAnswers +
                      totalNotAnsweredAnswers;
                  if (sumOfAnswers != 0) {
                    percentOfCorrectAnswers =
                        totalCorrectAnswers / sumOfAnswers;
                  } else {
                    percentOfCorrectAnswers = 0;
                  }
                }
                int weighting =
                    (assessments[j]["weighting"] / widget.weightingTotal * 100)
                        .round();

                return _AssessmentWidget(
                  courseElementName: assessmentName,
                  percentageOfCorrectAnswers: percentOfCorrectAnswers,
                  weighting: weighting,
                );
              }));
            }));
      }),
    );
  }
}

class _AssessmentWidget extends StatelessWidget {
  // members of MyWidget
  final String courseElementName;
  final double? percentageOfCorrectAnswers;
  final int weighting;

  // constructor
  const _AssessmentWidget({
    Key? key,
    required this.courseElementName,
    required this.percentageOfCorrectAnswers,
    required this.weighting,
  }) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
          onTap: () {},
          child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: scholarity_color.borderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.quiz_outlined,
                            size: 30, color: scholarity_color.darkGrey),
                        const SizedBox(width: 10),
                        ScholarityTextH2B(courseElementName),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ScholarityTextH5(
                        "${percentageOfCorrectAnswers != null ? "average grade: ${_niceRound(percentageOfCorrectAnswers! * 100).toString()}%\n" : "\n"}weighting: ${weighting.toString()}%"),
                  ),
                ],
              ))),
    );
  }
}

/*





























*/

class _CourseGradesStudentsController {
  int? studentUserId;
  bool isAdminMode = true;
  String studentName = "";
}

// myPage class which creates a state on call
class CourseGradesStudentsPage extends StatefulWidget {
  final int courseId;
  final _CourseGradesStudentsController controller;
  const CourseGradesStudentsPage(
      {Key? key, required this.courseId, required this.controller})
      : super(key: key);

  @override
  _CourseGradesStudentsPageState createState() =>
      _CourseGradesStudentsPageState();
}

// myPage state
class _CourseGradesStudentsPageState extends State<CourseGradesStudentsPage> {
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
    if (widget.controller.studentUserId == null) {
      return _CourseGradesStudentsAllPage(
        courseId: widget.courseId,
        controller: widget.controller,
        onUpdate: () {
          setState(() {});
        },
      );
    } else {
      return _CourseGradesStudentsStatisticsPage(
          courseId: widget.courseId, controller: widget.controller);
    }
  }
}

// myPage class which creates a state on call
class _CourseGradesStudentsStatisticsPage extends StatefulWidget {
  final int courseId;
  final _CourseGradesStudentsController controller;
  const _CourseGradesStudentsStatisticsPage(
      {Key? key, required this.courseId, required this.controller})
      : super(key: key);

  @override
  _CourseGradesStudentsStatisticsPageState createState() =>
      _CourseGradesStudentsStatisticsPageState();
}

// myPage state
class _CourseGradesStudentsStatisticsPageState
    extends State<_CourseGradesStudentsStatisticsPage> {
  bool _isLoadingCert = false;
  bool _isLoadingPass = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  double _calculateTotalGrade(List<dynamic> data, int totalWeighting) {
    double totalAssessmentGrades = 0;

    for (int i = 0; i < data.length; i++) {
      List<dynamic> courseElements = data[i]["children"];
      for (int j = 0; j < courseElements.length; j++) {
        List<dynamic> assessments = courseElements[j]["assessments"];
        for (int k = 0; k < assessments.length; k++) {
          Map<String, dynamic> assessment = assessments[k];
          int totalCorrectAnswers = assessment["totalCorrectAnswers"];
          int totalNumOfAnswers = assessment["totalCorrectAnswers"] +
              assessment["totalIncorrectAnswers"] +
              assessment["totalNotAnsweredAnswers"];

          double assessmentWeighting = 0;
          // divide by zero check
          if (totalWeighting != 0) {
            assessmentWeighting = assessments[k]["weighting"] / totalWeighting;
          }

          double assessmentPercentage = 0;
          // divide by zero check
          if (totalNumOfAnswers != 0) {
            assessmentPercentage = totalCorrectAnswers / totalNumOfAnswers;
          }

          totalAssessmentGrades += assessmentPercentage * assessmentWeighting;
        }
      }
    }
    return _niceRound(totalAssessmentGrades * 100);
  }

  int _calculateAssessmentsPassed(List<dynamic> data) {
    int assessmentsPassed = 0;
    // check if all assessments are passed
    for (int i = 0; i < data.length; i++) {
      List<dynamic> courseElements = data[i]["children"];
      for (int j = 0; j < courseElements.length; j++) {
        List<dynamic> assessments = courseElements[j]["assessments"];
        for (int k = 0; k < assessments.length; k++) {
          Map<String, dynamic> assessment = assessments[k];
          int totalCorrectAnswers = assessment["totalCorrectAnswers"];
          int totalNumOfAnswers = assessment["totalCorrectAnswers"] +
              assessment["totalIncorrectAnswers"] +
              assessment["totalNotAnsweredAnswers"];
          double assessmentPercentage = totalCorrectAnswers / totalNumOfAnswers;
          double passingPercentage = assessment["passingPercentage"];
          if (assessmentPercentage * 100 >= passingPercentage) {
            assessmentsPassed++;
          }
        }
      }
    }
    return assessmentsPassed;
  }

  int _calculateAssessmentsTotal(List<dynamic> data) {
    int assessmentsTotal = 0;
    // check if all assessments are passed
    for (int i = 0; i < data.length; i++) {
      List<dynamic> courseElements = data[i]["children"];
      for (int j = 0; j < courseElements.length; j++) {
        List<dynamic> assessments = courseElements[j]["assessments"];
        assessmentsTotal += assessments.length;
      }
    }
    return assessmentsTotal;
  }

  bool _isPassed(List<dynamic> data) {
    int assesmentsPassed = _calculateAssessmentsPassed(data);
    int assessmentsTotal = _calculateAssessmentsTotal(data);
    return assessmentsTotal <= assesmentsPassed;
  }

  Future<List<dynamic>> _load() async {
    if (widget.controller.isAdminMode) {
      Map<String, dynamic> response =
          await networking_api_service.getAssessmentStatsForStudentForCourse(
        courseId: widget.courseId,
        studentUserId: widget.controller.studentUserId!,
      );
      return response["data"]["data"];
    } else {
      Map<String, dynamic> response = await networking_api_service
          .getAssessmentStatsForThisStudentForCourse(
        courseId: widget.courseId,
      );
      return response["data"];
    }
  }

  Future<void> _printCertificate() async {
    setState(() {
      _isLoadingCert = true;
    });

    // get the name of the person recieving the award
    String name;
    int userId;
    if (!widget.controller.isAdminMode) {
      auth_service.AuthUserData? userData =
          auth_service.globalUser.getAuthUserData();
      name = "${userData!.firstName} ${userData.lastName}";
      userId = userData.userId;
    } else {
      name = widget.controller.studentName;
      userId = 5;
    }

    await certificate_service
        .printCertficate(certificate_service.CertificateUserInput(
      name: name,
      courseId: widget.courseId,
      jobTitle: "วิศวกร",
      company: "บจก. ABC",
      userId: userId,
    ));
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoadingCert = false;
    });
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // calculate the total grade
    error_service.checkAlerts(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScholarityTextH2(widget.controller.isAdminMode
            ? widget.controller.studentName
            : "Grades"),
        const SizedBox(height: 60),
        FutureBuilder(
            future: _load(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              // if loading
              if (!snapshot.hasData) {
                return const Column(
                  children: [
                    ScholarityBoxLoading(height: 50, width: 500),
                    ScholarityBoxLoading(height: 50, width: 500),
                    ScholarityBoxLoading(height: 50, width: 500),
                    ScholarityBoxLoading(height: 50, width: 500),
                  ],
                );
              }
              List<dynamic> assessmentCourseHierarchy = snapshot.data;
              int weightingTotal =
                  _getWeightingTotal(assessmentCourseHierarchy);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Row(
                        children: [
                          _PassIcon(
                              state: _isPassed(assessmentCourseHierarchy)
                                  ? _PassIconState.passed
                                  : _PassIconState.notPassed),
                          const SizedBox(width: 10),
                          ScholarityTextH4(_isPassed(assessmentCourseHierarchy)
                              ? "Course Passed"
                              : "Not Passed"),
                        ],
                      )),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const ScholarityTextH2B("Total Grade:"),
                                const SizedBox(width: 10),
                                ScholarityTextH2B(
                                    "${_calculateTotalGrade(assessmentCourseHierarchy, weightingTotal)}%"),
                              ],
                            ),
                            Row(
                              children: [
                                const ScholarityTextH2B("Assessments Passed:"),
                                const SizedBox(width: 10),
                                ScholarityTextH2B(
                                    "${_calculateAssessmentsPassed(assessmentCourseHierarchy)}/${_calculateAssessmentsTotal(assessmentCourseHierarchy)}"),
                              ],
                            ),
                            _isPassed(assessmentCourseHierarchy)
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Row(
                                      children: [
                                        ScholarityButton(
                                            text: "Print Certificate",
                                            loading: _isLoadingCert,
                                            onPressed: () async {
                                              await _printCertificate();
                                            }),
                                        ScholarityButton(
                                            text: "Print Passport",
                                            loading: _isLoadingPass,
                                            onPressed: () async {
                                              setState(() {
                                                _isLoadingPass = true;
                                              });

                                              // get the name of the person recieving the award
                                              String name =
                                                  widget.controller.studentName;
                                              String jobTitle = "วิศวกร";
                                              String company = "บจก. ABC";
                                              int userId = 5;
                                              int? profilePictureImageId = null;

                                              if (!widget
                                                  .controller.isAdminMode) {
                                                auth_service.AuthUserData?
                                                    userData = auth_service
                                                        .globalUser
                                                        .getAuthUserData();
                                                if (userData != null) {
                                                  name =
                                                      "${userData.firstName} ${userData.lastName}";
                                                  userId = userData.userId;
                                                  Map<String, dynamic>
                                                      response =
                                                      await networking_api_service
                                                          .getUser(
                                                              userId: userId);
                                                  jobTitle = Uri
                                                      .decodeComponent(response[
                                                                  "data"]
                                                              ["extraUserData"]
                                                          ["jobTitle"]);
                                                  company = Uri.decodeComponent(
                                                      response["data"]
                                                              ["extraUserData"]
                                                          ["company"]);
                                                  profilePictureImageId = response[
                                                              "data"]
                                                          ["extraUserData"]
                                                      ["profilePictureImageId"];
                                                }
                                              }

                                              await certificate_service
                                                  .printPassport(certificate_service
                                                      .CertificateUserInput(
                                                          name: name,
                                                          courseId:
                                                              widget.courseId,
                                                          jobTitle: jobTitle,
                                                          company: company,
                                                          userId: userId,
                                                          profilePictureImageId:
                                                              profilePictureImageId));
                                              await Future.delayed(
                                                  const Duration(seconds: 2));
                                              setState(() {
                                                _isLoadingPass = false;
                                              });
                                            }),
                                      ],
                                    ))
                                : (!widget.controller.isAdminMode
                                    ? Container()
                                    : ScholarityButton(
                                        text: "Force print certificate",
                                        loading: _isLoadingCert,
                                        onPressed: () async {
                                          setState(() {
                                            error_service.alert(
                                                error_service.Alert(
                                                    title:
                                                        "Force print certificate?",
                                                    description:
                                                        "This student did not pass the course. Do you still want to print it?",
                                                    buttonName: "YES",
                                                    allowCancel: true,
                                                    callback: (_) async {
                                                      await _printCertificate();
                                                    }));
                                          });
                                        })),
                          ],
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Column(
                    children: List.generate(assessmentCourseHierarchy.length,
                        (int i) {
                      String courseSectionName = Uri.decodeComponent(
                          assessmentCourseHierarchy[i]["courseSectionName"]);
                      List<dynamic> courseElements =
                          assessmentCourseHierarchy[i]["children"];

                      return ExpansionTile(
                          initiallyExpanded: true,
                          title: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ScholarityTextH2B(courseSectionName),
                          ),
                          childrenPadding: const EdgeInsets.all(8.0),
                          children:
                              List.generate(courseElements.length, (int j) {
                            String courseElementName = Uri.decodeComponent(
                                courseElements[j]["courseElementName"]);
                            List<dynamic> assessments =
                                courseElements[j]["assessments"];

                            return Column(
                                children:
                                    List.generate(assessments.length, (int j) {
                              String assessmentName = courseElementName;
                              if (assessments.length > 1) {
                                assessmentName += "\nAssessment ${j + 1}";
                              }

                              int totalNotAnsweredAnswers =
                                  assessments[j]["totalNotAnsweredAnswers"];
                              int totalCorrectAnswers =
                                  assessments[j]["totalCorrectAnswers"];
                              int totalIncorrectAnswers =
                                  assessments[j]["totalIncorrectAnswers"];
                              int sumOfAnswers = totalCorrectAnswers +
                                  totalIncorrectAnswers +
                                  totalNotAnsweredAnswers;
                              double percentOfCorrectAnswers;
                              if (sumOfAnswers != 0) {
                                percentOfCorrectAnswers =
                                    totalCorrectAnswers / sumOfAnswers;
                              } else {
                                percentOfCorrectAnswers = 0;
                              }
                              int weighting = (assessments[j]["weighting"] /
                                      weightingTotal *
                                      100)
                                  .round();
                              return _AssessmentStatisticsWidget(
                                unansweredQuestions: totalNotAnsweredAnswers,
                                courseElementName: assessmentName,
                                isUserBeganAssessment: assessments[j]
                                        ["userBeganAssessment"] ==
                                    "true",
                                percentOfCorrectAnswers:
                                    percentOfCorrectAnswers,
                                weighting: weighting,
                                passingPercentage: assessments[j]
                                    ["passingPercentage"],
                                correctAnswers: assessments[j]
                                    ["correctAnswers"],
                                showAnswers: widget.controller.isAdminMode,
                              );
                            }));
                          }));
                    }),
                  ),
                ],
              );
            }),
      ],
    );
  }
}

class _AssessmentStatisticsWidget extends StatelessWidget {
  // members of MyWidget
  final String courseElementName;
  final bool isUserBeganAssessment;
  final double percentOfCorrectAnswers;
  final int weighting;
  final int passingPercentage;
  final int unansweredQuestions;
  final bool showAnswers;
  final List<dynamic> correctAnswers;

  // constructor
  const _AssessmentStatisticsWidget(
      {Key? key,
      required this.courseElementName,
      required this.isUserBeganAssessment,
      required this.percentOfCorrectAnswers,
      required this.weighting,
      required this.passingPercentage,
      required this.correctAnswers,
      required this.unansweredQuestions,
      required this.showAnswers})
      : super(key: key);

  _PassIconState _isPassed() {
    if (unansweredQuestions > 0) return _PassIconState.notFinished;
    if ((percentOfCorrectAnswers * 100) >= passingPercentage) {
      return _PassIconState.passed;
    } else {
      return _PassIconState.notPassed;
    }
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // test if the user has no 'not answered' questions left
    //bool isUserFinishedAssessment = true;
    for (int i = 0; i < correctAnswers.length; i++) {
      if (correctAnswers[i] == "not answered") {
        //isUserFinishedAssessment = false;
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
          onTap: () {},
          child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: scholarity_color.borderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            _PassIcon(state: _isPassed()),
                            const SizedBox(width: 10),
                            ScholarityTextH2B(courseElementName),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ScholarityTextH5("score:"),
                                ScholarityTextH5("weighting:"),
                                ScholarityTextH5("weighted score:"),
                              ],
                            ),
                            const SizedBox(width: 10),
                            ScholarityTextH5(
                                "${_niceRound(percentOfCorrectAnswers * 100).toString()}%\n"
                                /*"${_isPassed() == _PassIconState.passed ? "" : "(passing score is $passingPercentage%)\n"}"*/
                                "${weighting.toString()}%\n"
                                "${(_niceRound(percentOfCorrectAnswers * weighting)).toString()}%"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  isUserBeganAssessment
                      ? const SizedBox(height: 20)
                      : Container(),
                  showAnswers
                      ? Row(
                          children:
                              List.generate(correctAnswers.length, (int i) {
                            return Flexible(
                                child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: _AssessmentQuestionStatus(
                                  status: correctAnswers[i]),
                            ));
                          }),
                        )
                      : Container(),
                ],
              ))),
    );
  }
}

enum _PassIconState { passed, notPassed, notFinished }

class _PassIcon extends StatelessWidget {
  // members of MyWidget
  final _PassIconState state;
  final bool isSmall;

  // constructor
  const _PassIcon({Key? key, required this.state, this.isSmall = false})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    switch (state) {
      case _PassIconState.passed:
        return Tooltip(
            message: "passed",
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.green,
              size: isSmall ? 20 : 35,
            ));
      case _PassIconState.notPassed:
        return Tooltip(
            message: "not passed",
            child: Icon(
              Icons.highlight_off_rounded,
              color: Colors.red,
              size: isSmall ? 20 : 35,
            ));
      case _PassIconState.notFinished:
        return Tooltip(
            message: "not finished",
            child: Icon(
              Icons.highlight_off_rounded,
              color: Colors.grey,
              size: isSmall ? 20 : 35,
            ));
    }
  }
}

class _AssessmentQuestionStatus extends StatelessWidget {
  // members of MyWidget
  final String status;

  // constructor
  const _AssessmentQuestionStatus({Key? key, required this.status})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    Color statusColor;
    _PassIconState passIconState;

    switch (status) {
      case "correct":
        statusColor = const Color(0xffdcefdc);
        passIconState = _PassIconState.passed;
        break;
      case "incorrect":
        statusColor = const Color(0xfffcd2cf);
        passIconState = _PassIconState.notPassed;
        break;
      case "not answered":
      default:
        statusColor = const Color(0xffe6e6e6);
        passIconState = _PassIconState.notFinished;
        break;
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 30,
          decoration: BoxDecoration(
              color: statusColor, borderRadius: BorderRadius.circular(8.0)),
        ),
        _PassIcon(
          state: passIconState,
          isSmall: true,
        ),
      ],
    );
  }
}

// myPage class which creates a state on call
class _CourseGradesStudentsAllPage extends StatefulWidget {
  final int courseId;
  final _CourseGradesStudentsController controller;
  final void Function() onUpdate;
  const _CourseGradesStudentsAllPage(
      {Key? key,
      required this.courseId,
      required this.controller,
      required this.onUpdate})
      : super(key: key);

  @override
  _CourseGradesStudentsAllPageState createState() =>
      _CourseGradesStudentsAllPageState();
}

// myPage state
class _CourseGradesStudentsAllPageState
    extends State<_CourseGradesStudentsAllPage> {
  ScholarityTextFieldController _textFieldController =
      ScholarityTextFieldController();
  bool _isLoadingForcePrintAllCertificates = false;
  @override
  void initState() {
    super.initState();
    _textFieldController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<dynamic>> _load() async {
    Map<String, dynamic> response = await networking_api_service
        .getCourseAnalyticsStudents(courseId: widget.courseId);
    return response["data"];
  }

  Future<void> _forcePrintAllCertificates(dynamic data) async {
    setState(() {
      _isLoadingForcePrintAllCertificates = true;
    });
    final List<certificate_service.CertificateUserInput> certificateUserInput =
        [];
    for (int i = 0; i < data.length; i++) {
      print(i);
      certificateUserInput.add(certificate_service.CertificateUserInput(
        name:
            "${Uri.decodeComponent(data[i]["firstName"])} ${Uri.decodeComponent(data[i]["lastName"])}",
        courseId: widget.courseId,
        jobTitle: "วิศวกร",
        company: "บจก. ABC",
        userId: data[i]["userId"],
      ));
    }
    await certificate_service.printAllCertficate(certificateUserInput);
    setState(() {
      _isLoadingForcePrintAllCertificates = false;
    });
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    error_service.checkAlerts(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const ScholarityTextH2("Students"),
      const SizedBox(height: 60),
      FutureBuilder(
          future: _load(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            // if loading
            if (!snapshot.hasData) {
              return const Column(
                children: [
                  ScholarityBoxLoading(height: 50, width: 500),
                  ScholarityBoxLoading(height: 50, width: 500),
                  ScholarityBoxLoading(height: 50, width: 500),
                  ScholarityBoxLoading(height: 50, width: 500),
                ],
              );
            }
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Container()),
                    ScholarityButton(
                      text: "Force print all certificates",
                      loading: _isLoadingForcePrintAllCertificates,
                      onPressed: () {
                        _forcePrintAllCertificates(snapshot.data);
                      },
                    )
                  ],
                ),
                ScholarityTable(
                    advancedHeaders: [
                      ScholarityTableHeader(key: "email", label: "Email"),
                      ScholarityTableHeader(
                          key: "firstName", label: "First name"),
                      ScholarityTableHeader(
                          key: "lastName", label: "Last name"),
                      ScholarityTableHeader(
                          key: "totalAssessmentGrades", label: "Grade"),
                      ScholarityTableHeader(
                          key: "assessmentsPassed",
                          label: "Assessments passed"),
                    ],
                    onView: (pk, data, index) {
                      widget.controller.studentUserId = data["userId"];
                      widget.controller.studentName = Uri.decodeComponent(
                          "${data["firstName"]} ${data["lastName"]}");
                      widget.onUpdate();
                    },
                    data: snapshot.data),
              ],
            );
          }),
    ]);
  }
}

class _StudentWidget extends StatelessWidget {
  // members of MyWidget
  final String studentName, studentEmail, studentDateLastLogin;
  final int studentUserId;
  final void Function(int studentUserId) onPressed;

  // constructor
  const _StudentWidget({
    Key? key,
    required this.studentName,
    required this.studentEmail,
    required this.studentDateLastLogin,
    required this.studentUserId,
    required this.onPressed,
  }) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
          onTap: () {
            onPressed(studentUserId);
          },
          child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: scholarity_color.borderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Icon(Icons.person_rounded,
                      size: 30, color: scholarity_color.darkGrey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ScholarityTextH2B(studentName),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: ScholarityTextP(studentEmail)),
                  const SizedBox(width: 10),
                  Expanded(
                      child:
                          ScholarityTextP(parseSqlDate(studentDateLastLogin))),
                ],
              ))),
    );
  }
}

const Map<String, String> monthHash = {
  "01": "January",
  "02": "February",
  "03": "March",
  "04": "April",
  "05": "May",
  "06": "June",
  "07": "July",
  "08": "August",
  "09": "September",
  "10": "October",
  "11": "November",
  "12": "December",
};

String parseSqlDate(String date) {
  List<String> dateSplit = date.split("-");
  String year = dateSplit[0];
  String month = monthHash[dateSplit[1]]!;
  String day = dateSplit[2].substring(0, 2);
  return "$month $day, $year";
}
