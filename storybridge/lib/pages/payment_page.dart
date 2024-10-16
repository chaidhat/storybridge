import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/payment_service.dart' as payment_service;
import 'package:mooc/services/auth_service.dart' as auth_service;
import 'package:url_launcher/url_launcher.dart';

// myPage class which creates a state on call
class PaymentCheckoutPage extends StatefulWidget {
  final int plan;
  const PaymentCheckoutPage({Key? key, required this.plan}) : super(key: key);

  @override
  _PaymentCheckoutPageState createState() => _PaymentCheckoutPageState();
}

class _OrganizationData {
  String organizationName;
  String? checkoutUrl;
  int organizationId;
  bool alreadyHasSubscription;
  _OrganizationData({
    required this.organizationName,
    required this.checkoutUrl,
    required this.organizationId,
    required this.alreadyHasSubscription,
  });
}

// myPage state
class _PaymentCheckoutPageState extends State<PaymentCheckoutPage> {
  final List<_OrganizationData> _organizations = [];
  Future<bool> _loadData() async {
    await Future.delayed(const Duration(seconds: 2));
    // TODO: make a better version of this
    // this finds the user's default organization
    // this is copied from course_service.sendToOrg()
    //int organizationId;
    // check if user is initially assigned to organization (has orgId already)
    bool isUserInitiallyAssignedToOrg = false;
    auth_service.AuthUserData? userData =
        auth_service.globalUser.getAuthUserData();
    if (userData != null) {
      isUserInitiallyAssignedToOrg = userData.organizationId != 0;
    }
    _organizations.clear();

    if (isUserInitiallyAssignedToOrg) {
      // if user is initally assigned, then go to that organization
      //organizationId = userData!.organizationId;
      return true;
    } else {
      // find first organizationId, if user has no organization, then go to register
      Map<String, dynamic> response =
          await networking_api_service.getOrganizations();
      // bring to create a new organization
      if (response["data"].length == 0) {
        // user does not have any organizations
        return true;
      } else {
        for (int i = 0; i < response["data"].length; i++) {
          String? checkoutUrl = await payment_service.getPaymentCheckoutUrl(
              organizationId: response["data"][i]["organizationId"],
              plan: payment_service.PaymentTier.values[widget.plan]);
          _organizations.add(_OrganizationData(
              organizationName:
                  Uri.decodeComponent(response["data"][i]["organizationName"]),
              organizationId: response["data"][i]["organizationId"],
              alreadyHasSubscription: checkoutUrl == null,
              checkoutUrl: checkoutUrl));
        }
      }
    }
    return true;
  }

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
    return Scaffold(
        body: Center(
            child: ScholarityTile(
      width: 470,
      child: IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ScholarityPadding(
            thick: true,
            child: FutureBuilder(
                future: _loadData(),
                builder: (context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ScholarityTextH3(
                            "Please choose an organization\nto purchase plan for:"),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                List.generate(_organizations.length, (index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: InkWell(
                                    onTap: () async {
                                      if (_organizations[index].checkoutUrl !=
                                          null) {
                                        launchUrl(Uri.parse(
                                            _organizations[index]
                                                .checkoutUrl!));
                                      } else {
                                        String url = await payment_service
                                            .getPaymentPortalUrl(
                                                organizationId:
                                                    _organizations[index]
                                                        .organizationId);
                                        // this organization already has a subscription
                                        await showDialog<String>(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                _PaymentAlertDialog(
                                                    portalUrl: url));
                                      }

                                      Navigator.of(context).pushNamed(
                                          "/organization?id=${_organizations[index].organizationId.toString()}");
                                    },
                                    child: ScholarityTile(
                                        child: ScholarityPadding(
                                            child: ScholarityTextH2B(
                                                _organizations[index]
                                                    .organizationName)))),
                              );
                            })),
                      ],
                    );
                  } else {
                    return const ScholarityBoxLoading(
                      height: 100,
                      width: 300,
                    );
                  }
                }),
          ),
        ),
      ),
    )));
  }
}

class MyWidget extends StatelessWidget {
  // members of MyWidget
  final int x;

  // constructor
  const MyWidget({Key? key, required this.x}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class _PaymentAlertDialog extends StatelessWidget {
  final String portalUrl;
  // constructor
  const _PaymentAlertDialog({Key? key, required this.portalUrl})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return ScholarityAlertDialogWrapper(
      child: ScholarityAlertDialog(
        title: const ScholarityTextH2B("Organization already has a plan!"),
        content: SizedBox(
          height: 150,
          width: 300,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const ScholarityTextP(
                "This organization appears to have an existing plan. "
                "To upgrade it, please either cancel or upgrade it using our portal."),
            Expanded(child: Container()),
            Row(
              children: [
                ScholarityButton(
                    text: "Dismiss",
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                ScholarityButton(
                    text: "Go to Portal",
                    invertedColor: true,
                    onPressed: () {
                      launchUrl(Uri.parse(portalUrl));
                      Navigator.pop(context);
                    })
              ],
            )
          ]),
        ),
      ),
    );
  }
}
