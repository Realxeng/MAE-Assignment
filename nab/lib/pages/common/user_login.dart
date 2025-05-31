import 'dart:developer';
import 'package:nab/utils/user_provider.dart';
import 'package:nab/utils/auth_wrapper.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  _LoginPageState();
  final Color mainGrey = Color(0xFFD9D9D9);
  final Color darkGrey = Color(0xFF9A9A9A);

  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<String> _placeholders = ["Email", "Password"];

  int _focusedField = -1; // -1 means none is focused

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 247, 247, 1),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 30),
                Image.asset('assets/Nab_Emblem.png', height: 100),
                SizedBox(height: 10),
                Text(
                  "Sign In",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 26),

                ...List.generate(_placeholders.length, (i) => _buildInput(i)),

                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _bottomButton("BACK", false, _onBackPressed),
                      Spacer(),
                      Spacer(),
                      _bottomButton("LOGIN", true, _onNextPressed),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(int index) {
    final isFocused = index == _focusedField;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isFocused ? darkGrey : mainGrey,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: TextField(
            controller: _controllers[index],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isFocused ? Colors.white : Colors.grey[700],
              fontSize: 18,
            ),
            cursorColor: Colors.blue,
            obscureText: _placeholders[index] == "Password",
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              border: InputBorder.none,
              hintText: _placeholders[index],
              hintStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: isFocused ? Colors.white70 : Colors.grey[700],
                fontSize: 18,
              ),
            ),
            onTap: () {
              setState(() {
                _focusedField = index;
              });
            },
            onChanged: (_) {
              setState(() {});
            },
          ),
        ),
      ),
    );
  }

  Widget _bottomButton(String text, bool isActive, VoidCallback onPressed) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onPressed,
      child: Container(
        width: 100,
        height: 42,
        decoration: BoxDecoration(
          color: isActive ? Color(0xFFB3B3B3) : Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.grey[600],
              fontSize: 17,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  void _onNextPressed() async {
    AuthWrapper authWrapper = AuthWrapper();
    UserProvider userProvider = UserProvider();
    try {
      await authWrapper.signIn(_controllers);
      if (!mounted) return;
      userProvider.redirectUser(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onBackPressed() {
    Navigator.pop(context);
  }
}
