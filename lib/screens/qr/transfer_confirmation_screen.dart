// File: lib/screens/qr/transfer_confirmation_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fintech_app/services/api_service.dart';

class TransferConfirmationScreen extends StatefulWidget {
  final String qrString; // Data QR mentah (base64)
  final Map<String, dynamic> recipientData; // Info penerima dari API Parse

  const TransferConfirmationScreen({
    super.key,
    required this.qrString,
    required this.recipientData,
  });

  @override
  State<TransferConfirmationScreen> createState() =>
      _TransferConfirmationScreenState();
}

class _TransferConfirmationScreenState
    extends State<TransferConfirmationScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  // Fungsi untuk memanggil API transferViaQR
  void _handleTransfer() async {
    if (_amountController.text.isEmpty || _pinController.text.isEmpty) {
      _showError("Jumlah dan PIN wajib diisi.");
      return;
    }

    setState(() { _isLoading = true; });

    final result = await _apiService.transferViaQR(
      widget.qrString,
      _amountController.text,
      _pinController.text,
    );

    setState(() { _isLoading = false; });

    if (result['success'] == true) {
      // BERHASIL!
      final Map<String, dynamic> transactionData = result['data'];
      await _showSuccessAndNavigate(transactionData);

      if (mounted) {
        // Kembali 2x (tutup halaman ini & halaman scanner)
        // dan kirim sinyal 'true' ke Home
        Navigator.of(context).popUntil((route) => route.isFirst); 
        // Kita perlu cara yang lebih baik untuk refresh Home, 
        // tapi ini akan membawa user kembali ke Home.
        // Kita akan perbaiki refresh-nya setelah ini.
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

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF23265A),
        title: Text(
          "Transfer QR Berhasil!",
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Berhasil transfer Rp $amount ke $receiverName.",
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
            },
            child: Text("OK", style: GoogleFonts.poppins(color: Colors.blueAccent)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data penerima dari widget
    final String fullName = widget.recipientData['full_name'] ?? 'N/A';
    final String username = widget.recipientData['username'] ?? 'N/A';

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
          "Konfirmasi Transfer QR",
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
              // Info Penerima
              Text(
                "Transfer Ke:",
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF23265A),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.blueAccent, size: 40),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "@$username",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),

              // Input Jumlah
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

              // Tombol Konfirmasi Bayar
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
                          "Konfirmasi & Bayar",
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

  // Widget helper untuk TextField
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