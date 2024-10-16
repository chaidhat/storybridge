import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';
import 'package:mooc/storybridge.dart'; // Storybridge

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
    return StorybridgeTabPage(body: [
      const SizedBox(height: 40),
      OrganizationAuthShareWidget(
        organizationId: widget.organizationId,
      ),
      const SizedBox(height: 40),
      const StorybridgeDescriptor(
        name: "Organization Name",
      ),
      StorybridgeSettingButton(
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
      const StorybridgeDescriptor(
        name: "Organization Email",
      ),
      StorybridgeSettingButton(
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
      const StorybridgeDescriptor(
        name: "Organization Logo",
      ),
      ProfilePictureSelectorWidget(
        organizationId: widget.organizationId,
      ),
    ]);
  }
}
