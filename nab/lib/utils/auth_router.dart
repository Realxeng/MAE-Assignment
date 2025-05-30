import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nab/pages/customer/cus_home_page.dart';
import 'package:nab/pages/admin/admin_home_page.dart';
import 'package:nab/pages/vendor/vendor_home_page.dart';
import 'package:nab/pages/common/landing_page.dart';
import 'user_provider.dart';

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

        // Signed in, fetch user role - use FutureBuilder with fetchUserData
        final user = snapshot.data!;
        return FutureBuilder<Map<String, dynamic>?>(
          future: UserProvider().fetchUserData(user.uid),
          builder: (context, roleSnap) {
            if (roleSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (!roleSnap.hasData ||
                roleSnap.data == null ||
                roleSnap.data!.isEmpty) {
              return LandingPage(); // Or error page
            }
            String? role = roleSnap.data?['role'];

            switch (role) {
              case "admin":
                return AdminHomePage(uid: user.uid);
              case "renter":
                return CustomerHomePage(uid: user.uid);
              case "vendor":
                return VendorHomePage(uid: user.uid);
              default:
                return LandingPage();
            }
          },
        );
      },
    );
  }
}
