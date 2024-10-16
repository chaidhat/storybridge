const Auth = require('./auth');
const Org = require('./organizations');
const Courses = require('./courses');
const CourseSections = require('./courseSections');
const CourseElements = require('./courseElements');
const Videos = require("./videos");
const VideoData = require("./videoData");
const Payment = require('./payment');
const Analytics = require('./analytics');
const Ai = require('./ai');
const Admin = require('./admin');
const Certificates = require('./certificate');
const Sicher = require('./sicher');
const Fleet = require('./fleet');
const Stub = require('./stub');

const POLICY_AUTH = {
    "pol.auth.log.0": {authErrorType: "general", message: "Something went wrong."},
    "pol.auth.log.1": {authErrorType: "email", message: "Please enter your email."},
    "pol.auth.log.2": {authErrorType: "password", message: "Please enter your password."},
    "pol.auth.log.3": {authErrorType: "email", message: "Username cannot be found."},
    "pol.auth.log.4": {authErrorType: "password", message: "Password is incorrect."},
    "pol.auth.log.5": {authErrorType: "password", message: "Too many incorrect attempts. Please try again later."},

    "pol.auth.reg.0": {authErrorType: "general", message: "Something went wrong."},
    "pol.auth.reg.1": {authErrorType: "name", message: "Please enter your name."},
    "pol.auth.reg.2": {authErrorType: "email", message: "Please enter your email."},
    "pol.auth.reg.3": {authErrorType: "password", message: "Please enter your password."},
    "pol.auth.reg.4": {authErrorType: "email", message: "Please enter valid email."},
    "pol.auth.reg.5": {authErrorType: "email", message: "Email already exists - please log in."},
    "pol.auth.reg.6": {authErrorType: "password", message: "Password too short."},
    "pol.auth.reg.7": {authErrorType: "password", message: "Password must contain a number."},
    "pol.auth.reg.8": {authErrorType: "password", message: "Password must contain a letter."},
    "pol.auth.reg.9": {authErrorType: "name", message: "Name too long."},
    "pol.auth.reg.10": {authErrorType: "email", message: "Email too long."},

    "pol.auth.forgotpassword.0" : {message: "Username cannot be found."},
    "pol.auth.forgotpassword.1" : {message: "Incorrect reset token."},
    "pol.auth.forgotpassword.2" : {message: "Please enter your password."},
    "pol.auth.forgotpassword.3" : {message: "Password too short."},
    "pol.auth.forgotpassword.4" : {message: "Password must contain a number."},
    "pol.auth.forgotpassword.5" : {message: "Password must contain a letter."},

    "pol.auth.change.0" : {message: "Something went wrong"},
    "pol.auth.change.1" : {message: "Please enter your name."},
    "pol.auth.change.2" : {message: "Please enter your email."},
    "pol.auth.change.3" : {message: "Please enter valid email."},
    "pol.auth.change.4" : {message: "Email already exists."},
    "pol.auth.change.5" : {message: "Name too long."},
    "pol.auth.change.6" : {message: "Email too long."},

    "pol.auth.passwordchange.0": {authErrorType: "oldPassword", message: "Old password incorrect."},
    "pol.auth.passwordchange.1": {authErrorType: "oldPassword", message: "Please enter your old password."},
    "pol.auth.passwordchange.2": {authErrorType: "newPassword", message: "Please enter your new password."},
    "pol.auth.passwordchange.3": {authErrorType: "newPassword", message: "Password too short."},
    "pol.auth.passwordchange.4": {authErrorType: "newPassword", message: "Password must contain a number."},
    "pol.auth.passwordchange.5": {authErrorType: "newPassword", message: "Password must contain a letter."},
}

class Router{
    request;
    response;

    constructor (request, response){
        this.request = request;
        this.response = response;
    }

    async parse (action) {
        //console.log(`parsing action: ${action}`);
        switch (action) {
            case "getUserFromToken":
                this.getUserFromToken();
                break;
            case "login":
                this.login();
                break;
            case "register":
                this.register();
                break;
            case "preregister":
                this.preregister();
                break;
            case "getOrganizations":
                this.getOrganizations();
                break;
            case "getOrganization":
                this.getOrganization();
                break;
            case "createOrganization":
                this.createOrganization();
                break;
            case "getCourses":
                this.getCourses();
                break;
            case "getCourse":
                this.getCourse();
                break;
            case "createCourse":
                this.createCourse();
                break;
            case "changeOrganizationOptions":
                this.changeOrganizationOptions();
                break;
            case "changeCourseOptions":
                this.changeCourseOptions();
                break;
            case "removeCourse":
                this.removeCourse();
                break;
            case "getCourseHierarchy":
                this.getCourseHierarchy();
                break;
            case "createCourseSection":
                this.createCourseSection();
                break;
            case "changeCourseSection":
                this.changeCourseSection();
                break;
            case "removeCourseSection":
                this.removeCourseSection();
                break;
            case "createCourseElement":
                this.createCourseElement();
                break;
            case "getCourseElement":
                this.getCourseElement();
                break;
            case "changeCourseElementName":
                this.changeCourseElementName();
                break;
            case "changeCourseElementData":
                this.changeCourseElementData();
                break;
            case "createVideo":
                this.createVideo();
                break;
            case "getVideo":
                this.getVideo();
                break;
            case "createImage":
                this.createImage();
                break;
            case "createImageForUser":
                this.createImageForUser();
                break;
            case "getImage":
                this.getImage();
                break;
            case "getAssessment":
                this.getAssessment();
                break;
            case "updateAssessment":
                this.updateAssessment();
                break;
            case "createAssessment":
                this.createAssessment();
                break;
            case "removeAssessment":
                this.removeAssessment();
                break;
            case "getAssessmentTaskFromAssessment":
                this.getAssessmentTaskFromAssessment();
                break;
            case "updateAssessmentTaskFromAssessment":
                this.updateAssessmentTaskFromAssessment();
                break;
            case "createAssessmentTaskFromAssessment":
                this.createAssessmentTaskFromAssessment();
                break;
            case "removeCourseElement":
                this.removeCourseElement();
                break;
            case "downloadVideo":
                await VideoData.downloadVideo(this);
                break;
            case "downloadImage":
                await VideoData.downloadImage(this);
                break;
            case "uploadContent":
                await VideoData.uploadContent(this);
                break;
            case "doneUploadContent":
                await VideoData.doneUploadContent(this);
                break;
            case "getCompressionStatus":
                this.getCompressionStatus();
                break;
            case "subscribeToCourse":
                this.subscribeToCourse();
                break;
            case "getAllAssessmentsForCourse":
                this.getAllAssessmentsForCourse();
                break;
            case "getAllStudentsForCourse":
                this.getAllStudentsForCourse();
                break;
            case "getAssessmentStatsForStudentForCourse":
                this.getAssessmentStatsForStudentForCourse();
                break;
            case "getAssessmentStatsForThisStudentForCourse":
                this.getAssessmentStatsForThisStudentForCourse();
                break;
            case "getCheckoutSessionUrl":
                this.getCheckoutSessionUrl();
                break;
            case "getPortalSessionUrl":
                this.getPortalSessionUrl();
                break;
            case "getCheckoutSessionUrlCourse":
                this.getCheckoutSessionUrlCourse();
                break;
            case "reportAnalyticsEvent":
                this.reportAnalyticsEvent();
                break;
            case "reportAnalyticsForm":
                this.reportAnalyticsForm();
                break;
            case "getAiCourseElementSummary":
                this.getAiCourseElementSummary();
                break;
            case "askAiCourseElementQuestion":
                this.askAiCourseElementQuestion();
                break;
            case "getCourseSalesSettings":
                this.getCourseSalesSettings();
                break;
            case "changeCourseSalesSettings":
                this.changeCourseSalesSettings();
                break;
            case "getCourseSalesHistory":
                this.getCourseSalesHistory();
                break;
            case "getOrganizationBalance":
                this.getOrganizationBalance();
                break;
            case "createWithdrawal":
                this.createWithdrawal();
                break;
            case "getWithdrawals":
                this.getWithdrawals();
                break;
            case "createStripeSubscription":
                this.createStripeSubscription();
                break;
            case "adminPing":
                this.adminPing();
                break;
            case "adminGetDb":
                this.adminGetDb();
                break;
            case "adminCallDb":
                this.adminCallDb();
                break;
            case "createCertificateData":
                this.createCertificateData();
                break;
            case "getCertificateData":
                this.getCertificateData();
                break;
            case "updateCertificateData":
                this.updateCertificateData();
                break;
            case "sicher_getLectures":
                this.sicher_getLectures();
                break;
            case "sicher_getLecture":
                this.sicher_getLecture();
                break;
            case "sicher_createLecture":
                this.sicher_createLecture();
                break;
            case "sicher_changeLecture":
                this.sicher_changeLecture();
                break;
            case "sicher_removeLecture":
                this.sicher_removeLecture();
                break;
            case "sicher_getTopLectures":
                this.sicher_getTopLectures();
                break;
            case "sicher_createBooking":
                this.sicher_createBooking();
                break;
            case "sicher_getBooking":
                this.sicher_getBooking();
                break;
            case "forgotPassword":
                this.forgotPassword();
                break;
            case "resetPassword":
                this.resetPassword();
                break;


            default:
                if (!Stub.handleAction(action, this)) {
                    this.response.status(400);
                    this.response.json({"message": "invalid action"});
                }
                return;
        }
    }

    getQuery(query, optional = false) {
        let answer = this.request.body[query];
        if (answer !== undefined) {
            return answer;
        } else {
            if (!optional) {
                this.response.status(400);
                this.response.json({"message": `query '${query}' expected in url but not found`})
                console.log(`query '${query}' expected in url but not found`);
                throw "error";
            } else {
                return null;
            }
        }
    }
    handleError(err) {
        /*
        STATUS CODES used in this project:
        200 - OK
        400 - bad request   client error (e.g., misspelt query)
        403 - forbidden     user error (e.g., incorrect password) a message is provided via json
        500 - server error  server error (really bad day)
        */

        // check if the error is custom
        if (err.status !== undefined && err.policy !== undefined) {
            this.response.status(err.status);
            this.response.json({policy: err.policy, errorData: POLICY_AUTH[err.policy]});
            console.log("error: " + err.policy);
            return;
        }
        if (err.status !== undefined && err.message !== undefined) {
            this.response.status(err.status);
            this.response.json({message: err.message});
            console.log("error: " + err.status);
            return;
        }

        console.log("error: " + err);

        switch (err) {
            case "no user exists":
                this.response.status(403);
                this.response.json({message: err});
                return;
            case "no token exists":
                this.response.status(403);
                this.response.json({message: err});
                return;
            case "passwords do not match":
                this.response.status(403);
                this.response.json({message: err});
                return;
            case "user already exists":
                this.response.status(403);
                this.response.json({message: err});
                return;
            case "assigner not part of organization":
                this.response.status(400);
                this.response.json({message: err});
                return;
            case "assigner has insufficient permission":
                this.response.status(400);
                this.response.json({message: err});
                return;
            case "assigner not part of course":
                this.response.status(400);
                this.response.json({message: err});
                return;
            default:
                console.log(err.stack)
                this.response.status(500);
                this.response.json({message: "fatal: unreachable"});
                return;
        }
    }

    async getUserFromToken() {
        let token = this.getQuery("token");
        let userData = {};
        try {
            var data = await Auth.getUserFromToken(token);
        } catch (err) {
            this.handleError(err)
            return;
        }

        if (data.length <= 0 || data === undefined) { // no token found
            this.response.status(403);
            this.response.json({message: "no token found"});
            return;
        }
        userData = data[0];
        var organizationPrivilegeData = await Org.getOrganizationPrivilegesForUser(token);
        var coursePrivilegeData = await Courses.getCoursePrivilegesForUser(token);
        var courseSubscriptionData = await Courses.getCourseSubscriptionsForUser(token);

        this.response.status(200);
        this.response.json({
            "userId": userData.userId,
            "username": userData.username,
            "email": userData.email,
            "firstName": userData.firstName,
            "lastName": userData.lastName,
            "organizationId": userData.organizationId,
            "organizationPrivilegeData": organizationPrivilegeData,
            "coursePrivilegeData": coursePrivilegeData,
            "courseSubscriptionData": courseSubscriptionData,
        });
    }
    async login() {
        let username = this.getQuery("username");
        let password = this.getQuery("password");
        let organizationId = this.getQuery("organizationId");
        try {
            var token = await Auth.loginUser(username, password, organizationId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"token": token});
    }
    async register() {
        let username = this.getQuery("username");
        let password = this.getQuery("password");
        let email = this.getQuery("email");
        let firstName = this.getQuery("firstName");
        let lastName = this.getQuery("lastName");
        let organizationId = this.getQuery("organizationId");
        let token = "";
        try {
            token = await Auth.registerUser(username, password, email, firstName, lastName, organizationId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"token": token});
    }
    async preregister() {
        let username = this.getQuery("username");
        let password = this.getQuery("password");
        let email = this.getQuery("email");
        let firstName = this.getQuery("firstName");
        let lastName = this.getQuery("lastName");
        let organizationId = this.getQuery("organizationId");
        let userId = "";
        try {
            userId = await Auth.preregisterUser(username, password, email, firstName, lastName, organizationId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"userId": userId});
    }
    async getOrganizations() {
        let token = this.getQuery("token");
        let data;
        try {
            data = await Org.getOrganizationsForUser(token);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async getOrganization() {
        let token = this.getQuery("token");
        let organizationId = this.getQuery("organizationId");
        let orgData;
        try {
            // TODO: there should be an authentication check
            orgData = await Org.getOrganization(organizationId, true);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({
            "data": orgData[0],
        });
    }
    async createOrganization() {
        let token = this.getQuery("token");
        let organizationName = this.getQuery("organizationName");
        let orgData;
        try {
            orgData = await Org.createOrganization(token, {
                organizationName: organizationName,
                email: "",
            });
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({
            "organizationId": orgData.organizationId,
            "organizationPrivilegeId": orgData.organizationPrivilegesId,
        });
    }
    async getCourses() {
        let token = this.getQuery("token");
        let organizationId = this.getQuery("organizationId");
        let data;
        try {
            data = await Courses.getCoursesForOrganization(token, organizationId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async getCourse() {
        let token = this.getQuery("token");
        let courseId = this.getQuery("courseId");
        let courseData;
        try {
            // TODO: there should be an authentication check
            courseData = await Courses.getCourse(courseId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({
            "data": courseData[0],
        });
    }
    async createCourse() {
        let token = this.getQuery("token");
        let organizationId = this.getQuery("organizationId");
        let courseName = this.getQuery("courseName");
        let courseId;
        try {
            courseId = await Courses.addCourse(token, organizationId, {
                courseName: courseName,
                courseDescription: "",
            });

            // this is to add the front page of the course, which is courseSection = 0 and courseElement = 0
            // this also adds starter pages as like a tutorial for the user
            let courseSectionId = await CourseSections.addCourseSection(token, courseId, 
                { courseSectionName: "Front Page Section"}
            );
            await CourseElements.createCourseElement(
                token, 
                courseSectionId,
                3, // front page
                {
                    courseElementName: "Click to edit title",
                    courseElementDescription: "This is an automatically created front page",
                },
                // front page data
                '{"widgetType":"column","children":[{"widgetType":"button","text":"button"},{"widgetType":"text","text":"Click the button above to enroll now!"},{"widgetType":"text","text":"Click this widget to edit this text. Introduce your course to your students and give a detailed description of your syllabus here. You can change the course name under the Settings tab. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam dictum diam id nunc hendrerit, nec sollicitudin lacus tincidunt. Phasellus faucibus efficitur ornare. Nulla rhoncus magna ut arcu consectetur, at condimentum dolor rutrum. Sed id molestie enim, quis fermentum tellus. Donec dictum pellentesque metus vel pretium. Fusce nec lorem id turpis mattis accumsan eget sit amet lacus. Aenean egestas ligula vel lorem finibus elementum. Lorem ipsum dolor sit amet, consectetur adipiscing elit. "}]}'
            );
            let courseSectionId2 = await CourseSections.addCourseSection(token, courseId, 
                { courseSectionName: "Act 1"}
            );
            await CourseElements.createCourseElement(
                token, 
                courseSectionId2,
                1, // reading page element
                {
                    courseElementName: "Scene 1",
                    courseElementDescription: "This is an automatically created front page",
                },
                // empty page data
                '{"widgetType":"column", "children":[]}'
            );
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({
            "courseId": courseId,
        });
    }
    async changeOrganizationOptions () {
        let token = this.getQuery("token");
        let organizationId = this.getQuery("organizationId");
        let organizationName = this.getQuery("organizationName", true);
        let email = this.getQuery("email", true);
        let profilePictureImageId = this.getQuery("profilePictureImageId", true);
        let extraUserDataFields = this.getQuery("extraUserDataFields", true);

        let organizationOptions = {};
        if (organizationName !== null) organizationOptions.organizationName = organizationName;
        if (email !== null) organizationOptions.email = email;
        if (profilePictureImageId !== null) organizationOptions.profilePictureImageId = profilePictureImageId;
        if (extraUserDataFields !== null) organizationOptions.extraUserDataFields = extraUserDataFields;
        if (organizationOptions == {}) throw new Error("needs at least one optional argument");

        try {
            await Org.changeOrganizationOptions(token, organizationId, organizationOptions);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({});
    }
    async changeCourseOptions() {
        let token = this.getQuery("token");
        let courseId = this.getQuery("courseId");
        let courseName = this.getQuery("courseName", true);
        let courseDescription = this.getQuery("courseDescription", true);
        let isLive = this.getQuery("isLive", true);

        let courseOptions = {};
        if (courseName !== null) courseOptions.courseName = courseName;
        if (courseDescription !== null) courseOptions.courseDescription = courseDescription;
        if (isLive !== null) courseOptions.isLive = isLive === "true";
        if (courseOptions == {}) throw new Error("needs at least one optional argument");

        try {
            await Courses.changeCourseOptions(token, courseId, courseOptions);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({});
    }

    async removeCourse() {
        let token = this.getQuery("token");
        let courseId = this.getQuery("courseId");

        try {
            await Courses.removeCourse(token, courseId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({});
    }
    async getCourseHierarchy() {
        let token = this.getQuery("token");
        let courseId = this.getQuery("courseId");
        let calculateLocks = this.getQuery("calculateLocks");
        let data;
        try {
            data = await CourseSections.getCourseHierarchy(courseId, calculateLocks === "true", token);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({
            "data": data,
        });
    }
    async createCourseSection() {
        let token = this.getQuery("token");
        let courseId = this.getQuery("courseId");
        let courseSectionName = this.getQuery("courseSectionName");
        let courseSectionId;

        try {
            courseSectionId = await CourseSections.addCourseSection(token, courseId, 
                { courseSectionName: courseSectionName }
            );
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({
            "courseSectionId": courseSectionId,
        });
    }
    async changeCourseSection() {
        let token = this.getQuery("token");
        let courseSectionId = this.getQuery("courseSectionId");
        let courseSectionName = this.getQuery("courseSectionName");

        try {
            await CourseSections.changeCourseSection(token, courseSectionId, {
                courseSectionName: courseSectionName,
            });
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({});
    }
    async removeCourseSection() {
        let token = this.getQuery("token");
        let courseSectionId = this.getQuery("courseSectionId");

        try {
            await CourseSections.removeCourseSection(token, courseSectionId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({});
    }



    async createCourseElement() {
        let token = this.getQuery("token");
        let courseSectionId = this.getQuery("courseSectionId");
        let courseElementName = this.getQuery("courseElementName");
        let courseElementType = this.getQuery("courseElementType");
        let courseElementDescription = this.getQuery("courseElementDescription");
        let data = this.getQuery("data");
        let courseElementId;

        try {
            courseElementId = await CourseElements.createCourseElement(
                token, 
                courseSectionId,
                parseInt(courseElementType), 
                {
                    courseElementName: courseElementName,
                    courseElementDescription: courseElementDescription,
                },
                data
            );
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({
            "courseElementId": courseElementId,
        });
    }



    async getVideo() {
        // TODO: do auth checks
        let token = this.getQuery("token");
        let videoId = this.getQuery("videoId");
        let video;
        try {
            video = await Videos.getVideo(token, videoId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": video[0]});
    }
    async createVideo() {
        let token = this.getQuery("token");
        let courseId = this.getQuery("courseId");
        let courseElementId = this.getQuery("courseElementId");
        let videoId;

        try {
            videoId = await Videos.createVideo(token, courseId, courseElementId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({
            "videoId": videoId,
        });
    }

    async getImage() {
        // TODO: do auth checks
        let token = this.getQuery("token");
        let imageId = this.getQuery("imageId");
        let image;
        try {
            image = await Videos.getImage(token, imageId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": image[0]});
    }
    async createImage() {
        let token = this.getQuery("token");
        let courseId = this.getQuery("courseId");
        let courseElementId = this.getQuery("courseElementId");
        let auditTaskId = this.getQuery("auditTaskId");
        let imageId;

        try {
            imageId = await Videos.createImage(token, courseId, undefined, courseElementId, auditTaskId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({
            "imageId": imageId,
        });
    }
    async createImageForUser() {
        let token = this.getQuery("token");
        let userId = this.getQuery("userId");
        let imageId;

        try {
            imageId = await Videos.createImage(token, undefined, userId, 0, 0);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({
            "imageId": imageId,
        });
    }



    async getAssessment() {
        // TODO: do auth checks
        let token = this.getQuery("token");
        let auid = this.getQuery("auid");
        let assessment;
        try {
            assessment = await Videos.getAssessment(token, auid);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data":assessment[0]});
    }
    async updateAssessment() {
        // TODO: do auth checks
        let token = this.getQuery("token");
        let auid = this.getQuery("auid");
        let weighting = this.getQuery("weighting");
        let passingPercentage = this.getQuery("passingPercentage");
        let assessmentData = this.getQuery("assessmentData");
        try {
            await Videos.updateAssessment(token, auid, {
                weighting: weighting,
                passingPercentage: passingPercentage,
                assessmentData: assessmentData,
            });
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({});
    }
    async createAssessment() {
        let token = this.getQuery("token");
        let courseElementId = this.getQuery("courseElementId");
        let weighting = this.getQuery("weighting");
        let passingPercentage = this.getQuery("passingPercentage");
        let assessmentData = this.getQuery("assessmentData");
        let auid;

        try {
            auid = await Videos.createAssessment(token, courseElementId, {
                weighting: weighting,
                passingPercentage: passingPercentage,
                assessmentData: assessmentData,
            });
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({
            "auid": auid,
        });
    }
    async removeAssessment() {
        // TODO: do auth checks
        let token = this.getQuery("token");
        let auid = this.getQuery("auid");
        try {
            await Videos.removeAssessment(token, auid);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({});
    }






    async getAssessmentTaskFromAssessment() {
        let token = this.getQuery("token");
        let auid = this.getQuery("auid");
        let assessmentTask;
        try {
            assessmentTask = await Videos.getAssessmentTaskFromAssessment(token, auid);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({
            "data":assessmentTask[0]
        });
    }
    async updateAssessmentTaskFromAssessment() {
        let token = this.getQuery("token");
        let auid = this.getQuery("auid");
        let data = this.getQuery("data");
        try {
            await Videos.updateAssessmentTaskFromAssessment(token, auid, data);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({});
    }
    async createAssessmentTaskFromAssessment() {
        let token = this.getQuery("token");
        let auid = this.getQuery("auid");
        let data = this.getQuery("data");

        try {
            await Videos.createAssessmentTaskFromAssessment(token, 
                auid, 
                data
            );
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({});
    }


    async getCourseElement() {
        // TODO: do auth checks
        let token = this.getQuery("token");
        let courseElementId = this.getQuery("courseElementId");
        let courseElement;
        try {
            courseElement = await CourseElements.getCourseElement(token, courseElementId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": courseElement});
    }
    async changeCourseElementName() {
        let token = this.getQuery("token");
        let courseElementId = this.getQuery("courseElementId");
        let courseElementName = this.getQuery("courseElementName");
        let courseElementDescription = this.getQuery("courseElementDescription");

        try {
            await CourseElements.changeCourseElementName(token, courseElementId, {
                courseElementName: courseElementName,
                courseElementDescription: courseElementDescription,
            });
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({});
    }
    async changeCourseElementData() {
        let token = this.getQuery("token");
        let courseElementId = this.getQuery("courseElementId");
        let data = this.getQuery("data");

        try {
            await CourseElements.changeCourseElementData(token, courseElementId, data
            );
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({});
    }
    async removeCourseElement() {
        let token = this.getQuery("token");
        let courseElementId = this.getQuery("courseElementId");

        try {
            await CourseElements.removeCourseElement(token, courseElementId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({});
    }
    getCompressionStatus() {
        let contentDataId = this.getQuery("contentDataId");
        this.response.status(200);
        this.response.json(VideoData.getCompressionStatus(contentDataId));
    }

    async getOrganizationPrivilege() {
        let token = this.getQuery("token");
        let organizationId = this.getQuery("organizationId");

        try {
            var orgUserPrivilege = await Org.getOrgUserPrivilege(token, organizationId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": orgUserPrivilege});
    }
    async subscribeToCourse() {
        let token = this.getQuery("token");
        let courseId = this.getQuery("courseId");

        try {
            await Payment.subscribeToCourse(token, courseId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({});
    }
    async getAllAssessmentsForCourse() {
        let token = this.getQuery("token");
        let courseId = this.getQuery("courseId");
        let omitStudentGrades = this.getQuery("omitStudentGrades");
        let data;

        try {
            data = await Videos.getAllAssessmentsForCourse(token, courseId, false, omitStudentGrades === "true");
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async getAllStudentsForCourse() {
        let token = this.getQuery("token");
        let courseId = this.getQuery("courseId");
        let data;

        try {
            data = await Courses.getAllStudentsForCourse(token, courseId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async getAssessmentStatsForStudentForCourse() {
        let token = this.getQuery("token");
        let courseId = this.getQuery("courseId");
        let studentUserId = this.getQuery("studentUserId");
        let data;

        try {
            data = await Videos.getAssessmentStatsForStudentForCourse(token, courseId, studentUserId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async getAssessmentStatsForThisStudentForCourse() {
        let token = this.getQuery("token");
        let courseId = this.getQuery("courseId");
        let data;

        try {
            data = await Videos.getAssessmentStatsForThisStudentForCourse(token, courseId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async getCheckoutSessionUrl() {
        let token = this.getQuery("token");
        let orgId = this.getQuery("organizationId");
        let plan = this.getQuery("plan");
        let data;

        try {
            data = await Payment.getCheckoutSessionUrl(token, orgId, parseInt(plan));
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async getPortalSessionUrl() {
        let token = this.getQuery("token");
        let orgId = this.getQuery("organizationId");
        let data;

        try {
            data = await Payment.getPortalSessionUrl(token, orgId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }

    async getCheckoutSessionUrlCourse() {
        let token = this.getQuery("token");
        let courseId = this.getQuery("courseId");
        let data;

        try {
            data = await Payment.getCheckoutSessionUrlCourse(token,courseId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }

    async reportAnalyticsEvent() {
        let analyticsEventType = this.getQuery("analyticsEventType");
        let analyticsEventSubtype = this.getQuery("analyticsEventSubtype");

        try {
            await Analytics.triggerAnalyticsEvent(analyticsEventType, analyticsEventSubtype, null);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200).send();
    }

    async reportAnalyticsForm() {
        let token = this.getQuery("token");
        let analyticsFormType = this.getQuery("analyticsFormType");
        let analyticsFormData = this.getQuery("analyticsFormData");

        // get the userId and append it to the form data type
        let user = await Auth.getUserFromToken(token);
        let userId = user[0].userId;
        analyticsFormData.userId = userId;

        try {
            await Analytics.triggerAnalyticsEvent(5, analyticsFormType, analyticsFormData);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200).send();
    }

    async getAiCourseElementSummary() {
        let token = this.getQuery("token");
        let courseElementId = this.getQuery("courseElementId");
        let data;

        try {
            data = await Ai.getAiCourseElementSummary(token, courseElementId);
            //await Analytics.triggerAnalyticsEvent(analyticsEventType, analyticsEventSubtype, null);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.json({"data": data});
    }
    async askAiCourseElementQuestion() {
        let token = this.getQuery("token");
        let question = this.getQuery("question");
        let courseElementId = this.getQuery("courseElementId");
        let data;

        try {
            data = await Ai.askAiCourseElementQuestion(token, question, courseElementId);
            //await Analytics.triggerAnalyticsEvent(analyticsEventType, analyticsEventSubtype, null);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.json({"data": data});
    }
    async getCourseSalesSettings() {
        let token = this.getQuery("token");
        let courseId = this.getQuery("courseId");
        let data;

        try {
            data = await Payment.getCourseSalesSettings(token, courseId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async changeCourseSalesSettings () {
        let token = this.getQuery("token");
        let courseId = this.getQuery("courseId");
        let coursePrice = this.getQuery("coursePrice", this);
        let coursePriceCurrencyCode = this.getQuery("coursePriceCurrencyCode", true);
        let courseProductName = this.getQuery("courseProductName", this);
        let courseProductDescription = this.getQuery("courseProductDescription", true);

        let courseSalesSettings = {};
        if (coursePrice !== null) courseSalesSettings.coursePrice = coursePrice;
        if (coursePriceCurrencyCode !== null) courseSalesSettings.coursePriceCurrencyCode = coursePriceCurrencyCode;
        if (courseProductName !== null) courseSalesSettings.courseProductName = courseProductName;
        if (courseProductDescription !== null) courseSalesSettings.courseProductDescription = courseProductDescription;
        if (courseSalesSettings == {}) throw new Error("needs at least one optional argument");

        try {
            await Payment.changeCourseSalesSettings(token, courseId, courseSalesSettings);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({});
    }
    async getCourseSalesHistory() {
        let token = this.getQuery("token");
        let courseId = this.getQuery("courseId");
        let data;

        try {
            data = await Payment.getCourseSalesHistory(token, courseId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async getOrganizationBalance() {
        let token = this.getQuery("token");
        let organizationId = this.getQuery("organizationId");
        let data;

        try {
            data = await Payment.getOrganizationBalance(token, organizationId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async getWithdrawals() {
        let token = this.getQuery("token");
        let organizationId = this.getQuery("organizationId");
        let data;

        try {
            data = await Payment.getWithdrawals(token, organizationId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async createWithdrawal() {
        let token = this.getQuery("token");
        let organizationId = this.getQuery("organizationId");
        let withdrawalData = this.getQuery("withdrawalData");
        let data;

        try {
            data = await Payment.createWithdrawal(token, organizationId, withdrawalData);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async createStripeSubscription() {
        let token = this.getQuery("token");
        let organizationId = this.getQuery("organizationId");
        let plan = this.getQuery("plan");
        let currency = this.getQuery("currency");
        let data;

        try {
            data = await Payment.createStripeSubscription(token, organizationId, plan, currency);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async adminPing() {
        let token = this.getQuery("token");
        let data;

        try {
            data = await Admin.ping(token);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async adminGetDb() {
        let token = this.getQuery("token");
        let data;

        try {
            data = await Admin.getDb(token);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async adminCallDb() {
        let token = this.getQuery("token");
        let query = this.getQuery("query");
        let dbKey = this.getQuery("dbKey");
        let data;
        try {
            data = await Admin.callDb(token, query, dbKey);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async createCertificateData() {
        let token = this.getQuery("token");
        let courseId = this.getQuery("courseId");
        let certificateData = this.getQuery("data");
        let data;

        try {
            data = await Certificates.createCertificateData(token, courseId, certificateData);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async getCertificateData() {
        let token = this.getQuery("token");
        let courseId = this.getQuery("courseId");
        let data;

        try {
            data = await Certificates.getCertificateData(token, courseId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async updateCertificateData() {
        let token = this.getQuery("token");
        let courseId = this.getQuery("courseId");
        let certificateData = this.getQuery("data");
        let data;

        try {
            data = await Certificates.updateCertificateData(token, courseId, certificateData);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async sicher_getLectures() {
        let data;

        try {
            data = await Sicher.getLectures();
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async sicher_getLecture() {
        let sicherLectureId = this.getQuery("sicherLectureId");
        let data;

        try {
            data = await Sicher.getLecture(sicherLectureId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async sicher_createLecture() {
        let sicherAdminToken = this.getQuery("sicherAdminToken");

        let lectureName = this.getQuery("lectureName");
        let cost = this.getQuery("cost");
        let dateHeld = this.getQuery("dateHeld");
        let venue = this.getQuery("venue");
        let instructors = this.getQuery("instructors");
        let sicherLectureData = this.getQuery("data");

        let data;
        let sicherLectureId;

        try {
            sicherLectureId = await Sicher.createLecture(
                sicherAdminToken,
                lectureName,
                cost,
                dateHeld,
                venue,
                instructors,
                sicherLectureData,
            );
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"sicherLectureId": sicherLectureId});
    }
    async sicher_changeLecture() {
        let sicherAdminToken = this.getQuery("sicherAdminToken");
        let sicherLectureId = this.getQuery("sicherLectureId");

        let lectureName = this.getQuery("lectureName");
        let cost = this.getQuery("cost");
        let dateHeld = this.getQuery("dateHeld");
        let venue = this.getQuery("venue");
        let instructors = this.getQuery("instructors");
        let sicherLectureData = this.getQuery("data");

        let data;

        try {
            await Sicher.changeLecture(
                sicherAdminToken,
                sicherLectureId,
                lectureName,
                cost,
                dateHeld,
                venue,
                instructors,
                sicherLectureData,
            );
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({});
    }
    async sicher_removeLecture() {
        let sicherAdminToken = this.getQuery("sicherAdminToken");
        let sicherLectureId = this.getQuery("sicherLectureId");
        let data;

        try {
            await Sicher.removeLecture(sicherAdminToken, sicherLectureId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({});
    }
    async sicher_getTopLectures() {
        let data;

        try {
            data = await Sicher.getTopLectures();
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async sicher_createBooking() {
        let sicherTrainingId = this.getQuery("sicherTrainingId");
        let token = this.getQuery("token");

        try {
            var data = await Sicher.createBooking(sicherTrainingId, token);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async sicher_getBooking() {
        let sicherBookingId = this.getQuery("sicherBookingId");

        try {
            var data = await Sicher.getBooking(sicherBookingId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async forgotPassword() {
        const username = this.getQuery("username");
        const organizationId = this.getQuery("organizationId");

        try {
            await Auth.forgotPasswordUser(username, organizationId);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({});
    }
    async resetPassword() {
        const forgotPasswordToken = this.getQuery("forgotPasswordToken");
        const password = this.getQuery("password");

        try {
            await Auth.resetPasswordUser(forgotPasswordToken, password);
        } catch (err) {
            this.handleError(err);
            return;
        }
        this.response.status(200);
        this.response.json({});
    }
    async fleet_getFleetFlightplanFromUser() {
        try {
            const data = await Fleet.getFleetFlightplanFromUser(
                this.getQuery("userId")
            );
            this.response.status(200);
            this.response.json({"data": data});
        } catch (err) {
            this.handleError(err);
        }
    }
}

module.exports.Router = Router;
