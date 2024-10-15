const Db = require('./database');
const prompt = require('prompt-sync')();

var dbService = new Db.DatabaseTable("", "", []);

console.log("======= Storybridge ssh database tool =======")
executePrompt();

async function executePrompt() {
    let queryStr = prompt("> ");
    if (queryStr === "exit") return;
    let data = await dbService.query(queryStr);
    console.log(data);
    executePrompt();
}