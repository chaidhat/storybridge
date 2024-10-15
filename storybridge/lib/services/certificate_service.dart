import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/networking_service.dart' as networking_service;

// this is for certificate data SPECIFIC to EACH user
class CertificateUserInput {
  String name, jobTitle, company;
  int courseId, userId;
  int? profilePictureImageId;
  CertificateUserInput({
    required this.name,
    this.profilePictureImageId,
    required this.jobTitle,
    required this.company,
    required this.courseId,
    required this.userId,
  });
}

// this is for certificate data for ALL USERS in a course
class CertificateData {
  String? dateOfTraining;
  String? signeeName;
  String? signeePosition;
  CertificateData({this.dateOfTraining, this.signeeName, this.signeePosition});

  void loadFromString(String objStr) {
    Map<String, dynamic> obj = jsonDecode(objStr);
    dateOfTraining = obj["dateOfTraining"];
    signeeName = obj["signeeName"];
    signeePosition = obj["signeePosition"];
  }

  @override
  String toString() {
    Map<String, dynamic> obj = {
      "dateOfTraining": dateOfTraining,
      "signeeName": signeeName,
      "signeePosition": signeePosition
    };
    return jsonEncode(obj);
  }
}

Future<CertificateData> getCertificateData(int courseId) async {
  Map<String, dynamic> response =
      await networking_api_service.getCertificateData(courseId: courseId);
  if (response["data"].length == 0) {
    // this means there is no certificate data for this course.
    await networking_api_service.createCertificateData(
        courseId: courseId,
        certificateData: CertificateData(
                dateOfTraining: "date of training",
                signeeName: "Chayadhana Chaimongkol",
                signeePosition: "Managing Director")
            .toString());
    response =
        await networking_api_service.getCertificateData(courseId: courseId);
  }
  CertificateData output = CertificateData();
  output.loadFromString(Uri.decodeComponent(response["data"][0]["data"]));
  return output;
}

Future<void> updateCertificateData(
    int courseId, CertificateData certificateData) async {
  await networking_api_service.updateCertificateData(
      courseId: courseId, certificateData: certificateData.toString());
}

Future<void> _generateCertificate(
    PdfPageFormat format, CertificateUserInput data, pw.Document doc) async {
  ByteData image = await rootBundle
      .load('assets/certificate-backgrounds/Storybridge-certificate.jpg');
  Uint8List imageData = (image).buffer.asUint8List();
  pw.Font serifFont = await PdfGoogleFonts.sarabunMedium();
  pw.Font nameFont = await PdfGoogleFonts.sarabunMedium();
  pw.Font sansFont = await PdfGoogleFonts.sarabunRegular();

  // get the course data
  Map<String, dynamic> courseData =
      await networking_api_service.getCourse(courseId: data.courseId);
  String? courseName = Uri.decodeComponent(courseData["data"]["courseName"]);

  // get the organization data
  int organizationId = courseData["data"]["organizationId"];
  Map<String, dynamic> organizationData = await networking_api_service
      .getOrganization(organizationId: organizationId);
  String? companyName =
      Uri.decodeComponent(organizationData["data"]["organizationName"]);
  int? companyLogoImageId = organizationData["data"]["profilePictureImageId"];

  bool hasPicture = companyLogoImageId != null;
  String? companyLogoContentDataId;

  final netImage;

  // now load the content behind that logo imageId
  if (hasPicture) {
    Map<String, dynamic> imageData =
        await networking_api_service.getImage(imageId: companyLogoImageId);
    companyLogoContentDataId = imageData["data"]["contentDataId"];
    netImage = await networkImage(
        '${networking_service.getApiUrl()}?action=downloadImage&contentDataId=${companyLogoContentDataId}');
  } else {
    netImage = await networkImage(
        'https://www.iana.org/_img/2022/iana-logo-header.svg');
  }

  // get certificate data
  CertificateData certificateData = await getCertificateData(data.courseId);

  doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      build: (pw.Context context) {
        return pw.FullPage(
            ignoreMargins: true,
            child: pw.Stack(children: [
              pw.Image(pw.MemoryImage(imageData), fit: pw.BoxFit.fill),
              pw.Stack(children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(50),
                  child: pw.Image(netImage, height: 100),
                ),
                _PdfTextWidget(
                    x: 0,
                    y: 5,
                    text: "Certificate of Completion",
                    font: serifFont,
                    fontSize: 30),
                _PdfTextWidget(
                    x: 0,
                    y: 7.5,
                    text: "$companyName hereby certifies that",
                    font: sansFont,
                    fontSize: 20),
                _PdfTextWidget(
                    x: 0, y: 9, text: data.name, font: nameFont, fontSize: 40),
                _PdfTextWidget(
                    x: 0,
                    y: 11.5,
                    text: "Has succesfully completed the course",
                    font: sansFont,
                    fontSize: 20),
                _PdfTextWidget(
                    x: 0,
                    y: 13,
                    text: courseName,
                    font: nameFont,
                    fontSize: 30),
                _PdfTextWidget(
                    x: 0,
                    y: 15,
                    text: "Training on ${certificateData.dateOfTraining}",
                    font: sansFont,
                    fontSize: 20),
                _PdfTextWidget(
                    x: 8.5,
                    y: 17.3,
                    text: certificateData.signeeName ?? "ERROR",
                    font: sansFont,
                    fontSize: 18),
                _PdfTextWidget(
                    x: 8.5,
                    y: 18.1,
                    text: certificateData.signeePosition ?? "ERROR",
                    font: sansFont,
                    fontSize: 17),
              ])
            ]));
      }));
}

Future<Uint8List> _generatePassport(
    PdfPageFormat format, CertificateUserInput data) async {
  final doc = pw.Document();
  ByteData image =
      await rootBundle.load('assets/certificate-backgrounds/pt-card.jpg');
  Uint8List imageData = (image).buffer.asUint8List();
  pw.Font thaiFont = await PdfGoogleFonts.notoSansThaiRegular();
  pw.Font nameFont = await PdfGoogleFonts.notoSansThaiBold();

  // get certificate data
  final netImage;

  // now load the content behind that imageId
  bool hasProfilePicture =
      data.profilePictureImageId != null && data.profilePictureImageId != 0;

  if (hasProfilePicture) {
    Map<String, dynamic> imageData = await networking_api_service.getImage(
        imageId: data.profilePictureImageId!);
    String _imageContentDataId = imageData["data"]["contentDataId"];
    netImage = await networkImage(
      '${networking_service.getApiUrl()}?action=downloadImage&contentDataId=$_imageContentDataId',
    );
  } else {
    ByteData placeholderImage =
        await rootBundle.load('assets/images/default_user_profile_picture.jpg');
    Uint8List placeholderImageData = (placeholderImage).buffer.asUint8List();
    netImage = pw.MemoryImage(placeholderImageData);
    // now load the content behind that logo imageId
  }

  doc.addPage(pw.Page(
      pageFormat:
          const PdfPageFormat(85.5 * PdfPageFormat.mm, 54.0 * PdfPageFormat.mm),
      build: (pw.Context context) {
        return pw.FullPage(
            ignoreMargins: true,
            child: pw.Stack(children: [
              pw.Image(pw.MemoryImage(imageData), fit: pw.BoxFit.fill),
              pw.Stack(children: [
                _PdfTextWidget(
                    x: 3.5,
                    y: 0.4,
                    text:
                        "บัตรประจำตัว\nบริษัท พีทีจี เอ็นเนอยี จำกัด (มหาชน) ",
                    font: thaiFont,
                    textAlign: pw.TextAlign.left,
                    fontSize: 7),
                _PdfTextWidget(
                    x: 3.5,
                    y: 2,
                    text: data.name,
                    font: nameFont,
                    fontSize: 9,
                    textAlign: pw.TextAlign.left),
                _PdfTextWidget(
                    x: 3.5,
                    y: 2.5,
                    text: "${data.company}\n${data.jobTitle}",
                    font: thaiFont,
                    fontSize: 9,
                    textAlign: pw.TextAlign.left),
                _PdfPositionedWidget(
                    x: 0.52,
                    y: 1.6,
                    child: pw.SizedBox(
                        width: 2.2 * PdfPageFormat.cm,
                        height: 2.2 * PdfPageFormat.cm,
                        child: pw.BarcodeWidget(
                          color: PdfColor.fromHex("#000000"),
                          barcode: pw.Barcode.qrCode(),
                          data:
                              "https://www.Storybridge.io/app/#/user?id=${data.userId}",
                        ))),
                _PdfPositionedWidget(
                  x: 6.8,
                  y: 3.2,
                  child: pw.SizedBox(
                      width: 1.5 * PdfPageFormat.cm,
                      height: 2 * PdfPageFormat.cm,
                      child: pw.Image(netImage!, fit: pw.BoxFit.cover)),
                ),
              ])
            ]));
      }));

  return doc.save();
}

class _PdfTextWidget extends pw.StatelessWidget {
  // members of MyWidget
  final String text;
  final double x, y, fontSize;
  final pw.Font? font;
  final pw.TextAlign textAlign;

  // constructor
  _PdfTextWidget({
    required this.x,
    required this.y,
    required this.fontSize,
    required this.text,
    required this.font,
    this.textAlign = pw.TextAlign.center,
  });

  // main build function
  @override
  pw.Widget build(_) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: y * PdfPageFormat.cm),
          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.SizedBox(width: x * PdfPageFormat.cm),
            pw.Container(
                width: textAlign == pw.TextAlign.center
                    ? 29.7 * PdfPageFormat.cm
                    : null,
                child: pw.Text(
                  text,
                  textAlign: textAlign,
                  style: pw.TextStyle(
                    fontSize: fontSize,
                    font: font,
                  ),
                )),
          ]),
        ]);
  }
}

class _PdfPositionedWidget extends pw.StatelessWidget {
  // members of MyWidget
  final pw.Widget child;
  final double x, y;

  // constructor
  _PdfPositionedWidget({
    required this.x,
    required this.y,
    required this.child,
  });

  // main build function
  @override
  pw.Widget build(_) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: y * PdfPageFormat.cm),
          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.SizedBox(width: x * PdfPageFormat.cm),
            pw.Container(
              child: child,
            ),
          ]),
        ]);
  }
}

Future<void> printCertficate(CertificateUserInput data) async {
  final doc = pw.Document();
  await Printing.layoutPdf(onLayout: (format) async {
    await _generateCertificate(format, data, doc);
    return doc.save();
  });
}

Future<void> printAllCertficate(List<CertificateUserInput> data) async {
  final doc = pw.Document();
  await Printing.layoutPdf(onLayout: (format) async {
    for (int i = 0; i < data.length; i++) {
      print(i);
      await _generateCertificate(format, data[i], doc);
    }
    return doc.save();
  });
}

Future<void> printPassport(CertificateUserInput data) async {
  await Printing.layoutPdf(
      onLayout: (format) => _generatePassport(format, data));
}
