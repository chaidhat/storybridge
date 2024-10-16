import 'package:flutter/material.dart';

List<StorybridgeFocusController> focusControllers = [];

void _registerFocusNode(StorybridgeFocusController focusController) {
  focusControllers.add(focusController);
}

void _deregisterFocusNode(StorybridgeFocusController focusController) {
  focusControllers.remove(focusController);
}

int _highestZ = 0;
void _globalUpdateFocus(
    bool hasFocus, StorybridgeFocusController focusController) async {
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

class StorybridgeFocusController {
  late void Function() update;
  bool hasFocus = false;
  int? z;

  StorybridgeFocusController();
}

class StorybridgeFocusNode {
  late void Function() requestFocus;
  late void Function() unfocus;
  bool hasFocus = false;
  StorybridgeFocusNode();
}

// myPage class which creates a state on call
class StorybridgeFocus extends StatefulWidget {
  final StorybridgeFocusBuilder builder;
  final void Function(bool hasFocus) onFocusChange;
  final StorybridgeFocusNode storybridgeFocusNode;
  final StorybridgeFocusController storybridgeFocusController =
      StorybridgeFocusController();
  final int z;
  StorybridgeFocus({
    Key? key,
    required this.builder,
    required this.onFocusChange,
    required this.storybridgeFocusNode,
    required this.z,
  }) : super(key: key) {
    storybridgeFocusController.z = z;
    _registerFocusNode(storybridgeFocusController);
  }

  @override
  _StorybridgeFocusState createState() => _StorybridgeFocusState();
}

// myPage state
class _StorybridgeFocusState extends State<StorybridgeFocus> {
  @override
  void dispose() {
    _deregisterFocusNode(widget.storybridgeFocusController);
    super.dispose();
  }

  void _requestFocus() {
    _globalUpdateFocus(true, widget.storybridgeFocusController);
  }

  void _unfocus() {
    _globalUpdateFocus(false, widget.storybridgeFocusController);
  }

  void _onControllerUpdate() {
    setState(() {
      bool hasFocus = widget.storybridgeFocusController.hasFocus;
      widget.onFocusChange(hasFocus);
      widget.storybridgeFocusNode.hasFocus = hasFocus;
    });
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    widget.storybridgeFocusNode.requestFocus = _requestFocus;
    widget.storybridgeFocusNode.unfocus = _unfocus;

    widget.storybridgeFocusController.update = _onControllerUpdate;
    return Focus(
      onFocusChange: (bool hasFocus) {
        _globalUpdateFocus(hasFocus, widget.storybridgeFocusController);
      },
      child: GestureDetector(
        onTap: () {
          _globalUpdateFocus(true, widget.storybridgeFocusController);
        },
        child: widget.builder
            .builder(context, widget.storybridgeFocusController.hasFocus),
      ),
    );
  }
}

class StorybridgeFocusBuilder {
  late Widget Function(BuildContext context, bool isFocused) builder;
  StorybridgeFocusBuilder({required this.builder});
}

class StorybridgeFocusDismisser extends StatelessWidget {
  // members of MyWidget
  final Widget child;

  // constructor
  const StorybridgeFocusDismisser({Key? key, required this.child})
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
