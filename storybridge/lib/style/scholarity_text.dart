import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/style/scholarity_colors.dart' as scholarity_color;
import 'package:mooc/services/translation_service.dart' as translation_service;

TextStyle get scholarityTextH2Style => TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w500,
      color: scholarity_color.darkGrey,
    );
TextStyle get scholarityTextH2BStyle => TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: scholarity_color.darkGrey,
    );
TextStyle get scholarityTextH4Style => TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.w500,
      color: scholarity_color.darkGrey,
    );

/*
*  Text H5
*/
TextStyle get scholarityTextH5DimStyle => TextStyle(
      fontSize: 14,
      fontFamily: "Inter",
      fontWeight: FontWeight.w500,
      color: scholarity_color.lightGrey,
    );
TextStyle get scholarityTextH5Style => TextStyle(
      fontSize: 14,
      fontFamily: "Inter",
      fontWeight: FontWeight.w500,
      color: scholarity_color.darkGrey,
    );
TextStyle get scholarityTextH5RedStyle => TextStyle(
      fontSize: 14,
      fontFamily: "Inter",
      fontWeight: FontWeight.w500,
      color: scholarity_color.scholarityAccent,
    );
TextStyle get scholarityTextH5BStyle => TextStyle(
      fontSize: 14,
      fontFamily: "Inter",
      fontStyle: FontStyle.italic,
      color: scholarity_color.darkGrey,
    );
TextStyle get scholarityTextH5RedBStyle => TextStyle(
      fontSize: 14,
      fontFamily: "Inter",
      fontStyle: FontStyle.italic,
      color: scholarity_color.scholarityAccent,
    );
TextStyle get scholarityTextH5WhiteStyle => TextStyle(
      fontSize: 14,
      fontFamily: "Inter",
      fontWeight: FontWeight.w500,
      color: scholarity_color.background,
    );
/*
*  End of Text H5
*/

TextStyle get scholarityTextPStyle => TextStyle(
      height: 1.5,
      color: scholarity_color.black,
      fontSize: 14,
    );
TextStyle get scholarityTextPRedStyle => TextStyle(
      color: scholarity_color.scholarityAccent,
      fontSize: 14,
    );
TextStyle get scholarityTextPLinkStyle => TextStyle(
      color: scholarity_color.scholarityAccent,
      decoration: TextDecoration.underline,
      fontSize: 14,
    );
TextStyle get scholarityTextPDimStyle => TextStyle(
      color: scholarity_color.grey,
      fontSize: 14,
    );
TextStyle get scholarityTextSmallStyle => TextStyle(
      height: 1.5,
      color: scholarity_color.black,
      fontSize: 14,
    );

class ScholarityTextH2 extends StatelessWidget {
  // members of MyWidget
  final String text;

  // constructor
  const ScholarityTextH2(this.text, {Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Text(translation_service.translate(text),
        style: scholarityTextH2Style);
  }
}

class ScholarityTextH2B extends StatelessWidget {
  // members of MyWidget
  final String text;

  // constructor
  const ScholarityTextH2B(this.text, {Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Text(translation_service.translate(text),
        style: scholarityTextH2BStyle);
  }
}

class ScholarityTextH3 extends StatelessWidget {
  // members of MyWidget
  final String text;
  final String? bracketText;

  // constructor
  const ScholarityTextH3(this.text, {Key? key, this.bracketText})
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
              color: scholarity_color.scholarityAccent,
            )),
        const SizedBox(width: 10),
        Text(translation_service.translate(bracketText ?? ""),
            style: TextStyle(
              fontSize: 14,
              color: scholarity_color.scholarityAccent,
            )),
      ],
    );
  }
}

class ScholarityTextH4 extends StatelessWidget {
  // members of MyWidget
  final String text;

  // constructor
  const ScholarityTextH4(this.text, {Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Text(translation_service.translate(text),
        style: scholarityTextH4Style);
  }
}

class ScholarityTextH5 extends StatelessWidget {
  // members of MyWidget
  final String text;
  final bool red;
  final bool dim;
  final bool bold;

  // constructor
  const ScholarityTextH5(this.text,
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
      //style: !bold ? scholarityTextH5Style : scholarityTextH5BStyle);
    } else {
      return quill.QuillEditor.basic(controller: _controller, readOnly: true);
    }
    */

    if (dim) {
      return Text(translation_service.translate(text),
          style: scholarityTextH5DimStyle);
    }
    if (!red) {
      return Text(translation_service.translate(text),
          style: !bold ? scholarityTextH5Style : scholarityTextH5BStyle);
    } else {
      return Text(translation_service.translate(text),
          style: !bold ? scholarityTextH5RedStyle : scholarityTextH5RedBStyle);
    }
  }
}

class ScholarityTextP extends StatelessWidget {
  // members of MyWidget
  final String text;
  final TextAlign? textAlign;
  final bool isDim;

  // constructor
  const ScholarityTextP(this.text,
      {Key? key, this.textAlign, this.isDim = false})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Text(translation_service.translate(text),
        textAlign: textAlign,
        style: !isDim ? scholarityTextPStyle : scholarityTextPDimStyle);
  }
}

class ScholarityDescriptor extends StatelessWidget {
  // members of MyWidget
  final String name;
  final String description;

  // constructor
  const ScholarityDescriptor(
      {Key? key, required this.name, this.description = ""})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        ScholarityTextH2B(name),
        description == "" ? Container() : ScholarityTextP(description),
        const SizedBox(height: 10),
      ],
    );
  }
}

class ScholarityTextBasic extends StatelessWidget {
  // members of MyWidget
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const ScholarityTextBasic(this.text, {Key? key, this.style, this.textAlign})
      : super(key: key);
  // main build function
  @override
  Widget build(BuildContext context) {
    return Text(translation_service.translate(text),
        style: style, textAlign: textAlign);
  }
}

class ScholarityTextSmall extends StatelessWidget {
  // members of MyWidget
  final String text;
  final TextAlign? textAlign;

  // constructor
  const ScholarityTextSmall(this.text, {Key? key, this.textAlign})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Text(translation_service.translate(text),
        textAlign: textAlign, style: scholarityTextSmallStyle);
  }
}
