import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/style/scholarity_colors.dart' as scholarity_color;
import 'package:mooc/services/translation_service.dart' as translation_service;

import 'package:excel/excel.dart' as excl;
import 'package:fuzzywuzzy/fuzzywuzzy.dart';

enum ScholarityTableHeaderType {
  text,
  dropdown,
  datetime,
  label,
  boolean,
  color
}

class ScholarityTableHeader {
  String key, label;
  double width;
  ScholarityTableHeaderType type;
  List<String>? dropdownList;
  Map<String, dynamic>? labelData;
  ScholarityTableHeader(
      {required this.key,
      required this.label,
      this.labelData,
      this.width = 190,
      this.type = ScholarityTableHeaderType.text,
      this.dropdownList}) {
    if (type == ScholarityTableHeaderType) {
      print("warning: dropdownList must be defined for ScholarityTableHeaders");
    }
  }
}

class ScholarityTable extends StatefulWidget {
  final List<dynamic> data;
  final List<String>? displayHeaders;
  final List<ScholarityTableHeader>? advancedHeaders;
  final String? pkName; // private key for table
  final void Function(dynamic pk, dynamic data, int index)? onEdit;
  final void Function(dynamic pk, dynamic data, int index)? onDelete;
  final void Function(dynamic pk, dynamic data, int index)? onView;
  final bool initiallyOpenSearch;
  final bool canSearch;
  final List<ScholarityTableButton>? extraButtons;
  final int maxItemsPerPage;
  final bool useAltStyle;
  const ScholarityTable({
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
  State<ScholarityTable> createState() => _ScholarityTableState();
}

class _ScholarityTableState extends State<ScholarityTable> {
  final List<ScholarityTableHeader> _headers = [];
  final List<String> _strHeaders = [];
  final Map<String, String> _labelsToKeys = {};
  bool _showSearchPage = false;
  int _page = 0;
  List<dynamic> _data = [];
  final ScholarityTextFieldController _searchController =
      ScholarityTextFieldController();
  final ScholarityTextFieldController _searchCategoryController =
      ScholarityTextFieldController();

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
      for (ScholarityTableHeader header in widget.advancedHeaders!) {
        _headers.add(header);
      }
      _getStringHeaders();
      return;
    }
    if (widget.displayHeaders != null) {
      for (String header in widget.displayHeaders!) {
        _headers.add(ScholarityTableHeader(
            key: header, label: header, type: ScholarityTableHeaderType.text));
      }
      _getStringHeaders();
      return;
    }

    for (Map<String, dynamic> obj in widget.data) {
      for (String key in obj.keys) {
        bool doesHeaderContainKey = false;
        for (ScholarityTableHeader h in _headers) {
          if (h.key == key) {
            doesHeaderContainKey = true;
          }
        }
        if (!doesHeaderContainKey) {
          _headers.add(ScholarityTableHeader(
              key: key, label: key, type: ScholarityTableHeaderType.text));
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
    excel.save(fileName: 'ScholarityDataDownload.xlsx');
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

  Widget _getCellWidget(dynamic cellData, ScholarityTableHeader header) {
    if (cellData != null) {
      switch (header.type) {
        case ScholarityTableHeaderType.boolean:
          String? cellString = cellData?.toString();
          if (cellString == "{type: Buffer, data: [1]}") {
            return Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.check_rounded,
                color: scholarity_color.black,
              ),
            );
          } else if (cellString == "{type: Buffer, data: [0]}") {
            return Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.close_rounded,
                color: scholarity_color.black,
              ),
            );
          } else {
            print("wrong data type for table.");
          }
          break;
        case ScholarityTableHeaderType.text:
        case ScholarityTableHeaderType.dropdown:
          String cellString;
          try {
            cellString = Uri.decodeComponent(cellData!.toString());
          } catch (_) {
            cellString = cellData;
          }
          return _ScholarityCell(
              useAltStyle: widget.useAltStyle,
              width: header.width,
              child: IntrinsicWidth(
                child: ScholarityTextP(cellString),
              ));

        case ScholarityTableHeaderType.datetime:
          DateTime? datetime = parseSqlDatetime(cellData?.toString());
          if (datetime != null) {
            return _ScholarityCell(
                useAltStyle: widget.useAltStyle,
                width: header.width,
                child: IntrinsicWidth(
                  child: ScholarityTextP(translation_service.getDate(datetime)),
                ));
          }
          break;
        case ScholarityTableHeaderType.label:
          return ScholarityLabels(
            selectedLabels: cellData,
            canEdit: true,
          );
        case ScholarityTableHeaderType.color:
          try {
            return _ScholarityCell(
                useAltStyle: widget.useAltStyle,
                width: header.width,
                child: IntrinsicWidth(
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: scholarity_color.borderColor),
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
        child: Divider(color: scholarity_color.borderColor),
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
        child: const ScholarityTextBasic('View'),
      ));
    }
    if (widget.onEdit != null) {
      output.add(PopupMenuItem(
        onTap: () {
          setState(() {
            showDialog<String>(
                context: context,
                builder: (BuildContext context) => ScholarityAlertDialogWrapper(
                      child: ScholarityAlertDialog(
                        content: _ScholarityCellEditForm(
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
        child: const ScholarityTextBasic('Edit'),
      ));
    }
    if (widget.extraButtons != null) {
      for (int j = 0; j < widget.extraButtons!.length; j++) {
        ScholarityTableButton button = widget.extraButtons![j];
        output.add(PopupMenuItem(
          onTap: () {
            String key = widget.pkName ?? _data[0].keys.toList().first;
            var id = _data[index][key];
            button.onPressed(id, _data[index]);
          },
          child: ScholarityTextBasic(button.buttonText),
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
        child: const ScholarityTextBasic('Delete',
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
            ? _ScholarityTableSearchWidget(
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
                    child: ScholarityIconButton(
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
              child: ScholarityIconButton(
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
                          child: ScholarityIconButton(
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
                          child: ScholarityIconButton(
                            icon: Icons.arrow_back_rounded,
                            onPressed: (_page > 0)
                                ? () {
                                    _prevPage();
                                  }
                                : null,
                          ),
                        ),
                        ScholarityTextP(
                            "Page ${_page + 1} of ${(_data.length / widget.maxItemsPerPage).ceil()}"),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: ScholarityIconButton(
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
                          child: ScholarityIconButton(
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
                                      child:
                                          ScholarityTextH2B(_headers[i].label));
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
                                    child: _ScholarityRow(
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
                                                          ScholarityIconButton(
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
                            scholarity_color.backgroundTransparent,
                            scholarity_color.background,
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
                              scholarity_color.backgroundTransparent,
                              scholarity_color.background,
                            ], // Gradient from https://learnui.design/tools/gradient-generator.html
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const _ScholarityTableEmptyWidget(),
      ],
    );
  }
}

class _ScholarityTableEmptyWidget extends StatelessWidget {
  // constructor
  const _ScholarityTableEmptyWidget({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return ScholarityTile(
      child: SizedBox(
        height: 300,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied_rounded,
                size: 40, color: scholarity_color.lightGrey),
            const SizedBox(
              width: 10,
            ),
            const ScholarityTextP("This table is empty!"),
          ],
        ),
      ),
    );
  }
}

class ScholarityTableButton {
  // members of MyWidget
  final String buttonText;
  final Function(dynamic pk, dynamic data) onPressed;
  ScholarityTableButton({required this.buttonText, required this.onPressed});
}

class _ScholarityCell extends StatelessWidget {
  // members of MyWidget
  final Widget child;
  final double width;
  final bool useAltStyle;

  // constructor
  const _ScholarityCell(
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
            return ScholarityTile(
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

class _ScholarityCellEditForm extends StatelessWidget {
  final List<ScholarityTextFieldController> _controllers = [];

  final void Function() onSave;
  final Map<String, dynamic> data;
  final List<ScholarityTableHeader> headers;
  // constructor
  _ScholarityCellEditForm(
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
      _controllers.add(ScholarityTextFieldController());
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
            const ScholarityTextH2B("Edit Object"),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(headers.length, (int i) {
                switch (headers[i].type) {
                  case ScholarityTableHeaderType.text:
                    return ScholarityTextField(
                      label: headers[i].label,
                      controller: _controllers[i],
                    );
                  case ScholarityTableHeaderType.dropdown:
                    return ScholarityDropdown(
                      label: headers[i].label,
                      controller: _controllers[i],
                      dropdownTypes: headers[i].dropdownList ?? [],
                    );
                  case ScholarityTableHeaderType.datetime:
                    // TODO: make this editable
                    return ScholarityTextP(
                      _controllers[i].text,
                    );
                  case ScholarityTableHeaderType.label:
                    return Container(); // TODO
                  case ScholarityTableHeaderType.boolean:
                    return Container(); // TODO
                  case ScholarityTableHeaderType.color:
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScholarityTextH2B(headers[i].label),
                        ScholarityColorPicker(controller: _controllers[i]),
                        const SizedBox(height: 30),
                      ],
                    ); // TODO
                }
              }),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ScholarityButton(
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
                ScholarityButton(
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

class _ScholarityTableSearchWidget extends StatelessWidget {
  // members of MyWidget
  final ScholarityTextFieldController searchController;
  final ScholarityTextFieldController searchCategoryController;
  final List<String> strHeaders;

  // constructor
  const _ScholarityTableSearchWidget(
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
            child: ScholarityTextField(
              label: "Search",
              isConstricted: true,
              controller: searchController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ScholarityDropdown(
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

class ScholarityTableDropdown extends StatefulWidget {
  final List<dynamic> data;
  final List<ScholarityTableHeader>? advancedHeaders;
  final bool isEnabled;
  final double width;
  final ScholarityTextFieldController controller;
  final void Function(dynamic pk) onSubmit;
  const ScholarityTableDropdown(
      {Key? key,
      required this.data,
      required this.advancedHeaders,
      this.isEnabled = true,
      this.width = 200,
      required this.onSubmit,
      required this.controller})
      : super(key: key);

  @override
  _ScholarityTableDropdownState createState() =>
      _ScholarityTableDropdownState();
}

// myPage state
class _ScholarityTableDropdownState extends State<ScholarityTableDropdown> {
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
        builder: (BuildContext context) => ScholarityAlertDialogWrapper(
          child: ScholarityAlertDialog(
            content: SizedBox(
              width: 700,
              height: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ScholarityTable(
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
      child: ScholarityTile(
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
                ScholarityTextP(widget.controller.text),
                Expanded(child: Container()),
                ScholarityIconButton(
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

class _ScholarityRow extends StatelessWidget {
  // members of MyWidget
  final Widget child;
  final bool useAltStyle;

  // constructor
  const _ScholarityRow(
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
                top: BorderSide(width: 1, color: scholarity_color.borderColor),
              ),
            ),
      child: SizedBox(
        height: 50,
        child: child,
      ),
    );
  }
}
