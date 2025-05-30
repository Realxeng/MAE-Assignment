import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String uid;
  final String role;
  final String? fullName;
  final String? email;
  final String? dob;
  final String? township;
  final String? username;
  final String? profileImage;
  final DateTime? dateCreated;

  UserModel({
    required this.id,
    required this.uid,
    required this.role,
    this.fullName,
    this.email,
    this.dob,
    this.township,
    this.username,
    this.profileImage,
    this.dateCreated,
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw StateError("User document data is null");
    }
    return UserModel(
      id: doc.id,
      uid: data['uid'] ?? '',
      role: data['role'] ?? 'Unknown',
      fullName: data['fullName'],
      email: data['email'],
      dob: data['dob'],
      township: data['township'],
      username: data['username'],
      profileImage: data['picture'],
      dateCreated: data['dateCreated'] as DateTime?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'role': role,
      'fullName': fullName,
      'email': email,
      'dob': dob,
      'township': township,
      'username': username,
      'picture': profileImage,
      'dateCreated': dateCreated?.toIso8601String(),
    };
  }
}
