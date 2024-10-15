/*
example of input for comparison
*/

import 'dart:math';
import 'package:mooc/services/auditing_service.dart' as auditing_service;

Map<String, dynamic> EXAMPLE_COMPARISON = {
  "comparisonTokenType": "function",
  "name": "and",
  "arguments": [
    {
      "comparisonTokenType": "function",
      "name": "is not",
      "arguments": [
        {
          "comparisonTokenType": "identifier",
          "quid": "123",
          "auditTemplateId": 123,
          "type": "answerText"
        },
        {
          "comparisonTokenType": "literal",
          "value": "abc",
          "type": "answerText"
        },
      ]
    },
    {
      "comparisonTokenType": "function",
      "name": "is",
      "arguments": [
        {
          "comparisonTokenType": "identifier",
          "quid": "123",
          "auditTemplateId": 123,
          "type": "answerText"
        },
        {
          "comparisonTokenType": "literal",
          "value": "def",
          "type": "answerText",
        },
      ]
    },
  ]
};

void throwError(String message) {
  print("ERROR PARSING COMPARISON: $message");
  throw message;
}

dynamic getFromJson(Map<String, dynamic> json, String key) {
  if (json[key] == null) {
    throwError("key $key not found.");
  }
  return json[key];
}

Future<dynamic> evaluateComparison(
    Map<String, dynamic> json, int auditTaskId) async {
  switch (getFromJson(json, "comparisonTokenType")) {
    case "function":
      return await evaluateComparisonFunction(getFromJson(json, "name"),
          getFromJson(json, "arguments"), auditTaskId);
    case "literal":
      return await evaluateComparisonLiteral(
          getFromJson(json, "value"), getFromJson(json, "type"));
    case "identifier":
      return await evaluateComparisonIdentifier(
          getFromJson(json, "quid"), getFromJson(json, "type"), auditTaskId);
    default:
      throwError(
          "unknown comparisonTokenType ${getFromJson(json, "comparisonTokenType")}");
      break;
  }
  return true;
}

Future<dynamic> evaluateComparisonFunction(
    String name, List<dynamic> arguments, int auditTaskId) async {
  if (name == "is empty" || name == "is not empty") {
    if (arguments.length != 1) {
      throwError("expected 1 argument but got something different");
    }
    var a = await evaluateComparison(arguments[0], auditTaskId);
    switch (name) {
      case "is empty":
        return a == null;
      case "is not empty":
        return a != null;
      default:
        throwError("unknown function name");
        return;
    }
  }

  if (arguments.length != 2) {
    throwError("expected 2 arguments but got something different");
  }
  var a = await evaluateComparison(arguments[0], auditTaskId);
  var b = await evaluateComparison(arguments[1], auditTaskId);
  if (a == null || b == null) return false;

  switch (name) {
    case "and":
      return a && b;
    case "or":
      return a || b;
  }

  if (arguments[0]["type"] != arguments[1]["type"]) {
    throwError("type must match!");
  }
  switch (arguments[0]["type"]) {
    case "answerText":
      a = a["answer"];
      b = b["answer"];
      switch (name) {
        case "is":
          return a == b;
        case "is not":
          return a != b;
        case "contains":
          return a.contains(b);
        case "does not contain":
          return !a.contains(b);
        case "starts with":
          return !a.startsWith(b);
        case "ends with":
          return !a.endsWith(b);
        default:
          throwError("unknown function name");
          return;
      }
    case "answerNumerical":
      a = a["answer"];
      b = b["answer"];
      switch (name) {
        case "is equal to":
          return a == b;
        case "is not equal to":
          return a != b;
        case "is greater than":
          return a > b;
        case "is less than":
          return a < b;
        case "is greater or equal to":
          return a >= b;
        case "is less than or equal to":
          return a <= b;
        default:
          throwError("unknown function name");
          return;
      }
    case "answerDropdown":
      a = a["answer"];
      b = b["answer"];
      switch (name) {
        case "is":
          return a == b;
        case "is not":
          return a != b;
        default:
          throwError("unknown function name");
          return;
      }
    case "answerButtons":
    case "answerCheckbox":
      a = a["answer"];
      b = b["answer"];
      switch (name) {
        case "is exactly":
          for (var i = 0; i < max(a.length, b.length); i++) {
            bool x, y;
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
              return false;
            }
          }
          return true;
        case "is not exactly":
          for (var i = 0; i < max(a.length, b.length); i++) {
            bool x, y;
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
              return true;
            }
          }
          return false;
        case "contains":
          for (var i = 0; i < max(a.length, b.length); i++) {
            bool x, y;
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
              return false;
            }
          }
          return true;
        case "does not contain":
          for (var i = 0; i < max(a.length, b.length); i++) {
            bool x, y;
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
              return true;
            }
          }
          return false;
        default:
          throwError("unknown function name");
          return;
      }
    case "answerDatetime":
      a = a["answer"];
      b = b["answer"];
      switch (name) {
        case "is equal to":
          return a == b;
        case "is not equal to":
          return a != b;
        default:
          throwError("unknown function name");
          return;
      }
    default:
      throwError("unknown first argument type ${arguments[0]}");
      return;
  }
}

Future<dynamic> evaluateComparisonIdentifier(
    String quid, String type, int auditTaskId) async {
  return await auditing_service.getAuditDataAnswer(quid,
      auditTaskId: auditTaskId);
}

Future<dynamic> evaluateComparisonLiteral(
    Map<String, dynamic> value, String type) async {
  return value;
}
