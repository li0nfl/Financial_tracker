import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'login_screen.dart';
import 'transaction_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  String _userName = "...";

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  void _loadUserName() async {
    String name = await _authService.getUserName();
    if (mounted) setState(() => _userName = name);
  }

  // Dialog Konfirmasi Logout[cite: 1]
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _authService.logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Halo, $_userName"), // Header nama pengguna[cite: 1]
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _confirmLogout,
          ), // Fitur Logout[cite: 1]
        ],
      ),
      body: StreamBuilder<List<TransactionModel>>(
        stream: _firestoreService
            .getTransactions(), // StreamBuilder Real-time[cite: 1]
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada transaksi recorded."));
          }

          List<TransactionModel> transactions = snapshot.data!;

          // Menghitung Statistik Ringkasan[cite: 1]
          double totalPemasukan = 0;
          double totalPengeluaran = 0;
          for (var item in transactions) {
            if (item.type == 'Pemasukan') {
              totalPemasukan += item.amount;
            } else {
              totalPengeluaran += item.amount;
            }
          }

          return Column(
            children: [
              // Card Ringkasan Statistik
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                          "Pemasukan",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Rp ${totalPemasukan.toStringAsFixed(0)}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          "Pengeluaran",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Rp ${totalPengeluaran.toStringAsFixed(0)}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Daftar Riwayat Real-time[cite: 1]
              Expanded(
                child: ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final item = transactions[index];
                    final isIncome = item.type == 'Pemasukan';
                    return ListTile(
                      leading: Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                      title: Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        DateFormat('dd MMM yyyy, HH:mm').format(item.timestamp),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Rp ${item.amount.toStringAsFixed(0)}",
                            style: TextStyle(
                              color: isIncome ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.grey),
                            onPressed: () =>
                                _firestoreService.deleteTransaction(
                                  item.id,
                                ), // Hapus Transaksi[cite: 1]
                          ),
                        ],
                      ),
                      onTap: () {
                        // Detail & Edit Transaksi[cite: 1]
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TransactionFormScreen(transaction: item),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
          );
        },
      ),
    );
  }
}
