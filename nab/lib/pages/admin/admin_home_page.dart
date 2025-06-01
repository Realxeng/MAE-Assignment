import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nab/utils/image_provider.dart';
import 'package:nab/utils/user_provider.dart';
import 'package:provider/provider.dart';

class AdminHomePage extends StatefulWidget {
  final String uid;
  final void Function(int)? onTabChange;
  const AdminHomePage({super.key, required this.uid, this.onTabChange});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> with AutomaticKeepAliveClientMixin<AdminHomePage> {
  int activeBookings = 0;
  int vehiclesToVerify = 0;
  int numOfUsers = 0;
  String? userName;

  late StreamSubscription<QuerySnapshot> _bookingsSubscription;
  late StreamSubscription<QuerySnapshot> _vehiclesSubscription;
  late StreamSubscription<QuerySnapshot> _usersSubscription;

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

    _usersSubscription = FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        numOfUsers = snapshot.docs.length;
      });
    });
  }

  @override
  void dispose() {
    _bookingsSubscription.cancel();
    _vehiclesSubscription.cancel();
    _usersSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userProvider = context.watch<UserProvider>();
    userName = userProvider.user?.username ?? "User";
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: CircleAvatar(
            radius: 24,
            backgroundImage: _getProfileImage(),
          ),
          onPressed: () {
            widget.onTabChange?.call(3); // Navigate to Edit Profile
          },
        ),
        title: Text('Welcome $userName'),
      ),
      backgroundColor: Colors.grey[850],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatCard('Total Users', numOfUsers.toString()),
            _buildStatCard('Active Bookings', activeBookings.toString()),
            _buildStatCard('Vehicles To Verify', vehiclesToVerify.toString()),
          ],
        ),
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
}