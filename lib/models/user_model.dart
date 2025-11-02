// lib/models/user_model.dart

class User {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String verificationStatus;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.verificationStatus,
  });

  // Factory constructor untuk membuat User dari JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? 'N/A', // Jika username null
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? 'Guest',
      phoneNumber: json['phone_number'] ?? '',
      verificationStatus: json['verification_status'] ?? 'unverified',
    );
  }
}