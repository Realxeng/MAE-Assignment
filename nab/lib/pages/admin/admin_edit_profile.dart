import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nab/utils/image_provider.dart';
import 'package:nab/utils/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class EditAdminProfilePage extends StatefulWidget {
  final String uid; // <-- Add this parameter
  const EditAdminProfilePage({super.key, required this.uid});

  @override
  _EditAdminProfilePageState createState() => _EditAdminProfilePageState();
}

class _EditAdminProfilePageState extends State<EditAdminProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _townshipController = TextEditingController();

  File? _pickedImageFile;
  String? _profileImageBase64;
  String? _fullName;
  DateTime? _dob;

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Use widget.uid (from constructor) instead of currentUser.uid
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final uid = widget.uid; // Get uid passed to widget
      
      final docSnapshot =
          await FirebaseFirestore.instance.collection('Users').doc(uid).get();

      if (!docSnapshot.exists) {
        throw Exception('User data not found');
      }

      final data = docSnapshot.data()!;

      setState(() {
        _usernameController.text = data['username'] ?? '';
        _emailController.text = data['email'] ?? '';
        _townshipController.text = data['township'] ?? '';
        _profileImageBase64 = data['profilePicture'];
        _fullName = data['fullName'] ?? '';

        Timestamp? dobTimestamp = data['dob'] as Timestamp?;
        if (dobTimestamp != null) {
          _dob = dobTimestamp.toDate();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // When submitting changes, you may want to verify that the uid matches current logged-in user
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final updatedUsername = _usernameController.text.trim();
    final updatedEmail = _emailController.text.trim();
    final updatedTownship = _townshipController.text.trim();

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // If you want to restrict updates to the logged-in user only,
      // you could check here if widget.uid == userProvider.currentUser.uid

      await userProvider.updateUserProfile(
        email: updatedEmail,
        username: updatedUsername,
        township: updatedTownship,
        profilePictureFile: _pickedImageFile,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      await _loadUserData();
      _pickedImageFile = null;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _logout() async {
    setState(() => _isSaving = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.signOut();

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _townshipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dobFormatted = _dob != null
        ? "${_dob!.day.toString().padLeft(2, '0')}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.year}"
        : '';

    Widget profileImageWidget;
    if (_pickedImageFile != null) {
      profileImageWidget = CircleAvatar(
        radius: 60,
        backgroundImage: FileImage(_pickedImageFile!),
      );
    } else if (_profileImageBase64 != null && _profileImageBase64!.isNotEmpty) {
      final decodedBytes = ImageConstants.constants.decodeBase64(_profileImageBase64!);
      profileImageWidget = CircleAvatar(
        radius: 60,
        backgroundImage: MemoryImage(decodedBytes),
      );
    } else {
      profileImageWidget = const CircleAvatar(
        radius: 60,
        backgroundImage: AssetImage('assets/images/default_profile.png'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Admin Profile'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            profileImageWidget,
                            Positioned(
                              right: 4,
                              bottom: 4,
                              child: InkWell(
                                onTap: _pickImage,
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        _buildReadOnlyField('Full Name', _fullName ?? ''),
                        const SizedBox(height: 12),
                        _buildReadOnlyField('Date of Birth', dobFormatted),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _usernameController,
                          decoration: _inputDecoration('Username'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Username cannot be empty';
                            }
                            if (value.trim().length < 3) {
                              return 'Username must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          decoration: _inputDecoration('Email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email cannot be empty';
                            }
                            final emailRegEx = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                            if (!emailRegEx.hasMatch(value.trim())) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _townshipController,
                          decoration: _inputDecoration('Township'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Township cannot be empty';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _submit,
                            child: const Text('Save Changes'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isSaving ? null : _logout,
                            icon: const Icon(Icons.logout),
                            label: const Text('Logout'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.error,
                              side: BorderSide(color: Theme.of(context).colorScheme.error),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                if (_isSaving)
                  Container(
                    color: Colors.black.withOpacity(0.4),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      readOnly: true,
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    );
  }
}