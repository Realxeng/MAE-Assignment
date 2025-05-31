import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RentalRented extends StatelessWidget {
  const RentalRented({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final completedStream =
        FirebaseFirestore.instance
            .collection('bookings')
            .where(
              'vendor',
              isEqualTo: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid),
            )
            .where('status', isEqualTo: 'completed')
            .snapshots();

    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: StreamBuilder<QuerySnapshot>(
        stream: completedStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No completed rentals.",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final bookings = snapshot.data!.docs;
          bookings.sort((a, b) {
            final aDate =
                (a['dateEnded'] as Timestamp?)?.toDate() ?? DateTime.now();
            final bDate =
                (b['dateEnded'] as Timestamp?)?.toDate() ?? DateTime.now();
            return bDate.compareTo(aDate);
          });

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, i) {
              final data = bookings[i].data() as Map<String, dynamic>;
              final carRef = data['car'] as DocumentReference?;
              final end = (data['dateEnded'] as Timestamp?)?.toDate();
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
                  title: Text(
                    'Rental Complete',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'Ended: ${end?.toString().split(' ').first ?? '-'}\n'
                    'Status: ${data['status']}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Text(
                    "\$${data['price']?.toStringAsFixed(2) ?? '-'}",
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
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
