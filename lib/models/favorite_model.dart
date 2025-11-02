// File: lib/models/favorite_model.dart

class FavoriteRecipient {
  final int favoriteId;
  final String recipientUserId;
  final String recipientUsername;
  final String recipientFullName;
  final String? aliasName;
  final String displayName;

  FavoriteRecipient({
    required this.favoriteId,
    required this.recipientUserId,
    required this.recipientUsername,
    required this.recipientFullName,
    this.aliasName,
    required this.displayName,
  });

  factory FavoriteRecipient.fromJson(Map<String, dynamic> json) {
    return FavoriteRecipient(
      favoriteId: json['favorite_id'] ?? 0,
      recipientUserId: json['recipient']?['user_id'] ?? '',
      recipientUsername: json['recipient']?['username'] ?? 'N/A',
      recipientFullName: json['recipient']?['full_name'] ?? 'N/A',
      aliasName: json['alias_name'],
      displayName: json['display_name'] ?? json['recipient']?['full_name'] ?? 'N/A',
    );
  }
}