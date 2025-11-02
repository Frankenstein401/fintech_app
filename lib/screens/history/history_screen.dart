// File: lib/screens/history/history_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fintech_app/services/api_service.dart';
import 'package:fintech_app/models/transaction_model.dart'; // Model kita

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _apiService = ApiService();
  // Kita panggil API untuk semua history (default limit 100 dari service)
  late Future<Map<String, dynamic>> _historyData;

  @override
  void initState() {
    super.initState();
    // Panggil API saat halaman dibuka
    _historyData = _apiService.getTransactionHistory(limit: 100); // Ambil 100 transaksi
  }

  // Fungsi untuk format saldo (kita copy dari home_screen)
  String _formatBalance(String balance) {
    try {
      double amount = double.parse(balance);
      return amount
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
    } catch (e) {
      return balance;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121433),
      appBar: AppBar(
        backgroundColor: const Color(0xFF23265A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Mutasi Rekening",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        // TODO: Tambahkan tombol filter (nanti)
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _historyData,
        builder: (context, snapshot) {
          // 1. Saat loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            );
          }

          // 2. Jika error
          if (!snapshot.hasData || snapshot.data!['success'] == false) {
            return Center(
              child: Text(
                snapshot.data?['message'] ?? "Gagal memuat riwayat",
                style: GoogleFonts.inter(color: Colors.white60),
              ),
            );
          }

          // 3. Jika sukses
          final List<Transaction> transactions = snapshot.data!['data'];

          // 4. Jika tidak ada transaksi
          if (transactions.isEmpty) {
            return Center(
              child: Text(
                "Belum ada transaksi.",
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 16),
              ),
            );
          }

          // 5. Tampilkan list (bisa di-scroll)
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];

              // Logika yang sama persis dengan di Home
              final bool isSent = transaction.type == 'sent';
              final String title = isSent
                  ? "Transfer ke ${transaction.receiver['full_name']}"
                  : "Terima dari ${transaction.sender['full_name']}";
              final String amount = (isSent ? "- Rp " : "+ Rp ") +
                  _formatBalance(isSent ? transaction.totalDeducted! : transaction.amount);
              final Color color =
                  isSent ? const Color(0xFFEF4444) : const Color(0xFF10B981);
              final IconData icon =
                  isSent ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

              // Panggil widget item
              return _buildTransactionItem(
                icon: icon,
                iconColor: color,
                title: title,
                subtitle: transaction.createdAt, // Nanti kita format tanggalnya
                amount: amount,
                amountColor: color,
              );
            },
          );
        },
      ),
    );
  }

  // Widget item (sama persis dengan di home_screen.dart)
  Widget _buildTransactionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    required Color amountColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle, // Nanti kita format tanggalnya
                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.inter(
              color: amountColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}