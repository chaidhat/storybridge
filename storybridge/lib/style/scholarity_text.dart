import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/style/Storybridge_colors.dart' as Storybridge_color;
import 'package:mooc/services/translation_service.dart' as translation_service;

TextStyle get StorybridgeTextH2Style => TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w500,
      color: Storybridge_color.darkGrey,
    );
TextStyle get StorybridgeTextH2BStyle => TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: Storybridge_color.darkGrey,
    );
TextStyle get StorybridgeTextH4Style => TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.w500,
      color: Storybridge_color.darkGrey,
    );

/*
*  Text H5
*/
TextStyle get StorybridgeTextH5DimStyle => TextStyle(
      fontSize: 14,
      fontFamily: "Inter",
      fontWeight: FontWeight.w500,
      color: Storybridge_color.lightGrey,
    );
TextStyle get StorybridgeTextH5Style => TextStyle(
      fontSize: 14,
      fontFamily: "Inter",
      fontWeight: FontWeight.w500,
      color: Storybridge_color.darkGrey,
    );
TextStyle get StorybridgeTextH5RedStyle => TextStyle(
      fontSize: 14,
      fontFamily: "Inter",
      fontWeight: FontWeight.w500,
      color: Storybridge_color.StorybridgeAccent,
    );
TextStyle get StorybridgeTextH5BStyle => TextStyle(
      fontSize: 14,
      fontFamily: "Inter",
      fontStyle: FontStyle.italic,
      color: Storybridge_color.darkGrey,
    );
TextStyle get StorybridgeTextH5RedBStyle => TextStyle(
      fontSize: 14,
      fontFamily: "Inter",
      fontStyle: FontStyle.italic,
      color: Storybridge_color.StorybridgeAccent,
    );
TextStyle get StorybridgeTextH5WhiteStyle => TextStyle(
      fontSize: 14,
      fontFamily: "Inter",
      fontWeight: FontWeight.w500,
      color: Storybridge_color.background,
    );
/*
*  End of Text H5
*/

TextStyle get StorybridgeTextPStyle => TextStyle(
      height: 1.5,
      color: Storybridge_color.black,
      fontSize: 14,
    );
TextStyle get StorybridgeTextPRedStyle => TextStyle(
      color: Storybridge_color.StorybridgeAccent,
      fontSize: 14,
    );
TextStyle get StorybridgeTextPLinkStyle => TextStyle(
      color: Storybridge_color.StorybridgeAccent,
      decoration: TextDecoration.underline,
      fontSize: 14,
    );
TextStyle get StorybridgeTextPDimStyle => TextStyle(
      color: Storybridge_color.grey,
      fontSize: 14,
    );
TextStyle get StorybridgeTextSmallStyle => TextStyle(
      height: 1.5,
      color: Storybridge_color.black,
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
        style: StorybridgeTextH2Style);
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
        style: StorybridgeTextH2BStyle);
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
              color: Storybridge_color.StorybridgeAccent,
            )),
        const SizedBox(width: 10),
        Text(translation_service.translate(bracketText ?? ""),
            style: TextStyle(
              fontSize: 14,
              color: Storybridge_color.StorybridgeAccent,
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
        style: StorybridgeTextH4Style);
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
      //style: !bold ? StorybridgeTextH5Style : StorybridgeTextH5BStyle);
    } else {
      return quill.QuillEditor.basic(controller: _controller, readOnly: true);
    }
    */

    if (dim) {
      return Text(translation_service.translate(text),
          style: StorybridgeTextH5DimStyle);
    }
    if (!red) {
      return Text(translation_service.translate(text),
          style: !bold ? StorybridgeTextH5Style : StorybridgeTextH5BStyle);
    } else {
      return Text(translation_service.translate(text),
          style:
              !bold ? StorybridgeTextH5RedStyle : StorybridgeTextH5RedBStyle);
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
        style: !isDim ? StorybridgeTextPStyle : StorybridgeTextPDimStyle);
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
        textAlign: textAlign, style: StorybridgeTextSmallStyle);
  }
}
