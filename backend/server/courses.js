const Db = require('./database');
const Auth = require('./auth');
const Org = require('./organizations');
const CourseSections = require('./courseSections');
const Videos = require("./videos");
const Certificates = require('./certificate');

var courses = new Db.DatabaseTable("Courses",
    "courseId",
    [
        {
        name: "courseName",
        type: "varchar(1023)"
        },
        {
        name: "dateCreated",
        type: "datetime"
        },
        {
        name: "dateModified",
        type: "datetime"
        },
        {
        name: "organizationId",
        type: "int"
        },
        {
        name: "courseDescription",
        type: "varchar(4095)"
        },
        {
        name: "isLive",
        type: "bit"
        },
        {
        name: "isMooc",
        type: "bit"
        },
        {
        name: "stripeProductId",
        type: "varchar(32)"
        },
]);
courses.init();

var coursePrivileges = new Db.DatabaseTable("CoursePrivileges",
    "coursePrivilegeId",
    [
        {
        name: "userId",
        type: "int"
        },
        {
        name: "courseId",
        type: "int"
        },
        {
        name: "canAnalyze",
        type: "bit"
        },
        {
        name: "canEdit",
        type: "bit"
        },
        {
        name: "canTeach",
        type: "bit"
        },
        {
        name: "isAdmin",
        type: "bit"
        },
        {
        name: "isOwner",
        type: "bit"
        },
]);
coursePrivileges.init();

var courseSubscriptions = new Db.DatabaseTable("CourseSubscriptions",
    "courseSubscriptionId",
    [
        {
        name: "userId",
        type: "int"
        },
        {
        name: "courseId",
        type: "int"
        },
        {
        name: "dateSubscribed",
        type: "datetime"
        },
        {
        name: "paymentId",
        type: "int"
        },
]);
courseSubscriptions.init();

const DEFAULT_COURSE_OWNER_PRIVILEGES = {
    canAnalyze: true,
    canEdit: true,
    canTeach: true,
    isAdmin: true,
    isOwner: true,
};

module.exports.addCourse = addCourse;
async function addCourse (token, organizationId, courseOptions) {
    // check assigner has privileges
    let assignerPrivileges = await Org.getOrgUserPrivilege(token, organizationId);
    let assignerIsAdmin = Db.readBool(assignerPrivileges.isAdmin);
    if (!assignerIsAdmin) {
        throw "assigner has insufficient permission";
    }

    // perform length checks
    if (encodeURI(courseOptions.courseName).length > 1023) {
        throw {status: 403, message: "courseName is too long! (>1023 chars)"};
    }
    if (encodeURI(courseOptions.courseDescription).length > 4095) {
        throw {status: 403, message: "courseDescription is too long! (>4095 chars)"};
    }

    // add course
    let courseId = await courses.insertInto({
        courseName: courseOptions.courseName,
        dateCreated: Db.getDatetime(),
        dateModified: Db.getDatetime(),
        organizationId: organizationId, // TODO: implement organizationId
        courseDescription: courseOptions.courseDescription,
        isLive: 0,
        isMooc: 0,
    });

    return courseId;
}

module.exports.assignUserToCourse = assignUserToCourse;
async function assignUserToCourse (assignerToken, assigneeUserId, courseId, privilegeOptions, overrideSafety = false) {
    // check assigner has privileges
    await assertUserIsAdminForCourse(assignerToken, courseId);

    // add the user privileges
    let coursePrivilegeId = await coursePrivileges.insertInto({
        userId: assigneeUserId,
        courseId: courseId,
        canAnalyze: privilegeOptions.canAnalyze,
        canEdit: privilegeOptions.canEdit,
        canTeach: privilegeOptions.canTeach,
        isAdmin: privilegeOptions.isAdmin,
        isOwner: false,
    });
    return coursePrivilegeId;
}
module.exports.changeUserCoursePrivilege = changeUserCoursePrivilege;
async function changeUserCoursePrivilege (assignerToken, assigneeUserId, courseId, privilegeOptions) {
    // check assigner has privileges
    await assertUserIsAdminForCourse(assignerToken, courseId);

    await coursePrivileges.update(
        {
            userId: assigneeUserId,
            courseId: courseId,
        },
        {
            canAnalyze: privilegeOptions.canAnalyze,
            canEdit: privilegeOptions.canEdit,
            canTeach: privilegeOptions.canTeach,
            isAdmin: privilegeOptions.isAdmin,
        }
    );
}

module.exports.deassignUserFromCourse = deassignUserFromCourse;
async function deassignUserFromCourse (assignerToken, assigneeUserId, courseId) {
    // check assigner has privileges
    await assertUserIsAdminForCourse(assignerToken, courseId);

    // delete course privileges
    await coursePrivileges.deleteFrom(
        {
            userId: assigneeUserId,
            courseId: courseId,
        }
    );
}

// used only for when course is being deleted
module.exports.deassignAllUsersFromCourse = deassignAllUsersFromCourse;
async function deassignAllUsersFromCourse (courseId) {
    // delete course privileges
    await coursePrivileges.deleteFrom({ courseId: courseId, });
}

module.exports.getCoursePrivilege = getCoursePrivilege;
async function getCoursePrivilege(coursePrivilegeId) {
    return await coursePrivileges.select({coursePrivilegeId: coursePrivilegeId});
}

async function getCourseUserPrivilege(token, courseId) {
    let assignerUserId = await Auth.getUserFromToken(token);
    assignerUserId = assignerUserId[0].userId;
    let assignerCoursePrivilege = await coursePrivileges.select({
        courseId: courseId,
        userId: assignerUserId,
    });
    if (assignerCoursePrivilege.length === 0) {
        throw "assigner not part of course";
    }
    return assignerCoursePrivilege[0];
}

module.exports.getAllCoursePrivilegesForOrganization = getAllCoursePrivilegesForOrganization;
async function getAllCoursePrivilegesForOrganization(organizationId) {
    let coursePrivilegesOutput = [];
    let data = await courses.select({organizationId: organizationId});
    for (var i = 0; i < data.length; i++) {
        data2 = await coursePrivileges.select({
            courseId: data[i].courseId,
        });
        for (var j = 0; j < data2.length; j++) {
            coursePrivilegesOutput.push(data2[j]);
        }
    }
    return coursePrivilegesOutput;
}

module.exports.getCourse = getCourse;
async function getCourse (courseId) {
    return await courses.select({courseId: courseId});
}
module.exports.getCoursePrivilegesForUser = getCoursePrivilegesForUser;
async function getCoursePrivilegesForUser (token) {
    let user = await Auth.getUserFromToken(token);
    let userId = user[0].userId;

    let coursePrivilegesOfUser = await coursePrivileges.select({
        userId: userId,
    });
    return coursePrivilegesOfUser;
}

module.exports.getCoursesForOrganization = getCoursesForOrganization
async function getCoursesForOrganization(token, organizationId) {
    // check assigner has privileges
    let assignerPrivileges;
    try {
    assignerPrivileges = await Org.getOrgUserPrivilege(token, organizationId);
    } catch {}

    if (assignerPrivileges == null) {
        // assigner is not part of organization
        return await courses.select({organizationId: organizationId, isLive: true});
    } else {
        // assigner is part of organization
        return await courses.select({organizationId: organizationId});
    }
}

module.exports.changeCourseOptions = changeCourseOptions;
async function changeCourseOptions (token, courseId, courseOptions) {
    await assertUserCanEditCourse(token, courseId);

    courseOptions.dateModified = Db.getDatetime(),
    await courses.update(
        { courseId: courseId },
        courseOptions,
    );
}

module.exports.changeCourseLiveness = changeCourseLiveness;
async function changeCourseLiveness (token, courseId, courseLiveness) {
    await assertUserIsAdminForCourse(token, courseId);

    await courses.update(
        { courseId: courseId },
        {
            isLive: courseLiveness,
            dateModified: Db.getDatetime(),
        }
    );
}

module.exports.changeCourseMoocness = changeCourseMoocness;
async function changeCourseMoocness (token, courseId, courseMoocness) {
    await assertUserIsAdminForCourse(token, courseId);

    await courses.update(
        { courseId: courseId },
        {
            isMooc: courseMoocness,
            dateModified: Db.getDatetime(),
        }
    );
}

module.exports.removeCourse = removeCourse;
async function removeCourse (token, courseId) {
    // get organizationId
    let courseData = await courses.select({courseId: courseId});
    let organizationId = courseData[0].organizationId;

    // check assigner has privileges
    let assignerPrivileges = await Org.getOrgUserPrivilege(token, organizationId);
    let assignerHasPerms = Db.readBool(assignerPrivileges.isAdmin);
    if (!assignerHasPerms) {
        throw "assigner has insufficient permission to remove course (must be admin)";
    }

    // clean all course sections
    await CourseSections.removeAllCourseSectionsFromCourse(courseId);

    // remove all privileges
    await deassignAllUsersFromCourse(courseId);

    // remove all subscriptions
    await courseSubscriptions.deleteFrom({courseId: courseId});

    // remove all certificates linked with course
    await Certificates.removeCertificateDataFromCourse(courseId);

    // remove course
    await courses.deleteFrom({ courseId: courseId });
}

module.exports.deleteAllCoursesFromOrganization = deleteAllCoursesFromOrganization;
async function deleteAllCoursesFromOrganization(organizationId) {
    // clean all course sections
    let data = await courses.select({ organizationId: organizationId });
    for (var i = 0; i < data.length; i++) {
        await CourseSections.removeAllCourseSectionsFromCourse(data[i].courseId);
        await coursePrivileges.deleteFrom({courseId: data[i].courseId});
    }
    await courses.deleteFrom({ organizationId: organizationId });
}

async function assertUserIsAdminForCourse(token, courseId) {

    // get organizationId
    let courseData = await getCourse(courseId);
    let organizationId = courseData[0].organizationId;
    // for org
    try {
        let orgAssignerPrivileges = await Org.getOrgUserPrivilege(token, organizationId);
        var orgAssignerIsAdmin = Db.readBool(orgAssignerPrivileges.isAdmin);
    } catch (e) {
        var orgAssignerIsAdmin = false;
    }
    // for course
    try {
        let courseAssignerPrivileges = await getCourseUserPrivilege(token, courseId);
        var courseAssignerIsAdmin = Db.readBool(courseAssignerPrivileges.isAdmin);
    } catch (e) {
        var courseAssignerIsAdmin = false;
    }

    // does the assigner have sufficient privileges?
    if (!(orgAssignerIsAdmin || courseAssignerIsAdmin)) {
        throw "assigner has insufficient permission";
    }
}
module.exports.assertUserCanEditCourse = assertUserCanEditCourse;
async function assertUserCanEditCourse(token, courseId) {

    // get organizationId
    let courseData = await getCourse(courseId);
    let organizationId = courseData[0].organizationId;
    // for org
    try {
        let orgAssignerPrivileges = await Org.getOrgUserPrivilege(token, organizationId);
        var orgAssignerCanEdit = Db.readBool(orgAssignerPrivileges.canEditAll);
        var orgAssignerIsAdmin = Db.readBool(orgAssignerPrivileges.isAdmin);
    } catch (e) {
        var orgAssignerCanEdit = false;
        var orgAssignerIsAdmin = false;
    }
    // for course
    try {
        let courseAssignerPrivileges = await getCourseUserPrivilege(token, courseId);
        var courseAssignerCanEdit = Db.readBool(courseAssignerPrivileges.canEdit);
        var courseAssignerIsAdmin = Db.readBool(courseAssignerPrivileges.isAdmin);
    } catch (e) {
        var courseAssignerCanEdit = false;
        var courseAssignerIsAdmin = false;
    }

    // does the assigner have sufficient privileges?
    // admin powers = can edit
    if (!(orgAssignerCanEdit || courseAssignerCanEdit) && !(orgAssignerIsAdmin || courseAssignerIsAdmin)) {
        throw "assigner has insufficient permission";
    }
}
module.exports.subscribeToCourse = subscribeToCourse;
async function subscribeToCourse(token, courseId, paymentId) {
    // get assignee userid from username
    let assigneeUserId = await Auth.getUserFromToken(token);
    assigneeUserId = assigneeUserId[0].userId;

    // add the user privileges
    let courseSubscriptionId = await courseSubscriptions.insertInto({
        userId: assigneeUserId,
        courseId: courseId,
        dateSubscribed: Db.getDatetime(),
        paymentId: paymentId !== undefined ? paymentId : null
    });
    return courseSubscriptionId;
}
module.exports.unsubscribeToCourse = unsubscribeToCourse;
async function unsubscribeToCourse(token, courseId) {
    // get assignee userid from username
    let assigneeUserId = await Auth.getUserFromToken(token);
    assigneeUserId = assigneeUserId[0].userId;

    // TODO: courseSubscriptions should have a 'valid' flag which is set to null instead of being deleted here.
    // this is because payment data is also stored with course subscription, which we don't want to lose the context to.
    await courseSubscriptions.deleteFrom({
        userId: assigneeUserId,
        courseId: courseId,
    });
}

module.exports.getCourseSubscriptionsForUser = getCourseSubscriptionsForUser;
async function getCourseSubscriptionsForUser(token) {
    // get assignee userid from username
    let userId = await Auth.getUserFromToken(token);
    userId = userId[0].userId;
    let data = await courseSubscriptions.select({userId: userId})
    return data;
}

module.exports.getCourseSubscriptionsForUserId = getCourseSubscriptionsForUserId;
async function getCourseSubscriptionsForUserId(token, userId) {
    // TODO: do auth
    // get assignee userid from username
    let data = await courseSubscriptions.select({userId: userId})
    for (let i = 0; i < data.length; i++) {
        const courseId = data[i].courseId;
        const course = await courses.select({courseId: courseId});
        data[i].courseName = course[0].courseName;
    }
    return data;
}

module.exports.getAllStudentsForCourse = getAllStudentsForCourse;
async function getAllStudentsForCourse(token, courseId) {
    // TODO: do auth checks
    let courseSubscriptionData = await courseSubscriptions.select({courseId: courseId});

    // check for duplicate userId: if it exists, remove it.
    for (let i = 0; i <courseSubscriptionData.length; i++) {
        let skip = false;
        for (let j = i + 1; j < courseSubscriptionData.length; j++) {
            if (courseSubscriptionData[i].userId === courseSubscriptionData[j].userId) {
                // remove it
                courseSubscriptionData.splice(i--, 1);
                skip = true;
                break;
            }
        }
        if (skip) continue;
    }

    // query the server to get userData for userId
   let userIds = [];
    for (let i = 0; i < courseSubscriptionData.length; i++) {
        userIds.push(courseSubscriptionData[i].userId);
    }
    let userData = await Auth.getUserFromUserIds(userIds);
    for (let i = 0; i < userData.length; i++) {

        // omit these for security
        delete userData[i].token;
        delete userData[i].password;
        for (let j = 0; j < courseSubscriptionData.length; j++) {
            if (userData[i].userId === courseSubscriptionData[j].userId) {
                courseSubscriptionData[j].userData = userData[i];
            }
        }
    }
    return courseSubscriptionData;
}
module.exports.getCourseAnalyticsStudents = getCourseAnalyticsStudents;
async function getCourseAnalyticsStudents(token, courseId) {
    // TODO: do auth checks
    let courseSubscriptionData = await courseSubscriptions.select({courseId: courseId});

    // check for duplicate userId: if it exists, remove it.
    for (let i = 0; i <courseSubscriptionData.length; i++) {
        let skip = false;
        for (let j = i + 1; j < courseSubscriptionData.length; j++) {
            if (courseSubscriptionData[i].userId === courseSubscriptionData[j].userId) {
                // remove it
                courseSubscriptionData.splice(i--, 1);
                skip = true;
                break;
            }
        }
        if (skip) continue;
    }
    // query the server to get userData for userId
    for (let i = 0; i < courseSubscriptionData.length; i++) {
        const userId = courseSubscriptionData[i].userId;
        const user = await Auth.getUser(userId);
        delete user.extraUserData;

        if (i < 10) {
            console.log(i);
            const assessmentStats = await Videos.getAssessmentStatsForStudentForCourse(token, courseId, userId);
            user.totalAssessmentGrades = Math.round(assessmentStats.totalAssessmentGrades * 1000) / 10;
            user.assessmentsPassed = assessmentStats.assessmentsPassed;
        }

        courseSubscriptionData[i] = user;
    }
    return courseSubscriptionData;
}

module.exports.getCourseFromPayment = getCourseFromPayment;
async function getCourseFromPayment(stripeProductId, userId) {
    return await courses.select({stripeProductId: stripeProductId});
}