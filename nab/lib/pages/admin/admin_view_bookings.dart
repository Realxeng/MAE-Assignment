import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nab/utils/booking_provider.dart';
import 'package:nab/utils/image_provider.dart';
import 'package:provider/provider.dart';

class ViewBookingsPage extends StatefulWidget {
  const ViewBookingsPage({super.key});

  @override
  _ViewBookingsPageState createState() => _ViewBookingsPageState();
}

class _ViewBookingsPageState extends State<ViewBookingsPage> with AutomaticKeepAliveClientMixin<ViewBookingsPage> {
  String _selectedStatus = 'pending';
  final Set<String> _expandedBookings = {};

  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context); // Ensure the mixin's build method is called
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Booking'), // Changed to singular to match image
        backgroundColor: Colors.grey[300], // Light background for header
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F5F5),  // soft off-white background
      body: Column(
        children: [
          const SizedBox(height: 12),
          _buildStatusToggleButtons(),
          const SizedBox(height: 12),
          Expanded(
            child: Consumer<BookingProvider>(
        builder: (context, BookingProvider, child) {
          final docs = BookingProvider.bookings;
                if (docs.isEmpty) {
                  return const Center(
                      child: Text('No bookings found.',
                          style: TextStyle(color: Colors.black54)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index];
                    final car = data.car;
                    final vendor = data.vendor;
                    final cus = data.customer;

                    final cusname = cus?.fullName ?? 'N/A';
                    DateTime createdAt = data.createdAt ?? DateTime.now();
                    final formattedDate =
                        "${createdAt.day.toString().padLeft(2, '0')}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.year}";
                    final carModel = car?.carModel ?? 'N/A';
                    final carImageUrl = car?.image ?? '';
                    final notes = data.notes?? 'None';
                    final price =
                        data.price != null ? "\$${data.price.toString()}" : 'N/A';
                    final vendorName = vendor?.fullName ?? 'N/A';
                    final bookingStatus = data.status ?? 'Unknown';

                    final isExpanded = _expandedBookings.contains(data.id);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color.fromRGBO(68, 138, 255, 0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromRGBO(0, 0, 0, 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Person ${index + 1}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                          ),
                          const SizedBox(height: 10),
                          _buildLabelValue('USERNAME', cusname),
                          _buildLabelValue('CREATED AT', formattedDate),
                          _buildLabelValue('CAR MODEL', carModel),
                          if (isExpanded) ...[
                            const SizedBox(height: 12),
                            if (carImageUrl != null && carImageUrl.isNotEmpty)
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image(image: MemoryImage(ImageConstants.constants.decodeBase64(carImageUrl))),
                                ),
                              ),
                            const SizedBox(height: 12),
                            _buildLabelValue('NOTES', notes),
                            _buildLabelValue('PRICE', price),
                            _buildLabelValue('VENDOR NAME', vendorName),
                            _buildLabelValue('BOOKING STATUS', bookingStatus.toString().toUpperCase()),
                          ],
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isExpanded) {
                                    _expandedBookings.remove(data.id);
                                  } else {
                                    _expandedBookings.add(data.id!);
                                  }
                                });
                              },
                              child: Text(
                                isExpanded ? 'COLLAPSE' : 'VIEW MORE',
                                style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildLabelValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontFamily: 'Comic Sans MS'),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
            ),
          ],
        ),
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
                fontWeight: FontWeight.w600,
                fontFamily: 'Comic Sans MS',
              ),
            ),
            selectedColor: Colors.blueAccent,
            backgroundColor: Colors.grey[300],
            selected: isSelected,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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