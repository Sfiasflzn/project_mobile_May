class BookingModel {
  final String id;
  final String exhibitorId;
  final String eventId;
  final String boothId;
  final String companyName;
  final String companyDescription;
  final String exhibitProfile;
  final List<String> addOns;
  final double totalPrice;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'pending', 'approved', 'rejected', 'cancelled'
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.exhibitorId,
    required this.eventId,
    required this.boothId,
    required this.companyName,
    required this.companyDescription,
    required this.exhibitProfile,
    required this.addOns,
    required this.totalPrice,
    required this.startDate,
    required this.endDate,
    this.status = 'pending',
    required this.createdAt,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      exhibitorId: map['exhibitorId'] ?? '',
      eventId: map['eventId'] ?? '',
      boothId: map['boothId'] ?? '',
      companyName: map['companyName'] ?? '',
      companyDescription: map['companyDescription'] ?? '',
      exhibitProfile: map['exhibitProfile'] ?? '',
      addOns: List<String>.from(map['addOns'] ?? []),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      startDate: (map['startDate'] as dynamic).toDate(),
      endDate: (map['endDate'] as dynamic).toDate(),
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'exhibitorId': exhibitorId,
      'eventId': eventId,
      'boothId': boothId,
      'companyName': companyName,
      'companyDescription': companyDescription,
      'exhibitProfile': exhibitProfile,
      'addOns': addOns,
      'totalPrice': totalPrice,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
