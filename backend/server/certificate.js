const Db = require('./database');

var certificateData = new Db.DatabaseTable("CertificateData",
    "certificateDataId",
    [
        {
        name: "courseId",
        type: "int"
        },
        {
        name: "data",
        type: "varchar(4095)"
        },
]);
certificateData.init();

module.exports.createCertificateData = createCertificateData;
async function createCertificateData(token, courseId, data) {
    // TODO: auth checks
    await certificateData.insertInto({
        courseId: courseId,
        data: data,
    });
}

module.exports.getCertificateData = getCertificateData;
async function getCertificateData(token, courseId) {
    // TODO: auth checks
    return await certificateData.select({courseId: courseId});
}

module.exports.updateCertificateData = updateCertificateData;
async function updateCertificateData(token, courseId, data) {
    // TODO: auth checks
    await certificateData.update({courseId: courseId}, {
        data: data
    });
}

module.exports.removeCertificateDataFromCourse = removeCertificateDataFromCourse;
async function removeCertificateDataFromCourse(courseId) {
    await certificateData.deleteFrom({courseId: courseId});
}