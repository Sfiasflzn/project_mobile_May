class BoothModel {
  final String id;
  final String eventId;
  final String boothId; // e.g., 'A1', 'B3'
  final String type;    // 'standard', 'premium', 'corner'
  final double size;    // in sqm
  final double price;
  final List<String> amenities;
  final String status;  // 'available', 'booked', 'selected'
  final int row;
  final int col;

  BoothModel({
    required this.id,
    required this.eventId,
    required this.boothId,
    required this.type,
    required this.size,
    required this.price,
    required this.amenities,
    this.status = 'available',
    required this.row,
    required this.col,
  });

  factory BoothModel.fromMap(Map<String, dynamic> map, String id) {
    return BoothModel(
      id: id,
      eventId: map['eventId'] ?? '',
      boothId: map['boothId'] ?? '',
      type: map['type'] ?? 'standard',
      size: (map['size'] ?? 0).toDouble(),
      price: (map['price'] ?? 0).toDouble(),
      amenities: List<String>.from(map['amenities'] ?? []),
      status: map['status'] ?? 'available',
      row: map['row'] ?? 0,
      col: map['col'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'boothId': boothId,
      'type': type,
      'size': size,
      'price': price,
      'amenities': amenities,
      'status': status,
      'row': row,
      'col': col,
    };
  }
}
