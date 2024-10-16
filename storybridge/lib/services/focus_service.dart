import 'package:flutter/material.dart';

List<ScholarityFocusController> focusControllers = [];

void _registerFocusNode(ScholarityFocusController focusController) {
  focusControllers.add(focusController);
}

void _deregisterFocusNode(ScholarityFocusController focusController) {
  focusControllers.remove(focusController);
}

int _highestZ = 0;
void _globalUpdateFocus(
    bool hasFocus, ScholarityFocusController focusController) async {
  int z = focusController.z ?? 0;
  if (z > _highestZ) {
    _highestZ = z;
  }

  // wait for all update focuses to come in
  // this is because if they overlap, both of them are called
  await Future.delayed(const Duration(milliseconds: 1));
  // only the top focus node should get focused
  if (z != _highestZ) return;

  for (int i = 0; i < focusControllers.length; i++) {
    if (focusControllers[i] == focusController) {
      // focus on that element
      if (focusControllers[i].hasFocus != hasFocus) {
        focusControllers[i].hasFocus = hasFocus;
        focusControllers[i].update();
      }
    } else {
      // unfocus everything else
      if (focusControllers[i].hasFocus) {
        focusControllers[i].hasFocus = false;
        focusControllers[i].update();
      }
    }
  }

  // reset highest Z
  _highestZ = 0;
}

void _globalUnfocusAll() {
  for (int i = 0; i < focusControllers.length; i++) {
    // unfocus everything else
    if (focusControllers[i].hasFocus) {
      focusControllers[i].hasFocus = false;
      focusControllers[i].update();
    }
  }
}

class ScholarityFocusController {
  late void Function() update;
  bool hasFocus = false;
  int? z;

  ScholarityFocusController();
}

class ScholarityFocusNode {
  late void Function() requestFocus;
  late void Function() unfocus;
  bool hasFocus = false;
  ScholarityFocusNode();
}

// myPage class which creates a state on call
class ScholarityFocus extends StatefulWidget {
  final ScholarityFocusBuilder builder;
  final void Function(bool hasFocus) onFocusChange;
  final ScholarityFocusNode scholarityFocusNode;
  final ScholarityFocusController scholarityFocusController =
      ScholarityFocusController();
  final int z;
  ScholarityFocus({
    Key? key,
    required this.builder,
    required this.onFocusChange,
    required this.scholarityFocusNode,
    required this.z,
  }) : super(key: key) {
    scholarityFocusController.z = z;
    _registerFocusNode(scholarityFocusController);
  }

  @override
  _ScholarityFocusState createState() => _ScholarityFocusState();
}

// myPage state
class _ScholarityFocusState extends State<ScholarityFocus> {
  @override
  void dispose() {
    _deregisterFocusNode(widget.scholarityFocusController);
    super.dispose();
  }

  void _requestFocus() {
    _globalUpdateFocus(true, widget.scholarityFocusController);
  }

  void _unfocus() {
    _globalUpdateFocus(false, widget.scholarityFocusController);
  }

  void _onControllerUpdate() {
    setState(() {
      bool hasFocus = widget.scholarityFocusController.hasFocus;
      widget.onFocusChange(hasFocus);
      widget.scholarityFocusNode.hasFocus = hasFocus;
    });
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    widget.scholarityFocusNode.requestFocus = _requestFocus;
    widget.scholarityFocusNode.unfocus = _unfocus;

    widget.scholarityFocusController.update = _onControllerUpdate;
    return Focus(
      onFocusChange: (bool hasFocus) {
        _globalUpdateFocus(hasFocus, widget.scholarityFocusController);
      },
      child: GestureDetector(
        onTap: () {
          _globalUpdateFocus(true, widget.scholarityFocusController);
        },
        child: widget.builder
            .builder(context, widget.scholarityFocusController.hasFocus),
      ),
    );
  }
}

class ScholarityFocusBuilder {
  late Widget Function(BuildContext context, bool isFocused) builder;
  ScholarityFocusBuilder({required this.builder});
}

class ScholarityFocusDismisser extends StatelessWidget {
  // members of MyWidget
  final Widget child;

  // constructor
  const ScholarityFocusDismisser({Key? key, required this.child})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          _globalUnfocusAll();
        },
        child: child);
  }
}
