import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RentalDashboard extends StatelessWidget {
  const RentalDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('listing')
                  .where('uid', isEqualTo: uid)
                  .snapshots(),
          builder: (context, listingSnap) {
            final listingCount = listingSnap.data?.docs.length ?? 0;

            return StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('bookings')
                      .where(
                        'vendor',
                        isEqualTo: FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid),
                      )
                      .snapshots(),
              builder: (context, bookingSnap) {
                final bookingCount = bookingSnap.data?.docs.length ?? 0;
                final activeCount =
                    bookingSnap.data?.docs
                        .where((doc) => doc['status'] == 'active')
                        .length ??
                    0;
                final completedCount =
                    bookingSnap.data?.docs
                        .where((doc) => doc['status'] == 'completed')
                        .length ??
                    0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _statCard('Your Listings', listingCount),
                    _statCard('Active Bookings', activeCount),
                    _statCard('Total Bookings', bookingCount),
                    _statCard('Completed Rentals', completedCount),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _statCard(String label, int count) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 20, color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
