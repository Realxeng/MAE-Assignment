import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nab/utils/user_provider.dart';
import 'package:nab/pages/common/landing_page.dart';

class AuthRouter extends StatefulWidget {
  const AuthRouter({super.key});

  @override
  State<AuthRouter> createState() => _AuthRouterState();
}

class _AuthRouterState extends State<AuthRouter> {
  late UserProvider userProvider;

  @override
  void initState() {
    super.initState();
    userProvider = UserProvider();
    userProvider.addListener(() {
      // rebuild when user data changes
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    userProvider.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Splash/Loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Not signed in
        if (!snapshot.hasData || snapshot.data == null) {
          return LandingPage(); // Show login/welcome page
        }

        final user = snapshot.data!;
        final userModel = userProvider.user;

        // Still loading user data
        if (userModel == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Redirect based on role
        switch (userModel.role) {
          case "admin":
            Navigator.pushReplacementNamed(
              context,
              '/adminHome',
              arguments: {'uid': user.uid},
            );
            break;
          case "renter":
            Navigator.pushReplacementNamed(
              context,
              '/customerHome',
              arguments: {'uid': user.uid},
            );
            break;
          case "vendor":
            Navigator.pushReplacementNamed(
              context,
              '/vendorHome',
              arguments: {'uid': user.uid},
            );
            break;
          default:
            Navigator.pushReplacementNamed(context, '/');
            break;
        }
        // Return a placeholder widget after navigation to satisfy the return type
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
