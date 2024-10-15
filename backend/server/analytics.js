const Db = require('./database');

var analyticsEvents = new Db.DatabaseTable("AnalyticsEvent",
    "analyticsEventId",
    [
        {
        name: "timeCreated",
        type: "datetime"
        },
        {
        name: "analyticsEventType",
        type: "int"
        },
        {
        name: "analyticsEventSubtype",
        type: "int"
        },
        {
        name: "analyticsEventDataId",
        type: "int"
        },
]);
analyticsEvents.init();

var analyticsEventData = new Db.DatabaseTable("AnalyticsEventData",
    "analyticsEventDataId",
    [
        {
        name: "analyticsEventData",
        type: "varchar(2048)"
        },
]);
analyticsEventData.init();

var analyticsFormBugs = new Db.DatabaseTable("AnalyticsFormBugs",
    "analyticsFormBugsId",
    [
        {
        name: "timeCreated",
        type: "datetime"
        },
        {
        name: "analyticsFormBugType",
        type: "int"
        },
        {
        name: "analyticsFormBugData",
        type: "varchar(2048)"
        },
]);
analyticsFormBugs.init();

var analyticsFormFeedback = new Db.DatabaseTable("AnalyticsFormFeedback",
    "analyticsFormFeedbackId",
    [
        {
        name: "timeCreated",
        type: "datetime"
        },
        {
        name: "analyticsFormFeedbackType",
        type: "int"
        },
        {
        name: "analyticsFormFeedbackData",
        type: "varchar(2048)"
        },
]);
analyticsFormFeedback.init();

module.exports.triggerAnalyticsEvent = triggerAnalyticsEvent;
async function triggerAnalyticsEvent(analyticsEventType, analyticsEventSubtype, analyticsEventDataData) {
    if (analyticsEventDataData !== null && analyticsEventDataData !== undefined) {
        console.log(analyticsEventDataData);
        var analyticsEventDataId = await analyticsEventData.insertInto(
            {
                analyticsEventData: JSON.stringify(analyticsEventDataData),
            }
        );
    } else {
        var analyticsEventDataId = null;
    }
    //BUG HERE
    /*
    await analyticsEvents.insertInto(
        {
            timeCreated: Db.getDatetime(),
            analyticsEventType: analyticsEventType,
            analyticsEventSubtype: analyticsEventSubtype,
            analyticsEventDataId: analyticsEventDataId,
        }
    );
    console.log("analytics: time: " + (new Date()).toLocaleString("en-US", { timeZone: "Asia/Bangkok" }) + "\t\ttype: " + analyticsEventType  + "\t\tsubtype: " + analyticsEventSubtype + "\t\tdata:" + analyticsEventDataData);
    */
}

module.exports.getAnalyticEvents = getAnalyticsEvents;
async function getAnalyticsEvents(analyticsEventType) {
    let data = await analyticsEvents.select({
        analyticsEventType: analyticsEventType,
    });
    return data;
}

module.exports.getAnalyticEventData = getAnalyticsEventData;
async function getAnalyticsEventData(analyticsEventDataId) {
    let data = await analyticsEventData.select({
        analyticsEventDataId: analyticsEventDataId,
    });
    data[0].analyticsEventData = JSON.parse(decodeURI(data[0].analyticsEventData));
    return data;
}

module.exports.executeAnalyticsCommand = executeAnalyticsCommand;
async function executeAnalyticsCommand() {
    let data = await analyticsEvents.select();
    console.log(data.length);
}