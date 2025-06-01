import 'package:flutter/material.dart';
import 'package:nab/utils/image_provider.dart';
import 'package:nab/utils/user_provider.dart';
import 'package:nab/utils/listing_provider.dart';
import 'package:provider/provider.dart';

class VendorListingPage extends StatefulWidget {
  final String uid;
  const VendorListingPage({Key? key, required this.uid}) : super(key: key);

  @override
  State<VendorListingPage> createState() => _VendorListingPageState();
}

class _VendorListingPageState extends State<VendorListingPage>
    with AutomaticKeepAliveClientMixin<VendorListingPage> {
  bool _hasFetchedListings = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user != null && !_hasFetchedListings) {
      context.read<ListingProvider>().fetchListingsByVendor(user.id);
      _hasFetchedListings = true;
    }
  }

  void _openListing(String carPlate) {
    // TODO: Implement navigation to listing detail or edit page
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    const headerColor = Color.fromARGB(255, 140, 200, 255);

    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: headerColor,
        centerTitle: true,
        title: const Text(
          'My Listings',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color.fromARGB(255, 27, 27, 27),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        color: Colors.grey[850],
        child: Consumer<ListingProvider>(
          builder: (context, listingProvider, _) {
            final listings = listingProvider.listings;

            if (listings.isEmpty) {
              return const Center(
                child: Text(
                  "No cars listed for rental",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              );
            }

            return GridView.builder(
              itemCount: listings.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1 / 1.3,
              ),
              itemBuilder: (context, index) {
                final car = listings[index];

                ImageProvider? imageProvider;
                try {
                  if (car.image != null && car.image!.isNotEmpty) {
                    imageProvider = MemoryImage(
                      ImageConstants.constants.decodeBase64(car.image!),
                    );
                  }
                } catch (_) {
                  imageProvider = null;
                }

                return InkWell(
                  onTap: () => _openListing(car.carPlate ?? ''),
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
                                car.carModel ?? 'Unknown Model',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                car.carPlate ?? 'N/A',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  letterSpacing: 1.2,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              // Optional additional info like views/bookmarks/bookings can be added here
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
