import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fintech_app/screens/auth/register_screen.dart'; // Import RegisterScreen

// TIDAK ADA 'import dart:ui;'

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121433), // Warna dasar
      body: Stack(
        children: [
          // Background dengan gradasi
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF23265A), // Gradasi
                  Color(0xFF121433), // Warna dasar
                ],
              ),
            ),
          ),
          
          // Gambar di bagian atas (TANPA ColorFilter)
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      'https://picsum.photos/id/1043/800/600'), // Gambar abstrak
                  fit: BoxFit.cover,
                  // ❌ colorFilter DIHAPUS
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
              ),
            ),
          ),
          
          // Konten Login: Teks, Form, Tombol
          Positioned.fill(
            top: MediaQuery.of(context).size.height * 0.35, 
            child: Container(
              // ❌ Efek Kaca (BackdropFilter & ImageFilter) DIHAPUS
              // ✅ Diganti dengan gradasi solid
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF23265A), // Warna gradasi atas
                    Color(0xFF121433), // Warna gradasi bawah
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
                boxShadow: [ // Kita tetap pakai shadow
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 15,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome Back!",
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
                        "Sign in to continue to your account.",
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 50),

                      // Input Email (dengan underline border)
                      _buildUnderlineTextField(
                        controller: _emailController,
                        hintText: "Email Address",
                        icon: Icons.alternate_email,
                      ),
                      const SizedBox(height: 30),

                      // Input Password (dengan underline border)
                      _buildUnderlineTextField(
                        controller: _passwordController,
                        hintText: "Password",
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),

                      // Checkbox Remember Me dan Forgot Password
                      Row(
                        children: [
                          Transform.scale(
                            scale: 1.2,
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  _rememberMe = newValue!;
                                });
                              },
                              activeColor: Colors.blueAccent,
                              checkColor: Colors.white,
                              side: const BorderSide(color: Colors.white54, width: 1.5),
                            ),
                          ),
                          Text(
                            "Remember me",
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              print("Forgot Password clicked");
                            },
                            child: Text(
                              "Forgot Password?",
                              style: GoogleFonts.poppins(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Tombol Login
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            print("Login button pressed");
                            print("Email: ${_emailController.text}");
                            print("Password: ${_passwordController.text}");
                            print("Remember Me: $_rememberMe");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 10,
                            shadowColor: Colors.blueAccent.withOpacity(0.5),
                          ),
                          child: Text(
                            "Login",
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Link Register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Pindah ke Halaman Register
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const RegisterScreen()),
                              );
                            },
                            child: Text(
                              " Sign up",
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
          ),
        ],
      ),
    );
  }

  // Widget helper (ini aman, tidak pakai dart:ui)
  Widget _buildUnderlineTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
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