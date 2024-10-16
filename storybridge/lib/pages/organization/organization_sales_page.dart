import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/pages/course/course_grades_page.dart';

import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:intl/intl.dart';

class OrganizationSalesPage extends StatefulWidget {
  final int organizationId;
  const OrganizationSalesPage({Key? key, required this.organizationId})
      : super(key: key);

  @override
  _OrganizationSalesPageState createState() => _OrganizationSalesPageState();
}

// myPage state
class _OrganizationSalesPageState extends State<OrganizationSalesPage> {
  final Map<String, dynamic> _salesData = {};
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _loadSalesData() async {
    _salesData.clear();
    Map<String, dynamic> response = await networking_api_service
        .getOrganizationBalance(organizationId: widget.organizationId);
    // copy the response
    _salesData.addAll(response["data"]);
    return true;
  }

  Future<dynamic> _loadWithdrawals() async {
    Map<String, dynamic> response = await networking_api_service.getWithdrawals(
        organizationId: widget.organizationId);
    // copy the response
    return response["data"];
  }

  void _requestWithdrawal() async {
    if (_salesData["netBalance"]?.length != 0) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => ScholarityAlertDialogWrapper(
          child: ScholarityAlertDialog(
            content: _WithdrawalForm(organizationId: widget.organizationId),
          ),
        ),
      );
    } else {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => ScholarityAlertDialogWrapper(
          child: ScholarityAlertDialog(
            content: _WithdrawalInsufficientFundsForm(),
          ),
        ),
      );
    }
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    NumberFormat numberFormat = NumberFormat.decimalPattern('hi');
    return ScholarityTabPage(
      body: [
        const SizedBox(height: 40),
        FutureBuilder(
            future: _loadSalesData(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ScholarityTextH2B("Balance"),
                    const ScholarityTextP(
                        "Start selling your courses by creating a course and going to the 'Sales' page. All net revenue from your students are aggregated here in your balance where you can withdraw the funds to your bank account whenever."),
                    const SizedBox(height: 20),
                    ScholarityTile(
                        child: ScholarityPadding(
                            child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ScholarityTextP("Your Balance"),
                        FutureBuilder(
                            future: _loadSalesData(),
                            builder: (BuildContext context,
                                AsyncSnapshot<bool> snapshot) {
                              if (snapshot.hasData) {
                                List<Widget> output = [];
                                Map netRevenue = _salesData["netBalance"];
                                netRevenue.forEach((key, value) {
                                  output.add(Row(children: [
                                    ScholarityTextH2(key.toUpperCase()),
                                    const SizedBox(width: 20),
                                    ScholarityTextH2(
                                        numberFormat.format(value / 100)),
                                  ]));
                                });
                                if (output.length != 0) {
                                  return Column(children: output);
                                } else {
                                  return const ScholarityTextH2("\$0");
                                }
                              } else {
                                return const ScholarityBoxLoading(
                                  width: 50,
                                  height: 50,
                                );
                              }
                            }),
                      ],
                    ))),
                    const SizedBox(height: 20),
                    ScholarityButton(
                      padding: false,
                      text: "Withdraw to Bank Account",
                      onPressed: _requestWithdrawal,
                    ),
                    const SizedBox(height: 5),
                    const ScholarityTextP(
                        "Note: We may take 1-3 business days to process your withdrawal."),
                    const SizedBox(height: 60),
                    const ScholarityTextH2B("Withdrawal History"),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        children: [
                          Expanded(child: ScholarityTextH2B("Date Requested")),
                          Expanded(child: ScholarityTextH2B("Date Paid Out")),
                          Expanded(child: ScholarityTextH2B("Amount")),
                          SizedBox(width: 30, child: ScholarityTextH2B("ID")),
                        ],
                      ),
                    ),
                    FutureBuilder(
                        future: _loadWithdrawals(),
                        builder: (BuildContext context,
                            AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data!.length == 0) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: ScholarityTextP(
                                    "You haven't withdrawn any funds from your account"),
                              );
                            }
                            return Column(
                                children: List.generate(snapshot.data!.length,
                                    (int index) {
                              return _OrganizationSalesWithdrawalEntryWidget(
                                dateRequested: snapshot.data![index]
                                    ["dateRequested"],
                                datePaidOut: snapshot.data![index]
                                    ["datePaidOut"],
                                withdrawalId: snapshot.data![index]
                                    ["withdrawalId"],
                                withdrawalAmount: snapshot.data![index]
                                    ["netWithdrawn"],
                              );
                            }));
                          } else {
                            return const ScholarityBoxLoading(
                              width: 100,
                              height: 50,
                            );
                          }
                        }),
                    /*
                    const SizedBox(height: 60),
                    const ScholarityTextH2B("Sales data"),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ScholarityTile(
                              child: ScholarityPadding(
                                  child: Column(
                            children: [
                              ScholarityTextP("Net Volume from Sales"),
                              ScholarityTextH4("\$50"),
                            ],
                          ))),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: ScholarityTile(
                              child: ScholarityPadding(
                                  child: Column(
                            children: [
                              ScholarityTextP("Gross Volume"),
                              ScholarityTextH4("\$12"),
                            ],
                          ))),
                        ),
                      ],
                    ),
                    */
                  ],
                );
              } else {
                return const ScholarityPageLoading();
              }
            }),
      ],
    );
  }
}

class _OrganizationSalesWithdrawalEntryWidget extends StatelessWidget {
  // members of MyWidget
  final String dateRequested;
  final String? datePaidOut;
  final int withdrawalId;
  final Map withdrawalAmount;

  // constructor
  const _OrganizationSalesWithdrawalEntryWidget(
      {Key? key,
      required this.dateRequested,
      required this.datePaidOut,
      required this.withdrawalId,
      required this.withdrawalAmount})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    NumberFormat numberFormat = NumberFormat.decimalPattern('hi');
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ScholarityTile(
          child: ScholarityPadding(
              child: Row(
        children: [
          Expanded(child: ScholarityTextP(parseSqlDate(dateRequested))),
          Expanded(
              child: datePaidOut != null
                  ? ScholarityTextP(parseSqlDate(datePaidOut!))
                  : const Tooltip(
                      message:
                          "We may take 1-3 business days to process a withdrawal. Please expect an email from us.",
                      child: Row(
                        children: [
                          Icon(Icons.watch_later_rounded),
                          SizedBox(width: 5),
                          ScholarityTextP("Processing"),
                        ],
                      ),
                    )),
          Expanded(child: Builder(builder: (context) {
            List<Widget> output = [];
            withdrawalAmount.forEach((key, value) {
              output.add(Row(children: [
                ScholarityTextP(
                    "${key.toUpperCase()} ${numberFormat.format(value / 100)}"),
              ]));
            });
            return Column(children: output);
          })),
          SizedBox(width: 30, child: ScholarityTextP(withdrawalId.toString())),
        ],
      ))),
    );
  }
}

// myPage class which creates a state on call
class _WithdrawalForm extends StatelessWidget {
  final int organizationId;
  // constructor
  _WithdrawalForm({Key? key, required this.organizationId}) : super(key: key);

  final ScholarityTextFieldController _contactEmailController =
      ScholarityTextFieldController();
  final ScholarityTextFieldController _accountTypeController =
      ScholarityTextFieldController();

  // main build function
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScholarityIconButton(
                icon: Icons.close,
                onPressed: () {
                  Navigator.pop(context);
                }),
            const SizedBox(height: 10),
            const ScholarityTextH4("Withdraw to Bank Account"),
            const SizedBox(height: 20),
            const ScholarityDescriptor(
                name: "Contact Email",
                description:
                    "Our sales representative will contact you via this email within 1-3 business days to process your withdrawal."),
            ScholarityTextField(
                controller: _contactEmailController, label: "contact email"),
            const ScholarityDescriptor(
                name: "Account Type",
                description:
                    "Please select your account type to receive the payment."),
            ScholarityDropdown(
                label: "type",
                controller: _accountTypeController,
                dropdownTypes: const [
                  "PayPal",
                  "PromptPay",
                  "Wire Transfer",
                  "Other"
                ]),
            const SizedBox(height: 40),
            ScholarityButton(
              invertedColor: true,
              padding: false,
              text: "Send",
              onPressed: () async {
                Map<String, String> withdrawalData = {
                  "contactEmail": _contactEmailController.text,
                  "accountType": _accountTypeController.text,
                };
                await networking_api_service.createWithdrawal(
                    organizationId: organizationId,
                    withdrawalData: jsonEncode(withdrawalData));
                Navigator.pushNamed(context, "/reload");
              },
            ),
            const SizedBox(height: 5),
            const ScholarityTextP(
                "Note: We may take 1-3 business days to process your withdrawal."),
          ],
        ),
      ),
    );
  }
}

class _WithdrawalInsufficientFundsForm extends StatelessWidget {
  // constructor
  const _WithdrawalInsufficientFundsForm({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScholarityIconButton(
                icon: Icons.close,
                onPressed: () {
                  Navigator.pop(context);
                }),
            const SizedBox(height: 10),
            const ScholarityTextH2B("No funds to be withdrawn."),
            const ScholarityTextP(
                "There are no funds which can be withdrawn to your bank account as your balance is \$0. Your net profit will start to show up here after students have bought your course. If you previously requested a withdrawal, this could mean it has been processed successfully and the funds have been sent to your bank account.\n\nIf you believe this is mistaken, please contact us immediately at contact@scholarity.io."),
          ],
        ),
      ),
    );
  }
}

class _WithdrawalDuplicateForm extends StatelessWidget {
  // constructor
  const _WithdrawalDuplicateForm({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScholarityIconButton(
                icon: Icons.close,
                onPressed: () {
                  Navigator.pop(context);
                }),
            const SizedBox(height: 10),
            const ScholarityTextH2B("There is already a pending withdrawal."),
            const ScholarityTextP(
                "You cannot perform more than one withdrawal."),
          ],
        ),
      ),
    );
  }
}

const Map<String, String> monthHash = {
  "01": "January",
  "02": "February",
  "03": "March",
  "04": "April",
  "05": "May",
  "06": "June",
  "07": "July",
  "08": "August",
  "09": "September",
  "10": "October",
  "11": "November",
  "12": "December",
};
