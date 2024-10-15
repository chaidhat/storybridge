import 'package:mooc/services/networking_api_service.dart'
    as networking_api_service;
import 'package:mooc/services/auditing_service.dart' as auditing_service;

List<ShowIfController> showIfControllers = [];

String preprocessFormula(String formula) {
  formula = formula.replaceAll(
      "AUDIT_TASK_ID", auditing_service.getAuditTaskId().toString());
  return formula;
}

ShowIfController getShowIfController(String formula) {
  for (int i = 0; i < showIfControllers.length; i++) {
    if (showIfControllers[i].formula == formula) {
      return showIfControllers[i];
    }
  }
  return ShowIfController(formula: formula);
}

class ShowIfController {
  String formula;
  final List<Function(bool)> listeners = [];
  bool isShowing = true;

  ShowIfController({required this.formula}) {
    showIfControllers.add(this);
  }

  Future<void> evaluate() async {
    bool newIsShowing = false;
    try {
      Map<String, dynamic> response = await networking_api_service
          .executeFormula(formula: preprocessFormula(formula));
      if (response["data"]["valueType"] != "boolean") {
        return;
      }
      newIsShowing = response["data"]["value"];
      if (newIsShowing != isShowing) {
        isShowing = newIsShowing;
        for (int i = 0; i < listeners.length; i++) {
          listeners[i](newIsShowing);
        }
      }
    } catch (_) {}
  }

  void addListener(Function(bool) onUpdate) {
    listeners.add(onUpdate);
  }
}

void updateAllShowifs() {
  for (int i = 0; i < showIfControllers.length; i++) {
    showIfControllers[i].evaluate();
  }
}
