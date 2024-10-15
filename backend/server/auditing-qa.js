const Db = require('./database');

const auditTextQuestions = new Db.DatabaseTable("AuditTextQuestions",
    "auditTextQuestionId",
    [
        {
        name: "quid",
        type: "int"
        },
        {
        name: "auditTemplateId",
        type: "int"
        },
        {
        name: "question",
        type: "varchar(1024)"
        },
        {
        name: "isLargeField",
        type: "bit"
        },
        {
        name: "isNumericalField",
        type: "bit"
        },
        {
        name: "validiationRegex",
        type: "varchar(256)"
        },
        {
        name: "answerHint",
        type: "varchar(256)"
        },
]);
auditTextQuestions.init();

const auditMultichoiceQuestions = new Db.DatabaseTable("AuditMultichoiceQuestions",
    "auditMultichoiceQuestionId",
    [
        {
        name: "quid",
        type: "int"
        },
        {
        name: "auditTemplateId",
        type: "int"
        },
        {
        name: "question",
        type: "varchar(256)"
        },
        {
        name: "dateSourceType",
        type: "varchar(256)"
        },
        {
        name: "labelGroupId",
        type: "int"
        },
        {
        name: "unlinkedAnswers",
        type: "varchar(256)"
        },
        {
        name: "unlinkedCanSelectMultiple",
        type: "bit"
        },
        {
        name: "hasOtherField",
        type: "bit"
        },
]);
auditMultichoiceQuestions.init();
const auditMultichoiceQuestionsUnlinkedAnswer = new Db.DatabaseTable("AuditMultichoiceQuestionsUnlinkedAnswer",
    "auditMultichoiceQuestionsUnlinkedAnswerId",
    [
        {
        name: "auditMultichoiceQuestionId",
        type: "int"
        },
        {
        name: "unlinkedAnswer",
        type: "varchar(1024)"
        },
]);
auditMultichoiceQuestionsUnlinkedAnswer.init();

const auditDatetimeQuestions = new Db.DatabaseTable("AuditDatetimeQuestions",
    "auditDatetimeQuestionId",
    [
        {
        name: "quid",
        type: "int"
        },
        {
        name: "auditTemplateId",
        type: "int"
        },
        {
        name: "question",
        type: "varchar(256)"
        },
        {
        name: "datetimeMode",
        type: "varchar(256)"
        },
        {
        name: "autofillMode",
        type: "varchar(256)"
        },
]);
auditDatetimeQuestions.init();

const auditFileuploadQuestions = new Db.DatabaseTable("AuditFileuploadQuestions",
    "auditFileuploadQuestionId",
    [
        {
        name: "quid",
        type: "int"
        },
        {
        name: "auditTemplateId",
        type: "int"
        },
        {
        name: "question",
        type: "varchar(256)"
        },
        {
        name: "fileExtensions",
        type: "varchar(256)"
        },
        {
        name: "allowMultipleFiles",
        type: "bit"
        },
]);
auditFileuploadQuestions.init();

const auditTextAnswers = new Db.DatabaseTable("AuditTextAnswers",
    "auditTextAnswerId",
    [
        {
        name: "quid",
        type: "int"
        },
        {
        name: "auditTaskId",
        type: "int"
        },
        {
        name: "answer",
        type: "varchar(1024)"
        },
        {
        name: "answerNumber",
        type: "double"
        },
]);
auditTextAnswers.init();

const auditMultichoiceAnswers = new Db.DatabaseTable("AuditMultichoiceAnswers",
    "auditMultichoiceAnswerId",
    [
        {
        name: "quid",
        type: "int"
        },
        {
        name: "auditTaskId",
        type: "int"
        },
        {
        name: "selectedOtherField",
        type: "bit"
        },
        {
        name: "otherField",
        type: "varchar(1024)"
        },
        {
        name: "answers",
        type: "AuditMultichoiceAnswersChoice[]"
        },
]);
auditMultichoiceAnswers.init();

const auditMultichoiceAnswersChoice = new Db.DatabaseTable("AuditMultichoiceAnswersChoice",
    "auditMultichoiceAnswersChoiceId",
    [
        {
        name: "auditMultichoiceAnswerId",
        type: "int"
        },
        {
        name: "labelGroupId",
        type: "int"
        },
        {
        name: "userId",
        type: "bit"
        },
        {
        name: "auditMultichoiceQuestionsUnlinkedAnswerId",
        type: "int"
        },
]);
auditMultichoiceAnswersChoice.init();

const auditDatetimeAnswers = new Db.DatabaseTable("AuditDatetimeAnswers",
    "auditDatetimeAnswerId",
    [
        {
        name: "quid",
        type: "int"
        },
        {
        name: "auditTaskId",
        type: "int"
        },
        {
        name: "datetime",
        type: "datetime"
        },
]);
auditDatetimeAnswers.init();

const auditFileuploadAnswers = new Db.DatabaseTable("AuditFileuploadAnswers",
    "auditFileuploadAnswerId",
    [
        {
        name: "quid",
        type: "int"
        },
        {
        name: "auditTaskId",
        type: "int"
        },
        {
        name: "files",
        type: "AuditFileuploadAnswersFiles[]"
        },
]);
auditFileuploadAnswers.init();

const auditFileuploadAnswersFiles = new Db.DatabaseTable("AuditFileuploadAnswersFiles",
    "auditFileuploadAnswersFileId",
    [
        {
        name: "auditFileuploadAnswerId",
        type: "int"
        },
        {
        name: "imageId",
        type: "int"
        },
        {
        name: "filename",
        type: "varchar(1024)"
        },
]);
auditFileuploadAnswersFiles.init();

// get
module.exports.getAuditTextQuestions = getAuditTextQuestions;
async function getAuditTextQuestions (token, auditTextQuestionId) {
    //TODO: auth
    const data = await auditTextQuestions.select({auditTextQuestionId});
    return data;
}

// create
module.exports.createAuditTextQuestions = createAuditTextQuestions;
async function createAuditTextQuestions (
    token,
    quid,
    auditTemplateId,
    question,
    isLargeField,
    isNumericalField,
    validiationRegex,
    answerHint
) {
    //TODO: auth
    // create
    const auditTextQuestionId = await auditTextQuestions.insertInto({
        quid: quid,
        auditTemplateId: auditTemplateId,
        question: question,
        isLargeField: isLargeField,
        isNumericalField: isNumericalField,
        validiationRegex: validiationRegex,
        answerHint: answerHint
    });
    return auditTextQuestionId;
}

// change
module.exports.changeAuditTextQuestions = changeAuditTextQuestions;
async function changeAuditTextQuestions (
    token,
    auditTextQuestionId,
    quid,
    auditTemplateId,
    question,
    isLargeField,
    isNumericalField,
    validiationRegex,
    answerHint
) {
    //TODO: auth
    // change
    await auditTextQuestions.update(
        {
            auditTextQuestionId: auditTextQuestionId,
        },
        {
            quid: quid,
            auditTemplateId: auditTemplateId,
            question: question,
            isLargeField: isLargeField,
            isNumericalField: isNumericalField,
            validiationRegex: validiationRegex,
            answerHint: answerHint
        }
    );
}

// remove
module.exports.removeAuditTextQuestions = removeAuditTextQuestions;
async function removeAuditTextQuestions (token, auditTextQuestionId) {
    await auditTextQuestions.deleteFrom(
        {
            auditTextQuestionId: auditTextQuestionId,
        }
    );
}

// get
module.exports.getAuditMultichoiceQuestions = getAuditMultichoiceQuestions;
async function getAuditMultichoiceQuestions (token, auditMultichoiceQuestionId) {
    //TODO: auth
    const data = await auditMultichoiceQuestions.select({auditMultichoiceQuestionId});
    return data;
}

// create
module.exports.createAuditMultichoiceQuestions = createAuditMultichoiceQuestions;
async function createAuditMultichoiceQuestions (
    token,
    quid,
    auditTemplateId,
    question,
    dateSourceType,
    labelGroupId,
    unlinkedAnswers,
    unlinkedCanSelectMultiple,
    hasOtherField
) {
    //TODO: auth
    // create
    const auditMultichoiceQuestionId = await auditMultichoiceQuestions.insertInto({
        quid: quid,
        auditTemplateId: auditTemplateId,
        question: question,
        dateSourceType: dateSourceType,
        labelGroupId: labelGroupId,
        unlinkedAnswers: unlinkedAnswers,
        unlinkedCanSelectMultiple: unlinkedCanSelectMultiple,
        hasOtherField: hasOtherField
    });
    return auditMultichoiceQuestionId;
}

// change
module.exports.changeAuditMultichoiceQuestions = changeAuditMultichoiceQuestions;
async function changeAuditMultichoiceQuestions (
    token,
    auditMultichoiceQuestionId,
    quid,
    auditTemplateId,
    question,
    dateSourceType,
    labelGroupId,
    unlinkedAnswers,
    unlinkedCanSelectMultiple,
    hasOtherField
) {
    //TODO: auth
    // change
    await auditMultichoiceQuestions.update(
        {
            auditMultichoiceQuestionId: auditMultichoiceQuestionId,
        },
        {
            quid: quid,
            auditTemplateId: auditTemplateId,
            question: question,
            dateSourceType: dateSourceType,
            labelGroupId: labelGroupId,
            unlinkedAnswers: unlinkedAnswers,
            unlinkedCanSelectMultiple: unlinkedCanSelectMultiple,
            hasOtherField: hasOtherField
        }
    );
}

// remove
module.exports.removeAuditMultichoiceQuestions = removeAuditMultichoiceQuestions;
async function removeAuditMultichoiceQuestions (token, auditMultichoiceQuestionId) {
    await auditMultichoiceQuestions.deleteFrom(
        {
            auditMultichoiceQuestionId: auditMultichoiceQuestionId,
        }
    );
}

// get
module.exports.getAuditDatetimeQuestions = getAuditDatetimeQuestions;
async function getAuditDatetimeQuestions (token, auditDatetimeQuestionId) {
    //TODO: auth
    const data = await auditDatetimeQuestions.select({auditDatetimeQuestionId});
    return data;
}

// create
module.exports.createAuditDatetimeQuestions = createAuditDatetimeQuestions;
async function createAuditDatetimeQuestions (
    token,
    quid,
    auditTemplateId,
    question,
    datetimeMode,
    autofillMode
) {
    //TODO: auth
    // create
    const auditDatetimeQuestionId = await auditDatetimeQuestions.insertInto({
        quid: quid,
        auditTemplateId: auditTemplateId,
        question: question,
        datetimeMode: datetimeMode,
        autofillMode: autofillMode
    });
    return auditDatetimeQuestionId;
}

// change
module.exports.changeAuditDatetimeQuestions = changeAuditDatetimeQuestions;
async function changeAuditDatetimeQuestions (
    token,
    auditDatetimeQuestionId,
    quid,
    auditTemplateId,
    question,
    datetimeMode,
    autofillMode
) {
    //TODO: auth
    // change
    await auditDatetimeQuestions.update(
        {
            auditDatetimeQuestionId: auditDatetimeQuestionId,
        },
        {
            quid: quid,
            auditTemplateId: auditTemplateId,
            question: question,
            datetimeMode: datetimeMode,
            autofillMode: autofillMode
        }
    );
}

// remove
module.exports.removeAuditDatetimeQuestions = removeAuditDatetimeQuestions;
async function removeAuditDatetimeQuestions (token, auditDatetimeQuestionId) {
    await auditDatetimeQuestions.deleteFrom(
        {
            auditDatetimeQuestionId: auditDatetimeQuestionId,
        }
    );
}

// get
module.exports.getAuditFileuploadQuestions = getAuditFileuploadQuestions;
async function getAuditFileuploadQuestions (token, auditFileuploadQuestionId) {
    //TODO: auth
    const data = await auditFileuploadQuestions.select({auditFileuploadQuestionId});
    return data;
}

// create
module.exports.createAuditFileuploadQuestions = createAuditFileuploadQuestions;
async function createAuditFileuploadQuestions (
    token,
    quid,
    auditTemplateId,
    question,
    fileExtensions,
    allowMultipleFiles
) {
    //TODO: auth
    // create
    const auditFileuploadQuestionId = await auditFileuploadQuestions.insertInto({
        quid: quid,
        auditTemplateId: auditTemplateId,
        question: question,
        fileExtensions: fileExtensions,
        allowMultipleFiles: allowMultipleFiles
    });
    return auditFileuploadQuestionId;
}

// change
module.exports.changeAuditFileuploadQuestions = changeAuditFileuploadQuestions;
async function changeAuditFileuploadQuestions (
    token,
    auditFileuploadQuestionId,
    quid,
    auditTemplateId,
    question,
    fileExtensions,
    allowMultipleFiles
) {
    //TODO: auth
    // change
    await auditFileuploadQuestions.update(
        {
            auditFileuploadQuestionId: auditFileuploadQuestionId,
        },
        {
            quid: quid,
            auditTemplateId: auditTemplateId,
            question: question,
            fileExtensions: fileExtensions,
            allowMultipleFiles: allowMultipleFiles
        }
    );
}

// remove
module.exports.removeAuditFileuploadQuestions = removeAuditFileuploadQuestions;
async function removeAuditFileuploadQuestions (token, auditFileuploadQuestionId) {
    await auditFileuploadQuestions.deleteFrom(
        {
            auditFileuploadQuestionId: auditFileuploadQuestionId,
        }
    );
}

// get
module.exports.getAuditTextAnswers = getAuditTextAnswers;
async function getAuditTextAnswers (token, auditTextAnswerId) {
    //TODO: auth
    const data = await undefined.select({auditTextAnswerId});
    return data;
}

// create
module.exports.createAuditTextAnswers = createAuditTextAnswers;
async function createAuditTextAnswers (
    token,
    quid,
auditTaskId,
answer,
answerNumber
) {
    //TODO: auth
    // create
    const auditTextAnswerId = await undefined.insertInto({
        quid: quid,
auditTaskId: auditTaskId,
answer: answer,
answerNumber: answerNumber
    });
    return auditTextAnswerId;
}

// change
module.exports.changeAuditTextAnswers = changeAuditTextAnswers;
async function changeAuditTextAnswers (
    token,
    auditTextAnswerId,
    quid,
auditTaskId,
answer,
answerNumber
) {
    //TODO: auth
    // change
    await undefined.update(
        {
            auditTextAnswerId: auditTextAnswerId,
        },
        {
            quid: quid,
auditTaskId: auditTaskId,
answer: answer,
answerNumber: answerNumber
        }
    );
}

// remove
module.exports.removeAuditTextAnswers = removeAuditTextAnswers;
async function removeAuditTextAnswers (token, auditTextAnswerId) {
    await undefined.deleteFrom(
        {
            auditTextAnswerId: auditTextAnswerId,
        }
    );
}

// get
module.exports.getAuditMultichoiceAnswers = getAuditMultichoiceAnswers;
async function getAuditMultichoiceAnswers (token, auditMultichoiceAnswerId) {
    //TODO: auth
    const data = await undefined.select({auditMultichoiceAnswerId});
    return data;
}

// create
module.exports.createAuditMultichoiceAnswers = createAuditMultichoiceAnswers;
async function createAuditMultichoiceAnswers (
    token,
    quid,
auditTaskId,
selectedOtherField,
otherField
) {
    //TODO: auth
    // create
    const auditMultichoiceAnswerId = await undefined.insertInto({
        quid: quid,
auditTaskId: auditTaskId,
selectedOtherField: selectedOtherField,
otherField: otherField
    });
    return auditMultichoiceAnswerId;
}

// change
module.exports.changeAuditMultichoiceAnswers = changeAuditMultichoiceAnswers;
async function changeAuditMultichoiceAnswers (
    token,
    auditMultichoiceAnswerId,
    quid,
auditTaskId,
selectedOtherField,
otherField
) {
    //TODO: auth
    // change
    await undefined.update(
        {
            auditMultichoiceAnswerId: auditMultichoiceAnswerId,
        },
        {
            quid: quid,
auditTaskId: auditTaskId,
selectedOtherField: selectedOtherField,
otherField: otherField
        }
    );
}

// remove
module.exports.removeAuditMultichoiceAnswers = removeAuditMultichoiceAnswers;
async function removeAuditMultichoiceAnswers (token, auditMultichoiceAnswerId) {
    await undefined.deleteFrom(
        {
            auditMultichoiceAnswerId: auditMultichoiceAnswerId,
        }
    );
}

// get
module.exports.getAuditDatetimeAnswers = getAuditDatetimeAnswers;
async function getAuditDatetimeAnswers (token, auditDatetimeAnswerId) {
    //TODO: auth
    const data = await undefined.select({auditDatetimeAnswerId});
    return data;
}

// create
module.exports.createAuditDatetimeAnswers = createAuditDatetimeAnswers;
async function createAuditDatetimeAnswers (
    token,
    quid, 
auditTaskId,
datetime
) {
    //TODO: auth
    // create
    const auditDatetimeAnswerId = await undefined.insertInto({
        quid: quid,
auditTaskId: auditTaskId,
datetime: datetime
    });
    return auditDatetimeAnswerId;
}

// change
module.exports.changeAuditDatetimeAnswers = changeAuditDatetimeAnswers;
async function changeAuditDatetimeAnswers (
    token,
    auditDatetimeAnswerId,
    quid,
auditTaskId,
datetime
) {
    //TODO: auth
    // change
    await undefined.update(
        {
            auditDatetimeAnswerId: auditDatetimeAnswerId,
        },
        {
            quid: quid,
auditTaskId: auditTaskId,
datetime: datetime
        }
    );
}

// remove
module.exports.removeAuditDatetimeAnswers = removeAuditDatetimeAnswers;
async function removeAuditDatetimeAnswers (token, auditDatetimeAnswerId) {
    await undefined.deleteFrom(
        {
            auditDatetimeAnswerId: auditDatetimeAnswerId,
        }
    );
}

// get
module.exports.getAuditFileuploadAnswers = getAuditFileuploadAnswers;
async function getAuditFileuploadAnswers (token, auditFileuploadAnswerId) {
    //TODO: auth
    const data = await undefined.select({auditFileuploadAnswerId});
    return data;
}

// create
module.exports.createAuditFileuploadAnswers = createAuditFileuploadAnswers;
async function createAuditFileuploadAnswers (
    token,
    quid,
auditTaskId
) {
    //TODO: auth
    // create
    const auditFileuploadAnswerId = await undefined.insertInto({
        quid: quid,
auditTaskId: auditTaskId
    });
    return auditFileuploadAnswerId;
}

// change
module.exports.changeAuditFileuploadAnswers = changeAuditFileuploadAnswers;
async function changeAuditFileuploadAnswers (
    token,
    auditFileuploadAnswerId,
    quid,
auditTaskId
) {
    //TODO: auth
    // change
    await undefined.update(
        {
            auditFileuploadAnswerId: auditFileuploadAnswerId,
        },
        {
            quid: quid,
auditTaskId: auditTaskId
        }
    );
}

// remove
module.exports.removeAuditFileuploadAnswers = removeAuditFileuploadAnswers;
async function removeAuditFileuploadAnswers (token, auditFileuploadAnswerId) {
    await undefined.deleteFrom(
        {
            auditFileuploadAnswerId: auditFileuploadAnswerId,
        }
    );
}