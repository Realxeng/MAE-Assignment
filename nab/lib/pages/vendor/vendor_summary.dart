// vendor_home_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:nab/pages/common/user_edit_profile.dart';
import 'package:nab/utils/booking_provider.dart';
import 'package:nab/pages/vendor/rental_income_breakdown.dart';

class VendorHomePage extends StatefulWidget {
  final String uid;

  const VendorHomePage({Key? key, required this.uid}) : super(key: key);

  @override
  State<VendorHomePage> createState() => _VendorHomePageState();
}

class _VendorHomePageState extends State<VendorHomePage> {
  int _selectedIndex = 0;

  List<double> monthlyEarnings = List.filled(6, 0);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildDashboard(),
      _buildPlaceholder('Listing Page'),
      _buildPlaceholder('Rental Page'),
      _buildProfile(),
    ];

    final Color backgroundColor = Colors.grey[900]!;
    final Color selectedItemColor = const Color.fromARGB(255, 140, 200, 255);
    final Color unselectedItemColor = Colors.white70;

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: backgroundColor,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: unselectedItemColor,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'DASHBOARD',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.car_rental),
            label: 'LISTING',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_returned),
            label: 'RENTAL',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PROFILE'),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final darkBackground = Colors.grey[900];
    final headerBlue = const Color.fromARGB(255, 140, 200, 255);
    final lightText = Colors.white;
    final subText = Colors.white70;
    final uid = widget.uid;

    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
        child: Consumer<BookingProvider>(
          builder: (context, bookingProvider, _) {
            final incomeMap = bookingProvider.calculateYearlyIncome(
              uid,
              DateTime.now().year,
            );

            monthlyEarnings = List.generate(6, (i) => incomeMap[i + 1] ?? 0.0);

            // Get recent finished bookings for this vendor, sorted by dateStarted descending
            List finishedBookings =
                bookingProvider.bookings.where((booking) {
                  return booking.vendor != null &&
                      booking.vendor!.id == uid &&
                      booking.status == "finished" &&
                      booking.dateStarted != null;
                }).toList();

            finishedBookings.sort(
              (a, b) => b.dateStarted!.compareTo(a.dateStarted!),
            );

            final recentRentals = finishedBookings.take(4).toList();

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(uid: uid),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[700],
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Dashboard",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: lightText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Monthly Earning",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: lightText,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => MonthlyEarningsBreakdownPage(
                                      vendorUid: uid,
                                    ),
                              ),
                            );
                          },
                          child: Text(
                            "See More",
                            style: TextStyle(
                              fontSize: 13,
                              color: headerBlue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 180,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: _calculateMaxY(monthlyEarnings),
                            barGroups: List.generate(
                              6,
                              (index) => BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: monthlyEarnings[index],
                                    color: headerBlue,
                                    width: 18,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ],
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: _calculateInterval(monthlyEarnings),
                                  getTitlesWidget: (value, meta) {
                                    if ((value %
                                                _calculateInterval(
                                                  monthlyEarnings,
                                                )) ==
                                            0 &&
                                        value <=
                                            _calculateMaxY(monthlyEarnings)) {
                                      return Text(
                                        "RM${value.toInt()}",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: lightText,
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    const labels = [
                                      "JAN",
                                      "FEB",
                                      "MAR",
                                      "APR",
                                      "MAY",
                                      "JUN",
                                    ];
                                    if (value.toInt() < labels.length) {
                                      return Text(
                                        labels[value.toInt()],
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: lightText,
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              horizontalInterval: _calculateInterval(
                                monthlyEarnings,
                              ),
                              drawVerticalLine: false,
                              getDrawingHorizontalLine:
                                  (value) => FlLine(
                                    color: Colors.white12,
                                    strokeWidth: 1,
                                  ),
                            ),
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    Text(
                      "Recent Rental",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: lightText,
                      ),
                    ),
                    const SizedBox(height: 8),

                    recentRentals.isEmpty
                        ? Text(
                          "No recent rentals",
                          style: TextStyle(color: subText),
                        )
                        : Column(
                          children:
                              recentRentals.map((booking) {
                                final started =
                                    booking.dateStarted != null
                                        ? "${booking.dateStarted!.day.toString().padLeft(2, '0')}/"
                                            "${booking.dateStarted!.month.toString().padLeft(2, '0')}/"
                                            "${booking.dateStarted!.year}"
                                        : "No Date";
                                final priceStr =
                                    booking.price != null
                                        ? "RM${booking.price!.toStringAsFixed(2)}"
                                        : "N/A";
                                final notes = booking.notes ?? "";

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.car_rental, color: headerBlue),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              priceStr,
                                              style: TextStyle(
                                                color: lightText,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            if (notes.isNotEmpty)
                                              Text(
                                                notes,
                                                style: TextStyle(
                                                  color: subText,
                                                  fontSize: 12,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        started,
                                        style: TextStyle(
                                          color: subText,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                        ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  double _calculateMaxY(List<double> earnings) {
    final max =
        earnings.isEmpty ? 1000 : earnings.reduce((a, b) => a > b ? a : b);
    if (max < 1000) return 1000;
    return (max / 100).ceil() * 100.0;
  }

  double _calculateInterval(List<double> earnings) {
    final maxY = _calculateMaxY(earnings);
    if (maxY <= 1000) return 250;
    return maxY / 4;
  }

  Widget _buildProfile() {
    final darkBackground = Colors.grey[900];
    final lightText = Colors.white;

    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
        child: Center(
          child: Text(
            'Profile Page',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: lightText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String title) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
