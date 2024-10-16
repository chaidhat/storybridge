import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/services/error_service.dart' as error_service;

List<_Currency> GLOBAL_CURRENCIES = [];

class _Currency {
  final String currencyCode;
  final String currencyFullName;
  const _Currency({required this.currencyCode, required this.currencyFullName});
}

Future<void> _populateGlobalCurrencies() async {
  // reset global currencies
  GLOBAL_CURRENCIES = [];

  // load all currencies
  final String currencies =
      await rootBundle.loadString('assets/currencies.json');
  final Map<String, dynamic> currenciesData = await json.decode(currencies);

  // to recreate this list, uncomment the code in server/payments.js and run it and copy paste the console log.
  final String supportedStripeCurrencies =
      await rootBundle.loadString('assets/supported-stripe-currencies.json');
  final List<dynamic> supportedStripeCurrenciesData =
      await json.decode(supportedStripeCurrencies);

  // only choose currencies in currencies.json which are listed in the supported stripe currencies
  for (var currencyCode in currenciesData.keys) {
    if (supportedStripeCurrenciesData.contains(currencyCode.toLowerCase())) {
      GLOBAL_CURRENCIES.add(_Currency(
          currencyCode: currencyCode.toUpperCase(),
          currencyFullName: "${currencyCode.toUpperCase()} - " +
              currenciesData[currencyCode]["name"]));
    }
  }
}

class PriceSelectorController {
  double price = 0;
  String currencyCode = "";
}

// myPage class which creates a state on call
class PriceSelector extends StatefulWidget {
  final int courseId;
  final PriceSelectorController controller;
  final bool showFreeCourseWarning;
  final Function() onSubmit;
  const PriceSelector(
      {Key? key,
      required this.courseId,
      required this.controller,
      required this.showFreeCourseWarning,
      required this.onSubmit})
      : super(key: key);

  @override
  _PriceSelectorState createState() => _PriceSelectorState();
}

// myPage state
class _PriceSelectorState extends State<PriceSelector> {
  ScholarityTextFieldController pricingController =
      ScholarityTextFieldController();
  ScholarityTextFieldController currencyController =
      ScholarityTextFieldController();
  double price = 0;

  @override
  void initState() {
    price = widget.controller.price;
    pricingController.text =
        ((price * 100).roundToDouble() / 100).toStringAsFixed(2);
    currencyController.text = "";
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<String>> _loadData() async {
    if (GLOBAL_CURRENCIES.isEmpty) {
      await _populateGlobalCurrencies();
    }
    List<String> entries = [];
    for (int i = 0; i < GLOBAL_CURRENCIES.length; i++) {
      entries.add(GLOBAL_CURRENCIES[i].currencyFullName);
      if (GLOBAL_CURRENCIES[i].currencyCode ==
              widget.controller.currencyCode.toUpperCase() &&
          currencyController.text == "") {
        currencyController.text = GLOBAL_CURRENCIES[i].currencyFullName;
      }
    }
    return entries;
  }

  bool _validate() {
    try {
      price = double.parse(pricingController.text);
      if (price < 0) {
        setState(() {
          pricingController.errorText = "Price must not be negative.";
        });
      } else {
        // passed
        pricingController.text =
            ((price * 100).roundToDouble() / 100).toStringAsFixed(2);
        setState(() {
          pricingController.clearError();
          currencyController.clearError();
        });
        return true;
      }
    } catch (_) {
      setState(() {
        pricingController.errorText = "Price must be a number";
      });
    }
    return false;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 300,
          child: Focus(
            onFocusChange: (bool isFocused) {
              setState(() {
                if (!isFocused) {
                  _validate();
                }
              });
            },
            child: ScholarityTextField(
              label: "Price",
              controller: pricingController,
            ),
          ),
        ),
        price != 0 || !widget.showFreeCourseWarning
            ? Container()
            : const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: _FreeCourseWarning(),
              ),
        FutureBuilder(
            future: _loadData(),
            builder:
                (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              if (snapshot.hasData) {
                return ScholarityDropdown(
                  label: "Currency",
                  controller: currencyController,
                  dropdownTypes: snapshot.data!,
                );
              } else {
                return const ScholarityBoxLoading(width: 100, height: 30);
              }
            }),
        const SizedBox(height: 20),
        ScholarityButton(
          text: "Save Price",
          onPressed: () async {
            if (_validate()) {
              widget.controller.price = price;
              if (currencyController.text == "") {
                setState(() {
                  pricingController.errorText = "Please select currency.";
                });
                return;
              }
              for (int i = 0; i < GLOBAL_CURRENCIES.length; i++) {
                if (currencyController.text ==
                    GLOBAL_CURRENCIES[i].currencyFullName) {
                  widget.controller.currencyCode =
                      GLOBAL_CURRENCIES[i].currencyCode;
                }
              }
              try {
                await widget.onSubmit();
              } on error_service.ScholarityException catch (err) {
                switch (err.message) {
                  case "course price too low":
                    setState(() {
                      pricingController.errorText =
                          "Price cannot be below USD 1 and not free.";
                    });
                    break;
                  case "course price too high":
                    setState(() {
                      pricingController.errorText =
                          "Price cannot exceed USD 999 - Contact Sales.";
                    });
                    break;
                  default:
                    setState(() {
                      pricingController.errorText =
                          "An error occured whilst saving";
                    });
                    break;
                }
              }
            }
          },
        ),
      ],
    );
  }
}

class _FreeCourseWarning extends StatelessWidget {
  // constructor
  const _FreeCourseWarning({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return const ScholarityTile(
        child: ScholarityPadding(
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_rounded),
            SizedBox(width: 10),
            ScholarityTextH2B("Price is Zero"),
          ],
        ),
        SizedBox(height: 5),
        ScholarityTextP(
            "Students can enroll and access the course without paying."),
      ],
    )));
  }
}
