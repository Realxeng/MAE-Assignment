import 'package:flutter/material.dart';
import 'package:nab/utils/image_provider.dart';
import 'package:nab/utils/booking_provider.dart';
import 'package:nab/utils/listing_provider.dart';
import 'package:provider/provider.dart';

class CustomerBookingPage extends StatefulWidget {
  final String uid;
  final String plate; // Id of car/listing being booked

  const CustomerBookingPage({
    super.key,
    required this.uid,
    required this.plate,
  });

  @override
  State<CustomerBookingPage> createState() => _CustomerBookingPageState();
}

class _CustomerBookingPageState extends State<CustomerBookingPage> {
  bool _isLoading = true;
  String carModel = '';
  String carPlate = '';
  String? base64Image;
  String vendorName = '';
  String vendorContact = '';
  String vendorAddress = '';

  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
  }

  Future<void> _loadBookingDetails() async {
    final listingProvider = context.read<ListingProvider>();
    await listingProvider.fetchListingsByPlate(widget.plate);
    final listing = listingProvider.listings;
    setState(() {
      carModel = listing[0].carModel ?? "";
      carPlate = listing[0].carPlate ?? "";
      base64Image = listing[0].image ?? "";
      vendorName = listing[0].user?.fullName ?? "";
      vendorContact = listing[0].contactNumber.toString() ?? "";
      vendorAddress = listing[0].user?.township ?? "";
      _isLoading = false;
    });
  }

  void _confirmBooking() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Booking Confirmed!')));
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider =
        (base64Image != null && base64Image!.isNotEmpty)
            ? MemoryImage(ImageConstants.constants.decodeBase64(base64Image!))
            : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Booking"),
        backgroundColor: Colors.grey[900],
        leading: BackButton(color: Colors.white),
      ),
      backgroundColor: Colors.grey[850],
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Placeholder map container (replace with actual map widget if you want)
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[700],
                      ),
                      child: Center(
                        child: Text(
                          'Map Placeholder\n(Integrate Google Map or other here)',
                          style: TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Car Info Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black45, blurRadius: 6),
                        ],
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child:
                                imageProvider != null
                                    ? Image(
                                      image: imageProvider,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                    : Container(
                                      height: 180,
                                      color: Colors.grey[700],
                                      child: const Icon(
                                        Icons.directions_car,
                                        size: 80,
                                        color: Colors.white70,
                                      ),
                                    ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              "$carModel\n$carPlate",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Vendor Info Card
                    Text(
                      "Vendor",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey[700],
                            child: Text(
                              vendorName.isNotEmpty
                                  ? vendorName[0].toUpperCase()
                                  : "?",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vendorName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  vendorContact,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                Text(
                                  vendorAddress,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Confirm Booking Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _confirmBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Confirm Booking",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
