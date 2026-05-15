class EventModel {
  final String id;
  final String name;
  final String venue;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final int maxExhibitors;
  final bool preventAdjacentCompetitors;
  final bool isPublished;
  final String organizerId;
  final String status; // 'upcoming', 'ongoing', 'ended'

  EventModel({
    required this.id,
    required this.name,
    required this.venue,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.maxExhibitors,
    this.preventAdjacentCompetitors = false,
    this.isPublished = false,
    required this.organizerId,
    required this.status,
  });

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      name: map['name'] ?? '',
      venue: map['venue'] ?? '',
      startDate: (map['startDate'] as dynamic).toDate(),
      endDate: (map['endDate'] as dynamic).toDate(),
      description: map['description'] ?? '',
      maxExhibitors: map['maxExhibitors'] ?? 0,
      preventAdjacentCompetitors: map['preventAdjacentCompetitors'] ?? false,
      isPublished: map['isPublished'] ?? false,
      organizerId: map['organizerId'] ?? '',
      status: map['status'] ?? 'upcoming',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'venue': venue,
      'startDate': startDate,
      'endDate': endDate,
      'description': description,
      'maxExhibitors': maxExhibitors,
      'preventAdjacentCompetitors': preventAdjacentCompetitors,
      'isPublished': isPublished,
      'organizerId': organizerId,
      'status': status,
    };
  }
}
