import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/profile_service.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  File? _selectedImage;
  String? _currentImagePath; // Store local image path from Firestore
  bool _isLoading = false;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _profileService.getUserProfile();
      if (profile != null) {
        setState(() {
          _nameController.text = profile['name'] ?? '';
          _emailController.text = profile['email'] ?? '';
          _phoneController.text = profile['phone'] ?? '';
          _currentImagePath = profile['profileImagePath']; // Get local image path
          _isLoadingData = false;
        });
        print('Profile loaded: ${profile['name']}, Image Path: ${profile['profileImagePath']}');
      } else {
        setState(() {
          _isLoadingData = false;
        });
        print('No profile found');
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        print('Image selected: ${image.path}');
      }
    } catch (e) {
      print('Error picking image: $e');
      _showErrorSnackBar('Failed to pick image. Please try again.');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        print('Photo taken: ${image.path}');
      }
    } catch (e) {
      print('Error taking photo: $e');
      _showErrorSnackBar('Failed to take photo. Please try again.');
    }
  }

  Future<void> _removeImage() async {
    try {
      setState(() {
        _selectedImage = null;
        _currentImagePath = null;
      });
      
      // Delete from Firestore
      final success = await _profileService.deleteProfileImage();
      if (success) {
        _showSuccessSnackBar('Profile image removed successfully!');
      } else {
        _showErrorSnackBar('Failed to remove profile image.');
      }
    } catch (e) {
      print('Error removing image: $e');
      _showErrorSnackBar('Failed to remove image. Please try again.');
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16213E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Profile Photo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
                _buildImageOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
                if (_selectedImage != null || _currentImagePath != null)
                  _buildImageOption(
                    icon: Icons.delete,
                    label: 'Remove',
                    onTap: () {
                      Navigator.pop(context);
                      _removeImage();
                    },
                    color: Colors.red,
                  ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: (color ?? const Color(0xFFFF6B35)).withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              icon,
              color: color ?? const Color(0xFFFF6B35),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print('Saving profile...');
      print('Name: ${_nameController.text.trim()}');
      print('Email: ${_emailController.text.trim()}');
      print('Phone: ${_phoneController.text.trim()}');
      print('Has selected image: ${_selectedImage != null}');

      final success = await _profileService.updateUserProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        profileImage: _selectedImage,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        // Update the current image path to the selected image path
        if (_selectedImage != null) {
          setState(() {
            _currentImagePath = _selectedImage!.path;
            _selectedImage = null; // Clear selected image since it's now saved
          });
        }
        
        _showSuccessSnackBar('Profile updated successfully!');
        Navigator.pop(context);
      } else {
        // Check if user is logged in
        print('Profile update failed - checking authentication status...');
        final isAuthenticated = await _profileService.isUserAuthenticatedAsync();
        if (!isAuthenticated) {
          _showErrorSnackBar('Please log in to update your profile.');
        } else {
          _showErrorSnackBar('Failed to update profile. Please check your internet connection and try again.');
        }
      }
    } catch (e) {
      print('Error saving profile: $e');
      setState(() {
        _isLoading = false;
      });
      
      // Show more specific error messages based on the error type
      String errorMessage = 'An error occurred. Please try again.';
      if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied. Please log in again.';
      }
      
      _showErrorSnackBar(errorMessage);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF6B35),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _showImageOptions,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFFF6B35),
            width: 3,
          ),
        ),
        child: ClipOval(
          child: _selectedImage != null
              ? Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                )
              : _currentImagePath != null && File(_currentImagePath!).existsSync()
                  ? Image.file(
                      File(_currentImagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading local image: $error');
                        return Container(
                          color: const Color(0xFF16213E),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white54,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: const Color(0xFF16213E),
                      child: const Icon(
                        Icons.add_a_photo,
                        size: 40,
                        color: Colors.white54,
                      ),
                    ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1A2E),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Profile',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF6B35),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFFF6B35),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xFFFF6B35),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image Section
              Center(child: _buildProfileImage()),
              const SizedBox(height: 8),
              Text(
                'Tap to change photo',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 40),
              // Form Fields
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _emailController,
                label: 'Email Address',
                icon: Icons.email,
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              
              // Sign Out Button
              _buildSignOutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: const Color(0xFFFF6B35)),
        filled: true,
        fillColor: const Color(0xFF16213E),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B35), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: validator,
    );
  }
  
  Widget _buildSignOutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: OutlinedButton(
        onPressed: () async {
          try {
            await _profileService.signOut();
            Navigator.of(context).pushReplacementNamed('/signin');
          } catch (e) {
            print('Error signing out: $e');
            _showErrorSnackBar('Failed to sign out. Please try again.');
          }
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        ),
        child: const Text(
          'Sign Out',
          style: TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}