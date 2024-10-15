import 'dart:convert';
import 'dart:math';

import 'package:mooc/services/course_navigation_service.dart'
    as course_navigation_service;
import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/showif_service.dart' as showif_service;

dynamic _data;
dynamic _auditTaskData;
Map<int, int> _auditStatusLabelGroupId = {};
Map<int, dynamic> _auditTemplateData = {};
int? _auditTaskId;

Future<void> setAuditTaskId(int? auditTaskId) async {
  if (auditTaskId == null) {
    _data = null;
    _auditTaskData = null;
    return;
  }
  _auditTaskId = auditTaskId;
  try {
    Map<String, dynamic> response =
        await networking_api_service.getAuditTask(auditTaskId: auditTaskId);
    _data = response["data"][0];
    _auditTaskData =
        jsonDecode(Uri.decodeComponent(_data["auditTaskData"]))["data"];
  } catch (e) {
    rethrow;
  }
}

int? getAuditTaskId() {
  return _auditTaskId;
}

dynamic getAuditData() {
  return _data;
}

class _UpdateIdentifier {
  String quid;
  int auditTaskId;
  _UpdateIdentifier({required this.quid, required this.auditTaskId});
  String serialize() {
    return "$quid-$auditTaskId";
  }
}

const int DELAY_SECONDS = 2; // seconds
Map<String, bool> _queuedUpdate = {};
Map<String, bool> _lockUpdate = {};
Map<String, dynamic> _auditTaskQuestionData = {};

void _updateAuditTask(_UpdateIdentifier updateIdentifier) async {
  if (_auditTaskData == null) {
    return null;
  }
  _lockUpdate[updateIdentifier.serialize()] = true;
  _queuedUpdate[updateIdentifier.serialize()] = false;
  // execute update
  if (_data != null) {
    await networking_api_service.setAuditTaskQuestion(
        quid: updateIdentifier.quid,
        auditTaskId: updateIdentifier.auditTaskId,
        data: jsonEncode(_auditTaskQuestionData[updateIdentifier.serialize()]));
    showif_service.updateAllShowifs();
  }

  await Future.delayed(const Duration(seconds: DELAY_SECONDS));
  if (_queuedUpdate[updateIdentifier.serialize()]!) {
    _updateAuditTask(updateIdentifier);
  } else {
    _lockUpdate[updateIdentifier.serialize()] = false;
  }
}

void setAuditDataAnswer(String quid, dynamic data) async {
  if (_auditTaskData == null) {
    return null;
  }
  _UpdateIdentifier updateIdentifier =
      _UpdateIdentifier(quid: quid, auditTaskId: _auditTaskId!);
  _auditTaskQuestionData[updateIdentifier.serialize()] = data;
  _queuedUpdate[updateIdentifier.serialize()] = true;
  if (_lockUpdate[updateIdentifier.serialize()] == null) {
    _lockUpdate[updateIdentifier.serialize()] = false;
  }
  if (!_lockUpdate[updateIdentifier.serialize()]!) {
    _updateAuditTask(updateIdentifier);
  }
}

Future<dynamic> getAuditDataAnswer(String quid, {int? auditTaskId}) async {
  if (_auditTaskData == null && auditTaskId == null) {
    return null;
  }
  _UpdateIdentifier updateIdentifier;
  int ati;
  if (auditTaskId == null) {
    ati = _auditTaskId!;
  } else {
    ati = auditTaskId;
  }
  updateIdentifier = _UpdateIdentifier(quid: quid, auditTaskId: ati);
  if (_auditTaskQuestionData[updateIdentifier.serialize()] != null) {
    // use the cached data.
    // Please don't remove this in the future.
    // if you do, make sure that checkboxes work.
    // instead, update the CACHE instead of this
    return _auditTaskQuestionData[updateIdentifier.serialize()];
  }
  Map<String, dynamic> response = await networking_api_service
      .getAuditTaskQuestion(quid: quid, auditTaskId: ati);
  if (response["data"].length == 0) {
    return null;
  }
  return jsonDecode(Uri.decodeComponent(response["data"][0]["data"]));
}

// NAVIGATION

Map<int, String> _selectedPageId = {};

void setSelectedAuditTemplatePageId(int auditTemplateId, String pageId) {
  _selectedPageId[auditTemplateId] = pageId;
  _reloadAuditTemplatePages(auditTemplateId);
}

String? getSelectedAuditTemplatePageId(int auditTemplateId) {
  return _selectedPageId[auditTemplateId];
}

abstract class AuditTemplateElement {
  void onAuditChangePage(String pageId);
}

AuditTemplateElement? auditTemplateViewer;
AuditTemplateElement? auditTemplateHierarchy;

void _updateAuditTemplate(int auditTemplateId) async {
  Map<String, dynamic> response = await networking_api_service.getAuditTemplate(
      auditTemplateId: auditTemplateId);
  await networking_api_service.changeAuditTemplate(
      auditTemplateId: auditTemplateId,
      auditTemplateName:
          Uri.decodeComponent(response["data"][0]["auditTemplateName"]),
      auditTemplateDescription:
          Uri.decodeComponent(response["data"][0]["auditTemplateDescription"]),
      auditTemplateData: jsonEncode(_auditTemplateData[auditTemplateId]));
}

void _reloadAuditTemplatePages(int auditTemplateId) {
  auditTemplateViewer?.onAuditChangePage(
      _auditTemplateData[auditTemplateId]["pages"].last["pageId"]);
  auditTemplateHierarchy?.onAuditChangePage(
      _auditTemplateData[auditTemplateId]["pages"].last["pageId"]);
}

Future<void> setAuditTemplateId(int auditTemplateId, bool isAdminMode) async {
  Map<String, dynamic> response = await networking_api_service.getAuditTemplate(
      auditTemplateId: auditTemplateId);
  String responseData =
      Uri.decodeComponent(response["data"][0]["auditTemplateData"]);
  _auditStatusLabelGroupId[auditTemplateId] =
      response["data"][0]["statusLabelGroupId"];
  _auditTemplateData[auditTemplateId] = jsonDecode(responseData);
  if (_auditTemplateData[auditTemplateId]["pages"] == null) {
    // backwards compatibility. Update old auditTemplateData to a newer format.
    Map<String, dynamic> out = {};
    out["pages"] = [];
    out["pages"].add({
      "pageId": Random().nextInt(9999999).toString(),
      "pageName": "page",
      "data": _auditTemplateData[auditTemplateId],
    });
    _auditTemplateData[auditTemplateId] = out;
  }
  course_navigation_service.setStateForAudit(
      auditTemplateId, response["data"][0]["organizationId"], isAdminMode);
  gotoFrontAuditTemplatePage(auditTemplateId);
}

int getAuditTemplateStatusLabelGroupId(int auditTemplateId) {
  return _auditStatusLabelGroupId[auditTemplateId]!;
}

Future<Map<String, dynamic>> getAuditTemplatePageData(
    int auditTemplateId, bool isAdminMode) async {
  String pageId = _selectedPageId[auditTemplateId]!;
  if (_auditTemplateData[auditTemplateId] == null) {
    try {
      await setAuditTemplateId(auditTemplateId, isAdminMode);
    } catch (_) {
      rethrow;
    }
  }

  for (int i = 0;
      i < _auditTemplateData[auditTemplateId]["pages"].length;
      i++) {
    if (_auditTemplateData[auditTemplateId]["pages"][i]["pageId"] == pageId) {
      return _auditTemplateData[auditTemplateId]["pages"][i];
    }
  }
  return _auditTemplateData[auditTemplateId]["pages"][0]; // return front page
}

void setAuditTemplatePageData(int auditTemplateId, var data) async {
  String pageId = _selectedPageId[auditTemplateId]!;
  if (_auditTemplateData[auditTemplateId] == null) {
    throw Exception();
  }
  bool found = false;
  for (int i = 0;
      i < _auditTemplateData[auditTemplateId]["pages"].length;
      i++) {
    if (_auditTemplateData[auditTemplateId]["pages"][i]["pageId"] == pageId) {
      found = true;
      _auditTemplateData[auditTemplateId]["pages"][i]["data"] = data;
      break;
    }
  }
  if (!found) {
    throw Exception();
  }

  try {
    _updateAuditTemplate(auditTemplateId);
  } catch (_) {
    rethrow;
  }
}

void gotoFrontAuditTemplatePage(int auditTemplateId) {
  if (_auditTemplateData[auditTemplateId] == null) {
    throw Exception();
  }
  _selectedPageId[auditTemplateId] =
      _auditTemplateData[auditTemplateId]["pages"][0]["pageId"];
}

void addAuditTemplatePage(int auditTemplateId) {
  _auditTemplateData[auditTemplateId]["pages"].add({
    "pageName": "Untitled Page",
    "pageId": Random().nextInt(9999999).toString(),
    "data": {"widgetType": "column", "children": []}
  });
  _updateAuditTemplate(auditTemplateId);
  _reloadAuditTemplatePages(auditTemplateId);
}

Future<List<dynamic>> getAuditTemplateHierarchyData(
    int auditTemplateId, bool isAdminMode) async {
  if (_auditTemplateData[auditTemplateId] == null) {
    try {
      await setAuditTemplateId(auditTemplateId, isAdminMode);
    } catch (_) {
      rethrow;
    }
  }
  List<dynamic> output = [];
  for (int i = 0;
      i < _auditTemplateData[auditTemplateId]["pages"].length;
      i++) {
    output.add({
      "pageName": _auditTemplateData[auditTemplateId]["pages"][i]["pageName"],
      "pageId": _auditTemplateData[auditTemplateId]["pages"][i]["pageId"],
    });
  }
  return output;
}

void renameAuditTemplatePage(
    int auditTemplateId, String pageId, String newPageName) {
  for (int i = 0;
      i < _auditTemplateData[auditTemplateId]["pages"].length;
      i++) {
    if (_auditTemplateData[auditTemplateId]["pages"][i]["pageId"] == pageId) {
      _auditTemplateData[auditTemplateId]["pages"][i]["pageName"] = newPageName;
    }
  }
  _updateAuditTemplate(auditTemplateId);
  _reloadAuditTemplatePages(auditTemplateId);
}

void deleteAuditTemplatePage(int auditTemplateId, String pageId) {
  for (int i = 0;
      i < _auditTemplateData[auditTemplateId]["pages"].length;
      i++) {
    if (_auditTemplateData[auditTemplateId]["pages"][i]["pageId"] == pageId) {
      _auditTemplateData[auditTemplateId]["pages"].removeAt(i);
    }
  }
  _updateAuditTemplate(auditTemplateId);
  _reloadAuditTemplatePages(auditTemplateId);
}

List<String> parseCommaData(String input) {
  List<String> output = input.split(",");
  for (int i = 0; i < output.length; i++) {
    output[i] = output[i].trim();
    output[i] = output[i].replaceAll("\n", "");
  }
  return output;
}
