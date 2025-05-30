import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nab/models/booking.dart';
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

  Future<void> addBooking(BookingModel booking) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .add(booking.toJson());
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
}
