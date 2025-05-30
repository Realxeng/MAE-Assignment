import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthWrapper {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signUp(List<TextEditingController> details, String role) async {
    // Check if username already exists
    QuerySnapshot usernameCheck =
        await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: details[4].text)
            .get();
    if (usernameCheck.docs.isNotEmpty) {
      log('Username already exists');
      return;
    }
    try {
      final credentials = await _auth.createUserWithEmailAndPassword(
        email: details[1].text,
        password: details[5].text,
      );
      CollectionReference users = FirebaseFirestore.instance.collection(
        'users',
      );
      await users.add({
        'uid': credentials.user?.uid,
        'fullName': details[0].text,
        'email': details[1].text,
        'dob': details[2].text,
        'township': details[3].text,
        'username': details[4].text,
        'role': role,
        'dateCreated': DateTime.now(),
      });
    } catch (e) {
      log('Error signing up: $e');
    }
  }

  Future<String> signIn(List<TextEditingController> details) async {
    UserCredential crendetials;
    try {
      crendetials = await _auth.signInWithEmailAndPassword(
        email: details[0].text,
        password: details[1].text,
      );
      return crendetials.user?.uid ?? '';
    } catch (e) {
      log('Error signing in: $e');
    }
    return '';
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/landing', (route) => false);
    } catch (e) {
      log('Error signing out: $e');
    }
  }
}
