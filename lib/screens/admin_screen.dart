import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:ladakh_app/services/firebase_service.dart';
import 'package:ladakh_app/models/ad_model.dart';
import 'package:ladakh_app/widgets/ad_card.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.red[900],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firebaseService.getReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No reports! Good job community.'));
          }

          final reports = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              final data = report.data() as Map<String, dynamic>;
              final adId = data['adId'];
              final reason = data['reason'];

              return Card(
                color: Colors.red[50],
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text('Report: $reason', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  subtitle: Text('Ad ID: $adId'),
                  children: [
                    // Fetch and show the Ad associated with this report
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('ads').doc(adId).get(),
                      builder: (context, adSnapshot) {
                        if (!adSnapshot.hasData) return const LinearProgressIndicator();
                        if (!adSnapshot.data!.exists) return const Padding(padding: EdgeInsets.all(8.0), child: Text('Ad already deleted.'));
                        
                        final adData = adSnapshot.data!.data() as Map<String, dynamic>;
                        final ad = AdModel.fromMap(adData, adSnapshot.data!.id);
                        
                        return Column(
                          children: [
                            AdCard(ad: ad), // Reuse our nice card
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    firebaseService.dismissReport(report.id);
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                                  icon: const Icon(Icons.check),
                                  label: const Text('Ignore Report'),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    firebaseService.deleteAd(adId);
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  icon: const Icon(Icons.delete_forever),
                                  label: const Text('DELETE AD'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
