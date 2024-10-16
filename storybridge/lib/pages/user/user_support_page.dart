import 'package:flutter/material.dart';
import 'package:mooc/scholarity.dart'; // Scholarity

// myPage class which creates a state on call
class UserSupportPage extends StatefulWidget {
  final int userId;
  const UserSupportPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserSupportPageState createState() => _UserSupportPageState();
}

// myPage state
class _UserSupportPageState extends State<UserSupportPage> {
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
    return ScholarityTabPage(body: [
      const SizedBox(height: 40),
      Row(
        children: [
          const Icon(
            Icons.phone_rounded,
            size: 40,
          ),
          const SizedBox(width: 10),
          const ScholarityTextH2B("081 325 3809"),
        ],
      ),
    ]);
  }
}
