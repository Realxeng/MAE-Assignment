import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nab/pages/customer/cus_home_page.dart';
import 'package:nab/pages/admin/admin_home_page.dart';
import 'package:nab/pages/vendor/vendor_home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider {
  Future<Map<String, dynamic>?>? userDetails;
  void Function()? onSignedOut;
  UserProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        userDetails = fetchUserData(user.uid);
      } else {
        onSignedOut?.call();
      }
    });
  }

  Future<Map<String, dynamic>?> fetchUserData(String uid) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('uid', isEqualTo: uid)
              .limit(1)
              .get();
      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        return userDoc.data();
      }
      return null;
    } catch (e) {
      // log error or handle as needed
      return null;
    }
  }

  void redirectUser(BuildContext context, String uid) async {
    String role = (await userDetails)?['role'] ?? 'Unknown';
    switch (role) {
      case "renter":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CustomerHomePage(uid: uid)),
        );
        break;
      case "admin":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminHomePage(uid: uid)),
        );
        break;
      case "vendor":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VendorHomePage(uid: uid)),
        );
        break;
      default:
        // Handle unexpected role or display an error
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unknown user role.')));
    }
  }
}
