import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fintech_app/services/api_service.dart';
import 'package:fintech_app/models/user_model.dart';
import 'package:fintech_app/models/wallet_model.dart';
import 'package:fintech_app/screens/transfer/transfer_screen.dart';
import 'package:fintech_app/screens/qr/my_qr_screen.dart';
import 'package:fintech_app/screens/qr/qr_scanner_screen.dart';
import 'package:fintech_app/models/transaction_model.dart';
import 'package:fintech_app/screens/history/history_screen.dart';
import 'package:fintech_app/screens/topup/topup_screen.dart';
import 'package:fintech_app/screens/favorites/favorites_screen.dart';
import 'package:fintech_app/screens/notification/notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _profileData;
  late Future<Map<String, dynamic>> _historyData;
  int _currentIndex = 0;

  late AnimationController _pulseController;
  late AnimationController _floatController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _profileData = _apiService.getProfile();
    _historyData = _apiService.getTransactionHistory(limit: 3);

    // Setup animations
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            );
          }

          if (!snapshot.hasData || snapshot.data!['success'] == false) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFEF4444),
                    size: 60,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    snapshot.data?['message'] ?? "Gagal memuat data",
                    style: GoogleFonts.inter(
                      color: const Color(0xFFEF4444),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final User user = snapshot.data!['user'];
          final Wallet wallet = snapshot.data!['wallet'];

          return _buildDashboardUI(context, user, wallet);
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildDashboardUI(BuildContext context, User user, Wallet wallet) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(user),
              const SizedBox(height: 30),
              _buildBalanceCard(wallet),
              const SizedBox(height: 30),
              _buildQuickActions(),
              const SizedBox(height: 30),
              Text(
                "Your Cards",
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),
              _buildBankCard(user, wallet),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Recent Transactions",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Pindah ke Halaman History
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "See All",
                      style: GoogleFonts.inter(
                        color: const Color(0xFF6366F1),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildTransactionList(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(User user) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.transparent,
            child: Text(
              user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : "U",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello 👋",
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                user.fullName,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        GestureDetector(
          // ⬅️ 1. BUNGKUS DENGAN INI
          onTap: () {
            // ⬅️ 2. TAMBAHKAN onTAP
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            );
          },
          child: Container(
            // ⬅️ 3. INI KODE LAMA BOS
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(Wallet wallet) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6366F1).withOpacity(0.2),
            const Color(0xFF8B5CF6).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Total Balance",
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6366F1),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Rp ${_formatBalance(wallet.balance)}",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.credit_card, color: Colors.white60, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        wallet.accountNumber,
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 85,
                        height: 85,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFFFBBF24).withOpacity(0.4),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 25,
                              child: _buildCoinLayer(50, 0.3),
                            ),
                            Positioned(
                              bottom: 20,
                              child: _buildCoinLayer(55, 0.5),
                            ),
                            Positioned(
                              bottom: 15,
                              child: _buildCoinLayer(60, 0.7),
                            ),
                            Positioned(
                              bottom: 10,
                              child: _buildCoinLayer(65, 1.0),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCoinLayer(double size, double opacity) {
    return Container(
      width: size,
      height: size * 0.3,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFBBF24).withOpacity(opacity),
            Color(0xFFF59E0B).withOpacity(opacity),
          ],
        ),
        borderRadius: BorderRadius.circular(size),
        border: Border.all(
          color: Color(0xFFFFEBCD).withOpacity(opacity * 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFBBF24).withOpacity(0.3 * opacity),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          'Rp',
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(opacity),
            fontSize: size * 0.25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
          icon: Icons.send_outlined,
          label: "Send",
          onTap: () => print("Send Money tapped"),
        ),
        _buildActionButton(
          icon: Icons.call_received_outlined,
          label: "Setor Dana", // ⬅️ Ganti labelnya
          onTap: () {
            // Pindah ke Halaman Top-Up
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TopupScreen()),
            );
          },
        ),
        _buildActionButton(
          icon: Icons.credit_card_outlined,
          label: "Transfer",
          onTap: () async {
            final bool? transferSuccess = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TransferScreen()),
            );

            if (transferSuccess == true && mounted) {
              _refreshProfileData();
            }
          },
        ),
        _buildActionButton(
          icon: Icons.more_horiz,
          label: "More",
          onTap: () => print("More tapped"),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankCard(User user, Wallet wallet) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: -50,
            bottom: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Our Bank",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        "VISA",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF1A1F71),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 45,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.credit_card,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  _formatCardNumber(wallet.accountNumber),
                  style: GoogleFonts.robotoMono(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "CARDHOLDER",
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.fullName.toUpperCase(),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "VALID THRU",
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "12/29",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Ganti fungsi _buildTransactionList() di home_screen.dart dengan ini:

  Widget _buildTransactionList() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _historyData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            ),
          );
        }

        // ⬇️ DEBUG: Print snapshot data
        print("📦 Snapshot hasData: ${snapshot.hasData}");
        print("📦 Snapshot data: ${snapshot.data}");

        if (!snapshot.hasData || snapshot.data!['success'] == false) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Belum ada transaksi",
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 14),
              ),
            ),
          );
        }

        final List<Transaction> transactions = snapshot.data!['data'];

        // ⬇️ DEBUG: Print jumlah transaksi
        print("🔢 Total transactions: ${transactions.length}");

        // ⬇️ DEBUG: Print detail setiap transaksi
        for (int i = 0; i < transactions.length; i++) {
          final t = transactions[i];
          print("━━━━━━━━━━━━━━━━━━━━━━━━━━");
          print("📊 Transaction #$i:");
          print("   ID: ${t.transactionId}");
          print("   TYPE: ${t.type}"); // ⬅️ FOKUS KE INI!
          print("   Amount: ${t.amount}");
          print("   Sender: ${t.sender['full_name']}");
          print("   Receiver: ${t.receiver['full_name']}");
          print("   Created: ${t.createdAt}");
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━");

        if (transactions.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Belum ada transaksi.",
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 14),
              ),
            ),
          );
        }

        return Column(
          children: transactions.map((transaction) {
            final bool isSent = transaction.type == 'sent';

            // ⬇️ DEBUG: Print kondisi per item
            print("🎯 Rendering ${transaction.transactionId}: isSent=$isSent");

            final String title = isSent
                ? "Transfer ke ${transaction.receiver['full_name']}"
                : "Terima dari ${transaction.sender['full_name']}";

            final String amount =
                (isSent ? "- Rp " : "+ Rp ") +
                _formatBalance(
                  isSent
                      ? (transaction.totalDeducted ?? transaction.amount)
                      : transaction.amount,
                );

            final Color color = isSent
                ? const Color(0xFFEF4444)
                : const Color(0xFF10B981);

            final IconData icon = isSent
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded;

            return _buildTransactionItem(
              icon: icon,
              iconColor: color,
              title: title,
              subtitle: transaction.createdAt,
              amount: amount,
              amountColor: color,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    required Color amountColor,
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
                  style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.inter(
              color: amountColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(Icons.home_rounded, "Home", 0),
              _buildNavItem(Icons.history_rounded, "History", 1),
              _buildNavItemCenter(Icons.qr_code_scanner, "QR", 2),
              _buildNavItem(Icons.favorite_rounded, "Favorite", 3),
              _buildNavItem(Icons.person_rounded, "Profile", 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });

        // ⬇️ LOGIKA BARU ⬇️
        if (index == 1) {
          // Tombol "History"
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HistoryScreen()),
          );
        } else if (index == 3) {
          // ⬅️ Tombol "Favorite" (index 3)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FavoritesScreen()),
          );
        } else if (index == 0) {
          // Tombol Home, tidak perlu navigasi
        } else {
          print("$label tapped");
          // TODO: Nanti kita atur navigasi untuk Profile
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF6366F1).withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF6366F1) : Colors.white60,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isActive ? const Color(0xFF6366F1) : Colors.white60,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItemCenter(IconData icon, String label, int index) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        _showQrOptions(context);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isActive
                ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
                : [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
          ),
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  String _formatBalance(String balance) {
    try {
      double amount = double.parse(balance);
      return amount
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
    } catch (e) {
      return balance;
    }
  }

  String _formatCardNumber(String accountNumber) {
    if (accountNumber.length >= 10) {
      return "${accountNumber.substring(0, 4)} ${accountNumber.substring(4, 8)} ${accountNumber.substring(8)}";
    }
    return accountNumber;
  }

  void _refreshProfileData() {
    setState(() {
      _profileData = _apiService.getProfile();
      _historyData = _apiService.getTransactionHistory(limit: 3);
    });
  }

  void _showQrOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF23265A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Pindai QR",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.blueAccent,
                  size: 30,
                ),
                title: Text(
                  "Pindai untuk Bayar",
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                ),
                subtitle: Text(
                  "Gunakan kamera untuk memindai QR",
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QrScannerScreen(),
                    ),
                  );
                },
              ),
              const Divider(color: Colors.white24),
              ListTile(
                leading: const Icon(
                  Icons.qr_code_2,
                  color: Colors.blueAccent,
                  size: 30,
                ),
                title: Text(
                  "Tampilkan QR Saya",
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                ),
                subtitle: Text(
                  "Tampilkan QR untuk menerima pembayaran",
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyQrScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
