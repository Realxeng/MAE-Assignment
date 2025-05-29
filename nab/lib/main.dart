import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nab/splashscreen.dart';
import 'firebase_options.dart';
import 'login.dart';

void main() async {
  runApp(const MyApp());
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      home: SplashScreen(),
    );
  }
}
