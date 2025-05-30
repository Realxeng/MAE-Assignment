import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nab/models/listing.dart';

class ListingProvider extends ChangeNotifier {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _listingSubscription;
  List<ListingModel> _listingModel = [];
  List<ListingModel> get listings => _listingModel;
  ListingProvider() {
    fetchAllListings();
  }

  @override
  void dispose() {
    _listingSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchAllListings() async {
    await _listingSubscription?.cancel();

    _listingSubscription = FirebaseFirestore.instance
        .collection('listings')
        .snapshots()
        .listen(
          (querySnapshot) {
            _listingModel =
                querySnapshot.docs
                    .map((doc) => ListingModel.fromMap(doc.data()))
                    .toList();
            notifyListeners();
          },
          onError: (error) {
            _listingModel = [];
            notifyListeners();
          },
        );
  }
}
