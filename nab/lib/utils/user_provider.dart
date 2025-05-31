import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nab/pages/customer/cus_home_page.dart';
import 'package:nab/pages/admin/admin_home_page.dart';
import 'package:nab/pages/vendor/vendor_home_page.dart';
import 'package:nab/models/user.dart';
import 'package:nab/utils/image_provider.dart';

class UserProvider extends ChangeNotifier {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _userSubscription;
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
        _userSubscription?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchUserData(String uid) async {
    await _userSubscription?.cancel();

    _userSubscription = FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .snapshots()
        .listen(
          (querySnapshot) {
            if (querySnapshot.docs.isNotEmpty) {
              final userDoc = querySnapshot.docs.first;
              _userModel = UserModel.fromDocument(userDoc);
            } else {
              _userModel = null;
            }
            notifyListeners();
          },
          onError: (error) {
            _userModel = null;
            notifyListeners();
          },
        );
  }

  void redirectUser(BuildContext context) async {
    String role = _userModel?.role ?? 'Unknown';
    String uid = _userModel?.uid ?? '';
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

  Future<bool> updateUserProfile({
    required String email,
    required String username,
    required String township,
    File? profilePictureFile, // optional image file
  }) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('No user is currently logged in.');
    }

    String userId = currentUser.uid;

    // Update email in Firebase Auth if changed
    if (email != currentUser.email) {
      await currentUser.updateEmail(email);
      await currentUser.reload();
    }

    String? profilePictureBase64;

    if (profilePictureFile != null) {
      profilePictureBase64 = ImageConstants.constants.convertToBase64(
        profilePictureFile,
      );
    }

    Map<String, dynamic> updatedData = {
      'email': email,
      'username': username,
      'township': township,
    };

    if (profilePictureBase64 != null && profilePictureBase64.isNotEmpty) {
      updatedData['profilePicture'] = profilePictureBase64;
    }

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .update(updatedData);

    return true;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _userModel = null;
    notifyListeners();
    onSignedOut?.call();
  }
}
