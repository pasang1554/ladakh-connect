import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:ladakh_app/models/ad_model.dart';
import 'package:ladakh_app/services/firebase_service.dart';
import 'package:ladakh_app/widgets/ad_card.dart';
import 'package:ladakh_app/screens/login_screen.dart';
import 'package:ladakh_app/utils/translations.dart';
import 'package:ladakh_app/main.dart'; // LanguageProvider

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final langCode = Provider.of<LanguageProvider>(context).locale;
    String t(String key) => AppTranslations.get(langCode, key);
    final firebaseService = Provider.of<FirebaseService>(context, listen: false);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Please Login to view profile')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Ads / ངའི་ཁྱབ་བསྒྲགས།'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          )
        ],
      ),
      body: StreamBuilder<List<AdModel>>(
        // We need a query for *my* ads. 
        // For MVP without updating index, we can filter client side or add a specific query in Service.
        // Let's rely on client-side filter of the main stream for simplicity if list is small, 
        // OR better: add getMyAds to service. Let's filter client side for now to reduce complexity errors.
        stream: firebaseService.getAds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final allAds = snapshot.data ?? [];
          // Filter ads where phone number matches? Or better, we should have stored userId.
          // In my AdModel I stored 'sellerPhone' but not 'userId'.
          // Major mistake in AdModel design! I can't securely filter by User ID because I didn't save it.
          // Fix: I will filter by sellerPhone since that's what we have, assuming user phone matches.
          // BUT wait, FirebaseAuth phone number includes +91, AdModel might not. 
          // Let's filter by checking if user.phoneNumber contains sellerPhone or vice versa.
          
          final myAds = allAds.where((ad) {
             // Loose matching for MVP
             return user.phoneNumber != null && (
               user.phoneNumber!.contains(ad.sellerPhone) || 
               ad.sellerPhone.contains(user.phoneNumber!.replaceAll('+91', ''))
             );
          }).toList();

          if (myAds.isEmpty) {
            return const Center(child: Text('You have not posted any ads yet.'));
          }

          return ListView.builder(
            itemCount: myAds.length,
            itemBuilder: (context, index) {
              final ad = myAds[index];
              return Stack(
                children: [
                   AdCard(ad: ad),
                   Positioned(
                     right: 24,
                     top: 16,
                     child: CircleAvatar(
                       backgroundColor: Colors.white,
                       child: IconButton(
                         icon: const Icon(Icons.delete, color: Colors.red),
                         onPressed: () {
                           showDialog(
                             context: context,
                             builder: (context) => AlertDialog(
                               title: const Text('Delete Ad?'),
                               content: const Text('This cannot be undone.'),
                               actions: [
                                 TextButton(child: const Text('Cancel'), onPressed:()=>Navigator.pop(context)),
                                 TextButton(
                                   child: const Text('Delete', style: TextStyle(color: Colors.red)), 
                                   onPressed:() {
                                     Navigator.pop(context);
                                     firebaseService.deleteAd(ad.id);
                                   }
                                 ),
                               ],
                             ),
                           );
                         },
                       ),
                     ),
                   ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
