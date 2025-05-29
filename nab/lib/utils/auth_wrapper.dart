import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class AuthWrapper {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signUp(List<TextEditingController> details) async {
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
      });
    } catch (e) {
      log('Error signing up: $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      log('Error signing in: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log('Error signing out: $e');
    }
  }
}
