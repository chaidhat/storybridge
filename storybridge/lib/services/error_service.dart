import 'package:flutter/material.dart';
import 'package:mooc/storybridge.dart'; // Storybridge

final navigatorKey = GlobalKey<NavigatorState>();

class StorybridgeException implements Exception {
  String message;
  Map<String, dynamic>? errorData;
  String? description;
  bool expandError;
  StorybridgeException(this.message,
      {this.description, this.expandError = true, this.errorData});
}

void reportError(StorybridgeException error, BuildContext context) {
  if (!error.expandError) return;
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => StorybridgeAlertDialogWrapper(
      child: StorybridgeAlertDialog(
        title: StorybridgeTextBasic(error.message),
        content: SizedBox(
            width: 250,
            child: StorybridgeTextBasic(
                error.description ?? "No description given.")),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const StorybridgeTextBasic('Dismiss'),
          ),
        ],
      ),
    ),
  );
}

class Alert {
  String title, description, buttonName, prefillInputText;
  bool acceptInput, isLarge, allowCancel;
  Function(String input) callback;
  Alert(
      {required this.title,
      required this.description,
      required this.buttonName,
      required this.callback,
      this.prefillInputText = "",
      this.isLarge = false,
      this.acceptInput = false,
      this.allowCancel = false}) {
    _alertInputController.text = prefillInputText;
  }
}

Alert? alertQueued;
bool isRunningAlert = false;
void alert(Alert alertMessage) {
  alertQueued = alertMessage;
}

final _alertInputController = StorybridgeTextFieldController();

// stupid code
// delete later maybe
void checkAlerts(BuildContext bc) async {
  if (alertQueued != null && !isRunningAlert) {
    isRunningAlert = true;
    bool isSubmit = false;
    await Future.delayed(const Duration(milliseconds: 100), () {});
    await showDialog<String>(
      context: bc,
      builder: (BuildContext context) => StorybridgeAlertDialogWrapper(
        child: StorybridgeAlertDialog(
          title: StorybridgeTextH2B(alertQueued!.title),
          content: SizedBox(
              width: !alertQueued!.isLarge ? 250 : 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StorybridgeTextP(alertQueued!.description),
                  const SizedBox(height: 20),
                  alertQueued!.acceptInput
                      ? SizedBox(
                          height: !alertQueued!.isLarge ? null : 120,
                          child: StorybridgeTextField(
                            label: "",
                            isLarge: alertQueued!.isLarge,
                            controller: _alertInputController,
                          ),
                        )
                      : Container(),
                ],
              )),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                isSubmit = true;
              },
              child: StorybridgeTextBasic(alertQueued!.buttonName),
            ),
            alertQueued!.allowCancel
                ? TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const StorybridgeTextBasic('Cancel'),
                  )
                : Container(),
          ],
        ),
      ),
    );
    Function callback = alertQueued!.callback;
    alertQueued = null;
    isRunningAlert = false;
    if (isSubmit) callback(_alertInputController.text);
  }
}
