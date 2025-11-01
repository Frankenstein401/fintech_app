import 'package:flutter/material.dart';
import 'package:fintech_app/screens/auth/login_screen.dart'; // Import LoginScreen kita
import 'package:google_fonts/google_fonts.dart'; // ⬅️ 1. IMPORT GOOGLE FONTS

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fintech App',
      debugShowCheckedModeBanner: false,

      // ⬇️ 2. ATUR THEME DI SINI ⬇️
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),

      home: const LoginScreen(), // Set LoginScreen sebagai halaman awal
    );
  }
}