import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:dart_ipify/dart_ipify.dart';

void reportAnalyticsOnLoadRegisterPage() async {
  final ipv4 = await Ipify.ipv4();
  await networking_api_service.reportAnalyticsEvent(
      analyticsEventType: 1, analyticsEventSubtype: ipv4);
}
