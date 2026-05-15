class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String company;
  final String role; // 'guest', 'exhibitor', 'organizer', 'admin'
  final bool isActive;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.company,
    required this.role,
    this.isActive = true,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      company: map['company'] ?? '',
      role: map['role'] ?? 'exhibitor',
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'company': company,
      'role': role,
      'isActive': isActive,
    };
  }
}
