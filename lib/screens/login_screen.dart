import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:ladakh_app/main.dart'; // LanguageProvider
import 'package:ladakh_app/utils/translations.dart';
import 'package:ladakh_app/screens/post_ad_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  
  bool _isOtpHidden = true; // State to show OTP field
  bool _isLoading = false;
  String _verificationId = '';

  FirebaseAuth get _auth => FirebaseAuth.instance;

  Future<void> _verifyPhone(String errorMsg) async {
    setState(() => _isLoading = true);
    
    // Simple validation
    String phone = _phoneController.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
      setState(() => _isLoading = false);
      return;
    }
    
    if (!phone.startsWith('+91')) {
      phone = '+91$phone'; // Assume India
    }

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-sign in on Android
          await _auth.signInWithCredential(credential);
          _onLoginSuccess();
        },
        verificationFailed: (FirebaseAuthException e) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Verification Failed: ${e.message}')));
           setState(() => _isLoading = false);
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isOtpHidden = false;
            _isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _signInWithOTP() async {
    setState(() => _isLoading = true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text.trim(),
      );
      await _auth.signInWithCredential(credential);
      _onLoginSuccess();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid OTP')),
      );
    }
  }

  void _onLoginSuccess() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PostAdScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final langCode = Provider.of<LanguageProvider>(context).locale;
    String t(String key) => AppTranslations.get(langCode, key);

    return Scaffold(
      appBar: AppBar(title: const Text('Login / ནང་འཛུལ།')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.phonelink_lock, size: 80, color: Colors.grey),
            const SizedBox(height: 32),
            if (_isOtpHidden) ...[
              const Text(
                'Enter Phone Number to Continue',
                 textAlign: TextAlign.center,
                 style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+91...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : () => _verifyPhone('Enter valid phone number'),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('GET OTP'),
              ),
            ] else ...[
               const Text(
                'Enter OTP Sent to your phone',
                 textAlign: TextAlign.center,
                 style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'OTP',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_clock),
                ),
              ),
              const SizedBox(height: 16),
               ElevatedButton(
                onPressed: _isLoading ? null : _signInWithOTP,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('VERIFY & LOGIN'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
