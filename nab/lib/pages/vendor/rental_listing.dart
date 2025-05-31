import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RentalListing extends StatelessWidget {
  const RentalListing({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final listingStream =
        FirebaseFirestore.instance
            .collection('listing')
            .where('uid', isEqualTo: uid)
            .snapshots();

    return Scaffold(
      backgroundColor: Colors.grey[850],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
        onPressed: () {
          // TODO: Navigate to add new listing page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Add Listing Page Coming Soon!")),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: listingStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No listings found.",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>? ?? {};
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading:
                      data['image'] != null
                          ? CircleAvatar(
                            backgroundImage: NetworkImage(data['image']),
                            radius: 28,
                          )
                          : const CircleAvatar(
                            child: Icon(
                              Icons.directions_car,
                              color: Colors.blueAccent,
                            ),
                            radius: 28,
                            backgroundColor: Colors.white12,
                          ),
                  title: Text(
                    data['carModel'] ?? 'Unknown Model',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Plate: ${data['carPlate'] ?? '-'}\nStatus: ${data['status'] ?? '-'}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent),
                    onPressed: () {
                      // TODO: Edit listing page
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Edit Listing Coming Soon!"),
                        ),
                      );
                    },
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
