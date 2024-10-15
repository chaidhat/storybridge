const Db = require('./database');
const Token = require('./token');
const Auth = require('./auth');
const Courses = require('./courses');
const CourseSections = require('./courseSections');
const CourseElements = require('./courseElements');
const VideoData = require('./videoData');
const Auditing = require('./auditing');

const CORRECT = 'correct';
const INCORRECT = 'incorrect';
const NOT_ANSWERED = 'not answered';

const FALSE_BUFFER = Buffer.alloc(1);

var videos = new Db.DatabaseTable("Videos",
    "videoId",
    [
        {
        name: "courseId",
        type: "int"
        },
        {
        name: "duration",
        type: "int"
        },
        {
        name: "contentDataId",
        type: "varchar(16)"
        },
        {
        name: "isUploaded",
        type: "bit"
        },
        {
        name: "isUploading",
        type: "bit"
        },
        {
        name: "courseElementId",
        type: "int"
        },
]);
videos.init();

var images = new Db.DatabaseTable("Images",
    "imageId",
    [
        {
        name: "courseId",
        type: "int"
        },
        {
        name: "contentDataId",
        type: "varchar(16)"
        },
        {
        name: "isUploaded",
        type: "bit"
        },
        {
        name: "isUploading",
        type: "bit"
        },
        {
        name: "userId",
        type: "int"
        },
        {
        name: "courseElementId",
        type: "int"
        },
        {
        name: "extension",
        type: "varchar(16)"
        },
        {
        name: "auditTaskId",
        type: "int"
        },
]);
images.init();

/*

DOCUMENTAITON FOR ALL ASSESSMENT DATA STORAGE CAN BE FOUND IN DOCS
    /docs/readme-assessment-standard.txt

*/

var assessments = new Db.DatabaseTable("Assessments",
    "assessmentId",
    [
        {
        name: "courseElementId",
        type: "int"
        },
        {
        name: "auid",
        type: "varchar(16)"
        },
        {
        name: "weighting",
        type: "int"
        },
        {
        name: "passingPercentage",
        type: "int"
        },
        {
        name: "assessmentData",
        type: "mediumtext"
        },
]);
assessments.init();

var assessmentTasks = new Db.DatabaseTable("AssessmentTasks",
    "assessmentTaskId",
    [
        {
        name: "userId",
        type: "int"
        },
        {
        name: "auid",
        type: "varchar(16)"
        },
        {
        name: "data",
        type: "mediumtext"
        },
]);
assessmentTasks.init();

var videoTasks = new Db.DatabaseTable("VideoTasks",
    "VideoTaskId",
    [
        {
        name: "userId",
        type: "int"
        },
        {
        name: "videoId",
        type: "int"
        },
        {
        name: "isWatched",
        type: "bit"
        },
]);
videoTasks.init();

module.exports.createVideo = createVideo;
async function createVideo (token, courseId, courseElementId) {
    await Courses.assertUserCanEditCourse(token, courseId);
    // create unique id
    do {
        var contentDataId = Token.generateToken();

        // check if there are any existing uid
        let checkData = await videos.select({contentDataId: contentDataId});
        let checkData2 = await images.select({contentDataId: contentDataId});
        var pass = checkData.length === 0 && checkData2.length === 0;
        // repeat if there is an existing one (very rare chance)
    } while (!pass);

    let videoId = await videos.insertInto({
        courseId: courseId,
        courseElementId: courseElementId,
        contentDataId: contentDataId,
        duration: 0,
        isUploaded: false,
        isUploading: false,
    });
    
    return videoId;
}

module.exports.getVideo = getVideo;
async function getVideo (token, videoId) {
    // TODO: do auth
    let vdo = await videos.select({videoId: videoId});
    if (vdo.length > 0) {
        const vt = await videoTasks.select({videoId: videoId});
        vdo[0].views = vt.length;
    }
    return vdo;
}

module.exports.updateUploadingVideo = updateUploadingVideo;
async function updateUploadingVideo (contentDataId, isUploading) {
    // update videos and images at the same time, which is slightly dangerous.
    await videos.update(
        { contentDataId: contentDataId }, 
        { isUploading: isUploading }
    );
    await images.update(
        { contentDataId: contentDataId }, 
        { isUploading: isUploading }
    );
    if (!isUploading) {
        console.log("done uploading " + contentDataId)
        await videos.update(
            { contentDataId: contentDataId }, 
            { isUploaded: true }
        );
        await images.update(
            { contentDataId: contentDataId }, 
            { isUploaded: true }
        );
    }
}

module.exports.createImage = createImage;
async function createImage (token, courseId, userId, courseElementId, auditTaskId) {
    // if courseId === 0, then that means it is a logo or a organizational image, not assoc. with a course
    let outCourseId = 0;
    let outUserId = 0;
    if (courseId !== undefined) {
        if (courseId !== "0") {
            await Courses.assertUserCanEditCourse(token, courseId);
        } else {
            // todo: check if the image can be edited by that user for the organization.
        }
        outCourseId = courseId;
    } else if (userId !== undefined) {
        outUserId = userId;
    } else {
        throw {status: 403, message: "either courseId or userId must be provided to createImage()"};
    }

    // create unique id
    do {
        var contentDataId = Token.generateToken();

        // check if there are any existing uid
        let checkData = await videos.select({contentDataId: contentDataId});
        let checkData2 = await images.select({contentDataId: contentDataId});
        var pass = checkData.length === 0 && checkData2.length === 0;
        // repeat if there is an existing one (very rare chance)
    } while (!pass);

    let imageId = await images.insertInto({
        courseId: outCourseId,
        contentDataId: contentDataId,
        courseElementId: courseElementId,
        auditTaskId: auditTaskId,
        isUploaded: false,
        isUploading: false,
        userId: outUserId,
    });
    
    return imageId;
}

module.exports.getImage = getImage;
async function getImage (token, imageId) {
    // TODO: do auth
    return await images.select({imageId: imageId});
}

module.exports.removeImage = removeImage;
async function removeImage (token, imageId) {
    // TODO: do auth

    const contentDataId = (await images.select({imageId: imageId}))[0].contentDataId;
    VideoData.removeImg(contentDataId);
    
    await images.deleteFrom({imageId: imageId});
}

module.exports.getAssessment = getAssessment;
async function getAssessment (token, auid) {
    // TODO: do auth
    return await assessments.select({auid: auid});
}

module.exports.updateAssessment = updateAssessment;
async function updateAssessment (token, auid, assessmentPreferences) {
    // authenticate user
    let as = await assessments.select({auid: auid});
    try {
        await CourseElements.assertUserCanEditCourseElement(token, as[0].courseElementId);
    } catch (err) {
        throw "assigner has insufficient permission";
    }

    return await assessments.update({auid: auid},
        {
            weighting: assessmentPreferences.weighting,
            passingPercentage: assessmentPreferences.passingPercentage,
            assessmentData: assessmentPreferences.assessmentData,
        }
    );
}

module.exports.createAssessment = createAssessment;
async function createAssessment (token, courseElementId, assessmentPreferences) {
    await CourseElements.assertUserCanEditCourseElement(token, courseElementId);
    // create unique id
    do {
        var auid = Token.generateToken();

        // check if there are any existing auid
        let checkData = await assessments.select({auid: auid});
        var pass = checkData.length === 0;
        // repeat if there is an existing one (very rare chance)
    } while (!pass);

    await assessments.insertInto({
        auid: auid,
        courseElementId: courseElementId,
        weighting: assessmentPreferences.weighting,
        passingPercentage: assessmentPreferences.passingPercentage,
        assessmentData: assessmentPreferences.assessmentData,
    });
    
    return auid;
}

module.exports.removeAssessment = removeAssessment;
async function removeAssessment (token, auid) {
    // TODO: do auth
    await assessmentTasks.deleteFrom({
        auid: auid
    });
    await assessments.deleteFrom({
        auid: auid
    });
}

module.exports.removeAllAssessmentsFromCourseElement = removeAllAssessmentsFromCourseElement;
async function removeAllAssessmentsFromCourseElement (courseElementId) {
    // TODO: do auth
    let assessmentsInCourseElement = await assessments.select({courseElementId: courseElementId});
    for (let i = 0; i < assessmentsInCourseElement.length; i++) {
        let auid = assessmentsInCourseElement[i].auid;

        await assessmentTasks.deleteFrom({
            auid: auid
        });
        console.log("deleting " + auid);
        await assessments.deleteFrom({
            auid: auid
        });
    }
}






module.exports.getAssessmentTaskFromAssessment = getAssessmentTaskFromAssessment;
async function getAssessmentTaskFromAssessment (token, auid) {
    let userId = await Auth.getUserFromToken(token);
    userId = userId[0].userId;

    return await assessmentTasks.select({
        userId: userId,
        auid: auid
    });
}

module.exports.updateAssessmentTaskFromAssessment = updateAssessmentTaskFromAssessment;
async function updateAssessmentTaskFromAssessment (token, auid, data) {
    let userId = await Auth.getUserFromToken(token);
    userId = userId[0].userId;

    return await assessmentTasks.update(
        {
            auid: auid,
            userId: userId
        },
        {
            data: data,
        }
    );
}

module.exports.createAssessmentTaskFromAssessment = createAssessmentTaskFromAssessment;
async function createAssessmentTaskFromAssessment (token,auid,data) {
    let userId = await Auth.getUserFromToken(token);
    userId = userId[0].userId;

    let assessmentTaskId = await assessmentTasks.insertInto({
        userId: userId,
        auid: auid,
        data: data,
    });
    
    return assessmentTaskId;
}

module.exports.removeAssessmentTaskFromAssessment = removeAssessmentTaskFromAssessment;
async function removeAssessmentTaskFromAssessment (token, auid) {
    let userId = await Auth.getUserFromToken(token);
    userId = userId[0].userId;

    return await assessmentTasks.deleteFrom({
        userId: userId,
        auid: auid
    });
}

module.exports.getAllAssessmentsForCourse = getAllAssessmentsForCourse;
// override flag prevents 
// 1. omitting the assessmentData
// 2. pulling assessment statistics from students
async function getAllAssessmentsForCourse (token, courseId, override = false, omitStudentGrades = false) {
    let data = await CourseSections.getCourseHierarchy(courseId);
    let courseElementIds = [];
    for (let i = 0; i < data.length; i++) {
        for (let j = 0; j < data[i].children.length; j++) {
            courseElementIds.push(data[i].children[j].courseElementId)
            // initialize the children data
            data[i].children[j].assessments = [];
        }
    }
    // TODO: SELECTING data from assessments table is redudant
    let assessmentData = await assessments.select({courseElementId: courseElementIds});

    // add assessment data to course hierarchy
    for (let i = 0; i < assessmentData.length; i++) {
        let assessmentCourseElementId = assessmentData[i].courseElementId;

        // find courseElementId in data
        for (let j = 0; j < data.length; j++) {
            for (let k = 0; k < data[j].children.length; k++) {
                let courseElementId = data[j].children[k].courseElementId;
                // if matching, add it to hierachy
                if (assessmentCourseElementId === courseElementId) {
                    if (!override) {
                        assessmentData[i].assessmentData = ""; // omit the data
                    }
                    data[j].children[k].assessments.push(assessmentData[i]);
                }
            }
        }
    }

    // omit courseSections & courseElements which do not have assessments
    for (let i = 0; i < data.length; i++) {
        let courseSectionHasChildren = false;
        for (let j = 0; j < data[i].children.length; j++) {
            let courseElementHasChildren = false;
            if (data[i].children[j].assessments.length > 0) {
                courseElementHasChildren = true;
                courseSectionHasChildren = true;
            }
            if (!courseElementHasChildren) {
                data[i].children.splice(j--, 1);
            }
        }
        if (!courseSectionHasChildren) {
            data.splice(i--, 1);
        }
    }

    if (override || omitStudentGrades) 
        return data;

    let gradeData = (await getAssessmentStatsForStudentForCourse(token, courseId, null, true)).data;

    // calculate the statistics
    for (let i = 0; i < gradeData.length; i++) {
        let gradeDataSection = gradeData[i];
        for (let j = 0; j < gradeDataSection.children.length; j++) {
            let gradeDataPage = gradeDataSection.children[j];
            for (let k = 0; k < gradeDataPage.assessments.length; k++) {
                let gradeDataAssessment = gradeDataPage.assessments[k];
                let correctAnswers = gradeDataAssessment.correctAnswers;

                //console.log(correctAnswers);
                // correctAnswers is in a matrix: for example
                // [ [ 'correct', 'incorrect' ], [ 'correct', 'not answered' ]]
                // whereby the first element is the first person's answer.
                let totalNotAnsweredAnswers = 0;
                let totalCorrectAnswers = 0;
                let totalIncorrectAnswers = 0;
                // aggregate the answers for the assessment
                for (let l = 0; l < correctAnswers.length; l++) {
                    for (let m = 0; m < correctAnswers[l].length; m++) {
                        switch (correctAnswers[l][m]) {
                            case CORRECT:
                                totalCorrectAnswers++;
                                break;
                            case INCORRECT:
                                totalIncorrectAnswers++;
                                break;
                            case NOT_ANSWERED:
                            default:
                                totalNotAnsweredAnswers++;
                        }
                    }
                }
                // set the data
                data[i].children[j].assessments[k].totalNotAnsweredAnswers = totalNotAnsweredAnswers;
                data[i].children[j].assessments[k].totalCorrectAnswers = totalCorrectAnswers;
                data[i].children[j].assessments[k].totalIncorrectAnswers = totalIncorrectAnswers;
                data[i].children[j].assessments[k].correctAnswers = ""; // omit the answers to save data
            }
        }
    }

    return data;
}

module.exports.getAssessmentStatsForThisStudentForCourse = getAssessmentStatsForThisStudentForCourse;
async function getAssessmentStatsForThisStudentForCourse (token, courseId) {
    
    // get userId from token
    let userId = await Auth.getUserFromToken(token);
    return (await getAssessmentStatsForStudentForCourse(token, courseId, userId[0].userId)).data;
}

module.exports.getAssessmentStatsForStudentForCourse = getAssessmentStatsForStudentForCourse;
async function getAssessmentStatsForStudentForCourse (token, courseId, studentUserId, overrideSearchAllStudents = false) {

    let dat = await getAllAssessmentsForCourse(token, courseId, true);
    // go through all courseSections in dat
    for (let i = 0; i < dat.length; i++) {
        // go through all courseElements in courseSection
        for (let j = 0; j < dat[i]["children"].length; j++) {
            // go through all assessments in courseElements
            for (let k = 0; k < dat[i]["children"][j]["assessments"].length; k++) {

                // get the assessment
                let assessment = dat[i]["children"][j]["assessments"][k];

                // find the assessmentTask, created by the user, that is associated with the assessment
                let asTasks;
                let correctAnswerOutput = [];
                if (!overrideSearchAllStudents) {
                    asTasks = await assessmentTasks.select({userId: studentUserId, auid: assessment.auid});
                } else {
                    asTasks = await assessmentTasks.select({auid: assessment.auid});
                    var correctAnswerOutputs = [];
                }

                let totalNotAnsweredAnswers = 0;
                let totalCorrectAnswers = 0;
                let totalIncorrectAnswers = 0;

                // has the student started the assessment?
                for (let n = 0; n < asTasks.length; n++) {
                    correctAnswerOutput = [];
                    let assessmentTask = asTasks[n];

                    // parse the answer and question data for that assessment
                    let answers = JSON.parse(decodeURI(assessmentTask.data)).answers; 
                    let questions = JSON.parse(decodeURI(assessment.assessmentData)).questions;

                    // go through all the questions for the assessment
                    for (let l = 0; l < questions.length; l++) {
                        let question = questions[l];
                        let foundAnswer = false;
                        // find the associated answer with that quid
                        for (let m = 0; m < answers.length; m++) {
                            let answer = answers[m];
                            if (question.quid === answer.quid) {
                                // OK this is the answer for that question
                                foundAnswer = true;

                                // now analzye if the answer for the question is correct
                                if (question.questionType === "multipleChoice") {
                                    let correctAnswer = question.questionAnswerData.correctAnswers;
                                    // e.g., [ 'true', 'false', 'true', 'false ]
                                    //console.log(correctAnswer);

                                    // e.g., { answer: 0, quid: '1234567' }
                                    //console.log(answer)

                                    if (correctAnswer[answer.answer] === 'true') {
                                        correctAnswerOutput.push(CORRECT)
                                        totalCorrectAnswers++;
                                    } else if (correctAnswer[answer.answer] === 'false') {
                                        correctAnswerOutput.push(INCORRECT)
                                        totalIncorrectAnswers++;
                                    }
                                }
                                break;
                            }
                        }

                        // no answer found for that quid
                        if (!foundAnswer) {
                            correctAnswerOutput.push(NOT_ANSWERED)
                            totalNotAnsweredAnswers++;
                        }
                    }
                    if (overrideSearchAllStudents) {
                        correctAnswerOutputs.push(correctAnswerOutput);
                    }
                }

                dat[i].children[j].assessments[k].totalNotAnsweredAnswers = totalNotAnsweredAnswers;
                dat[i].children[j].assessments[k].totalCorrectAnswers = totalCorrectAnswers;
                dat[i].children[j].assessments[k].totalIncorrectAnswers = totalIncorrectAnswers;

                // cleanup
                dat[i]["children"][j]["assessments"][k].assessmentData = "";
                if (!overrideSearchAllStudents) {
                    dat[i]["children"][j]["assessments"][k].userBeganAssessment = (asTasks.length !== 0) ? "true" : "false";
                    dat[i]["children"][j]["assessments"][k].correctAnswers = correctAnswerOutput;
                } else {
                    // if we search all the students, put this in a 2D matrix of sorts.
                    dat[i]["children"][j]["assessments"][k].correctAnswers = correctAnswerOutputs;
                }
                //console.log(dat[0]["children"][0]["assessments"][0]);
            }
        }
    }
    // calcualte total weighting
    let totalWeighting = 0;
    try {
        for (let i = 0; i < dat.length; i++) {
            let  ce= dat[i]["children"];
            for (let j = 0; j <ce.length; j++) {
                let as = ce[j]["assessments"];
                for (let k = 0; k < as.length; k++) {
                    totalWeighting += as[k]["weighting"];
                }
            }
        }
    } catch(e) {

    }


    // calculate total assessment grades for student
    let totalAssessmentGrades = 0;
    try {
        for (let i = 0; i < dat.length; i++) {
            let ce = dat[i]["children"];
            for (let j = 0; j < ce.length; j++) {
                let ases = ce[j]["assessments"];
                for (let k = 0; k < ases.length; k++) {
                const as = ases[k];
                const totalCorrectAnswers = as["totalCorrectAnswers"];
                const totalNumOfAnswers = as["totalCorrectAnswers"] +
                    as["totalIncorrectAnswers"] +
                    as["totalNotAnsweredAnswers"];

                let assessmentWeighting = 0;
                // divide by zero check
                if (totalWeighting != 0) {
                    assessmentWeighting = ases[k]["weighting"] / totalWeighting;
                }

                let assessmentPercentage = 0;
                // divide by zero check
                if (totalNumOfAnswers != 0) {
                    assessmentPercentage = totalCorrectAnswers / totalNumOfAnswers;
                }

                totalAssessmentGrades += assessmentPercentage * assessmentWeighting;
                }
            }
        }
    } catch (e) {

    }

    // check if all assessments are passed
    let assessmentsPassed = 0;
    try {
        for (let i = 0; i < dat.length; i++) {
            const ce = dat[i]["children"];
            for (let j = 0; j < ce.length; j++) {
                const  ases= ce[j]["assessments"];
                for (let k = 0; k < ases.length; k++) {
                const as = ases[k];
                let totalCorrectAnswers = as["totalCorrectAnswers"];
                let totalNumOfAnswers = as["totalCorrectAnswers"] +
                    as["totalIncorrectAnswers"] +
                    as["totalNotAnsweredAnswers"];
                let assessmentPercentage = totalCorrectAnswers / totalNumOfAnswers;
                let passingPercentage = as["passingPercentage"];
                if (assessmentPercentage * 100 >= passingPercentage) {
                    assessmentsPassed++;
                }
                }
            }
        }
    } catch (e) {

    }

    const out = {
        data: dat,
        totalAssessmentGrades: totalAssessmentGrades,
        totalWeighting: totalWeighting,
        assessmentsPassed: assessmentsPassed,
    };
    
    return out;
}

module.exports.removeEverythingFromCourse = removeEverythingFromCourse;
async function removeEverythingFromCourse (courseId) {
    // TODO: do auth
    await images.deleteFrom({courseId: courseId});
    await videos.deleteFrom({courseId: courseId});
    // TODO: handle video and image data deletion properly
    // assessment deletion is handled in courseElement deletion
}

module.exports.calculateLocks = calculateLocks;
async function calculateLocks (token, courseId) {
    const users = await Auth.getUserFromToken(token);
    if (users.length === 0) {
        return [];
    }
    const userId = users[0].userId;
    const asStats = (await getAssessmentStatsForStudentForCourse(token, courseId, userId)).data;
    let output = {};
    for (let i = 0; i < asStats.length; i++) {
        // courseSection level
        for (let j = 0; j < asStats[i].children.length; j++) {
            // courseElement level
            const courseElementId = asStats[i].children[j].courseElementId;
            for (let k = 0; k < asStats[i].children[j].assessments.length; k++) {
                if (asStats[i].children[j].assessments[k].totalNotAnsweredAnswers > 0 ||
                    asStats[i].children[j].assessments[k].userBeganAssessment === 'false'
                ) {
                    output[courseElementId] = true;
                    break;
                }
            }
        }
    }
    return output;
}

module.exports.areAllVideosWatched = areAllVideosWatched;
async function areAllVideosWatched (token, courseElementId) {
    const users = await Auth.getUserFromToken(token);
    if (users.length === 0) {
        return false;
    }
    const userId = users[0].userId;
    const vids = await videos.select({courseElementId: courseElementId});
    let numWatchedVids = 0;
    for (let k = 0; k < vids.length; k++) {
        const vidTasks = await videoTasks.select({userId: userId,videoId: vids[k].videoId});
        if (vidTasks.length > 0 && !vidTasks[0].isWatched.equals(FALSE_BUFFER)) {
            numWatchedVids++;
        }
    }
    if (numWatchedVids < vids.length) {
        return false;
    }
    return true;
}

module.exports.getCourseFiles = getCourseFiles;
async function getCourseFiles (token, courseId) {
    // TODO: do auth
    const imgs = await images.select({courseId: courseId});
    const vids = await videos.select({courseId: courseId});
    let output = [];
    for (let i = 0; i < imgs.length; i++) {
        output.push(imgs[i]);
    }
    for (let i = 0; i <vids.length; i++) {
        output.push(vids[i]);
    }
    let totalSize = 0;
    for (let i = 0; i < output.length; i++) {
        const size = await VideoData.getFileSize(output[i].contentDataId);
        output[i].size = Math.round(size * 100) / 100;
        totalSize += size;
    }
    return {
        totalSize: totalSize,
        data: output};
}

module.exports.getAuditTemplateFiles = getAuditTemplateFiles;
async function getAuditTemplateFiles (token, auditTemplateId) {
    // TODO: do auth
    const tasks = await Auditing.getAuditTasksForTemplate(auditTemplateId);
    let output = [];

    for (let i = 0; i < tasks.length; i++) {
        const imgs = await images.select({auditTaskId: tasks[i].auditTaskId});
        for (let j = 0; j < imgs.length; j++) {
            output.push(imgs[j]);
        }
    }
    
    let totalSize = 0;
    for (let i = 0; i < output.length; i++) {
        const size = await VideoData.getFileSize(output[i].contentDataId);
        output[i].size = Math.round(size * 100) / 100;
        totalSize += size;
    }
    return {
        totalSize: totalSize,
        data: output};
}

module.exports.getUserFiles = getUserFiles;
async function getUserFiles (userId) {
    // TODO: do auth
    const imgs = await images.select({userId: userId});
    let output = [];
    for (let i = 0; i < imgs.length; i++) {
        output.push(imgs[i]);
    }
    let totalSize = 0;
    for (let i = 0; i < output.length; i++) {
        const size = await VideoData.getFileSize(output[i].contentDataId);
        output[i].size = Math.round(size * 100) / 100;
        totalSize += size;
    }
    return {
        totalSize: totalSize,
        data: output};
}

module.exports.markVideoTaskAsRead = markVideoTaskAsRead;
async function markVideoTaskAsRead (token, videoId) {
    const userId = (await Auth.getUserFromToken(token))[0].userId;
    const vts = await videoTasks.select({videoId: videoId, userId: userId});
    if (vts.length === 0) {
        videoTasks.insertInto({
            videoId: videoId,
            userId: userId,
            isWatched: true,
        });
    } else {
        videoTasks.update({
            videoId: videoId,
            userId: userId,
        }, {
            isWatched: true,
        });
    }
}

module.exports.markVideoTaskAsUnread = markVideoTaskAsUnread;
async function markVideoTaskAsUnread (token, videoId) {
    const userId = (await Auth.getUserFromToken(token))[0].userId;
    const vts = await videoTasks.select({videoId: videoId, userId: userId});
    if (vts.length === 0) {
        videoTasks.insertInto({
            videoId: videoId,
            userId: userId,
            isWatched: false,
        });
    } else {
        videoTasks.update({
            videoId: videoId,
            userId: userId,
        }, {
            isWatched: false,
        });
    }
}

module.exports.getIsVideoRead = getIsVideoRead;
async function getIsVideoRead (token, videoId) {
    const userId = (await Auth.getUserFromToken(token))[0].userId;
    const data = await videoTasks.select({videoId: videoId, userId: userId});
    if (data.length === 0) {
        return false;
    }
    const falseBuffer =  Buffer.alloc(1);
    return !data[0].isWatched.equals(falseBuffer);
}

module.exports.debug_setCourseElementIdForVideo = debug_setCourseElementIdForVideo;
async function debug_setCourseElementIdForVideo(videoId, courseElementId) {
    await videos.update({videoId: videoId}, {courseElementId: courseElementId});
}
module.exports.debug_setCourseElementIdForImage = debug_setCourseElementIdForImage;
async function debug_setCourseElementIdForImage(imageId, courseElementId) { 
    await images.update({imageId: imageId}, {courseElementId: courseElementId}); 
} 

module.exports.removeVideo = removeVideo;
async function removeVideo(token, videoId) {
    // TODO: auth
    const vid = (await videos.select({videoId: videoId}))[0];

    VideoData.removeVideo(vid.contentDataId);
    await videos.deleteFrom({videoId: videoId});
    await videoTasks.deleteFrom({videoId: videoId});
}

module.exports.removeImage = removeImage;
async function removeImage(token, imageId) {
    // TODO: auth
    const img = (await images.select({imageId: imageId}))[0];

    VideoData.removeImg(img.contentDataId);
    await images.deleteFrom({imageId: imageId});
}

module.exports.getImageExtension = getImageExtension;
async function getImageExtension(contentDataId) {
    const res = await images.select({ contentDataId: contentDataId});
    if (res.length === 0) {
        return null;
    }
    return res[0].extension;
}
module.exports.setImageExtension = setImageExtension;
async function setImageExtension(contentDataId, extension) {
    await images.update({ contentDataId: contentDataId}, { extension: extension });
}