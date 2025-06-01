import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'package:nab/utils/listing_provider.dart';
import 'package:nab/utils/booking_provider.dart';
import 'package:nab/utils/user_provider.dart';
import 'package:nab/utils/image_provider.dart';

class RentalListingPage extends StatelessWidget {
  const RentalListingPage({Key? key}) : super(key: key);

  Widget getCarImage(String? base64Str) {
    if (base64Str == null || base64Str.isEmpty) {
      return Icon(Icons.directions_car, size: 32, color: Colors.grey[600]);
    }
    try {
      Uint8List bytes = ImageConstants().decodeBase64(base64Str);
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(bytes, width: 76, height: 76, fit: BoxFit.cover),
      );
    } catch (e) {
      return Icon(Icons.directions_car, size: 32, color: Colors.grey[600]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingProvider = Provider.of<ListingProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    // Optional: filter for listings that belong to the current vendor only
    final user = userProvider.user;
    final isVendor = user?.role == 'vendor';
    final vendorUid = user?.uid ?? '';

    final listings =
        isVendor
            ? listingProvider.listings
                .where((l) => l.vendorUid == vendorUid)
                .toList()
            : listingProvider.listings;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 0, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Listings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child:
                  listings.isEmpty
                      ? Center(
                        child: Text(
                          'No listings found.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        itemCount: listings.length,
                        itemBuilder: (context, index) {
                          final listing = listings[index];

                          // Booking count for this listing
                          final int numTimesBooked =
                              bookingProvider.bookings
                                  .where((b) => b.listingId == listing.id)
                                  .length;

                          // These properties should be present in your ListingModel
                          final int numSeen = listing.views ?? 0;
                          final int numBookmarked = listing.bookmarks ?? 0;

                          String carName = listing.carName ?? '';
                          String carModel = listing.carModel ?? '';
                          String carPlate = listing.carPlate ?? '';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[500],
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: SizedBox(
                                      width: 76,
                                      height: 76,
                                      child: getCarImage(listing.base64Image),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 8,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '[$carName]',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '[${numSeen}] People saw this listing\n'
                                            '[${numBookmarked}] People bookmarked this\n'
                                            'Booked [${numTimesBooked}] times\n'
                                            '• [other details]',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Show add new listing page/dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'New Listing',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Edit selected listing logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Edit This Listing',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Delete selected listing logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
