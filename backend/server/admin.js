const Db = require('./database');
const Token = require('./token');
const Password = require('./password');

let ADMIN_KEY_HASH = "c5f8f1f27114077b1fe5bd9503705c87001642378d310af5d92ec4ead5712afd"
let ADMIN_DB_KEY_HASH = "dd1b86393d0ab15613508c0efda192d2665dda30b7df62cd4f6aef8f4ebebd64"

// this is supposed to clone a course from an organization to another.
module.exports.ping = ping;
async function ping(token) {
    // check if admin is valid
    if (Password.sha(token) !== ADMIN_KEY_HASH) {
        throw {status: 403, message: "Invalid admin token."};
    }

    return "Valid admin token.";
}

module.exports.getDb = getDb;
async function getDb(token) {
    // check if admin is valid
    if (Password.sha(token) !== ADMIN_KEY_HASH) {
        throw {status: 403, message: "Invalid admin token."};
    }

    // get all the tables
    let data = await Db.adminQuery("SHOW TABLES");
    let tables = [];
    data.forEach((d, idx) => {
        tables.push(d["Tables_in_my_db"]);
    });

    // get the top five things for those tables
    let tableData = [];
    for (let i = 0; i < tables.length; i++) {
        let t = tables[i];
        let data;
        if (TABLE_ID_MAP[t] !== undefined) {
            tId = TABLE_ID_MAP[t];
            data = await Db.adminQuery(`SELECT * FROM ${t} ORDER BY ${tId} DESC LIMIT 5`);
        } else {
            // there exists no tId for this table
            data = await Db.adminQuery(`SELECT * FROM ${t} LIMIT 5`);
        }
        tableData.push({tableName: t, tableData: data});
    }
    return tableData;
}

module.exports.callDb = callDb;
async function callDb(token, query, dbKey) {
    // check if admin is valid
    if (Password.sha(token) !== ADMIN_KEY_HASH) {
        throw {status: 403, message: "Invalid admin token."};
    }
    if (Password.sha(dbKey) !== ADMIN_DB_KEY_HASH) {
        throw {status: 403, message: "Invalid db key."};
    }
    // DANGER: this is unsanitized.
    try {
        console.log(`callDb execute: "${query}"`);
        var out = await Db.adminQuery(query, errorQuietly = true);
    } catch (e) {
        var out = e.toString();
    }
    return out;
}

// IMPORTANT: update this list every time a new table is created.
const TABLE_ID_MAP = {
    "AnalyticsEvent": "analyticsEventId",
    "AnalyticsEventData": "analyticsEventDataId",
    /*"AnalyticsFormBugs": "AnalyticsFormBugId",*/
    /*"AnalyticsFormFeedback": "AnalyticsFormFeedbackId",*/
    "AssessmentTasks": "AssessmentTaskId",
    "Assessments": "AssessmentId",
    "CourseElements": "courseElementId",
    /*"CoursePrivileges": "coursePrivilegeId",*/
    "CourseSections": "courseSectionId",
    "CourseSubscriptions": "courseSubscriptionId",
    "Courses": "courseId",
    "Images": "imageId",
    "OrganizationPrivileges": "organizationPrivilegeId",
    "Organizations": "organizationId",
    "Payments": "paymentId",
    "Tests": "testId",
    "Users": "userId",
    "Videos": "videoId",
    "Withdrawals": "withdrawalId",
}