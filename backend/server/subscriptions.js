const Db = require('./database');

var subscriptions = new Db.DatabaseTable("Subscriptions",
    "subscriptionId",
    [
        {
        "name": "userId",
        "type": "int"
        },
        {
        "name": "courseId",
        "type": "int"
        },
        {
        "name": "dateSubscribed",
        "type": "datetime"
        },
]);
subscriptions.init();

async function subscribeToCourse (token, courseId) {
}

async function unsubscribeToCourse (token, courseId) {
}