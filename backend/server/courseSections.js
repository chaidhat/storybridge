const Db = require('./database');
const Auth = require('./auth');
const Org = require('./organizations');
const Courses = require('./courses');
const CourseElements = require('./courseElements');
const Videos = require('./videos');

var courseSections = new Db.DatabaseTable("CourseSections",
    "courseSectionId",
    [
        {
        "name": "courseId",
        "type": "int"
        },
        {
        "name": "courseSectionName",
        "type": "varchar(1023)"
        },
        {
        "name": "dateCreated",
        "type": "datetime"
        },
        {
        "name": "dateModified",
        "type": "datetime"
        },
        {
        "name": "sectionOrder",
        "type": "int"
        },
]);
courseSections.init();

module.exports.addCourseSection = addCourseSection;
async function addCourseSection (token, courseId, courseSectionOptions) {
    // check auth
    await Courses.assertUserCanEditCourse(token, courseId);

    // find element order
    let sectionOrder = await _getNextSectionOrder(courseId);

    // perform length checks
    if (encodeURI(courseSectionOptions.courseSectionName).length > 1023) {
        throw {status: 403, message: "courseSectionName is too long! (>1023 chars)"};
    }

    let courseSectionId = await courseSections.insertInto({
        courseId: courseId,
        courseSectionName: courseSectionOptions.courseSectionName,
        dateCreated: Db.getDatetime(),
        dateModified: Db.getDatetime(),
        sectionOrder: sectionOrder,
    });
    return courseSectionId;
}

module.exports.changeCourseSection = changeCourseSection;
async function changeCourseSection (token, courseSectionId, courseSectionOptions) {
    // check auth
    await assertUserCanEditCourseSection(token, courseSectionId);

    // perform length checks
    if (courseSectionOptions.courseSectionName != null) {
        if (encodeURI(courseSectionOptions.courseSectionName).length > 1023) {
            throw {status: 403, message: "courseSectionName is too long! (>1023 chars)"};
        }
    }

    await courseSections.update(
        { courseSectionId: courseSectionId, },
        { courseSectionName: courseSectionOptions.courseSectionName, }
    );
}

module.exports.removeCourseSection = removeCourseSection;
async function removeCourseSection (token, courseSectionId) {
    // check auth
    await assertUserCanEditCourseSection(token, courseSectionId);

    // remove element order
    let courseSection = await courseSections.select({ courseSectionId: courseSectionId });
    await _removeSectionOrder(courseSection[0].sectionOrder, courseSection[0].courseId);
    await CourseElements.removeAllCourseElementsFromCourseSection(courseSection[0].courseSectionId);

    courseSections.deleteFrom({ courseSectionId: courseSectionId, });
}

module.exports.removeAllCourseSectionsFromCourse = removeAllCourseSectionsFromCourse;
async function removeAllCourseSectionsFromCourse(courseId) {
    // clean all course sections
    let data = await courseSections.select({ courseId:  courseId });
    for (var i = 0; i < data.length; i++) {
        await CourseElements.removeAllCourseElementsFromCourseSection(data[i].courseSectionId);
    }
    await courseSections.deleteFrom({ courseId: courseId, });
}

module.exports.getAllCourseSectionsFromCourse = getAllCourseSectionsFromCourse;
async function getAllCourseSectionsFromCourse(courseId) {
    return await courseSections.select({ courseId: courseId });
}

module.exports.getCourseHierarchy = getCourseHierarchy;
async function getCourseHierarchy(courseId, calculateLocks = false, token = null, ) {
    //await assertUserCanViewCourse(token, courseId);
    let courseLocks = {};
    if (calculateLocks) {
        courseLocks = await Videos.calculateLocks(token, courseId);
    }
    let isLocked = false;
    let output = await courseSections.select({ courseId: courseId });
    for (let i = 0; i < output.length; i++) {
        // TODO: SELECTING data from courses table is redudant
        let childrenData = await CourseElements.getAllElementsFromCourseSection(output[i].courseSectionId);
        output[i].children = []
        for (let j = 0; j < childrenData.length; j++) {
            let childData = {
                courseElementId: childrenData[j].courseElementId,
                courseElementName: childrenData[j].courseElementName,
                courseElementType: childrenData[j].courseElementType,
                elementOrder: childrenData[j].elementOrder,
            };
            // check if this courseElement should be locked
            if (isLocked) {
                childData.isLocked = true;
            } else {
                let areAllVideosWatched = true;
                if (calculateLocks) {
                    areAllVideosWatched = await Videos.areAllVideosWatched(token, childrenData[j].courseElementId);
                }
                isLocked = courseLocks[childrenData[j].courseElementId] !== undefined || !areAllVideosWatched;
                childData.isLocked = false;
            }
            // push child away
            output[i].children.push(childData);
        }
    }
    return output;
}

module.exports.getCourseSection = getCourseSection;
async function getCourseSection(courseSectionId) {
    return await courseSections.select({ courseSectionId: courseSectionId });
}

module.exports.assertUserCanEditCourseSection = assertUserCanEditCourseSection;
async function assertUserCanEditCourseSection(token, courseSectionId) {
    let courseSection = await courseSections.select({ courseSectionId: courseSectionId });
    let courseId = courseSection[0].courseId;
    await Courses.assertUserCanEditCourse(token, courseId);
}

/*
async function assertUserCanViewCourse(token, courseId) {
    // get organizationId
    let courseData = await Courses.getCourse(courseId);
    let organizationId = courseData[0].organizationId;

    let user = await Auth.getUserFromToken(token);
    userId = user[0].userId;
    await Org.getCoursePrivilegesForCourseAndUser(courseId, organizationId, userId);
    // if no errors caused by above, should be OK
}
*/

async function _getNextSectionOrder (courseId) {
    let sectionOrder = await courseSections.selectMax("sectionOrder", { courseId: courseId });

    // check if even any elements exists
    if (sectionOrder.sectionOrder === null) {
        return 0;
    }
    return sectionOrder.sectionOrder + 1;
}

async function _removeSectionOrder (sectionOrder, courseId) {
    let cs = await courseSections.select({courseId: courseId});
    for (let i = 0; i < cs.length; i++) {
        if (cs[i].sectionOrder > sectionOrder) {
            await courseSections.update(
                { courseSectionId: cs[i].courseSectionId },
                { sectionOrder: cs[i].sectionOrder - 1 }
            );
        }
    }
}

// 0: [ Alice ]
// 1: [ Bob ]
// 2: [ Charlie ]
// 3: [ Derek ]
// 4: [ Franky ]
// move Bob to index 3 (toSectionOrder = 3, currentSectionOrder = 1)
// 0: [ Alice ]
// 1: [ Charlie ]
// 2: [ Derek ]
// 3: [ Bob ]
// 4: [ Franky ]
// 
// step 1: remove the currentSectionOrder
// step 2: anything above or equal toSectionOrder, shift up by one
// step 3: insert into

module.exports.moveCourseSection = moveCourseSection;
async function moveCourseSection(courseSectionId, toSectionOrder) {
    let courseSection = (await courseSections.select({courseSectionId: courseSectionId}))[0];
    let currentSectionOrder = courseSection.sectionOrder;
    let courseId = courseSection.courseId;

    // step 1: remove the currentSectionOrder
    await _removeSectionOrder(currentSectionOrder, courseId);

    // step 2: anything above toSectionOrder, shift up by one
    let cs = await courseSections.select({courseId: courseId});
    for (let i = 0; i < cs.length; i++) {
        if (cs[i].sectionOrder >= toSectionOrder) {
            await courseSections.update(
                { courseSectionId: cs[i].courseSectionId },
                { sectionOrder: cs[i].sectionOrder + 1 }
            );
        }
    }

    // step 3: insert into
    await courseSections.update(
        { courseSectionId: courseSectionId },
        { sectionOrder: toSectionOrder }
    );
}
