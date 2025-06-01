import 'package:flutter/material.dart';
import 'package:nab/utils/booking_provider.dart';
import 'package:nab/utils/image_provider.dart';
import 'package:nab/utils/user_provider.dart';
import 'package:provider/provider.dart';

class CustomerBookingListPage extends StatefulWidget {
  final String uid;
  final void Function(int)? onTabChange;

  const CustomerBookingListPage({
    super.key,
    required this.uid,
    this.onTabChange,
  });

  @override
  State<CustomerBookingListPage> createState() =>
      _CustomerBookingListPageState();
}

class _CustomerBookingListPageState extends State<CustomerBookingListPage>
    with AutomaticKeepAliveClientMixin<CustomerBookingListPage> {
  bool _hasFetchedActiveBookings = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_hasFetchedActiveBookings) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;
      if (user != null) {
        context.read<BookingProvider>().fetchActiveBookings(user);
        _hasFetchedActiveBookings = true;
      }
    }
  }

  void _openBooking(String plate) {
    // Add your navigation or any action for booking tap here
    // For example:
    // Navigator.push(...);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    const headerBlue = Color.fromARGB(255, 140, 200, 255);

    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: headerBlue,
        centerTitle: true,
        title: const Text(
          'Active Bookings',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color.fromARGB(255, 27, 27, 27),
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[850],
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Consumer<BookingProvider>(
          builder: (context, bookingProvider, _) {
            final bookings = bookingProvider.bookings;
            if (bookings.isEmpty) {
              return const Center(
                child: Text(
                  "No active bookings found",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              );
            }

            return GridView.builder(
              itemCount: bookings.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1 / 1.2,
              ),
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final car = booking.car;

                ImageProvider? imageProvider;
                try {
                  if (car?.image != null && car!.image!.isNotEmpty) {
                    imageProvider = MemoryImage(
                      ImageConstants.constants.decodeBase64(car.image!),
                    );
                  }
                } catch (_) {
                  imageProvider = null;
                }

                return InkWell(
                  onTap: () {
                    _openBooking(car?.carPlate ?? "");
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                            ),
                            child:
                                imageProvider != null
                                    ? ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(10),
                                      ),
                                      child: Image(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    )
                                    : const Center(
                                      child: Icon(
                                        Icons.directions_car,
                                        size: 60,
                                      ),
                                    ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(10),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                car?.carModel ?? 'Unknown Model',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                car?.carPlate ?? 'N/A',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1.2,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
