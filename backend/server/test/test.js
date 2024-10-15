const Db = require('../database');
const Auth = require('../auth');
const Org = require('../organizations');
const Courses = require('../courses');
const CourseSections = require('../courseSections');
const CourseElements = require('../courseElements');
const Payment = require('../payment');
const Analytics = require('../analytics');

const Token = require('../token');

var assert = require('assert');
const { debug } = require('console');

assert.exists = function (obj, msg) {
    if (obj === undefined) {
        assert.fail(msg)
    }
}
const testOrm = require('../orm/test/test');
const testAuth = require('./auth');

module.exports.runTests = runTests;
async function runTests() {
    await testAuth.runTests();
    await testOrm.runTests();
}
runTests();


/*
describe('Database', function () {
    it('should connect to the SQL server', async function () {
        Db.sqlConnect();
    });
    let testingTable;
    it('should initialize & clear table', async function () {

        testingTable = new Db.DatabaseTable("Tests",
            "testId",
            [
                {
                name: "username",
                type: "varchar(50)"
                },
                {
                name: "password",
                type: "varchar(32)"
                },
                {
                name: "idx",
                type: "int"
                }
            ]
        );
        await testingTable.init();
        await testingTable.drop();
        await testingTable.init();

        // check
        let data = await testingTable.select();
        assert.equal(data.length, 0);
    });
    it('should insert into table', async function () {
        await testingTable.insertInto(
        {
            username: "cat",
            password: "bat",
            idx: 1,
        });
        await testingTable.insertInto(
        {
            username: "cat",
            password: "mat",
            idx: 2,
        });

        // check
        let data = await testingTable.select();
        assert.equal(data.length, 2);
        assert.equal(data[0].testId, 1);
        assert.equal(data[0].username, "cat");
        assert.equal(data[0].password, "bat");
        assert.equal(data[1].testId, 2);
        assert.equal(data[1].username, "cat");
        assert.equal(data[1].password, "mat");
    });
    it('should get maximum value of column', async function () {
        let data = await testingTable.selectMax("idx", {username: "cat"});
        assert.equal(data.idx, 2);
    });
    it('should delete from table', async function () {
        await testingTable.deleteFrom(
            {password: "mat"},
        );

        // check
        let data = await testingTable.select();
        assert.equal(data.length, 1);
        assert.equal(data[0].testId, 1);
        assert.equal(data[0].username, "cat");
        assert.equal(data[0].password, "bat");
    });
    it('should update table', async function () {
        await testingTable.update(
            // where...
            {username: "cat"},
            // set entry to...
            {
                username: "bat",
                password: "nat",
            }
        );

        // check
        let data = await testingTable.select();
        assert.equal(data.length, 1);
        assert.equal(data[0].testId, 1);
        assert.equal(data[0].username, "bat");
        assert.equal(data[0].password, "nat");
    });
});
*/

/*
describe('Authentication', function () {
    let randomName = Token.generateToken();
    let token = "";
    it('should create a Storybridge user', async function () {
        try {
            token = await Auth.loginUser("test", "password", 0);
            await Auth.deleteUser(token, "password");
        } catch {

        }
        token = await Auth.registerUser("test", "password", "test@test.com", randomName, "lastName",0 );

        let data = await Auth.getUserFromToken(token);
        let user = data[0];
        assert.equal(user.username, "test");
        assert.equal(user.firstName, randomName);
    });
    it('should NOT create duplicate Storybridge user', async function () {
        await assert.rejects(
            async function () { 
                await Auth.registerUser("test", "password", "test@test.com", "firstName", "lastName",0);
            }
        );
    });
    it('should create duplicate user for specific org', async function () {
        try {
            token = await Auth.loginUser("test", "password", 1);
            await Auth.deleteUser(token, "password");
        } catch {

        }
        token = await Auth.registerUser("test", "password", "test@test.com", randomName, "lastName",1 );

        let data = await Auth.getUserFromToken(token);
        let user = data[0];
        assert.equal(user.username, "test");
        assert.equal(user.firstName, randomName);
    });
    it('should login Storybridge user', async function () {
        token = await Auth.loginUser("test", "password",0);

        let data = await Auth.getUserFromToken(token);
        let user = data[0];
        assert.equal(user.firstName, randomName);
    });
    it('should login user for specific organization', async function () {
        token = await Auth.loginUser("test", "password",1);

        let data = await Auth.getUserFromToken(token);
        let user = data[0];
        assert.equal(user.firstName, randomName);
    });
    it('should NOT login user with wrong username', async function () {
        await assert.rejects(
            async function () { 
                await Auth.loginUser(`test_${randomName}`, "password",0);
            }
        );
    });
    it('should logout user', async function () {
        await Auth.logoutUser(token);
        let data = await Auth.getUserFromToken(token);
        assert.equal(data.length, "0");
    });
    it('should delete user', async function () {
        token = await Auth.loginUser("test", "password",0);
        await Auth.deleteUser(token, "password");
        token = await Auth.loginUser("test", "password",1);
        await Auth.deleteUser(token, "password");

        let data = await Auth.getUserFromToken(token);
        assert.equal(data.length, "0");

        // login should fail
        await assert.rejects(
            async function () { 
                await Auth.loginUser("test", "password",0);
            }
        );
    });
});

describe('Privilege Structure Tests', function () {
    describe('Organizations & Privileges', function () {
        let randomName = Token.generateToken();
        let orgId;
        let orgPrivId;
        let tokenA;
        let tokenB;
        it('init', async function () {
            // create user
            try {
                tokenA = await Auth.loginUser("test", "password",0);
                await Auth.deleteUser(tokenA, "password");
            } catch {
            }
            tokenA = await Auth.registerUser("test", "password", "test@test.com", randomName, "lastName",0);
        });
        it('should add organization', async function () {
            let orgData = await Org.createOrganization(tokenA, {
                organizationName: `TestOrg${randomName}_e`,
                email: "a@a.a",
            });
            orgId = orgData.organizationId;
            orgPrivId = orgData.organizationPrivilegesId;
            let data = await Org.getOrganization(orgId);
            assert.equal(data[0].organizationName, `TestOrg${randomName}_e`);
            assert.equal(data[0].email, `a@a.a`);
        });
        it('should change organization options', async function () {
            let data = await Org.getOrganization(orgId);
            assert.equal(data[0].organizationName, `TestOrg${randomName}_e`);

            // change only orgName
            await Org.changeOrganizationOptions(tokenA, orgId, {organizationName: `TestOrg${randomName}`});
            data = await Org.getOrganization(orgId);
            assert.equal(data[0].organizationName, `TestOrg${randomName}`);
            assert.equal(data[0].email, `a@a.a`);

            // change only email
            await Org.changeOrganizationOptions(tokenA, orgId, {email: `b@b.b`});
            data = await Org.getOrganization(orgId);
            assert.equal(data[0].organizationName, `TestOrg${randomName}`);
            assert.equal(data[0].email, `b@b.b`);
        });
        it('should adds the creator as owner when adding organization', async function () {
            let dataOrgPriv = await Org.getOrganizationPrivileges(orgPrivId);
            assert.equal(dataOrgPriv.length, 1);
            assert.equal(Db.readBool(dataOrgPriv[0].isOwner), true);
            let dataOrgPrivUser = await Auth.getUserFromUserId(dataOrgPriv[0].userId);
            assert.equal(dataOrgPrivUser[0].username, "test");
        });
        it('should assign new user to organization', async function () {
            try {
                tokenB = await Auth.loginUser("test2", "password",0);
                await Auth.deleteUser(tokenB, "password");
            } catch {
            }
            tokenB = await Auth.registerUser("test2", "password", "test@test.com", `a_${randomName}`, "lastName",0);
            orgPrivId = await Org.assignUserToOrganization(tokenA, "test2", orgId, {
                canAnalyzeAll: true,
                canEditAll: true,
                canTeachAll: true,
                isAdmin: false,
                isOwner: false,
            });
            let dataOrgPriv = await Org.getOrganizationPrivileges(orgPrivId);
            assert.equal(dataOrgPriv.length, 1);
            assert.equal(Db.readBool(dataOrgPriv[0].isOwner), false);
        });
        it('should show that user B has access to that organization', async function () {
            let data = await Org.getOrganizationsForUser(tokenB);
            assert.equal(data.length, 1);
            assert.equal(data[0].organizationId, orgId);
        });
        it('should NOT add duplicate user to organization', async function () {
            // should fail
            await assert.rejects(
                async function () { 
                    await Org.assignUserToOrganization(tokenA, "test2", orgId, {
                canAnalyzeAll: true,
                canEditAll: true,
                canTeachAll: true,
                isAdmin: false,
                isOwner: false,
                    });
                }
            );
        });
        it('should NOT allow non-admins to edit other org users', async function () {
            // should fail
            await assert.rejects(
                async function () { 
                    await Org.assignUserToOrganization(tokenB, "test", orgId, {
                canAnalyzeAll: true,
                canEditAll: true,
                canTeachAll: true,
                isAdmin: false,
                isOwner: false,
                    });
                }
            );
        });
        it('should change teacher organization privilege', async function () {
            await Org.changeUserOrganizationPrivilege(tokenA, "test2", orgId, {
                canAnalyzeAll: true,
                canEditAll: true,
                canTeachAll: true,
                isAdmin: true,
                isOwner: false,
            });
            let dataOrgPriv = await Org.getOrganizationPrivileges(orgPrivId);
            assert.equal(dataOrgPriv.length, 1);
            assert.equal(Db.readBool(dataOrgPriv[0].isAdmin), true);
        });
        it('should deassign teacher from organization', async function () {
            await Org.deassignUserFromOrganization(tokenA, "test2", orgId);
            let dataOrgPriv = await Org.getOrganizationPrivileges(orgPrivId);
            assert.equal(dataOrgPriv.length, 0);
        });
        it('should NOT allow non-owners to delete their organization', async function () {
            await assert.rejects(
                async function () { 
                    await Org.deleteOrganization(tokenB, orgId);
                }
            );
        });
        it('should delete organization', async function () {
            await Org.deleteOrganization(tokenA, orgId);
            let data = await Org.getOrganization(orgId);
            assert.equal(data.length, 0);
        });
        it('cleanup', async function () {
            Auth.deleteUser(tokenA, "password");
            Auth.deleteUser(tokenB, "password");
        });
    });

    describe('Courses & Privileges', function () {
        let randomName = Token.generateToken();
        let orgId;
        let orgPrivId;
        let tokenA;
        let tokenB;
        let courseId;
        let coursePrivId;
        it('init', async function () {
            // create users
            try {
                tokenA = await Auth.loginUser("test", "password",0);
                await Auth.deleteUser(tokenA, "password");
            } catch {
            }
            tokenA = await Auth.registerUser("test", "password", "test@test.com", randomName, "lastName",0);
            try {
                tokenB = await Auth.loginUser("test2", "password",0);
                await Auth.deleteUser(tokenB, "password");
            } catch {
            }
            tokenB = await Auth.registerUser("test2", "password", "test@test.com", randomName, "lastName",0);

            // create organizations
            let orgData = await Org.createOrganization(tokenA, {
                organizationName: `TestOrg${randomName}`,
                email: "",
            });
            orgId = orgData.organizationId;
            orgPrivId = orgData.organizationPrivilegesId;
        });
        it('should add new course', async function () {
            courseId = await Courses.addCourse(tokenA, orgId, {
                courseName: `test_course_${randomName}`,
                courseDescription: "wow",
            });
            let data = await Courses.getCourse(courseId);
            assert.equal(data.length, 1);
            assert.equal(data[0].courseName, `test_course_${randomName}`);
            assert.equal(data[0].organizationId, orgId);
        });
        it('should get courses from organization', async function () {
            data = await Courses.getCoursesForOrganization(tokenA, orgId);
            assert.equal(data.length, 1);
            assert.equal(data.length, 1);
        });
        it('should NOT add new course if not allowed', async function () {
            await assert.rejects(
                async function () {
                    courseId = await Courses.addCourse(tokenB, orgId, {
                        courseName: `test_course_${randomName}`,
                        courseDescription: "wow",
                    });
                }
            );
        });
        it('should NOT assign non-organization members to course', async function () {
            await assert.rejects(
                async function () {
                    coursePrivId = await Org.assignUserToCourse(tokenA, "test2", courseId, {
                        canAnalyze: true,
                        canEdit: true,
                        canTeach: true,
                    });
                }
            );
            data = await Courses.getAllCoursePrivilegesForOrganization(orgId);
            assert.equal(data.length, 0);
        });
        it('should assign others to course', async function () {
            data = await Courses.getAllCoursePrivilegesForOrganization(orgId);
            assert.equal(data.length, 0);

            // now test it
            coursePrivId = await Courses.assignUserToCourse(tokenA, "test2", courseId, {
                canAnalyze: true,
                canEdit: true,
                canTeach: true,
                isAdmin: true,
            });

            // checks
            data = await Courses.getCoursePrivilege(coursePrivId);
            assert.equal(data.length, 1);
            assert.equal(data[0].courseId,courseId);
            data = await Courses.getAllCoursePrivilegesForOrganization(orgId);
            assert.equal(data.length, 1);
        });
        it('should change teacher course privilege', async function () {
            data = await Courses.getCoursePrivilege(coursePrivId);
            assert.equal(data.length, 1);
            assert.equal(Db.readBool(data[0].canEdit), true);

            await Courses.changeUserCoursePrivilege(tokenA, "test2", courseId, {
                canAnalyze: true,
                canEdit: false,
                canTeach: true,
                isAdmin: true,
            });

            data = await Courses.getCoursePrivilege(coursePrivId);
            assert.equal(data.length, 1);
            assert.equal(Db.readBool(data[0].canEdit), false);
        });
        it('should change course options', async function () {
            data = await Courses.getCourse(courseId);
            assert.equal(data[0].courseName, `test_course_${randomName}`);
            await Courses.changeCourseOptions(tokenA, courseId,
            {
                courseName:`test_course_2_${randomName}`,
                courseDescription:"testcourse"
            }
            );
            data = await Courses.getCourse(courseId);
            assert.equal(data[0].courseName, `test_course_2_${randomName}`);
            assert.equal(data[0].courseDescription, `testcourse`);

            // change only description
            await Courses.changeCourseOptions(tokenA, courseId,
            {
                courseDescription:"testcourse2"
            }
            );
            data = await Courses.getCourse(courseId);
            assert.equal(data[0].courseName, `test_course_2_${randomName}`);
            assert.equal(data[0].courseDescription, `testcourse2`);
        });
        it('should change course liveness', async function () {
            data = await Courses.getCourse(courseId);
            assert.equal(Db.readBool(data[0].isLive), false);
            await Courses.changeCourseLiveness(tokenA, courseId, true);
            data = await Courses.getCourse(courseId);
            assert.equal(Db.readBool(data[0].isLive), true);
        });
        it('should change course is mooc', async function () {
            data = await Courses.getCourse(courseId);
            assert.equal(Db.readBool(data[0].isMooc), false);
            await Courses.changeCourseMoocness(tokenA, courseId, true);
            data = await Courses.getCourse(courseId);
            assert.equal(Db.readBool(data[0].isMooc), true);
        });
        it('should NOT change course liveness for underprivileged users', async function () {
            data = await Courses.getCourse(courseId);
            assert.equal(Db.readBool(data[0].isLive), true);
            await Courses.changeUserCoursePrivilege(tokenA, "test2", courseId, {
                canAnalyze: true,
                canEdit: false,
                canTeach: true,
                isAdmin: false,
            });
            await assert.rejects(
                async function () {
                    await Courses.changeCourseLiveness(tokenB, courseId, false);
                }
            );
            data = await Courses.getCourse(courseId);
            assert.equal(Db.readBool(data[0].isLive), true);
        });
        it('should deassign teacher from course', async function () {
            data = await Courses.getAllCoursePrivilegesForOrganization(orgId);
            assert.equal(data.length, 1);
            await Courses.deassignUserFromCourse(tokenA, "test2", courseId);
            data = await Courses.getAllCoursePrivilegesForOrganization(orgId);
            assert.equal(data.length, 0);
        });
        it('should remove course', async function () {
            data = await Courses.getAllCoursePrivilegesForOrganization(orgId);
            assert.equal(data.length, 0);
            data = await Courses.getCourse(courseId);
            assert.equal(data.length, 1);
            await Courses.removeCourse(tokenA, courseId);
            data = await Courses.getAllCoursePrivilegesForOrganization(orgId);
            assert.equal(data.length, 0);
            data = await Courses.getCourse(courseId);
            assert.equal(data.length, 0);
        });
        it('should remove courses when organization is deleted', async function () {
            // create course
            courseId = await Courses.addCourse(tokenA, orgId, {
                courseName: `test_course_${randomName}`,
                courseDescription: "wow",
            });
            data = await Courses.getAllCoursePrivilegesForOrganization(orgId);
            assert.equal(data.length, 0);
            data = await Courses.getCourse(courseId);
            assert.equal(data.length, 1);

            // remove organization
            await Org.deleteOrganization(tokenA, orgId);

            data = await Courses.getCourse(courseId);
            assert.equal(data.length, 0);
        });
        it('should remove course privileges when organization is deleted', async function () {
            data = await Courses.getAllCoursePrivilegesForOrganization(orgId);
            assert.equal(data.length, 0);
        });
        it('cleanup', async function () {
            Auth.deleteUser(tokenA, "password");
            Auth.deleteUser(tokenB, "password");
        });
    });
});

describe('Course Development Tests', function () {
    describe('Courses Sections', function () {
        let randomName = Token.generateToken();
        let orgId;
        let orgPrivId;
        let tokenA;
        let tokenB;
        let courseId;
        let csid;
        let courseSectionId;
        it('init', async function () {
            // create users
            try {
                tokenA = await Auth.loginUser("test", "password",0);
                await Auth.deleteUser(tokenA, "password");
            } catch {
            }
            tokenA = await Auth.registerUser("test", "password", "test@test.com", randomName, "lastName",0);
            try {
                tokenB = await Auth.loginUser("test2", "password",0);
                await Auth.deleteUser(tokenB, "password");
            } catch {
            }
            tokenB = await Auth.registerUser("test2", "password", "test@test.com", randomName, "lastName",0);
            // create organization
            let orgData = await Org.createOrganization(tokenA, {
                organizationName: `TestOrg${randomName}`,
                email: "",
            });
            orgId = orgData.organizationId;
            orgPrivId = orgData.organizationPrivilegesId;
            // create course
            courseId = await Courses.addCourse(tokenA, orgId, {
                courseName: `test_course_${randomName}`,
                courseDescription: "wow",
            });
        });
        it('should add course section to course', async function () {
            let data = await CourseSections.getAllCourseSectionsFromCourse(courseId);
            assert.equal(data.length, 0);
            courseSectionId = await CourseSections.addCourseSection(tokenA, courseId, 
                { courseSectionName: "section_1" }
            );
            data = await CourseSections.getAllCourseSectionsFromCourse(courseId);
            assert.equal(data.length, 1);
        });
        it('should not allow non permission to edit', async function () {
            data = await CourseSections.getAllCourseSectionsFromCourse(courseId);
            assert.equal(data.length, 1);
            await assert.rejects(
                async function () { 
                    await CourseSections.addCourseSection(tokenB, courseId, 
                        { courseSectionName: "section_2" }
                    );
                }
            );
            data = await CourseSections.getAllCourseSectionsFromCourse(courseId);
            assert.equal(data.length, 1);
        });
        it('should change course section', async function () {
            let data = await CourseSections.getCourseSection(courseSectionId);
            assert.equal(data[0].courseSectionName, "section_1");
            await CourseSections.changeCourseSection(tokenA, courseSectionId, 
                { courseSectionName: "section_1_edited" }
            );
            data = await CourseSections.getCourseSection(courseSectionId);
            assert.equal(data[0].courseSectionName, "section_1_edited");
        });
        it('should have correct section order when adding', async function () {
            data = await CourseSections.getAllCourseSectionsFromCourse(courseId);
            assert.equal(data.length, 1);
            csid = await CourseSections.addCourseSection(tokenA, courseId, 
                { courseSectionName: "section_2" }
            );
            data = await CourseSections.getAllCourseSectionsFromCourse(courseId);
            assert.equal(data.length, 2);
            assert.equal(data[0].sectionOrder, 0);
            assert.equal(data[1].sectionOrder, 1);
        });
        it('should move course section order', async function () {
            await CourseSections.addCourseSection(tokenA, courseId, 
                { courseSectionName: "section_3" }
            );
            await CourseSections.addCourseSection(tokenA, courseId, 
                { courseSectionName: "section_4" }
            );
            await CourseSections.addCourseSection(tokenA, courseId, 
                { courseSectionName: "section_5" }
            );
            await CourseSections.moveCourseSection(csid, 3);
            data = await CourseSections.getAllCourseSectionsFromCourse(courseId);
            assert.equal(data.length, 5);
            assert.equal(data[0].sectionOrder, 0);
            assert.equal(data[1].sectionOrder, 3);
            assert.equal(data[2].sectionOrder, 1);
            assert.equal(data[3].sectionOrder, 2);
            assert.equal(data[4].sectionOrder, 4);
        });
        it('should remove course section from course', async function () {
            data = await CourseSections.getAllCourseSectionsFromCourse(courseId);
            assert.equal(data.length, 5);
            await CourseSections.removeCourseSection(tokenA, courseSectionId);
            data = await CourseSections.getAllCourseSectionsFromCourse(courseId);
            assert.equal(data.length, 4);
        });
        it('should redo section order after removal', async function () {
            data = await CourseSections.getAllCourseSectionsFromCourse(courseId);
            assert.equal(data.length, 4);
            assert.equal(data[0].sectionOrder, 2);
        });
        it('should remove course sections when course is deleted', async function () {
            data = await CourseSections.getAllCourseSectionsFromCourse(courseId);
            assert.equal(data.length, 4);
            await Courses.removeCourse(tokenA, courseId);
            data = await CourseSections.getAllCourseSectionsFromCourse(courseId);
            assert.equal(data.length, 0);
        });
        it('cleanup', async function () {
            await Org.deleteOrganization(tokenA, orgId);
            Auth.deleteUser(tokenA, "password");
        });
    });
    describe('Videos & Forms', function () {
        let randomName = Token.generateToken();
        let orgId;
        let tokenA;
        let tokenB;
        let courseId;
        let courseSectionId;
        let courseElementId;
        it('init', async function () {
            // create users
            try {
                tokenA = await Auth.loginUser("test", "password",0);
                await Auth.deleteUser(tokenA, "password");
            } catch {
            }
            tokenA = await Auth.registerUser("test", "password", "test@test.com", randomName, "lastName",0);
            try {
                tokenB = await Auth.loginUser("test2", "password",0);
                await Auth.deleteUser(tokenB, "password");
            } catch {
            }
            tokenB = await Auth.registerUser("test2", "password", "test@test.com", randomName, "lastName",0);
            // create organization
            let orgData = await Org.createOrganization(tokenA, {
                organizationName: `TestOrg${randomName}`,
                email: "",
            });
            orgId = orgData.organizationId;
            orgPrivId = orgData.organizationPrivilegesId;
            // create course
            courseId = await Courses.addCourse(tokenA, orgId, {
                courseName: `test_course_${randomName}`,
                courseDescription: "wow",
            });
            courseSectionId = await CourseSections.addCourseSection(tokenA, courseId, 
                { courseSectionName: "section_1" }
            );
        });
        it('should add video courseElement', async function () {
            let data = await CourseElements.getAllElementsFromCourseSection(courseSectionId);
            assert.equal(data.length, 0);
            courseElementId = await CourseElements.createCourseElement(tokenA, courseSectionId, 0, {
                courseElementName: "bob",
                courseElementDescription: "this is a description",
            },
            "data_sample"
            );
            data = await CourseElements.getAllElementsFromCourseSection(courseSectionId);
            assert.equal(data.length, 1);
            assert.equal(data[0].courseElementName, "bob");
            assert.equal(data[0].courseElementType, 0);
            assert.equal(data[0].data, "data_sample");
        });
        it('should get data from courseElement', async function () {
            data = await CourseElements.getCourseElement(tokenA, courseElementId);
            assert.equal(data[0].data, "data_sample");
        });
        it('should give course hierarchy', async function () {
            await CourseSections.addCourseSection(tokenA, courseId, 
                { courseSectionName: "section_2" }
            );
            let data = await CourseSections.getCourseHierarchy(courseId);
            assert.equal(data.length, 2);
            assert.equal(data[0].children.length, 1);
            assert.equal(data[0].children[0].courseElementName, "bob");
            assert.equal(data[0].children[0].courseElementType, 0);
        });
        it('should have correct element order when adding', async function () {
            await CourseElements.createCourseElement(tokenA, courseSectionId, 0, {
                courseElementName: "video_2",
                courseElementDescription: "this is a description",
            }, "");
            let data = await CourseSections.getCourseHierarchy(courseId);
            assert.equal(data[0].children.length, 2);
            assert.equal(data[0].children[0].elementOrder, 0);
            assert.equal(data[0].children[1].elementOrder, 1);
        });
        it('should change course elements', async function () {
            await CourseElements.createCourseElement(tokenA, courseSectionId, 0, {
                courseElementName: "video_3",
                courseElementDescription: "this is a description",
            }, "");
            courseElementId = await CourseElements.createCourseElement(tokenA, courseSectionId, 2, {
                courseElementName: "form",
                courseElementDescription: "this is a description",
            }, "");
            data = await CourseElements.getAllElementsFromCourseSection(courseSectionId);
            assert.equal(data.length, 4);
            assert.equal(data[3].courseElementName, "form");
            await CourseElements.changeCourseElementName(tokenA, courseElementId, {
                courseElementName: "form_edited",
                courseElementDescription: "",
            });
            data = await CourseElements.getAllElementsFromCourseSection(courseSectionId);
            assert.equal(data.length, 4);
            assert.equal(data[3].courseElementName, "form_edited");
        });
        it('should move course element order', async function () {
            await CourseElements.createCourseElement(tokenA, courseSectionId, 0, {
                courseElementName: "video_5",
                courseElementDescription: "this is a description",
            }, "");
            await CourseElements.moveCourseElement(courseElementId, 1);
            let data = await CourseSections.getCourseHierarchy(courseId);
            assert.equal(data[0].children.length, 5);
            assert.equal(data[0].children[0].elementOrder, 0);
            assert.equal(data[0].children[1].elementOrder, 2);
            assert.equal(data[0].children[2].elementOrder, 3);
            assert.equal(data[0].children[3].elementOrder, 1);
            assert.equal(data[0].children[4].elementOrder, 4);
        });
        it('should remove course elements', async function () {
            data = await CourseSections.getCourseHierarchy(courseId);
            assert.equal(data[0].children.length, 5);
            await CourseElements.removeCourseElement(tokenA, courseElementId);
            data = await CourseSections.getCourseHierarchy(courseId);
            assert.equal(data[0].children.length, 4);
        });
        it('should remove course elements when course sections is deleted', async function () {
            await CourseSections.removeCourseSection(tokenA, courseSectionId);
            data = await CourseSections.getCourseHierarchy(courseId);
            assert.equal(data.length, 1);
            assert.equal(data[0].children.length, 0);
        });
        it('cleanup', async function () {
            await Org.deleteOrganization(tokenA, orgId);
            Auth.deleteUser(tokenA, "password");
        });
    });
    describe('Subscriptions', function () {
        let randomName = Token.generateToken();
        let orgId;
        let tokenA;
        let courseId;
        it('init', async function () {
            // create users
            try {
                tokenA = await Auth.loginUser("test", "password",0);
                await Auth.deleteUser(tokenA, "password");
            } catch {
            }
            tokenA = await Auth.registerUser("test", "password", "test@test.com", randomName, "lastName",0);
            // create organization
            let orgData = await Org.createOrganization(tokenA, {
                organizationName: `TestOrg${randomName}`,
                email: "",
            });
            orgId = orgData.organizationId;
            orgPrivId = orgData.organizationPrivilegesId;
            // create course
            courseId = await Courses.addCourse(tokenA, orgId, {
                courseName: `test_course_${randomName}`,
                courseDescription: "wow",
            });
        });
        it('subscribe user to course', async function () {
            let courseSubscriptions = await Courses.getCourseSubscriptionsForUser(tokenA);
            assert.equal(courseSubscriptions.length, 0);
            await Courses.subscribeToCourse(tokenA, courseId);
            courseSubscriptions = await Courses.getCourseSubscriptionsForUser(tokenA);
            assert.equal(courseSubscriptions.length, 1);
        });
        it('unsubscribe user from course', async function () {
            let courseSubscriptions = await Courses.getCourseSubscriptionsForUser(tokenA);
            assert.equal(courseSubscriptions.length, 1);
            await Courses.unsubscribeToCourse(tokenA, courseId);
            courseSubscriptions = await Courses.getCourseSubscriptionsForUser(tokenA);
            assert.equal(courseSubscriptions.length, 0);
        });
        it('deleting course should remove user subscriptions', async function () {
            await Courses.subscribeToCourse(tokenA, courseId);
            courseSubscriptions = await Courses.getCourseSubscriptionsForUser(tokenA);
            assert.equal(courseSubscriptions.length, 1);
            await Courses.removeCourse(tokenA, courseId);
            courseSubscriptions = await Courses.getCourseSubscriptionsForUser(tokenA);
            assert.equal(courseSubscriptions.length, 0);
        });
        it('cleanup', async function () {
            await Org.deleteOrganization(tokenA, orgId);
            Auth.deleteUser(tokenA, "password");
        });
    });
});

describe('Analytics', function () {
    describe('gather analytics', function () {
        it('trigger analytics w/o eventData', async function () {
            let randomNumber = Math.floor(Math.random() * 255);
            await Analytics.triggerAnalyticsEvent(0, randomNumber, null);
            let data = await Analytics.getAnalyticEvents(0);
            assert.equal(data[data.length - 1].analyticsEventType, 0);
            assert.equal(data[data.length - 1].analyticsEventSubtype, randomNumber);
        });
        it('trigger analytics w/ eventData', async function () {
            let randomNumber = Math.floor(Math.random() * 255);
            await Analytics.triggerAnalyticsEvent(0, randomNumber, {token: randomNumber});
            let data = await Analytics.getAnalyticEvents(0);
            assert.equal(data[data.length - 1].analyticsEventType, 0);
            assert.equal(data[data.length - 1].analyticsEventSubtype, randomNumber);
            data = await Analytics.getAnalyticEventData(data[data.length - 1].analyticsEventDataId);
            assert.equal(data[0].analyticsEventData.token, randomNumber);

        });
    });
});
*/
/*
mocha.describe('Template', function () {
    mocha.describe('test 1', function () {
        mocha.it('test', async function () {
        });
    });
});
*/