import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- NEW: Method to save an admin announcement ---
  Future<void> saveAnnouncement(String message) async {
    await _firestore.collection('announcements').add({
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // --- NEW: Method to get a stream of announcements ---
  Stream<QuerySnapshot> getAnnouncementsStream() {
    return _firestore
        .collection('announcements')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // --- Existing Methods ---
  Stream<QuerySnapshot> getPredictionsStream({Duration? within}) {
    Query query = _firestore
        .collection('predictions')
        .orderBy('timestamp', descending: true);
    if (within != null) {
      DateTime cutoff = DateTime.now().subtract(within);
      query = query.where('timestamp', isGreaterThanOrEqualTo: cutoff);
    }
    return query.snapshots();
  }

  Stream<QuerySnapshot> getClinicReportsStream({Duration? within}) {
    Query query = _firestore
        .collection('clinic_reports')
        .orderBy('timestamp', descending: true);
    if (within != null) {
      DateTime cutoff = DateTime.now().subtract(within);
      query = query.where('timestamp', isGreaterThanOrEqualTo: cutoff);
    }
    return query.snapshots();
  }

  Future<void> savePrediction(Map<String, dynamic> data) async {
    await _firestore.collection('predictions').add(data);
  }

  Future<void> saveClinicReport(Map<String, dynamic> data) async {
    await _firestore.collection('clinic_reports').add(data);
  }
}

