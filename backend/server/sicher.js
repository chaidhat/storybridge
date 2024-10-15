const Db = require('./database');
const Auth = require('./auth');

var sicherLectures = new Db.DatabaseTable("SicherLectures",
    "sicherLectureId",
    [
        {
        name: "lectureName",
        type: "varchar(1023)"
        },
        {
        name: "cost",
        type: "int"
        },
        {
        name: "dateHeld", // DEPRECATED
        type: "varchar(511)"
        },
        {
        name: "venue", // DEPRECATED
        type: "varchar(1023)"
        },
        {
        name: "instructors",
        type: "varchar(1023)"
        },
        {
        name: "data",
        type: "mediumtext"
        },
]);
sicherLectures.init();

var sicherBookings = new Db.DatabaseTable("SicherBookings",
    "SicherBookingId",
    [
        {
        name: "userId",
        type: "int"
        },
        {
        name: "sicherLectureId",
        type: "int"
        },
        {
        name: "sicherTrainingId",
        type: "int"
        },
        {
        name: "dateBooked",
        type: "datetime"
        },
]);
sicherBookings.init();

module.exports.getLectures = getLectures;
async function getLectures () {
    let data = await sicherLectures.select();
    for (let i = 0; i < data.length; i++) {
        try {
            const minData = JSON.parse(decodeURI(data[i].data)).data[0].sectionDescription;
            let minDataCut = minData.substring(0, Math.min(250, minData.length));
            data[i].data = minDataCut;
        } catch (e) {
            console.log(e)
            data[i].data = e;
        }
    }
    return data;
}

module.exports.getTopLectures = getTopLectures;
async function getTopLectures () {
    let data = await sicherLectures.select(undefined, "ORDER BY sicherLectureId DESC LIMIT 3");
    for (let i = 0; i < 3; i++) {
        try {
            const minData = JSON.parse(decodeURI(data[i].data)).data[0].sectionDescription;
            let minDataCut = minData.substring(0, Math.min(250, minData.length));
            data[i].data = minDataCut;
        } catch (e) {
            console.log(e)
            data[i].data = e;
        }
    }
    return data;
}

module.exports.getLecture = getLecture;
async function getLecture (sicherLectureId) {
    // also return how many bookings there are per training
    let lecture = await sicherLectures.select({sicherLectureId: sicherLectureId});
    const lectureData = JSON.parse(decodeURI(lecture[0].data));

    if (lectureData.trainings !== undefined) {
        // get number of bookings per training data
        for (let i = 0; i < lectureData.trainings.length; i++) {
            const trainingId = lectureData.trainings[i].trainingId;
            const numOfBookings = (await sicherBookings.select({sicherTrainingId: trainingId})).length;
            lectureData.trainings[i].numOfBookings = numOfBookings;
        }
        lecture[0].data = JSON.stringify(lectureData)
    }
    return lecture;
}

module.exports.createLecture = createLecture;
async function createLecture (
    sicherAdminToken,
    lectureName,
    cost,
    dateHeld,
    venue,
    instructors,
    sicherLectureData,
) {
    if (sicherAdminToken !== "dasani") {
        throw {status: 403, message: "sicherAdminToken wrong"};
    }

    // add lecture
    let sicherLectureId = await sicherLectures.insertInto({
        lectureName: lectureName,
        cost: cost,
        dateHeld: dateHeld,
        venue: venue,
        instructors: instructors,
        data: sicherLectureData,
    });

    return sicherLectureId;
}

module.exports.changeLecture = changeLecture;
async function changeLecture (
    sicherAdminToken,
    sicherLectureId,
    lectureName,
    cost,
    dateHeld,
    venue,
    instructors,
    sicherLectureData,
) {
    if (sicherAdminToken !== "dasani") {
        throw {state: 403, message: "sicherAdminToken wrong"};
    }

    await sicherLectures.update(
        {
            sicherLectureId: sicherLectureId,
        },
        {
            lectureName: lectureName,
            cost: cost,
            dateHeld: dateHeld,
            venue: venue,
            instructors: instructors,
            data: sicherLectureData,
        }
    );
}

module.exports.removeLecture = removeLecture;
async function removeLecture (sicherAdminToken, sicherLectureId) {
    if (sicherAdminToken !== "dasani") {
        throw {status: 403, message: "sicherAdminToken wrong"};
    }

    await sicherLectures.deleteFrom(
        {
            sicherLectureId: sicherLectureId,
        }
    );
}

module.exports.createBooking = createBooking;
async function createBooking(
    sicherTrainingId,
    token
) {
    const userData = await Auth.getUserFromToken(token);
    const userId = userData[0].userId;
    const sicherLectureId = sicherTrainingId.substring(0, sicherTrainingId.length - 3);

    // add booking
    let sicherBookingId = await sicherBookings.insertInto({
        userId: userId,
        sicherLectureId: sicherLectureId,
        sicherTrainingId: sicherTrainingId,
        dateBooked: Db.getDatetime(),
    });

    return sicherBookingId;
}

module.exports.getBooking = getBooking;
async function getBooking(
    sicherBookingId
) {
    const bookingData = (await sicherBookings.select({sicherBookingId: sicherBookingId}))[0];
    const sicherLectureId = bookingData.sicherLectureId
    const userId = bookingData.userId
    const sicherLectureData = (await sicherLectures.select({sicherLectureId: sicherLectureId}))[0];
    const userData = (await Auth.getUserFromUserId(userId))[0];
    const userEmail = userData.email;
    const userName = `${userData.firstName} ${userData.lastName}`;
    /*
    returns user and lecture associated with that booking
    */

    return {
        bookingData: bookingData,
        sicherLectureData: sicherLectureData,
        userEmail: userEmail,
        userName: userName,
    };
}
