import 'package:flutter/material.dart';
import 'package:mooc/storybridge.dart'; // Storybridge

import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;

class StorybridgeLoginHeader extends StatelessWidget {
  // constructor
  const StorybridgeLoginHeader({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
        child: Image(fit: BoxFit.fill, image: AssetImage('assets/logo-1.png')));
  }
}

class CustomLoginHeader extends StatelessWidget {
  final int organizationId;

  // constructor
  const CustomLoginHeader({Key? key, required this.organizationId})
      : super(key: key);

  Future<String> loadOrganizationName() async {
    Map<String, dynamic> organization = await networking_api_service
        .getOrganization(organizationId: organizationId);
    String organizationName =
        Uri.decodeComponent(organization["data"]["organizationName"]);
    return organizationName;
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadOrganizationName(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            String organizationName = snapshot.data!;
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfilePictureWidget(organizationId: organizationId),
                const SizedBox(height: 10),
                StorybridgeTextH2B(organizationName)
              ],
            );
          } else {
            return const StorybridgeBoxLoading(height: 70, width: 100);
          }
        });
  }
}
