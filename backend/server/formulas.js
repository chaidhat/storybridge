const Auditing = require('./auditing');

const TYPE_STRING = "string";
const TYPE_NUMBER = "number";
const TYPE_OBJ = "object";
const TYPE_BOOL = "boolean";

const SCHOLS_FUNCTIONS = [
    {
        functionName: "evaluate",
        argumentTypes: [TYPE_STRING, TYPE_NUMBER],
        f: async ([quid, auditTaskId]) => {
            let data = await Auditing.getAuditTaskQuestion(quid, auditTaskId);
            if (data.length === 0) {
                return null;
            }
            data = JSON.parse(decodeURI(data[0].data));
            return {
                valueType: TYPE_OBJ,
                value: data,
            };
        },
    },
    {
        // gets the name of the owner of the audit
        functionName: "getAuditPrivileges",
        argumentTypes: [TYPE_NUMBER],
        f: async ([quid, auditTaskId]) => {
            let data = await Auditing.getAuditTaskQuestion(quid, auditTaskId);
            if (data.length === 0) {
                return null;
            }
            data = JSON.parse(decodeURI(data[0].data));
            return {
                valueType: TYPE_OBJ,
                value: data,
            };
        },
    },
    {
        functionName: "dot",
        argumentTypes: [TYPE_OBJ, TYPE_STRING],
        f: ([obj, key]) => {
            let data = obj[key];
            if (data === undefined) {
                return null;
            }
            return {
                valueType: typeof data,
                value: data,
            };
        },
    },
    {
        functionName: "is",
        argumentTypes: [TYPE_NUMBER, TYPE_NUMBER],
        f: ([a, b]) => {
            return {
                valueType: TYPE_BOOL,
                value: a === b,
            };
        },
    },
    {
        functionName: "is",
        argumentTypes: [TYPE_STRING, TYPE_STRING],

        f: ([a, b]) => {
            return {
                valueType: TYPE_BOOL,
                value: a === b,
            };
        },
    },
    {
        functionName: "is",
        argumentTypes: [TYPE_BOOL, TYPE_BOOL],

        f: ([a, b]) => {
            return {
                valueType: TYPE_BOOL,
                value: a === b,
            };
        },
    },
    {
        functionName: "isExactly",
        argumentTypes: [TYPE_OBJ, TYPE_OBJ],

        f: ([a, b]) => {
            for (var i = 0; i < Math.max(a.length, b.length); i++) {
                let x, y;
                if (i < a.length) {
                    x = a[i];
                } else {
                    x = false;
                }
                if (i < b.length) {
                    y = b[i];
                } else {
                    y = false;
                }

                if (x != y) {
                    return {
                        valueType: TYPE_BOOL,
                        value: false,
                    };
                }
            }
            return {
                valueType: TYPE_BOOL,
                value: true,
            };
        },
    },
    {
        functionName: "includes",
        argumentTypes: [TYPE_STRING, TYPE_STRING],

        f: ([a, b]) => {
            return {
                valueType: TYPE_BOOL,
                value: a.includes(b),
            };
        },
    },
    {
        functionName: "contains",
        argumentTypes: [TYPE_OBJ, TYPE_OBJ],

        f: ([a, b]) => {
            for (var i = 0; i < Math.max(a.length, b.length); i++) {
                let x, y;
                if (i < a.length) {
                    x = a[i];
                } else {
                    x = false;
                }
                if (i < b.length) {
                    y = b[i];
                } else {
                    y = false;
                }

                if (y && !x) {
                    return {
                        valueType: TYPE_BOOL,
                        value: false,
                    };
                }
            }
            return {
                valueType: TYPE_BOOL,
                value: true,
            };
        },
    },
    {
        functionName: "startsWith",
        argumentTypes: [TYPE_STRING, TYPE_STRING],

        f: ([a, b]) => {
            return {
                valueType: TYPE_BOOL,
                value: a.startsWith(b),
            };
        },
    },
    {
        functionName: "endsWith",
        argumentTypes: [TYPE_STRING, TYPE_STRING],

        f: ([a, b]) => {
            return {
                valueType: TYPE_BOOL,
                value: a.endsWith(b),
            };
        },
    },
    {
        functionName: "length",
        argumentTypes: [TYPE_STRING],

        f: ([a]) => {
            return {
                valueType: TYPE_NUMBER,
                value: a.length,
            };
        },
    },
    {
        functionName: "isGreaterThan",
        argumentTypes: [TYPE_NUMBER, TYPE_NUMBER],

        f: ([a, b]) => {
            return {
                valueType: TYPE_BOOL,
                value: a > b,
            };
        },
    },
    {
        functionName: "isLessThan",
        argumentTypes: [TYPE_NUMBER, TYPE_NUMBER],

        f: ([a, b]) => {
            return {
                valueType: TYPE_BOOL,
                value: a < b,
            };
        },
    },
    {
        functionName: "isGreaterOrEqualTo",
        argumentTypes: [TYPE_NUMBER, TYPE_NUMBER],

        f: ([a, b]) => {
            return {
                valueType: TYPE_BOOL,
                value: a >= b,
            };
        },
    },
    {
        functionName: "isLessThanOrEqualTo",
        argumentTypes: [TYPE_NUMBER, TYPE_NUMBER],

        f: ([a, b]) => {
            return {
                valueType: TYPE_BOOL,
                value: a <= b,
            };
        },
    },
    {
        functionName: "isEmpty",
        argumentTypes: [TYPE_STRING],

        f: ([a]) => {
            return {
                valueType: TYPE_BOOL,
                value: false,
            };
        },
    },
    {
        functionName: "isEmpty",
        argumentTypes: [TYPE_NUMBER],

        f: ([a]) => {
            return {
                valueType: TYPE_BOOL,
                value: false,
            };
        },
    },
    {
        functionName: "isEmpty",
        argumentTypes: [TYPE_OBJ],

        f: ([a]) => {
            if (a === null) {
                return {
                    valueType: TYPE_BOOL,
                    value: true,
                };
            }
            return {
                valueType: TYPE_BOOL,
                value: false,
            };
        },
    },
    {
        functionName: "isEmpty",
        argumentTypes: [TYPE_BOOL],

        f: ([a]) => {
            return {
                valueType: TYPE_BOOL,
                value: false,
            };
        },
    },
    {
        functionName: "not",
        argumentTypes: [TYPE_BOOL],

        f: ([a]) => {
            return {
                valueType: TYPE_BOOL,
                value: !a,
            };
        },
    },
    {
        functionName: "and",
        argumentTypes: [TYPE_BOOL, TYPE_BOOL],

        f: ([a, b]) => {
            return {
                valueType: TYPE_BOOL,
                value: a && b,
            };
        },
    },
    {
        functionName: "or",
        argumentTypes: [TYPE_BOOL, TYPE_BOOL],

        f: ([a, b]) => {
            return {
                valueType: TYPE_BOOL,
                value: a || b,
            };
        },
    },
];

function parseFormula(formula) {
    let val = "";
    let arguments = [];
    let isThisAFunction = false;
    let stringMode = false;
    for (let i = 0; i < formula.length; i++) {
        // this is for strings
        if (formula[i] === '"' || formula[i] === "[" || formula[i] === "]") {
            stringMode = !stringMode;
            val = val + formula[i];
            continue;
        }
        if (stringMode) {
            val = val + formula[i];
            continue;
        }
        // if it encounters a starting bracket, then it assumes that function parameters have started
        if (formula[i] === "(") {
            do {
                i++;
                isThisAFunction = true;
                const inner = parseFormula(formula.substring(i));
                i += inner.index;
                arguments.push(inner.returnValue);
            } while (formula[i] === ",");
            if (formula[i] !== ")") {
                throw {
                    status: 403,
                    message: `expected closing bracket in formula at character #${i}`,
                };
            }
        }

        // if it encounters a comma or closing bracket, then it assumes that function parameters have started
        if (formula[i] === "," || formula[i] === ")") {
            // this is a literal
            if (isThisAFunction) {
                // this is a function
                return {
                    index: i + 1,
                    returnValue: {
                        type: "function",
                        functionName: val,
                        arguments: arguments,
                    },
                };
            } else {
                // this is a literal
                let valueType = "";
                try {
                    val = JSON.parse(val);
                    valueType = typeof val;
                } catch (_) {
                    throw {
                        status: 403,
                        message: `unknown literal type ${val}`,
                    };
                }

                return {
                    index: i,
                    returnValue: {
                        type: "literal",
                        value: val,
                        valueType: valueType,
                    },
                };
            }
            continue;
        }

        // if it's not anything special
        val = val + formula[i];
    }
    // check that all strings and brackets are closed
    if (stringMode) {
        throw { status: 403, message: `unclosed string or bracket in formula` };
    }
}
// doesn't fully check the formula, but it's a required step.
function preParseFormula(formula) {
    let depth = 0;
    for (let i = 0; i < formula.length; i++) {
        switch (formula[i]) {
            case ",":
            case '"':
            case "[":
            case "]":
                if (depth === 0) {
                    throw {
                        status: 403,
                        message: `unexpected '${formula[i]}' in formula at character #${i}`,
                    };
                }
                break;
            case "(":
                depth++;
                break;
            case ")":
                depth--;
                if (depth < 0) {
                    throw {
                        status: 403,
                        message: `unexpected closing bracket at character #${i}`,
                    };
                }
                if (depth === 0 && i !== formula.length - 1) {
                    throw {
                        status: 403,
                        message: `expected EOL in formula at character #${i}`,
                    };
                }
                break;
        }
    }
    if (depth !== 0) {
        throw { status: 403, message: `unmatched brackets in formula` };
    }
}

module.exports.verifyFormula = verifyFormula;
async function verifyFormula(formula) {
    try {
        preParseFormula(formula);
        const d = parseFormula(formula);
        if (d === undefined) {
            throw { status: 403, message: `formula is malformed.` };
        }
        return d.returnValue;
        // don't evaluate.
    } catch (e) {
        throw e;
    }
}
module.exports.executeFormula = executeFormula;
async function executeFormula(formula) {
    try {
        const d = await verifyFormula(formula);
        return await evaluateFormula(d);
    } catch (e) {
        throw e;
    }
}

async function evaluateFormula(formula) {
    switch (formula.type) {
        case "function":
            return await handleFunction(
                formula.functionName,
                formula.arguments,
            );
        case "literal":
            return await handleLiteral(formula.value, formula.valueType);
    }
}

async function handleFunction(functionName, arguments) {
    let parameters = [];
    let parameterTypes = [];
    for (let i = 0; i < arguments.length; i++) {
        const input = await evaluateFormula(arguments[i]);
        parameters.push(input.value);
        parameterTypes.push(input.valueType);
    }
    // find the right function
    var lambda = null;
    for (let i = 0; i < SCHOLS_FUNCTIONS.length; i++) {
        if (SCHOLS_FUNCTIONS[i].functionName === functionName) {
            let pass = true;
            if (
                SCHOLS_FUNCTIONS[i].argumentTypes.length ===
                parameterTypes.length
            ) {
                let pass = true;
                for (
                    let j = 0;
                    j < SCHOLS_FUNCTIONS[i].argumentTypes.length;
                    j++
                ) {
                    if (
                        SCHOLS_FUNCTIONS[i].argumentTypes[j] !==
                        parameterTypes[j]
                    ) {
                        pass = false;
                    }
                }
                if (pass) {
                    // found it!
                    lambda = SCHOLS_FUNCTIONS[i].f;
                    break;
                }
            }
        }
    }
    if (lambda === null) {
        throw {
            status: 403,
            message: `unknown function ${functionName}(${parameterTypes.join(", ")})`,
        };
    }
    return await lambda(parameters);
}

async function handleLiteral(value, valueType) {
    return { value: value, valueType: valueType };
}

async function assert(evaluation, expectedValue) {
    const d = await executeFormula(evaluation);
    if (d.value !== expectedValue) {
        throw `assertion failed!
        formula:\t${evaluation}
        expected:\t${expectedValue}
        got:\t\t${d.value}`;
    }
    console.log(`assertion passed:\t\t${evaluation}`);
}

module.exports.findAllPossibleFuncsForValue = findAllPossibleFuncsForValue;
async function findAllPossibleFuncsForValue(valueType) {
    let input = [];
    for (let i = 0; i < SCHOLS_FUNCTIONS.length; i++) {
        if (SCHOLS_FUNCTIONS[i].argumentTypes[0] === valueType) {
            let func = {
                functionName: SCHOLS_FUNCTIONS[i].functionName,
                argumentTypes: SCHOLS_FUNCTIONS[i].argumentTypes,
            };
            input.push(func);
        }
    }
    return input;
}

async function a() {
    //const d = await parseFormula("ev(aa(qqqqq,e),b)");
    /*const d = await executeFormula(
        'ev(pratt(as(124,true),ql("true",[true, false])),whitney("a"),"doc")',
    );*/
    try {
        // tests
        /*
        //
        await assert("is(true,false)", false);
        await assert("is(1,1)", true);
        await assert('is("abc","xyz")', false);
        await assert('is("abc","abc")', true);
        */
        /*
        await assert('includes("a", "b")', false);
        await assert('includes("aba", "b")', true);
        */
       /*
        await assert('startsWith("aba", "ba")', false);
        await assert('startsWith("aba", "ab")', true);
        await assert('endsWith("abaco", "co")', true);
        await assert('endsWith("abaco", "de")', false);
        await assert('length("abaco")', 5);
        await assert("isGreaterThan(5,3)", true);
        await assert("isGreaterThan(5,5)", false);
        await assert("isLessThan(3,5)", true);
        await assert("isLessThan(3,3)", false);
        await assert("isGreaterOrEqualTo(4,5)", false);
        await assert("isGreaterOrEqualTo(5,5)", true);
        await assert("isGreaterOrEqualTo(6,5)", true);
        await assert("isLessThanOrEqualTo(6,5)", false);
        await assert("isLessThanOrEqualTo(5,5)", true);
        await assert("isLessThanOrEqualTo(4,5)", true);
        await assert("isEmpty(4)", false);
        await assert("isEmpty(null)", true);
        await assert("not(true)", false);
        await assert("not(false)", true);
        await assert("or(true, false)", true);
        await assert("or(false, false)", false);
        await assert("and(true, true)", true);
        await assert("and(is(true,true),false)", false);

        const d = await executeFormula('evaluate("5831814",4)');
        console.log(JSON.stringify(d, null, 3));

        //const g = await findAllPossibleFuncsForValue("null");
        console.log("assertion tests ok");
        //console.log(g);
        */
    } catch (e) {
        console.log(e);
    }
}
a();
//parseFormula("ev(a(b),q)")
//parseFormula("ev(pratt(as(a,b),ql(q,e)),whitney(a),doc)")