import 'package:flutter/material.dart';
import 'package:ladakh_app/screens/home_screen.dart';
import 'package:ladakh_app/main.dart'; // For LanguageProvider
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate loading or check for user session here
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _showLanguageSelection();
      }
    });
  }

  void _showLanguageSelection() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Select Language / སྐད་རིགས།'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              onTap: () => _navigateToHome('en'),
            ),
            ListTile(
              leading: const Text('🇮🇳', style: TextStyle(fontSize: 24)),
              title: const Text('Hindi (हिंदी)'),
              onTap: () => _navigateToHome('hi'),
            ),
            ListTile(
              leading: const Text('🏔️', style: TextStyle(fontSize: 24)),
              title: const Text('Ladakhi (ལ་དྭགས་སྐད།)'),
              onTap: () => _navigateToHome('lb'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToHome(String langCode) {
    Provider.of<LanguageProvider>(context, listen: false).setLanguage(langCode);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD35400), // Pumpkin Brand Color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.storefront, size: 80, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'Ladakh Bazaar',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ལ་དྭགས་ ཁྲོམ་ར།',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
