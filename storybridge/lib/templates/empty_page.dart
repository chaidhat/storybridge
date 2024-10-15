import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/Storybridge.dart'; // Storybridge

// myPage class which creates a state on call
class MyPage extends StatefulWidget {
  final int x;
  const MyPage({Key? key, required this.x}) : super(key: key);

  @override
  MyPageState createState() => MyPageState();
}

// myPage state
class MyPageState extends State<MyPage> {
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
    int x2 = widget.x * 2;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Page"),
      ),
      body: Container(),
    );
  }
}

class MyPageWithFuture extends StatefulWidget {
  final int organizationId;
  const MyPageWithFuture({Key? key, required this.organizationId})
      : super(key: key);

  @override
  MyPageWithFutureState createState() => MyPageWithFutureState();
}

// myPage state
class MyPageWithFutureState extends State<MyPageWithFuture> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _load() async {
    /*
    // pull data from server
    Map<String, dynamic> response = await networking_api_service.
    return response["data"];
    */
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    return FutureBuilder(
        future: _load(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            // data has not loaded yet, show loading page
            return const StorybridgePageLoading();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(),
            ],
          );
        });
  }
}
