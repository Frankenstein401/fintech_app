import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fintech_app/services/api_service.dart'; // ⬅️ IMPORT JEMBATAN API
import 'package:fintech_app/screens/auth/setup_profile_screen.dart'; // ⬅️ IMPORT HALAMAN TUJUAN

class OtpScreen extends StatefulWidget {
  // Kita BUTUH data ini dari Halaman Register nanti
  final String email;
  final String userId; 

  const OtpScreen({super.key, required this.email, required this.userId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  
  final ApiService _apiService = ApiService(); // ⬅️ PANGGIL JEMBATAN
  bool _isLoading = false; // ⬅️ State untuk loading

  @override
  void dispose() {
    for (var controller in _otpControllers) controller.dispose();
    for (var focusNode in _focusNodes) focusNode.dispose();
    super.dispose();
  }

  String get _otpCode => _otpControllers.map((e) => e.text).join();

  // ⬇️ FUNGSI INI KITA ROMBAK ⬇️
  void _onOtpCompleted() async {
    if (_otpCode.length < 6) {
      _showError("Harap isi 6 digit OTP.");
      return;
    }

    // 1. Mulai Loading
    setState(() {
      _isLoading = true;
    });

    // 2. Panggil API
    final result = await _apiService.verifyOtp(widget.userId, _otpCode);

    // 3. Hentikan Loading
    setState(() {
      _isLoading = false;
    });

    // 4. Cek Hasil
    if (result['success'] == true) {
      // BERHASIL! Pindah ke Halaman Setup Profile
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SetupProfileScreen(userId: widget.userId),
        ),
      );
    } else {
      // GAGAL! Tampilkan pesan error
      _showError(result['message']);
    }
  }

  // Helper untuk menampilkan pesan error
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan email yang disensor (menggantikan nomor HP)
    String maskedEmail = widget.email.replaceRange(3, widget.email.indexOf('@'), '******');

    return Scaffold(
      backgroundColor: const Color(0xFF121433),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Verification code",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Kode telah dikirim ke\n$maskedEmail", // ⬅️ Tampilkan email
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              // (Timer kita skip dulu untuk kecepatan)
              
              const SizedBox(height: 50),

              // Input OTP (6 kotak)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    height: 55,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        filled: true,
                        fillColor:
                            const Color(0xFF23265A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.blueAccent, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.2), width: 1),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.length == 1 && index < 5) {
                          FocusScope.of(context)
                              .requestFocus(_focusNodes[index + 1]);
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context)
                              .requestFocus(_focusNodes[index - 1]);
                        }
                        if (_otpCode.length == 6) {
                          _onOtpCompleted(); // Otomatis panggil jika sudah 6 digit
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 30),

              // Tombol Resend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't get a code?",
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () {
                      print("Resend button clicked");
                      // TODO: Panggil API /api/auth/resend-otp
                    },
                    child: Text(
                      "Resend",
                      style: GoogleFonts.poppins(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(), 

              // Kebijakan Privasi
              // ... (kode kebijakan privasi tetap sama)

              const SizedBox(height: 20),

              // Tombol Continue (Sekarang ada logic loading)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  // ⬇️ ROMBAK LOGIC TOMBOL ⬇️
                  onPressed: _isLoading ? null : _onOtpCompleted, // Matikan tombol saat loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 10,
                    shadowColor: Colors.blueAccent.withOpacity(0.5),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white) // Tampilkan loading
                      : Text(
                          "Continue", // Tampilkan teks
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
}