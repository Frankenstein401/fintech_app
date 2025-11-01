import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fintech_app/services/api_service.dart'; // ⬅️ IMPORT JEMBATAN API
import 'package:fintech_app/screens/auth/login_screen.dart'; // ⬅️ IMPORT HALAMAN LOGIN (Tujuan akhir)

class SetupProfileScreen extends StatefulWidget {
  // Kita terima 2 data ini dari OtpScreen
  final String userId;

  const SetupProfileScreen({super.key, required this.userId});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // 2 Controller untuk 2 input
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  // Fungsi untuk memanggil API Setup Profile
  void _handleSetupProfile() async {
    if (_usernameController.text.isEmpty || _pinController.text.isEmpty) {
      _showError("Username dan PIN wajib diisi.");
      return;
    }
    if (_pinController.text.length != 6) {
      _showError("PIN harus 6 digit.");
      return;
    }

    // 1. Mulai Loading
    setState(() {
      _isLoading = true;
    });

    // 2. Panggil API (Kita akan tambahkan fungsi ini di ApiService)
    final result = await _apiService.setupProfile(
      widget.userId, // Ambil userId dari 'widget'
      _usernameController.text,
      _pinController.text,
    );

    // 3. Hentikan Loading
    setState(() {
      _isLoading = false;
    });

    // 4. Cek Hasil
    if (result['success'] == true) {
      // BERHASIL! Tampilkan pop-up sukses dan lempar ke Halaman Login
      _showSuccessAndNavigate();
    } else {
      // GAGAL! Tampilkan pesan error
      _showError(result['message']);
    }
  }

  // Helper untuk menampilkan pesan error
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

  // Helper untuk sukses
  void _showSuccessAndNavigate() {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false, // User tidak bisa skip
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF23265A),
          title: Text(
            "Registrasi Berhasil!",
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          content: Text(
            "Akun Anda telah berhasil dibuat. Silakan login.",
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Lempar ke Halaman Login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false, // Hapus semua riwayat halaman sebelumnya
                );
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tidak ada tombol back, user harus selesaikan ini
                const SizedBox(height: 30),
                Text(
                  "Setup Profile",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.blue.withOpacity(0.5),
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Satu langkah terakhir, buat username dan PIN Anda.",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 50),

                // Input Username
                _buildUnderlineTextField(
                  controller: _usernameController,
                  hintText: "Create Username",
                  icon: Icons.person_search_outlined,
                ),
                const SizedBox(height: 30),

                // Input PIN
                _buildUnderlineTextField(
                  controller: _pinController,
                  hintText: "Create 6-Digit PIN",
                  icon: Icons.pin_outlined,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6, // ⬅️ Batasi 6 digit
                ),
                const SizedBox(height: 60),

                // Tombol Complete Setup
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSetupProfile,
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
                            "Complete Setup",
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
      maxLength: maxLength, // ⬅️ Tambahkan maxLength
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
      cursorColor: Colors.blueAccent,
      decoration: InputDecoration(
        counterText: "", // ⬅️ Sembunyikan counter
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