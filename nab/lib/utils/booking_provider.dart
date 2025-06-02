import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nab/models/booking.dart';
import 'package:nab/models/listing.dart';
import 'package:nab/models/user.dart';

class BookingProvider extends ChangeNotifier {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _bookingSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _listingSubscription;

  List<BookingModel> _bookings = [];
  List<BookingModel> get bookings => _bookings;

  // NEW: List and getter for car listings
  List<ListingModel> _listings = [];
  List<ListingModel> get listings => _listings;

  BookingProvider() {
    fetchAllBookings();
  }

  @override
  void dispose() {
    _bookingSubscription?.cancel();
    _listingSubscription?.cancel(); // Also cancel the listings subscription
    super.dispose();
  }

  // -------------- EXISTING BOOKING METHODS (unchanged) -----------------
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
      'vendorACK': false,
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

  // -------------- NEW: FETCH RENTAL LISTINGS FOR THE VENDOR ---------------

  Future<void> fetchVendorListings(UserModel vendor) async {
    await _listingSubscription?.cancel();

    final vendorRef = FirebaseFirestore.instance
        .collection('users')
        .doc(vendor.id);
    _listingSubscription = FirebaseFirestore.instance
        .collection('listing') // Make sure your collection is named correctly
        .where('vendor', isEqualTo: vendorRef)
        .snapshots()
        .listen(
          (querySnapshot) {
            _listings =
                querySnapshot.docs
                    .map((doc) => ListingModel.fromDocument(doc))
                    .toList();
            notifyListeners();
          },
          onError: (err) {
            _listings = [];
            notifyListeners();
          },
        );
  }

  Future<void> fetchBookingsForVendorUnacknowledged(String vendorUid) async {
    await _bookingSubscription?.cancel();

    final vendorRef = FirebaseFirestore.instance
        .collection('users')
        .doc(vendorUid);

    _bookingSubscription = FirebaseFirestore.instance
        .collection('bookings')
        .where('vendor', isEqualTo: vendorRef)
        .where('vendorACK', isEqualTo: false)
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

  /// Acknowledge a booking: set status to "ongoing" and vendorACK to true.
  Future<void> acknowledgeBooking(BookingModel booking) async {
    if (booking.id == null) {
      throw Exception("Booking ID is null");
    }

    final docRef = FirebaseFirestore.instance
        .collection('bookings')
        .doc(booking.id);

    await docRef.update({'status': 'ongoing', 'vendorACK': true});

    // Update local cache and notify listeners
    final index = _bookings.indexWhere((b) => b.id == booking.id);
    if (index != -1) {
      _bookings[index] = _bookings[index].copyWith(
        status: 'ongoing',
        vendorACK: true,
      );
      notifyListeners();
    }
  }

  void clearListings() {
    _listings.clear();
    notifyListeners();
  }
}
