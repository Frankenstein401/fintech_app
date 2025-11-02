// File: lib/models/transaction_model.dart
// Model yang sudah diperbaiki untuk handle numeric types dari API

class Transaction {
  final String transactionId;
  final String type; // 'sent' atau 'received'
  final Map<String, dynamic> sender;
  final Map<String, dynamic> receiver;
  final String amount;
  final String? adminFee;        // ⬅️ Ubah jadi nullable
  final String? totalDeducted;
  final String? notes;
  final String status;
  final String createdAt;

  Transaction({
    required this.transactionId,
    required this.type,
    required this.sender,
    required this.receiver,
    required this.amount,
    this.adminFee,               // ⬅️ Hapus required
    this.totalDeducted,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['transaction_id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'unknown',
      sender: json['sender'] ?? {},
      receiver: json['receiver'] ?? {},
      
      // ⬇️ PERBAIKAN: Handle int/double/string
      amount: _parseToString(json['amount']),
      adminFee: _parseToString(json['admin_fee']),
      totalDeducted: _parseToString(json['total_deducted']),
      
      notes: json['notes']?.toString(),
      status: json['status']?.toString() ?? 'failed',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  // ⬇️ HELPER: Convert any number type to string
  static String _parseToString(dynamic value) {
    if (value == null) return '0';
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is double) return value.toStringAsFixed(2);
    return value.toString();
  }
}