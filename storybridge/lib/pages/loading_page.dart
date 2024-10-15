import 'package:flutter/material.dart';

// myPage class which creates a state on call
class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<LoadingPage> {
  bool _visible = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> waitToShow() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!_isDisposed) {
      setState(() {
        _visible = true;
      });
    }
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    waitToShow();
    // ignore: unused_local_variable
    return Scaffold(
        body: Center(
      child: AnimatedOpacity(
          opacity: _visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          child: const CircularProgressIndicator()),
    ));
  }
}
