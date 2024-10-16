import 'package:flutter/material.dart';

class ScholarityAlertDialogWrapper extends StatelessWidget {
  // members of MyWidget
  final Widget child;

  // constructor
  const ScholarityAlertDialogWrapper({Key? key, required this.child})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    /*
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: child,
    );
    */
    // blur was causing issues
    return child;
  }
}
