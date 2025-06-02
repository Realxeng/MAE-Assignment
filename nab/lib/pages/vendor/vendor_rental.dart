import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nab/utils/booking_provider.dart';
import 'package:nab/models/booking.dart';
import 'package:nab/utils/image_provider.dart';

class VendorBookingPage extends StatefulWidget {
  final String vendorUid;
  const VendorBookingPage({Key? key, required this.vendorUid})
    : super(key: key);

  @override
  State<VendorBookingPage> createState() => _VendorBookingPageState();
}

class _VendorBookingPageState extends State<VendorBookingPage>
    with AutomaticKeepAliveClientMixin<VendorBookingPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider>().fetchBookingsForVendorUnacknowledged(
        widget.vendorUid,
      );
    });
  }

  void _showBookingDetails(BookingModel booking) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            booking.car?.carModel ?? 'Unknown Car Model',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (booking.car?.image != null &&
                    booking.car!.image!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      ImageConstants.constants.decodeBase64(
                        booking.car!.image!,
                      ),
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 140,
                    color: Colors.grey[700],
                    child: const Icon(
                      Icons.directions_car,
                      size: 80,
                      color: Colors.white70,
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  'Car Plate: ${booking.car?.carPlate ?? 'N/A'}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  'Customer: ${booking.customer?.fullName ?? 'Unknown'}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  'Contact: ${booking.customer?.email ?? 'N/A'}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  'Notes: ${booking.notes ?? "None"}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  'Status: ${booking.status ?? "Unknown"}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await context.read<BookingProvider>().acknowledgeBooking(
                    booking,
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking acknowledged')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to acknowledge booking: $e'),
                    ),
                  );
                }
              },
              child: const Text(
                'Acknowledge',
                style: TextStyle(color: Colors.greenAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // for AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 140, 200, 255),
        centerTitle: true,
        title: const Text(
          'Pending Bookings',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color.fromARGB(255, 27, 27, 27),
          ),
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, _) {
          final bookings =
              bookingProvider.bookings
                  .where(
                    (booking) =>
                        booking.status?.toLowerCase() != 'finished' &&
                        booking.status?.toLowerCase() != 'completed',
                  )
                  .toList();

          if (bookings.isEmpty) {
            return const Center(
              child: Text(
                'No pending booking requests',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];

              return Card(
                color: Colors.grey[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  onTap: () => _showBookingDetails(booking),
                  leading:
                      booking.car?.image != null &&
                              booking.car!.image!.isNotEmpty
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.memory(
                              ImageConstants.constants.decodeBase64(
                                booking.car!.image!,
                              ),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                          : const Icon(Icons.directions_car, size: 48),
                  title: Text(
                    booking.car?.carModel ?? 'Unknown Model',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Plate: ${booking.car?.carPlate ?? 'N/A'}\nCustomer: ${booking.customer?.fullName ?? 'N/A'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white70,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
