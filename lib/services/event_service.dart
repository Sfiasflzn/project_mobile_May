import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Stream<List<EventModel>> getPublishedEvents() {
    return _firestore
        .collection('events')
        .where('isPublished', isEqualTo: true)
        .orderBy('startDate')
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => EventModel.fromMap(d.data(), d.id)).toList());
  }


  Stream<List<EventModel>> getOrganizerEvents(String organizerId) {
    return _firestore
        .collection('events')
        .where('organizerId', isEqualTo: organizerId)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => EventModel.fromMap(d.data(), d.id)).toList());
  }

  // get all the events (Admin)
  Stream<List<EventModel>> getAllEvents() {
    return _firestore
        .collection('events')
        .orderBy('startDate')
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => EventModel.fromMap(d.data(), d.id)).toList());
  }

  // Create new event
  Future<String> createEvent(EventModel event) async {
    final doc = await _firestore.collection('events').add(event.toMap());
    return doc.id;
  }

  // Update event
  Future<void> updateEvent(EventModel event) async {
    await _firestore
        .collection('events')
        .doc(event.id)
        .update(event.toMap());
  }

  // Publish / Unpublish event (Admin)
  Future<void> togglePublish(String eventId, bool isPublished) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .update({'isPublished': isPublished});
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
  }
}
