import 'package:flutter/material.dart';
import 'package:nab/utils/booking_provider.dart';
import 'package:nab/utils/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:nab/utils/image_provider.dart';
import 'package:nab/utils/listing_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerHomePage extends StatefulWidget {
  final String uid;
  final VoidCallback? onChangeTab;
  const CustomerHomePage({super.key, required this.uid, this.onChangeTab});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage>
    with AutomaticKeepAliveClientMixin<CustomerHomePage> {
  bool _hasFetchedBookings = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      userProvider.onSignedOut = () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You have been signed out.")),
        );
        Navigator.pushReplacementNamed(context, '/login');
      };
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<UserProvider>(context, listen: false).user;

    if (user != null && !_hasFetchedBookings) {
      context.read<BookingProvider>().fetchPastBookings(user);
      context.read<ListingProvider>().fetchAvailableListings();
      _hasFetchedBookings = true;
    }
  }

  ImageProvider _getProfileImage() {
    final userProvider = context.watch<UserProvider>();
    final profileImage = userProvider.user?.profileImage ?? "User";
    return MemoryImage(ImageConstants.constants.decodeBase64(profileImage));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = context.watch<UserProvider>().user;
    if (user == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final username = user.username ?? "User";
    final fullName = user.fullName ?? "";
    const borderRadius = BorderRadius.all(Radius.circular(16));
    final bgColor = Color.fromARGB(255, 200, 200, 200);
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section: Welcome and SOS button
              Container(
                color: bgColor,
                padding: const EdgeInsets.only(
                  bottom: 16,
                ), // some bottom spacing
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 20, 12, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () => widget.onChangeTab?.call(),
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 2,
                                top: 2,
                                bottom: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundImage: _getProfileImage(),
                                    backgroundColor: const Color.fromARGB(
                                      255,
                                      85,
                                      160,
                                      222,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          username,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromRGBO(
                                              21,
                                              21,
                                              21,
                                              1,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          fullName,
                                          style: TextStyle(
                                            color: const Color.fromARGB(
                                              255,
                                              150,
                                              150,
                                              150,
                                            ),
                                            fontSize: 15,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 26),
                                ],
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(30),
                              onTap: () async {
                                try {
                                  await context.read<UserProvider>().signOut();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Failed to make SOS call: $e",
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.sos,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: borderRadius,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 5),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(Icons.search, color: Colors.grey),
                            ),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: "Search...",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Quick Filter Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _QuickFilterButton(text: "Near Me!")),
                          const SizedBox(width: 12),
                          Expanded(child: _QuickFilterButton(text: "Compact")),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 12,
                        bottom: 4,
                      ),
                      child: Row(
                        children: [
                          Expanded(child: _QuickFilterButton(text: "Sedan")),
                          const SizedBox(width: 12),
                          Expanded(child: _QuickFilterButton(text: "...")),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Recommendation Title
              Container(
                padding: const EdgeInsets.only(bottom: 80),
                color: Colors.grey[850],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(12, 14, 0, 8),
                      child: Text(
                        "Recommendation",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Recommendations Section
                    Consumer<ListingProvider>(
                      builder: (context, listingProvider, child) {
                        final listings = listingProvider.listings;
                        if (listings.isEmpty) {
                          return const SizedBox(
                            height: 144,
                            child: Center(
                              child: Text("No recommendations available"),
                            ),
                          );
                        }
                        return SizedBox(
                          height: 144,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(left: 12, right: 12),
                            itemCount: listings.length,
                            itemBuilder: (context, index) {
                              final listing = listings[index];
                              return _CarCard(
                                title: listing.carModel ?? 'Car Model',
                                plateNumber: listing.carPlate,
                                image: MemoryImage(
                                  ImageConstants.constants.decodeBase64(
                                    listing.image ?? '',
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),

                    // Past Bookings Title
                    const Padding(
                      padding: EdgeInsets.fromLTRB(12, 20, 0, 8),
                      child: Text(
                        "Past Bookings",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Past Bookings Section
                    Consumer<BookingProvider>(
                      builder: (context, bookingProvider, child) {
                        final pastBookings = bookingProvider.bookings;
                        if (pastBookings.isEmpty) {
                          return SizedBox(
                            height: 140,
                            child: Center(
                              child: Text("No past bookings found"),
                            ),
                          );
                        }

                        return SizedBox(
                          height: 140,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.only(left: 12, right: 12),
                            separatorBuilder:
                                (_, __) => const SizedBox(width: 12),
                            itemCount: pastBookings.length,
                            itemBuilder: (context, index) {
                              final booking = pastBookings[index];
                              final car = booking.car;

                              ImageProvider? imageProvider;

                              final base64Image = car?.image;
                              if (base64Image != null &&
                                  base64Image.isNotEmpty) {
                                try {
                                  imageProvider = MemoryImage(
                                    ImageConstants.constants.decodeBase64(
                                      base64Image,
                                    ),
                                  );
                                } catch (e) {
                                  // If decoding fails, fallback to placeholder
                                  imageProvider = null;
                                }
                              }
                              return _CarBookingCard(
                                carModel: car?.carModel ?? 'Unknown Model',
                                plateNumber: car?.carPlate ?? 'Unknown Plate',
                                image: imageProvider,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> triggerSOSCall() async {
    final Uri emergencyUri = Uri(scheme: 'tel', path: '911');

    if (await canLaunchUrl(emergencyUri)) {
      await launchUrl(emergencyUri, mode: LaunchMode.externalApplication);
    } else {
      print('Could not launch phone dialer.');
    }
  }
}

// --- Helper Widgets (same as before, keep them as StatelessWidget) ---
class _QuickFilterButton extends StatelessWidget {
  final String text;
  const _QuickFilterButton({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 150, 150, 150),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
    );
  }
}

class _CarCard extends StatelessWidget {
  final String title;
  final String? plateNumber; // car plate number
  final ImageProvider? image;

  const _CarCard({this.title = "Perodua Myvi", this.plateNumber, this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 220, // fixed height for consistent layout
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image (stretched)
            if (image != null)
              Image(image: image!, fit: BoxFit.cover)
            else
              Container(
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(
                    Icons.directions_car,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
              ),

            // Description box with transparent background (inside gradient)
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  color: Color.fromRGBO(12, 12, 12, 0.7),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 2, 18, 9),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (plateNumber != null)
                            Text(
                              plateNumber!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CarBookingCard extends StatelessWidget {
  final String carModel;
  final String plateNumber;
  final ImageProvider? image;

  const _CarBookingCard({
    required this.carModel,
    required this.plateNumber,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child:
                  image != null
                      ? Image(
                        image: image!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                      : Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(Icons.directions_car, size: 60),
                        ),
                      ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            child: Text(
              "$carModel\n$plateNumber",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
