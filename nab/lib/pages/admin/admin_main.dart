import 'package:flutter/material.dart';
import 'package:nab/pages/admin/admin_home_page.dart';
import 'package:nab/pages/admin/admin_verify_listings.dart';
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
      //VerifyListingsPage(),        // Your home page for admin
      //ManageUsersPage(),     // Your manage users page
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
              child: Icon(Icons.people),
            ),
            label: 'Manage Users',
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
              child: Icon(Icons.account_circle, size: 30),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}