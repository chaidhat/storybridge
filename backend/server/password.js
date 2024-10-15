const bcrypt = require("bcryptjs");
const sha256 = require('sha256');

const COST_FACTOR = 11;

module.exports.sha = function (password) {
    return sha256(password);
}

module.exports.hash = 
async password => {
    return await this.hashOldPass(sha256(password));
}

module.exports.cmp =
async (password, hash) => {
    return await bcrypt.compare(sha256(password), hash);
}

module.exports.hashOldPass =
async oldPassword => {
    return await bcrypt.hash(oldPassword, COST_FACTOR);
}