import 'package:flutter/material.dart';
import 'package:nab/pages/admin/admin_home_page.dart';
import 'package:nab/pages/admin/admin_manage_listings.dart';
import 'package:nab/pages/admin/admin_view_bookings.dart';

class AdminMainPage extends StatefulWidget {
  final String uid;
  const AdminMainPage({super.key, required this.uid});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      AdminHomePage(uid: widget.uid),
      ManageListingsPage(),    
      ViewBookingsPage(),    // Your view bookings page as you shared earlier
      //ViewFeedbacksPage(),   // Your view feedbacks page
    ];
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.grey[900],
        showUnselectedLabels: true, 
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Icon(Icons.home),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Icon(Icons.car_rental, size: 30),
            ),
            label: 'Manage Listings',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Icon(Icons.calendar_today),
            ),
            label: 'View Bookings',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Icon(Icons.account_circle, size: 25),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}