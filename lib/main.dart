import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'LoginPage.dart';

void main() async {
  runApp(Phoenix(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dziennik Hodowlany',
      theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity),
      home: LoginPage(title: 'Login page'),
    );
  }
}
