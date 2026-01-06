import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ladakh_app/models/ad_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collectionName = 'ads';

  // Get stream of all ads (sorted by date)
  Stream<List<AdModel>> getAds() {
    return _firestore
        .collection(_collectionName)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AdModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // Upload image to Firebase Storage
  Future<String> uploadImage(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = _storage.ref().child('ad_images/$fileName.jpg');
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Post a new ad
  Future<void> postAd(AdModel ad) async {
    await _firestore.collection(_collectionName).add(ad.toMap());
  }

  // Search ads (Basic local filter for now as Firestore fuzzy search is limited)
  Stream<List<AdModel>> searchAds(String query) {
    // In a real app, use Algolia or specialized search.
    // Here we just fetch all and filter in UI or simple memory cache.
    // For MVP, returning all and filtering in Provider is easier.
    return getAds(); 
  }

  // Report an ad
  Future<void> reportAd(String adId, String reason) async {
    await _firestore.collection('reports').add({
      'adId': adId,
      'reason': reason,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // --- Admin Features ---

  // Get all reports
  Stream<QuerySnapshot> getReports() {
    return _firestore.collection('reports')
      .orderBy('timestamp', descending: true)
      .snapshots();
  }

  // Delete an ad (and its reports)
  Future<void> deleteAd(String adId) async {
    await _firestore.collection('ads').doc(adId).delete();
    // Optional: Cleanup reports for this ad
    final reports = await _firestore.collection('reports').where('adId', isEqualTo: adId).get();
    for (var doc in reports.docs) {
      doc.reference.delete();
    }
  }

  // Dismiss a report (false alarm)
  Future<void> dismissReport(String reportId) async {
    await _firestore.collection('reports').doc(reportId).delete();
  }
}
