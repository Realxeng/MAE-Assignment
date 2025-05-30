import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nab/admin_home_page.dart';
import 'package:nab/pages/customer/cus_home_page.dart';
import 'package:nab/pages/common/landing_page.dart';
import 'package:nab/utils/user_provider.dart';
import 'package:nab/pages/vendor/vendor_home_page.dart';

class AuthRouter extends StatelessWidget {
  const AuthRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Splash/Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Not signed in
        if (!snapshot.hasData || snapshot.data == null) {
          return LandingPage(); // Show login/welcome
        }

        // Signed in, fetch user role
        return FutureBuilder<String>(
          future: UserProvider().fetchUserRole(snapshot.data!.uid),
          builder: (context, roleSnap) {
            if (!roleSnap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            switch (roleSnap.data) {
              case "admin":
                return AdminHomePage(uid: snapshot.data!.uid);
              case "renter":
                return CustomerHomePage();
              case "vendor":
                return VendorHomePage();
              default:
                return LandingPage();
            }
          },
        );
      },
    );
  }
}
