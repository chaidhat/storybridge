import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/services/payment_service.dart' as payment_service;

class PaymentNoTierWidget extends StatelessWidget {
  // constructor
  const PaymentNoTierWidget({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    const payment_service.PaymentTier paymentTier =
        payment_service.PaymentTier.enterpriseTier;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScholarityTextH2B(payment_service.paymentTierName[paymentTier]!),
        const SizedBox(height: 10),
        ScholarityTextP(
            "You have no tier at the moment. Please purchase a tier to begin using Scholarity.")
      ],
    );
  }
}

class PaymentBasicTierWidget extends StatelessWidget {
  // constructor
  const PaymentBasicTierWidget({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    const payment_service.PaymentTier paymentTier =
        payment_service.PaymentTier.basicTier;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScholarityTextH2B(payment_service.paymentTierName[paymentTier]!),
        const SizedBox(height: 10),
        ScholarityTextP("Begin building your course online effortlessly.\n\n"
            "• Unlimited students\n"
            "• Create up to ${payment_service.paymentTierCourseMax[paymentTier]!.toString()} courses\n"
            "• ${payment_service.paymentTierDataMax[paymentTier]!.toString()}GB (~${payment_service.paymentTierDataMax[paymentTier]!.toString()} hours) of video data"),
      ],
    );
  }
}

class PaymentExpandTierWidget extends StatelessWidget {
  // constructor
  const PaymentExpandTierWidget({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    const payment_service.PaymentTier paymentTier =
        payment_service.PaymentTier.expandTier;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScholarityTextH2B(payment_service.paymentTierName[paymentTier]!),
        const SizedBox(height: 10),
        ScholarityTextP(
            "Expand your teaching brand and business using our best-in-class features.\n\n"
            "• Everything in Basic Tier\n"
            "• Have up to ${payment_service.paymentTierCourseMax[paymentTier]!.toString()} courses\n"
            "• ${payment_service.paymentTierDataMax[paymentTier]!.toString()}GB (~${payment_service.paymentTierDataMax[paymentTier]!.toString()} hours) of video data"),
      ],
    );
  }
}

class PaymentBusinessTierWidget extends StatelessWidget {
  // constructor
  const PaymentBusinessTierWidget({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    const payment_service.PaymentTier paymentTier =
        payment_service.PaymentTier.businessTier;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScholarityTextH2B(payment_service.paymentTierName[paymentTier]!),
        const SizedBox(height: 10),
        ScholarityTextP(
            "Designed for small/medium businesses, schools and SMEs.\n\n"
            "• Everything in Expand Tier\n"
            "• Have up to ${payment_service.paymentTierCourseMax[paymentTier]!.toString()} courses\n"
            "• ${payment_service.paymentTierDataMax[paymentTier]!.toString()}GB (~${payment_service.paymentTierDataMax[paymentTier]!.toString()} hours) of video data\n"
            "• Rapid support with rapid response"),
      ],
    );
  }
}

class PaymentEnterpriseTierWidget extends StatelessWidget {
  // constructor
  const PaymentEnterpriseTierWidget({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    const payment_service.PaymentTier paymentTier =
        payment_service.PaymentTier.enterpriseTier;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ScholarityTextH2B(payment_service.paymentTierName[paymentTier]!),
        const SizedBox(height: 10),
        ScholarityTextP(
            "Designed for large corporations, schools and enterprises.\n\n"
            "• Everything in Business Tier\n"
            "• Have up to unlimited courses\n"
            "• ${payment_service.paymentTierDataMax[paymentTier]!.toString()}GB (~${payment_service.paymentTierDataMax[paymentTier]!.toString()} hours) of video data\n"),
      ],
    );
  }
}
