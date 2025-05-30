class ListingModel {
  final String? attachments;
  final String? carModel;
  final String? carPlate;
  final int? contactNumber;
  final String? image;
  final String? status;
  final String? uid;
  final String? username;
  final String? vehicleCondition;

  ListingModel({
    this.attachments,
    this.carModel,
    this.carPlate,
    this.contactNumber,
    this.image,
    this.status,
    this.uid,
    this.username,
    this.vehicleCondition,
  });

  factory ListingModel.fromMap(Map<String, dynamic> data) {
    return ListingModel(
      attachments: data['attachments'],
      carModel: data['carModel'],
      carPlate: data['carPlate'],
      contactNumber: data['contactNumber'],
      image: data['image'],
      status: data['status'],
      uid: data['uid'],
      username: data['username'],
      vehicleCondition: data['vehicleCondition'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attachments': attachments,
      'carModel': carModel,
      'carPlate': carPlate,
      'contactNumber': contactNumber,
      'image': image,
      'status': status,
      'uid': uid,
      'username': username,
      'vehicleCondition': vehicleCondition,
    };
  }
}
