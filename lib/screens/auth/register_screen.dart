import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fintech_app/services/api_service.dart'; // ⬅️ IMPORT
import 'package:fintech_app/screens/auth/otp_screen.dart'; // ⬅️ IMPORT
import 'package:fintech_app/screens/auth/login_screen.dart'; // ⬅️ IMPORT

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  // 4 Controller untuk 4 input
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi untuk memanggil API Register
  void _handleRegister() async {
    // Validasi simpel (pastikan tidak kosong)
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showError("Semua field wajib diisi.");
      return;
    }

    // 1. Mulai Loading
    setState(() {
      _isLoading = true;
    });

    // 2. Panggil API
    final result = await _apiService.register(
      _fullNameController.text,
      _emailController.text,
      _phoneController.text,
      _passwordController.text,
    );

    // 3. Hentikan Loading
    setState(() {
      _isLoading = false;
    });

    // 4. Cek Hasil
    if (result['success'] == true) {
      // BERHASIL! Pindah ke Halaman OTP
      // Kirim userId dan email ke OtpScreen
      String userId = result['data']['user_id'];
      String email = result['data']['email'];

      // Pakai mounted check agar aman
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(email: email, userId: userId),
          ),
        );
      }
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
                // Tombol Back (Kembali ke Login)
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Kembali ke halaman sebelumnya (Login)
                  },
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 30),

                // Judul
                Text(
                  "Create Account",
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
                  "Start your journey with us.",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 50),

                // Input Full Name
                _buildUnderlineTextField(
                  controller: _fullNameController,
                  hintText: "Full Name",
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 30),

                // Input Email
                _buildUnderlineTextField(
                  controller: _emailController,
                  hintText: "Email Address",
                  icon: Icons.alternate_email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 30),

                // Input Phone Number
                _buildUnderlineTextField(
                  controller: _phoneController,
                  hintText: "Phone Number",
                  icon: Icons.phone_android_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 30),

                // Input Password
                _buildUnderlineTextField(
                  controller: _passwordController,
                  hintText: "Password",
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
                const SizedBox(height: 60),

                // Tombol Register
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
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
                            "Create Account",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 40),

                // Link Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Kembali ke Login Screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: Text(
                        " Login",
                        style: GoogleFonts.poppins(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget helper untuk TextField (style sama persis)
  Widget _buildUnderlineTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
      cursorColor: Colors.blueAccent,
      decoration: InputDecoration(
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