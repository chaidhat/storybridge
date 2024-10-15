import 'package:flutter/material.dart';
import 'package:mooc/Storybridge.dart'; // Storybridge

import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/payment_service.dart' as payment_service;
import 'package:url_launcher/url_launcher.dart';

// myPage class which creates a state on call
class OrganizationRegisterPage extends StatefulWidget {
  final int organizationId;
  const OrganizationRegisterPage({Key? key, required this.organizationId})
      : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<OrganizationRegisterPage> {
  final StorybridgeTextFieldController _organizationNameController =
      StorybridgeTextFieldController();
  final StorybridgeTextFieldController _tierController =
      StorybridgeTextFieldController();
  bool _loading = true;
  String _checkoutUrl = "";
  @override
  void initState() {
    _tierController.text = "Basic Tier"; // TODO: do tier controllers better
    _loadCheckoutUrl(payment_service.PaymentTier.basicTier);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

// TODO: show expired warning
  Future<void> _checkIfOrganizationIsAlreadyMade() async {
    // find first organizationId, if user has no organization, then go to register
    Map<String, dynamic> response = await networking_api_service
        .getOrganization(organizationId: widget.organizationId);

    // if the user has already set the organization name, it means the organization has probably been activated and now expired
    print(response["data"]["organizationName"]);
  }

  void _loadCheckoutUrl(payment_service.PaymentTier paymentTier) async {
    //await _checkIfOrganizationIsAlreadyMade();
    _checkoutUrl = await payment_service.getPaymentCheckoutUrl(
            organizationId: widget.organizationId, plan: paymentTier) ??
        "insert error url"; //TODO: enter error url
    setState(() {
      _loading = false;
    });
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return Scaffold(
        body: Center(
      child: SingleChildScrollView(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StorybridgeTile(
                    width: 470,
                    child: StorybridgePadding(
                      thick: true,
                      child: SizedBox(
                        height: 320,
                        child: SingleChildScrollView(
                            child: // TODO: implement show expired warning
                                Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const StorybridgeTextH3("Setup Your Organization"),
                            const StorybridgeTextP(
                                "Organizations are a collection of teachers and courses under one business name. You can change this name later."),
                            const SizedBox(height: 20),
                            StorybridgeTextField(
                              label: "Organization Name",
                              controller: _organizationNameController,
                              isPragmaticField: true,
                            ),
                            StorybridgeButton(
                                loading: _loading,
                                text: "Create & Checkout",
                                invertedColor: true,
                                verticalOnlyPadding: true,
                                onPressed: () async {
                                  launchUrl(Uri.parse(_checkoutUrl));
                                  await networking_api_service
                                      .setOrganizationName(
                                          organizationId: widget.organizationId,
                                          organizationName:
                                              _organizationNameController.text);
                                }),
                          ],
                        )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StorybridgeTile(
                    width: 470,
                    child: StorybridgePadding(
                      thick: true,
                      child: SizedBox(
                        height: 320,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const StorybridgeTextH3("Your Selected Plan"),
                              StorybridgeDropdown(
                                controller: _tierController,
                                label: "Tier",
                                dropdownTypes: [
                                  "Basic Tier",
                                  "Expand Tier",
                                  "Business Tier"
                                ],
                                onSubmit: (newValue) {
                                  _tierController.text =
                                      newValue ?? "Basic Tier";
                                  setState(() {
                                    switch (_tierController.text) {
                                      case "Expand Tier":
                                        _loadCheckoutUrl(payment_service
                                            .PaymentTier.expandTier);
                                        break;
                                      case "Business Tier":
                                        _loadCheckoutUrl(payment_service
                                            .PaymentTier.businessTier);
                                        break;
                                      case "Basic Tier":
                                      default:
                                        _loadCheckoutUrl(payment_service
                                            .PaymentTier.basicTier);
                                        break;
                                    }
                                    _loading = true;
                                  });
                                },
                              ),
                              const SizedBox(height: 10),
                              StorybridgeTile(child: StorybridgePadding(
                                  child: Builder(builder: (context) {
                                switch (_tierController.text) {
                                  case "Expand Tier":
                                    return PaymentExpandTierWidget();
                                  case "Business Tier":
                                    return PaymentBusinessTierWidget();
                                  case "Basic Tier":
                                  default:
                                    return PaymentBasicTierWidget();
                                }
                              }))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
