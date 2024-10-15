var assert = require('assert');

const Db = require('../database');
const Auth = require('../auth');
const testHelper = require('./helper');
const mocha = require ('mocha');


module.exports.runTests = runTests;
async function runTests() {
    describe('pol.auth', function () {
        describe('pol.auth.log', function () {
            it('control', async function () {
                assert.doesNotThrow(async () => {
                    await Auth.loginUser("TESTDEBUG", "password", 0);
                });
            });
            it('pol.auth.log.0', async function () {
                try {
                    await Auth.loginUser("OOPSDEBUG", "password", 0);
                } catch (err) {
                    var e = err;
                }
                assert.exists(e, "Expected exception but none thrown");
                assert.exists(e.status);
                assert.equal(e.status, 500);
                assert.equal(e.policy, "pol.auth.log.0");
            });
            it('pol.auth.log.1', async function () {
                try {
                    await Auth.loginUser("", "password", 0);
                } catch (err) {
                    var e = err;
                }
                assert.exists(e, "Expected exception but none thrown");
                assert.exists(e.status);
                assert.equal(e.status, 403);
                assert.equal(e.policy, "pol.auth.log.1");
            });
            it('pol.auth.log.2', async function () {
                try {
                    await Auth.loginUser("TESTDEBUG", "", 0);
                } catch (err) {
                    var e = err;
                }
                assert.exists(e, "Expected exception but none thrown");
                assert.exists(e.status);
                assert.equal(e.status, 403);
                assert.equal(e.policy, "pol.auth.log.2");
            });
            it('pol.auth.log.3', async function () {
                try {
                    await Auth.loginUser("NOUSEREXISTSDEBUG", "a", 0);
                } catch (err) {
                    var e = err;
                }
                assert.exists(e, "Expected exception but none thrown");
                assert.exists(e.status);
                assert.equal(e.status, 403);
                assert.equal(e.policy, "pol.auth.log.3");
            });
            it('pol.auth.log.4', async function () {
                try {
                    await Auth.loginUser("PASSWORDWRONGDEBUG", "a", 0);
                } catch (err) {
                    var e = err;
                }
                assert.exists(e, "Expected exception but none thrown");
                assert.exists(e.status);
                assert.equal(e.status, 403);
                assert.equal(e.policy, "pol.auth.log.4");
            });
            xit('pol.auth.log.5', async function () {
                // NOT YET IMPLEMENTED
            });
        });
        describe('pol.auth.reg', function () {
            it('control', async function () {
                assert.doesNotThrow(async () => {
                    await Auth.registerUser(
                        "TESTDEBUG",    // username
                        "aBCd_234",     // password
                        "test@debug.c", // email
                        "firstname",    // firstName
                        "lastname",     // lastName
                        0,              // organizationId
                    );
                });
            });
            it('pol.auth.reg.0', async function () {
                try {
                    await Auth.registerUser(
                        "OOPSDEBUG",    // username
                        "aBCd_234",     // password
                        "test@debug.c", // email
                        "firstname",    // firstName
                        "lastname",     // lastName
                        0,              // organizationId
                    );
                } catch (err) {
                    var e = err;
                }
                assert.exists(e, "Expected exception but none thrown");
                assert.exists(e.status);
                assert.equal(e.status, 500);
                assert.equal(e.policy, "pol.auth.reg.0");
            });
            it('pol.auth.reg.1', async function () {
                try {
                    await Auth.registerUser(
                        "TESTDEBUG",    // username
                        "aBCd_234",     // password
                        "test@debug.c", // email
                        "",             // firstName
                        "",             // lastName
                        0,              // organizationId
                    );
                } catch (err) {
                    var e = err;
                }
                assert.exists(e, "Expected exception but none thrown");
                assert.exists(e.status);
                assert.equal(e.status, 403);
                assert.equal(e.policy, "pol.auth.reg.1");
            });
            it('pol.auth.reg.2', async function () {
                try {
                    await Auth.registerUser(
                        "TESTDEBUG",    // username
                        "aBCd_234",     // password
                        "", // email
                        "firstname",    // firstName
                        "lastname",     // lastName
                        0,              // organizationId
                    );
                } catch (err) {
                    var e = err;
                }
                assert.exists(e, "Expected exception but none thrown");
                assert.exists(e.status);
                assert.equal(e.status, 403);
                assert.equal(e.policy, "pol.auth.reg.2");
            });
            it('pol.auth.reg.3', async function () {
                try {
                    await Auth.registerUser(
                        "TESTDEBUG",    // username
                        "",     // password
                        "test@debug.c", // email
                        "firstname",    // firstName
                        "lastname",     // lastName
                        0,              // organizationId
                    );
                } catch (err) {
                    var e = err;
                }
                assert.exists(e, "Expected exception but none thrown");
                assert.exists(e.status);
                assert.equal(e.status, 403);
                assert.equal(e.policy, "pol.auth.reg.3");
            });
            it('pol.auth.reg.4', async function () {
                try {
                    await Auth.registerUser(
                        "TESTDEBUG",    // username
                        "aBCd_234",     // password
                        "bademail", // email
                        "firstname",    // firstName
                        "lastname",     // lastName
                        0,              // organizationId
                    );
                } catch (err) {
                    var e = err;
                }
                assert.exists(e, "Expected exception but none thrown");
                assert.exists(e.status);
                assert.equal(e.status, 403);
                assert.equal(e.policy, "pol.auth.reg.4");
            });
            it('pol.auth.reg.5', async function () {
                try {
                    await Auth.registerUser(
                        "ALRDYEXISTSDEBUG",    // username
                        "aBCd_234",     // password
                        "test@debug.c", // email
                        "firstname",    // firstName
                        "lastname",     // lastName
                        0,              // organizationId
                    );
                } catch (err) {
                    var e = err;
                }
                assert.exists(e, "Expected exception but none thrown");
                assert.exists(e.status);
                assert.equal(e.status, 403);
                assert.equal(e.policy, "pol.auth.reg.5");
            });
            xit('pol.auth.reg.6', async function () {
                // DISABLED
                try {
                    await Auth.registerUser(
                        "TESTDEBUG",    // username
                        "shOrt_2",      // password
                        "test@debug.c", // email
                        "firstname",    // firstName
                        "lastname",     // lastName
                        0,              // organizationId
                    );
                } catch (err) {
                    var e = err;
                }
                assert.exists(e, "Expected exception but none thrown");
                assert.exists(e.status);
                assert.equal(e.status, 403);
                assert.equal(e.policy, "pol.auth.reg.6");
            });
            xit('pol.auth.reg.7', async function () {
                // DISABLED
                try {
                    await Auth.registerUser(
                        "TESTDEBUG",    // username
                        "nonumbers_",     // password
                        "test@debug.c", // email
                        "firstname",    // firstName
                        "lastname",     // lastName
                        0,              // organizationId
                    );
                } catch (err) {
                    var e = err;
                }
                assert.exists(e, "Expected exception but none thrown");
                assert.exists(e.status);
                assert.equal(e.status, 403);
                assert.equal(e.policy, "pol.auth.reg.7");
            });
            xit('pol.auth.reg.8', async function () {
                // DISABLED
                try {
                    await Auth.registerUser(
                        "TESTDEBUG",    // username
                        "12345678_",     // password
                        "test@debug.c", // email
                        "firstname",    // firstName
                        "lastname",     // lastName
                        0,              // organizationId
                    );
                } catch (err) {
                    var e = err;
                }
                assert.exists(e, "Expected exception but none thrown");
                assert.exists(e.status);
                assert.equal(e.status, 403);
                assert.equal(e.policy, "pol.auth.reg.8");
            });
            it('pol.auth.reg.9', async function () {
                try {
                    await Auth.registerUser(
                        "TESTDEBUG",    // username
                        "aBCd_234",     // password
                        "test@debug.c", // email
                        "nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn",    // firstName
                        "lastname",     // lastName
                        0,              // organizationId
                    );
                } catch (err) {
                    var e = err;
                }
                assert.exists(e, "Expected exception but none thrown");
                assert.exists(e.status);
                assert.equal(e.status, 403);
                assert.equal(e.policy, "pol.auth.reg.9");
            });
            it('pol.auth.reg.10', async function () {
                try {
                    await Auth.registerUser(
                        "TESTDEBUG",    // username
                        "aBCd_234",     // password
                        "nnn@n.nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn",    // email
                        "firstname",    // firstName
                        "lastname",     // lastName
                        0,              // organizationId
                    );
                } catch (err) {
                    var e = err;
                }
                assert.exists(e, "Expected exception but none thrown");
                assert.exists(e.status);
                assert.equal(e.status, 403);
                assert.equal(e.policy, "pol.auth.reg.10");
            });
        });
    });
}