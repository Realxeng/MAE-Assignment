import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nab/models/listing.dart';

class ListingProvider extends ChangeNotifier {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _listingSubscription;
  List<ListingModel> _listingModel = [];
  List<ListingModel> get listings => _listingModel;
  List<ListingModel> listingFiltered = [];
  ListingModel? _singleListing;
  ListingModel? get singleListing => _singleListing;

  ListingProvider() {
    fetchAllListings();
  }

  @override
  void dispose() {
    _listingSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchListingsByVendor(String vendorId) async {
    await _listingSubscription?.cancel();

    final vendorRef = FirebaseFirestore.instance
        .collection('users')
        .doc(vendorId);
    _listingSubscription = FirebaseFirestore.instance
        .collection('listing')
        .where('vendor', isEqualTo: vendorRef)
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

  Future<void> addListing({
    required String vendorId,
    required String carModel,
    required String carPlate,
    required String carType,
    required int price,
    required int contactNumber,
    required String? imageBase64,
    required String? attachmentBase64,
    required String vehicleCondition,
  }) async {
    final vendorRef = FirebaseFirestore.instance
        .collection('users')
        .doc(vendorId);

    final listingData = {
      'vendor': vendorRef,
      'carModel': carModel,
      'carPlate': carPlate.toUpperCase(),
      'carType': carType.toLowerCase(),
      'contactNumber': contactNumber,
      'imageBase64': imageBase64,
      'attachmentBase64': attachmentBase64,
      'vehicleCondition': vehicleCondition,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('listing').add(listingData);
    } catch (e) {
      debugPrint('Error adding listing: $e');
    }
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

  Future<void> fetchAcceptedListingsByType(String type) async {
    await _listingSubscription?.cancel();

    _listingSubscription = FirebaseFirestore.instance
        .collection('listing')
        .where('status', isEqualTo: 'accepted')
        .where('carType', isEqualTo: type.toLowerCase())
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

  Future<void> fetchAcceptedListings() async {
    await _listingSubscription?.cancel();

    _listingSubscription = FirebaseFirestore.instance
        .collection('listing')
        .where('status', isEqualTo: 'accepted')
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

  Future<void> fetchRejectedListings() async {
    await _listingSubscription?.cancel();

    _listingSubscription = FirebaseFirestore.instance
        .collection('listing')
        .where('status', isEqualTo: 'rejected')
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

  Future<void> fetchListingsByType(String type) async {
    // If type is empty, show all:
    if (type.isEmpty) {
      listingFiltered = List.from(_listingModel);
      notifyListeners();
      return;
    }
    // else filter the list or fetch filtered from server
    listingFiltered = _listingModel.where((l) => l.carType == type).toList();
    notifyListeners();
  }

  void clearFilter() {
    listingFiltered = List.from(_listingModel);
    notifyListeners();
  }

  Future<void> fetchListingsByPlate(String plate) async {
    await _listingSubscription?.cancel();

    final completer = Completer<void>();

    _listingSubscription = FirebaseFirestore.instance
        .collection('listing')
        .where('carPlate', isEqualTo: plate.toUpperCase())
        .snapshots()
        .listen(
          (querySnapshot) async {
            if (querySnapshot.docs.isNotEmpty) {
              _singleListing = await ListingModel.fromDocumentAsync(
                querySnapshot.docs.first,
              );
            } else {
              _singleListing = null;
            }
            notifyListeners();

            if (!completer.isCompleted) {
              completer.complete(); // Complete on first data
            }
          },
          onError: (error) {
            _singleListing = null;
            notifyListeners();

            if (!completer.isCompleted) {
              completer.completeError(error);
            }
          },
        );

    return completer.future;
  }
}
