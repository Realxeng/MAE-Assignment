import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyEarning {
  final String monthYear;
  final double totalAmount;

  MonthlyEarning({required this.monthYear, required this.totalAmount});
}

class MonthlyEarningsBreakdownPage extends StatefulWidget {
  final String vendorUid;

  const MonthlyEarningsBreakdownPage({Key? key, required this.vendorUid})
    : super(key: key);

  @override
  State<MonthlyEarningsBreakdownPage> createState() =>
      _MonthlyEarningsBreakdownPageState();
}

class _MonthlyEarningsBreakdownPageState
    extends State<MonthlyEarningsBreakdownPage> {
  late Future<List<MonthlyEarning>> _futureEarnings;

  @override
  void initState() {
    super.initState();
    _futureEarnings = fetchMonthlyEarnings(widget.vendorUid);
  }

  Future<List<MonthlyEarning>> fetchMonthlyEarnings(String vendorUid) async {
    try {
      final vendorRef = FirebaseFirestore.instance
          .collection('users')
          .doc(vendorUid);

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('bookings')
              .where('vendor', isEqualTo: vendorRef)
              .where('status', isEqualTo: 'finished')
              .get();

      print("Fetched bookings count: ${querySnapshot.docs.length}");

      Map<String, double> earningsMap = {};

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final Timestamp? dateEndedTs = data['dateEnded'] as Timestamp?;
        final price = (data['price'] as num?)?.toDouble() ?? 0;

        if (dateEndedTs == null) {
          print("Skipping doc ${doc.id} due to null dateEnded");
          continue;
        }

        final dateEnded = dateEndedTs.toDate();
        final monthYear = DateFormat('MMM yyyy').format(dateEnded);

        earningsMap[monthYear] = (earningsMap[monthYear] ?? 0) + price;
      }

      final earningsList =
          earningsMap.entries
              .map(
                (entry) => MonthlyEarning(
                  monthYear: entry.key,
                  totalAmount: entry.value,
                ),
              )
              .toList();

      earningsList.sort((a, b) {
        final aDate = DateFormat('MMM yyyy').parse(a.monthYear);
        final bDate = DateFormat('MMM yyyy').parse(b.monthYear);
        return bDate.compareTo(aDate);
      });

      return earningsList;
    } catch (e) {
      print("Error fetching monthly earnings: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkBackground = Colors.grey[900];
    final lightText = Colors.white;
    final headerBlue = const Color.fromARGB(255, 140, 200, 255);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkBackground,
        title: const Text('Monthly Earnings Breakdown'),
      ),
      backgroundColor: darkBackground,
      body: FutureBuilder<List<MonthlyEarning>>(
        future: _futureEarnings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading earnings',
                style: TextStyle(color: lightText),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No earnings data found.',
                style: TextStyle(color: lightText),
              ),
            );
          }

          final earnings = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: earnings.length,
            separatorBuilder: (_, __) => const Divider(color: Colors.white24),
            itemBuilder: (context, index) {
              final earning = earnings[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  earning.monthYear,
                  style: TextStyle(
                    color: lightText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: Text(
                  'RM${earning.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: headerBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
