import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nab/models/user.dart';

class ListingModel {
  final String? id;
  final String? attachments;
  final String? carModel;
  final String? carPlate;
  final String? carType;
  final int? contactNumber;
  final String? image;
  final String? status;
  final String? vehicleCondition;
  UserModel? user;

  ListingModel({
    this.id,
    this.attachments,
    this.carModel,
    this.carPlate,
    this.carType,
    this.contactNumber,
    this.image,
    this.status,
    this.vehicleCondition,
    this.user,
    bool? ownerACK,
  });

  factory ListingModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ListingModel(
      id: doc.id,
      attachments: data['attachments'],
      carModel: data['carModel'],
      carPlate: data['carPlate'],
      carType: data['carType'],
      contactNumber: data['contactNumber'],
      image: data['image'],
      status: data['status'],
      vehicleCondition: data['vehicleCondition'],
      ownerACK: data['ownerACK'] as bool? ?? false,
    );
  }

  get vendorUid => null;

  get views => null;

  get bookmarks => null;

  get carName => null;

  String? get base64Image => null;

  static Future<ListingModel> fromDocumentAsync(DocumentSnapshot data) async {
    final userRef = data['user'] as DocumentReference?;
    UserModel? user;

    if (userRef != null) {
      final userSnap = await userRef.get();
      if (!userSnap.exists || userSnap.data() == null) {
        user = null;
        throw StateError(
          'User document data is null for userId: ${userRef.id}',
        );
      } else {
        user = UserModel.fromDocument(userSnap);
      }
    }

    return ListingModel(
      id: data.id,
      attachments: data['attachments'],
      carModel: data['carModel'],
      carPlate: data['carPlate'],
      carType: data['carType'],
      contactNumber: data['contactNumber'] as int?,
      image: data['image'],
      status: data['status'],
      vehicleCondition: data['vehicleCondition'],
      user: user,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attachments': attachments,
      'carModel': carModel,
      'carPlate': carPlate,
      'carType': carType,
      'contactNumber': contactNumber,
      'image': image,
      'status': status,
      'vehicleCondition': vehicleCondition,
    };
  }
}
