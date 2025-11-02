// File: lib/screens/transfer/transfer_screen.dart
// VERSI 2.0 (Bisa menerima data penerima awal)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fintech_app/services/api_service.dart'; 

class TransferScreen extends StatefulWidget {
  // ⬇️ KITA TAMBAHKAN INI ⬇️
  // Ini adalah data opsional. Jika dikirim, form akan terisi otomatis
  final String? initialRecipient; 

  const TransferScreen({super.key, this.initialRecipient}); // ⬅️ UBAH INI

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  // ⬇️ TAMBAHKAN FUNGSI INI ⬇️
  @override
  void initState() {
    super.initState();
    // Jika ada kiriman data 'initialRecipient', masukkan ke form
    if (widget.initialRecipient != null) {
      _recipientController.text = widget.initialRecipient!;
    }
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  // (Fungsi _handleTransfer, _showError, _showSuccessAndNavigate TETAP SAMA)
  void _handleTransfer() async {
    if (_recipientController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _pinController.text.isEmpty) {
      _showError("Semua field wajib diisi.");
      return;
    }
    setState(() { _isLoading = true; });
    final result = await _apiService.transferP2P(
      _recipientController.text,
      _amountController.text,
      _pinController.text,
    );
    setState(() { _isLoading = false; });
    if (result['success'] == true) {
      final Map<String, dynamic> transactionData = result['data'];
      await _showSuccessAndNavigate(transactionData); 
      if (mounted) {
        Navigator.pop(context, true); // Kirim sinyal 'true'
      }
    } else {
      _showError(result['message']);
    }
  }
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
  Future<void> _showSuccessAndNavigate(Map<String, dynamic> data) async {
    final String receiverName = data['receiver']['full_name'] ?? 'N/A';
    final String amount = data['amount'] ?? '0';
    final String notes = data['notes'] ?? '-';
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF23265A),
        title: Text(
          "Transfer Berhasil!",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Detail Transaksi:", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 10),
            _buildDetailRow("Ke", receiverName),
            _buildDetailRow("Jumlah", "Rp $amount"),
            _buildDetailRow("Catatan", notes),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); 
            },
            child: Text("OK", style: GoogleFonts.poppins(color: Colors.blueAccent)),
          )
        ],
      ),
    );
  }
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            ),
          ),
          const Text(": ", style: TextStyle(color: Colors.white70)),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
  // (Fungsi build() TETAP SAMA)
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
          "Transfer Dana",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Kirim Ke",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Masukkan No. Rekening, Username, atau Email tujuan.",
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 50),

              // Input Penerima
              _buildUnderlineTextField(
                controller: _recipientController, // ⬅️ Ini akan terisi otomatis
                hintText: "No. Rekening / Username / Email",
                icon: Icons.person_search_outlined,
              ),
              const SizedBox(height: 30),

              // Input Jumlah (Amount)
              _buildUnderlineTextField(
                controller: _amountController,
                hintText: "Jumlah Transfer (Rp)",
                icon: Icons.attach_money_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 30),

              // Input PIN
              _buildUnderlineTextField(
                controller: _pinController,
                hintText: "Masukkan 6-Digit PIN",
                icon: Icons.pin_outlined,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              const SizedBox(height: 60),

              // Tombol Transfer
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleTransfer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 10,
                    shadowColor: Colors.blueAccent.withOpacity(0.5),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Kirim Sekarang",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // (Fungsi _buildUnderlineTextField() TETAP SAMA)
  Widget _buildUnderlineTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
      cursorColor: Colors.blueAccent,
      decoration: InputDecoration(
        counterText: "",
        prefixIcon: Icon(icon, color: Colors.white70, size: 22),
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(color: Colors.white54, fontSize: 16),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white30, width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }
}