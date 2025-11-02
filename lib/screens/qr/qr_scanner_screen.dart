// File: lib/screens/qr/qr_scanner_screen.dart
// VERSI 2 (Sudah ada tombol DEBUG)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:fintech_app/services/api_service.dart';
import 'package:fintech_app/screens/qr/transfer_confirmation_screen.dart'; 

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final ApiService _apiService = ApiService();
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return; 

    setState(() {
      _isProcessing = true;
    });

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? qrString = barcodes.first.rawValue; 

      if (qrString != null) {
        print("QR Scanned: $qrString");
        _parseQrString(qrString);
      } else {
        _showError("Gagal membaca data QR.");
        setState(() { _isProcessing = false; });
      }
    }
  }

  void _parseQrString(String qrString) async {
    final result = await _apiService.parseQR(qrString);

    if (result['success'] == true && mounted) {
      final Map<String, dynamic> recipientData = result['data']['receiver'];
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TransferConfirmationScreen(
            qrString: qrString,
            recipientData: recipientData,
          ),
        ),
      );
    } else {
      _showError(result['message'] ?? "QR Code tidak valid.");
      setState(() {
        _isProcessing = false; 
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Pindai QR untuk Bayar",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Tampilan Kamera Scanner
          MobileScanner(
            controller: MobileScannerController(
              detectionSpeed: DetectionSpeed.normal,
              facing: CameraFacing.back,
            ),
            onDetect: _onDetect,
          ),

          // Overlay (Bingkai) untuk scan
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blueAccent.withOpacity(0.7),
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),

          // Teks Bantuan
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: Text(
                "Posisikan QR code di dalam bingkai",
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // ⬇️ TOMBOL DEBUG YANG BOS MINTA ⬇️
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                onPressed: () {
                  // 1. DAFTARKAN userB di Postman
                  // 2. LOGIN sebagai userB di Postman
                  // 3. PANGGIL GET /api/qr/generate (pakai token userB)
                  // 4. COPY `qr_string` dari response
                  // 5. PASTE di bawah ini:
                  const String debugQrString = "eyJyZWNlaXZlcl93YWxsZXRfaWQiOiJmODdkNjAzNi1hZDI3LTQ1MmMtOGM5YS0wYjQzMTBhZmJlZTUiLCJyZWNlaXZlcl91c2VybmFtZSI6IkdhbmNveTEyMyIsInJlY2VpdmVyX2Z1bGxfbmFtZSI6IkdhbmlHYW5pIiwidGltZXN0YW1wIjoxNzYyMDQ1NDY1LCJzaWduYXR1cmUiOiI1ZjU1NjE0MzBiODliMjY0MmI0ODY4YWIyM2EyZTQ2ZTY4MmM1OTY2NDc4NTMxNDkwOWQ3NjFlMzJlZmRkMGYxIn0="; 
                  
                  if (debugQrString == "PASTE_QR_STRING_DARI_USER_B_DI_SINI") {
                    _showError("Harap masukkan QR String manual di kode (qr_scanner_screen.dart)");
                  } else {
                    _parseQrString(debugQrString);
                  }
                },
                child: const Text("DEBUG: Paste QR String", style: TextStyle(color: Colors.black)),
              ),
            ),
          ),

          // Tampilan loading jika sedang memproses
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}