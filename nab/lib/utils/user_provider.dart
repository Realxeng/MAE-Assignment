import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nab/cus_home_page.dart';
import 'package:nab/admin_home_page.dart';
import 'package:nab/vendor_home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider {
  Future<String> fetchUserRole(String uid) async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where(
                'uid',
                isEqualTo: uid,
              ) // Filter documents where 'uid' matches
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Get the first matching document
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Extract the 'role' field from the document
        String userRole = userData['role'] ?? 'Unknown';
        return userRole;
      } else {
        log('No user found with UID: $uid');
        return 'No Role Found';
      }
    } catch (e) {
      log('Error fetching user data: $e');
      return 'Error';
    }
  }

  void redirectUser(BuildContext context, String uid) async {
    UserProvider userProvider = UserProvider();
    String role = await userProvider.fetchUserRole(uid);
    switch (role) {
      case "renter":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CustomerHomePage()),
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
          MaterialPageRoute(builder: (context) => VendorHomePage()),
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
