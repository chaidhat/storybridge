const Db = require('./database');
const Token = require('./token');
const CourseSections = require('./courseSections');
const Videos = require('./videos');
const Courses = require('./courses');
const Org = require('./organizations');


var courseElements = new Db.DatabaseTable("CourseElements",
    "courseElementId",
    [
        {
        name: "courseSectionId",
        type: "int"
        },
        {
        name: "courseElementName",
        type: "varchar(1023)"
        },
        {
        name: "courseElementDescription",
        type: "varchar(4095)"
        },
        {
        name: "courseElementType",
        type: "int"
        },
        /*
        courseElementType
        0 - video
        1 - literature
        2 - forms
        */
        {
        name: "elementOrder",
        type: "int"
        },
        {
        name: "dateCreated",
        type: "datetime"
        },
        {
        name: "data",
        type: "mediumtext"
        },
]);
courseElements.init();

module.exports.createCourseElement = createCourseElement;
async function createCourseElement (token, courseSectionId, courseElementType, courseElementOptions, data) {
    // check auth
    await CourseSections.assertUserCanEditCourseSection(token, courseSectionId);

    // determine next element order
    let elementOrder = await _getNextElementOrder(courseSectionId);

    let courseElementId = await courseElements.insertInto({
        courseSectionId: courseSectionId,
        courseElementName: courseElementOptions.courseElementName,
        courseElementDescription: courseElementOptions.courseElementDescription,
        courseElementType: courseElementType,
        data: data,
        elementOrder: elementOrder,
        dateCreated: Db.getDatetime(),
    });

    return courseElementId;
}

module.exports.getCourseElement = getCourseElement;
async function getCourseElement (token, courseElementId) {
    let pass = false;

    // check if this is the front page (doesn't matter if they're logged in or out)
    let ce = await courseElements.select({courseElementId: courseElementId});
    let courseSectionId = ce[0].courseSectionId;
    let courseSections = await CourseSections.getCourseSection(courseSectionId);
    if (courseSections[0].sectionOrder === 0) {
        pass = true;
    }

    // check if they are subscribed to the course
    if (!pass) {
        var courseId = courseSections[0].courseId;

        let courseSubscriptions = await Courses.getCourseSubscriptionsForUser(token);
        for (let i = 0; i < courseSubscriptions.length; i++) {
            if (courseSubscriptions[i].courseId == courseId) {
                pass = true;
                break;
            }
        }
    }

    // if they aren't subbed,
    // check if they have any course privileges (if they are a teacher)
    if (!pass) {
        let course = await Courses.getCourse(courseId);
        let organizationId = course[0].organizationId;
        let orgPrivileges = await Org.getOrganizationPrivilegesForUser(token);
        for (let i = 0; i < orgPrivileges.length; i++) {
            if (orgPrivileges[i].organizationId== organizationId) {
                pass = true;
                break;
            }
        }
    }

    if (!pass) {
        throw "assigner has insufficient permission";
    }

    return await courseElements.select({courseElementId: courseElementId});
}


module.exports.getAllElementsFromCourseSection = getAllElementsFromCourseSection;
async function getAllElementsFromCourseSection(courseSectionId) {
    let elementOutput = await courseElements.select({ courseSectionId: courseSectionId });
    let output = [];

    for (let i = 0; i < elementOutput.length; i++) {
        output.push(elementOutput[i]);
}
    return output;
}

module.exports.assertUserCanEditCourseElement = assertUserCanEditCourseElement;
async function assertUserCanEditCourseElement (token, courseElementId) {
    let courseElement = await courseElements.select({courseElementId: courseElementId});
    let courseSectionId = courseElement[0].courseSectionId;
    // check auth
    await CourseSections.assertUserCanEditCourseSection(token, courseSectionId);
}

module.exports.changeCourseElementName = changeCourseElementName;
async function changeCourseElementName (token, courseElementId, courseElementOptions) {
    await assertUserCanEditCourseElement(token, courseElementId);

    // perform length checks
    if (encodeURI(courseElementOptions.courseElementName).length > 1023) {
        throw {status: 403, message: "courseElementName is too long! (>1023 chars)"};
    }
    if (encodeURI(courseElementOptions.courseElementDescription).length > 4095) {
        throw {status: 403, message: "courseElementName is too long! (>1023 chars)"};
    }

    await courseElements.update(
        { courseElementId: courseElementId },
        {
            courseElementName: courseElementOptions.courseElementName,
            courseElementDescription: courseElementOptions.courseElementDescription,
        }
    );
}
module.exports.changeCourseElementData = changeCourseElementData;
async function changeCourseElementData (token, courseElementId, data) {
    await assertUserCanEditCourseElement(token, courseElementId);

    // perform length checks
    if (encodeURI(data).length > 16777215) {
        throw {status: 403, message: "data is too long! (>16777215 chars)"};
    }

    await courseElements.update(
        { courseElementId: courseElementId },
        { data: data },
    );
}

module.exports.removeCourseElement = removeCourseElement;
async function removeCourseElement (token, courseElementId) {
    let courseElement = await courseElements.select({courseElementId: courseElementId});
    let courseSectionId = courseElement[0].courseSectionId;
    // check auth ( no need to use assertUserCanEditCourseElement as it is done here more efficiently )
    await CourseSections.assertUserCanEditCourseSection(token, courseSectionId);

    await _removeElementOrder(courseElement[0].courseElementOrder, courseSectionId)

    // delete all data associated with it
    await Videos.removeAllAssessmentsFromCourseElement(courseElementId);

    // delete itself
    await courseElements.deleteFrom({courseElementId: courseElementId});
}

module.exports.removeAllCourseElementsFromCourseSection = removeAllCourseElementsFromCourseSection;
async function removeAllCourseElementsFromCourseSection(courseSectionId) {
    // select all course elements
    let ce = await courseElements.select({courseSectionId: courseSectionId});
    for (let i = 0; i < ce.length; i++) {
        let courseElement = ce[i];
        // delete all data associated with it
        await Videos.removeAllAssessmentsFromCourseElement(courseElement.courseElementId);
        // delete itself
        await courseElements.deleteFrom({courseElementId: courseElement.courseElementId});
    }
}

async function _getNextElementOrder (courseSectionId) {
    let elementOrder = await courseElements.selectMax("elementOrder", { courseSectionId: courseSectionId });

    // check if even any elements exists
    if (elementOrder.elementOrder === null) {
        return 0;
    }
    return elementOrder.elementOrder + 1;
}

async function _removeElementOrder (elementOrder, courseSectionId) {
    let ce = await courseElements.select({courseSectionId: courseSectionId});
    for (let i = 0; i < ce.length; i++) {
        if (ce[i].elementOrder > elementOrder) {
            await courseElements.update(
                { courseElementId: ce[i].courseElementId },
                { elementOrder: ce[i].elementOrder - 1 }
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

module.exports.moveCourseElement = moveCourseElement;
async function moveCourseElement(courseElementId, toElementOrder) {
    let courseElement = (await courseElements.select({courseElementId: courseElementId}))[0];
    let currentElementOrder = courseElement.elementOrder;
    let courseSectionId = courseElement.courseSectionId;

    // step 1: remove the currentSectionOrder
    await _removeElementOrder(currentElementOrder, courseSectionId);

    // step 2: anything above toSectionOrder, shift up by one
    let ce = await courseElements.select({courseSectionId: courseSectionId});
    for (let i = 0; i < ce.length; i++) {
        if (ce[i].elementOrder >= toElementOrder) {
            await courseElements.update(
                { courseElementId: ce[i].courseElementId },
                { elementOrder: ce[i].elementOrder + 1 }
            );
        }
    }

    // step 3: insert into
    await courseElements.update(
        { courseElementId: courseElementId },
        { elementOrder: toElementOrder }
    );
}

async function debug_migrateAddCourseElementIdToFiles() {
    const ces = await courseElements.select();
    for (let j = 0; j < ces.length; j++) {
            const ce = ces[j];
            console.log(ce.courseElementId)
            try {

                    const data = JSON.parse(decodeURI(ce.data));
                    const columnData = data.children;
                    for (let i = 0; i < columnData.length; i++) {
                            const widgetData = columnData[i];
                            if (widgetData.widgetType === 'video') {
                                //await Videos.debug_setCourseElementIdForVideo(widgetData.videoId, ce.courseElementId);
                            }
                            if (widgetData.widgetType === 'image') {
                                //await Videos.debug_setCourseElementIdForImage(widgetData.imageId, ce.courseElementId);
                            }
                    }
            } catch (e) {
                    console.log(e);
            }
    }
}