import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nab/utils/user_provider.dart';
import 'package:nab/pages/vendor/rental_dashboard.dart';
import 'package:nab/pages/vendor/rental_listing.dart';
import 'package:nab/pages/vendor/rental_schedule.dart';
import 'package:nab/pages/vendor/rental_rented.dart';

class VendorHomePage extends StatefulWidget {
  final String uid; // uid added as a required named parameter

  const VendorHomePage({Key? key, required this.uid}) : super(key: key);

  @override
  State<VendorHomePage> createState() => _VendorHomePageState();
}

class _VendorHomePageState extends State<VendorHomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Pass uid down to pages if required or use Provider to load user data with uid
    _pages = const [
      RentalDashboard(),
      RentalListing(),
      RentalSchedule(),
      RentalRented(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Optionally, get username from a user provider using widget.uid if you want to do so:
    final userProvider = context.watch<UserProvider>();
    final userName = userProvider.user?.username ?? "Vendor";

    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, $userName'),
        backgroundColor: Colors.grey[900],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey[500],
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: 'Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            label: 'Rented',
          ),
        ],
      ),
    );
  }
}
