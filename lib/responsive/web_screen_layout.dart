import 'package:flutter/material.dart';
import 'package:vertical_flutter/utils/colors.dart';

class WebScreenLayout extends StatelessWidget {
  const WebScreenLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: webBackgroundColor,
        centerTitle: false,
        title: Text("Vertical"),
        //title: SvgPicture.asset('assets/ic_instagram.svg', color: primaryColor, height: 32),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.messenger_outline,
            ),
          ),
        ],
      ),
      body: Center(
        child: Text("this is web"),
      ),
    );
  }
}
