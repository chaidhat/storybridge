import 'package:flutter/material.dart';

// myPage class which creates a state on call
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 200),
          const SizedBox(
              height: 70,
              child: Image(
                  fit: BoxFit.fill, image: AssetImage('assets/logo-1.png'))),
          Container(),
        ],
      ),
    );
  }
}
