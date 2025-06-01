import 'package:firebase_auth/firebase_auth.dart';
import 'package:nab/utils/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:nab/utils/user_provider.dart';

class RegisterPage extends StatefulWidget {
  final String role;
  const RegisterPage({super.key, required this.role});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  _RegisterPageState();
  final Color mainGrey = Color(0xFFD9D9D9);
  final Color darkGrey = Color(0xFF9A9A9A);
  String? _dobString;
  DateTime? _dob;

  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<String> _placeholders = [
    "Full Name",
    "Email",
    "Date of Birth",
    "Township",
    "Username",
    "Password",
  ];

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
                  "Register",
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
                      _bottomButton("NEXT", true, _onNextPressed),
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
    bool isDobField = _placeholders[index] == "Date of Birth";

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
            controller:
                isDobField
                    ? TextEditingController(text: _dobString)
                    : _controllers[index],
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
            readOnly: isDobField,
            onTap:
                isDobField
                    ? () async {
                      setState(() {
                        _focusedField = index;
                      });
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _dob ?? DateTime(2000, 1, 1),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _dob = picked;
                          _dobString =
                              "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                        });
                      }
                    }
                    : () {
                      setState(() {
                        _focusedField = index;
                      });
                    },
            onChanged:
                isDobField
                    ? null
                    : (_) {
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
    _controllers[2].text = _dobString ?? '';
    try {
      await authWrapper.signUp(_controllers, widget.role);
      userProvider.redirectUser(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error Signing Up.')));
    }
  }

  void _onBackPressed() {
    Navigator.pop(context);
  }
}
