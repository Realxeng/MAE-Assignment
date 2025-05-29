import 'package:flutter/material.dart';

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Car Renting App')),
      body: Center(
        child: Text(
          'Welcome to the Car Renting App!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
