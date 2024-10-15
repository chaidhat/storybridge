const Password = require('../password');
const getUserDb = require('../auth').getUserDb;
const progressBar = require('progress-bar-cli');

module.exports.migratePasswords = 
async () => {
    /*
    let userDatas = (await getUserDb().query("SELECT userId, password FROM Users;"));

    let startTime = new Date();
    let i = 0;
    for await (const userData of userDatas) {
        progressBar.progressBar(i, userDatas.length, startTime, { style: 4 });
        //add username sanitization?
        await getUserDb().query(
            `UPDATE Users SET password = '${await Password.hashOldPass(userData.password)}' WHERE userId = '${userData.userId}';`
        );
        i++;
    }

    console.log('Migration completed successfully');
    */
}