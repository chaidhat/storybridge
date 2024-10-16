import 'dart:math';

import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/services/auditing_service.dart' as auditing_service;
import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;

enum DataSourceType { labelGroups, users, unlinked }

const Map<DataSourceType, String> dataSourceStringMap = {
  DataSourceType.labelGroups: "labelGroups",
  DataSourceType.users: "users",
  DataSourceType.unlinked: "unlinked",
};

/*

["a", "b", "c"] -> DataAnswers.getAnswersFromEncoded() -> [true, false, false, true, true]
[{labelId: 152}, {labelId: 153}] -> DataAnswers.getAnswersFromEncoded() -> [false, true, true, false]
[{userId:553}] -> DataAnswers.getAnswersFromEncoded() -> [false, true, false, false]

DataAnswers.getEncodedFromAnswers will be the inverse
*/
class DataSource {
  DataSourceType dataSourceType;
  int? labelGroupId;
  final ScholarityTextFieldController unlinkedAnswers =
      ScholarityTextFieldController();
  DataSource(
      {this.labelGroupId, this.dataSourceType = DataSourceType.unlinked}) {
    if (dataSourceType == DataSourceType.labelGroups && labelGroupId == null) {
      throw Exception("labelGroupId must be specified");
    }
    unlinkedAnswers.addListener(() {
      onUpdate();
    });
  }
  final List<Function> _callbacks = [];

  void addListener(Function callback) {
    _callbacks.add(callback);
  }

  Future<List<bool>> getAnswersFromEncoded(
      dynamic json, int organizationId) async {
    switch (dataSourceType) {
      case DataSourceType.labelGroups:
        // json should be encoded as [{labelId: 152}, {labelId: 153}, ... ]
        Map<String, dynamic> response =
            await networking_api_service.getLabels(labelGroupId: labelGroupId!);
        List<bool> output = [];
        for (int i = 0; i < response["data"].length; i++) {
          int labelId = response["data"][i]["labelId"];
          bool isLabelIdInJson = false;
          try {
            for (var obj in json) {
              if (obj["labelId"] == labelId) {
                isLabelIdInJson = true;
              }
            }
          } catch (e) {
            throw Exception("Answer encoding is malformed.");
          }
          output.add(isLabelIdInJson);
        }
        return output;
      case DataSourceType.users:
        // json should be encoded as [{userId: 152}, {userId: 153}, ... ]
        Map<String, dynamic> response = await networking_api_service
            .getUserFromOrganizationId(organizationId: organizationId);
        List<bool> output = [];
        for (int i = 0; i < response["data"].length; i++) {
          int userId = response["data"][i]["userId"];
          bool isUserIdInJson = false;
          try {
            for (var obj in json) {
              if (obj["userId"] == userId) {
                isUserIdInJson = true;
              }
            }
          } catch (e) {
            throw Exception("Answer encoding is malformed.");
          }
          output.add(isUserIdInJson);
        }
        return output;
      case DataSourceType.unlinked:
        // json should be encoded as [{unlinkedAnswer: "a"}, {unlinkedAnswer: "b"}, ...]
        List<String> response =
            auditing_service.parseCommaData(unlinkedAnswers.text);
        List<bool> output = [];
        for (int i = 0; i < response.length; i++) {
          String unlinkedAnswer = response[i];
          bool isUserIdInJson = false;
          try {
            for (var obj in json) {
              if (obj["unlinkedAnswer"] == unlinkedAnswer) {
                isUserIdInJson = true;
              }
            }
          } catch (e) {
            throw Exception("Answer encoding is malformed.");
          }
          output.add(isUserIdInJson);
        }
        return output;
    }
  }

  Future<dynamic> getEncodedFromAnswers(
      List<bool> answers, int organizationId) async {
    switch (dataSourceType) {
      case DataSourceType.labelGroups:
        // json should be encoded as [{labelId: 152}, {labelId: 153}, ... ]
        Map<String, dynamic> response =
            await networking_api_service.getLabels(labelGroupId: labelGroupId!);
        List<dynamic> output = [];
        for (int i = 0; i < answers.length; i++) {
          if (answers[i]) {
            output.add({"labelId": response["data"][i]["labelId"]});
          }
        }
        return output;
      case DataSourceType.users:
        // json should be encoded as [{userId: 152}, {userId: 153}, ... ]
        Map<String, dynamic> response = await networking_api_service
            .getUserFromOrganizationId(organizationId: organizationId);
        List<dynamic> output = [];
        for (int i = 0; i < answers.length; i++) {
          if (answers[i]) {
            output.add({"userId": response["data"][i]["userId"]});
          }
        }
        return output;
      case DataSourceType.unlinked:
        // json should be encoded as [{unlinkedAnswer: "a"}, {unlinkedAnswer: "b"}, ...]
        List<String> response =
            auditing_service.parseCommaData(unlinkedAnswers.text);
        List<dynamic> output = [];
        for (int i = 0; i < answers.length; i++) {
          if (answers[i]) {
            output.add({"unlinkedAnswer": response[i]});
          }
        }
        return output;
    }
  }

  Future<Map<String, DataSource>> getAllDataSourceNames(
      int organizationId) async {
    Map<String, DataSource> output = {};
    output["Manually specify dropdowns"] =
        (DataSource(dataSourceType: DataSourceType.unlinked));
    output["Organization users"] =
        (DataSource(dataSourceType: DataSourceType.users));
    Map<String, dynamic> response = await networking_api_service.getLabelGroups(
        organizationId: organizationId);
    for (int i = 0; i < response["data"].length; i++) {
      output["Data type: ${Uri.decodeComponent(response["data"][i]["labelGroupName"])}"] =
          DataSource(
              dataSourceType: DataSourceType.labelGroups,
              labelGroupId: response["data"][i]["labelGroupId"]);
    }
    return output;
  }

  Future<String> getCurrentDataSourceName() async {
    if (dataSourceType == DataSourceType.unlinked) {
      return "Manually specify dropdowns";
    } else if (dataSourceType == DataSourceType.users) {
      return "Users";
    } else {
      if (labelGroupId == null) {}
      Map<String, dynamic> response = await networking_api_service
          .getLabelGroup(labelGroupId: labelGroupId!);
      return "Data type: ${Uri.decodeComponent(response["data"][0]["labelGroupName"])}";
    }
  }

  Future<List<String>> getDropdowns(int organizationId) async {
    switch (dataSourceType) {
      case DataSourceType.labelGroups:
        Map<String, dynamic> response =
            await networking_api_service.getLabels(labelGroupId: labelGroupId!);
        List<String> labelNames = [];
        for (int i = 0; i < response["data"].length; i++) {
          labelNames.add(Uri.decodeComponent(response["data"][i]["labelName"]));
        }
        return labelNames;
      case DataSourceType.users:
        Map<String, dynamic> response = await networking_api_service
            .getUserFromOrganizationId(organizationId: organizationId);
        List<String> labelNames = [];
        for (int i = 0; i < response["data"].length; i++) {
          labelNames.add(Uri.decodeComponent(response["data"][i]["email"]));
        }
        return labelNames;
      case DataSourceType.unlinked:
        return auditing_service.parseCommaData(unlinkedAnswers.text);
    }
  }

  void onUpdate() {
    for (Function callback in _callbacks) {
      callback();
    }
  }

  void deserialize(dynamic json) {
    if (json == null) {
      return;
    }
    try {
      labelGroupId = json["labelGroupId"];
      unlinkedAnswers.text = json["unlinkedAnswers"] ?? "";
      for (DataSourceType key in dataSourceStringMap.keys) {
        if (dataSourceStringMap[key] == json["type"]) {
          dataSourceType = key;
        }
        if (dataSourceType == DataSourceType.labelGroups &&
            labelGroupId == null) {
          throw "labelGroupId cannot be null if dataSourceType is DataSourceType.labelGroups";
        }
      }
    } catch (e) {
      throw Exception("Malformed DataSource");
    }
  }

  dynamic serialize() {
    return {
      "type": dataSourceStringMap[dataSourceType],
      "labelGroupId": labelGroupId,
      "unlinkedAnswers": unlinkedAnswers.text,
    };
  }
}

// myPage class which creates a state on call
class DatasourceEditor extends StatefulWidget {
  final DataSource dataSource;
  final int organizationId;
  const DatasourceEditor(
      {Key? key, required this.dataSource, required this.organizationId})
      : super(key: key);

  @override
  _DatasourceEditorState createState() => _DatasourceEditorState();
}

// myPage state
class _DatasourceEditorState extends State<DatasourceEditor> {
  final Map<String, DataSource> _dataSources = {};
  String? _previewDataSource;
  final ScholarityTextFieldController _dataSourceController =
      ScholarityTextFieldController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<dynamic> _load() async {
    if (_dataSources.isEmpty) {
      _dataSourceController.text =
          await widget.dataSource.getCurrentDataSourceName();
      // load data sources
      _dataSources.clear();
      _dataSources.addAll(
          await widget.dataSource.getAllDataSourceNames(widget.organizationId));
    }

    if (_previewDataSource == null &&
        widget.dataSource.dataSourceType != DataSourceType.unlinked) {
      List<String> previews =
          await widget.dataSource.getDropdowns(widget.organizationId);
      _previewDataSource =
          "${previews.getRange(0, min(5, previews.length)).join(", ")}${previews.length > 5 ? "..." : ""}";
    } else if (widget.dataSource.dataSourceType == DataSourceType.unlinked) {
      _previewDataSource = null;
    }
    return true;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return FutureBuilder(
        future: _load(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScholarityTextP(
                  "User can select answers from the following options:"),
              ScholarityDropdown(
                  width: 400,
                  controller: _dataSourceController,
                  onSubmit: (value) {
                    setState(() {
                      widget.dataSource.dataSourceType = value.dataSourceType;
                      widget.dataSource.labelGroupId = value.labelGroupId;
                      widget.dataSource.onUpdate();
                      _previewDataSource = null;
                    });
                  },
                  label: "Data Source",
                  mappedDropdownTypes: _dataSources),
              widget.dataSource.dataSourceType == DataSourceType.unlinked
                  ? const ScholarityTextP(
                      "Please separate selections with a comma")
                  : Container(),
              widget.dataSource.dataSourceType == DataSourceType.unlinked
                  ? SizedBox(
                      height: 110,
                      child: ScholarityTextField(
                        isLarge: true,
                        label: "Answers, separated by commas",
                        hintText: "alice, bob, charlie",
                        controller: widget.dataSource.unlinkedAnswers,
                      ),
                    )
                  : Container(),
              _previewDataSource != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ScholarityTextP(_previewDataSource!),
                    )
                  : Container(),
            ],
          );
        });
  }
}
