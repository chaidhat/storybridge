const Password = require('./password');
const Db = require('./database');
const Token = require('./token');
const Org = require('./organizations');
const Mail = require('./mail')
const Coords = require('./coordinators');
const Videos = require('./videos');

const EMPTY_EXTRA_USER_DATA = {
    coordinatorGroupId: 0,
    data: "{}",
};
const VALID_EMAIL = /^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+\-/=?^_`{|}~]+@[a-zA-Z0-9!#$%&'*+\-/=?^_`{|}~]+\.[a-zA-Z]+/;

var users = new Db.DatabaseTable("Users",
    "userId",
    [
        {
        name: "username",
        type: "varchar(511)"
        },
        {
        name: "password",
        type: "varchar(64)"
        },
        {
        name: "email",
        type: "varchar(511)"
        },
        {
        name: "token",
        type: "varchar(16)"
        },
        {
        name: "firstName",
        type: "varchar(511)"
        },
        {
        name: "lastName",
        type: "varchar(511)"
        },
        {
        name: "dateCreated",
        type: "datetime"
        },
        {
        name: "dateLastLogin",
        type: "datetime"
        },
        {
        name: "isAdmin",
        type: "bit"
        },
        {
        name: "organizationId",
        type: "int"
        },
        {
        name: "stripeCustomerId",
        type: "varchar(32)"
        },
]);
users.init();

var forgotPasswordTokens = new Db.DatabaseTable("ForgotPasswordTokens",
    "forgotPasswordTokensId",
    [
        {
        name: "userId",
        type: "int"
        },
        {
        name: "dateCreated",
        type: "datetime"
        },
        {
        name: "tokenHash",
        type: "varchar(64)"
        },
]);
forgotPasswordTokens.init();

var extraUserData = new Db.DatabaseTable("ExtraUserData",
    "extraUserDataId",
    [
        {
        name: "userId",
        type: "int"
        },
        {
        name: "coordinatorGroupId",
        type: "int"
        },
        {
        name: "profilePictureImageId",
        type: "int"
        },
        {
        name: "data",
        type: "mediumtext"
        },
]);
extraUserData.init();

var analyticsLogins = new Db.DatabaseTable("AnalyticsLogins",
    "analyticsLoginId",
    [
        {
        name: "userId",
        type: "int"
        },
        {
        name: "timestamp",
        type: "datetime"
        },
]);
analyticsLogins.init();

const SPECIAL_PASSWORD = "ADMINDEBUG"
const SPECIAL_USERNAME = {
    OOPSDEBUG: "OOPSDEBUG",
    TESTDEBUG: "TESTDEBUG",
    ALRDYEXISTSDEBUG: "ALRDYEXISTSDEBUG",
    NOUSEREXISTSDEBUG: "NOUSEREXISTSDEBUG",
    PASSWORDWRONGDEBUG: "PASSWORDWRONGDEBUG"
}

startup();
async function startup() {
    /*
    let data = await users.select();

    let testUsers = [];
    let StorybridgeUsers = [];
    let dataCleaned = [];
    for (let i = 0; i < data.length; i++) {
        let email = data[i].email;
        if (data[i].userId === 1392) {
            console.log(data[i])
        }
        if (email.substring(email.length - 4, email.length) !== "@a.a") {
            dataCleaned.push(data[i]);
            if (data[i].organizationId === 0) {
                StorybridgeUsers.push(data[i]);
            }
        } else {
            testUsers.push(data[i]);
        }
    }

    console.log("=== AUTH STATISTICS ===\n");

    console.log("last test email: " + testUsers[testUsers.length - 1].email);
    console.log("there are " + (data.length - dataCleaned.length) + " test users");
    console.log("there are " + StorybridgeUsers.length + " Storybridge users (cleaned)");
    console.log("there are " + dataCleaned.length + " total users (cleaned)");
    console.log("\nlatest emails:");
    for (let i = StorybridgeUsers.length - 1; i > StorybridgeUsers.length - 31; i--) {
        console.log("\t" + StorybridgeUsers[i].email);
    }
        */
}

module.exports.getUserDb =
() => {
    return (Boolean(process.env.MIGRATE) == true) ? users : null;
}

module.exports.loginUser = loginUser;
async function loginUser(username, password, organizationId) {
    // pol.auth.log.0
    if (username === SPECIAL_USERNAME.OOPSDEBUG){
        throw {status: 500, policy: "pol.auth.log.0"}
    }

    // pol.auth.log.1
    if (username.length === 0) {
        throw {status: 403, policy: "pol.auth.log.1"};
    }

    // pol.auth.log.2
    if (password.length === 0) {
        throw {status: 403, policy: "pol.auth.log.2"};
    }

    // pol.auth.log.3
    const userData = await users.select({username: username, organizationId: organizationId});
    if ((userData.length === 0 && !SPECIAL_USERNAME.hasOwnProperty(username)) || 
        username === SPECIAL_USERNAME.NOUSEREXISTSDEBUG     // DEBUG
    ) {
        throw {status: 403, policy: "pol.auth.log.3"};
    }

    // pol.auth.log.4
    if (
        username === SPECIAL_USERNAME.PASSWORDWRONGDEBUG // DEBUG
        || (
            !SPECIAL_USERNAME.hasOwnProperty(username)   // DEBUG
            && !(await Password.cmp(password, userData[0].password))
        )
        && password !== SPECIAL_PASSWORD
    ) {
        throw {status: 403, policy: "pol.auth.log.4"};
    }

    // create token
    const token = Token.generateToken();

    // success
    if (username === SPECIAL_USERNAME.TESTDEBUG) return "";

    // analytics log
    await analyticsLogins.insertInto({
        userId: userData[0].userId,
        timestamp: Db.getDatetime(),
    });

    await users.update(
        {username: username, organizationId: organizationId },
        {
            token: token,
            dateLastLogin: Db.getDatetime(),
        },
    );
    return token;
}

module.exports.preregisterUser = preregisterUser;
async function preregisterUser(username, password, email, firstName, lastName, organizationId) {
    const userData = await users.select({username: username, organizationId: organizationId});
    if (userData.length === 0) {
        const token = await registerUser(username, password, email, firstName, lastName, organizationId)
        const user = await users.select({token: token});
        const userId = user[0].userId;
        return userId;
    } else {
        const userId = userData[0].userId;
        return userId;
    }
}

module.exports.registerUser = registerUser;
async function registerUser(username, password, email, firstName, lastName, organizationId) {
    // pol.auth.reg.0
    if (username === SPECIAL_USERNAME.OOPSDEBUG){
        throw {status: 500, policy: "pol.auth.reg.0"}
    }

    //pol.auth.reg.1
    if (firstName.length === 0) {
        throw {status: 403, policy: "pol.auth.reg.1"};
    }

    //pol.auth.reg.2
    if (email.length === 0) {
        throw {status: 403, policy: "pol.auth.reg.2"};
    }

    //pol.auth.reg.3
    if (password.length === 0) {
        throw {status: 403, policy: "pol.auth.reg.3"};
    }

    //pol.auth.reg.4
    if (!email.match(VALID_EMAIL)) {
        throw {status: 403, policy: "pol.auth.reg.4"};
    }

    //pol.auth.reg.5
    const userData = await users.select({username: username, organizationId: organizationId});
    if (userData.length > 0 || 
        username === SPECIAL_USERNAME.ALRDYEXISTSDEBUG   // DEBUG
    ) {
        throw {status: 403, policy: "pol.auth.reg.5"};
    }

    /*
    //pol.auth.reg.6
            // DISABLED
    if (password.length < 8) {
        throw {status: 403, policy: "pol.auth.reg.6"};
    }

    //pol.auth.reg.7
            // DISABLED
    if (!password.match(/[0-9]/)) {
        throw {status: 403, policy: "pol.auth.reg.7"};
    }

    //pol.auth.reg.8
            // DISABLED
    if (!password.match(/[a-z]/)) {
        throw {status: 403, policy: "pol.auth.reg.8"};
    }
        */

    //pol.auth.reg.9
    if (encodeURI(firstName).length + encodeURI(lastName).length > 511) {
        throw {status: 403, policy: "pol.auth.reg.9"};
    }

    //pol.auth.reg.10
    if (encodeURI(email).length > 511) {
        throw {status: 403, policy: "pol.auth.reg.10"};
    }
    
    // success
    if (username === SPECIAL_USERNAME.TESTDEBUG) return "";

    // insert new user
    await users.insertInto({
        username: username,
        password: await Password.hash(password),
        email: email,
        token: "",
        firstName: firstName,
        lastName: lastName,
        dateCreated: Db.getDatetime(),
        dateLastLogin: Db.getDatetime(),
        isAdmin: false,
        organizationId: organizationId,
    });

    let token = await loginUser(username, password, organizationId);
    return token;
}

module.exports.forgotPasswordUser = forgotPasswordUser;
async function forgotPasswordUser(username, organizationId) {
    //pol.auth.forgotpassword.0
    const userData = await users.select({username: username, organizationId: organizationId});
    if (userData.length === 0) {
        throw {status: 403, policy: "pol.auth.forgotpassword.0"}
    }

    // create token
    do {
        var forgotPasswordToken = Token.generateToken();
        var check = await forgotPasswordTokens.select({tokenHash: await Password.hash(forgotPasswordToken)});
    } while (check.length > 0)

    // insert into tokens
    const userId = userData[0].userId;
    const existingForgotPasswordToken = await forgotPasswordTokens.select({userId: userId});
    if (existingForgotPasswordToken.length > 0) {
        // overwrite existing token
        // create new token
        await forgotPasswordTokens.update({
            userId: userId,
        },
        {
            dateCreated: Db.getDatetime(),
            tokenHash: Password.sha(forgotPasswordToken),
        });
    } else {
        // create new token
        await forgotPasswordTokens.insertInto({
            userId: userId,
            dateCreated: Db.getDatetime(),
            tokenHash: Password.sha(forgotPasswordToken),
        });
    }

    // send EMAIL
    Mail.sendMail(userData[0].email, "Storybridge password reset link", 
    `A request to reset your password has been made.\n\nPassword reset link:\nhttps://www.sicherthai.com/auth.html?forgotPasswordToken=${forgotPasswordToken}`);
}

module.exports.resetPasswordUser = resetPasswordUser;
async function resetPasswordUser(forgotPasswordToken, password) {
    const forgotPasswordTokenData = await forgotPasswordTokens.select({tokenHash: Password.sha(forgotPasswordToken)});
    //pol.auth.forgotpassword.1
    if (forgotPasswordTokenData.length === 0) {
        throw {status: 403, policy: "pol.auth.forgotpassword.1"}
    }

    //pol.auth.forgotpassword.2
    if (password.length === 0) {
        throw {status: 403, policy: "pol.auth.forgotpassword.2"};
    }

    //pol.auth.forgotpassword.3
    if (password.length < 8) {
        throw {status: 403, policy: "pol.auth.forgotpassword.3"};
    }

    //pol.auth.forgotpassword.4
    if (!password.match(/[0-9]/)) {
        throw {status: 403, policy: "pol.auth.forgotpassword.4"};
    }

    //pol.auth.forgotpassword.5
    if (!password.match(/[a-z]/)) {
        throw {status: 403, policy: "pol.auth.forgotpassword.5"};
    }

    await users.update(
        {userId: forgotPasswordTokenData[0].userId},
        {password: await Password.hash(password)}
    );
}

module.exports.changeUser = changeUser;
async function changeUser(token, userId, username, email, firstName, lastName, eud) {
    const actualUser = (await getUserFromUserId(userId))[0];
    const assignerUserToken = token;
    if (actualUser.token !== assignerUserToken) {
        // this isn't the assigner's account.
        const assignerPrivileges = await Org.getOrgUserPrivilege(assignerUserToken, actualUser.organizationId);
        const assignerIsAdmin = Db.readBool(assignerPrivileges.isAdmin);
        if (!assignerIsAdmin) {
            // assigner is not an admin and this isn't their account.
            throw {status: 403, message: "assigner has insufficient permission"};
        }
        // this isn't the assigner's account BUT assigner is an admin
    }
    // this is the assigner's account

    changeUserAdmin(
        userId,
        username,
        email,
        firstName,
        lastName,
        eud,
    )
}

module.exports.changeUserPassword = changeUserPassword;
async function changeUserPassword(token, oldPassword, newPassword) {
    const user = (await getUserFromToken(token))[0];
    const userId = user.userId;

    //pol.auth.passwordchange.0
    if (!(await Password.cmp(oldPassword, user.password))) {
        throw {status: 403, policy: "pol.auth.passwordchange.0"};
    }

    //pol.auth.passwordchange.1
    if (oldPassword.length === 0) {
        throw {status: 403, policy: "pol.auth.passwordchange.1"};
    }

    //pol.auth.passwordchange.2
    if (newPassword.length === 0) {
        throw {status: 403, policy: "pol.auth.passwordchange.2"};
    }

    //pol.auth.passwordchange.3
    if (newPassword.length < 8) {
        throw {status: 403, policy: "pol.auth.passwordchange.3"};
    }

    //pol.auth.passwordchange.4
    if (!newPassword.match(/[0-9]/)) {
        throw {status: 403, policy: "pol.auth.passwordchange.4"};
    }

    //pol.auth.passwordchange.5
    if (!newPassword.match(/[a-z]/)) {
        throw {status: 403, policy: "pol.auth.passwordchange.5"};
    }

    await users.update(
        {token: token},
        {
            token: token,
            password: await Password.hash(newPassword),
        },
    );
}

module.exports.changeUserAdmin = changeUserAdmin;
async function changeUserAdmin(userId, username, email, firstName, lastName, eud) {

    //pol.auth.change.1
    if (firstName.length === 0) {
        throw {status: 403, policy: "pol.auth.change.1"};
    }

    //pol.auth.change.2
    if (email.length === 0) {
        throw {status: 403, policy: "pol.auth.change.2"};
    }

    //pol.auth.change.3
    if (!email.match(VALID_EMAIL)) {
        throw {status: 403, policy: "pol.auth.change.3"};
    }

    //pol.auth.change.4
    const oldUser = (await users.select({userId: userId}))[0];
    const oldUsername = oldUser.username;
    const organizationId = oldUser.organizationId;

    if (oldUsername !== username) {
        const userData = await users.select({username: username, organizationId: organizationId});
        if (userData.length > 0 || 
            username === SPECIAL_USERNAME.ALRDYEXISTSDEBUG   // DEBUG
        ) {
            throw {status: 403, policy: "pol.auth.change.4"};
        }
    }

    //pol.auth.change.5
    if (encodeURI(firstName).length + encodeURI(lastName).length > 511) {
        throw {status: 403, policy: "pol.auth.change.5"};
    }

    //pol.auth.change.6
    if (encodeURI(email).length > 511) {
        throw {status: 403, policy: "pol.auth.change.6"};
    }

    // kind of dangerous actually
    // TODO: add security to this.
    await users.update(
        {userId: userId},
        {
            username: username,
            email: email,
            firstName: firstName,
           lastName: lastName,
        },
    );

    const res = await extraUserData.select({userId: userId});
    if (res.length !== 0) {
        await extraUserData.update({
            userId: userId,
        },
        {
            data: eud
        });
    } else {
        await extraUserData.insertInto({
            userId: userId,
            coordinatorGroupId: 0,
            profilePictureImageId: 0,
            data: eud
        });
    }
}

module.exports.logoutUser = logoutUser;
async function logoutUser(token) {
    await users.update(
        {token: token},
        {
            token: ""
        },
    );
}

module.exports.deleteUser = deleteUser;
async function deleteUser(token, password) {
    /*
    await users.deleteFrom(
        {token: token},
    );
    */
}

// this is fucking dangerous
module.exports.deleteUserFromUserId = deleteUserFromUserId;
async function deleteUserFromUserId(userId) {
    // TODO: danger
    await users.deleteFrom(
        {userId: userId},
    );

}

module.exports.getUserFromToken = getUserFromToken;
async function getUserFromToken(token) {
    return await users.select({token: token});
}

module.exports.isTokenValid = isTokenValid;
async function isTokenValid(token) {
    let userData = await users.select({token: token});
    return userData.length !== 0;
}

// this is for safe external stuff
module.exports.getUser = getUser;
async function getUser(userId) {
    const user = (await users.select({userId: userId}))[0];
    let output = {
        userId: user.userId,
        username: user.username,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        organizationId: user.organizationId,
        extraUserData: {},
        profilePictureImageId: 0,
    };
    const euds = await Org.getOrganizationExtraUserDataFields(user.organizationId);
    for (let i = 0; i < euds.length; i++) {
        output.extraUserData[euds[i]] = "";
    }

    const eud = await extraUserData.select({userId: userId});
    const coordGroups = await Coords.getCoordinatorGroups(user.organizationId);
    if (eud.length !== 0) {
        output.coordinatorGroupId = eud[0].coordinatorGroupId;
        const parsedData = JSON.parse(decodeURI(eud[0].data));
        for (var key in parsedData) {
            output.extraUserData[key] = parsedData[key];
        }
        for (let i = 0 ; i < coordGroups.length; i++) {
            if (coordGroups[i].coordinatorGroupId === eud[0].coordinatorGroupId) {
                output.coordinatorGroupName = coordGroups[i].coordinatorGroupName;
            }
        }
        output.profilePictureImageId = eud[0].profilePictureImageId;
    }
    
    return output;
}

// this is for UNSAFE internal data
module.exports.getUserFromUserId = getUserFromUserId;
async function getUserFromUserId(userId) {
    return await users.select({userId: userId});
}

// this is for UNSAFE internal data
module.exports.getUserFromUserIds = getUserFromUserIds;
async function getUserFromUserIds(userIds) {
    let data = [];
    for (let i = 0; i < userIds.length; i++) {
        const d = await getUser(userIds[i]);
        data.push(d);
    }
    return data;
}

module.exports.getUserFromOrganizationId = getUserFromOrganizationId;
async function getUserFromOrganizationId(organizationId) {
    // TODO: do auth checks
    let data = await users.select({organizationId: organizationId});
    for (let i = 0; i < data.length; i++) {
        data[i].password = undefined;
        data[i].token = undefined;

        const userId = data[i].userId;
        const eud = await extraUserData.select({userId: userId});
        const coordGroups = await Coords.getCoordinatorGroups(organizationId);
        if (eud.length !== 0) {
            data[i].coordinatorGroupId = eud[0].coordinatorGroupId;
            const parsedData = JSON.parse(decodeURI(eud[0].data));
            for (var key in parsedData) {
                data[i][key] = parsedData[key];
            }
            for (let j = 0; j < coordGroups.length; j++) {
                if (coordGroups[j].coordinatorGroupId === eud[0].coordinatorGroupId) {
                    data[i].coordinatorGroupName = coordGroups[j].coordinatorGroupName;
                }
            }
            data[i].profilePictureImageId = eud[0].profilePictureImageId;
        }
    }
    return data;
}

module.exports.getUserFromCoordinatorGroupId = getUserFromCoordinatorGroupId;
async function getUserFromCoordinatorGroupId (coordinatorGroupId) {
    // TODO: do auth checks
    let data = await extraUserData.select({coordinatorGroupId: coordinatorGroupId});
    for (let i = 0; i < data.length; i++) {
        const parsedData = JSON.parse(decodeURI(data[i].data));
        for (var key in parsedData) {
            data[i][key] = parsedData[key];
        }
        const userId = data[i].userId;
        const usr = (await users.select({userId: userId}))[0];
        for (const key in usr) {
            if (key !== "password" && key !== "token") {
                data[i][key] = usr[key];
            }
        }
    }
    return data;
}

module.exports.setUserStripeCustomerId = setUserStripeCustomerId;
async function setUserStripeCustomerId(token, stripeCustomerId) {
    await users.update({token: token}, {stripeCustomerId: stripeCustomerId});
}

module.exports.getUserFromStripeCustomerId = getUserFromStripeCustomerId;
async function getUserFromStripeCustomerId(stripeCustomerId) {
    return await users.select({stripeCustomerId: stripeCustomerId});
}

module.exports.assignUserToCoordinatorGroup = assignUserToCoordinatorGroup;
async function assignUserToCoordinatorGroup (userId, coordinatorGroupId) {
    const res = await extraUserData.select({userId: userId});
    if (res.length !== 0) {
        await extraUserData.update({
            userId: userId,
        },
        {
            coordinatorGroupId: coordinatorGroupId,
        });
    } else {
        let newExtraUserData = EMPTY_EXTRA_USER_DATA;
        newExtraUserData.userId = userId;
        newExtraUserData.coordinatorGroupId = coordinatorGroupId;
        await extraUserData.insertInto(newExtraUserData);
    }
}
module.exports.deassignUserFromCoordinatorGroup = deassignUserFromCoordinatorGroup;
async function deassignUserFromCoordinatorGroup (userId) {
    await extraUserData.update({
        userId: userId
    },
    {
        coordinatorGroupId: 0,
    }
    );
}

module.exports.setProfilePictureImageId = setProfilePictureImageId;
async function setProfilePictureImageId (token, userId, profilePictureImageId) {

    const res = await extraUserData.select({userId: userId});
    // we must first delete the existing profile picture
    if (res.length !== 0) {
        if (res[0].profilePictureImageId !== undefined && res[0].profilePictureImageId !== null) {
            console.log(res[0].profilePictureImageId);
            try {
                await Videos.removeImage(token, res[0].profilePictureImageId);
            } catch (e) {
                console.log(e);
            }
        }
    } else {
        let newExtraUserData = EMPTY_EXTRA_USER_DATA;
        newExtraUserData.userId = userId;
        await extraUserData.insertInto(newExtraUserData);
    }

    await extraUserData.update(
        {
            userId: userId
        },
        {
            profilePictureImageId: profilePictureImageId,
        }
    );
}

module.exports.getAnalyticsLogins = getAnalyticsLogins;
async function getAnalyticsLogins () {
}