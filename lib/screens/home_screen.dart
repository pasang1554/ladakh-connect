import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:ladakh_app/models/ad_model.dart';
import 'package:ladakh_app/services/firebase_service.dart';
import 'package:ladakh_app/widgets/ad_card.dart';
import 'package:ladakh_app/screens/post_ad_screen.dart';
import 'package:ladakh_app/screens/login_screen.dart';
import 'package:ladakh_app/main.dart'; // For LanguageProvider
import 'package:ladakh_app/utils/translations.dart';
import 'package:ladakh_app/screens/safety_tips_screen.dart';
import 'package:ladakh_app/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  void _showLanguageSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Language / སྐད་རིགས་འདེམས་པ།', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                title: const Text('English'),
                onTap: () {
                  Provider.of<LanguageProvider>(context, listen: false).setLanguage('en');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text('🇮🇳', style: TextStyle(fontSize: 24)),
                title: const Text('Hindi (हिंदी)'),
                onTap: () {
                  Provider.of<LanguageProvider>(context, listen: false).setLanguage('hi');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Text('🏔️', style: TextStyle(fontSize: 24)),
                title: const Text('Ladakhi (ལ་དྭགས་སྐད།)'),
                onTap: () {
                  Provider.of<LanguageProvider>(context, listen: false).setLanguage('lb');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context, listen: false);
    final langCode = Provider.of<LanguageProvider>(context).locale;
    
    String t(String key) => AppTranslations.get(langCode, key);

    return Scaffold(
      appBar: AppBar(
        title: Text(t('title'), style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SafetyTipsScreen()),
              );
            },
            tooltip: t('safety_tips'),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
               // Check if logged in
               if (FirebaseAuth.instance.currentUser != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
               } else {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
               }
            },
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: () => _showLanguageSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: t('search'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear), 
                      onPressed: () {
                         _searchController.clear();
                         setState(() => _searchQuery = '');
                      },
                    )
                  : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<AdModel>>(
              stream: firebaseService.getAds(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                // Client-side filtering
                var ads = snapshot.data ?? [];
                if (_searchQuery.isNotEmpty) {
                  ads = ads.where((ad) {
                    final title = ad.title.toLowerCase();
                    final loc = ad.location.toLowerCase();
                    final cat = ad.category.toLowerCase();
                    return title.contains(_searchQuery) || 
                           loc.contains(_searchQuery) || 
                           cat.contains(_searchQuery);
                  }).toList();
                }

                if (ads.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.store_mall_directory_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(t('no_items'), 
                            style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: ads.length,
                  itemBuilder: (context, index) {
                    return AdCard(ad: ads[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PostAdScreen()),
            );
          }
        },
        label: Text(t('sell_item'), style: const TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add_a_photo),
        backgroundColor: const Color(0xFFD35400),
      ),
    );
  }
}
