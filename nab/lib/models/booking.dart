import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  String? createdAt;
  String? dateEnded;
  String? dateStarted;
  String? notes;
  double? price;
  String? status;
  DocumentReference? car;
  DocumentReference? customer;
  DocumentReference? vendor;

  BookingModel({
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

  factory BookingModel.fromMap(Map<String, dynamic> data) {
    return BookingModel(
      createdAt: data['createdAt'],
      dateEnded: data['dateEnded'],
      dateStarted: data['dateStarted'],
      notes: data['notes'],
      price: (data['price'] as num?)?.toDouble(),
      status: data['status'],
      car: data['car'] as DocumentReference?,
      customer: data['customer'] as DocumentReference?,
      vendor: data['vendor'] as DocumentReference?,
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
