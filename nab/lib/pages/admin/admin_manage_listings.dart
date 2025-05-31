import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nab/utils/image_provider.dart';
import 'package:nab/utils/listing_provider.dart';
import 'package:provider/provider.dart';

class ManageListingsPage extends StatefulWidget {
  const ManageListingsPage({super.key});

  @override
  _ManageListingsPageState createState() => _ManageListingsPageState();
}

class _ManageListingsPageState extends State<ManageListingsPage> {
  final Set<String> _expandedDocIds = {};
  final ImageConstants imageProvider = ImageConstants.constants;

  String _selectedStatus = 'pending';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchListings();
    });
  }

  void _fetchListings() {
    final provider = Provider.of<ListingProvider>(context, listen: false);
    switch (_selectedStatus) {
      case 'pending':
        provider.fetchPendingListings();
        break;
      case 'accepted':
        provider.fetchAcceptedListings();
        break;
      case 'rejected':
        provider.fetchRejectedListings();
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchListings();
  }

  void toggleExpand(String docId) {
    setState(() {
      if (_expandedDocIds.contains(docId)) {
        _expandedDocIds.remove(docId);
      } else {
        _expandedDocIds.add(docId);
      }
    });
  }

  Future<void> updateStatus(String docId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('listing').doc(docId).update({
        'status': newStatus,
        'statusUpdatedAt': Timestamp.now(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Listing $newStatus successfully'),
        backgroundColor: Colors.green,
      ));
      _fetchListings(); // Refresh listings on update
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update status: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Widget buildImageSection(String? base64String, String label) {
    if (base64String == null || base64String.isEmpty) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white, fontFamily: 'poppins')),
            const SizedBox(height: 8),
            Center(
                child: Text('No $label available',
                    style: const TextStyle(color: Colors.white, fontFamily: 'poppins'))),
            const SizedBox(height: 16),
          ]);
    }

    Uint8List imageBytes;
    try {
      imageBytes = imageProvider.decodeBase64(base64String);
    } catch (e) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white, fontFamily: 'poppins')),
            const SizedBox(height: 8),
            Center(
                child: Text('Invalid $label data',
                    style: const TextStyle(color: Colors.white, fontFamily: 'poppins'))),
            const SizedBox(height: 16),
          ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontFamily: 'poppins')),
        const SizedBox(height: 8),
        Image.memory(
          imageBytes,
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStatusFilter() {
    final statuses = ['pending', 'accepted', 'rejected'];
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: statuses.map((status) {
          final isSelected = _selectedStatus == status;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ChoiceChip(
              label: Text(
                status[0].toUpperCase() + status.substring(1),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'poppins',
                ),
              ),
              selectedColor: Colors.blueAccent,
              backgroundColor: Colors.grey[300],
              selected: isSelected,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              onSelected: (_) {
                if (_selectedStatus != status) {
                  setState(() {
                    _selectedStatus = status;
                    _expandedDocIds.clear();
                  });
                  _fetchListings();
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Listings'),
      ),
      backgroundColor: Colors.grey[850],
      body: Column(
        children: [
          _buildStatusFilter(),
          Expanded(
            child: Consumer<ListingProvider>(
              builder: (context, listingProvider, child) {
                final docs = listingProvider.listings;

                if (docs.isEmpty) {
                  return const Center(
                      child: Text(
                    'No listings found.',
                    style: TextStyle(color: Colors.white70, fontFamily: 'poppins'),
                  ));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index];
                    final user = data.user;

                    final username = user?.username ?? 'N/A';
                    final carModel = data.carModel ?? 'N/A';
                    final carPlate = data.carPlate ?? 'N/A';
                    final status = (data.status ?? 'pending').toLowerCase();
                    final vehicleCondition = data.vehicleCondition ?? 'Unknown';
                    final attachmentUrl = data.attachments;
                    final vehicleImageUrl = data.image;
                    final contactNumber = data.contactNumber ?? 'N/A';
                    final isExpanded = _expandedDocIds.contains(data.id);
                    final isPending = status == 'pending';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: Colors.grey[900],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Listing ${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Username: $username',
                                style: const TextStyle(
                                    color: Colors.white, fontFamily: 'poppins')),
                            Text('Car Model: $carModel',
                                style: const TextStyle(
                                    color: Colors.white, fontFamily: 'poppins')),
                            Text('Car Plate: $carPlate',
                                style: const TextStyle(
                                    color: Colors.white, fontFamily: 'poppins')),
                            if (isExpanded) ...[
                              const SizedBox(height: 12),
                              const Divider(),
                              const SizedBox(height: 8),
                              Text('Status: ${status[0].toUpperCase() + status.substring(1)}',
                                  style: const TextStyle(
                                      color: Colors.white, fontFamily: 'poppins')),
                              Text('Vehicle Condition: $vehicleCondition',
                                  style: const TextStyle(
                                      color: Colors.white, fontFamily: 'poppins')),
                              Text('Contact Number: $contactNumber',
                                  style: const TextStyle(
                                      color: Colors.white, fontFamily: 'poppins')),
                              const SizedBox(height: 8),
                              buildImageSection(attachmentUrl, 'Vehicle Certificate'),
                              buildImageSection(vehicleImageUrl, 'Vehicle Image'),
                              const SizedBox(height: 8),
                              // Approve/Reject buttons enabled only if pending
                              if (isPending)
  Row(
    children: [
      Expanded(
        child: ElevatedButton(
          onPressed: () => updateStatus(data.id!, 'accepted'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          child: const Text('Approve',
              style: TextStyle(color: Colors.white, fontFamily: 'poppins')),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: ElevatedButton(
          onPressed: () => updateStatus(data.id!, 'rejected'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Reject',
              style: TextStyle(color: Colors.white, fontFamily: 'poppins')),
        ),
      ),
    ],
  ),
                            ],
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 8),
                                ),
                                onPressed: () => toggleExpand(data.id!),
                                child: Text(
                                  isExpanded ? 'COLLAPSE' : 'EXPAND',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}