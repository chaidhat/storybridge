import 'dart:collection';

import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/error_service.dart' as error_service;

Map<int, bool> courseIdToHasCongratulated = {};

abstract class CourseNavigationFrontPageElement {
  void onUpdateFrontPage(bool isFrontPage);
}

abstract class CourseNavigationElement {
  void onNewData(CourseData? courseData);
  void onLoad();
}

Queue<CourseNavigationElement> _hierarchyStack = Queue(),
    _viewerStack = Queue();
List<CourseNavigationFrontPageElement> _frontPageElements = [];

CourseNavigationElement? _hierarchy, _viewer;
int? _courseId;
int? _organizationId;
bool _isAdmin = false;
CourseData? _courseData;

bool _updateFrontPagers = false;
void setCourseId(int courseId, int organizationId, bool isAdmin) async {
  _courseId = courseId;
  _organizationId = organizationId;
  _isAdmin = isAdmin;
  await _loadCourseData();
  goToFrontPage();
  //reloadAll();
  _updateFrontPagers = false;
}

// this is like setCourseId
void setStateForAudit(
    int auditTemplateId, int organizationId, bool isAdmin) async {
  _courseId = auditTemplateId;
  _organizationId = organizationId;
  _isAdmin = isAdmin;
  await _loadAuditData();
  //reloadAll();
  _updateFrontPagers = false;
}

void registerFrontPageElement(CourseNavigationFrontPageElement element) async {
  _frontPageElements.add(element);
  _updateFrontPagers = true;

  // wait until course data is init
  while (_courseData == null) {
    await Future.delayed(const Duration(milliseconds: 10));
  }
  reloadAll();
  _updateFrontPagers = false;
}

void deregisterFrontPageElement(CourseNavigationFrontPageElement element) {
  _frontPageElements.remove(element);
}

void registerHierarchy(CourseNavigationElement hierarchy) async {
  _hierarchyStack.addLast(hierarchy);
  _hierarchy = hierarchy;

  // wait until course data is init
  while (_courseData == null) {
    await Future.delayed(const Duration(milliseconds: 10));
  }
  _hierarchy?.onNewData(_courseData!);
}

void registerViewer(CourseNavigationElement viewer) async {
  _viewerStack.addLast(viewer);
  _viewer = viewer;

  // wait until course data is init
  while (_courseData == null) {
    await Future.delayed(const Duration(milliseconds: 10));
  }
  _viewer?.onNewData(_courseData!);
}

void deregisterHierarchy() {
  _hierarchyStack.removeLast();
  if (_hierarchyStack.isNotEmpty) {
    _hierarchy = _hierarchyStack.last;
  } else {
    _hierarchy = null;
  }
}

void deregisterViewer() {
  _viewerStack.removeLast();
  if (_viewerStack.isNotEmpty) {
    _viewer = _viewerStack.last;
  } else {
    _viewer = null;
  }
}

void goToFrontPage() {
  int firstPageElementId =
      _courseData!.courseHierarchy[0].courseElements[0].courseElementId;
  goToPage(firstPageElementId);
}

bool _wasFrontPage = false;
void goToPage(int courseElementId) {
  for (int i = 0; i < _courseData!.courseHierarchy.length; i++) {
    for (int j = 0;
        j < _courseData!.courseHierarchy[i].courseElements.length;
        j++) {
      if (_courseData!.courseHierarchy[i].courseElements[j].courseElementId ==
          courseElementId) {
        // found it
        _courseData!.selectedCourseSectionNo = i;
        _courseData!.selectedCourseElementNo = j;
        reloadAll();
        return;
      }
    }
  }
}

Future<void> reloadHierarchy() async {
  await _loadCourseData();
  if (_hierarchy != null) {
    _hierarchy!.onNewData(_courseData!);
  }
}

void reloadAll() {
  if (_hierarchy != null) {
    _hierarchy!.onNewData(_courseData!);
  }
  if (_viewer != null) {
    _viewer!.onNewData(_courseData!);
  }

  bool isFrontPage = _courseData!.selectedCourseElementNo == 0 &&
      _courseData!.selectedCourseSectionNo == 0;

  if (_wasFrontPage != isFrontPage || _updateFrontPagers) {
    for (CourseNavigationFrontPageElement element in _frontPageElements) {
      element.onUpdateFrontPage(isFrontPage);
    }
  }
  _wasFrontPage = isFrontPage;
}

void _reloadHierarchy() {
  if (_hierarchy != null) {
    _hierarchy!.onNewData(_courseData!);
  }
}

Future<void> addCourseSection() async {
  await networking_api_service.createCourseSection(courseId: _courseId!);
  await _loadCourseData();
  _reloadHierarchy();
}

Future<void> renameCourseSection(
    {required int courseSectionId, required String newName}) async {
  //_hierarchy!.putData(null);
  await networking_api_service.changeCourseSection(
      courseSectionId: courseSectionId, courseSectionName: newName);
  await _loadCourseData();
  _reloadHierarchy();
}

Future<void> removeCourseSection({required int courseSectionId}) async {
  await networking_api_service.removeCourseSection(
      courseSectionId: courseSectionId);

  // if the element is currently selected, go to front page.
  if (_courseData!.getSelectedCourseSection().courseSectionId ==
      courseSectionId) {
    _courseData!.selectedCourseSectionNo = 0;
    _courseData!.selectedCourseElementNo = 0;
  }

  await _loadCourseData();
  _reloadHierarchy();
}

Future<void> addCourseElement({required int courseSectionId}) async {
  await networking_api_service.createReadingPage(
      courseSectionId: courseSectionId);
  await _loadCourseData();

  // go to that new element (last course element of that course section)
  for (int i = 0; i < _courseData!.courseHierarchy.length; i++) {
    if (_courseData!.courseHierarchy[i].courseSectionId == courseSectionId) {
      _courseData!.selectedCourseSectionNo = i;
      _courseData!.selectedCourseElementNo =
          _courseData!.courseHierarchy[i].courseElements.length - 1;
    }
  }
  reloadAll();
}

Future<void> renameCourseElement(
    {required int courseElementId, required String newName}) async {
  await networking_api_service.changeCourseElementName(
      courseElementId: courseElementId, courseElementName: newName);
  await _loadCourseData();
  _hierarchy!.onNewData(_courseData!);
}

Future<void> removeCourseElement({required int courseElementId}) async {
  await networking_api_service.removeCourseElement(
      courseElementId: courseElementId);

  // if the element is currently selected, go to front page.
  if (_courseData!.getSelectedCourseElement().courseElementId ==
      courseElementId) {
    _courseData!.selectedCourseSectionNo = 0;
    _courseData!.selectedCourseElementNo = 0;
  }

  await _loadCourseData();
  _reloadHierarchy();
}

void _checkIfDone(Map<String, dynamic> data, int courseId) {
  if (courseIdToHasCongratulated[courseId] ?? false) return;
  var courseSections = data["data"];
  bool isPassed = true;
  bool areThereEvenAnyAssessments = false;
  for (int i = 0; i < courseSections.length; i++) {
    for (int j = 0; j < courseSections[i]["children"].length; j++) {
      if (courseSections[i]["children"][j]["isLocked"]) {
        isPassed = false;
        areThereEvenAnyAssessments = true;
      } else {
        areThereEvenAnyAssessments = true;
      }
    }
  }
  if (!_isAdmin && isPassed && areThereEvenAnyAssessments) {
    courseIdToHasCongratulated[courseId] = true;
    error_service.alert(error_service.Alert(
        title: "Congratulations!",
        description:
            "You have finished the course. Please click the 'grades' tab to get your certificate.",
        buttonName: "OK",
        callback: (_) async {}));
  }
}

Future<void> _loadCourseData() async {
  // request server for course hierachy (courseElements and courseSections in JSON)
  Map<String, dynamic> response = await networking_api_service
      .getCourseHierarchy(courseId: _courseId!, calculateLocks: !_isAdmin);

  _checkIfDone(response, _courseId!);

  List<CourseSection>? courseHierarchy = [];

  // parse response JSON
  for (int i = 0; i < response["data"].length; i++) {
    CourseSection courseSection = CourseSection();
    var courseSectionJson = response["data"][i];
    courseSection.courseSectionName = courseSectionJson["courseSectionName"];
    courseSection.courseSectionId = courseSectionJson["courseSectionId"];

    for (int j = 0; j < response["data"][i]["children"].length; j++) {
      CourseElement courseElement = CourseElement();
      var courseElementJson = response["data"][i]["children"][j];
      courseElement.courseElementId = courseElementJson["courseElementId"];
      courseElement.courseElementName = courseElementJson["courseElementName"];
      courseElement.courseElementType = courseElementJson["courseElementType"];
      if (courseElementJson["isLocked"] != null) {
        courseElement.isLocked = courseElementJson["isLocked"];
      }

      courseSection.courseElements.add(courseElement);
    }
    courseHierarchy.add(courseSection);
  }

  // set the courseData
  _courseData = CourseData(
      courseId: _courseId!,
      organizationId: _organizationId!,
      selectedCourseElementNo: _courseData?.selectedCourseElementNo ?? 0,
      selectedCourseSectionNo: _courseData?.selectedCourseSectionNo ?? 0,
      courseHierarchy: courseHierarchy);
}

Future<void> _loadAuditData() async {
  CourseElement ce = CourseElement();
  ce.courseElementName = "";
  CourseSection cs = CourseSection();
  cs.courseElements.add(ce);
  List<CourseSection>? courseHierarchy = [cs];

  // set the courseData
  _courseData = CourseData(
      courseId: _courseId!,
      organizationId: _organizationId!,
      selectedCourseElementNo: 0,
      selectedCourseSectionNo: 0,
      courseHierarchy: courseHierarchy);
}

class CourseSection {
  String courseSectionName = "";
  int courseSectionId = 0;
  List<CourseElement> courseElements = [];
}

class CourseElement {
  String courseElementName = "";
  int courseElementId = 0;
  int courseElementType = 0;
  bool isLocked = false;
}

class CourseData {
  List<CourseSection> courseHierarchy;
  int courseId;
  int organizationId;
  int selectedCourseSectionNo, selectedCourseElementNo;

  CourseSection getSelectedCourseSection() {
    return courseHierarchy[selectedCourseSectionNo];
  }

  CourseElement getSelectedCourseElement() {
    return courseHierarchy[selectedCourseSectionNo]
        .courseElements[selectedCourseElementNo];
  }

  CourseData({
    required this.courseId,
    required this.organizationId,
    required this.selectedCourseElementNo,
    required this.selectedCourseSectionNo,
    required this.courseHierarchy,
  });
}
