import 'package:flutter/material.dart';
import 'package:nab/models/listing.dart';
import 'package:nab/utils/image_provider.dart';
import 'package:nab/utils/booking_provider.dart';
import 'package:nab/utils/listing_provider.dart';
import 'package:nab/utils/user_provider.dart';
import 'package:provider/provider.dart';

class CustomerBookingPage extends StatefulWidget {
  final String uid;
  final void Function(int)? onTabChange;
  final String? plate;

  const CustomerBookingPage({
    super.key,
    required this.uid,
    required this.onTabChange,
    required this.plate,
  });

  @override
  State<CustomerBookingPage> createState() => _CustomerBookingPageState();
}

class _CustomerBookingPageState extends State<CustomerBookingPage>
    with AutomaticKeepAliveClientMixin<CustomerBookingPage> {
  bool _isLoading = true;
  String carModel = '';
  String carPlate = '';
  String carType = '';
  String condition = '';
  String? base64Image;
  String vendorName = '';
  String vendorContact = '';
  String vendorAddress = '';
  String vendorPicture = '';
  late ListingModel listing;

  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _loadBookingDetails() async {
    try {
      await context.read<ListingProvider>().fetchListingsByPlate(
        widget.plate ?? "",
      );
      final listing = context.read<ListingProvider>().singleListing;
      if (listing != null) {
        this.listing = listing;
        final vendor = listing.user;
        if (vendor != null) {
          setState(() {
            carModel = listing.carModel ?? "";
            carPlate = listing.carPlate ?? "";
            base64Image = listing.image ?? "";
            carType = listing.carType ?? "";
            condition = listing.vehicleCondition ?? "";
            vendorName = vendor.fullName ?? "";
            vendorContact = listing.contactNumber?.toString() ?? "";
            vendorAddress = vendor.township ?? "";
            vendorPicture = vendor.profileImage ?? "";
            _isLoading = false; // <-- Add this line here!
          });
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error fetching vendor data")),
          );
        }
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error fetching listing data")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to fetch listing: $e")));
    }
  }

  void _confirmBooking(String notes) async {
    final bookingProvider = context.read<BookingProvider>();
    final userProvider = context.read<UserProvider>();
    await userProvider.fetchUserData(widget.uid);
    final user = userProvider.user;
    bookingProvider.addBooking(listing, listing.user!, user!, notes);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Booking Sent!')));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final carImageProvider =
        (base64Image != null && base64Image!.isNotEmpty)
            ? MemoryImage(ImageConstants.constants.decodeBase64(base64Image!))
            : null;
    final vendorImageProvider =
        (vendorPicture != "" && vendorPicture.isNotEmpty)
            ? MemoryImage(ImageConstants.constants.decodeBase64(vendorPicture))
            : null;
    final TextEditingController _notesController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Booking"),
        backgroundColor: const Color.fromARGB(255, 200, 200, 200),
        leading: BackButton(color: const Color.fromARGB(255, 0, 0, 0)),
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

                    // Car Image Container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black45, blurRadius: 6),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child:
                            carImageProvider != null
                                ? Image(
                                  image: carImageProvider,
                                  height: 280,
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
                    ),

                    const SizedBox(height: 12),

                    // Car Details Container
                    Container(
                      width: double.infinity, // <--- add this
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black45, blurRadius: 6),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            carModel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            carPlate,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            "Car Type: $carType",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            "Condition: $condition",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
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
                            radius: 28,
                            child:
                                vendorImageProvider != null
                                    ? Image(
                                      image: vendorImageProvider,
                                      height: 220,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                    : Text(
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
                                Row(
                                  children: [
                                    Icon(Icons.call, size: 16),
                                    Text(
                                      vendorContact,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
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
                    const SizedBox(height: 16),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Add booking notes',
                        hintStyle: TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.grey[800],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Confirm Booking Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _confirmBooking("");
                        },
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
                            color: Colors.white,
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
