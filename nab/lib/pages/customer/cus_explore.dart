import 'package:flutter/material.dart';
import 'package:nab/utils/image_provider.dart';
import 'package:nab/utils/listing_provider.dart';
import 'package:provider/provider.dart';

class CustomerExplorePage extends StatefulWidget {
  final String uid;
  final void Function(int)? onTabChange;
  const CustomerExplorePage({super.key, required this.uid, this.onTabChange});

  @override
  State<CustomerExplorePage> createState() => _CustomerExplorePageState();
}

class _CustomerExplorePageState extends State<CustomerExplorePage>
    with AutomaticKeepAliveClientMixin<CustomerExplorePage> {
  final TextEditingController _searchController = TextEditingController();
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

  void _searchCarByType(String type) {
    context.read<ListingProvider>().fetchListingsByType(type);
    widget.onTabChange?.call(1);
  }

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

  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure keep alive works
    return Scaffold(
      backgroundColor: Colors.grey[850],
      // App bar with title
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 200, 200, 200),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Explore Cars',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color.fromARGB(255, 27, 27, 27),
          ),
        ),
      ),

      body: Container(
        color: Colors.grey[850],
        child: Column(
          children: [
            // Search bar
            Container(
              color: const Color.fromARGB(
                255,
                200,
                200,
                200,
              ), // distinct background color for top section
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 5),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(
                            Icons.search,
                            color: Color.fromARGB(255, 225, 225, 225),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            onSubmitted: (value) => _searchCarByType(value),
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: "Search...",
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: Color.fromARGB(255, 225, 225, 225),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Categories horizontal list
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final bool isSelected = selectedCategory == cat;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = cat;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? Colors.blue : Colors.grey[600],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              cat,
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
                  const SizedBox(height: 12),
                ],
              ),
            ),

            const SizedBox(height: 12),
            // Grid of car cards - Flexible to take available space
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Colors.grey[850]),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
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
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1 / 1.2,
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
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              // Placeholder image area
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
                                      listing.carModel ?? 'Unknown Model',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      listing.carPlate ?? 'N/A',
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
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
