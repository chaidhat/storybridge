import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:url_launcher/url_launcher.dart';

enum PaymentTier {
  basicTier,
  expandTier,
  businessTier,
  enterpriseTier,
  noTier,
}

const Map<PaymentTier, String> paymentTierName = {
  PaymentTier.basicTier: "Free Tier",
  PaymentTier.expandTier: "Expand Tier",
  PaymentTier.businessTier: "Business Tier",
  PaymentTier.enterpriseTier: "Enterprise Tier",
  PaymentTier.noTier: "Free Tier",
};

// how many courses is an organization allowed if under a payment tier
const Map<PaymentTier, int> paymentTierCourseMax = {
  PaymentTier.basicTier: 2,
  PaymentTier.expandTier: 5,
  PaymentTier.businessTier: 20,
  PaymentTier.enterpriseTier: 999,
  PaymentTier.noTier: 1,
};

// how many courses is an organization allowed if under a payment tier
const Map<PaymentTier, int> paymentTierDataMax = {
  PaymentTier.basicTier: 1,
  PaymentTier.expandTier: 10,
  PaymentTier.businessTier: 75,
  PaymentTier.enterpriseTier: 500,
  PaymentTier.noTier: 1,
};

void launchPaymentPricingPage() {
  launchUrl(Uri.parse("https://www.storybridge.io/pricing"));
}

// returns null if the org already has a subscription (cannot check out more!)
Future<String?> getPaymentCheckoutUrl({
  required int organizationId,
  required PaymentTier plan,
}) async {
  if (plan == PaymentTier.noTier) {
    return ""; // there's no checkout page for no tier!
  }
  Map<String, dynamic> data = await networking_api_service
      .getCheckoutSessionUrl(organizationId: organizationId, plan: plan.index);
  if (!data["data"]["isValid"]) {
    return null;
  }
  return data["data"]["url"];
}

Future<String> getPaymentPortalUrl({
  required int organizationId,
}) async {
  Map<String, dynamic> data = await networking_api_service.getPortalSessionUrl(
      organizationId: organizationId);
  return data["data"]["url"];
}
