const Db = require('./database');
const Auth = require('./auth');

const auditTemplates = new Db.DatabaseTable("AuditTemplates",
    "auditTemplateId",
    [
        {
        name: "auditTemplateName",
        type: "varchar(1023)"
        },
        {
        name: "auditTemplateDescription",
        type: "varchar(4095)"
        },
        {
        name: "organizationId",
        type: "int"
        },
        {
        name: "dateCreated",
        type: "datetime"
        },
        {
        name: "dateModified",
        type: "datetime"
        },
        {
        name: "isLive",
        type: "bit"
        },
        {
        name: "statusLabelGroupId",
        type: "int"
        },
        {
        name: "auditTemplateData",
        type: "mediumtext"
        },
]);
auditTemplates.init();

const auditTasks = new Db.DatabaseTable("AuditTasks",
    "auditTaskId",
    [
        {
        name: "auditTaskName",
        type: "varchar(1023)"
        },
        {
        name: "auditTaskDescription",
        type: "varchar(4095)"
        },
        {
        name: "auditTemplateId",
        type: "int"
        },
        {
        name: "auditTaskData",
        type: "mediumtext"
        },
        {
        name: "dateCreated",
        type: "datetime"
        },
        {
        name: "dateModified",
        type: "datetime"
        },
        {
        name: "status",
        type: "varchar(256)"
        },
]);
auditTasks.init();

const auditTaskQuestions = new Db.DatabaseTable("AuditTaskQuestions",
    "auditTaskQuestionId",
    [
        {
        name: "auditTaskId",
        type: "int"
        },
        {
        name: "quid",
        type: "varchar(16)"
        },
        {
        name: "data",
        type: "mediumtext"
        },
]);
auditTaskQuestions.init();

const auditPrivileges = new Db.DatabaseTable("AuditPrivileges",
    "auditPrivilegeId",
    [
        {
        name: "userId",
        type: "int"
        },
        {
        name: "auditTaskId",
        type: "int"
        },
        {
        name: "canEdit",
        type: "bit"
        },
        {
        name: "canComment",
        type: "bit"
        },
        {
        name: "isOwner",
        type: "bit"
        },

        {
        name: "submitMode",
        type: "int"
        },
        {
        name: "dateCreated",
        type: "datetime"
        },
        {
        name: "dateSubmitted",
        type: "datetime"
        },
        {
        name: "submitData",
        type: "mediumtext"
        },
]);
auditPrivileges.init();

const workflowNodes = new Db.DatabaseTable("WorkflowNodes",
    "workflowNodeId",
    [
        {
        name: "auditTemplateId",
        type: "int"
        },
        {
        name: "workflowNodetype",
        type: "int"
        },
        {
        name: "data",
        type: "mediumtext"
        },
]);
workflowNodes.init();

const workflowConnections = new Db.DatabaseTable("WorkflowConnections",
    "workflowConnectionId",
    [
        {
        name: "auditTemplateId",
        type: "int"
        },
        {
        name: "sourceAuditWorkflowNodeId",
        type: "int"
        },
        {
        name: "sourceOutputNumber",
        type: "int"
        },
        {
        name: "sinkAuditWorkflowNodeId",
        type: "int"
        },
        {
        name: "sinkInputNumber",
        type: "int"
        },
]);
workflowConnections.init();

const labels = new Db.DatabaseTable("Labels",
    "labelId",
    [
        {
        name: "labelGroupId",
        type: "int"
        },
        {
        name: "color",
        type: "varchar(6)"
        },
        {
        name: "labelName",
        type: "varchar(4095)"
        },
        {
        name: "labelDescription",
        type: "varchar(4095)"
        },
]);
labels.init();
const labelGroups = new Db.DatabaseTable("LabelGroups",
    "labelGroupId",
    [
        {
        name: "organizationId",
        type: "int"
        },
        {
        name: "labelGroupName",
        type: "varchar(4095)"
        },
        {
        name: "isMultichoiceAllowed",
        type: "bit"
        },
        {
        name: "canUserDelete",
        type: "bit"
        },
]);
labelGroups.init();


// audit templates did not have statuss label groups associated with them before. Create one for all of them.
/*
async function DEBUG_RetrofitAuditTemplatesWithStatusLabelGroupIds() {
    const templates = await auditTemplates.select();
    for (let i = 0; i < templates.length; i++) {
        const slgi = await createLabelGroup("", templates[i].organizationId, `${decodeURI(templates[i].auditTemplateName)} Statuses`, "false", "false")
        await auditTemplates.update(
            {
                auditTemplateId: templates[i].auditTemplateId,
            },
            {
                statusLabelGroupId: slgi,
            }
        );
    }
}
*/

module.exports.getAuditTemplates = getAuditTemplates;
async function getAuditTemplates (organizationId) {
    // also return how many bookings there are per training
    const templates = await auditTemplates.select({organizationId: organizationId});
    for (let i = 0; i < templates.length; i++) {
        delete templates[i].auditTemplateData; // clean up a bit
    }
    return templates;
}

module.exports.getAuditTemplate = getAuditTemplate;
async function getAuditTemplate (auditTemplateId) {
    // also return how many bookings there are per training
    return await auditTemplates.select({auditTemplateId: auditTemplateId});
}


module.exports.createAuditTemplate = createAuditTemplate;
async function createAuditTemplate (
    token, 
    auditTemplateName,
    auditTemplateDescription,
    organizationId,
    auditTemplateData,
) {
    // create a new labelGroup so that it can use as its status
    const statusLabelGroupId = await createLabelGroup (token, organizationId,`${decodeURI(auditTemplateName)} Statuses`, "false", "false");

    // create the audit template itself
    const auditTemplateId = await auditTemplates.insertInto({
        auditTemplateName: auditTemplateName,
        auditTemplateDescription: auditTemplateDescription,
        organizationId: organizationId,
        dateCreated: Db.getDatetime(),
        dateModified: Db.getDatetime(),
        isLive: false,
        statusLabelGroupId: statusLabelGroupId,
        auditTemplateData: auditTemplateData
    });
    return auditTemplateId;
}

module.exports.changeAuditTemplate = changeAuditTemplate;
async function changeAuditTemplate (
    token,
    auditTemplateId,
    auditTemplateName,
    auditTemplateDescription,
    auditTemplateData,
) {
    const at = await auditTemplates.select({auditTemplateId: auditTemplateId});
    await labelGroups.update({
        labelGroupId: at[0].statusLabelGroupId
    }, {
        labelGroupName: `${decodeURI(auditTemplateName)} Statuses`
    });
    await auditTemplates.update(
        {
            auditTemplateId: auditTemplateId,
        },
        {
            auditTemplateName: auditTemplateName,
            auditTemplateDescription: auditTemplateDescription,
            auditTemplateData: auditTemplateData,
        }
    );
}

module.exports.removeAuditTemplate = removeAuditTemplate;
async function removeAuditTemplate (token, auditTemplateId) {
    if ((await auditTasks.select({auditTemplateId: auditTemplateId})).length > 0) {
        throw {status: 403, message: "AuditTasks exist with this template already."}
    }
    // delete the associated status label group
    const at = await auditTemplates.select({auditTemplateId: auditTemplateId});
    await labelGroups.deleteFrom({
        labelGroupId: at[0].statusLabelGroupId
    });

    await auditTemplates.deleteFrom(
        {
            auditTemplateId: auditTemplateId,
        }
    );
    await removeWorkflow(auditTemplateId);
}

module.exports.getAuditTasks = getAuditTasks;
async function getAuditTasks (organizationId) {
    // also return how many bookings there are per training
    let output = [];
    const templates = await auditTemplates.select({organizationId: organizationId});
    for (let i = 0; i < templates.length; i++) {
        const tasks = await auditTasks.select({auditTemplateId: templates[i].auditTemplateId});
        for (let j = 0; j < tasks.length; j++) {
            delete tasks[j].auditTaskData; // clean up a bit
            tasks[j].auditTemplateName = templates[i].auditTemplateName;
            const selectedLabelIds = JSON.parse(decodeURI(tasks[j].status));
            tasks[j].status = await expandLabel(selectedLabelIds);
            output.push(tasks[j]);
        }
    }
    return output;
}
module.exports.getAuditTasksForTemplate = getAuditTasksForTemplate;
async function getAuditTasksForTemplate (auditTemplateId) {
    // also return how many bookings there are per training
    const tasks = await auditTasks.select({auditTemplateId: auditTemplateId});
    for (let i = 0; i < tasks.length; i++) {
        delete tasks[i].auditTaskData; // clean up a bit
    }
    return tasks;
}

module.exports.getAuditTask = getAuditTask;
async function getAuditTask (token, auditTaskId) {
    // auth check
    await assertUserCanViewAuditTask(token, auditTaskId);

    // also return how many bookings there are per training
    const a = await auditTasks.select({auditTaskId: auditTaskId});
    const selectedLabelIds = JSON.parse(decodeURI(a[0].status));
    a[0].status = await expandLabel(selectedLabelIds);
    return a;
}


module.exports.createAuditTask = createAuditTask;
async function createAuditTask (
    token, 
    auditTaskName,
    auditTaskDescription,
    auditTemplateId,
    auditTaskData,
    status,
) {
    const userId = (await Auth.getUserFromToken(token))[0].userId;
    // add lecture
    const auditTaskId = await auditTasks.insertInto({
        auditTaskName: auditTaskName,
        auditTaskDescription: auditTaskDescription,
        auditTemplateId: auditTemplateId,
        auditTaskData: auditTaskData,
        dateCreated: Db.getDatetime(),
        dateModified: Db.getDatetime(),
        status: status,
    });
    // add privilege
    const auditPrivilegeId = await auditPrivileges.insertInto({
        userId: userId,
        auditTaskId: auditTaskId,
        canEdit: true,
        canComment: true,
        isOwner: true,
        submitMode: 0,
        dateCreated: Db.getDatetime(),
        //dateSubmitted: null,
        //submitData: null,
    });
    return auditTaskId;
}

module.exports.changeAuditTask = changeAuditTask;
async function changeAuditTask (
    token,
    auditTaskId,
    auditTaskName,
    auditTaskDescription,
    auditTaskData,
) {
    await auditTasks.update(
        {
            auditTaskId: auditTaskId,
        },
        {
            auditTaskName: auditTaskName,
            auditTaskDescription: auditTaskDescription,
            auditTaskData: auditTaskData,
            dateModified: Db.getDatetime(),
        }
    );
}

module.exports.removeAuditTask = removeAuditTask;
async function removeAuditTask (token, auditTaskId) {
    await auditTasks.deleteFrom(
        {
            auditTaskId: auditTaskId,
        }
    );
    await auditTaskQuestions.deleteFrom(
        {
            auditTaskId: auditTaskId,
        }
    );
}


module.exports.getAuditTaskQuestion = getAuditTaskQuestion;
async function getAuditTaskQuestion (quid, auditTaskId) {
    return await auditTaskQuestions.select({
        auditTaskId: auditTaskId,
        quid: quid,
    });
}

module.exports.setAuditTaskQuestion = setAuditTaskQuestion;
async function setAuditTaskQuestion (quid, auditTaskId, data) {
    const atq = await auditTaskQuestions.select({
        auditTaskId: auditTaskId,
        quid: quid,
    });
    if (atq.length > 0) {
        // audit task question already exists
        // audit task question needs to be created
        await auditTaskQuestions.update({
            auditTaskId: auditTaskId,
            quid: quid,
        }, {
            data: data,
        });
    } else {
        // audit task question needs to be created
        await auditTaskQuestions.insertInto({
            auditTaskId: auditTaskId,
            quid: quid,
            data: data,
        });
    }
    await auditTasks.update(
        {
            auditTaskId: auditTaskId,
        },
        {
            dateModified: Db.getDatetime(),
        }
    );
}

module.exports.getAuditTemplateQuestions = getAuditTemplateQuestions;
async function getAuditTemplateQuestions (token, auditTemplateId) {
    const at = await auditTemplates.select({
        auditTemplateId: auditTemplateId,
    });
    const auditTemplateData = JSON.parse(decodeURI(at[0].auditTemplateData));
    let output = [];
    for (let i = 0; i < auditTemplateData.pages.length; i++) {
        const page = auditTemplateData.pages[i].data;
        const column = page.children;
        for (let j = 0; j < column.length; j++) {
            if (column[j].quid !== undefined) {
                output.push(column[j]);
            }
        }
    }
    return output;

}

module.exports.getAuditPrivilegesForUserId = getAuditPrivilegesForUserId;
async function getAuditPrivilegesForUserId(token, userId) {
    // TODO: do auth
    // get assignee userid from username
    let data = await auditPrivileges.select({userId: userId})
    for (let i = 0; i < data.length; i++) {
        const auditTaskId = data[i].auditTaskId;
        const auditTask = await auditTasks.select({auditTaskId: auditTaskId});
        data[i].dateCreated = auditTask[0].dateCreated;
        data[i].dateModified = auditTask[0].dateModified;
        data[i].auditTaskId = auditTask[0].auditTaskId;
        const auditTemplate = await auditTemplates.select({auditTemplateId: auditTask[0].auditTemplateId});
        data[i].auditTemplateName = auditTemplate[0].auditTemplateName;
    }
    return data;
}
module.exports.getAuditPrivilegesForAuditTask = getAuditPrivilegesForAuditTask;
async function getAuditPrivilegesForAuditTask(token, auditTaskId) {
    // TODO: do auth
    // get assignee userid from username
    let data = await auditPrivileges.select({auditTaskId: auditTaskId})
    for (let i = 0; i < data.length; i++) {
        const userId = data[i].userId;
        const user = await Auth.getUserFromUserId(userId);
        data[i].name = `${user[0].firstName} ${user[0].lastName}`;
        data[i].email = user[0].email;
        try {
            data[i].submitVerb = JSON.parse(decodeURI(data[i].submitData)).submitVerb;
        } catch (_) {

        }
    }
    return data;
}
module.exports.getAuditPrivilegeForUserAndAuditTask = getAuditPrivilegeForUserAndAuditTask;
async function getAuditPrivilegeForUserAndAuditTask(token, auditTaskId) {
    const userId = (await Auth.getUserFromToken(token))[0].userId;
    const ap = await auditPrivileges.select({userId: userId, auditTaskId: auditTaskId});
    return ap;
}

module.exports.createAuditPrivilege = createAuditPrivilege;
async function createAuditPrivilege (
    token, 
    userId,
    auditTaskId,
    canEdit,
    canComment,
    submitMode,
) {
    const exisitingPrivileges = await auditPrivileges.select({userId: userId, auditTaskId: auditTaskId});
    if (exisitingPrivileges.length > 0) {
        let isAllClosed = true;
        for (let i = 0; i < exisitingPrivileges.length; i++) {
            if (exisitingPrivileges[i].dateSubmitted === null) {
                isAllClosed = false;
                break;
            }
        }
        if (!isAllClosed) {
            throw {status: 403, message: "Cannot create more than one OPEN audit privilege per user. Change it instead or have them submit it."};
        }
    }
    const auditPrivilegeId = await auditPrivileges.insertInto({
        userId: userId,
        auditTaskId: auditTaskId,
        canEdit: canEdit === "true",
        canComment: canComment === "true",
        isOwner: false,
        submitMode: submitMode,
        dateCreated: Db.getDatetime(),
        //dateSubmitted: null,
        //submitData: null,
    });
    return auditPrivilegeId;
}

module.exports.changeAuditPrivilege = changeAuditPrivilege;
async function changeAuditPrivilege (
    token, 
    auditPrivilegeId,
    canEdit,
    canComment,
    submitMode,
) {
    await auditPrivileges.update(
        {
            auditPrivilegeId: auditPrivilegeId,
        },
        {
            canEdit: canEdit === "true",
            canComment: canComment === "true",
            submitMode: submitMode,
        }
    );
    return auditPrivilegeId;
}

module.exports.removeAuditPrivilege = removeAuditPrivilege;
async function removeAuditPrivilege (
    token, 
    auditPrivilegeId,
) {
    const exisitngPrivilege = await auditPrivileges.select({auditPrivilegeId: auditPrivilegeId});
    if (Db.readBool(exisitngPrivilege[0].isOwner)) {
        throw {status: 403, message: "Cannot remove an owner."};
    }
    await auditPrivileges.deleteFrom(
        {
            auditPrivilegeId: auditPrivilegeId,
        },
    );
    return auditPrivilegeId;
}

module.exports.getWorkflow = getWorkflow;
async function getWorkflow (auditTemplateId) {
    // also return how many bookings there are per training
    const nodes = await workflowNodes.select({auditTemplateId: auditTemplateId});
    const connections = await workflowConnections.select({auditTemplateId: auditTemplateId});
    return {
        nodes: nodes,
        connections: connections,
    };
}

module.exports.removeWorkflow = removeWorkflow;
async function removeWorkflow (auditTemplateId) {
    // also return how many bookings there are per training
    await workflowNodes.deleteFrom({auditTemplateId: auditTemplateId});
    await workflowConnections.deleteFrom({auditTemplateId: auditTemplateId});
}

module.exports.createWorkflowNode = createWorkflowNode;
async function createWorkflowNode (token, auditTemplateId, workflowNodeType, data) {
    const workflowNodeId = await workflowNodes.insertInto({
        auditTemplateId: auditTemplateId,
        workflowNodeType: workflowNodeType,
        data: data,
    });
    return workflowNodeId;
}

module.exports.changeWorkflowNode = changeWorkflowNode;
async function changeWorkflowNode (workflowNodeId, data) {
    await workflowNodes.update(
        {
            workflowNodeId: workflowNodeId,
        },
        {
            data: data
        }
    );
}

module.exports.removeWorkflowNode = removeWorkflowNode;
async function removeWorkflowNode (workflowNodeId) {
    await workflowNodes.deleteFrom(
        {
            workflowNodeId: workflowNodeId,
        }
    );
    await workflowConnections.deleteFrom(
        {
            sourceAuditWorkflowNodeId: workflowNodeId,
        }
    );
    await workflowConnections.deleteFrom(
        {
            sinkAuditWorkflowNodeId: workflowNodeId,
        }
    );
}

module.exports.createWorkflowConnection = createWorkflowConnection;
async function createWorkflowConnection (token, auditTemplateId, sourceAuditWorkflowNodeId, sourceOutputNumber, sinkAuditWorkflowNodeId, sinkInputNumber) {
    const workflowConnectionId = await workflowConnections.insertInto({
        auditTemplateId: auditTemplateId,
        sourceAuditWorkflowNodeId: sourceAuditWorkflowNodeId,
        sourceOutputNumber: sourceOutputNumber,
        sinkAuditWorkflowNodeId: sinkAuditWorkflowNodeId,
        sinkInputNumber: sinkInputNumber,
    });
    return workflowConnectionId;
}

module.exports.removeWorkflowConnection = removeWorkflowConnection;
async function removeWorkflowConnection (sourceAuditWorkflowNodeId, sinkAuditWorkflowNodeId) {
    await workflowConnections.deleteFrom(
        {
            sourceAuditWorkflowNodeId: sourceAuditWorkflowNodeId,
            sinkAuditWorkflowNodeId: sinkAuditWorkflowNodeId,
        }
    );
}

module.exports.submitAuditTask = submitAuditTask;
async function  submitAuditTask (auditTaskId) {
    await auditTasks.update(
        {auditTaskId: auditTaskId},
        {
            status: "awaiting approval"
        }
    );
}

module.exports.approveAuditTask = approveAuditTask;
async function  approveAuditTask (auditTaskId) {
    await auditTasks.update(
        {auditTaskId: auditTaskId},
        {
            status: "approved"
        }
    );
}

module.exports.rejectAuditTask = rejectAuditTask;
async function  rejectAuditTask (auditTaskId) {
    await auditTasks.update(
        {auditTaskId: auditTaskId},
        {
            status: "rejected"
        }
    );
}
module.exports.changeAuditTaskStatus = changeAuditTaskStatus;
async function  changeAuditTaskStatus (auditTaskId, status) {
    await auditTasks.update(
        {auditTaskId: auditTaskId},
        {
            status: status
        }
    );
}
module.exports.getLabelGroups = getLabelGroups;
async function getLabelGroups (organizationId) {
    // also return how many bookings there are per training
    return await labelGroups.select({organizationId: organizationId});
}
module.exports.getLabelGroup = getLabelGroup;
async function getLabelGroup (labelGroupId) {
    // also return how many bookings there are per training
    return await labelGroups.select({labelGroupId: labelGroupId});
}
module.exports.getLabels = getLabels;
async function getLabels (labelGroupId) {
    // also return how many bookings there are per training
    const data = await labels.select({labelGroupId: labelGroupId});
    // add previews
    for (let i = 0; i < data.length; i++) {
        data[i].preview = await expandLabel({selectedLabels: [data[i].labelId]});
    }
    return data;
}

module.exports.createLabelGroup = createLabelGroup;
async function createLabelGroup (token, organizationId, labelGroupName, isMultichoiceAllowed, canUserDelete) {
    // also return how many bookings there are per training
    const labelGroupId = await labelGroups.insertInto({
        organizationId: organizationId,
        labelGroupName: labelGroupName,
        isMultichoiceAllowed: isMultichoiceAllowed === "true",
        canUserDelete: canUserDelete === "true",
    });
    return labelGroupId;
}

module.exports.createLabel = createLabel;
async function createLabel (token, labelGroupId, color, labelName, labelDescription) {
    // also return how many bookings there are per training
    const labelId = await labels.insertInto({
        labelGroupId: labelGroupId,
        color: color,
        labelName: labelName,
        labelDescription: labelDescription,
    });
    return labelId;
}
module.exports.changeLabel = changeLabel;
async function changeLabel (token, labelId, color, labelName, labelDescription) {
    // also return how many bookings there are per training
    await labels.update(
    {
        labelId: labelId,
    },
    {
        color: color,
        labelName: labelName,
        labelDescription: labelDescription,
    });
}
module.exports.changeLabelGroup = changeLabelGroup;
async function changeLabelGroup (token,labelGroupId, labelGroupName, isMultichoiceAllowed) {
    // also return how many bookings there are per training
    await labelGroups.update(
    {
        labelGroupId: labelGroupId,
    },
    {
        labelGroupName: labelGroupName,
        isMultichoiceAllowed: isMultichoiceAllowed === "true",
    });
}
module.exports.removeLabel = removeLabel;
async function removeLabel (token, labelId) {
    // also return how many bookings there are per training
    await labels.deleteFrom({labelId: labelId});
}
module.exports.removeLabelGroup = removeLabelGroup;
async function removeLabelGroup (token,labelGroupId) {
    // also return how many bookings there are per training
    const lg = await labelGroups.select({labelGroupId: labelGroupId});
    if (lg[0].canUserDelete != null && Db.readBool(lg[0].canUserDelete)) {
        await labelGroups.deleteFrom({labelGroupId: labelGroupId});
    } else {
        throw {status: 403, message: "User cannot delete this label group. It belongs to the system."};
    }
}

async function expandLabel (selectedLabelIds) {
    // also return how many bookings there are per training
    try {
        let out = [];
        for (let i = 0; i < selectedLabelIds.selectedLabels.length; i++) {
            const label = await labels.select({labelId: selectedLabelIds.selectedLabels[i]});
            out.push(label[0]);
        }
        return out;
    } catch (e) {
        return [];
    }
}

module.exports.submitAuditPrivilege = submitAuditPrivilege;
async function  submitAuditPrivilege (token, auditTaskId, submitData) {
    const userId = (await Auth.getUserFromToken(token))[0].userId;
    const ap = await auditPrivileges.select({userId: userId, auditTaskId: auditTaskId});
    if (ap.length === 0) {
        throw {status: 403, message: "There exists no auditPrivileges for this user for this auditTask"};
    }
    await auditPrivileges.update(
        {userId: userId, auditTaskId: auditTaskId},
        {
            submitData: submitData,
            dateSubmitted: Db.getDatetime(),
        } 
    );
}

async function assertUserCanViewAuditTask(token, auditTaskId) {
    const ap = await getAuditPrivilegeForUserAndAuditTask(token, auditTaskId);
    if (ap.length === 0) {
        throw {status: 403, message: "user has insufficient privileges"};
    }
}

async function adminGetTasks(){
    const at = await auditTemplates.select(); // select all auditTemplates, and include relevant auditTasks for each auditTemplate.
    let pageObjCount = 0;
    let pageObjHistogram = {};
    for (let i = 0; i < at.length; i++) {
        const auditTemplateData = JSON.parse(decodeURI(at[i].auditTemplateData));
        if (auditTemplateData.pages !== undefined) {
            for (let j = 0; j < auditTemplateData.pages.length; j++) {
                const pageData = auditTemplateData.pages[j].data;
                for (let k = 0; k < pageData.children.length; k++) {
                    const pageDataChild = pageData.children[k];
                    const widgetType = pageDataChild.widgetType;
                    if (pageObjHistogram[widgetType] === undefined) {
                        pageObjHistogram[widgetType] = 0;
                    }
                    pageObjHistogram[widgetType]++;
                }
                pageObjCount += pageData.children.length;

            }
        }
    }
    const aq = await auditTaskQuestions.select(); // select all auditTemplates, and include relevant auditTasks for each auditTemplate.
    for (let i = 0; i < aq.length; i++) {
            if (i < 100) {
        if (aq[i].data!== undefined) {
            const auditQuestionData = JSON.parse(decodeURI(aq[i].data));

            //console.log(auditQuestionData)
        }
            }
    }
    //console.log(`pageObjCount ${pageObjCount}`);
    //console.log(`pageObjHistogram ${JSON.stringify(pageObjHistogram)}`);
}
adminGetTasks();