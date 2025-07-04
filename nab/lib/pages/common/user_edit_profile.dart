import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nab/utils/auth_wrapper.dart';
import 'package:nab/utils/image_provider.dart';
import 'package:nab/utils/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final String uid;
  const EditProfilePage({super.key, required this.uid});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _townshipController = TextEditingController();

  File? _pickedImageFile;
  String? _profileImageBase64;
  String? _email;
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
          _fullNameController.text = user.fullName ?? '';
          _townshipController.text = user.township ?? '';
          _profileImageBase64 = user.profileImage;
          _email = user.email ?? '';
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
        fullName: _fullNameController.text.trim(),
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
      final userProvider = AuthWrapper();
      await userProvider.signOut(context);

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
    _fullNameController.dispose();
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
      backgroundColor: Colors.grey[900], // a bit darker than before
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color.fromARGB(
          255,
          140,
          200,
          255,
        ), // your accent blue
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            Colors
                                .grey[850], // slightly lighter than scaffold bg
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                                        color: Colors.blueAccent.withOpacity(
                                          0.8,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.white70,
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
                                'Email: ${_email ?? ''}',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.white70),
                              ),
                            ),
                            const SizedBox(height: 8),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Date of Birth: $dobFormatted',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.white70),
                              ),
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _usernameController,
                              style: const TextStyle(color: Colors.white),
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
                              controller: _fullNameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration('Full Name'),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email cannot be empty';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            TextFormField(
                              controller: _townshipController,
                              style: const TextStyle(color: Colors.white),
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    140,
                                    200,
                                    255,
                                  ),
                                ),
                                child: const Text('Save Changes'),
                              ),
                            ),
                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _isSaving ? null : _logout,
                                icon: const Icon(
                                  Icons.logout,
                                  color: Colors.redAccent,
                                ),
                                label: const Text(
                                  'Logout',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Inside your Column children, below the Logout button:
                            const SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed:
                                    _isSaving ? null : _confirmDeleteAccount,
                                icon: const Icon(
                                  Icons.delete_forever,
                                  color: Colors.redAccent,
                                ),
                                label: const Text(
                                  'Delete Account',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_isSaving)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(child: CircularProgressIndicator()),
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
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.grey[800],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white30),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.white30),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.lightBlue.shade300, width: 2),
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final reauthenticated = await _showReauthenticateDialog(
      context,
      user.email ?? '',
    );

    if (!reauthenticated) return;

    setState(() => _isSaving = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.deleteUserAccount();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully')),
      );

      // Navigate after deletion
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete account: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool> _showReauthenticateDialog(
    BuildContext context,
    String? currentEmail,
  ) async {
    final _emailController = TextEditingController(text: currentEmail);
    final _passwordController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Re-authenticate'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  readOnly: true, // Usually you don't allow changing email here
                ),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          ),
    );

    if (result != true) return false;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: _passwordController.text.trim(),
    );

    try {
      await user.reauthenticateWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Re-authentication failed: ${e.message}')),
      );
      return false;
    }
  }
}
