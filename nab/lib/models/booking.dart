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

  get listingId => null;

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
    } else {
      throw Exception('Listing reference is not found');
    }

    if (customerRef != null) {
      final customerSnap = await customerRef.get();
      customer = UserModel.fromDocument(customerSnap);
    } else {
      throw Exception('Customer reference is not found');
    }
    if (vendorRef != null) {
      final vendorSnap = await vendorRef.get();
      vendor = UserModel.fromDocument(vendorSnap);
    } else {
      throw Exception('Vendor reference is not found');
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
}
