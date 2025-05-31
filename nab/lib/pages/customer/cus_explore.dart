import 'package:flutter/material.dart';
import 'package:nab/utils/image_provider.dart';
import 'package:nab/utils/listing_provider.dart';
import 'package:provider/provider.dart';

class CustomerExplorePage extends StatefulWidget {
  final String uid;
  const CustomerExplorePage({super.key, required this.uid});

  @override
  bool get wantKeepAlive => true;
  @override
  State<CustomerExplorePage> createState() => _CustomerExplorePageState();
}

class _CustomerExplorePageState extends State<CustomerExplorePage>
    with AutomaticKeepAliveClientMixin<CustomerExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTabIndex = 1;
  String selectedCategory = '';

  final List<String> categories = [
    'Compact',
    'SUV',
    'Sedan',
    'Family',
    'MPV',
    'Luxury',
    'Sports',
    'Electric',
    'Hybrid',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch listings after widget build if not already fetched
    final listingProvider = Provider.of<ListingProvider>(
      context,
      listen: false,
    );
    if (listingProvider.listings.isEmpty) {
      listingProvider.fetchAvailableListings();
    }
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure keep alive works
    return Scaffold(
      backgroundColor: Colors.white,
      // App bar with title
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Compare Cars',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 27, 27, 27),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.search, color: Colors.grey),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
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
            const SizedBox(height: 12),

            // Categories horizontal list
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final bool isSelected = selectedCategory == cat;

                  // Customize "More" button style to match '...'
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = cat;
                      });
                    },
                    child: Container(
                      padding:
                          cat == 'More'
                              ? const EdgeInsets.symmetric(horizontal: 12)
                              : const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey[600],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cat == 'More' ? '...' : cat,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Grid of car cards - Flexible to take available space
            Expanded(
              child: Consumer<ListingProvider>(
                builder: (context, listingProvider, _) {
                  final listings = listingProvider.listings;
                  if (listings.isEmpty) {
                    return const Center(child: Text("No cars to display"));
                  }

                  return GridView.builder(
                    itemCount: listings.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 3 / 4,
                        ),
                    itemBuilder: (context, index) {
                      final listing = listings[index];
                      ImageProvider? imageProvider;
                      try {
                        if (listing.image != null &&
                            listing.image!.isNotEmpty) {
                          imageProvider = MemoryImage(
                            ImageConstants.constants.decodeBase64(
                              listing.image!,
                            ),
                          );
                        }
                      } catch (_) {
                        // handle image decode error if any
                        imageProvider = null;
                      }
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            // Placeholder image area
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue[200],
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ),
                                ),
                                child:
                                    imageProvider != null
                                        ? ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                top: Radius.circular(10),
                                              ),
                                          child: Image(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        )
                                        : Center(
                                          child: Icon(
                                            Icons.cloud,
                                            size: 64,
                                            color: const Color.fromRGBO(
                                              255,
                                              255,
                                              255,
                                              0.7,
                                            ),
                                          ),
                                        ),
                              ),
                            ),
                            // Car name and code
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(10),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    listing.carModel ?? 'Unknown Model',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    listing.carPlate ?? 'N/A',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
