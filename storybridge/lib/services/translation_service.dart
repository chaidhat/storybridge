import 'dart:html';
import 'package:intl/intl.dart';
import 'package:mooc/style/scholarity_colors.dart' as scholarity_color;

import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

enum Language { english, thai, deutsch }

const Map<Language, String> LANGUAGE_TO_STRING = {
  Language.english: "en",
  Language.thai: "th",
  Language.deutsch: "de",
};

const Map<String, String> ENGLISH_TO_THAI = {
  // general
  "date created": "วันที่สร้าง",
  "date modified": "วันที่แก้ไข",
  "delete": "ลบ",
  "edit": "แก้ไข",
  "view": "ดู",
  "search": "ค้นหา",
  "category": "หมวดหมู่",
  "name": "ชื่อ",
  "first name": "ชื่อจริง",
  "last name": "นามสกุล",
  "this table is empty!": "ตารางนี้ว่างเปล่า",
  "get login/register link": "รับลิงก์เข้าสู่ระบบ/ลงทะเบียน",
  "today": "วันนี้",
  "yesterday": "เมื่อวาน",
  "tomorrow": "พรุ่งนี้",
  "jan": "ม.ค.",
  "feb": "ก.พ.",
  "mar": "มี.ค.",
  "apr": "เม.ย.",
  "may": "พ.ค.",
  "jun": "มิ.ย.",
  "jul": "ก.ค.",
  "aug": "ส.ค.",
  "sep": "ก.ย.",
  "oct": "ต.ค.",
  "nov": "พ.ย.",
  "dec": "ธ.ค.",

  // Auth
  "log into existing account.": "เข้าสู่บัญชีที่มีอยู่",
  "log into existing account": "เข้าสู่บัญชีที่มีอยู่",
  "create a free account": "สร้างบัญชีใหม่",
  "create a new account": "สร้างบัญชีใหม่",
  "sign in": "เข้าสู่ระบบ",
  "login": "เข้าสู่ระบบ",
  "register": "ลงทะเบียน",
  "i accept scholarity's terms of use and privacy notice.\nby creating an account, you agree to those terms.":
      "ฉันยอมรับข้อกำหนดการใช้งานและประกาศความเป็นส่วนตัวของ Scholarity โดยการสร้างบัญชี คุณตกลงตามข้อกำหนดเหล่านั้น",

  // Organization Page
  "courses": "หลักสูตร",
  "audits": "การตรวจสอบ",
  "people": "จัดการผู้ใช้",
  "fleet": "กองยานพาหนะ",
  "sales": "การขาย",
  "settings": "การตั้งค่า",
  // Organization Page, Courses
  "new": "สร้างใหม่",
  "e-learning system": "ระบบการเรียนรู้ออนไลน์",
  "empower your team with our intuitive e-learning system, allowing teachers to effortlessly create engaging online training videos for employees. enhance your workforce's skills and compliance with ease and efficiency.":
      "เพิ่มพลังให้กับทีมของคุณด้วยระบบการเรียนรู้ออนไลน์ที่ใช้งานง่ายของเรา ที่ช่วยให้ครูสามารถสร้างวิดีโอการฝึกอบรมออนไลน์ที่น่าสนใจสำหรับพนักงานได้อย่างง่ายดาย ยกระดับทักษะและการปฏิบัติตามกฎระเบียบของทีมงานของคุณได้อย่างสะดวกและมีประสิทธิภาพ",
  "auditing system": "ระบบการเรียนรู้ออนไลน์",
  "simplify your inspection, auditing and reporting workflows with our advanced auditing system. enhance accuracy and compliance in your organization with our user-friendly tools.":
      "ทำให้การตรวจสอบ การตรวจสอบบัญชี และการรายงานของคุณง่ายขึ้นด้วยระบบตรวจสอบขั้นสูงของเรา เพิ่มความแม่นยำและการปฏิบัติตามกฎระเบียบในองค์กรของคุณด้วยเครื่องมือที่ใช้งานง่ายของเรา",
  "fleet system": "ระบบการจัดการกองยานพาหนะ",
  "our fleet management system provides the tools you need to efficiently oversee your vehicle operations. from real-time tracking to maintenance scheduling, it ensures your fleet runs smoothly, safely, and in full compliance.":
      "ระบบการจัดการกองยานพาหนะของเรามีเครื่องมือที่คุณต้องการเพื่อดูแลการดำเนินงานของยานพาหนะอย่างมีประสิทธิภาพ ตั้งแต่การติดตามแบบเรียลไทม์ไปจนถึงการจัดตารางการบำรุงรักษา ระบบของเราช่วยให้กองยานพาหนะของคุณทำงานได้อย่างราบรื่น ปลอดภัย และเป็นไปตามกฎระเบียบอย่างเต็มที่",

  // Organization Page, Audits
  "audit templates": "แม่แบบการตรวจสอบ",
  "template type": "แม่แบบการตรวจสอบ",

  // Organization Page, People
  "users": "ผู้ใช้องค์กร",
  "students": "ผู้ใช้องค์กร",
  "teachers": "อาจารย์",
  "coordinators": "ผู้ประสานงานของบริษัท",
  "coordinator groups": "บริษัท",
  // Organization Page, People, students
  "edit student fields": "ก้ไขข้อมูลนักเรียน",
  "add student fields": "สร้างใหม่",
  "pre-register students": "ลงทะเบียนล่วงหน้า",
  "add coordinator group": "สร้างใหม่",
  "assign coordinators": "มอบหมายผู้ประสานงาน",
  "assign coordinator to coordinator group": "มอบหมายผู้ประสานงาน",
  // Organization Page, Sales
  "balance": "ยอดคงเหลือ",
  "your balance": "ยอดคงเหลือ",
  "withdraw to bank account": "ถอนเข้าบัญชีธนาคาร",
  "withdrawal history": "ประวัติการถอน",
  // Organization Page, Settings
  "organization name": "ชื่อองค์กร",
  "organization email": "อีเมลขององค์กร",
  "organization logo": "อีเมลขององค์กร",
  "save": "บันทึก",
  "upload profile picture": "อัพโหลดรูปภาพ",
  "your plan:": "ระดับ",
  "manage payment info": "ตั้งค่า",

  // Course Page, Admin
  "editor": "จัดการหลักสูตร",
  "analytics": "การวิเคราะหลักสูตร",
  "share": "แชร์",

  // Course Page, Admin editor
  "front page": "หน้าต้อนรับ",
  "add page": "เพิ่มหน้า",
  "add section": "เพิ่มบท",
  "front page widgets": "วิดเจ็ตสำหรับหน้าต้อนรับ",
  "drag & drop widgets": "ลากและวางวิดเจ็ต",
  "text": "ข้อความ",
  "header": "ส่วนหัว",
  "spacer": "ตัวเว้นวรรค",
  "notice": "ประกาศ",
  "text field": "ช่องข้อความ",
  "image": "รูปภาพ",
  "video": "วิดีโอ",
  "button": "ปุ่ม",
  "enroll widget": "วิดเจ็ตลงทะเบียน",

  // Course Page, Admin analytics
  "assessments": "การทดสอบ",
  "link to your course:": "ลิงก์ไปยังหลักสูตรของคุณ",
  "go to your course!": "ไปที่หลักสูตรของคุณ",
  "dismiss": "ปิด",
  "cancel": "ปิด",

  // Course Page, Students
  "course": "หลักสูตร",
  "grades": "คะแนนสอบ",

  // Course Page, Students, Course
  "enroll now": "ลงทะเบียน",
  "resume course": "เริ่มต้นหลักสูตร",
  "assessment": "การทดสอบ",
  "next question": "คำถามถัดไป",
  "previous question": "คำถามก่อนหน้า",
  "question": "คำถาม",
  "you have finished watching this video.": "คุณดูวิดีโอนี้จบแล้ว",

  // Course Page, Students, Grades
  "course passed": "ผ่านหลักสูตร",
  "not passed": "ยังไม่ผ่านหลักสูตร",
  "total grade:": "คะแนนสอบสะสม",
  "assessments passed:": "จำนวนการทดสอบที่ผ่าน",
  "print certificate": "พริ้นท์ใบรับรอง",
  "print passport": "พริ้นท์พาสปอร์ต",
  "score:": "คะแนน",
  "weighting:": "น้ำหนัก",
  "weighted score:": "คะแนนถ่วงน้ำหนัก",

  // audit page
  "audit": "การตรวจสอบ",
  "workflow": "เวิร์คโฟลว์",
  "permissions": "สิทธิ์",
  "assign user": "มอบหมายผู้ใช้",
  "answer widgets": "วิดเจ็ตคำตอบ",
  "question widgets": "วิดเจ็ตคำถาม",
  "dropdown": "ดรอปดาวน์",
  "checkbox": "เช็คบ็อกซ์",
  "buttons": "ปุ่ม",
  "date time": "วันที่และเวลา",
  "file upload": "อัปโหลดไฟล์",
  "status": "สถานะ",
  "custom lists": "รายการที่กำหนดเอง",
  "summary": "สรุป",
  "accept": "ยอมรับ",
  "submit": "ส่ง",

  // user pages
  "profile": "โปรไฟล์",
  "logout": "ออกจากระบบ",
  "my courses": "หลักสูตรของฉัน",
  "my files": "ไฟล์ของฉัน",
  "my audits": "การตรวจสอบของฉัน",
  "flight plan": "แผนการบิน",
  "support": "ศูนย์ช่วยเหลือ",

  // user pages, settings
  "profile photo": "รูปโปรไฟล์",
  "email": "อีเมล",
  "full name": "ชื่อเต็ม",
  "telephone": "โทรศัพท์",
  "jobtitle": "ตำแหน่งงาน",
  "company": "บริษัท",
  "employeeid": "รหัสพนักงาน",
  "view pdpa": "ดู PDPA",
  "you will be redirected to a website to read the pdpa.":
      "คุณจะถูกเปลี่ยนเส้นทางไปยังเว็บไซต์เพื่ออ่าน PDPA",
  "do you accept the pdpa?": "คุณยอมรับ PDPA ไหม?",
  "approve": "ยอมรับ",
  "reject": "ไม่ยอมรับ",
  "pdpa accepted": "PDPA OK",
  "pdpa not accepted yet": "ยังไม่ได้รับ PDPA",
  "password": "รหัสผ่าน",
  "change password": "เปลี่ยนรหัสผ่าน",
  "old password": "รหัสผ่านเก่า",
  "new password": "รหัสผ่านใหม่",
  "retype new password": "พิมพ์รหัสผ่านใหม่อีกครั้ง",
  "change profile picture": "เปลี่ยนรูปโปรไฟล์",
  "upload picture": "อัพโหลดรูปภาพ",
  "take photo": "ถ่ายภาพด้วยกล้อง",
  "please scroll down to bottom page before accepting.":
      " คุณต้องเลื่อนลงไปจนถึงหน้าสุดท้ายก่อนที่จะยอมรับ",
  "subdistrict": "ตำบล/แขวง",
  "district": "อำเภอ/เขต",
  "province": "จังหวัด",

  "no data to be shown": "ไม่มีข้อมูล",
  "download": "ดาวน์โหลด",
  "expiry date:": "วันหมดอายุ",
};

const Map<String, String> ENGLISH_TO_GERMAN = {
  // Auth
  "log into existing account.": "In bestehenden Account einloggen.",
  "log into existing account": "In bestehenden Account einloggen",
  "create a free account": "Ein kostenloses Konto erstellen",
  "create a new account": "Ein neues Konto erstellen",
  "sign in": "Anmelden",
  "login": "Anmelden",
  "register": "Registrieren",
  "i accept scholarity's terms of use and privacy notice.\nby creating an account, you agree to those terms.":
      "Ich akzeptiere die Nutzungsbedingungen und die Datenschutzerklärung von Scholarity.\nDurch die Erstellung eines Kontos stimmen Sie diesen Bedingungen zu.",

  // Organization Page
  "courses": "Kurse",
  "people": "Personen",
  "sales": "Verkäufe",
  "settings": "Einstellungen",

  // Organization Page, Courses
  "new": "Neu",

  // Organization Page, People
  "students": "Schüler",
  "teachers": "Lehrer",
  "coordinators": "Koordinatoren",
  "coordinator groups": "Koordinatorengruppen",

  // Organization Page, People, students
  "edit student fields": "Schülerfelder bearbeiten",
  "add student fields": "Schülerfelder hinzufügen",
  "pre-register students": "Schüler vorab registrieren",
  "edit": "Bearbeiten",
  "view": "Anzeigen",
  "add coordinator group": "Koordinatorengruppe hinzufügen",
  "assign coordinators": "Koordinatoren zuweisen",
  "assign coordinator to coordinator group":
      "Koordinator der Koordinatorengruppe zuweisen",

  // Organization Page, Sales
  "balance": "Guthaben",
  "your balance": "Ihr Guthaben",
  "withdraw to bank account": "Auf Bankkonto abheben",
  "withdrawal history": "Abhebungshistorie",

  // Organization Page, Settings
  "organization name": "Name der Organisation",
  "organization email": "E-Mail der Organisation",
  "organization logo": "Logo der Organisation",
  "save": "Speichern",
  "upload profile picture": "Profilbild hochladen",
  "your plan:": "Ihr Plan:",
  "manage payment info": "Zahlungsinformationen verwalten",

  // Course Page, Admin
  "editor": "Editor",
  "analytics": "Analytik",
  "share": "Teilen",

  // Course Page, Admin editor
  "front page": "Startseite",
  "add page": "Seite hinzufügen",
  "add section": "Abschnitt hinzufügen",
  "front page widgets": "Widgets für die Startseite",
  "drag & drop widgets": "Widgets per Drag & Drop hinzufügen",

  // Course Page, Admin analytics
  "assessments": "Bewertungen",
  "link to your course:": "Link zu Ihrem Kurs:",
  "go to your course!": "Gehe zu Ihrem Kurs!",
  "dismiss": "Schließen",

  // Course Page, Students
  "course": "Kurs",
  "grades": "Noten",

  // Course Page, Students, Course
  "enroll now": "Jetzt anmelden",
  "resume course": "Kurs fortsetzen",
  "assessment": "Bewertung",
  "next question": "Nächste Frage",
  "previous question": "Vorherige Frage",
  "question": "Frage",
  "you have finished watching this video.": "Sie haben dieses Video angesehen.",

  // Course Page, Students, Grades
  "course passed": "Kurs bestanden",
  "not passed": "Nicht bestanden",
  "total grade:": "Gesamtbewertung:",
  "assessments passed:": "Bestandene Bewertungen:",
  "print certificate": "Zertifikat drucken",
  "print passport": "Pass drucken",
  "score:": "Punktzahl:",
  "weighting:": "Gewichtung:",
  "weighted score:": "Gewichtete Punktzahl:",

  // user pages
  "profile": "Profil",
  "logout": "Abmelden",
  "my courses": "Meine Kurse",
  "my files": "Meine Dateien",
  "help center": "Hilfezentrum",

  // user pages, settings
  "profile photo": "Profilfoto",
  "email": "E-Mail",
  "full name": "Vollständiger Name",
  "telephone": "Telefonnummer",
  "jobtitle": "Berufsbezeichnung",
  "company": "Firma",
  "employeeid": "Mitarbeiterausweis",
  "view pdpa": "PDPA anzeigen",
  "you will be redirected to a website to read the pdpa.":
      "Sie werden zu einer Website weitergeleitet, um das PDPA zu lesen.",
  "do you accept the pdpa?": "Akzeptieren Sie das PDPA?",
  "approve": "Akzeptieren",
  "reject": "Ablehnen",
  "pdpa accepted": "PDPA akzeptiert",
  "pdpa not accepted yet": "PDPA noch nicht akzeptiert",
  "password": "Passwort",
  "change password": "Passwort ändern",
  "old password": "Altes Passwort",
  "new password": "Neues Passwort",
  "retype new password": "Neues Passwort erneut eingeben",
};

Language globalLanguage = Language.thai;
final Storage _localStorage = window.localStorage;
const Language DEFAULT_LANGUAGE = Language.thai;

void getStorageLanguage() {
  // attempt to get admin token from local storage
  if (_localStorage['lang'] != null) {
    globalLanguage = DEFAULT_LANGUAGE;
    LANGUAGE_TO_STRING.forEach((Language key, String value) {
      if (value == _localStorage['lang']) {
        globalLanguage = key;
      }
    });
  } else {
    globalLanguage = DEFAULT_LANGUAGE;
  }
}

void setLanguage(Language newLanguage) {
  globalLanguage = newLanguage;
  _localStorage['lang'] = LANGUAGE_TO_STRING[newLanguage] ?? "";
}

String translate(String input) {
  switch (globalLanguage) {
    case Language.thai:
      return ENGLISH_TO_THAI[input.toLowerCase()] ?? input;
    case Language.deutsch:
      return ENGLISH_TO_GERMAN[input.toLowerCase()] ?? input;
    case Language.english:
    default:
      return input;
  }
}

String getDate(DateTime datetime) {
  DateTime now = DateTime.now();
  /*
  We must calculate whether a date can land on TODAY, YESTERDAY, TOMORROW or other.
  */
  DateTime todayAtMidnight = DateTime(now.year, now.month, now.day);
  Duration dateDelta = datetime.difference(todayAtMidnight);
  // if datetime is SOONER than todayAtMidnight then dateDelta is NEGATIVE
  // if datetime is AFTER than todayAtMidnight then dateDelta is POSITIVE
  if (globalLanguage == Language.thai) {
    if (dateDelta.inHours >= -24 && dateDelta.inHours < 0) {
      return "เมื่อวาน ${DateFormat('H:mm').format(datetime)} น.";
    } else if (dateDelta.inHours >= 0 && dateDelta.inHours < 24) {
      return "วันนี้ ${DateFormat('H:mm').format(datetime)} น.";
    } else if (dateDelta.inHours >= 24 && dateDelta.inHours < 48) {
      return "พรุ่งนี้ ${DateFormat('H:mm').format(datetime)} น.";
    } else {
      return "${DateFormat('d').format(datetime)} ${translate(DateFormat('MMM').format(datetime))} ${DateFormat('yyyy H:mm').format(datetime)} น.";
    }
  } else {
    if (dateDelta.inHours >= -24 && dateDelta.inHours < 0) {
      return "Yesterday ${DateFormat('h:mm a').format(datetime)}";
    } else if (dateDelta.inHours >= 0 && dateDelta.inHours < 24) {
      return "Today ${DateFormat('h:mm a').format(datetime)}";
    } else if (dateDelta.inHours >= 24 && dateDelta.inHours < 48) {
      return "Tomorrow ${DateFormat('h:mm a').format(datetime)}";
    } else {
      return DateFormat('MMM d, yyyy h:mm a').format(datetime);
    }
  }
}

class LanguageFab extends StatelessWidget {
  // constructor
  const LanguageFab({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: scholarity_color.background,
      tooltip: "Language",
      onPressed: () {
        showDialog<String>(
            context: context,
            builder: (BuildContext context) => _LanguageDialog());
      },
      child: Icon(Icons.language_rounded, color: scholarity_color.black),
    );
  }
}

class _LanguageDialog extends StatelessWidget {
  // constructor
  const _LanguageDialog({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return ScholarityAlertDialogWrapper(
      child: ScholarityAlertDialog(
        content: SizedBox(
          width: 300,
          child: Column(
            children: [
              const SizedBox(height: 20),
              const ScholarityTile(
                child: ScholarityPadding(
                  child: IntrinsicHeight(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LanguageDialogButton(
                            language: Language.english,
                            languageName: "English",
                          ),
                          ScholarityDivider(),
                          _LanguageDialogButton(
                            language: Language.thai,
                            languageName: "ภาษาไทย",
                          ),
                          ScholarityDivider(),
                          _LanguageDialogButton(
                            language: Language.deutsch,
                            languageName: "ဗမာဘာသာစကား",
                          ),
                          ScholarityDivider(),
                          _LanguageDialogButton(
                            language: Language.deutsch,
                            languageName: "ភាសាខ្មែរ",
                          ),
                        ]),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ScholarityButton(
                      padding: false,
                      text: "Dismiss",
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageDialogButton extends StatelessWidget {
  // members of MyWidget
  final Language language;
  final String languageName;
  final bool isExperimental;

  // constructor
  const _LanguageDialogButton(
      {Key? key,
      required this.language,
      required this.languageName,
      this.isExperimental = false})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.pushNamed(context, "/reload");
          setLanguage(language);
        },
        child: SizedBox(
            height: 50,
            child: Align(
                alignment: Alignment.centerLeft,
                child: ScholarityTextH2B(languageName))));
  }
}
