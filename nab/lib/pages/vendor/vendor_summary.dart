import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nab/pages/common/user_edit_profile.dart';
import 'package:nab/pages/vendor/rental_listing.dart';
// Import your rental_income_breakdown.dart file here:
import 'package:nab/pages/vendor/rental_income_breakdown.dart';

class VendorHomePage extends StatefulWidget {
  final String uid;

  const VendorHomePage({Key? key, required this.uid}) : super(key: key);

  @override
  State<VendorHomePage> createState() => _VendorHomePageState();
}

class _VendorHomePageState extends State<VendorHomePage> {
  int _selectedIndex = 0; // Dashboard now at index 0

  final List<double> monthlyEarnings = const [750, 900, 850, 700, 500, 0];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
        child: SingleChildScrollView(
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
                        child: const Icon(Icons.person, color: Colors.white),
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

                /// Monthly Earnings and See More Row with navigation
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
                        maxY: 1000,
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
                              interval: 250,
                              getTitlesWidget: (value, meta) {
                                if (value % 250 == 0 && value <= 1000) {
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
                          horizontalInterval: 250,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine:
                              (value) =>
                                  FlLine(color: Colors.white12, strokeWidth: 1),
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ),

                /// Recent Rental Title
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

                /// Placeholder rental list
                Column(
                  children: List.generate(
                    4,
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Icon(Icons.circle_outlined, size: 18, color: subText),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildDashboard(), // index 0
      _buildPlaceholder('Listing Page'), // index 1
      _buildPlaceholder('Rental Page'), // index 2
      _buildProfile(), // index 3 (Profile)
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
          ), // now at leftmost (index 0)
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
}

class _DashboardAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? extraWidget;

  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;

  const _DashboardAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.extraWidget,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.grey.shade200;
    final iconCol = iconColor ?? Colors.black87;
    final txtColor = textColor ?? Colors.black87;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: iconCol),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: txtColor),
            ),
            if (extraWidget != null)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: extraWidget,
              ),
          ],
        ),
      ),
    );
  }
}
