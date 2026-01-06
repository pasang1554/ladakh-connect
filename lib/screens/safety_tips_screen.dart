import 'package:ladakh_app/main.dart';
import 'package:ladakh_app/utils/translations.dart';
import 'package:provider/provider.dart';
import 'package:ladakh_app/screens/admin_screen.dart';

class SafetyTipsScreen extends StatelessWidget {
  const SafetyTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langCode = Provider.of<LanguageProvider>(context).locale;
    String t(String key) => AppTranslations.get(langCode, key);

    return Scaffold(
      appBar: AppBar(title: Text(t('safety_tips'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTipCard(Icons.verified_user, 'Verify Seller', 
            'Always try to meet the seller in person in a safe, public place.'),
          _buildTipCard(Icons.money_off, 'No Advance Payment', 
            'Never send money online before seeing the item. Pay only after you check the product.'),
          _buildTipCard(Icons.phone_android, 'Check the Item', 
            'Check the phone/vehicle condition carefully before buying.'),
          _buildTipCard(Icons.report, 'Report Suspicious Ads', 
            'If you see something wrong, use the "Report" button.'),
          const Divider(height: 32),
          const Text(
            'About Ladakh Bazaar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'A free community app for Ladakh to buy and sell locally. Built for slow internet and simple usage.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 48),
          Center(
            child: TextButton.icon(
              onPressed: () {
                // In real app, check for specific admin phone number or password.
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen()));
              },
              icon: const Icon(Icons.admin_panel_settings, color: Colors.grey),
              label: const Text('Moderator Login', style: TextStyle(color: Colors.grey)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTipCard(IconData icon, String title, String desc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFD35400), size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
      ),
    );
  }
}
