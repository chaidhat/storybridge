import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/style/storybridge_colors.dart' as storybridge_color;
import 'package:mooc/services/translation_service.dart' as translation_service;

TextStyle get storybridgeTextH2Style => TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w500,
      color: storybridge_color.darkGrey,
    );
TextStyle get storybridgeTextH2BStyle => TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: storybridge_color.darkGrey,
    );
TextStyle get storybridgeTextH4Style => TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.w500,
      color: storybridge_color.darkGrey,
    );

/*
*  Text H5
*/
TextStyle get storybridgeTextH5DimStyle => TextStyle(
      fontSize: 14,
      fontFamily: "Inter",
      fontWeight: FontWeight.w500,
      color: storybridge_color.lightGrey,
    );
TextStyle get storybridgeTextH5Style => TextStyle(
      fontSize: 14,
      fontFamily: "Inter",
      fontWeight: FontWeight.w500,
      color: storybridge_color.darkGrey,
    );
TextStyle get storybridgeTextH5RedStyle => TextStyle(
      fontSize: 14,
      fontFamily: "Inter",
      fontWeight: FontWeight.w500,
      color: storybridge_color.storybridgeAccent,
    );
TextStyle get storybridgeTextH5BStyle => TextStyle(
      fontSize: 14,
      fontFamily: "Inter",
      fontStyle: FontStyle.italic,
      color: storybridge_color.darkGrey,
    );
TextStyle get storybridgeTextH5RedBStyle => TextStyle(
      fontSize: 14,
      fontFamily: "Inter",
      fontStyle: FontStyle.italic,
      color: storybridge_color.storybridgeAccent,
    );
TextStyle get storybridgeTextH5WhiteStyle => TextStyle(
      fontSize: 14,
      fontFamily: "Inter",
      fontWeight: FontWeight.w500,
      color: storybridge_color.background,
    );
/*
*  End of Text H5
*/

TextStyle get storybridgeTextPStyle => TextStyle(
      height: 1.5,
      color: storybridge_color.black,
      fontSize: 14,
    );
TextStyle get storybridgeTextPRedStyle => TextStyle(
      color: storybridge_color.storybridgeAccent,
      fontSize: 14,
    );
TextStyle get storybridgeTextPLinkStyle => TextStyle(
      color: storybridge_color.storybridgeAccent,
      decoration: TextDecoration.underline,
      fontSize: 14,
    );
TextStyle get storybridgeTextPDimStyle => TextStyle(
      color: storybridge_color.grey,
      fontSize: 14,
    );
TextStyle get storybridgeTextSmallStyle => TextStyle(
      height: 1.5,
      color: storybridge_color.black,
      fontSize: 14,
    );

class StorybridgeTextH2 extends StatelessWidget {
  // members of MyWidget
  final String text;

  // constructor
  const StorybridgeTextH2(this.text, {Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Text(translation_service.translate(text),
        style: storybridgeTextH2Style);
  }
}

class StorybridgeTextH2B extends StatelessWidget {
  // members of MyWidget
  final String text;

  // constructor
  const StorybridgeTextH2B(this.text, {Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Text(translation_service.translate(text),
        style: storybridgeTextH2BStyle);
  }
}

class StorybridgeTextH3 extends StatelessWidget {
  // members of MyWidget
  final String text;
  final String? bracketText;

  // constructor
  const StorybridgeTextH3(this.text, {Key? key, this.bracketText})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(translation_service.translate(text),
            style: TextStyle(
              fontSize: 20,
              color: storybridge_color.storybridgeAccent,
            )),
        const SizedBox(width: 10),
        Text(translation_service.translate(bracketText ?? ""),
            style: TextStyle(
              fontSize: 14,
              color: storybridge_color.storybridgeAccent,
            )),
      ],
    );
  }
}

class StorybridgeTextH4 extends StatelessWidget {
  // members of MyWidget
  final String text;

  // constructor
  const StorybridgeTextH4(this.text, {Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Text(translation_service.translate(text),
        style: storybridgeTextH4Style);
  }
}

class StorybridgeTextH5 extends StatelessWidget {
  // members of MyWidget
  final String text;
  final bool red;
  final bool dim;
  final bool bold;

  // constructor
  const StorybridgeTextH5(this.text,
      {Key? key, this.red = false, this.bold = false, this.dim = false})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    /*
    quill.QuillController _controller = quill.QuillController(
        document: quill.Document.fromJson(
            jsonDecode('[{"insert": ${jsonEncode(text + "\n")}}]')),
        selection: const TextSelection.collapsed(offset: 0));
    if (!red) {
      return quill.QuillEditor.basic(controller: _controller, readOnly: true);
      //style: !bold ? storybridgeTextH5Style : storybridgeTextH5BStyle);
    } else {
      return quill.QuillEditor.basic(controller: _controller, readOnly: true);
    }
    */

    if (dim) {
      return Text(translation_service.translate(text),
          style: storybridgeTextH5DimStyle);
    }
    if (!red) {
      return Text(translation_service.translate(text),
          style: !bold ? storybridgeTextH5Style : storybridgeTextH5BStyle);
    } else {
      return Text(translation_service.translate(text),
          style:
              !bold ? storybridgeTextH5RedStyle : storybridgeTextH5RedBStyle);
    }
  }
}

class StorybridgeTextP extends StatelessWidget {
  // members of MyWidget
  final String text;
  final TextAlign? textAlign;
  final bool isDim;

  // constructor
  const StorybridgeTextP(this.text,
      {Key? key, this.textAlign, this.isDim = false})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Text(translation_service.translate(text),
        textAlign: textAlign,
        style: !isDim ? storybridgeTextPStyle : storybridgeTextPDimStyle);
  }
}

class StorybridgeDescriptor extends StatelessWidget {
  // members of MyWidget
  final String name;
  final String description;

  // constructor
  const StorybridgeDescriptor(
      {Key? key, required this.name, this.description = ""})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        StorybridgeTextH2B(name),
        description == "" ? Container() : StorybridgeTextP(description),
        const SizedBox(height: 10),
      ],
    );
  }
}

class StorybridgeTextBasic extends StatelessWidget {
  // members of MyWidget
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const StorybridgeTextBasic(this.text, {Key? key, this.style, this.textAlign})
      : super(key: key);
  // main build function
  @override
  Widget build(BuildContext context) {
    return Text(translation_service.translate(text),
        style: style, textAlign: textAlign);
  }
}

class StorybridgeTextSmall extends StatelessWidget {
  // members of MyWidget
  final String text;
  final TextAlign? textAlign;

  // constructor
  const StorybridgeTextSmall(this.text, {Key? key, this.textAlign})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Text(translation_service.translate(text),
        textAlign: textAlign, style: storybridgeTextSmallStyle);
  }
}
