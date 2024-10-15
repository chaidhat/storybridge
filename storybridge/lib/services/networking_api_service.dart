import 'package:mooc/services/networking_service.dart' as networking_service;
import 'package:mooc/services/auth_service.dart' as auth_service;

const String notLoggedInToken = "-";

String getToken() {
  auth_service.Token? token = auth_service.globalUser.token;
  if (token != null) {
    return token.token;
  } else {
    return notLoggedInToken;
  }
}

String _getAdminToken() {
  auth_service.Token? token = auth_service.getAdminToken();
  if (token != null) {
    return token.token;
  } else {
    return notLoggedInToken;
  }
}

Future<void> createVideoPage({required int courseSectionId}) async {
  await _createCourseElement(
      courseSectionId: courseSectionId,
      courseElementType: 0,
      courseElementName: "Untitled Video",
      data: '{"widgetType":"column", "children":[]}');
}

Future<void> createReadingPage({required int courseSectionId}) async {
  await _createCourseElement(
      courseSectionId: courseSectionId,
      courseElementType: 1,
      courseElementName: "Untitled Page",
      data: '{"widgetType":"column", "children":[]}');
}

Future<void> createQuizPage({required int courseSectionId}) async {
  await _createCourseElement(
      courseSectionId: courseSectionId,
      courseElementType: 2,
      courseElementName: "Untitled Quiz",
      data: '{"widgetType":"column", "children":[]}');
}

Future<void> _createCourseElement(
    {required int courseSectionId,
    required int courseElementType,
    required String courseElementName,
    required String data}) async {
  String token = getToken();

  await networking_service.serverGet("createCourseElement", {
    "token": token,
    "courseSectionId": courseSectionId.toString(),
    "courseElementName": courseElementName,
    "courseElementDescription": "Click here to add a description!",
    "courseElementType": courseElementType.toString(),
    "data": data
  });
}

Future<Map<String, dynamic>> getCourse({required int courseId}) async {
  String token = getToken();

  Map<String, dynamic> response =
      await networking_service.serverGet("getCourse", {
    "token": token,
    "courseId": courseId.toString(),
  });
  return response;
}

Future<void> setOrganizationName(
    {required int organizationId, required String organizationName}) async {
  String token = getToken();
  await networking_service.serverGet("changeOrganizationOptions", {
    "token": token,
    "organizationId": organizationId.toString(),
    "organizationName": organizationName,
  });
}

Future<void> setOrganizationEmail(
    {required int organizationId, required String email}) async {
  String token = getToken();
  await networking_service.serverGet("changeOrganizationOptions", {
    "token": token,
    "organizationId": organizationId.toString(),
    "email": email,
  });
}

Future<void> setOrganizationProfilePictureImageId(
    {required int organizationId, required int profilePictureImageId}) async {
  String token = getToken();
  await networking_service.serverGet("changeOrganizationOptions", {
    "token": token,
    "organizationId": organizationId.toString(),
    "profilePictureImageId": profilePictureImageId.toString(),
  });
}

Future<void> setOrganizationExtraUserDataFields(
    {required int organizationId, required String eudFields}) async {
  String token = getToken();
  await networking_service.serverGet("changeOrganizationOptions", {
    "token": token,
    "organizationId": organizationId.toString(),
    "extraUserDataFields": eudFields,
  });
}

Future<void> setProfilePictureImageId(
    {required int userId, required int profilePictureImageId}) async {
  String token = getToken();
  await networking_service.serverGet("setProfilePictureImageId", {
    "token": token,
    "userId": userId.toString(),
    "profilePictureImageId": profilePictureImageId.toString(),
  });
}

Future<void> setCourseName(
    {required int courseId, required String courseName}) async {
  String token = getToken();
  await networking_service.serverGet("changeCourseOptions", {
    "token": token,
    "courseId": courseId.toString(),
    "courseName": courseName,
  });
}

Future<void> setCourseLiveness(
    {required int courseId, required bool isLive}) async {
  String token = getToken();
  await networking_service.serverGet("changeCourseOptions", {
    "token": token,
    "courseId": courseId.toString(),
    "isLive": isLive.toString(),
  });
}

Future<Map<String, dynamic>> getCourseHierarchy(
    {required int courseId, required bool calculateLocks}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getCourseHierarchy", {
    "token": token,
    "courseId": courseId.toString(),
    "calculateLocks": calculateLocks.toString(),
  });
  return response;
}

Future<int> createCourse({required int organizationId}) async {
  String token = getToken();

  Map<String, dynamic> response =
      await networking_service.serverGet("createCourse", {
    "token": token,
    "organizationId": organizationId.toString(),
    "courseName": "Untitled",
  });
  int courseId = response["courseId"];

  return courseId;
}

Future<void> createCourseSection({required int courseId}) async {
  String token = getToken();

  await networking_service.serverGet("createCourseSection", {
    "token": token,
    "courseId": courseId.toString(),
    "courseSectionName": "New Course Section",
  });
}

Future<void> changeCourseElementName({
  required int courseElementId,
  required String courseElementName,
}) async {
  String token = getToken();

  await networking_service.serverGet("changeCourseElementName", {
    "token": token,
    "courseElementId": courseElementId.toString(),
    "courseElementName": courseElementName,
    "courseElementDescription": "",
  });
}

Future<void> changeCourseElementData({
  required int courseElementId,
  required String data,
}) async {
  String token = getToken();

  await networking_service.serverGet(
      "changeCourseElementData",
      {
        "token": token,
        "courseElementId": courseElementId.toString(),
        "data": data,
      },
      ignoreErrors: false);
}

Future<void> removeCourseElement({required int courseElementId}) async {
  String token = getToken();

  await networking_service.serverGet("removeCourseElement", {
    "token": token,
    "courseElementId": courseElementId.toString(),
  });
}

Future<void> changeCourseSection(
    {required int courseSectionId, required String courseSectionName}) async {
  String token = getToken();

  await networking_service.serverGet("changeCourseSection", {
    "token": token,
    "courseSectionId": courseSectionId.toString(),
    "courseSectionName": courseSectionName,
  });
}

Future<void> removeCourseSection({required int courseSectionId}) async {
  String token = getToken();

  await networking_service.serverGet("removeCourseSection", {
    "token": token,
    "courseSectionId": courseSectionId.toString(),
  });
}

Future<Map<String, dynamic>> getOrganization(
    {required int organizationId}) async {
  String token = getToken();

  Map<String, dynamic> response =
      await networking_service.serverGet("getOrganization", {
    "token": token,
    "organizationId": organizationId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getCourses({required int organizationId}) async {
  String token = getToken();

  Map<String, dynamic> response2 =
      await networking_service.serverGet("getCourses", {
    "token": token,
    "organizationId": organizationId.toString(),
  });
  return response2;
}

Future<Map<String, dynamic>> createOrganization(
    {required String organizationName}) async {
  String token = getToken();

  Map<String, dynamic> response = await networking_service.serverGet(
      "createOrganization",
      {"token": token, "organizationName": organizationName});
  return response;
}

Future<void> removeCourse({required int courseId}) async {
  String token = getToken();

  await networking_service.serverGet("removeCourse", {
    "token": token,
    "courseId": courseId.toString(),
  });
}

Future<Map<String, dynamic>> getCourseElement(
    {required int courseElementId}) async {
  String token = getToken();

  Map<String, dynamic> response2 =
      await networking_service.serverGet("getCourseElement", {
    "token": token,
    "courseElementId": courseElementId.toString(),
  });
  return response2;
}

Future<Map<String, dynamic>> getVideo({required int videoId}) async {
  String token = getToken();

  Map<String, dynamic> response =
      await networking_service.serverGet("getVideo", {
    "token": token,
    "videoId": videoId.toString(),
  });
  return response;
}

Future<int> createVideo(
    {required int courseId, required int courseElementId}) async {
  String token = getToken();

  Map<String, dynamic> response =
      await networking_service.serverGet("createVideo", {
    "token": token,
    "courseId": courseId.toString(),
    "courseElementId": courseElementId.toString(),
  });
  return response["videoId"];
}

Future<Map<String, dynamic>> getImage({required int imageId}) async {
  String token = getToken();

  Map<String, dynamic> response =
      await networking_service.serverGet("getImage", {
    "token": token,
    "imageId": imageId.toString(),
  });
  return response;
}

Future<int> createImage(
    {required int courseId,
    required int courseElementId,
    required int auditTaskId}) async {
  String token = getToken();

  Map<String, dynamic> response =
      await networking_service.serverGet("createImage", {
    "token": token,
    "courseId": courseId.toString(),
    "courseElementId": courseElementId.toString(),
    "auditTaskId": auditTaskId.toString(),
  });
  return response["imageId"];
}

Future<int> createImageForUser({required int userId}) async {
  String token = getToken();

  Map<String, dynamic> response =
      await networking_service.serverGet("createImageForUser", {
    "token": token,
    "userId": userId.toString(),
  });
  return response["imageId"];
}

Future<Map<String, dynamic>> getOrganizations() async {
  String token = getToken();

  Map<String, dynamic> response =
      await networking_service.serverGet("getOrganizations", {
    "token": token,
  });
  return response;
}

Future<void> subscribeToCourse({required int courseId}) async {
  String token = getToken();

  await networking_service.serverGet("subscribeToCourse", {
    "token": token,
    "courseId": courseId.toString(),
  });
  return;
}

Future<Map<String, dynamic>> getAssessment({required String auid}) async {
  String token = getToken();

  Map<String, dynamic> response =
      await networking_service.serverGet("getAssessment", {
    "token": token,
    "auid": auid,
  });
  return response;
}

Future<void> updateAssessment(
    {required String auid,
    required int weighting,
    required int passingPercentage,
    required String assessmentData}) async {
  String token = getToken();

  await networking_service.serverGet("updateAssessment", {
    "token": token,
    "auid": auid,
    "weighting": weighting.toString(),
    "passingPercentage": passingPercentage.toString(),
    "assessmentData": assessmentData,
  });
  return;
}

Future<Map<String, dynamic>> createAssessment(
    {required int courseElementId,
    required int weighting,
    required int passingPercentage,
    required String assessmentData}) async {
  String token = getToken();

  Map<String, dynamic> response =
      await networking_service.serverGet("createAssessment", {
    "token": token,
    "courseElementId": courseElementId.toString(),
    "weighting": weighting.toString(),
    "passingPercentage": passingPercentage.toString(),
    "assessmentData": assessmentData,
  });
  return response;
}

Future<void> removeAssessment({required String auid}) async {
  String token = getToken();

  await networking_service.serverGet("removeAssessment", {
    "token": token,
    "auid": auid,
  });
  return;
}

Future<Map<String, dynamic>> getAssessmentTaskFromAssessment(
    {required String auid}) async {
  String token = getToken();

  Map<String, dynamic> response =
      await networking_service.serverGet("getAssessmentTaskFromAssessment", {
    "token": token,
    "auid": auid,
  });
  return response;
}

Future<void> updateAssessmentTaskFromAssessment(
    {required String auid, required String data}) async {
  String token = getToken();

  await networking_service.serverGet("updateAssessmentTaskFromAssessment", {
    "token": token,
    "auid": auid,
    "data": data,
  });
  return;
}

Future<Map<String, dynamic>> createAssessmentTaskFromAssessment(
    {required String auid, required String data}) async {
  String token = getToken();

  Map<String, dynamic> response =
      await networking_service.serverGet("createAssessmentTaskFromAssessment", {
    "token": token,
    "auid": auid,
    "data": data,
  });
  return response;
}

Future<Map<String, dynamic>> getAllAssessmentsForCourse(
    {required int courseId, required bool omitStudentGrades}) async {
  String token = getToken();

  Map<String, dynamic> response =
      await networking_service.serverGet("getAllAssessmentsForCourse", {
    "token": token,
    "courseId": courseId.toString(),
    "omitStudentGrades": omitStudentGrades ? "true" : "false",
  });
  return response;
}

Future<Map<String, dynamic>> getAllStudentsForCourse(
    {required int courseId}) async {
  String token = getToken();

  Map<String, dynamic> response =
      await networking_service.serverGet("getAllStudentsForCourse", {
    "token": token,
    "courseId": courseId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getAssessmentStatsForStudentForCourse(
    {required int courseId, required int studentUserId}) async {
  String token = getToken();

  Map<String, dynamic> response = await networking_service
      .serverGet("getAssessmentStatsForStudentForCourse", {
    "token": token,
    "courseId": courseId.toString(),
    "studentUserId": studentUserId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getAssessmentStatsForThisStudentForCourse(
    {required int courseId}) async {
  String token = getToken();

  Map<String, dynamic> response = await networking_service
      .serverGet("getAssessmentStatsForThisStudentForCourse", {
    "token": token,
    "courseId": courseId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getCheckoutSessionUrl(
    {required int organizationId, required int plan}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getCheckoutSessionUrl", {
    "token": token,
    "organizationId": organizationId.toString(),
    "plan": plan.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getPortalSessionUrl(
    {required int organizationId}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getPortalSessionUrl", {
    "token": token,
    "organizationId": organizationId.toString(),
  });
  return response;
}

Future<void> reportAnalyticsEvent(
    {required int analyticsEventType,
    // TODO: this should be int
    required String analyticsEventSubtype}) async {
  await networking_service.serverGet("reportAnalyticsEvent", {
    "analyticsEventType": analyticsEventType.toString(),
    "analyticsEventSubtype": analyticsEventSubtype.toString(),
  });
}

Future<Map<String, dynamic>> getAiCourseElementSummary(
    {required int courseElementId}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getAiCourseElementSummary", {
    "token": token,
    "courseElementId": courseElementId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> askAiCourseElementQuestion(
    {required String question, required int courseElementId}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("askAiCourseElementQuestion", {
    "token": token,
    "question": question,
    "courseElementId": courseElementId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getCourseSalesSettings(
    {required int courseId}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getCourseSalesSettings", {
    "token": token,
    "courseId": courseId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> changeCourseSalesSettings(
    {required int courseId,
    int? coursePrice,
    String? coursePriceCurrencyCode,
    String? courseProductName,
    String? courseProductDescription}) async {
  String token = getToken();
  Map<String, String> request = {
    "token": token,
    "courseId": courseId.toString()
  };
  if (coursePrice != null) {
    request["coursePrice"] = coursePrice.toString();
  }
  if (coursePriceCurrencyCode != null) {
    request["coursePriceCurrencyCode"] = coursePriceCurrencyCode;
  }
  if (courseProductName != null) {
    request["courseProductName"] = courseProductName;
  }
  if (courseProductDescription != null) {
    request["courseProductDescription"] = courseProductDescription;
  }
  Map<String, dynamic> response = await networking_service
      .serverGet("changeCourseSalesSettings", request, ignoreErrors: false);
  return response;
}

Future<Map<String, dynamic>> getCourseSalesHistory(
    {required int courseId}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getCourseSalesHistory", {
    "token": token,
    "courseId": courseId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getOrganizationBalance(
    {required int organizationId}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getOrganizationBalance", {
    "token": token,
    "organizationId": organizationId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getWithdrawals(
    {required int organizationId}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getWithdrawals", {
    "token": token,
    "organizationId": organizationId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> createWithdrawal(
    {required int organizationId, required String withdrawalData}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("createWithdrawal", {
    "token": token,
    "organizationId": organizationId.toString(),
    "withdrawalData": withdrawalData,
  });
  return response;
}

Future<Map<String, dynamic>> adminPing() async {
  String token = _getAdminToken();
  Map<String, dynamic> response = await networking_service.serverGet(
      "adminPing",
      {
        "token": token,
      },
      ignoreErrors: false);
  return response;
}

Future<Map<String, dynamic>> adminGetDb() async {
  String token = _getAdminToken();
  Map<String, dynamic> response = await networking_service.serverGet(
      "adminGetDb",
      {
        "token": token,
      },
      ignoreErrors: false);
  return response;
}

Future<Map<String, dynamic>> adminCallDb(
    {required String query, required String dbKey}) async {
  String token = _getAdminToken();
  Map<String, dynamic> response = await networking_service.serverGet(
      "adminCallDb",
      {
        "token": token,
        "query": query,
        "dbKey": dbKey,
      },
      ignoreErrors: false);
  return response;
}

Future<Map<String, dynamic>> createCertificateData(
    {required int courseId, required String certificateData}) async {
  String token = _getAdminToken();
  Map<String, dynamic> response = await networking_service.serverGet(
      "createCertificateData",
      {
        "token": token,
        "courseId": courseId.toString(),
        "data": certificateData,
      },
      ignoreErrors: false);
  return response;
}

Future<Map<String, dynamic>> getCertificateData({required int courseId}) async {
  String token = _getAdminToken();
  Map<String, dynamic> response = await networking_service.serverGet(
      "getCertificateData",
      {
        "token": token,
        "courseId": courseId.toString(),
      },
      ignoreErrors: false);
  return response;
}

Future<Map<String, dynamic>> updateCertificateData(
    {required int courseId, required String certificateData}) async {
  String token = _getAdminToken();
  Map<String, dynamic> response = await networking_service.serverGet(
      "updateCertificateData",
      {
        "token": token,
        "courseId": courseId.toString(),
        "data": certificateData
      },
      ignoreErrors: false);
  return response;
}

Future<Map<String, dynamic>> getFleetFlightplanFromUser({
  required int userId,
  required String timezone,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("fleet_getFleetFlightplanFromUser", {
    "token": token,
    "userId": userId.toString(),
    "timezone": timezone.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getFleetFlightplans({
  required int organizationId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("fleet_getFleetFlightplans", {
    "token": token,
    "organizationId": organizationId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> removeFleetFlightplan({
  required int fleetFlightplanId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("fleet_removeFleetFlightplan", {
    "token": token,
    "fleetFlightplanId": fleetFlightplanId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getFleetCars({
  required int organizationId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("fleet_getFleetCars", {
    "token": token,
    "organizationId": organizationId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getFleetCar({
  required int fleetCarId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("fleet_getFleetCar", {
    "token": token,
    "fleetCarId": fleetCarId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> createFleetCar({
  required int organizationId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("fleet_createFleetCar", {
    "token": token,
    "organizationId": organizationId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> changeFleetCar({
  required int fleetCarId,
  required int organizationId,
  required String licensePlate,
  required String model,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("fleet_changeFleetCar", {
    "token": token,
    "fleetCarId": fleetCarId.toString(),
    "organizationId": organizationId.toString(),
    "licensePlate": licensePlate.toString(),
    "model": model.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> removeFleetCar({
  required int fleetCarId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("fleet_removeFleetCar", {
    "token": token,
    "fleetCarId": fleetCarId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> changeFleetUserData({
  required int fleetUserDataId,
  required int userId,
  required int fleetCompanyId,
  required String firstName,
  required String lastName,
  required String email,
  required String nickname,
  required String workplace,
  required String employeeId,
  required int fleetUserType,
}) async {
  String token = getToken();
  Map<String, dynamic> response = await networking_service.serverGet(
    "fleet_changeFleetUserData",
    {
      "token": token,
      "fleetUserDataId": fleetUserDataId.toString(),
      "userId": userId.toString(),
      "fleetCompanyId": fleetCompanyId.toString(),
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "nickname": nickname,
      "workplace": workplace,
      "employeeId": employeeId,
      "fleetUserType": fleetUserType.toString(),
    },
  );
  return response;
}

Future<Map<String, dynamic>> removeFleetUserData({
  required int fleetUserDataId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("fleet_removeFleetUserData", {
    "token": token,
    "fleetUserDataId": fleetUserDataId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getFleetCompany({
  required int fleetCompanyId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("fleet_getFleetCompany", {
    "token": token,
    "fleetCompanyId": fleetCompanyId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> createFleetCompany({
  required String organizationName,
  required String email,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("fleet_createFleetCompany", {
    "token": token,
    "organizationName": organizationName.toString(),
    "email": email.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> changeFleetCompany({
  required int fleetCompanyId,
  required String organizationName,
  required String email,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("fleet_changeFleetCompany", {
    "token": token,
    "fleetCompanyId": fleetCompanyId.toString(),
    "organizationName": organizationName.toString(),
    "email": email.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> removeFleetCompany({
  required int fleetCompanyId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("fleet_removeFleetCompany", {
    "token": token,
    "fleetCompanyId": fleetCompanyId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getUser({
  required int userId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getUser", {
    "token": token,
    "userId": userId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> changeUser({
  required int userId,
  required String username,
  required String email,
  required String firstName,
  required String lastName,
  required String eud,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("changeUser", {
    "token": token,
    "userId": userId.toString(),
    "username": username.toString(),
    "email": email.toString(),
    "firstName": firstName.toString(),
    "lastName": lastName.toString(),
    "eud": eud.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> changeUserPassword({
  required String oldPassword,
  required String newPassword,
}) async {
  String token = getToken();
  Map<String, dynamic> response = await networking_service.serverGet(
      "changeUserPassword",
      {
        "token": token,
        "oldPassword": oldPassword.toString(),
        "newPassword": newPassword.toString(),
      },
      ignoreErrors: false);
  return response;
}

Future<Map<String, dynamic>> getUserFromOrganizationId({
  required int organizationId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getUserFromOrganizationId", {
    "token": token,
    "organizationId": organizationId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getOrganizationPrivilegesForOrganization({
  required int organizationId,
}) async {
  String token = getToken();
  Map<String, dynamic> response = await networking_service
      .serverGet("getOrganizationPrivilegesForOrganization", {
    "token": token,
    "organizationId": organizationId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> assignCoordinatorToCoordinatorGroup({
  required int userId,
  required int coordinatorGroupId,
}) async {
  String token = getToken();
  Map<String, dynamic> response = await networking_service
      .serverGet("assignCoordinatorToCoordinatorGroup", {
    "token": token,
    "userId": userId.toString(),
    "coordinatorGroupId": coordinatorGroupId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> deassignCoordinatorFromCoordinatorGroup({
  required int userId,
  required int coordinatorGroupId,
}) async {
  String token = getToken();
  Map<String, dynamic> response = await networking_service
      .serverGet("deassignCoordinatorFromCoordinatorGroup", {
    "token": token,
    "userId": userId.toString(),
    "coordinatorGroupId": coordinatorGroupId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getCoordinatorGroups({
  required int organizationId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getCoordinatorGroups", {
    "token": token,
    "organizationId": organizationId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> createCoordinatorGroup({
  required int organizationId,
  required String email,
  required String coordinatorGroupName,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("createCoordinatorGroup", {
    "token": token,
    "organizationId": organizationId.toString(),
    "email": email.toString(),
    "coordinatorGroupName": coordinatorGroupName.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> changeCoordinatorGroup({
  required int coordinatorGroupId,
  required String coordinatorGroupName,
  required String email,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("changeCoordinatorGroup", {
    "token": token,
    "coordinatorGroupId": coordinatorGroupId.toString(),
    "coordinatorGroupName": coordinatorGroupName.toString(),
    "email": email.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> removeCoordinatorGroup({
  required int coordinatorGroupId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("removeCoordinatorGroup", {
    "token": token,
    "coordinatorGroupId": coordinatorGroupId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> assignUserToCoordinatorGroup({
  required int userId,
  required int coordinatorGroupId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("assignUserToCoordinateGroup", {
    "token": token,
    "userId": userId.toString(),
    "coordinatorGroupId": coordinatorGroupId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> deassignUserFromCoordinatorGroup({
  required int userId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("deassignUserFromCoordinateGroup", {
    "token": token,
    "userId": userId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getCoordinatorPrivileges({
  required int organizationId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getCoordinatorPrivileges", {
    "token": token,
    "organizationId": organizationId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getUserFromCoordinatorGroupId({
  required int coordinatorGroupId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getUserFromCoordinatorGroupId", {
    "token": token,
    "coordinatorGroupId": coordinatorGroupId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getCourseFiles({
  required int courseId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getCourseFiles", {
    "token": token,
    "courseId": courseId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> markVideoTaskAsRead({
  required int videoId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("markVideoTaskAsRead", {
    "token": token,
    "videoId": videoId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> markVideoTaskAsUnread({
  required int videoId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("markVideoTaskAsUnread", {
    "token": token,
    "videoId": videoId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getIsVideoRead({
  required int videoId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getIsVideoRead", {
    "token": token,
    "videoId": videoId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> removeVideo({
  required int videoId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("removeVideo", {
    "token": token,
    "videoId": videoId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> removeImage({
  required int imageId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("removeImage", {
    "token": token,
    "imageId": imageId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getUserFiles({
  required int userId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getUserFiles", {
    "token": token,
    "userId": userId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getCourseAnalyticsStudents({
  required int courseId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getCourseAnalyticsStudents", {
    "token": token,
    "courseId": courseId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getAuditTemplates({
  required int organizationId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getAuditTemplates", {
    "token": token,
    "organizationId": organizationId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getAuditTemplate({
  required int auditTemplateId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getAuditTemplate", {
    "token": token,
    "auditTemplateId": auditTemplateId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> createAuditTemplate({
  required String auditTemplateName,
  required String auditTemplateDescription,
  required int organizationId,
  required String auditTemplateData,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("createAuditTemplate", {
    "token": token,
    "auditTemplateName": auditTemplateName.toString(),
    "auditTemplateDescription": auditTemplateDescription.toString(),
    "organizationId": organizationId.toString(),
    "auditTemplateData": auditTemplateData.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> removeAuditTemplate({
  required int auditTemplateId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("removeAuditTemplate", {
    "token": token,
    "auditTemplateId": auditTemplateId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getAuditTasks({
  required int organizationId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getAuditTasks", {
    "token": token,
    "organizationId": organizationId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getAuditTask({
  required int auditTaskId,
}) async {
  String token = getToken();
  Map<String, dynamic> response = await networking_service.serverGet(
      "getAuditTask",
      {
        "token": token,
        "auditTaskId": auditTaskId.toString(),
      },
      ignoreErrors: false);
  return response;
}

Future<Map<String, dynamic>> createAuditTask({
  required String auditTaskName,
  required String auditTaskDescription,
  required int auditTemplateId,
  required String auditTaskData,
  required String status,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("createAuditTask", {
    "token": token,
    "auditTaskName": auditTaskName.toString(),
    "auditTaskDescription": auditTaskDescription.toString(),
    "auditTemplateId": auditTemplateId.toString(),
    "auditTaskData": auditTaskData.toString(),
    "status": status.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> changeAuditTask({
  required int auditTaskId,
  required String auditTaskName,
  required String auditTaskDescription,
  required String auditTaskData,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("changeAuditTask", {
    "token": token,
    "auditTaskId": auditTaskId.toString(),
    "auditTaskName": auditTaskName.toString(),
    "auditTaskDescription": auditTaskDescription.toString(),
    "auditTaskData": auditTaskData.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> removeAuditTask({
  required int auditTaskId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("removeAuditTask", {
    "token": token,
    "auditTaskId": auditTaskId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> logoutUser() async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("logoutUser", {
    "token": token,
  });
  return response;
}

Future<Map<String, dynamic>> getAuditTaskQuestion({
  required String quid,
  required int auditTaskId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getAuditTaskQuestion", {
    "token": token,
    "quid": quid.toString(),
    "auditTaskId": auditTaskId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> setAuditTaskQuestion({
  required String quid,
  required int auditTaskId,
  required String data,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("setAuditTaskQuestion", {
    "token": token,
    "quid": quid.toString(),
    "auditTaskId": auditTaskId.toString(),
    "data": data.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getAuditTemplateQuestions({
  required int auditTemplateId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getAuditTemplateQuestions", {
    "token": token,
    "auditTemplateId": auditTemplateId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> executeFormula({
  required String formula,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("executeFormula", {
    "token": token,
    "formula": formula.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> findAllPossibleFuncsForValue({
  required String valueType,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("findAllPossibleFuncsForValue", {
    "token": token,
    "valueType": valueType.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> verifyFormula({
  required String formula,
}) async {
  String token = getToken();
  Map<String, dynamic> response = await networking_service.serverGet(
      "verifyFormula",
      {
        "token": token,
        "formula": formula.toString(),
      },
      ignoreErrors: false);
  return response;
}

Future<Map<String, dynamic>> getAuditTemplateFiles({
  required int auditTemplateId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getAuditTemplateFiles", {
    "token": token,
    "auditTemplateId": auditTemplateId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getCourseSubscriptionsForUserId({
  required int userId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getCourseSubscriptionsForUserId", {
    "token": token,
    "userId": userId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getAuditPrivilegesForUserId({
  required int userId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getAuditPrivilegesForUserId", {
    "token": token,
    "userId": userId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getAuditPrivilegesForAuditTask({
  required int auditTaskId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getAuditPrivilegesForAuditTask", {
    "token": token,
    "auditTaskId": auditTaskId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> removeAuditPrivilege({
  required int auditPrivilegeId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("removeAuditPrivilege", {
    "token": token,
    "auditPrivilegeId": auditPrivilegeId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getFleetDrivers({
  required int organizationId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getFleetDrivers", {
    "token": token,
    "organizationId": organizationId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> createFleetDriver({
  required int userId,
  required int organizationId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("createFleetDriver", {
    "token": token,
    "userId": userId.toString(),
    "organizationId": organizationId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> removeFleetDriver({
  required int fleetDriverId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("removeFleetDriver", {
    "token": token,
    "fleetDriverId": fleetDriverId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> isUserFleetDriver({
  required int organizationId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("isUserFleetDriver", {
    "token": token,
    "organizationId": organizationId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getFleetLocations({
  required int organizationId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getFleetLocations", {
    "token": token,
    "organizationId": organizationId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> removeFleetLocation({
  required int fleetLocationId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("removeFleetLocation", {
    "token": token,
    "fleetLocationId": fleetLocationId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> removeAllFleetLocation({
  required int organizationId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("removeAllFleetLocation", {
    "token": token,
    "organizationId": organizationId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> createFleetLocation({
  required int organizationId,
  required String locationName,
  required String locationAddress,
  required double longitude,
  required double latitude,
  required String subdistrict,
  required String district,
  required String province,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("createFleetLocation", {
    "token": token,
    "organizationId": organizationId.toString(),
    "locationName": locationName.toString(),
    "locationAddress": locationAddress.toString(),
    "longitude": longitude.toString(),
    "latitude": latitude.toString(),
    "subdistrict": subdistrict.toString(),
    "district": district.toString(),
    "province": province.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> changeFleetLocation({
  required int fleetLocationId,
  required String locationName,
  required String locationAddress,
  required double longitude,
  required double latitude,
  required String subdistrict,
  required String district,
  required String province,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("changeFleetLocation", {
    "token": token,
    "fleetLocationId": fleetLocationId.toString(),
    "locationName": locationName.toString(),
    "locationAddress": locationAddress.toString(),
    "longitude": longitude.toString(),
    "latitude": latitude.toString(),
    "subdistrict": subdistrict.toString(),
    "district": district.toString(),
    "province": province.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> createFleetFlightplan({
  required int userId,
  required int organizationId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("fleet_createFleetFlightplan", {
    "token": token,
    "userId": userId.toString(),
    "organizationId": organizationId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getFleetFlightplanFromUserToday({
  required int userId,
  required String timezone,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getFleetFlightplanFromUserToday", {
    "token": token,
    "userId": userId.toString(),
    "timezone": timezone.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getFleetLocation({
  required int fleetLocationId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getFleetLocation", {
    "token": token,
    "fleetLocationId": fleetLocationId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> createFleetWaypoint({
  required int fleetCarId,
  required int fleetLocationId,
  required int fleetFlightplanId,
  required String remark,
  required int waypointOrder,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("createFleetWaypoint", {
    "token": token,
    "fleetCarId": fleetCarId.toString(),
    "fleetLocationId": fleetLocationId.toString(),
    "fleetFlightplanId": fleetFlightplanId.toString(),
    "remark": remark.toString(),
    "waypointOrder": waypointOrder.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> removeFleetWaypoint({
  required int fleetWaypointId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("removeFleetWaypoint", {
    "token": token,
    "fleetWaypointId": fleetWaypointId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getAllWaypointsForOrganization({
  required int organizationId,
  required DateTime searchDateBegin,
  required DateTime searchDateEnd,
  required String timezone,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getAllWaypointsForOrganization", {
    "token": token,
    "organizationId": organizationId.toString(),
    "searchDateBegin": searchDateBegin.toUtc().toString(),
    "searchDateEnd": searchDateEnd.toUtc().toString(),
    "timezone": timezone.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getTodayDrivers({
  required int organizationId,
  required String timezone,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getTodayDrivers", {
    "token": token,
    "organizationId": organizationId.toString(),
    "timezone": timezone.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> forecastWeather({
  required double lat,
  required double lon,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("forecastWeather", {
    "token": token,
    "lat": lat.toString(),
    "lon": lon.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> forecastWeatherForFleetLocation({
  required int fleetLocationId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("forecastWeatherForFleetLocation", {
    "token": token,
    "fleetLocationId": fleetLocationId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getTodayCars({
  required int organizationId,
  required String timezone,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getTodayCars", {
    "token": token,
    "organizationId": organizationId.toString(),
    "timezone": timezone.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> checkinAtLocation({
  required double myLat,
  required double myLon,
  required int fleetWaypointId,
}) async {
  String token = getToken();
  Map<String, dynamic> response = await networking_service.serverGet(
      "checkinAtLocation",
      {
        "token": token,
        "myLat": myLat.toString(),
        "myLon": myLon.toString(),
        "fleetWaypointId": fleetWaypointId.toString(),
      },
      ignoreErrors: false);
  return response;
}

Future<Map<String, dynamic>> getWorkflow({
  required int auditTemplateId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getWorkflow", {
    "token": token,
    "auditTemplateId": auditTemplateId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> createWorkflowNode({
  required int auditTemplateId,
  required int workflowNodeType,
  required String data,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("createWorkflowNode", {
    "token": token,
    "auditTemplateId": auditTemplateId.toString(),
    "workflowNodeType": workflowNodeType.toString(),
    "data": data.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> changeWorkflowNode({
  required int workflowNodeId,
  required String data,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("changeWorkflowNode", {
    "token": token,
    "workflowNodeId": workflowNodeId.toString(),
    "data": data.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> removeWorkflowNode({
  required int workflowNodeId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("removeWorkflowNode", {
    "token": token,
    "workflowNodeId": workflowNodeId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> createWorkflowConnection({
  required int auditTemplateId,
  required int sourceAuditWorkflowNodeId,
  required int sourceOutputNumber,
  required int sinkAuditWorkflowNodeId,
  required int sinkInputNumber,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("createWorkflowConnection", {
    "token": token,
    "auditTemplateId": auditTemplateId.toString(),
    "sourceAuditWorkflowNodeId": sourceAuditWorkflowNodeId.toString(),
    "sourceOutputNumber": sourceOutputNumber.toString(),
    "sinkAuditWorkflowNodeId": sinkAuditWorkflowNodeId.toString(),
    "sinkInputNumber": sinkInputNumber.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> removeWorkflowConnection({
  required int sourceAuditWorkflowNodeId,
  required int sinkAuditWorkflowNodeId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("removeWorkflowConnection", {
    "token": token,
    "sourceAuditWorkflowNodeId": sourceAuditWorkflowNodeId.toString(),
    "sinkAuditWorkflowNodeId": sinkAuditWorkflowNodeId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> submitAuditTask({
  required int auditTaskId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("submitAuditTask", {
    "token": token,
    "auditTaskId": auditTaskId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> approveAuditTask({
  required int auditTaskId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("approveAuditTask", {
    "token": token,
    "auditTaskId": auditTaskId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> rejectAuditTask({
  required int auditTaskId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("rejectAuditTask", {
    "token": token,
    "auditTaskId": auditTaskId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getLabelGroups({
  required int organizationId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getLabelGroups", {
    "token": token,
    "organizationId": organizationId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getLabels({
  required int labelGroupId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getLabels", {
    "token": token,
    "labelGroupId": labelGroupId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> createLabel({
  required int labelGroupId,
  required String color,
  required String labelName,
  required String labelDescription,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("createLabel", {
    "token": token,
    "labelGroupId": labelGroupId.toString(),
    "color": color.toString(),
    "labelName": labelName.toString(),
    "labelDescription": labelDescription.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> changeLabelGroup({
  required int labelGroupId,
  required String labelGroupName,
  required bool isMultichoiceAllowed,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("changeLabelGroup", {
    "token": token,
    "labelGroupId": labelGroupId.toString(),
    "labelGroupName": labelGroupName.toString(),
    "isMultichoiceAllowed": isMultichoiceAllowed.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> changeLabel({
  required int labelId,
  required String color,
  required String labelName,
  required String labelDescription,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("changeLabel", {
    "token": token,
    "labelId": labelId.toString(),
    "color": color.toString(),
    "labelName": labelName.toString(),
    "labelDescription": labelDescription.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> removeLabelGroup({
  required int labelGroupId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("removeLabelGroup", {
    "token": token,
    "labelGroupId": labelGroupId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> removeLabel({
  required int labelId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("removeLabel", {
    "token": token,
    "labelId": labelId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getLabelGroup({
  required int labelGroupId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getLabelGroup", {
    "token": token,
    "labelGroupId": labelGroupId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> changeAuditTemplate({
  required int auditTemplateId,
  required String auditTemplateName,
  required String auditTemplateDescription,
  required String auditTemplateData,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("changeAuditTemplate", {
    "token": token,
    "auditTemplateId": auditTemplateId.toString(),
    "auditTemplateName": auditTemplateName.toString(),
    "auditTemplateDescription": auditTemplateDescription.toString(),
    "auditTemplateData": auditTemplateData.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> createLabelGroup({
  required int organizationId,
  required String labelGroupName,
  required bool isMultichoiceAllowed,
  required bool canUserDelete,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("createLabelGroup", {
    "token": token,
    "organizationId": organizationId.toString(),
    "labelGroupName": labelGroupName.toString(),
    "isMultichoiceAllowed": isMultichoiceAllowed.toString(),
    "canUserDelete": canUserDelete.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> changeAuditTaskStatus({
  required int auditTaskId,
  required String status,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("changeAuditTaskStatus", {
    "token": token,
    "auditTaskId": auditTaskId.toString(),
    "status": status.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> createAuditPrivilege({
  required int userId,
  required int auditTaskId,
  required bool canEdit,
  required bool canComment,
  required int submitMode,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("createAuditPrivilege", {
    "token": token,
    "userId": userId.toString(),
    "auditTaskId": auditTaskId.toString(),
    "canEdit": canEdit.toString(),
    "canComment": canComment.toString(),
    "submitMode": submitMode.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> changeAuditPrivilege({
  required int auditPrivilegeId,
  required bool canEdit,
  required bool canComment,
  required int submitMode,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("changeAuditPrivilege", {
    "token": token,
    "auditPrivilegeId": auditPrivilegeId.toString(),
    "canEdit": canEdit.toString(),
    "canComment": canComment.toString(),
    "submitMode": submitMode.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> submitAuditPrivilege({
  required int auditTaskId,
  required String submitData,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("submitAuditPrivilege", {
    "token": token,
    "auditTaskId": auditTaskId.toString(),
    "submitData": submitData.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getAuditPrivilegeForUserAndAuditTask({
  required int auditTaskId,
}) async {
  String token = getToken();
  Map<String, dynamic> response = await networking_service
      .serverGet("getAuditPrivilegeForUserAndAuditTask", {
    "token": token,
    "auditTaskId": auditTaskId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getAuditTextQuestions({
  required int auditTextQuestionId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getAuditTextQuestions", {
    "token": token,
    "auditTextQuestionId": auditTextQuestionId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> createAuditTextQuestions({
  required int quid,
  required int auditTemplateId,
  required String question,
  required bool isLargeField,
  required bool isNumericalField,
  required String validiationRegex,
  required String answerHint,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("createAuditTextQuestions", {
    "token": token,
    "quid": quid.toString(),
    "auditTemplateId": auditTemplateId.toString(),
    "question": question.toString(),
    "isLargeField": isLargeField.toString(),
    "isNumericalField": isNumericalField.toString(),
    "validiationRegex": validiationRegex.toString(),
    "answerHint": answerHint.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> changeAuditTextQuestions({
  required int auditTextQuestionId,
  required int quid,
  required int auditTemplateId,
  required String question,
  required bool isLargeField,
  required bool isNumericalField,
  required String validiationRegex,
  required String answerHint,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("changeAuditTextQuestions", {
    "token": token,
    "auditTextQuestionId": auditTextQuestionId.toString(),
    "quid": quid.toString(),
    "auditTemplateId": auditTemplateId.toString(),
    "question": question.toString(),
    "isLargeField": isLargeField.toString(),
    "isNumericalField": isNumericalField.toString(),
    "validiationRegex": validiationRegex.toString(),
    "answerHint": answerHint.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getAuditMultichoiceQuestions({
  required int auditMultichoiceQuestionId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getAuditMultichoiceQuestions", {
    "token": token,
    "auditMultichoiceQuestionId": auditMultichoiceQuestionId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> createAuditMultichoiceQuestions({
  required int quid,
  required int auditTemplateId,
  required String question,
  required String dateSourceType,
  required int labelGroupId,
  required List<String> unlinkedAnswers,
  required bool unlinkedCanSelectMultiple,
  required bool hasOtherField,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("createAuditMultichoiceQuestions", {
    "token": token,
    "quid": quid.toString(),
    "auditTemplateId": auditTemplateId.toString(),
    "question": question.toString(),
    "dateSourceType": dateSourceType.toString(),
    "labelGroupId": labelGroupId.toString(),
    "unlinkedAnswers": unlinkedAnswers.toString(),
    "unlinkedCanSelectMultiple": unlinkedCanSelectMultiple.toString(),
    "hasOtherField": hasOtherField.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> changeAuditMultichoiceQuestions({
  required int auditMultichoiceQuestionId,
  required int quid,
  required int auditTemplateId,
  required String question,
  required String dateSourceType,
  required int labelGroupId,
  required List<String> unlinkedAnswers,
  required String unlinkedCanSelectMultiple,
  required bool hasOtherField,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("changeAuditMultichoiceQuestions", {
    "token": token,
    "auditMultichoiceQuestionId": auditMultichoiceQuestionId.toString(),
    "quid": quid.toString(),
    "auditTemplateId": auditTemplateId.toString(),
    "question": question.toString(),
    "dateSourceType": dateSourceType.toString(),
    "labelGroupId": labelGroupId.toString(),
    "unlinkedAnswers": unlinkedAnswers.toString(),
    "unlinkedCanSelectMultiple": unlinkedCanSelectMultiple.toString(),
    "hasOtherField": hasOtherField.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> removeAuditMultichoiceQuestions({
  required int auditMultichoiceQuestionId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("removeAuditMultichoiceQuestions", {
    "token": token,
    "auditMultichoiceQuestionId": auditMultichoiceQuestionId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getAuditDatetimeQuestions({
  required int auditDatetimeQuestionId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getAuditDatetimeQuestions", {
    "token": token,
    "auditDatetimeQuestionId": auditDatetimeQuestionId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> createAuditDatetimeQuestions({
  required int quid,
  required int auditTemplateId,
  required String question,
  required String datetimeMode,
  required String autofillMode,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("createAuditDatetimeQuestions", {
    "token": token,
    "quid": quid.toString(),
    "auditTemplateId": auditTemplateId.toString(),
    "question": question.toString(),
    "datetimeMode": datetimeMode.toString(),
    "autofillMode": autofillMode.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> changeAuditDatetimeQuestions({
  required int auditDatetimeQuestionId,
  required int quid,
  required int auditTemplateId,
  required String question,
  required String datetimeMode,
  required String autofillMode,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("changeAuditDatetimeQuestions", {
    "token": token,
    "auditDatetimeQuestionId": auditDatetimeQuestionId.toString(),
    "quid": quid.toString(),
    "auditTemplateId": auditTemplateId.toString(),
    "question": question.toString(),
    "datetimeMode": datetimeMode.toString(),
    "autofillMode": autofillMode.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> removeAuditDatetimeQuestions({
  required int auditDatetimeQuestionId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("removeAuditDatetimeQuestions", {
    "token": token,
    "auditDatetimeQuestionId": auditDatetimeQuestionId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getAuditFileuploadQuestions({
  required int auditFileuploadQuestionId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getAuditFileuploadQuestions", {
    "token": token,
    "auditFileuploadQuestionId": auditFileuploadQuestionId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> createAuditFileuploadQuestions({
  required int quid,
  required String auditTemplateId,
  required String question,
  required String fileExtensions,
  required bool allowMultipleFiles,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("createAuditFileuploadQuestions", {
    "token": token,
    "quid": quid.toString(),
    "auditTemplateId": auditTemplateId.toString(),
    "question": question.toString(),
    "fileExtensions": fileExtensions.toString(),
    "allowMultipleFiles": allowMultipleFiles.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> changeAuditFileuploadQuestions({
  required int auditFileuploadQuestionId,
  required int quid,
  required String auditTemplateId,
  required String question,
  required String fileExtensions,
  required bool allowMultipleFiles,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("changeAuditFileuploadQuestions", {
    "token": token,
    "auditFileuploadQuestionId": auditFileuploadQuestionId.toString(),
    "quid": quid.toString(),
    "auditTemplateId": auditTemplateId.toString(),
    "question": question.toString(),
    "fileExtensions": fileExtensions.toString(),
    "allowMultipleFiles": allowMultipleFiles.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> removeAuditFileuploadQuestions({
  required int auditFileuploadQuestionId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("removeAuditFileuploadQuestions", {
    "token": token,
    "auditFileuploadQuestionId": auditFileuploadQuestionId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getAuditTextAnswers({
  required int auditTextAnswerId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getAuditTextAnswers", {
    "token": token,
    "auditTextAnswerId": auditTextAnswerId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> createAuditTextAnswers({
  required int quid,
  required int auditTaskId,
  required String answer,
  required double answerNumber,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("createAuditTextAnswers", {
    "token": token,
    "quid": quid.toString(),
    "auditTaskId": auditTaskId.toString(),
    "answer": answer.toString(),
    "answerNumber": answerNumber.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> changeAuditTextAnswers({
  required int auditTextAnswerId,
  required int quid,
  required int auditTaskId,
  required String answer,
  required double answerNumber,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("changeAuditTextAnswers", {
    "token": token,
    "auditTextAnswerId": auditTextAnswerId.toString(),
    "quid": quid.toString(),
    "auditTaskId": auditTaskId.toString(),
    "answer": answer.toString(),
    "answerNumber": answerNumber.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> removeAuditTextAnswers({
  required int auditTextAnswerId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("removeAuditTextAnswers", {
    "token": token,
    "auditTextAnswerId": auditTextAnswerId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getAuditMultichoiceAnswers({
  required int auditMultichoiceAnswerId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getAuditMultichoiceAnswers", {
    "token": token,
    "auditMultichoiceAnswerId": auditMultichoiceAnswerId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> createAuditMultichoiceAnswers({
  required int quid,
  required int auditTaskId,
  required bool selectedOtherField,
  required String otherField,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("createAuditMultichoiceAnswers", {
    "token": token,
    "quid": quid.toString(),
    "auditTaskId": auditTaskId.toString(),
    "selectedOtherField": selectedOtherField.toString(),
    "otherField": otherField.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> changeAuditMultichoiceAnswers({
  required int auditMultichoiceAnswerId,
  required int quid,
  required int auditTaskId,
  required bool selectedOtherField,
  required String otherField,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("changeAuditMultichoiceAnswers", {
    "token": token,
    "auditMultichoiceAnswerId": auditMultichoiceAnswerId.toString(),
    "quid": quid.toString(),
    "auditTaskId": auditTaskId.toString(),
    "selectedOtherField": selectedOtherField.toString(),
    "otherField": otherField.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> removeAuditMultichoiceAnswers({
  required int auditMultichoiceAnswerId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("removeAuditMultichoiceAnswers", {
    "token": token,
    "auditMultichoiceAnswerId": auditMultichoiceAnswerId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getAuditDatetimeAnswers({
  required int auditDatetimeAnswerId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getAuditDatetimeAnswers", {
    "token": token,
    "auditDatetimeAnswerId": auditDatetimeAnswerId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> createAuditDatetimeAnswers({
  required int quid,
  required int auditTaskId,
  required String datetime,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("createAuditDatetimeAnswers", {
    "token": token,
    "quid": quid.toString(),
    "auditTaskId": auditTaskId.toString(),
    "datetime": datetime.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> changeAuditDatetimeAnswers({
  required int auditDatetimeAnswerId,
  required int quid,
  required int auditTaskId,
  required String datetime,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("changeAuditDatetimeAnswers", {
    "token": token,
    "auditDatetimeAnswerId": auditDatetimeAnswerId.toString(),
    "quid": quid.toString(),
    "auditTaskId": auditTaskId.toString(),
    "datetime": datetime.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> removeAuditDatetimeAnswers({
  required int auditDatetimeAnswerId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("removeAuditDatetimeAnswers", {
    "token": token,
    "auditDatetimeAnswerId": auditDatetimeAnswerId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> getAuditFileuploadAnswers({
  required int auditFileuploadAnswerId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("getAuditFileuploadAnswers", {
    "token": token,
    "auditFileuploadAnswerId": auditFileuploadAnswerId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> createAuditFileuploadAnswers({
  required int quid,
  required int auditTaskId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("createAuditFileuploadAnswers", {
    "token": token,
    "quid": quid.toString(),
    "auditTaskId": auditTaskId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> changeAuditFileuploadAnswers({
  required int auditFileuploadAnswerId,
  required int quid,
  required int auditTaskId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("changeAuditFileuploadAnswers", {
    "token": token,
    "auditFileuploadAnswerId": auditFileuploadAnswerId.toString(),
    "quid": quid.toString(),
    "auditTaskId": auditTaskId.toString(),
  });
  return response;
}

Future<Map<String, dynamic>> removeAuditFileuploadAnswers({
  required int auditFileuploadAnswerId,
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("removeAuditFileuploadAnswers", {
    "token": token,
    "auditFileuploadAnswerId": auditFileuploadAnswerId.toString(),
  });
  return response;
}
