class UserModel {
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

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      role: data['role'] ?? 'Unknown',
      fullName: data['fullName'],
      email: data['email'],
      dob: data['dob'],
      township: data['township'],
      username: data['username'],
      profileImage: data['picture'],
      dateCreated: data['dateCreated'],
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
