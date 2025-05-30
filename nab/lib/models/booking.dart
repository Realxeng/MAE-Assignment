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
    );
  }

  static Future<BookingModel> fromDocumentAsync(DocumentSnapshot data) async {
    final customerRef = data['customer'];
    final vendorRef = data['vendor'];
    final carRef = data['car'] as DocumentReference?;
    UserModel? customer;
    UserModel? vendor;
    ListingModel? car;

    if (carRef != null) {
      final carSnap = await carRef.get();
      car = ListingModel.fromDocument(carSnap);
    }

    if (customerRef != null) {
      final customerSnap = await customerRef.get();
      customer = UserModel.fromDocument(customerSnap);
    }
    if (vendorRef != null) {
      final vendorSnap = await vendorRef.get();
      vendor = UserModel.fromDocument(vendorSnap);
    }

    return BookingModel(
      id: data.id,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      dateEnded: (data['dateEnded'] as Timestamp?)?.toDate(),
      dateStarted: (data['dateStarted'] as Timestamp?)?.toDate(),
      notes: data['notes'],
      price: (data['price'] as num?)?.toDouble(),
      status: data['status'],
      car: car,
      customer: customer,
      vendor: vendor,
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
