import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:ladakh_app/models/ad_model.dart';
import 'package:ladakh_app/main.dart'; // LanguageProvider
import 'package:ladakh_app/utils/translations.dart';
import 'package:ladakh_app/services/firebase_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class DetailScreen extends StatelessWidget {
  final AdModel ad;

  const DetailScreen({super.key, required this.ad});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (!await launchUrl(launchUri)) {
      throw Exception('Could not launch $launchUri');
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    var phone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), ''); 
    if (!phone.startsWith('91')) phone = '91$phone'; 

    final Uri launchUri = Uri.parse("whatsapp://send?phone=$phone");
    if (!await launchUrl(launchUri)) {
       final Uri webUri = Uri.parse("https://wa.me/$phone");
       if (!await launchUrl(webUri, mode: LaunchMode.externalApplication)) {
         throw Exception('Could not launch WhatsApp');
       }
    }
  }

  void _submitReport(BuildContext context, String adId, String reason) {
    // 1. Close Dialog
    Navigator.pop(context); 
    
    // 2. Call Backend
    Provider.of<FirebaseService>(context, listen: false).reportAd(adId, reason);

    // 3. Show Success (Using translation requires looking up context again, 
    // but we can pass the string or use a hardcoded safe one for now)
    ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('Report Sent / ཞུ་གཏུག་ འབྱོར་སོང་།')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Note: Currency formatting is standard numeric, so no translation needed usually
    final currencyFormatter = NumberFormat.simpleCurrency(locale: 'en_IN');
    
    final langCode = Provider.of<LanguageProvider>(context).locale;
    String t(String key) => AppTranslations.get(langCode, key);

    return Scaffold(
      extendBodyBehindAppBar: true, // Allow image to be behind transparent app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
               Share.share(
                 'Check out this ${ad.title} for ₹${ad.price.toInt()} on Ladakh Bazaar! Call: ${ad.sellerPhone}',
                 subject: 'Ladakh Bazaar Item',
               );
            },
          ),
          Container(
            margin: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white54,
            ),
            child: IconButton(
              icon: const Icon(Icons.flag, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(t('report_ad')),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(title: const Text('Spam / Fake'), onTap: () => _submitReport(context, ad.id, 'Spam')),
                        ListTile(title: const Text('Inappropriate'), onTap: () => _submitReport(context, ad.id, 'Inappropriate')),
                        ListTile(title: const Text('Sold Out'), onTap: () => _submitReport(context, ad.id, 'Sold Out')),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                );
              },
              tooltip: t('report_ad'),
            ),
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: ad.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.broken_image),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currencyFormatter.format(ad.price),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD35400),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.brown[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          timeago.format(ad.postedAt),
                          style: TextStyle(color: Colors.brown[900], fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ad.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        ad.location,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.category, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        ad.category,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Text(
                    t('description'),
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.brown[800]
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ad.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 80), 
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _makePhoneCall(ad.sellerPhone),
                icon: const Icon(Icons.call),
                label: Text(t('call')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _openWhatsApp(ad.sellerPhone),
                icon: const Icon(Icons.message), 
                label: Text(t('whatsapp')),
                style: ElevatedButton.styleFrom(
                   backgroundColor: const Color(0xFF25D366),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
