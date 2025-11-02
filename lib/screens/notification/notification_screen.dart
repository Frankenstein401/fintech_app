// File: lib/screens/notification/notification_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Kita samakan tema warnanya dengan Home
      backgroundColor: const Color(0xFF0F0F1E), 
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E), // Warna AppBar
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Notifikasi",
          style: GoogleFonts.inter( // Samakan font dengan Home
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Ini adalah pesan statis yang Bos minta
          _buildNotificationItem(
            icon: Icons.celebration_rounded,
            iconColor: const Color(0xFFFBBF24), // Warna Emas/Kuning
            title: "Selamat Datang di Fintech Bank!",
            subtitle: "Akun Anda telah berhasil dibuat. Selamat datang di era baru perbankan digital yang aman dan futuristik.",
            time: "Baru saja",
          ),
          // Nanti kita bisa tambahkan notifikasi lain dari API di sini
        ],
      ),
    );
  }

  // Widget helper untuk item notifikasi
  // (Kita tiru style dari _buildTransactionItem di Home)
  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  subtitle,
                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
                  maxLines: 3, // Izinkan 3 baris
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            time,
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}