import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nab/models/listing.dart';
import 'package:nab/models/user.dart';

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
        .collection('listing')
        .snapshots()
        .listen(
          (querySnapshot) {
            _listingModel =
                querySnapshot.docs
                    .map((doc) => ListingModel.fromDocument(doc))
                    .toList();
            notifyListeners();
          },
          onError: (error) {
            _listingModel = [];
            notifyListeners();
          },
        );
  }

  Future<void> fetchAvailableListings() async {
    await _listingSubscription?.cancel();

    _listingSubscription = FirebaseFirestore.instance
        .collection('listing')
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .listen(
          (querySnapshot) {
            _listingModel =
                querySnapshot.docs
                    .map((doc) => ListingModel.fromDocument(doc))
                    .toList();
            notifyListeners();
          },
          onError: (error) {
            _listingModel = [];
            notifyListeners();
          },
        );
  }

  Future<void> fetchPendingListings() async {
    await _listingSubscription?.cancel();

    _listingSubscription = FirebaseFirestore.instance
        .collection('listing')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen(
          (querySnapshot) async {
            _listingModel = await Future.wait(
                querySnapshot.docs.map((doc) async {
                return await ListingModel.fromDocumentAsync(doc);
              }),
            );
            notifyListeners();
          },
          onError: (error) {
            _listingModel = [];
            notifyListeners();
          },
        );
  }
}
