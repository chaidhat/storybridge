function generateToken () {
    let token = "";
    let possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
    for (let i = 0; i < 16; i++)
        token += possible.charAt(Math.floor(Math.random() * possible.length));
    return token;
}
module.exports.generateToken = generateToken;