const Db = require('./database');
const Auth = require('./auth');
const Token = require('./token');
const Org = require('./organizations');

var coordinatorPrivileges = new Db.DatabaseTable("CoordinatorPrivileges",
    "coordinatorPrivilegesId",
    [
        {
        name: "userId",
        type: "int"
        },
        {
        name: "coordinatorGroupId",
        type: "int"
        },
]);
coordinatorPrivileges.init();

var coordinatorGroups = new Db.DatabaseTable("CoordinatorGroups",
    "coordinatorGroupId",
    [
        {
        name: "organizationId",
        type: "int"
        },
        {
        name: "notificationEmail",
        type: "varchar(64)"
        },
        {
        name: "coordinatorGroupName",
        type: "varchar(64)"
        },
]);
coordinatorGroups.init();

module.exports.getCoordinatorPrivileges = getCoordinatorPrivileges;
async function getCoordinatorPrivileges (organizationId) {
    const coordGroups = await coordinatorGroups.select({organizationId: organizationId});
    let output = [];

    for (let i = 0; i < coordGroups.length; i++) {
        const coordPrivs = await coordinatorPrivileges.select({coordinatorGroupId: coordGroups[i].coordinatorGroupId});
        for (let j = 0; j < coordPrivs.length; j++) {
            let item = coordPrivs[j];
            const usr = await Auth.getUser(item.userId);
            for (const key in usr) {
                if (key !== "userId" && key !== "coordinatorGroupId") {
                    item[key] = usr[key];
                }
            }
            item.coordinatorGroupName = coordGroups[i].coordinatorGroupName;
            output.push(item);
        }
    }
    return output;
}

module.exports.assignCoordinatorToCoordinatorGroup = assignCoordinatorToCoordinatorGroup;
async function assignCoordinatorToCoordinatorGroup (userId, coordinatorGroupId) {
    if ((await coordinatorPrivileges.select({userId: userId, coordinatorGroupId: coordinatorGroupId})).length !== 0) {
        return; // there must only be ONE
    }

    await coordinatorPrivileges.insertInto({
        userId: userId,
        coordinatorGroupId: coordinatorGroupId,
    });
}

module.exports.deassignCoordinatorFromCoordinatorGroup = deassignCoordinatorFromCoordinatorGroup;
async function deassignCoordinatorFromCoordinatorGroup (userId, coordinatorGroupId) {
    await coordinatorPrivileges.deleteFrom({
        userId: userId,
        coordinatorGroupId: coordinatorGroupId,
    });
}

module.exports.getCoordinatorGroups = getCoordinatorGroups;
async function getCoordinatorGroups (organizationId) {
    const out = await coordinatorGroups.select({organizationId: organizationId});
    return out;
}

module.exports.createCoordinatorGroup = createCoordinatorGroup;
async function createCoordinatorGroup (
    token,
    organizationId,
    email,
    coordinatorGroupName,
) {
    const userId = (await Auth.getUserFromToken(token))[0].userId;
    // TODO: auth checks
    if (!(Org.isUserOrganizationTeacher(userId, organizationId))) {
        throw {status: 403, message: "user has insufficient permissions"}
    }

    const coordinatorGroupId = await coordinatorGroups.insertInto({
        organizationId: organizationId,
        notificationEmail: email,
        coordinatorGroupName: coordinatorGroupName,
    });

    // assign user as group coordinator
    await assignCoordinatorToCoordinatorGroup(userId, coordinatorGroupId);

    return group;
}

module.exports.changeCoordinatorGroup = changeCoordinatorGroup;
async function changeCoordinatorGroup (
    token,
    coordinatorGroupId,
    coordinatorGroupName,
    email,
) {
    const userId = (await Auth.getUserFromToken(token))[0].userId;
    const organizationId = (await coordinatorGroups.select({coordinatorGroupId: coordinatorGroupId}))[0].organizationId;

    // TODO: auth checks
    if (!(await isUserCoordinator(userId, coordinatorGroupId)) && !(Org.isUserOrganizationTeacher(userId, organizationId))) {
        throw {status: 403, message: "user has insufficient permissions"}
    }

    await coordinatorGroups.update(
        {
            coordinatorGroupId: coordinatorGroupId,
        },
        {
            coordinatorGroupName: coordinatorGroupName,
            notificationEmail: email,
        }
    );
}

module.exports.removeCoordinatorGroup = removeCoordinatorGroup;
async function removeCoordinatorGroup (token, coordinatorGroupId) {
    const userId = (await Auth.getUserFromToken(token))[0].userId;
    const organizationId = (await coordinatorGroups.select({coordinatorGroupId: coordinatorGroupId}))[0].organizationId;
    // TODO: auth checks
    if (!(Org.isUserOrganizationTeacher(userId, organizationId))) {
        throw {status: 403, message: "user has insufficient permissions"}
    }

    await coordinatorPrivileges.deleteFrom({
        coordinatorGroupId: coordinatorGroupId,
    });
    await coordinatorGroups.deleteFrom({
        coordinatorGroupId: coordinatorGroupId,
    });
}

async function isUserCoordinator(userId, coordinatorGroupId) {
    const group = await coordinatorPrivileges.select({
        userId: userId,
        coordinatorGroupId: coordinatorGroupId
    });
    return group.length !== 0;
}

