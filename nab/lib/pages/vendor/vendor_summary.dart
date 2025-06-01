import 'package:flutter/material.dart';
import 'package:nab/pages/common/user_edit_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nab/utils/image_provider.dart';
import 'package:nab/utils/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class VendorHomePage extends StatefulWidget {
  final String uid;
  final void Function(int)? onTabChange;
  const VendorHomePage({super.key, required this.uid, this.onTabChange});

  @override
  State<VendorHomePage> createState() => _VendorHomePageState();
}

class _VendorHomePageState extends State<VendorHomePage>
    with AutomaticKeepAliveClientMixin<VendorHomePage> {
  List<double> earnings = [600, 750, 700, 650, 400];
  String? userName;

  Future<void> _loadUserName() async {
    final userProvider = context.read<UserProvider>();
    userProvider.onSignedOut = () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have been signed out.")),
      );
      Navigator.pushReplacementNamed(context, '/login');
    };
  }

  ImageProvider _getProfileImage() {
    final userProvider = context.watch<UserProvider>();
    final profileImage = userProvider.user?.profileImage ?? "User";
    return MemoryImage(ImageConstants.constants.decodeBase64(profileImage));
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userProvider = context.watch<UserProvider>();
    userName = userProvider.user?.username ?? "Vendor";
    return Scaffold(
      backgroundColor: Color(0xFF222733),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Top Profile & Name
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => EditProfilePage(uid: widget.uid),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 24,
                        backgroundImage: _getProfileImage(),
                      ),
                    ),
                    SizedBox(width: 14),
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 26,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 22),
                // Monthly Earning Title and See More
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Monthly Earning",
                      style: TextStyle(
                        color: Colors.amber[200],
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Add see more function or navigation
                      },
                      child: Text(
                        "See More",
                        style: TextStyle(
                          color: Colors.blue[200],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                // Earning Chart
                SizedBox(height: 140, child: _buildBarChart()),
                SizedBox(height: 20),
                // Recent Rental Title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Recent Rental',
                    style: TextStyle(
                      color: Colors.greenAccent[400],
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                // List of Recent Rentals (empty)
                ...List.generate(
                  4,
                  (idx) => Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.radio_button_unchecked,
                          color: Colors.grey[400],
                        ),
                        SizedBox(width: 14),
                        Expanded(
                          child: Container(height: 2, color: Colors.white24),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _VendorNavBar(onTabChange: widget.onTabChange),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        backgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        groupsSpace: 16,
        barGroups: List.generate(6, (i) {
          double y = i < earnings.length ? earnings[i] : 0;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: y,
                color: y == 0 ? Colors.white12 : Colors.blueAccent,
                borderRadius: BorderRadius.circular(4),
                width: 18,
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 250,
              getTitlesWidget: (value, meta) {
                if (value % 250 == 0) {
                  return Text(
                    'RM${value.toInt()}',
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                  );
                }
                return Container();
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final labels = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN'];
                if (value >= 0 && value < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      labels[value.toInt()],
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine:
              (v) => FlLine(color: Colors.white12, strokeWidth: 1),
        ),
        minY: 0,
        maxY: 1000,
      ),
    );
  }
}

class _VendorNavBar extends StatelessWidget {
  final void Function(int)? onTabChange;
  const _VendorNavBar({this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          NavBarItem(
            icon: Icons.dashboard,
            label: "Dashboard",
            onTap: () => onTabChange?.call(0),
          ),
          NavBarItem(
            icon: Icons.list_alt,
            label: "Listings",
            onTap: () => onTabChange?.call(1),
          ),
          NavBarItem(
            icon: Icons.directions_car,
            label: "Rentals",
            onTap: () => onTabChange?.call(2),
          ),
          NavBarItem(
            icon: Icons.person,
            label: "Profile",
            onTap: () => onTabChange?.call(3),
          ),
        ],
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const NavBarItem({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 66,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70),
            SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.88),
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
