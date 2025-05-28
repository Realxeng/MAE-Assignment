import 'package:flutter/material.dart';
// ignore: unused_import
import 'cus_home_page.dart';

class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 100),
            Image.asset('assets/Nab_Emblem.png', width: 240, height: 150),
            Text(
              'Login to your account',
              style: TextStyle(fontSize: 20, fontFamily: 'Arial'),
            ),
            SizedBox(height: 20),
            Container(
              width: screenWidth * 0.8, // 80% of the screen width
              child: TextField(decoration: InputDecoration(labelText: 'Email')),
            ),
            SizedBox(height: 16), // Add spacing between fields
            Container(
              width: screenWidth * 0.8, // 80% of the screen width
              child: TextField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                checkUser();
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

void checkUser() {}
