import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewBookingsPage extends StatefulWidget {
  const ViewBookingsPage({Key? key}) : super(key: key);

  @override
  _ViewBookingsPageState createState() => _ViewBookingsPageState();
}

class _ViewBookingsPageState extends State<ViewBookingsPage> {
  String _selectedStatus = 'pending';
  final Set<String> _expandedBookings = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Bookings'),
        backgroundColor: Colors.grey[900], // matching admin theme
      ),
      backgroundColor: Colors.black87,
      body: Column(
        children: [
          const SizedBox(height: 12),
          _buildStatusToggleButtons(),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .where('status', isEqualTo: _selectedStatus)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading bookings', style: TextStyle(color: Colors.white)));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text('No bookings found.', style: TextStyle(color: Colors.white)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data()! as Map<String, dynamic>;

                    final username = data['username'] ?? 'N/A';
                    Timestamp createdAtTs = data['createdAt'] ?? Timestamp.now();
                    final createdAt = createdAtTs.toDate();
                    final formattedDate = "${createdAt.day.toString().padLeft(2, '0')}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.year}";

                    final carModel = data['carModel'] ?? 'N/A';
                    final carImageUrl = data['carImage'] as String?;
                    final notes = data['notes'] ?? 'None';
                    final price = data['price'] != null ? "\$${data['price'].toString()}" : 'N/A';
                    final vendorName = data['vendorName'] ?? 'N/A';
                    final bookingStatus = data['status'] ?? 'Unknown';

                    final isExpanded = _expandedBookings.contains(doc.id);

                    return Card(
                      color: Colors.grey[850],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(username.toString(),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 6),
                            Text('USERNAME: $username', style: const TextStyle(color: Colors.white70)),
                            Text('CREATED AT: $formattedDate', style: const TextStyle(color: Colors.white70)),
                            Text('CAR MODEL: $carModel', style: const TextStyle(color: Colors.white70)),
                            const SizedBox(height: 8),
                            if (isExpanded) ...[
                              if (carImageUrl != null && carImageUrl.isNotEmpty)
                                Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(carImageUrl, height: 140, fit: BoxFit.cover),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Text('NOTES: $notes', style: const TextStyle(color: Colors.white70)),
                              Text('PRICE: $price', style: const TextStyle(color: Colors.white70)),
                              Text('VENDOR NAME: $vendorName', style: const TextStyle(color: Colors.white70)),
                              Text('BOOKING STATUS: ${bookingStatus.toString().toUpperCase()}',
                                  style: const TextStyle(color: Colors.white70)),
                            ],
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (isExpanded) {
                                      _expandedBookings.remove(doc.id);
                                    } else {
                                      _expandedBookings.add(doc.id);
                                    }
                                  });
                                },
                                child: Text(
                                  isExpanded ? 'VIEW LESS' : 'VIEW MORE',
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

  Widget _buildStatusToggleButtons() {
    final statuses = ['pending', 'active', 'finished'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: statuses.map((status) {
        final bool isSelected = _selectedStatus == status;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: ChoiceChip(
            label: Text(
              status[0].toUpperCase() + status.substring(1),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            selectedColor: Colors.blueAccent,
            backgroundColor: Colors.grey[300],
            selected: isSelected,
            onSelected: (_) {
              setState(() {
                _selectedStatus = status;
                _expandedBookings.clear();
              });
            },
          ),
        );
      }).toList(),
    );
  }
}