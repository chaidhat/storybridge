const orm = require("./orm/lib/orm");

async function onDatabaseStart() {
    await new Promise((resolve) => {
        setTimeout(resolve, 1000);
    });
    await orm.validateAllTables();
    if (orm.getValidity()) {
        //console.log("all tables schemas are consistent with db");
    } else {
        console.log("tables schemas NOT fully consistent");

    }
}
onDatabaseStart();

module.exports = Object.assign({},orm)