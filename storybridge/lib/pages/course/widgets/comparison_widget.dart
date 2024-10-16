import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

import 'package:mooc/services/error_service.dart' as error_service;

class EditorWidgetMetadataController {
  EditorWidgetData editorWidgetData;
  EditorWidgetMetadata metadata;
  int auditTemplateId;
  EditorWidgetMetadataController(
      {required this.metadata,
      required this.auditTemplateId,
      required this.editorWidgetData});
}

class EditorWidgetMetadataPopup extends StatefulWidget {
  final EditorWidgetMetadataController controller;

  // constructor
  EditorWidgetMetadataPopup({
    Key? key,
    required this.controller,
  }) : super(key: key) {}

  @override
  State<EditorWidgetMetadataPopup> createState() =>
      _EditorWidgetMetadataPopupState();
}

class _EditorWidgetMetadataPopupState extends State<EditorWidgetMetadataPopup> {
  ScholarityTextFieldController _showIfFormulaController =
      ScholarityTextFieldController();

  void _save() {
    widget.controller.metadata.showIfs = _showIfFormulaController.text;
    widget.controller.editorWidgetData.onUpdate();
    Navigator.pop(context);
  }

  @override
  void initState() {
    _showIfFormulaController.text = widget.controller.metadata.showIfs;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScholarityIconButton(
              icon: Icons.close,
              onPressed: () {
                Navigator.pop(context);
              }),
          const SizedBox(height: 10),
          const ScholarityTextH2B("Show If"),
          ScholarityFormulaField(
            controller: _showIfFormulaController,
          ),
          ScholarityButton(
            text: "Save",
            onPressed: () {
              _save();
            },
          ),
          const ScholarityDivider(),
          const ScholarityTextH2B("Widget metadata"),
          ScholarityTextP("wuid: ${widget.controller.metadata.wuid}"),
          /*
          FutureBuilder(
              future: _load(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (!snapshot.hasData) {
                  return const ScholarityLoading();
                }
                return ScholarityFormulaField();
              })
              */
        ],
      ),
    );
  }
}

class ScholarityFormulaField extends StatefulWidget {
  // members of MyWidget
  final ScholarityTextFieldController controller;

  const ScholarityFormulaField({Key? key, required this.controller})
      : super(key: key);

  @override
  State<ScholarityFormulaField> createState() => _ScholarityFormulaFieldState();
}

class _ScholarityFormulaFieldState extends State<ScholarityFormulaField> {
  bool _isLoading = false;
  bool _isGoodSyntax = false;
  String _message = "";
  Future<void> _verify() async {
    setState(() {
      _isGoodSyntax = false;
      _message = "";
      _isLoading = true;
    });
    //widget.controller.clearError();
    try {
      setState(() {
        _isGoodSyntax = true;
        _isLoading = false;
      });
    } on error_service.ScholarityException catch (err) {
      setState(() {
        _message = err.message;
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    widget.controller.addListener(() {
      setState(() {
        _isGoodSyntax = false;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _message.isNotEmpty ? ScholarityTextP(_message) : Container(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: !_isLoading
                  ? SizedBox(
                      height: 120,
                      child: ScholarityTextField(
                        controller: widget.controller,
                        label: "formula",
                        isLarge: true,
                      ),
                    )
                  : const ScholarityBoxLoading(height: 100, width: 300),
            ),
            const SizedBox(width: 10),
            ScholarityIconButton(
              icon: _isGoodSyntax ? Icons.check : Icons.playlist_add_check,
              onPressed: () {
                _verify();
              },
            )
          ],
        ),
      ],
    );
  }
}
