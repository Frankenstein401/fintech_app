import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // URL base dari API Laravel kita
  // PENTING: Gunakan 10.0.2.2 untuk Android Emulator, BUKAN 127.0.0.1
  final String _baseUrl = "http://192.168.1.4:8000/api";

  // Fungsi untuk verifikasi OTP
  Future<Map<String, dynamic>> verifyOtp(String userId, String otpCode) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/verify-otp"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'otp_code': otpCode,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data']
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Verifikasi OTP gagal.'
        };
      }
    } catch (e) {
      print(e.toString());
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // Fungsi untuk Register (4 data)
  Future<Map<String, dynamic>> register(
      String fullName, String email, String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/register"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'full_name': fullName,
          'email': email,
          'phone_number': phone,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data']
        };
      } else {
        String errorMessage = responseData['message'] ?? 'Registrasi gagal.';
        if (responseData['data'] != null && responseData['data'] is Map) {
          Map<String, dynamic> errors = responseData['data'];
          if (errors.isNotEmpty) {
            errorMessage = errors.values.first[0];
          }
        }
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print(e.toString());
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ⬇️ FUNGSI BARU YANG KITA TAMBAHKAN ⬇️
  Future<Map<String, dynamic>> setupProfile(
      String userId, String username, String pin) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/setup-profile"), // Panggil API setup-profile
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'username': username,
          'pin': pin,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Jika sukses
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data']
        };
      } else {
        // Jika gagal (validasi, dll)
        String errorMessage = responseData['message'] ?? 'Setup profil gagal.';
        if (responseData['data'] != null && responseData['data'] is Map) {
          Map<String, dynamic> errors = responseData['data'];
          if (errors.isNotEmpty) {
            errorMessage = errors.values.first[0];
          }
        }
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      // Jika error koneksi
      print(e.toString());
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }
}