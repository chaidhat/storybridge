import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/style/Storybridge_colors.dart' as Storybridge_color;

class StorybridgeDivider extends StatelessWidget {
  final bool isLarge;
  // constructor
  const StorybridgeDivider({Key? key, this.isLarge = false}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Storybridge_color.borderColor,
      height: !isLarge ? null : 50,
      thickness: 1,
    );
  }
}
