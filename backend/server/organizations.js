const Db = require('./database');
const Auth = require('./auth');
const Courses = require('./courses');
const Payment = require('./payment');

var organizations = new Db.DatabaseTable("Organizations",
    "organizationId",
    [
        {
        name: "organizationName",
        type: "varchar(1023)"
        },
        {
        name: "dateCreated",
        type: "datetime"
        },
        {
        name: "stripeCustomerId",
        type: "varchar(32)"
        },
        {
        name: "stripeAccountId",
        type: "varchar(32)"
        },
        {
        name: "email",
        type: "varchar(511)"
        },
        {
        name: "profilePictureImageId",
        type: "int"
        },
        {
        name: "extraUserDataFields",
        type: "mediumtext",
        }
]);
organizations.init();

var organizationPrivileges = new Db.DatabaseTable("OrganizationPrivileges",
    "organizationPrivilegeId",
    [
        {
        name: "organizationId",
        type: "int"
        },
        {
        name: "userId",
        type: "int"
        },
        {
        name: "canAnalyzeAll",
        type: "bit"
        },
        {
        name: "canEditAll",
        type: "bit"
        },
        {
        name: "canTeachAll",
        type: "bit"
        },
        {
        name: "isAdmin",
        type: "bit"
        },
        {
        name: "isOwner",
        type: "bit"
        },
]);
organizationPrivileges.init();

const DEFAULT_ORGANIZATION_OWNER_PRIVILEGES = {
    canAnalyzeAll: true,
    canEditAll: true,
    canTeachAll: true,
    isAdmin: true,
    isOwner: true,
};

module.exports.createOrganization = createOrganization;
async function createOrganization (token, organizationOptions) {
    // perform length checks
    if (encodeURI(organizationOptions.organizationName).length > 1023) {
        throw {status: 403, message: "organizationName is too long! (>1023 chars)"};
    }

    let organizationId = await organizations.insertInto({
        organizationName: organizationOptions.organizationName,
        dateCreated: Db.getDatetime(),
        stripeCustomerId: null,
        email: organizationOptions.email,
        profilePictureImageId: null,
        extraUserDataFields: "",
    });

    let data = await Auth.getUserFromToken(token);
    let userId = data[0].userId;

    let organizationPrivilegeId = await assignUserToOrganization(token, userId, organizationId, DEFAULT_ORGANIZATION_OWNER_PRIVILEGES, true);
    return {
        organizationId: organizationId,
        organizationPrivilegesId: organizationPrivilegeId,
    };
}

module.exports.deleteOrganization = deleteOrganization;
async function deleteOrganization (token, organizationId) {
    // check assigner has privileges
    let assignerPrivileges = await getOrgUserPrivilege(token, organizationId);
    let assignerIsOwner = Db.readBool(assignerPrivileges.isAdmin);
    if (!assignerIsOwner) {
        throw "assigner has insufficient permission";
    }

    // delete courses
    await Courses.deleteAllCoursesFromOrganization(organizationId);

    // delete the user privileges
    await organizationPrivileges.deleteFrom(
    {
        organizationId: organizationId,
    });

    // delete the organization
    await organizations.deleteFrom({
        organizationId: organizationId,
    })
}

module.exports.changeOrganizationOptions = changeOrganizationOptions;
async function changeOrganizationOptions (token, organizationId, organizationOptions) {
    // check assigner has privileges
    let assignerPrivileges = await getOrgUserPrivilege(token, organizationId);
    let assignerIsOwner = Db.readBool(assignerPrivileges.isAdmin);
    if (!assignerIsOwner) {
        throw "assigner has insufficient permission";
    }

    // perform length checks
    if (organizationOptions.oragnizationName != null) {
        if (encodeURI(organizationOptions.organizationName).length > 1023) {
            throw {status: 403, message: "organizationName is too long! (>1023 chars)"};
        }
    }
    if (organizationOptions.email != null) {
        if (encodeURI(organizationOptions.email).length > 511) {
            throw {status: 403, message: "email is too long! (>511 chars)"};
        }
    }

    await organizations.update(
        {organizationId:  organizationId},
        organizationOptions,
    );

    // update Stripe customer
    await Payment.updateStripeCustomer(organizationId, organizationOptions);
}

module.exports.getOrgUserPrivilege = getOrgUserPrivilege;
async function getOrgUserPrivilege(assignerToken, organizationId) {
    let assignerUserId = await Auth.getUserFromToken(assignerToken);
    assignerUserId = assignerUserId[0].userId;
    let data = await organizationPrivileges.select();
    let assignerOrganizationPrivilege = await organizationPrivileges.select({
        organizationId: organizationId,
        userId: assignerUserId,
    });
    if (assignerOrganizationPrivilege.length === 0) {
        throw "assigner not part of organization";
    }
    return assignerOrganizationPrivilege[0];
}

module.exports.assignUserToOrganization = assignUserToOrganization;
async function assignUserToOrganization (assignerToken, assigneeUserId, organizationId, privilegeOptions, overrideSafety = false) {
    if (!overrideSafety) {
        // check assigner has privileges
        let assignerPrivileges = await getOrgUserPrivilege(assignerToken, organizationId);
        let assignerIsAdmin = Db.readBool(assignerPrivileges.isAdmin);
        if (!assignerIsAdmin) {
            throw "assigner has insufficient permission to assign teacher to organization (must be admin)";
        }
    }

    // check if assignee has already been assigned
    let assigneeOrganizaionPrivilege = await organizationPrivileges.select({
        organizationId: organizationId,
        userId: assigneeUserId,
    });
    if (assigneeOrganizaionPrivilege.length > 0) {
        throw "assignee already is assigned. Cannot have more than one assignation";
    }

    // add the user privileges
    let organizationPrivilegeId = await organizationPrivileges.insertInto({
        organizationId: organizationId,
        userId: assigneeUserId,
        canAnalyzeAll: privilegeOptions.canAnalyzeAll,
        canEditAll: privilegeOptions.canEditAll,
        canTeachAll: privilegeOptions.canTeachAll,
        isAdmin: privilegeOptions.isAdmin,
        isOwner: privilegeOptions.isOwner && overrideSafety,
    });
    return organizationPrivilegeId;
}

module.exports.changeUserOrganizationPrivilege = changeUserOrganizationPrivilege;
async function changeUserOrganizationPrivilege (assignerToken, assigneeUserId, organizationId, privilegeOptions) {
    // check assigner has privileges
    let assignerPrivileges = await getOrgUserPrivilege(assignerToken, organizationId);
    let assignerIsAdmin = Db.readBool(assignerPrivileges.isAdmin);
    if (!assignerIsAdmin) {
        throw "assigner has insufficient permission to change teacher's permission from organization (must be admin)";
    }

    // add the user privileges
    await organizationPrivileges.update(
    {
        organizationId: organizationId,
        userId: assigneeUserId,
    },
    {
        canAnalyzeAll: privilegeOptions.canAnalyzeAll,
        canEditAll: privilegeOptions.canEditAll,
        canTeachAll: privilegeOptions.canTeachAll,
        isAdmin: privilegeOptions.isAdmin,
    });
}

module.exports.deassignUserFromOrganization = deassignUserFromOrganization;
async function deassignUserFromOrganization (assignerToken, assigneeUserId, organizationId) {
    // check assigner has privileges
    let assignerPrivileges = await getOrgUserPrivilege(assignerToken, organizationId);
    let assignerIsAdmin = Db.readBool(assignerPrivileges.isAdmin);
    if (!assignerIsAdmin) {
        throw "assigner has insufficient permission to deassign teacher from organization (must be admin)";
    }

    // delete the user's privileges
    await organizationPrivileges.deleteFrom(
    {
        organizationId: organizationId,
        userId: assigneeUserId,
    });
}

module.exports.getOrganization = getOrganization;
async function getOrganization(organizationId, getPaymentTier = false) {
    let org = await organizations.select({"organizationId": organizationId});
    if (getPaymentTier) {
        org[0].paymentTier = await Payment.getOrgSubscriptionTier(organizationId);
    }
    return org;
}

module.exports.getOrganizationPrivileges = getOrganizationPrivileges;
async function getOrganizationPrivileges(organizationPrivilegeId) {
    return await organizationPrivileges.select({"organizationPrivilegeId": organizationPrivilegeId});
}

module.exports.getOrganizationPrivilegesForOrganization = getOrganizationPrivilegesForOrganization;
async function getOrganizationPrivilegesForOrganization (token, organizationId) {
    // TODO: perform auth checks

    const organizationPrivilegesOfOrg = await organizationPrivileges.select({
        organizationId: organizationId
    });
    for (let i = 0; i < organizationPrivilegesOfOrg.length; i++) {
        const userData = await Auth.getUser(organizationPrivilegesOfOrg[i].userId);
        for (var key in userData) {
            organizationPrivilegesOfOrg[i][key] = userData[key];
        }
    }
    return organizationPrivilegesOfOrg;
}

module.exports.getOrganizationPrivilegesForUser = getOrganizationPrivilegesForUser;
async function getOrganizationPrivilegesForUser (token) {
    let user = await Auth.getUserFromToken(token);
    let userId = user[0].userId;

    let organizationPrivilegesOfUser = await organizationPrivileges.select({
        userId: userId,
    });
    return organizationPrivilegesOfUser;
}

module.exports.getOrganizationsForUser = getOrganizationsForUser;
async function getOrganizationsForUser(token) {
    let user = await Auth.getUserFromToken(token);
    let userId = user[0].userId;

    let organizationPrivilegesOfUser = await organizationPrivileges.select({
        userId: userId,
    });
    let organizationIds = [];
    for (var i = 0; i < organizationPrivilegesOfUser.length; i++) {
        let organizationId = organizationPrivilegesOfUser[i].organizationId;
        let organization = await organizations.select({organizationId: organizationId});
        let paymentTier = await Payment.getOrgSubscriptionTier(organizationId);

        organizationIds.push({
            organizationId: organizationId,
            organizationName: organization[0].organizationName,
            paymentTier: paymentTier,
        });
    }
    return organizationIds;
}

module.exports.setOrganizationStripeCustomerId = setOrganizationStripeCustomerId;
async function setOrganizationStripeCustomerId(orgId, stripeCustomerId) {
    await organizations.update({organizationId: orgId}, {stripeCustomerId: stripeCustomerId});
}

module.exports.isUserOrganizationTeacher = isUserOrganizationTeacher;
async function isUserOrganizationTeacher(userId, orgId) {
    const aop = await organizationPrivileges.select({
        organizationId: orgId,
        userId: userId,
    });
    return aop.length !== 0;
}

module.exports.getOrganizationExtraUserDataFields = getOrganizationExtraUserDataFields;
async function getOrganizationExtraUserDataFields(organizationId) {
    if (organizationId === 0) {
        return ["telephone", "jobTitle", "company", "employeeId"];
    }
    const org = await organizations.select({organizationId: organizationId});
    const eudFieldsJson = org[0].extraUserDataFields;
    if (eudFieldsJson === null || eudFieldsJson === undefined || eudFieldsJson === "") {
        return [];
    }
    const eudFields = JSON.parse(decodeURI(eudFieldsJson));
    let output = [];
    for (let i = 0; i < eudFields.data.length; i++) {
        output.push(eudFields.data[i].fieldName);
    }
    return output;
}