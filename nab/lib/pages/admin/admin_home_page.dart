import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nab/utils/user_provider.dart';
import 'package:nab/pages/admin/admin_verify_listings.dart';
import 'package:nab/pages/admin/admin_view_bookings.dart';
import 'package:provider/provider.dart';

class AdminHomePage extends StatefulWidget {
  final String uid;
  const AdminHomePage({super.key, required this.uid});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;
  int activeBookings = 0;
  int vehiclesToVerify = 0;
  String? userName;

  late StreamSubscription<QuerySnapshot> _bookingsSubscription;
  late StreamSubscription<QuerySnapshot> _vehiclesSubscription;

  Future<void> _loadUserName() async {
    final userProvider = context.read<UserProvider>();
    userProvider.onSignedOut = () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have been signed out.")),
      );
      Navigator.pushReplacementNamed(context, '/login');
    };
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();

    // Listen to bookings with status 'active' in realtime
    _bookingsSubscription = FirebaseFirestore.instance
        .collection('bookings')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        activeBookings = snapshot.docs.length;
      });
    });

    // Listen to listings with status 'pending' in realtime
    _vehiclesSubscription = FirebaseFirestore.instance
        .collection('listing')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        vehiclesToVerify = snapshot.docs.length;
      });
    });
  }

  @override
  void dispose() {
    _bookingsSubscription.cancel();
    _vehiclesSubscription.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });

  switch (index) {
    case 0:
      //stay in homepage
      break;

    case 1:
      // Navigate to Manage Users page
      break;

    case 2:
      // Navigate to View Bookings page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ViewBookingsPage()),
      );
      break;

    case 3:
      // Navigate to View Feedbacks page
      break;
  }
}

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    userName = userProvider.user?.username ?? "User";
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.account_circle,
            size: 48,
          ), 
          onPressed: () {
            // Profile navigation if needed
          },
        ),
        title: Text('Welcome $userName'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatCard('Active Bookings', activeBookings.toString()),
            _buildActionCard(
              'Vehicle To Verify',
              vehiclesToVerify.toString(),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VerifyListingsPage(),
                  ),
                );
              },
            ),
          ],
        ),
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
              child: Icon(Icons.feedback),
            ),
            label: 'View Feedbacks',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String count) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Card(
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.symmetric(vertical: 12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 12),
              Text(label, style: TextStyle(fontSize: 20, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(String label, String count, VoidCallback onPressed) {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Card(
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.symmetric(vertical: 12),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      count,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      label,
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'View',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}