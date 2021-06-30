import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'MainHomePage.dart';

void main() async{
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: MainHomePage(),
    );
  }
}




