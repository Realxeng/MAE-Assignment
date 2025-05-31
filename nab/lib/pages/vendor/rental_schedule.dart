import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RentalSchedule extends StatelessWidget {
  const RentalSchedule({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final bookingsStream =
        FirebaseFirestore.instance
            .collection('bookings')
            .where(
              'vendor',
              isEqualTo: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid),
            )
            .where('status', isEqualTo: 'active')
            .snapshots();

    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: StreamBuilder<QuerySnapshot>(
        stream: bookingsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No upcoming bookings.",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final bookings = snapshot.data!.docs;
          // Sorted by start date ascending
          bookings.sort((a, b) {
            final aDate =
                (a['dateStarted'] as Timestamp?)?.toDate() ?? DateTime.now();
            final bDate =
                (b['dateStarted'] as Timestamp?)?.toDate() ?? DateTime.now();
            return aDate.compareTo(bDate);
          });

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, i) {
              final data = bookings[i].data() as Map<String, dynamic>;
              final carRef = data['car'] as DocumentReference?;
              final start = (data['dateStarted'] as Timestamp?)?.toDate();
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
                    'Booking (Status: ${data['status']})',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'From: ${start?.toString().split(' ').first ?? '-'}\n'
                    'To: ${end?.toString().split(' ').first ?? '-'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  isThreeLine: true,
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
