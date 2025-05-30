import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nab/utils/image_provider.dart';

class VerifyListingsPage extends StatefulWidget {
  const VerifyListingsPage({super.key});

  @override
  _VerifyListingsPageState createState() => _VerifyListingsPageState();
}

class _VerifyListingsPageState extends State<VerifyListingsPage> {
  final Set<String> _expandedDocIds = {};
  final ImageConstants image_provider = ImageConstants.constants;

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
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Listing $newStatus successfully'),
        backgroundColor: Colors.green,
      ));
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
            Text(label, style: const TextStyle(color: Colors.white, fontFamily: 'comic sans')),
            const SizedBox(height: 8),
            Center(child: Text('No $label available', style: const TextStyle(color: Colors.white, fontFamily: 'comic sans'))),
            const SizedBox(height: 16),
          ],
      );
    }

    Uint8List imageBytes;
    try {
      imageBytes = image_provider.decodeBase64(base64String);
    } catch (e) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontFamily: 'comic sans')),
            const SizedBox(height: 8),
            Center(child: Text('Invalid $label data', style: const TextStyle(color: Colors.white, fontFamily: 'comic sans'))),
            const SizedBox(height: 16),
          ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontFamily: 'comic sans')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Listings'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('listing')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading listings'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No listings found.'));
          }

          return ListView.builder( 
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              var data = doc.data()! as Map<String, dynamic>;

              final username = data['username'] ?? 'N/A';
              final carModel = data['carModel'] ?? 'N/A';
              final carPlate = data['carPlate'] ?? 'N/A';
              final status = data['status'] ?? 'Pending';
              final vehicleCondition = data['vehicleCondition'] ?? 'Unknown';
              final attachmentUrl = data['attachments'] as String?;
              final vehicleImageUrl = data['image'] as String?;
              final contactNumber = data['contactNumber'] ?? 'N/A';
              final isExpanded = _expandedDocIds.contains(doc.id);

              bool isActionDone = status == 'accepted' || status == 'rejected';

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
                      Text('Username: $username', style: const TextStyle(color: Colors.white, fontFamily: 'comic sans')),
                      Text('Car Model: $carModel', style: const TextStyle(color: Colors.white, fontFamily: 'comic sans')),
                      Text('Car Plate: $carPlate', style: const TextStyle(color: Colors.white, fontFamily: 'comic sans')),
                      if (isExpanded) ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text('Status: $status', style: const TextStyle(color: Colors.white, fontFamily: 'comic sans')),
                        Text('Vehicle Condition: $vehicleCondition', style: const TextStyle(color: Colors.white, fontFamily: 'comic sans')),
                        Text('Contact Number: $contactNumber', style: const TextStyle(color: Colors.white, fontFamily: 'comic sans')),
                        const SizedBox(height: 8),
                        buildImageSection(attachmentUrl, 'Attachment'),
                        buildImageSection(vehicleImageUrl, 'Vehicle Image'),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isActionDone
                                    ? null
                                    : () => updateStatus(doc.id, 'Accepted'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: const Text('Approve', style: TextStyle(color: Colors.white, fontFamily: 'comic sans')),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isActionDone
                                    ? null
                                    : () => updateStatus(doc.id, 'Rejected'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Reject', style: TextStyle(color: Colors.white, fontFamily: 'comic sans')),
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
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          ),
                          onPressed: () => toggleExpand(doc.id),
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
    );
  }
}