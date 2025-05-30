import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nab/utils/user_provider.dart';
import 'package:nab/pages/admin/admin_verify_listing.dart';

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

  Future<void> _loadUserName() async {
    UserProvider userProvider = UserProvider();
    String fetchedName = await userProvider.fetchUserName(widget.uid);
    setState(() {
      userName = fetchedName;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    final bookings = await FirebaseFirestore.instance
        .collection('bookings')
        .where('status', isEqualTo: 'active')
        .get();

    final vehicles = await FirebaseFirestore.instance
        .collection('listing')
        .where('status', isEqualTo: 'pending')
        .get();

    setState(() {
      activeBookings = bookings.docs.length;
      vehiclesToVerify = vehicles.docs.length;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Add page navigation logic here
    });
  }

  @override
  Widget build(BuildContext context) {
    _loadUserName();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
        icon: Icon(Icons.account_circle, size: 48), // You can use any icon or even an Image widget
        onPressed: () {
      // Add your profile page navigation here
        },
      ),
      title: Text('Welcome ${userName ?? 'Admin'}'),
  ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatCard('Active Bookings', activeBookings.toString()),
            _buildActionCard('Vehicle To Verify', vehiclesToVerify.toString(), () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VerifyListingsPage()),
              );
            }),
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
        showUnselectedLabels: true,   //Show labels for unselected items
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
    width: double.infinity,  // <-- Make card fill width of parent
    child: Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 12),  // Keep vertical margin only here
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
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildActionCard(String label, String count, VoidCallback onPressed) {
  return SizedBox(
    height: 200,
    width: double.infinity,  // Make full width
    child: Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 12), // Just vertical margin here
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
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 12),
                  Text(
                    label,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  Spacer(), // Push button down
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('View', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}