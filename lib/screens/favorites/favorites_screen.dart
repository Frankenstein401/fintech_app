// File: lib/screens/favorites/favorites_screen.dart
// VERSI 2.0 (Bisa diklik untuk transfer)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fintech_app/services/api_service.dart';
import 'package:fintech_app/models/favorite_model.dart';
import 'package:fintech_app/screens/transfer/transfer_screen.dart'; // ⬅️ IMPORT

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _favoritesData;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    setState(() {
      _favoritesData = _apiService.getFavorites();
    });
  }

  void _handleRemoveFavorite(int favoriteId) async {
    final result = await _apiService.removeFavorite(favoriteId);
    _showSnackbar(result['message'], !result['success']);
    if (result['success']) {
      _loadFavorites(); 
    }
  }

  void _handleAddNewFavorite(String identifier, String? alias) async {
    if (identifier.isEmpty) {
      _showSnackbar("Identifier (No. Rek/Username/Email) wajib diisi.", true);
      return;
    }

    Navigator.pop(context);
    final result = await _apiService.addFavorite(identifier, aliasName: alias);
    _showSnackbar(result['message'], !result['success']);
    if (result['success']) {
      _loadFavorites();
    }
  }

  // ⬇️ FUNGSI BARU UNTUK NAVIGASI KE TRANSFER ⬇️
  void _navigateToTransfer(FavoriteRecipient favorite) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransferScreen(
          // Kirim username (atau no. rekening jika ada) ke Halaman Transfer
          initialRecipient: favorite.recipientUsername, 
        ),
      ),
    );
  }

  // ... (Fungsi _showAddFavoriteDialog dan _showSnackbar tetap sama)
  void _showAddFavoriteDialog() {
    final TextEditingController idController = TextEditingController();
    final TextEditingController aliasController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF23265A),
          title: Text("Tambah Favorit Baru", style: GoogleFonts.poppins(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: idController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "No. Rek/Username/Email",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                ),
              ),
              TextField(
                controller: aliasController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Nama Alias (Opsional)",
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal", style: GoogleFonts.poppins(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                _handleAddNewFavorite(idController.text, aliasController.text.isEmpty ? null : aliasController.text);
              },
              child: Text("Simpan", style: GoogleFonts.poppins(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }
  void _showSnackbar(String message, bool isError) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.redAccent : Colors.green,
        ),
      );
    }
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
          "Kontak Favorit",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _favoritesData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            );
          }

          if (!snapshot.hasData || snapshot.data!['success'] == false) {
            return Center(
              child: Text(
                snapshot.data?['message'] ?? "Gagal memuat data favorit",
                style: GoogleFonts.inter(color: Colors.white60),
              ),
            );
          }

          final List<FavoriteRecipient> favorites = snapshot.data!['data'];

          if (favorites.isEmpty) {
            return Center(
              child: Text(
                "Anda belum punya kontak favorit.",
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 16),
              ),
            );
          }

          // Tampilkan list
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favorite = favorites[index];
              return _buildFavoriteItem(favorite); // ⬅️ Panggil widget ini
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFavoriteDialog,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ⬇️ UBAH WIDGET INI ⬇️
  Widget _buildFavoriteItem(FavoriteRecipient favorite) {
    return GestureDetector( // 1. Bungkus dengan GestureDetector
      onTap: () {
        _navigateToTransfer(favorite); // 2. Panggil fungsi navigasi
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF6366F1),
              child: Text(
                favorite.displayName[0].toUpperCase(),
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    favorite.displayName,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "@${favorite.recipientUsername}",
                    style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.redAccent.withOpacity(0.7)),
              onPressed: () {
                _handleRemoveFavorite(favorite.favoriteId);
              },
            ),
          ],
        ),
      ),
    );
  }
}