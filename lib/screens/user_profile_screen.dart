import 'package:flutter/material.dart';
import 'package:vertical_flutter/resources/auth_methods.dart';
import 'package:vertical_flutter/screens/login_screen.dart';
import 'package:vertical_flutter/utils/utils.dart';

import '../utils/colors.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  void logout() async {
    await AuthMethods().signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: logout,
      child: Text("sign out"),
    );
  }
}
