const fs = require('node:fs');


// for function parameter extraction
const STRIP_COMMENTS = /((\/\/.*$)|(\/\*[\s\S]*?\*\/))/mg;
const ARGUMENT_NAMES = /([^\s,]+)/g;

const Auth = require('./auth');
const Courses = require('./courses');
const Fleet = require('./fleet');
const Org = require('./organizations');
const Coords = require('./coordinators');
const Videos = require('./videos');
const VideoData = require('./videoData');
const Auditing = require('./auditing');
const AuditingQa = require('./auditing-qa');
const Formulas = require('./formulas');

const STUBS = [
    {action: "getUser",                             func: Auth.getUser},
    {action: "changeUser",                          func: Auth.changeUser},
    {action: "changeUserPassword",                  func: Auth.changeUserPassword},
    {action: "getUserFromOrganizationId",           func: Auth.getUserFromOrganizationId},
    {action: "getUserFromCoordinatorGroupId",       func: Auth.getUserFromCoordinatorGroupId},
    {action: "getOrganizationPrivilegesForOrganization", func: Org.getOrganizationPrivilegesForOrganization},
    {action: "getCoordinatorPrivileges",            func: Coords.getCoordinatorPrivileges},
    {action: "setProfilePictureImageId",            func: Auth.setProfilePictureImageId},
    {action: "logoutUser",                          func: Auth.logoutUser},

    {action: "getCourseAnalyticsStudents",          func: Courses.getCourseAnalyticsStudents},

    {action: "executeFormula",                      func: Formulas.executeFormula},
    {action: "findAllPossibleFuncsForValue",        func: Formulas.findAllPossibleFuncsForValue},
    {action: "verifyFormula",                       func: Formulas.verifyFormula},

    {action: "getCourseSubscriptionsForUserId",     func: Courses.getCourseSubscriptionsForUserId},

    {action: "getAuditTemplates",                   func: Auditing.getAuditTemplates},
    {action: "getAuditTemplate",                    func: Auditing.getAuditTemplate},
    {action: "createAuditTemplate",                 func: Auditing.createAuditTemplate},
    {action: "changeAuditTemplate",                 func: Auditing.changeAuditTemplate},
    {action: "removeAuditTemplate",                 func: Auditing.removeAuditTemplate},
    {action: "getAuditTasks",                       func: Auditing.getAuditTasks},
    {action: "getAuditTask",                        func: Auditing.getAuditTask},
    {action: "createAuditTask",                     func: Auditing.createAuditTask},
    {action: "changeAuditTask",                     func: Auditing.changeAuditTask},
    {action: "removeAuditTask",                     func: Auditing.removeAuditTask},
    {action: "getAuditTaskQuestion",                func: Auditing.getAuditTaskQuestion},
    {action: "setAuditTaskQuestion",                func: Auditing.setAuditTaskQuestion},
    {action: "getAuditTemplateQuestions",           func: Auditing.getAuditTemplateQuestions},
    {action: "getAuditPrivilegesForUserId",         func: Auditing.getAuditPrivilegesForUserId},
    {action: "getAuditPrivilegesForAuditTask",      func: Auditing.getAuditPrivilegesForAuditTask},
    {action: "createAuditPrivilege",                func: Auditing.createAuditPrivilege},
    {action: "changeAuditPrivilege",                func: Auditing.changeAuditPrivilege},
    {action: "removeAuditPrivilege",                func: Auditing.removeAuditPrivilege},
    {action: "submitAuditPrivilege",                func: Auditing.submitAuditPrivilege},
    {action: "getAuditPrivilegeForUserAndAuditTask", func: Auditing.getAuditPrivilegeForUserAndAuditTask},

    {action: "getWorkflow",                         func: Auditing.getWorkflow},
    {action: "createWorkflowNode",                  func: Auditing.createWorkflowNode},
    {action: "changeWorkflowNode",                  func: Auditing.changeWorkflowNode},
    {action: "removeWorkflowNode",                  func: Auditing.removeWorkflowNode},
    {action: "createWorkflowConnection",            func: Auditing.createWorkflowConnection},
    {action: "removeWorkflowConnection",            func: Auditing.removeWorkflowConnection},
    {action: "submitAuditTask",                     func: Auditing.submitAuditTask},
    {action: "approveAuditTask",                    func: Auditing.approveAuditTask},
    {action: "rejectAuditTask",                     func: Auditing.rejectAuditTask},

    {action: "getLabelGroups",                      func: Auditing.getLabelGroups},
    {action: "getLabelGroup",                       func: Auditing.getLabelGroup},
    {action: "getLabels",                           func: Auditing.getLabels},
    {action: "createLabelGroup",                    func: Auditing.createLabelGroup},
    {action: "createLabel",                         func: Auditing.createLabel},
    {action: "changeLabelGroup",                    func: Auditing.changeLabelGroup},
    {action: "changeLabel",                         func: Auditing.changeLabel},
    {action: "removeLabelGroup",                    func: Auditing.removeLabelGroup},
    {action: "removeLabel",                         func: Auditing.removeLabel},
    {action: "changeAuditTaskStatus",               func: Auditing.changeAuditTaskStatus},

    {action: "getAuditTextQuestions",               func: AuditingQa.getAuditTextQuestions},
    {action: "createAuditTextQuestions",            func: AuditingQa.createAuditTextQuestions},
    {action: "changeAuditTextQuestions",            func: AuditingQa.changeAuditTextQuestions},
    {action: "removeAuditTextQuestions",            func: AuditingQa.removeAuditTextQuestions},
    {action: "getAuditMultichoiceQuestions",        func: AuditingQa.getAuditMultichoiceQuestions},
    {action: "createAuditMultichoiceQuestions",     func: AuditingQa.createAuditMultichoiceQuestions},
    {action: "changeAuditMultichoiceQuestions",     func: AuditingQa.changeAuditMultichoiceQuestions},
    {action: "removeAuditMultichoiceQuestions",     func: AuditingQa.removeAuditMultichoiceQuestions},
    {action: "getAuditDatetimeQuestions",           func: AuditingQa.getAuditDatetimeQuestions},
    {action: "createAuditDatetimeQuestions",        func: AuditingQa.createAuditDatetimeQuestions},
    {action: "changeAuditDatetimeQuestions",        func: AuditingQa.changeAuditDatetimeQuestions},
    {action: "removeAuditDatetimeQuestions",        func: AuditingQa.removeAuditDatetimeQuestions},
    {action: "getAuditFileuploadQuestions",         func: AuditingQa.getAuditFileuploadQuestions},
    {action: "createAuditFileuploadQuestions",      func: AuditingQa.createAuditFileuploadQuestions},
    {action: "changeAuditFileuploadQuestions",      func: AuditingQa.changeAuditFileuploadQuestions},
    {action: "removeAuditFileuploadQuestions",      func: AuditingQa.removeAuditFileuploadQuestions},

    {action: "getAuditTextAnswers",                 func: AuditingQa.getAuditTextAnswers},
    {action: "createAuditTextAnswers",              func: AuditingQa.createAuditTextAnswers},
    {action: "changeAuditTextAnswers",              func: AuditingQa.changeAuditTextAnswers},
    {action: "removeAuditTextAnswers",              func: AuditingQa.removeAuditTextAnswers},
    {action: "getAuditMultichoiceAnswers",          func: AuditingQa.getAuditMultichoiceAnswers},
    {action: "createAuditMultichoiceAnswers",       func: AuditingQa.createAuditMultichoiceAnswers},
    {action: "changeAuditMultichoiceAnswers",       func: AuditingQa.changeAuditMultichoiceAnswers},
    {action: "removeAuditMultichoiceAnswers",       func: AuditingQa.removeAuditMultichoiceAnswers},
    {action: "getAuditDatetimeAnswers",             func: AuditingQa.getAuditDatetimeAnswers},
    {action: "createAuditDatetimeAnswers",          func: AuditingQa.createAuditDatetimeAnswers},
    {action: "changeAuditDatetimeAnswers",          func: AuditingQa.changeAuditDatetimeAnswers},
    {action: "removeAuditDatetimeAnswers",          func: AuditingQa.removeAuditDatetimeAnswers},
    {action: "getAuditFileuploadAnswers",           func: AuditingQa.getAuditFileuploadAnswers},
    {action: "createAuditFileuploadAnswers",        func: AuditingQa.createAuditFileuploadAnswers},
    {action: "changeAuditFileuploadAnswers",        func: AuditingQa.changeAuditFileuploadAnswers},
    {action: "removeAuditFileuploadAnswers",        func: AuditingQa.removeAuditFileuploadAnswers},

    {action: "assignCoordinatorToCoordinatorGroup", func: Coords.assignCoordinatorToCoordinatorGroup},
    {action: "deassignCoordinatorFromCoordinatorGroup",         func: Coords.deassignCoordinatorFromCoordinatorGroup},
    {action: "getCoordinatorGroups",                func: Coords.getCoordinatorGroups},
    {action: "createCoordinatorGroup",              func: Coords.createCoordinatorGroup},
    {action: "changeCoordinatorGroup",              func: Coords.changeCoordinatorGroup},
    {action: "removeCoordinatorGroup",              func: Coords.removeCoordinatorGroup},


    {action: "assignUserToCoordinateGroup",         func: Auth.assignUserToCoordinatorGroup},
    {action: "deassignUserFromCoordinateGroup",     func: Auth.deassignUserFromCoordinatorGroup},

    {action: "getCourseFiles",                      func: Videos.getCourseFiles},
    {action: "getAuditTemplateFiles",               func: Videos.getAuditTemplateFiles},
    {action: "getUserFiles",                        func: Videos.getUserFiles},
    {action: "markVideoTaskAsRead",                 func: Videos.markVideoTaskAsRead},
    {action: "markVideoTaskAsUnread",               func: Videos.markVideoTaskAsUnread},
    {action: "getIsVideoRead",                      func: Videos.getIsVideoRead},
    {action: "removeVideo",                         func: Videos.removeVideo},
    {action: "removeImage",                         func: Videos.removeImage},

    {action: "fleet_getFleetFlightplanFromUser",    func: Fleet.getFleetFlightplanFromUser},
    {action: "fleet_getFleetFlightplans",           func: Fleet.getFleetFlightplans},
    {action: "fleet_createFleetFlightplan",         func: Fleet.createFleetFlightplan},
    {action: "fleet_removeFleetFlightplan",         func: Fleet.removeFleetFlightplan},
    {action: "fleet_getFleetCars",                  func: Fleet.getFleetCars},
    {action: "fleet_getFleetCar",                   func: Fleet.getFleetCar},
    {action: "fleet_createFleetCar",                func: Fleet.createFleetCar},
    {action: "fleet_changeFleetCar",                func: Fleet.changeFleetCar},
    {action: "fleet_removeFleetCar",                func: Fleet.removeFleetCar},
    {action: "getFleetDrivers",                     func: Fleet.getFleetDrivers},
    {action: "createFleetDriver",                   func: Fleet.createFleetDriver},
    {action: "removeFleetDriver",                   func: Fleet.removeFleetDriver},
    {action: "isUserFleetDriver",                   func: Fleet.isUserFleetDriver},
    {action: "getFleetLocations",                   func: Fleet.getFleetLocations},
    {action: "getFleetLocation",                    func: Fleet.getFleetLocation},
    {action: "createFleetLocation",                 func: Fleet.createFleetLocation},
    {action: "changeFleetLocation",                 func: Fleet.changeFleetLocation},
    {action: "removeFleetLocation",                 func: Fleet.removeFleetLocation},
    {action: "removeAllFleetLocation",              func: Fleet.removeAllFleetLocation},
    {action: "getFleetFlightplanFromUserToday",     func: Fleet.getFleetFlightplanFromUserToday},
    {action: "createFleetWaypoint",                 func: Fleet.createFleetWaypoint},
    {action: "removeFleetWaypoint",                 func: Fleet.removeFleetWaypoint},
    {action: "getAllWaypointsForOrganization",      func: Fleet.getAllWaypointsForOrganization},
    {action: "getTodayDrivers",                     func: Fleet.getTodayDrivers},
    {action: "getTodayCars",                        func: Fleet.getTodayCars},
    {action: "forecastWeather",                     func: Fleet.forecastWeather},
    {action: "forecastWeatherForFleetLocation",     func: Fleet.forecastWeatherForFleetLocation},
    {action: "checkinAtLocation",                   func: Fleet.checkinAtLocation},

]
_generateStubs()

function _getParamNames(func, ignoreToken=false) {
    var fnStr = func.toString().replace(STRIP_COMMENTS, '');
    var result = fnStr.slice(fnStr.indexOf('(') + 1, fnStr.indexOf(')')).match(ARGUMENT_NAMES);
    if (result === null)
        result = [];
    return result;
}
function _generateDartStub(action, func) {
    const paramNames = _getParamNames(func, ignoreToken=true);
    let params = "";
    let params2 = "";
    for (let i = 0; i < paramNames.length; i++) {
        if (paramNames[i] === "token") {
            continue;
        }

        params += `required TYPE ${paramNames[i]},\n`;
        params2 += `"${paramNames[i]}": ${paramNames[i]}.toString(),\n`;
    }
    
    return `
Future<Map<String, dynamic>> ${func.name}({
    ${params}
}) async {
  String token = getToken();
  Map<String, dynamic> response =
      await networking_service.serverGet("${action}", {
    "token": token,
    ${params2}
  });
  return response;
}
  
`;
}

module.exports.handleAction = handleAction;
function handleAction(action, parser) {
    for (let i = 0; i < STUBS.length; i++) {
        const stub = STUBS[i];
        if (stub.action === action) {
            _handleStub(stub.func, parser);
            return true;
        }
    }
    return false;
}

async function _handleStub(func, parser) {
    // DANGER: possible security concerns here. You should double check.
    const paramNames = _getParamNames(func);
    var params = [];
    for (let i = 0; i < paramNames.length; i++) {
        params[i] = parser.getQuery(paramNames[i]);
    }
    try {
        const data = await func.apply(null, params);
        parser.response.status(200);
        parser.response.json({"data": data});
    } catch (err) {
        parser.handleError(err);
    }
}

function _generateStubs() {
    let content = "";
    for (let i = 0; i < STUBS.length; i++) {
        const stub = STUBS[i];
        content += _generateDartStub(stub.action, stub.func);
    }
    fs.writeFile('stub.dart', content, err => {
        if (err) {
            console.error(err);
        } else {
            // file written successfully
        }
    });
}