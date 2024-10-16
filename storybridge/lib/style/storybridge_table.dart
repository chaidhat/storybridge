import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mooc/storybridge.dart'; // Storybridge

import 'package:mooc/style/storybridge_colors.dart' as storybridge_color;
import 'package:mooc/services/translation_service.dart' as translation_service;

import 'package:excel/excel.dart' as excl;
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

enum StorybridgeTableHeaderType {
  text,
  dropdown,
  datetime,
  label,
  boolean,
  color
}

class StorybridgeTableHeader {
  String key, label;
  double width;
  StorybridgeTableHeaderType type;
  List<String>? dropdownList;
  Map<String, dynamic>? labelData;
  StorybridgeTableHeader(
      {required this.key,
      required this.label,
      this.labelData,
      this.width = 190,
      this.type = StorybridgeTableHeaderType.text,
      this.dropdownList}) {
    if (type == StorybridgeTableHeaderType) {
      print(
          "warning: dropdownList must be defined for StorybridgeTableHeaders");
    }
  }
}

class StorybridgeTable extends StatefulWidget {
  final List<dynamic> data;
  final List<String>? displayHeaders;
  final List<StorybridgeTableHeader>? advancedHeaders;
  final String? pkName; // private key for table
  final void Function(dynamic pk, dynamic data, int index)? onEdit;
  final void Function(dynamic pk, dynamic data, int index)? onDelete;
  final void Function(dynamic pk, dynamic data, int index)? onView;
  final bool initiallyOpenSearch;
  final bool canSearch;
  final List<StorybridgeTableButton>? extraButtons;
  final int maxItemsPerPage;
  final bool useAltStyle;
  const StorybridgeTable({
    Key? key,
    required this.data,
    this.displayHeaders,
    this.advancedHeaders,
    this.pkName,
    this.onEdit,
    this.onDelete,
    this.onView,
    this.extraButtons,
    this.maxItemsPerPage = 20,
    this.canSearch = true,
    this.useAltStyle = true,
    this.initiallyOpenSearch = false,
  }) : super(key: key);

  @override
  State<StorybridgeTable> createState() => _StorybridgeTableState();
}

class _StorybridgeTableState extends State<StorybridgeTable> {
  final List<StorybridgeTableHeader> _headers = [];
  final List<String> _strHeaders = [];
  final Map<String, String> _labelsToKeys = {};
  bool _showSearchPage = false;
  int _page = 0;
  List<dynamic> _data = [];
  final StorybridgeTextFieldController _searchController =
      StorybridgeTextFieldController();
  final StorybridgeTextFieldController _searchCategoryController =
      StorybridgeTextFieldController();

  @override
  void initState() {
    super.initState();
    _page = 0;
    _showSearchPage = widget.initiallyOpenSearch;
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _filterSearchData(String searchTerm, String searchCategory) {
    if (searchTerm == "") {
      _data = widget.data;
      return;
    }
    _data = [];
    List<String> choices = [];
    for (int i = 0; i < widget.data.length; i++) {
      try {
        choices.add(Uri.decodeComponent(
            widget.data[i][_labelsToKeys[searchCategory]].toString()));
      } catch (e) {
        choices.add(widget.data[i][_labelsToKeys[searchCategory]].toString());
      }
    }
    var results = extractAllSorted(
      query: searchTerm,
      choices: choices,
      cutoff: 70,
    );
    for (int i = 0; i < results.length; i++) {
      int j = results[i].index;
      var dataPoint = widget.data[j];
      if (dataPoint != null) {
        _data.add(dataPoint);
      }
    }
  }

  void _clampPages() {
    if (_page * widget.maxItemsPerPage >= _data.length) {
      _page = 0;
    }
  }

  void _getHeaders() {
    _headers.clear();
    if (widget.advancedHeaders != null) {
      for (StorybridgeTableHeader header in widget.advancedHeaders!) {
        _headers.add(header);
      }
      _getStringHeaders();
      return;
    }
    if (widget.displayHeaders != null) {
      for (String header in widget.displayHeaders!) {
        _headers.add(StorybridgeTableHeader(
            key: header, label: header, type: StorybridgeTableHeaderType.text));
      }
      _getStringHeaders();
      return;
    }

    for (Map<String, dynamic> obj in widget.data) {
      for (String key in obj.keys) {
        bool doesHeaderContainKey = false;
        for (StorybridgeTableHeader h in _headers) {
          if (h.key == key) {
            doesHeaderContainKey = true;
          }
        }
        if (!doesHeaderContainKey) {
          _headers.add(StorybridgeTableHeader(
              key: key, label: key, type: StorybridgeTableHeaderType.text));
        }
      }
    }
    _getStringHeaders();
  }

  void _downloadTable() {
    var excel = excl.Excel.createExcel();
    excl.Sheet sheetObject = excel['Sheet1'];
    for (int i = 0; i < _strHeaders.length; i++) {
      var cell = sheetObject
          .cell(excl.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = excl.TextCellValue(_strHeaders[i]);
      cell.cellStyle =
          (cell.cellStyle ?? excl.CellStyle()).copyWith(boldVal: true);
      sheetObject.setColumnAutoFit(i);
    }
    for (int i = 0; i < _data.length; i++) {
      for (int j = 0; j < _strHeaders.length; j++) {
        var cell = sheetObject.cell(
            excl.CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1));
        late String dataStr;
        try {
          dataStr = Uri.decodeComponent(
              _data[i][_labelsToKeys[_strHeaders[j]]]?.toString() ?? "");
        } catch (e) {
          dataStr = _data[i][_labelsToKeys[_strHeaders[j]]]?.toString() ?? "";
        }
        cell.value = excl.TextCellValue(dataStr);
      }
    }
    excel.save(fileName: 'StorybridgeDataDownload.xlsx');
  }

  void _getStringHeaders() {
    _strHeaders.clear();
    for (int i = 0; i < _headers.length; i++) {
      _labelsToKeys[_headers[i].label] = _headers[i].key;
      _strHeaders.add(_headers[i].label);
    }
  }

  void _nextPage() {
    if ((_page + 1) * widget.maxItemsPerPage < _data.length) {
      setState(() {
        _page++;
      });
    }
  }

  void _prevPage() {
    if (_page > 0) {
      setState(() {
        _page--;
      });
    }
  }

  void _firstPage() {
    setState(() {
      _page = 0;
    });
  }

  void _lastPage() {
    setState(() {
      while (((_page + 1) * widget.maxItemsPerPage < _data.length)) {
        _page++;
      }
    });
  }

  Widget _getCellWidget(dynamic cellData, StorybridgeTableHeader header) {
    if (cellData != null) {
      switch (header.type) {
        case StorybridgeTableHeaderType.boolean:
          String? cellString = cellData?.toString();
          if (cellString == "{type: Buffer, data: [1]}") {
            return Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.check_rounded,
                color: storybridge_color.black,
              ),
            );
          } else if (cellString == "{type: Buffer, data: [0]}") {
            return Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.close_rounded,
                color: storybridge_color.black,
              ),
            );
          } else {
            print("wrong data type for table.");
          }
          break;
        case StorybridgeTableHeaderType.text:
        case StorybridgeTableHeaderType.dropdown:
          String cellString;
          try {
            cellString = Uri.decodeComponent(cellData!.toString());
          } catch (_) {
            cellString = cellData;
          }
          return _StorybridgeCell(
              useAltStyle: widget.useAltStyle,
              width: header.width,
              child: IntrinsicWidth(
                child: StorybridgeTextP(cellString),
              ));

        case StorybridgeTableHeaderType.datetime:
          DateTime? datetime = parseSqlDatetime(cellData?.toString());
          if (datetime != null) {
            return _StorybridgeCell(
                useAltStyle: widget.useAltStyle,
                width: header.width,
                child: IntrinsicWidth(
                  child:
                      StorybridgeTextP(translation_service.getDate(datetime)),
                ));
          }
          break;
        case StorybridgeTableHeaderType.label:
          return StorybridgeLabels(
            selectedLabels: cellData,
            canEdit: true,
          );
        case StorybridgeTableHeaderType.color:
          try {
            return _StorybridgeCell(
                useAltStyle: widget.useAltStyle,
                width: header.width,
                child: IntrinsicWidth(
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: storybridge_color.borderColor),
                            borderRadius: BorderRadius.circular(4),
                            color: HexColor(cellData!.toString())),
                        height: 20,
                        width: 20,
                      ),
                    ],
                  ),
                ));
          } catch (_) {}
          break;
      }
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 30,
        child: Divider(color: storybridge_color.borderColor),
      ),
    );
  }

  bool _areTherePopupItems() {
    List<PopupMenuEntry> output = _getPopupItems(0);
    return output.isNotEmpty;
  }

  List<PopupMenuEntry> _getPopupItems(int index) {
    List<PopupMenuEntry> output = [];

    if (widget.onView != null) {
      output.add(PopupMenuItem(
        onTap: () {
          setState(() {
            String key = widget.pkName ?? _data[0].keys.toList().first;
            var id = _data[index][key];
            widget.onView!(id, _data[index], index);
          });
        },
        child: const StorybridgeTextBasic('View'),
      ));
    }
    if (widget.onEdit != null) {
      output.add(PopupMenuItem(
        onTap: () {
          setState(() {
            showDialog<String>(
                context: context,
                builder: (BuildContext context) =>
                    StorybridgeAlertDialogWrapper(
                      child: StorybridgeAlertDialog(
                        content: _StorybridgeCellEditForm(
                            data: _data[index],
                            headers: _headers,
                            onSave: () {
                              String key =
                                  widget.pkName ?? _data[0].keys.toList().first;
                              try {
                                var id = widget.data[index][key];
                                widget.onEdit!(id, _data[index], index);
                              } catch (e) {
                                print(
                                    "id for table is invalid. id name is '$key'");
                              }
                            }),
                      ),
                    ));
          });
        },
        child: const StorybridgeTextBasic('Edit'),
      ));
    }
    if (widget.extraButtons != null) {
      for (int j = 0; j < widget.extraButtons!.length; j++) {
        StorybridgeTableButton button = widget.extraButtons![j];
        output.add(PopupMenuItem(
          onTap: () {
            String key = widget.pkName ?? _data[0].keys.toList().first;
            var id = _data[index][key];
            button.onPressed(id, _data[index]);
          },
          child: StorybridgeTextBasic(button.buttonText),
        ));
      }
    }
    if (widget.onDelete != null) {
      output.add(PopupMenuItem(
        onTap: () {
          setState(() {
            String key = widget.pkName ?? _data[0].keys.toList().first;
            var id = _data[index][key];
            widget.onDelete!(id, _data[index], index);
          });
        },
        child: const StorybridgeTextBasic('Delete',
            style: TextStyle(color: Colors.red)),
      ));
    }
    return output;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    _getHeaders();
    if (_strHeaders.isNotEmpty &&
        !_strHeaders.contains(_searchCategoryController.text)) {
      _searchCategoryController.text = _strHeaders[0];
    }
    _filterSearchData(_searchController.text, _searchCategoryController.text);
    _clampPages();
    return Column(
      children: [
        _showSearchPage
            ? _StorybridgeTableSearchWidget(
                searchController: _searchController,
                searchCategoryController: _searchCategoryController,
                strHeaders: _strHeaders,
              )
            : Container(),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(width: 20),
            widget.canSearch
                ? Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: StorybridgeIconButton(
                      icon: Icons.search_rounded,
                      onPressed: () {
                        setState(() {
                          _showSearchPage = !_showSearchPage;
                        });
                      },
                    ),
                  )
                : Container(),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: StorybridgeIconButton(
                icon: Icons.download_rounded,
                onPressed: () {
                  _downloadTable();
                },
              ),
            ),
            (_data.length > widget.maxItemsPerPage)
                ? Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: StorybridgeIconButton(
                            icon: Icons.first_page,
                            onPressed: (_page > 0)
                                ? () {
                                    _firstPage();
                                  }
                                : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: StorybridgeIconButton(
                            icon: Icons.arrow_back_rounded,
                            onPressed: (_page > 0)
                                ? () {
                                    _prevPage();
                                  }
                                : null,
                          ),
                        ),
                        StorybridgeTextP(
                            "Page ${_page + 1} of ${(_data.length / widget.maxItemsPerPage).ceil()}"),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: StorybridgeIconButton(
                            icon: Icons.arrow_forward_rounded,
                            onPressed: ((_page + 1) * widget.maxItemsPerPage <
                                    _data.length)
                                ? () {
                                    _nextPage();
                                  }
                                : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: StorybridgeIconButton(
                            icon: Icons.last_page,
                            onPressed: ((_page + 1) * widget.maxItemsPerPage <
                                    _data.length)
                                ? () {
                                    _lastPage();
                                  }
                                : null,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
          ]),
        ),
        _data.isNotEmpty
            ? IntrinsicHeight(
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: _areTherePopupItems() ? 52 : 0),
                                child: Row(
                                    children:
                                        List.generate(_headers.length, (int i) {
                                  return SizedBox(
                                      width: _headers[i].width,
                                      child: StorybridgeTextH2B(
                                          _headers[i].label));
                                })),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(
                                    min(
                                        _data.length -
                                            (_page * widget.maxItemsPerPage),
                                        widget.maxItemsPerPage),
                                    (int iNotOffset) {
                                  int i = iNotOffset +
                                      (_page * widget.maxItemsPerPage);
                                  return InkWell(
                                    onTap: (widget.onView != null)
                                        ? () {
                                            setState(() {
                                              String key = widget.pkName ??
                                                  _data[0].keys.toList().first;
                                              var id = _data[i][key];
                                              widget.onView!(id, _data[i], i);
                                            });
                                          }
                                        : null,
                                    child: _StorybridgeRow(
                                      useAltStyle: widget.useAltStyle,
                                      child: Row(
                                        children: [
                                          _areTherePopupItems()
                                              ? PopupMenuButton(
                                                  tooltip: "",
                                                  itemBuilder:
                                                      (BuildContext context) {
                                                    return _getPopupItems(i);
                                                  },
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 18),
                                                      child:
                                                          StorybridgeIconButton(
                                                        icon: Icons
                                                            .more_horiz_rounded,
                                                        isEnabled: true,
                                                      )),
                                                )
                                              : Container(),
                                          Row(
                                            children: List.generate(
                                                _headers.length, (int j) {
                                              var cell =
                                                  _data[i][_headers[j].key];
                                              return SizedBox(
                                                  width: _headers[j].width,
                                                  child: _getCellWidget(
                                                      cell, _headers[j]));
                                            }),
                                          ),
                                          const SizedBox(width: 10),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: <Color>[
                            storybridge_color.backgroundTransparent,
                            storybridge_color.background,
                          ], // Gradient from https://learnui.design/tools/gradient-generator.html
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: 20,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: <Color>[
                              storybridge_color.backgroundTransparent,
                              storybridge_color.background,
                            ], // Gradient from https://learnui.design/tools/gradient-generator.html
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const _StorybridgeTableEmptyWidget(),
      ],
    );
  }
}

class _StorybridgeTableEmptyWidget extends StatelessWidget {
  // constructor
  const _StorybridgeTableEmptyWidget({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgeTile(
      child: SizedBox(
        height: 300,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied_rounded,
                size: 40, color: storybridge_color.lightGrey),
            const SizedBox(
              width: 10,
            ),
            const StorybridgeTextP("This table is empty!"),
          ],
        ),
      ),
    );
  }
}

class StorybridgeTableButton {
  // members of MyWidget
  final String buttonText;
  final Function(dynamic pk, dynamic data) onPressed;
  StorybridgeTableButton({required this.buttonText, required this.onPressed});
}

class _StorybridgeCell extends StatelessWidget {
  // members of MyWidget
  final Widget child;
  final double width;
  final bool useAltStyle;

  // constructor
  const _StorybridgeCell(
      {Key? key,
      required this.child,
      this.width = 150,
      required this.useAltStyle})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: EdgeInsets.only(right: !useAltStyle ? 8 : 16),
        child: Builder(builder: (context) {
          if (!useAltStyle) {
            return StorybridgeTile(
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: child,
                    )));
          } else {
            return child;
          }
        }),
      ),
    );
  }
}

class _StorybridgeCellEditForm extends StatelessWidget {
  final List<StorybridgeTextFieldController> _controllers = [];

  final void Function() onSave;
  final Map<String, dynamic> data;
  final List<StorybridgeTableHeader> headers;
  // constructor
  _StorybridgeCellEditForm(
      {Key? key,
      required this.data,
      required this.headers,
      required this.onSave})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    _controllers.clear();
    for (int i = 0; i < headers.length; i++) {
      _controllers.add(StorybridgeTextFieldController());
      _controllers[i].text =
          Uri.decodeComponent(data[headers[i].key].toString());
    }
    return SingleChildScrollView(
      child: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const StorybridgeTextH2B("Edit Object"),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(headers.length, (int i) {
                switch (headers[i].type) {
                  case StorybridgeTableHeaderType.text:
                    return StorybridgeTextField(
                      label: headers[i].label,
                      controller: _controllers[i],
                    );
                  case StorybridgeTableHeaderType.dropdown:
                    return StorybridgeDropdown(
                      label: headers[i].label,
                      controller: _controllers[i],
                      dropdownTypes: headers[i].dropdownList ?? [],
                    );
                  case StorybridgeTableHeaderType.datetime:
                    // TODO: make this editable
                    return StorybridgeTextP(
                      _controllers[i].text,
                    );
                  case StorybridgeTableHeaderType.label:
                    return Container(); // TODO
                  case StorybridgeTableHeaderType.boolean:
                    return Container(); // TODO
                  case StorybridgeTableHeaderType.color:
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StorybridgeTextH2B(headers[i].label),
                        StorybridgeColorPicker(controller: _controllers[i]),
                        const SizedBox(height: 30),
                      ],
                    ); // TODO
                }
              }),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                StorybridgeButton(
                  padding: false,
                  text: "Save",
                  invertedColor: true,
                  onPressed: () {
                    Navigator.pop(context);
                    for (int i = 0; i < headers.length; i++) {
                      var dat = data[headers[i].key];
                      if (dat is int) {
                        data[headers[i].key] = int.parse(_controllers[i].text);
                      } else if (dat is String) {
                        data[headers[i].key] = _controllers[i].text;
                      }
                    }
                    onSave();
                  },
                ),
                const SizedBox(width: 10),
                StorybridgeButton(
                    padding: false,
                    text: "Cancel",
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StorybridgeTableSearchWidget extends StatelessWidget {
  // members of MyWidget
  final StorybridgeTextFieldController searchController;
  final StorybridgeTextFieldController searchCategoryController;
  final List<String> strHeaders;

  // constructor
  const _StorybridgeTableSearchWidget(
      {Key? key,
      required this.searchController,
      required this.searchCategoryController,
      required this.strHeaders})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: StorybridgeTextField(
              label: "Search",
              isConstricted: true,
              controller: searchController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: StorybridgeDropdown(
                controller: searchCategoryController,
                label: "Category",
                dropdownTypes: strHeaders),
          )
        ],
      ),
    );
  }
}

DateTime? parseSqlDatetime(String? sqlDatetime) {
  if (sqlDatetime == null) {
    return null;
  }
  // e.g. 2023-07-12T15:50:32.000Z
  DateTime output = DateTime.parse(sqlDatetime).toLocal();
  return output;
}

class StorybridgeTableDropdown extends StatefulWidget {
  final List<dynamic> data;
  final List<StorybridgeTableHeader>? advancedHeaders;
  final bool isEnabled;
  final double width;
  final StorybridgeTextFieldController controller;
  final void Function(dynamic pk) onSubmit;
  const StorybridgeTableDropdown(
      {Key? key,
      required this.data,
      required this.advancedHeaders,
      this.isEnabled = true,
      this.width = 200,
      required this.onSubmit,
      required this.controller})
      : super(key: key);

  @override
  _StorybridgeTableDropdownState createState() =>
      _StorybridgeTableDropdownState();
}

// myPage state
class _StorybridgeTableDropdownState extends State<StorybridgeTableDropdown> {
  String selectedIcon = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showPicker() {
    setState(() {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => StorybridgeAlertDialogWrapper(
          child: StorybridgeAlertDialog(
            content: SizedBox(
              width: 700,
              height: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StorybridgeTable(
                      maxItemsPerPage: 5,
                      advancedHeaders: widget.advancedHeaders,
                      initiallyOpenSearch: true,
                      onView: (dynamic pk, dynamic data, int index) {
                        setState(() {
                          try {
                            widget.controller.text = Uri.decodeComponent(
                                data[widget.advancedHeaders![0].key]);
                          } catch (_) {
                            widget.controller.text =
                                data[widget.advancedHeaders![0].key];
                          }
                          widget.onSubmit(pk);
                        });
                        Navigator.pop(context);
                      },
                      data: widget.data,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return SizedBox(
      width: widget.width,
      height: 48,
      child: StorybridgeTile(
        child: InkWell(
          hoverColor: Colors.transparent,
          onTap: widget.isEnabled
              ? () {
                  _showPicker();
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                const SizedBox(width: 10),
                StorybridgeTextP(widget.controller.text),
                Expanded(child: Container()),
                StorybridgeIconButton(
                  icon: Icons.arrow_drop_down,
                  onPressed: widget.isEnabled
                      ? () {
                          _showPicker();
                        }
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StorybridgeRow extends StatelessWidget {
  // members of MyWidget
  final Widget child;
  final bool useAltStyle;

  // constructor
  const _StorybridgeRow(
      {Key? key, required this.child, required this.useAltStyle})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: !useAltStyle
          ? null
          : BoxDecoration(
              border: Border(
                top: BorderSide(width: 1, color: storybridge_color.borderColor),
              ),
            ),
      child: SizedBox(
        height: 50,
        child: child,
      ),
    );
  }
}
