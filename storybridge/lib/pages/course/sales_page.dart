import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/error_service.dart' as error_service;
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

// myPage class which creates a state on call
class CourseSalesPage extends StatefulWidget {
  final int courseId;
  const CourseSalesPage({required this.courseId, Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<CourseSalesPage> {
  int _selectedPage = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  final ScholarityTabPageController _tabPageController =
      ScholarityTabPageController();
  // main build function
  @override
  Widget build(BuildContext context) {
    return ScholarityTabPage(tabPageController: _tabPageController, sideBar: [
      const SizedBox(height: 80),
      ScholaritySideBarButton(
          label: "Sales Page",
          icon: Icons.shopping_cart_rounded,
          onPressed: () {
            // hide mobile sidebar
            _tabPageController.mobileShowSidebar = false;
            _tabPageController.update();

            setState(() {
              _selectedPage = 0;
            });
          },
          selected: _selectedPage == 0),
      ScholaritySideBarButton(
          label: "Sales History",
          icon: Icons.paid_rounded,
          onPressed: () {
            // hide mobile sidebar
            _tabPageController.mobileShowSidebar = false;
            _tabPageController.update();

            setState(() {
              _selectedPage = 1;
            });
          },
          selected: _selectedPage == 1),
      ScholaritySideBarButton(
          label: "Balance",
          icon: Icons.money_rounded,
          onPressed: () {
            // hide mobile sidebar
            _tabPageController.mobileShowSidebar = false;
            _tabPageController.update();

            setState(() {
              _selectedPage = 2;
            });
          },
          selected: _selectedPage == 2)
    ], body: [
      Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: Builder(builder: (context) {
          switch (_selectedPage) {
            case 0:
              return CourseSalesGeneralPage(courseId: widget.courseId);
            case 1:
              return CourseSalesHistoryPage(courseId: widget.courseId);
            case 2:
              return CourseSalesBalancePage(courseId: widget.courseId);
          }
          return Container();
        }),
      )
    ]);
  }
}

// myPage class which creates a state on call
class CourseSalesGeneralPage extends StatefulWidget {
  final int courseId;
  const CourseSalesGeneralPage({Key? key, required this.courseId})
      : super(key: key);

  @override
  _CourseSalesGeneralPageState createState() => _CourseSalesGeneralPageState();
}

// myPage state
class _CourseSalesGeneralPageState extends State<CourseSalesGeneralPage> {
  final PriceSelectorController _priceSelectorController =
      PriceSelectorController();
  String _courseProductName = "";
  String _courseProductDescription = "";
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _load() async {
    Map<String, dynamic> response = await networking_api_service
        .getCourseSalesSettings(courseId: widget.courseId);
    _priceSelectorController.price =
        (response["data"]["coursePrice"] / 100) ?? 0;
    _priceSelectorController.currencyCode =
        response["data"]["coursePriceCurrencyCode"] ?? "";
    _courseProductName = response["data"]["courseProductName"];
    _courseProductDescription = response["data"]["courseProductDescription"];
    return true;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    error_service.checkAlerts(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ScholarityTextH2("Sales"),
        const SizedBox(height: 40),
        FutureBuilder(
            future: _load(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ScholarityDescriptor(
                          name: "Course Price",
                          description:
                              "The total price your students have to pay to access your story."),
                      PriceSelector(
                        controller: _priceSelectorController,
                        courseId: widget.courseId,
                        showFreeCourseWarning: true,
                        onSubmit: () async {
                          await networking_api_service
                              .changeCourseSalesSettings(
                                  courseId: widget.courseId,
                                  coursePrice:
                                      (_priceSelectorController.price * 100)
                                          .round(),
                                  coursePriceCurrencyCode:
                                      _priceSelectorController.currencyCode
                                          .toLowerCase());
                        },
                      ),
                      const SizedBox(height: 20),
                      const _FeeWarning(),
                      const SizedBox(height: 20),
                      const ScholarityDescriptor(
                          name: "Payment Page - Product Name",
                          description:
                              "This is the name of your course your students will see in the payment page."),
                      ScholaritySettingButton(
                          loadValue: () async {
                            return _courseProductName;
                          },
                          saveValue: (String value) async {
                            await networking_api_service
                                .changeCourseSalesSettings(
                              courseId: widget.courseId,
                              courseProductName: value,
                            );
                          },
                          name: "Payment Page - Product Name"),
                      const ScholarityDescriptor(
                          name: "Payment Page - Product Description",
                          description:
                              "This is the description your students will see in the payment page."),
                      ScholaritySettingButton(
                          isLarge: true,
                          loadValue: () async {
                            return _courseProductDescription;
                          },
                          saveValue: (String value) async {
                            await networking_api_service
                                .changeCourseSalesSettings(
                              courseId: widget.courseId,
                              courseProductDescription: value,
                            );
                          },
                          name: "Payment Page - Product Description"),
                    ]);
              } else {
                return const ScholarityPageLoading();
              }
            }),
      ],
    );
  }
}

class _FeeWarning extends StatelessWidget {
  // constructor
  const _FeeWarning({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return ScholarityTile(
        child: ScholarityPadding(
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.info_rounded),
            SizedBox(width: 10),
            ScholarityTextH2B("Taxes & Stripe Processing Fees"),
          ],
        ),
        const SizedBox(height: 5),
        const ScholarityTextP(
            "As Scholarity partners with Stripe for secure payment processing, just like our competitors, you will be subject to taxes, Stripe's processing fees, and Stripe's currency conversion fees (to Thai Baht). Scholarity takes no transaction fees on top of that."),
        const SizedBox(height: 15),
        InkWell(
            onTap: () {
              launchUrl(Uri.parse("https://stripe.com/en-th/pricing"));
            },
            child: ScholarityTextBasic("Learn More",
                style: scholarityTextPLinkStyle))
      ],
    )));
  }
}

class _SalesHistoryEntry {
  String email = "";
  String dateCreated = "";
  double paidAmount = 0;
  double paidNet = 0;
  String paidCurrencyCode = "";
}

// myPage class which creates a state on call
class CourseSalesHistoryPage extends StatefulWidget {
  final int courseId;
  const CourseSalesHistoryPage({Key? key, required this.courseId})
      : super(key: key);

  @override
  _CourseSalesHistoryPageState createState() => _CourseSalesHistoryPageState();
}

// myPage state
class _CourseSalesHistoryPageState extends State<CourseSalesHistoryPage> {
  final List<_SalesHistoryEntry> _salesHistoryEntries = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _load() async {
    Map<String, dynamic> response = await networking_api_service
        .getCourseSalesHistory(courseId: widget.courseId);
    _salesHistoryEntries.clear();
    List<dynamic> data = response["data"];
    for (var entryData in data) {
      _SalesHistoryEntry entry = _SalesHistoryEntry();
      entry.email = entryData["email"];
      entry.dateCreated = entryData["dateCreated"];
      entry.paidAmount = entryData["paidAmount"] / 100;
      entry.paidNet = entryData["paidNet"] / 100;
      entry.paidCurrencyCode = entryData["paidCurrencyCode"];
      _salesHistoryEntries.add(entry);
    }
    return true;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    error_service.checkAlerts(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ScholarityTextH2("Sales History"),
        const SizedBox(height: 40),
        FutureBuilder(
            future: _load(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 22),
                      child: Row(children: [
                        Expanded(child: ScholarityTextH2B("Customer")),
                        Expanded(child: ScholarityTextH2B("Date")),
                        Row(
                          children: [
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: ScholarityTextH2B("Amount")),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    ScholarityTextH2B("Fees"),
                                    SizedBox(width: 2),
                                    Tooltip(
                                        message:
                                            "Taxes & Stripe processing fees.\nScholarity takes 0% transaction cost on top.\nLearn more at https://stripe.com/en-th/pricing.",
                                        child: Icon(Icons.info_rounded,
                                            color: Colors.grey))
                                  ],
                                )),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: ScholarityTextH2B("Net"),
                            ),
                          ],
                        ),
                      ]),
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            List.generate(_salesHistoryEntries.length, (int i) {
                          return _CourseSalesHistoryEntryWidget(
                              salesHistoryEntry: _salesHistoryEntries[i]);
                        })),
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

class _CourseSalesHistoryEntryWidget extends StatelessWidget {
  // members of MyWidget
  final _SalesHistoryEntry salesHistoryEntry;

  // constructor
  const _CourseSalesHistoryEntryWidget(
      {Key? key, required this.salesHistoryEntry})
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
          Expanded(child: ScholarityTextP(salesHistoryEntry.email)),
          Expanded(
              child:
                  ScholarityTextP(parseSqlDate(salesHistoryEntry.dateCreated))),
          Row(
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ScholarityTextP(
                      "${salesHistoryEntry.paidCurrencyCode.toUpperCase()} ${numberFormat.format(salesHistoryEntry.paidAmount)}")),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ScholarityTextP(
                      "${salesHistoryEntry.paidCurrencyCode.toUpperCase()} ${numberFormat.format(salesHistoryEntry.paidAmount - salesHistoryEntry.paidNet)}")),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ScholarityTextP(
                      "${salesHistoryEntry.paidCurrencyCode.toUpperCase()} ${salesHistoryEntry.paidNet}")),
            ],
          ),
        ],
      ))),
    );
  }
}

// myPage class which creates a state on call
class CourseSalesBalancePage extends StatefulWidget {
  final int courseId;
  const CourseSalesBalancePage({Key? key, required this.courseId})
      : super(key: key);

  @override
  _CourseSalesBalancePageState createState() => _CourseSalesBalancePageState();
}

// myPage state
class _CourseSalesBalancePageState extends State<CourseSalesBalancePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    error_service.checkAlerts(context);
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScholarityTextH2("Balance"),
        SizedBox(height: 40),
        ScholarityTextP("Please see organization page for the balance.")
      ],
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

String parseSqlDate(String date) {
  List<String> dateSplit = date.split("-");
  String year = dateSplit[0];
  String month = monthHash[dateSplit[1]]!;
  String day = dateSplit[2].substring(0, 2);
  return "$month $day, $year";
}
