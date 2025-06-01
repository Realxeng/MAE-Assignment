import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nab/utils/image_provider.dart';
import 'package:nab/utils/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class EditAdminProfilePage extends StatefulWidget {
  final String uid;
  const EditAdminProfilePage({super.key, required this.uid});

  @override
  State<EditAdminProfilePage> createState() => _EditAdminProfilePageState();
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

  bool _isLoading = true; // start as loading
  bool _isSaving = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final userProvider = context.read<UserProvider>();
      await userProvider.fetchUserData(widget.uid);
      final user = userProvider.user;

      if (user == null) {
        // user data not loaded, optionally retry after some delay
        Future.delayed(Duration(seconds: 1), _fetchUserData);
      } else {
        setState(() {
          _isLoading = false;
          // update controllers and fields here...
          _usernameController.text = user.username ?? '';
          _emailController.text = user.email ?? '';
          _townshipController.text = user.township ?? '';
          _profileImageBase64 = user.profileImage;
          _fullName = user.fullName ?? '';
          _dob = user.dob != null ? DateTime.tryParse(user.dob!) : null;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      // You can add a SnackBar or error UI here.
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _isLoading = true; // set loading to true when dependencies change
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;
    if (widget.uid != currentUserUid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You can only update your own profile.'),
          ),
        );
      }
      setState(() => _isSaving = false);
      return;
    }

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      await userProvider.updateUserProfile(
        fullName: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        township: _townshipController.text.trim(),
        profilePictureFile: _pickedImageFile,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      _fetchUserData();

      _pickedImageFile = null;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Failed to load user data.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchUserData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    final dobFormatted =
        _dob != null
            ? "${_dob!.day.toString().padLeft(2, '0')}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.year}"
            : '';

    Widget profileImageWidget;
    if (_pickedImageFile != null) {
      profileImageWidget = CircleAvatar(
        radius: 60,
        backgroundImage: FileImage(_pickedImageFile!),
      );
    } else if (_profileImageBase64 != null && _profileImageBase64!.isNotEmpty) {
      final decodedBytes = ImageConstants.constants.decodeBase64(
        _profileImageBase64!,
      );
      profileImageWidget = CircleAvatar(
        radius: 60,
        backgroundImage: MemoryImage(decodedBytes),
      );
    } else {
      profileImageWidget = const CircleAvatar(
        radius: 60,
        backgroundImage: AssetImage('assets/Nab_Emblem.png'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Admin Profile'),
        centerTitle: true,
      ),
      body:
          _isLoading
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
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

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Full Name: ${_fullName ?? ''}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(height: 8),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Date of Birth: $dobFormatted',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(height: 16),

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
                                foregroundColor:
                                    Theme.of(context).colorScheme.error,
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.error,
                                ),
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
                      color: const Color.fromRGBO(0, 0, 0, 0.4),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    );
  }
}
