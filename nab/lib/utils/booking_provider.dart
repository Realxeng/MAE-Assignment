import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nab/models/booking.dart';
import 'package:nab/models/listing.dart';
import 'package:nab/models/user.dart';

class BookingProvider extends ChangeNotifier {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _bookingSubscription;
  List<BookingModel> _bookings = [];
  List<BookingModel> get bookings => _bookings;

  BookingProvider() {
    fetchAllBookings();
  }

  @override
  void dispose() {
    _bookingSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchAllBookings() async {
    await _bookingSubscription?.cancel();
    _bookingSubscription = FirebaseFirestore.instance
        .collection('bookings')
        .snapshots()
        .listen(
          (querySnapshot) async {
            final bookings = await Future.wait(
              querySnapshot.docs.map(
                (doc) => BookingModel.fromDocumentAsync(doc),
              ),
            );
            _bookings = bookings;
            notifyListeners();
          },
          onError: (error) {
            _bookings = [];
            notifyListeners();
          },
        );
  }

  Future<void> addBooking(
    ListingModel listing,
    UserModel vendor,
    UserModel customer,
    String notes,
  ) async {
    final bookingData = fromListingandUser(listing, vendor, customer, notes);
    try {
      await FirebaseFirestore.instance.collection('bookings').add(bookingData);
    } catch (e) {
      print("Error adding booking: $e");
    }
  }

  Future<void> fetchPastBookings(UserModel user) async {
    DocumentReference userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.id);
    await _bookingSubscription?.cancel();

    _bookingSubscription = FirebaseFirestore.instance
        .collection('bookings')
        .where('customer', isEqualTo: userDocRef)
        .where('dateEnded', isNotEqualTo: null)
        .where('dateEnded', isLessThan: DateTime.now())
        .snapshots()
        .listen(
          (querySnapshot) async {
            _bookings = await Future.wait(
              querySnapshot.docs.map((doc) async {
                return await BookingModel.fromDocumentAsync(doc);
              }),
            );
            notifyListeners();
          },
          onError: (error) {
            _bookings = [];
            notifyListeners();
          },
        );
  }

  Future<void> fetchBookingFromStatus(String status) async {
    await _bookingSubscription?.cancel();

    _bookingSubscription = FirebaseFirestore.instance
        .collection('bookings')
        .where('status', isEqualTo: status)
        .snapshots()
        .listen(
          (querySnapshot) async {
            _bookings = await Future.wait(
              querySnapshot.docs.map((doc) async {
                return await BookingModel.fromDocumentAsync(doc);
              }),
            );
            notifyListeners();
          },
          onError: (error) {
            _bookings = [];
            notifyListeners();
          },
        );
  }

  Future<void> fetchActiveBookings(UserModel user) async {
    DocumentReference userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.id);
    await _bookingSubscription?.cancel();

    _bookingSubscription = FirebaseFirestore.instance
        .collection('bookings')
        .where('customer', isEqualTo: userDocRef)
        .snapshots()
        .listen(
          (querySnapshot) async {
            _bookings = await Future.wait(
              querySnapshot.docs.map(
                (doc) => BookingModel.fromDocumentAsync(doc),
              ),
            );
            notifyListeners();
          },
          onError: (error) {
            _bookings = [];
            notifyListeners();
          },
        );
  }

  Map<String, dynamic> fromListingandUser(
    ListingModel listing,
    UserModel vendor,
    UserModel customer,
    String notes,
  ) {
    final firestore = FirebaseFirestore.instance;
    final carRef = firestore.collection("listing").doc(listing.id);
    final vendorRef = firestore.collection("users").doc(vendor.id);
    final cusRef = firestore.collection("users").doc(customer.id);
    return {
      'car': carRef,
      'createdAt': Timestamp.now(),
      'customer': cusRef,
      'dateEnded': null,
      'dateStarted': null,
      'notes': notes,
      'price': 0,
      'status': "pending",
      'vendor': vendorRef,
    };
  }

  /// Calculates total income for a vendor in a specified [year] and [month].
  /// Only bookings with status "finished" are counted.
  double calculateMonthlyIncome(String vendorUid, int year, int month) {
    final filteredBookings = _bookings.where((booking) {
      if (booking.vendor == null ||
          booking.dateStarted == null ||
          booking.price == null ||
          booking.status == null) {
        return false;
      }
      final bookingMonth = booking.dateStarted!;
      return booking.vendor!.id == vendorUid &&
          bookingMonth.year == year &&
          bookingMonth.month == month &&
          booking.status == "finished";
    });

    double totalIncome = 0;
    for (var booking in filteredBookings) {
      totalIncome += booking.price!;
    }

    return totalIncome;
  }

  /// Calculates total income for all months of [year] for a vendor.
  /// Returns a map with keys as month (1-12) and values as total income.
  /// Only bookings with status "finished" are counted.
  Map<int, double> calculateYearlyIncome(String vendorUid, int year) {
    final Map<int, double> incomeByMonth = {};

    for (int month = 1; month <= 12; month++) {
      incomeByMonth[month] = calculateMonthlyIncome(vendorUid, year, month);
    }

    return incomeByMonth;
  }
}
