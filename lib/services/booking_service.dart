import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<String> createBooking(BookingModel booking) async {
    // Update booth status ke 'booked'
    final boothQuery = await _firestore
        .collection('booths')
        .where('boothId', isEqualTo: booking.boothId)
        .where('eventId', isEqualTo: booking.eventId)
        .get();

    if (boothQuery.docs.isNotEmpty) {
      await boothQuery.docs.first.reference.update({'status': 'booked'});
    }

    final doc = await _firestore
        .collection('bookings')
        .add(booking.toMap());
    return doc.id;
  }


  Stream<List<BookingModel>> getExhibitorBookings(String exhibitorId) {
    return _firestore
        .collection('bookings')
        .where('exhibitorId', isEqualTo: exhibitorId)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => BookingModel.fromMap(d.data(), d.id))
        .toList());
  }


  Stream<List<BookingModel>> getAllBookings() {
    return _firestore
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => BookingModel.fromMap(d.data(), d.id))
        .toList());
  }

  // Update booking status (Organizer/Admin)
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _firestore
        .collection('bookings')
        .doc(bookingId)
        .update({'status': status});
  }

  // Update booking details (Exhibitor edit)
  Future<void> updateBooking(BookingModel booking) async {
    await _firestore
        .collection('bookings')
        .doc(booking.id)
        .update(booking.toMap());
  }

  // Cancel booking
  Future<void> cancelBooking(String bookingId, String boothId, String eventId) async {
    await _firestore
        .collection('bookings')
        .doc(bookingId)
        .update({'status': 'cancelled'});


    final boothQuery = await _firestore
        .collection('booths')
        .where('boothId', isEqualTo: boothId)
        .where('eventId', isEqualTo: eventId)
        .get();

    if (boothQuery.docs.isNotEmpty) {
      await boothQuery.docs.first.reference.update({'status': 'available'});
    }
  }
}
