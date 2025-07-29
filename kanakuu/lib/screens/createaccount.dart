import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';
import '../services/biometric_service.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({Key? key}) : super(key: key);

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _userService = UserService();
  final _biometricService = BiometricService();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _biometricEnabled = false;
  bool _termsAccepted = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please accept the Terms of Service and Privacy Policy')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String userId = const Uuid().v4();

      await _userService.createUserProfile(
        userId: userId,
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        biometricEnabled: _biometricEnabled,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);

      if (_biometricEnabled) {
        final isAvailable = await _biometricService.isBiometricAvailable();
        if (isAvailable) {
          await _biometricService.enableBiometric(_emailController.text.trim());
        }
      }

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      print("Unexpected error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
    @override
    Widget build(BuildContext context) {
        return Scaffold(
        backgroundColor: const Color(0xFF1A1D29),
        body: SafeArea(
            child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
                key: _formKey,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    const SizedBox(height: 40),
                    
                    // Logo
                 Center(
                      child: Container(
    width: 90, // slightly bigger for glow space
    height: 90,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Color(0xFFFF6B35).withOpacity(0.5), // Orange glow
          blurRadius: 15,
          spreadRadius: 2,
        ),
      ],
    ),
                    
  child: ClipOval(
    child: Image.asset(
      'assets/Ahorra_logo.png',
      width: 80,
      height: 80,
      fit: BoxFit.cover, // Fill the circle properly
    ),
  ),
),
                 ),
const SizedBox(height: 32),



                    
                    // Title
                    const Text(
                    'Create account',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Subtitle
                    const Text(
                    'Start your smart savings journey',
                    style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Full Name Field
                    const Text(
                    'Full Name',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                    ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                    controller: _fullNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        hintText: 'Enter your full name',
                        hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                        prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6B7280)),
                        filled: true,
                        fillColor: const Color(0xFF2A2D3A),
                        border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF374151)),
                        ),
                        enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF374151)),
                        ),
                        focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFFF6B35)),
                        ),
                    ),
                    validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                        return 'Please enter your full name';
                        }
                        return null;
                    },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Email Field
                    const Text(
                    'Email',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                    ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6B7280)),
                        filled: true,
                        fillColor: const Color(0xFF2A2D3A),
                        border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF374151)),
                        ),
                        enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF374151)),
                        ),
                        focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFFF6B35)),
                        ),
                    ),
                    validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                        }
                        return null;
                    },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Password Field
                    const Text(
                    'Password',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                    ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        hintText: 'Create a password',
                        hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6B7280)),
                        suffixIcon: IconButton(
                        icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: const Color(0xFF6B7280),
                        ),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2A2D3A),
                        border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF374151)),
                        ),
                        enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF374151)),
                        ),
                        focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFFF6B35)),
                        ),
                    ),
                    validator: (value) {
                        if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                        }
                        if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                        }
                        return null;
                    },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Confirm Password Field
                    const Text(
                    'Confirm Password',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                    ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        hintText: 'Confirm your password',
                        hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6B7280)),
                        suffixIcon: IconButton(
                        icon: Icon(
                            _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: const Color(0xFF6B7280),
                        ),
                        onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF2A2D3A),
                        border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF374151)),
                        ),
                        enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF374151)),
                        ),
                        focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFFF6B35)),
                        ),
                    ),
                    validator: (value) {
                        if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                        return 'Passwords do not match';
                        }
                        return null;
                    },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Biometric Authentication Option
                    Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: const Color(0xFF2A2D3A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF374151)),
                    ),
                    child: Row(
                        children: [
                        Checkbox(
                            value: _biometricEnabled,
                            onChanged: (value) => setState(() => _biometricEnabled = value ?? false),
                            activeColor: const Color(0xFFFF6B35),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                            Icons.fingerprint,
                            color: Color(0xFFFF6B35),
                            size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                                Text(
                                'Enable biometric authentication',
                                style: TextStyle(
                                    color: Color(0xFFFF6B35),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                ),
                                ),
                                Text(
                                'Use your fingerprint or face to sign in securely and quickly.',
                                style: TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 12,
                                ),
                                ),
                            ],
                            ),
                        ),
                        ],
                    ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Terms and Privacy
                    Row(
                    children: [
                        Checkbox(
                        value: _termsAccepted,
                        onChanged: (value) => setState(() => _termsAccepted = value ?? false),
                        activeColor: const Color(0xFFFF6B35),
                        ),
                        Expanded(
                        child: RichText(
                            text: const TextSpan(
                            style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 12,
                            ),
                            children: [
                                TextSpan(text: 'I agree to the '),
                                TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(color: Color(0xFFFF6B35)),
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(color: Color(0xFFFF6B35)),
                                ),
                            ],
                            ),
                        ),
                        ),
                    ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Create Account Button
                    ElevatedButton(
                    onPressed: _isLoading ? null : _createAccount,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                            )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                                Text(
                                'Create account',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18),
                            ],
                            ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Sign In Link
                    Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        const Text(
                        'Already have an account? ',
                        style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 14,
                        ),
                        ),
                        GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(context, '/signin'),
                        child: const Text(
                            'Sign in',
                            style: TextStyle(
                            color: Color(0xFFFF6B35),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            ),
                        ),
                        ),
                    ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Copyright
                    const Text(
                    '© 2024 Ahorra. All rights reserved.',
                    style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    ),
                ],
                ),
            ),
            ),
        ),
        );
    }
    }