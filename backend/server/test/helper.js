module.exports.randomStr = randomStr;
function randomStr() {
    const length = 8;
    let result = '';
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const charactersLength = characters.length;
    let counter = 0;
    while (counter < length) {
      result += characters.charAt(Math.floor(Math.random() * charactersLength));
      counter += 1;
    }
    return result;
}

module.exports.randomInt = randomInt;
function randomInt(minInt = -2147483648, maxInt = 2147483647) {
    return Math.floor((Math.random() * (maxInt - minInt)) + minInt);
}