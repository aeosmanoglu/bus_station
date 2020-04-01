import 'package:bustest/login_page.dart';
import 'package:flutter/material.dart';
import 'bus_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: LoginPage(),
    );
  }
}


