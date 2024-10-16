import 'package:flutter/material.dart'; // Flutter
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:mooc/storybridge.dart'; // Storybridge

//const COLOR_MAIN = const Color(0xFF006EB4);
const Color _lightmodeStorybridgeAccent = Color.fromARGB(255, 30, 92, 145);
const Color _lightmodeStorybridgeAccentLight =
    Color.fromARGB(255, 221, 245, 255);
const Color _lightmodeStorybridgeAccentBackground = Color(0xFFE7FBFF);
const Color _lightmodeBackground = Color(0xFFFFFFFF);
const Color _lightmodeBackgroundTransparent = Color(0x00FFFFFF);
const Color _lightmodeBackgroundDim = Color(0xFFF8F8F8);
const Color _lightmodeGrey = Color(0xFF606060);
const Color _lightmodeLightGrey = Color(0xFFA0A0A0);
const Color _lightmodeDarkGrey = Color(0xFF303030);
const Color _lightmodeBorderColor = Color(0xFFD0D0D0);
const Color _lightmodeBlack = Color(0xFF000000);
const Color _lightmodeBackgroundLoading = Color(0xFFF0F0F0);

const Color _darkmodeStorybridgeAccent = Color.fromARGB(255, 98, 170, 233);
const Color _darkmodeStorybridgeAccentLight = Color.fromARGB(255, 85, 85, 85);
const Color _darkmodeStorybridgeAccentBackground =
    Color.fromARGB(255, 32, 32, 32);
const Color _darkmodeBackground = Color.fromARGB(255, 0, 0, 0);
const Color _darkmodeBackgroundTransparent = Color.fromARGB(0, 0, 0, 0);
const Color _darkmodeBackgroundDim = Color.fromARGB(255, 25, 25, 25);
const Color _darkmodeGrey = Color(0xFF606060);
const Color _darkmodeLightGrey = Color.fromARGB(255, 84, 84, 84);
const Color _darkmodeDarkGrey = Color.fromARGB(255, 255, 255, 255);
const Color _darkmodeBorderColor = Color.fromARGB(255, 79, 79, 79);
const Color _darkmodeBlack = Color.fromARGB(255, 255, 255, 255);
const Color _darkmodeBackgroundLoading = Color.fromARGB(255, 23, 23, 23);

Color storybridgeAccent = _lightmodeStorybridgeAccent;
Color storybridgeAccentLight = _lightmodeStorybridgeAccentLight;
Color storybridgeAccentBackground = _lightmodeStorybridgeAccentBackground;
Color background = _lightmodeBackground;
Color backgroundDim = _lightmodeBackgroundDim;
Color backgroundTransparent = _lightmodeBackgroundTransparent;
Color grey = _lightmodeGrey;
Color lightGrey = _lightmodeLightGrey;
Color darkGrey = _lightmodeDarkGrey;
Color borderColor = _lightmodeBorderColor;
Color black = _lightmodeBlack;
Color backgroundLoading = _lightmodeBackgroundLoading;

bool _isDarkMode = false;

bool getIsDarkMode() {
  return _isDarkMode;
}

void toggleDarkMode() {
  _isDarkMode = !_isDarkMode;
  if (_isDarkMode) {
    storybridgeAccent = _darkmodeStorybridgeAccent;
    storybridgeAccentLight = _darkmodeStorybridgeAccentLight;
    storybridgeAccentBackground = _darkmodeStorybridgeAccentBackground;
    background = _darkmodeBackground;
    backgroundDim = _darkmodeBackgroundDim;
    backgroundTransparent = _darkmodeBackgroundTransparent;
    grey = _darkmodeGrey;
    lightGrey = _darkmodeLightGrey;
    darkGrey = _darkmodeDarkGrey;
    borderColor = _darkmodeBorderColor;
    black = _darkmodeBlack;
    backgroundLoading = _darkmodeBackgroundLoading;
  } else {
    storybridgeAccent = _lightmodeStorybridgeAccent;
    storybridgeAccentLight = _lightmodeStorybridgeAccentLight;
    storybridgeAccentBackground = _lightmodeStorybridgeAccentBackground;
    background = _lightmodeBackground;
    backgroundDim = _lightmodeBackgroundDim;
    backgroundTransparent = _lightmodeBackgroundTransparent;
    grey = _lightmodeGrey;
    lightGrey = _lightmodeLightGrey;
    darkGrey = _lightmodeDarkGrey;
    borderColor = _lightmodeBorderColor;
    black = _lightmodeBlack;
    backgroundLoading = _lightmodeBackgroundLoading;
  }
}
/*
OLD colour scheme
const storybridgeRed = Color(0xFFD41C3A);
const storybridgeRedLight = Color(0xFFfbdfe4);
const storybridgeRedBackground = Color(0xFFFDF2F4);
const background = Color(0xFFFFFFFF);
const backgroundDim = Color(0xFFF8F8F8);
const grey = Color(0xFF606060);
const lightGrey = Color(0xFFA0A0A0);
const darkGrey = Color(0xFF303030);
const borderColor = Color(0xFFD0D0D0);
const black = Color(0xFF000000);
const backgroundLoading = Color(0xFFF0F0F0);
*/

const green = Color(0xFF7CEA9C);
const blueblue = Color.fromARGB(255, 105, 97, 128);
const auditBlue = Color.fromARGB(255, 26, 189, 235);

const double storybridgeHolderMaxWidth = 740;
const double storybridgeHolderMaxWidthNotPadded = 787;
const double storybridgeSideBarWidth = 300;

//DARKMODE

/*
const storybridgeRed = Color(0xFFD41C3A);
const storybridgeRedLight = Color(0xFF612728);
const storybridgeRedBackground = Color(0xFF391d1F);
const backgroundDim = Color(0xFF161C21);
const grey = Color(0xFFFFFFFF);
const darkGrey = Color(0xFFFFFFFF);
const borderColor = Color(0xFF404040);
const background = Color(0xFF0E1117);
const black = Color(0xFFFFFFFF);
const backgroundLoading = Color(0xFFF0F0F0);
*/

const BoxShadow highShadow = BoxShadow(
  color: Color(0x40000000),
  blurRadius: 10,
  offset: Offset(0, 6), // Shadow position
);

const BoxShadow shadow = BoxShadow(
  color: Color(0x30000000),
  blurRadius: 10,
  offset: Offset(0, 4), // Shadow position
);

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (double strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
// usage Color color2 = HexColor("#b74093");

// myPage class which creates a state on call
class StorybridgeColorPicker extends StatefulWidget {
  final StorybridgeTextFieldController controller;
  const StorybridgeColorPicker({Key? key, required this.controller})
      : super(key: key);

  @override
  _StorybridgeColorPickerState createState() => _StorybridgeColorPickerState();
}

// myPage state
class _StorybridgeColorPickerState extends State<StorybridgeColorPicker> {
  Color? pickerColor;
  @override
  void initState() {
    super.initState();
    try {
      pickerColor = HexColor(widget.controller.text);
    } catch (e) {
      throw Exception("'#${widget.controller.text}' is an invalid colour!");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  void pickColor() {
    if (pickerColor == null) {
      return;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Select color'),
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: pickerColor!,
                  onColorChanged: changeColor,
                ),
                // Use Material color picker:
                //
                // child: MaterialPicker(
                //   pickerColor: pickerColor,
                //   onColorChanged: changeColor,
                //   showLabel: true, // only on portrait mode
                // ),
                //
                // Use Block color picker:
                //
                // child: BlockPicker(
                //   pickerColor: currentColor,
                //   onColorChanged: changeColor,
                // ),
                //
                // child: MultipleChoiceBlockPicker(
                //   pickerColors: currentColors,
                //   onColorsChanged: changeColors,
                // ),
              ),
              actions: <Widget>[
                StorybridgeButton(
                  text: "Confirm",
                  invertedColor: true,
                  onPressed: () {
                    widget.controller.text = pickerColor!
                        .toHexString(enableAlpha: true, includeHashSign: false)
                        .substring(2, 8);
                    Navigator.pop(context);
                  },
                ),
              ],
            ));
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 40,
      child: Row(
        children: [
          InkWell(
            onTap: () {
              pickColor();
            },
            child: pickerColor != null
                ? Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(8),
                        color: pickerColor),
                    height: 40,
                    width: 100,
                  )
                : StorybridgeTextP(
                    "Invalid colour: '#${widget.controller.text}'"),
          ),
          const SizedBox(width: 10),
          StorybridgeIconButton(
            onPressed: () {
              pickColor();
            },
            icon: Icons.colorize_rounded,
          )
        ],
      ),
    );
  }
}

// myPage class which creates a state on call
class StorybridgeColorPickerIcon extends StatefulWidget {
  final StorybridgeTextFieldController controller;
  const StorybridgeColorPickerIcon({Key? key, required this.controller})
      : super(key: key);

  @override
  StorybridgeColorPickerIconState createState() =>
      StorybridgeColorPickerIconState();
}

// myPage state
class StorybridgeColorPickerIconState
    extends State<StorybridgeColorPickerIcon> {
  Color? pickerColor;
  @override
  void initState() {
    super.initState();
    try {
      pickerColor = HexColor(widget.controller.text);
    } catch (e) {
      throw Exception("'#${widget.controller.text}' is an invalid colour!");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ValueChanged<Color> callback
  void changeColor(Color color) {
    pickerColor = color;
  }

  void pickColor() {
    if (pickerColor == null) {
      return;
    }
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Select color'),
              content: SingleChildScrollView(
                child: BlockPicker(
                  pickerColor: pickerColor!,
                  onColorChanged: changeColor,
                ),
              ),
              actions: <Widget>[
                StorybridgeButton(
                  text: "Confirm",
                  invertedColor: true,
                  onPressed: () {
                    widget.controller.text = pickerColor!
                        .toHexString(enableAlpha: true, includeHashSign: false)
                        .substring(2, 8);
                    Navigator.pop(context);
                  },
                ),
              ],
            ));
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return StorybridgeIconButton(
      icon: Icons.format_color_fill_rounded,
      onPressed: () {
        pickColor();
      },
    );
  }
}

const double targetContrastRatio = .2; // 5
bool isWhite(Color color) {
  return color.toHexString() == Colors.white.toHexString();
}

bool isBlack(Color color) {
  return color.toHexString() == Colors.black.toHexString();
}

bool isGrey(Color color) {
  return HSVColor.fromColor(color).saturation == 0;
}

double _getContrastRatio(Color color1, Color color2) {
  return (color1.computeLuminance() + 0.05) /
      (color2.computeLuminance() + 0.05);
}

// 255 means fully opaque
Color _manualBlendWhite(Color color, double perc) {
  double mR = 255 - color.red.toDouble();
  double mG = 255 - color.green.toDouble();
  double mB = 255 - color.blue.toDouble();
  return color
      .withRed((color.red + (mR * perc)).round())
      .withGreen((color.green + (mG * perc)).round())
      .withBlue((color.blue + (mB * perc)).round());
}

Color getTextColor(Color color) {
  HSLColor c = HSLColor.fromColor(color);
  if (isWhite(color)) {
    return black;
  }
  if (!getIsDarkMode()) {
    // normal light mode
    if (isGrey(color)) {
      return black;
    }

    if (_getContrastRatio(c.toColor(), _manualBlendWhite(color, 0.85)) >
        targetContrastRatio) {
      while (_getContrastRatio(c.toColor(), _manualBlendWhite(color, 0.85)) >
          targetContrastRatio) {
        c = c.withLightness(c.lightness - 0.005);
      }
    } else {
      while (_getContrastRatio(c.toColor(), _manualBlendWhite(color, 0.85)) <
          targetContrastRatio) {
        c = c.withLightness(c.lightness + 0.005);
      }
    }
    return c.toColor();
  } else {
    // normal dark mode
    // extreme dark mode
    if (isGrey(color)) {
      return black;
    }
    return c.withSaturation(1).withLightness(.7).toColor();
  }
}

Color getBackgroundColor(Color color) {
  if (isWhite(color)) {
    return Colors.transparent;
  }
  if (!getIsDarkMode()) {
    // normal light mode
    return _manualBlendWhite(color, 0.85);
  } else {
    // normal dark mode
    // extreme dark mode
    return HSLColor.fromColor(color)
        .withLightness(1 - HSLColor.fromColor(color).lightness)
        .withAlpha(0.3)
        .toColor();
  }
}
