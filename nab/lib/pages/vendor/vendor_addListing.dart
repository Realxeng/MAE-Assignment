import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nab/utils/listing_provider.dart';
import 'package:nab/utils/image_provider.dart';
import 'package:flutter/services.dart';

class VendorAddListingPage extends StatefulWidget {
  final String uid;
  const VendorAddListingPage({Key? key, required this.uid}) : super(key: key);

  @override
  State<VendorAddListingPage> createState() => _VendorAddListingPageState();
}

class _VendorAddListingPageState extends State<VendorAddListingPage> {
  final _formKey = GlobalKey<FormState>();

  int? _price;
  String? _carModel;
  String? _carPlate;
  String? _carType;
  int? _contactNumber;
  String _vehicleCondition = 'good';

  Uint8List? _attachmentBytes;
  Uint8List? _carImageBytes;

  bool _isSaving = false;

  final List<String> carTypes = [
    'Sedan',
    'SUV',
    'Hatchback',
    'Van',
    'Coupe',
    'Other',
  ];
  final List<String> conditionTypes = ['poor', 'good', 'very good'];

  Future<void> _pickAttachment() async {
    try {
      Uint8List? picked = await ImageConstants.constants.pickImage();
      if (picked != null) {
        setState(() {
          _attachmentBytes = picked;
        });
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to pick attachment image: $e');
    }
  }

  Future<void> _pickCarImage() async {
    try {
      Uint8List? picked = await ImageConstants.constants.pickImage();
      if (picked != null) {
        setState(() {
          _carImageBytes = picked;
        });
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to pick car image: $e');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSaving = true);

    try {
      String? attachmentBase64 =
          _attachmentBytes != null
              ? ImageConstants.constants.convertToBase64(_attachmentBytes!)
              : null;
      String? imageBase64 =
          _carImageBytes != null
              ? ImageConstants.constants.convertToBase64(_carImageBytes!)
              : null;

      await context.read<ListingProvider>().addListing(
        vendorId: widget.uid,
        price: _price!,
        carModel: _carModel!,
        carPlate: _carPlate!,
        carType: _carType!,
        contactNumber: _contactNumber!,
        imageBase64: imageBase64,
        attachmentBase64: attachmentBase64,
        vehicleCondition: _vehicleCondition,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing added successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add listing: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildImagePicker({
    required String label,
    Uint8List? imageBytes,
    required VoidCallback onPickImage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onPickImage,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child:
                imageBytes != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(imageBytes, fit: BoxFit.cover),
                    )
                    : Center(
                      child: Icon(
                        Icons.add_a_photo,
                        size: 48,
                        color: Colors.grey[700],
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Listing')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildImagePicker(
                label: 'Attachment (optional)',
                imageBytes: _attachmentBytes,
                onPickImage: _pickAttachment,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Car Model'),
                validator:
                    (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                onSaved: (v) => _carModel = v!.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Car Plate'),
                validator:
                    (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                onSaved: (v) => _carPlate = v!.trim(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Car Type'),
                items:
                    carTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                onChanged: (v) {
                  setState(() => _carType = v);
                },
                onSaved: (v) => _carType = v,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.phone,
                validator:
                    (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                onSaved: (v) => _contactNumber = int.parse(v!.trim()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Price (RM) per day',
                ),
                keyboardType: TextInputType.phone,
                validator:
                    (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                onSaved: (v) => _price = int.parse(v!.trim()),
              ),
              const SizedBox(height: 16),
              _buildImagePicker(
                label: 'Car Image (optional)',
                imageBytes: _carImageBytes,
                onPickImage: _pickCarImage,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Vehicle Condition',
                ),
                value: _vehicleCondition,
                items:
                    conditionTypes
                        .map(
                          (cond) => DropdownMenuItem(
                            value: cond,
                            child: Text(cond.toUpperCase()),
                          ),
                        )
                        .toList(),
                onChanged: (v) {
                  setState(() => _vehicleCondition = v!);
                },
                onSaved: (v) => _vehicleCondition = v!,
              ),
              const SizedBox(height: 24),
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Add Listing'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
