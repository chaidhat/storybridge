import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/scholarity.dart'; // Scholarity

class ProductCoursesWidget extends StatelessWidget {
  // constructor
  const ProductCoursesWidget({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return ScholarityTile(
      useAltStyle: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
                height: 100,
                width: 100,
                child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: Image.asset("assets/images/e-learning.png"))),
            const SizedBox(width: 20),
            const Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScholarityTextH2B("E-Learning System"),
                  SizedBox(height: 20),
                  ScholarityTextP(
                      "Empower your team with our intuitive e-learning system, allowing teachers to effortlessly create engaging online training videos for employees. Enhance your workforce's skills and compliance with ease and efficiency."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductAuditWidget extends StatelessWidget {
  // constructor
  const ProductAuditWidget({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return ScholarityTile(
      useAltStyle: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
                height: 100,
                width: 100,
                child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: Image.asset("assets/images/auditing.png"))),
            const SizedBox(width: 20),
            const Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScholarityTextH2B("Auditing System"),
                  SizedBox(height: 20),
                  ScholarityTextP(
                      "Simplify your inspection, auditing and reporting workflows with our advanced auditing system. Enhance accuracy and compliance in your organization with our user-friendly tools."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductFleetWidget extends StatelessWidget {
  // constructor
  const ProductFleetWidget({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return ScholarityTile(
      useAltStyle: true,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
                height: 100,
                width: 100,
                child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: Image.asset("assets/images/fleet.png"))),
            const SizedBox(width: 20),
            const Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScholarityTextH2B("Fleet System"),
                  SizedBox(height: 20),
                  ScholarityTextP(
                      "Our fleet management system provides the tools you need to efficiently oversee your vehicle operations. From real-time tracking to maintenance scheduling, it ensures your fleet runs smoothly, safely, and in full compliance."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
