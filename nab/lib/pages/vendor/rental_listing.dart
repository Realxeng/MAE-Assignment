import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RentalListingPage extends StatelessWidget {
  final String vendorUid;

  const RentalListingPage({Key? key, required this.vendorUid})
    : super(key: key);

  Future<List<Map<String, dynamic>>> fetchVendorListings() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('listings')
            .where('vendorId', isEqualTo: vendorUid)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // add doc id for reference if needed
      return data;
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'unavailable':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Colors.grey;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Listings"),
        backgroundColor: Colors.blueGrey,
      ),
      backgroundColor: backgroundColor[900],
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchVendorListings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          final listings = snapshot.data ?? [];

          if (listings.isEmpty) {
            return const Center(
              child: Text(
                "No listings found",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: listings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final listing = listings[index];
              final title = listing['title'] ?? 'Untitled';
              final status = listing['status'] ?? 'Unknown';
              final imageBase64 = listing['image'];
              ImageProvider? imageProvider;
              try {
                if (imageBase64 != null &&
                    imageBase64 is String &&
                    imageBase64.isNotEmpty) {
                  imageProvider = MemoryImage(
                    // Assuming image is base64 encoded string, decode it here
                    // Import dart:convert at top: import 'dart:convert';
                    // And decode as:
                    base64Decode(imageBase64),
                  );
                }
              } catch (_) {
                imageProvider = null;
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        imageProvider != null
                            ? Image(
                              image: imageProvider,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                            : const Icon(
                              Icons.home_work,
                              size: 60,
                              color: Colors.white70,
                            ),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status.toString().toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    // Optionally implement detail or edit page navigation here
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
