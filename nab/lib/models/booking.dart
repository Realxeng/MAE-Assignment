import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nab/models/listing.dart';
import 'package:nab/models/user.dart';

class BookingModel {
  String? id;
  DateTime? createdAt;
  DateTime? dateEnded;
  DateTime? dateStarted;
  String? notes;
  double? price;
  String? status;
  ListingModel? car;
  UserModel? customer;
  UserModel? vendor;

  BookingModel({
    this.id,
    this.createdAt,
    this.dateEnded,
    this.dateStarted,
    this.notes,
    this.price,
    this.status,
    this.car,
    this.customer,
    this.vendor,
  });

  factory BookingModel.fromDocument(DocumentSnapshot data) {
    return BookingModel(
      id: data.id,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      dateEnded: (data['dateEnded'] as Timestamp?)?.toDate(),
      dateStarted: (data['dateStarted'] as Timestamp?)?.toDate(),
      notes: data['notes'],
      price: (data['price'] as num?)?.toDouble(),
      status: data['status'],
      car: data['car'] != null ? ListingModel.fromDocument(data['car']) : null,
      customer:
          data['customer'] != null
              ? UserModel.fromDocument(data['customer'].get())
              : null,
      vendor:
          data['vendor'] != null
              ? UserModel.fromDocument(data['vendor'].get())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt,
      'dateEnded': dateEnded,
      'dateStarted': dateStarted,
      'notes': notes,
      'price': price,
      'status': status,
      'car': car,
      'customer': customer,
      'vendor': vendor,
    };
  }
}
