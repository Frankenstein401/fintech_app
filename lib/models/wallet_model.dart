// lib/models/wallet_model.dart

class Wallet {
  final String walletId;
  final String accountNumber; // ⬅️ Ini Kuncinya!
  final String balance;
  final String balanceLimit;

  Wallet({
    required this.walletId,
    required this.accountNumber,
    required this.balance,
    required this.balanceLimit,
  });

  // Factory constructor untuk membuat Wallet dari JSON
  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      walletId: json['wallet_id'] ?? '',
      accountNumber: json['account_number'] ?? 'N/A', // ⬅️ Kita ambil
      balance: json['balance'] ?? '0.00',
      balanceLimit: json['balance_limit'] ?? '0.00',
    );
  }
}