import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booth_model.dart';

class BoothService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Stream<List<BoothModel>> getBoothsForEvent(String eventId) {
    return _firestore
        .collection('booths')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => BoothModel.fromMap(d.data(), d.id)).toList());
  }


  Future<void> createBooth(BoothModel booth) async {
    await _firestore.collection('booths').add(booth.toMap());
  }

  // Update status booth
  Future<void> updateBoothStatus(String boothId, String status) async {
    await _firestore
        .collection('booths')
        .doc(boothId)
        .update({'status': status});
  }

  // Delete booth
  Future<void> deleteBooth(String boothId) async {
    await _firestore.collection('booths').doc(boothId).delete();
  }


  Future<void> addBoothType({
    required String name,
    required double size,
    required double price,
    required bool available,
  }) async {
    await _firestore.collection('boothTypes').add({
      'name': name,
      'size': size,
      'price': price,
      'available': available,
    });
  }


  Stream<List<Map<String, dynamic>>> getBoothTypes() {
    return _firestore.collection('boothTypes').snapshots().map(
            (snap) => snap.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }
}
