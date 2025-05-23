import 'package:flutter/material.dart';
import 'login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0x00AFFFFF)),
      ),
      home: Login(),
    );
  }
}
