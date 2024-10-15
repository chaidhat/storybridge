import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/style/Storybridge_colors.dart' as Storybridge_color;

const int MOBILE_SCREEN_WIDTH = 1000;

bool isMobileScreen(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  if (width > MOBILE_SCREEN_WIDTH) {
    return false;
  } else {
    return true;
  }
}

class StorybridgeTile extends StatelessWidget {
  // members of MyWidget
  final double? width;
  final Widget child;
  final bool useAltStyle;
  final bool hasShadows;
  final Color? color;

  // constructor
  const StorybridgeTile(
      {Key? key,
      this.width,
      required this.child,
      this.useAltStyle = false,
      this.hasShadows = false,
      this.color})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Storybridge_color.background;
    Color backgroundDimColor = Storybridge_color.backgroundDim;
    Color borderColor = Storybridge_color.borderColor;
    if (color != null) {
      backgroundColor = Storybridge_color.getBackgroundColor(color!);
      backgroundDimColor = Storybridge_color.getBackgroundColor(color!);
      borderColor = Storybridge_color.getTextColor(color!);
    }

    return SizedBox(
      width: width ?? 100000, // if no width given, then expand fully
      child: Container(
        decoration: BoxDecoration(
          border:
              !useAltStyle ? Border.all(color: borderColor, width: 1) : null,
          borderRadius: BorderRadius.circular(8),
          color: !useAltStyle ? backgroundColor : backgroundDimColor,
          boxShadow:
              hasShadows ? const [Storybridge_color.highShadow] : const [],
        ),
        child: child,
      ),
    );
  }
}

class StorybridgeHolder extends StatelessWidget {
  // members of MyWidget
  final Widget child;
  final bool hasPadding;
  final bool hasReducedPadding;
  final bool hasVeryReducedPadding;

  // constructor
  const StorybridgeHolder(
      {Key? key,
      required this.child,
      this.hasPadding = true,
      this.hasReducedPadding = false,
      this.hasVeryReducedPadding = false})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: hasPadding
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
          : EdgeInsets.zero,
      child: Container(
        constraints: !hasVeryReducedPadding
            ? BoxConstraints(
                maxWidth: !hasReducedPadding
                    ? Storybridge_color.StorybridgeHolderMaxWidth
                    : Storybridge_color.StorybridgeHolderMaxWidthNotPadded)
            : null,
        child: Padding(
          padding:
              !hasVeryReducedPadding ? EdgeInsets.zero : EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}

class StorybridgePadding extends StatelessWidget {
  // members of MyWidget
  final Widget child;
  final bool thick;
  final bool verticalOnly;

  // constructor
  const StorybridgePadding(
      {Key? key,
      required this.child,
      this.thick = false,
      this.verticalOnly = false})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    double paddingThickness = thick ? 30 : 20;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: verticalOnly ? 0 : paddingThickness,
          vertical: verticalOnly ? paddingThickness / 2 : paddingThickness),
      child: child,
    );
  }
}

// myPage class which creates a state on call
class StorybridgeHoverButton extends StatefulWidget {
  final Widget child, button;
  final bool enabled;
  const StorybridgeHoverButton({
    Key? key,
    required this.child,
    required this.button,
    this.enabled = true,
  }) : super(key: key);

  @override
  _StorybridgeHoverButtonState createState() => _StorybridgeHoverButtonState();
}

// myPage state
class _StorybridgeHoverButtonState extends State<StorybridgeHoverButton> {
  bool _isHovering = false;

  // main build function
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovering = false;
        });
      },
      child: Stack(
        children: [
          widget.child,
          _isHovering && widget.enabled
              ? Align(
                  alignment: Alignment.centerRight,
                  child: widget.button,
                )
              : Container(),
        ],
      ),
    );
  }
}

class StorybridgeBox extends StatelessWidget {
  // members of MyWidget
  final Widget child;
  final bool useAltStyle;

  // constructor
  const StorybridgeBox(
      {Key? key, required this.child, this.useAltStyle = false})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: !useAltStyle
                ? Storybridge_color.StorybridgeAccentBackground
                : Storybridge_color.backgroundDim,
            borderRadius: BorderRadius.circular(8),
            border: !useAltStyle
                ? Border.all(color: Storybridge_color.StorybridgeAccent)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: IntrinsicWidth(child: child),
          ),
        ),
      ],
    );
  }
}

class StorybridgeProgressIndicator extends StatelessWidget {
  // members of MyWidget
  final double progress;

  // constructor
  const StorybridgeProgressIndicator({Key? key, required this.progress})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      borderRadius: BorderRadius.circular(10),
      backgroundColor: Storybridge_color.lightGrey,
      value: progress,
      minHeight: 10,
      semanticsLabel: 'Linear progress indicator',
    );
  }
}
