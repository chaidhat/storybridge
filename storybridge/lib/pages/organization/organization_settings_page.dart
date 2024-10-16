import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/payment_service.dart' as payment_service;

// myPage class which creates a state on call
class OrganizationSettingsPage extends StatefulWidget {
  final int organizationId;
  const OrganizationSettingsPage({Key? key, required this.organizationId})
      : super(key: key);

  @override
  _OrganizationSettingsPageState createState() =>
      _OrganizationSettingsPageState();
}

// myPage state
class _OrganizationSettingsPageState extends State<OrganizationSettingsPage> {
  late payment_service.PaymentTier _paymentTier;
  late String _paymentPortalUrl;
  Future<bool> _loadData() async {
    Map<String, dynamic> response = await networking_api_service
        .getOrganization(organizationId: widget.organizationId);
    _paymentTier =
        payment_service.PaymentTier.values[response["data"]["paymentTier"]];
    _paymentPortalUrl = await payment_service.getPaymentPortalUrl(
        organizationId: widget.organizationId);
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
    return ScholarityTabPage(body: [
      const SizedBox(height: 40),
      OrganizationAuthShareWidget(
        organizationId: widget.organizationId,
      ),
      const SizedBox(height: 40),
      const ScholarityDescriptor(
        name: "Organization Name",
      ),
      ScholaritySettingButton(
        name: "Organization Name",
        loadValue: () async {
          Map<String, dynamic> org = await networking_api_service
              .getOrganization(organizationId: widget.organizationId);
          return Uri.decodeComponent(org["data"]["organizationName"]);
        },
        saveValue: (String value) async {
          networking_api_service.setOrganizationName(
              organizationId: widget.organizationId, organizationName: value);
          Navigator.pushNamed(context, "/reload");
        },
      ),
      const ScholarityDescriptor(
        name: "Organization Email",
      ),
      ScholaritySettingButton(
        name: "Organization Email",
        loadValue: () async {
          Map<String, dynamic> org = await networking_api_service
              .getOrganization(organizationId: widget.organizationId);
          return Uri.decodeComponent(org["data"]["email"]);
        },
        saveValue: (String value) async {
          networking_api_service.setOrganizationEmail(
              organizationId: widget.organizationId, email: value);
        },
      ),
      const ScholarityDescriptor(
        name: "Organization Logo",
      ),
      ProfilePictureSelectorWidget(
        organizationId: widget.organizationId,
      ),
      const SizedBox(height: 30),
      const ScholarityDivider(),
      const SizedBox(height: 30),
      const ScholarityTextH2B("Your plan:"),
      const SizedBox(height: 10),
      Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: ScholarityTile(
          child: ScholarityPadding(
            child: FutureBuilder(
                future: _loadData(),
                builder: (context, AsyncSnapshot<bool> snapshot) {
                  if (snapshot.hasData) {
                    switch (_paymentTier) {
                      case payment_service.PaymentTier.basicTier:
                        return const PaymentBasicTierWidget();
                      case payment_service.PaymentTier.expandTier:
                        return const PaymentExpandTierWidget();
                      case payment_service.PaymentTier.businessTier:
                        return const PaymentBusinessTierWidget();
                      case payment_service.PaymentTier.enterpriseTier:
                        return const PaymentEnterpriseTierWidget();
                      case payment_service.PaymentTier.noTier:
                        return const PaymentEnterpriseTierWidget();
                    }
                  } else {
                    return const ScholarityBoxLoading(height: 120, width: 300);
                  }
                }),
          ),
        ),
      ),
      const SizedBox(height: 30),
      ScholarityButton(
          text: "Manage Payment Info",
          onPressed: () {
            launchUrl(Uri.parse(_paymentPortalUrl));
          }),
    ]);
  }
}
