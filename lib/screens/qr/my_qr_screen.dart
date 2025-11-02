// File: lib/screens/qr/my_qr_screen.dart
// VERSI 2 (Sudah fix overflow)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fintech_app/services/api_service.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Import paket QR

class MyQrScreen extends StatefulWidget {
  const MyQrScreen({super.key});

  @override
  State<MyQrScreen> createState() => _MyQrScreenState();
}

class _MyQrScreenState extends State<MyQrScreen> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _qrDataFuture;

  @override
  void initState() {
    super.initState();
    _qrDataFuture = _apiService.generateQR();
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
          "Tampilkan QR",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _qrDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (!snapshot.hasData || snapshot.data!['success'] == false) {
            return Center(
              child: Text(
                snapshot.data?['message'] ?? "Gagal memuat QR Code",
                style: GoogleFonts.poppins(color: Colors.redAccent),
              ),
            );
          }

          final qrData = snapshot.data!['data'];
          final String qrString = qrData['qr_string'];
          final String fullName = qrData['receiver_info']['full_name'];
          final String username = qrData['receiver_info']['username'];

          // ⬇️ DIBUNGKUS DENGAN SingleChildScrollView ⬇️
          return SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0), // Beri padding atas bawah
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Pindai untuk Membayar",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Tunjukkan QR ini ke pengirim",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Widget QR Code
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.5),
                            blurRadius: 25,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: QrImageView(
                        data: qrString,
                        version: QrVersions.auto,
                        size: 250.0,
                        gapless: false,
                        // (Opsi 1 yang Bos pilih, tanpa logo)
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Info Penerima
                    Text(
                      fullName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "@$username",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}