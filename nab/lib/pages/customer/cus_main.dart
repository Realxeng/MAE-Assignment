import 'package:flutter/material.dart';
import 'package:nab/pages/common/user_edit_profile.dart';
import 'package:nab/pages/customer/cus_booking.dart';
import 'package:nab/pages/customer/cus_explore.dart';
import 'package:nab/pages/customer/cus_home_page.dart';
import 'package:nab/utils/listing_provider.dart';
import 'package:provider/provider.dart';

class CustomerMainPage extends StatefulWidget {
  final String uid;
  const CustomerMainPage({super.key, required this.uid});

  @override
  State<CustomerMainPage> createState() => _CustomerMainPageState();
}

class _CustomerMainPageState extends State<CustomerMainPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      CustomerHomePage(uid: widget.uid, onTabChange: _onTabChange),
      CustomerExplorePage(uid: widget.uid, onTabChange: _onTabChange),
      EditProfilePage(uid: widget.uid),
    ];
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _onTabChange(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
    if (_selectedIndex == 0) {
      setState(() {
        final listingProvider = context.read<ListingProvider>();
        listingProvider.fetchAvailableListings();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[500],
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notification',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
