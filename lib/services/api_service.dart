// File: lib/services/api_service.dart
// VERSI BARU (dengan requestTopup)

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fintech_app/models/user_model.dart';
import 'package:fintech_app/models/wallet_model.dart';
import 'package:fintech_app/models/transaction_model.dart';
import 'package:fintech_app/models/favorite_model.dart';

class ApiService {
  // ⬅️ GANTI DENGAN IP KOMPUTER BOS
  final String _baseUrl = "http://192.168.1.4:8000/api";
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // --- SEMUA FUNGSI LAMA ---
  // (login, getProfile, transferP2P, register, verifyOtp,
  // setupProfile, forgotPassword, resetPassword, generateQR,
  // parseQR, transferViaQR, getTransactionHistory)
  // ... (Saya anggap semua kode lama ada di sini) ...

  // (Ini adalah contoh, pastikan semua fungsi lama Bos ada di sini)
  Future<Map<String, dynamic>> login(String identifier, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/login"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'identifier': identifier, 'password': password}),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        String token = responseData['data']['token'];
        await _storage.write(key: 'auth_token', value: token);
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login gagal.',
        };
      }
    } catch (e) {
      print(e.toString());
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    String? token = await _getToken();
    if (token == null) {
      return {
        'success': false,
        'message': 'Token tidak ditemukan. Silakan login ulang.',
      };
    }
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/auth/me"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        User user = User.fromJson(responseData['data']['user']);
        Wallet wallet = Wallet.fromJson(responseData['data']['wallet']);
        return {'success': true, 'user': user, 'wallet': wallet};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal mengambil data profile.',
        };
      }
    } catch (e) {
      print(e.toString());
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  Future<Map<String, dynamic>> transferP2P(
    String recipientIdentifier,
    String amount,
    String pin,
  ) async {
    String? token = await _getToken();
    if (token == null) {
      return {
        'success': false,
        'message': 'Token tidak ditemukan. Silakan login ulang.',
      };
    }
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/transaction/transfer"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'receiver_identifier': recipientIdentifier,
          'amount': amount,
          'pin': pin,
        }),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Transfer gagal.',
        };
      }
    } catch (e) {
      print(e.toString());
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  Future<Map<String, dynamic>> register(
    String fullName,
    String email,
    String phone,
    String password,
  ) async {
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
          'data': responseData['data'],
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

  Future<Map<String, dynamic>> verifyOtp(String userId, String otpCode) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/verify-otp"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'user_id': userId, 'otp_code': otpCode}),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Verifikasi OTP gagal.',
        };
      }
    } catch (e) {
      print(e.toString());
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  Future<Map<String, dynamic>> setupProfile(
    String userId,
    String username,
    String pin,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/setup-profile"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'user_id': userId, 'username': username, 'pin': pin}),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data'],
        };
      } else {
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
      print(e.toString());
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/forgot-password"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );
      final responseData = jsonDecode(response.body);
      return {'success': true, 'message': responseData['message']};
    } catch (e) {
      print(e.toString());
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    String email,
    String otpCode,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/reset-password"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'otp_code': otpCode,
          'password': newPassword,
        }),
      );
      final responseData = jsonDecode(response.body);
      return {
        'success': responseData['success'] ?? false,
        'message': responseData['message'],
      };
    } catch (e) {
      print(e.toString());
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  Future<Map<String, dynamic>> generateQR() async {
    String? token = await _getToken();
    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan.'};
    }
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/qr/generate"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        return {'success': true, 'data': responseData['data']};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal generate QR.',
        };
      }
    } catch (e) {
      print(e.toString());
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  Future<Map<String, dynamic>> parseQR(String qrString) async {
    String? token = await _getToken();
    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan.'};
    }
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/qr/parse"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'qr_string': qrString}),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        return {'success': true, 'data': responseData['data']};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'QR tidak valid.',
        };
      }
    } catch (e) {
      print(e.toString());
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  Future<Map<String, dynamic>> transferViaQR(
    String qrString,
    String amount,
    String pin,
  ) async {
    String? token = await _getToken();
    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan.'};
    }
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/qr/transfer"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'qr_string': qrString, 'amount': amount, 'pin': pin}),
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Transfer QR gagal.',
        };
      }
    } catch (e) {
      print(e.toString());
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  Future<Map<String, dynamic>> getTransactionHistory({int limit = 100}) async {
    String? token = await _getToken();
    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan.'};
    }
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/transaction/history?limit=$limit"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success'] == true) {
        List<Transaction> transactions = (responseData['data'] as List)
            .map((json) => Transaction.fromJson(json))
            .toList();
        return {'success': true, 'data': transactions};
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Gagal mengambil riwayat transaksi.',
        };
      }
    } catch (e) {
      print(e.toString());
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ⬇️ FUNGSI BARU UNTUK TOP-UP ⬇️
  Future<Map<String, dynamic>> requestTopup(
    String amount,
    String paymentMethod,
    String proofUrl,
  ) async {
    String? token = await _getToken();
    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan.'};
    }

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/wallet/topup"), // Panggil API topup
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // ⬅️ Pakai Token
        },
        body: jsonEncode({
          'amount': amount,
          'payment_method': paymentMethod,
          'proof_url': proofUrl,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Permintaan top-up gagal.',
        };
      }
    } catch (e) {
      print(e.toString());
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // ... (di dalam class ApiService)

  // ⬇️ --- FUNGSI BARU UNTUK FAVORITES --- ⬇️

  // 1. GET (Mendapatkan semua favorit)
  Future<Map<String, dynamic>> getFavorites() async {
    String? token = await _getToken();
    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan.'};
    }

    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/favorites"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Ubah list JSON menjadi List<FavoriteRecipient>
        List<FavoriteRecipient> favorites =
            (responseData['data']['favorites'] as List)
                .map((json) => FavoriteRecipient.fromJson(json))
                .toList();
        return {
          'success': true,
          'data': favorites,
        }; // Kembalikan list of Objects
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal mengambil data favorit.',
        };
      }
    } catch (e) {
      print(e.toString());
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // 2. POST (Menambah favorit baru)
  Future<Map<String, dynamic>> addFavorite(
    String recipientIdentifier, {
    String? aliasName,
  }) async {
    String? token = await _getToken();
    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan.'};
    }

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/favorites"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'recipient_identifier': recipientIdentifier,
          'alias_name': aliasName,
        }),
      );
      final responseData = jsonDecode(response.body);
      return {
        'success': responseData['success'],
        'message': responseData['message'],
      };
    } catch (e) {
      print(e.toString());
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // 3. PUT (Update alias)
  Future<Map<String, dynamic>> updateFavorite(
    int favoriteId,
    String aliasName,
  ) async {
    String? token = await _getToken();
    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan.'};
    }

    try {
      final response = await http.put(
        Uri.parse("$_baseUrl/favorites/$favoriteId"), // Pakai ID di URL
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'alias_name': aliasName}),
      );
      final responseData = jsonDecode(response.body);
      return {
        'success': responseData['success'],
        'message': responseData['message'],
      };
    } catch (e) {
      print(e.toString());
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // 4. DELETE (Menghapus favorit)
  Future<Map<String, dynamic>> removeFavorite(int favoriteId) async {
    String? token = await _getToken();
    if (token == null) {
      return {'success': false, 'message': 'Token tidak ditemukan.'};
    }

    try {
      final response = await http.delete(
        Uri.parse("$_baseUrl/favorites/$favoriteId"), // Pakai ID di URL
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final responseData = jsonDecode(response.body);
      return {
        'success': responseData['success'],
        'message': responseData['message'],
      };
    } catch (e) {
      print(e.toString());
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // --- FUNGSI BARU 1: LOGOUT ---
  Future<Map<String, dynamic>> logout() async {
    String? token = await _getToken();
    if (token == null)
      return {'success': false, 'message': 'Token tidak ditemukan.'};

    try {
      await http.post(
        Uri.parse("$_baseUrl/auth/logout"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      await _storage.delete(key: 'auth_token'); // Hapus token dari HP
      return {'success': true, 'message': 'Logout berhasil.'};
    } catch (e) {
      print(e.toString());
      await _storage.delete(
        key: 'auth_token',
      ); // Hapus token lokal juga jika API gagal
      return {'success': false, 'message': 'Gagal logout.'};
    }
  }

  // --- FUNGSI BARU 2: UPDATE PROFIL (Nama & Username) ---
  Future<Map<String, dynamic>> updateProfile(String fullName, String username) async {
    String? token = await _getToken();
    if (token == null) return {'success': false, 'message': 'Token tidak ditemukan.'};

    try {
      final response = await http.put( // ⬅️ Method PUT
        Uri.parse("$_baseUrl/profile/update-profile"), // Sesuai rute baru Bos
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'full_name': fullName,
          'username': username,
        }),
      );
      final responseData = jsonDecode(response.body);
      return {'success': responseData['success'], 'message': responseData['message']};
    } catch (e) {
      print(e.toString());
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // --- FUNGSI BARU 3: GANTI PASSWORD (Saat user login) ---
  Future<Map<String, dynamic>> changePassword(String currentPassword, String newPassword) async {
    String? token = await _getToken();
    if (token == null) return {'success': false, 'message': 'Token tidak ditemukan.'};

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/profile/change-password"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );
      final responseData = jsonDecode(response.body);
      return {'success': responseData['success'], 'message': responseData['message']};
    } catch (e) {
      print(e.toString());
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // --- FUNGSI BARU 4: GANTI PIN (Saat user login) ---
  Future<Map<String, dynamic>> changePin(String currentPassword, String newPin) async {
    String? token = await _getToken();
    if (token == null) return {'success': false, 'message': 'Token tidak ditemukan.'};

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/profile/change-pin"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_pin': newPin,
        }),
      );
      final responseData = jsonDecode(response.body);
      return {'success': responseData['success'], 'message': responseData['message']};
    } catch (e) {
      print(e.toString());
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // --- FUNGSI BARU 5: LUPA PIN (Minta OTP) ---
  Future<Map<String, dynamic>> forgotPin(String email) async {
     try {
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/forgot-pin"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );
      final responseData = jsonDecode(response.body);
      return {'success': true, 'message': responseData['message']};
    } catch (e) {
      print(e.toString());
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  // --- FUNGSI BARU 6: LUPA PIN (Reset) ---
  Future<Map<String, dynamic>> resetPin(
      String email, String otpCode, String newPin) async {
     try {
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/reset-pin"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'otp_code': otpCode,
          'new_pin': newPin,
        }),
      );
      final responseData = jsonDecode(response.body);
      return {
        'success': responseData['success'] ?? false,
        'message': responseData['message']
      };
    } catch (e) {
      print(e.toString());
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }
}
