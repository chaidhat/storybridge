import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/style/scholarity_colors.dart' as scholarity_color;

class ScholarityDivider extends StatelessWidget {
  final bool isLarge;
  // constructor
  const ScholarityDivider({Key? key, this.isLarge = false}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Divider(
      color: scholarity_color.borderColor,
      height: !isLarge ? null : 50,
      thickness: 1,
    );
  }
}
