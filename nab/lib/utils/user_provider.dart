import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nab/pages/admin/admin_main.dart';
import 'package:nab/pages/customer/cus_main.dart';
import 'package:nab/pages/vendor/vendor_summary.dart';
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

  Future<void> redirectUser(BuildContext context) async {
    // Wait for user data to load with timeout
    const timeout = Duration(seconds: 5);
    final stopwatch = Stopwatch()..start();

    // Wait until _userModel is non-null or timeout
    while (_userModel == null && stopwatch.elapsed < timeout) {
      await Future.delayed(Duration(milliseconds: 100));
    }
    stopwatch.stop();

    if (_userModel == null) {
      // Still null after waiting: show an error or just return
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data. Please try again.')),
      );
      return;
    }

    String role = _userModel?.role ?? 'Unknown';
    String uid = _userModel?.uid ?? '';

    switch (role) {
      case "renter":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CustomerMainPage(uid: uid)),
        );
        break;
      case "admin":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminMainPage(uid: uid)),
        );
        break;
      case "vendor":
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VendorHomePage(uid: uid)),
        );
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Unknown user role.')));
    }
  }

  Future<bool> updateUserProfile({
    required String fullName,
    required String username,
    required String township,
    File? profilePictureFile, // optional image file
  }) async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('No user is currently logged in.');
    }

    String userId = currentUser.uid;

    await fetchUserData(userId);

    String? profilePictureBase64;

    if (profilePictureFile != null) {
      profilePictureBase64 = ImageConstants.constants.convertToBase64(
        profilePictureFile,
      );
    }

    Map<String, dynamic> updatedData = {
      'fullName': fullName,
      'username': username,
      'township': township,
    };

    if (profilePictureBase64 != null && profilePictureBase64.isNotEmpty) {
      updatedData['picture'] = profilePictureBase64;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user?.id)
        .set(updatedData, SetOptions(merge: true));

    return true;
  }

  Future<void> deleteUserAccount() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('No user is currently logged in.');
    }

    String userId = currentUser.uid;

    await fetchUserData(userId);

    try {
      // Delete Firebase Authentication user
      await currentUser.delete();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.id)
          .delete();

      // Clear local user model and notify listeners
      _userModel = null;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception('Please re-authenticate to delete your account.');
      } else {
        throw Exception('Failed to delete user: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    _userModel = null;
    notifyListeners();
    onSignedOut?.call();
  }
}
