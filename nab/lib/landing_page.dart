import 'package:flutter/material.dart';
import 'user_register.dart';
import 'user_login.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  static const Color mainGrey = Color(0xFFD9D9D9);
  static const Color darkGrey = Color(0xFF9A9A9A);
  static const Color blue = Color(0xFF2C8ED6);

  Color renterButtonColor = blue;
  Color vendorButtonColor = mainGrey;
  String role = "renter"; // Default role
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(247, 247, 247, 1),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              // Spacer for top margin
              Spacer(flex: 3),
              // Logo
              Image.asset("assets/Nab_Logo_Nobg.png", height: 175),
              Image.asset("assets/Nab_Branding_Android.png", height: 50),
              Spacer(flex: 2),
              // Slogan
              // Have an Account? Login
              Text(
                "Have an Account?",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Container(
                  width: 110,
                  height: 36,
                  decoration: BoxDecoration(
                    color: mainGrey,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      "Log in",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ),
              Spacer(flex: 2),

              // Vendor & Renter Select Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Vendor Button
                    Expanded(
                      child: Material(
                        color: darkGrey, // Button background color
                        borderRadius: BorderRadius.circular(
                          22,
                        ), // Same radius as the button
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            22,
                          ), // Match the ripple radius
                          highlightColor: Colors.transparent,
                          splashColor: Colors.white24,
                          onTap: () {
                            setState(() {
                              role = "vendor";
                              vendorButtonColor = blue;
                              renterButtonColor = mainGrey;
                            });
                          },
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: vendorButtonColor,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Center(
                              child: Text(
                                "VENDOR",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  color:
                                      vendorButtonColor == blue
                                          ? Colors.white
                                          : darkGrey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    SizedBox(width: 10),
                    // Renter Button (active)
                    Expanded(
                      child: Material(
                        color: darkGrey, // Button background color
                        borderRadius: BorderRadius.circular(
                          22,
                        ), // Same radius as the button
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            22,
                          ), // Match the ripple radius
                          highlightColor: Colors.transparent,
                          splashColor: Colors.white24,
                          onTap: () {
                            setState(() {
                              role = "renter";
                              renterButtonColor = blue;
                              vendorButtonColor = mainGrey;
                            });
                          },
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: renterButtonColor,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Center(
                              child: Text(
                                "CUSTOMER",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  color:
                                      renterButtonColor == blue
                                          ? Colors.white
                                          : darkGrey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Material(
                  color: darkGrey, // Button background color
                  borderRadius: BorderRadius.circular(
                    22,
                  ), // Same radius as the button
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      22,
                    ), // Match the ripple radius
                    highlightColor: Colors.transparent,
                    splashColor:
                        Colors.white24, // Customize splash color if needed
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterPage(role: role),
                        ),
                      );
                    },
                    child: Container(
                      height: 44,
                      // Remove color here, Material already provides the color
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Center(
                        child: Text(
                          "REGISTER",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
