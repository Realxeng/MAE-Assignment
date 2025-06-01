// monthly_earnings_breakdown_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nab/utils/booking_provider.dart';

class MonthlyEarningsBreakdownPage extends StatelessWidget {
  final String vendorUid;

  const MonthlyEarningsBreakdownPage({Key? key, required this.vendorUid})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final now = DateTime.now();
    final income = bookingProvider.calculateYearlyIncome(vendorUid, now.year);

    return Scaffold(
      appBar: AppBar(title: const Text("Monthly Earnings")),
      body: ListView.builder(
        itemCount: 12,
        itemBuilder: (context, index) {
          final month = index + 1;
          final earning = income[month] ?? 0.0;
          return ListTile(
            leading: Text(
              _monthLabel(month),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Text("RM${earning.toStringAsFixed(2)}"),
          );
        },
      ),
    );
  }

  String _monthLabel(int month) {
    const labels = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return labels[month - 1];
  }
}
