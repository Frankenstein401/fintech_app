// File: lib/screens/topup/topup_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fintech_app/services/api_service.dart'; // Import Jembatan API

class TopupScreen extends StatefulWidget {
  const TopupScreen({super.key});

  @override
  State<TopupScreen> createState() => _TopupScreenState();
}

class _TopupScreenState extends State<TopupScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // 3 Controller
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _methodController = TextEditingController(text: "Bank Transfer"); // Default
  final TextEditingController _proofController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _methodController.dispose();
    _proofController.dispose();
    super.dispose();
  }

  // Fungsi untuk memanggil API Top-Up
  void _handleTopup() async {
    if (_amountController.text.isEmpty ||
        _methodController.text.isEmpty ||
        _proofController.text.isEmpty) {
      _showError("Semua field wajib diisi.");
      return;
    }

    setState(() { _isLoading = true; });

    final result = await _apiService.requestTopup(
      _amountController.text,
      _methodController.text,
      _proofController.text,
    );

    setState(() { _isLoading = false; });

    if (result['success'] == true) {
      // BERHASIL! Tampilkan pop-up dan kembali ke Home
      _showSuccessAndNavigate(result['message']);
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

  void _showSuccessAndNavigate(String message) {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF23265A),
          title: Text(
            "Permintaan Terkirim!",
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            message, // "Permintaan top-up berhasil dibuat. Menunggu verifikasi admin."
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Kembali ke Dashboard (Halaman Home)
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text("OK", style: GoogleFonts.poppins(color: Colors.blueAccent)),
            )
          ],
        ),
      );
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
          "Setor Dana",
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
                "Konfirmasi Setoran",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Masukkan detail setoran Anda. Saldo akan masuk setelah diverifikasi Admin.",
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 50),

              // Input Jumlah (Amount)
              _buildUnderlineTextField(
                controller: _amountController,
                hintText: "Jumlah Setoran (Rp)",
                icon: Icons.attach_money_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 30),

              // Input Metode
              _buildUnderlineTextField(
                controller: _methodController,
                hintText: "Metode Pembayaran (misal: Bank Transfer)",
                icon: Icons.account_balance_outlined,
              ),
              const SizedBox(height: 30),

              // Input Bukti URL (Sederhana untuk tes)
              _buildUnderlineTextField(
                controller: _proofController,
                hintText: "URL Bukti Transfer (https://...)",
                icon: Icons.link_outlined,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 60),

              // Tombol Konfirmasi Setoran
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleTopup,
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
                          "Kirim Permintaan",
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