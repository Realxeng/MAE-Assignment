import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nab/pages/customer/cus_home_page.dart';
import 'package:nab/pages/admin/admin_home_page.dart';
import 'package:nab/pages/vendor/vendor_home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nab/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _userModel;
  UserModel? get user => _userModel;
  void Function()? onSignedOut;
  UserProvider() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        fetchUserData(user.uid);
      } else {
        _userModel = null;
        onSignedOut?.call();
        notifyListeners();
      }
    });
  }

  Future<void> fetchUserData(String uid) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('uid', isEqualTo: uid)
              .limit(1)
              .get();
      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first.data();
        _userModel = UserModel.fromMap(userDoc);
      } else {
        _userModel = null;
      }
      notifyListeners();
    } catch (e) {
      _userModel = null;
      notifyListeners();
    }
  }

  void redirectUser(BuildContext context, String uid) async {
    String role = _userModel?.role ?? 'Unknown';
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
