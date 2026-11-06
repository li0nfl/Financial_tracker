import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/firestore_service.dart';

class TransactionFormScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const TransactionFormScreen({super.key, this.transaction});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _type = 'Pengeluaran';
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _type = widget.transaction!.type;
    }
  }

  void _save() async {
    String title = _titleController.text.trim();
    double? amount = double.tryParse(_amountController.text.trim());

    if (title.isEmpty || amount == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Isi data dengan benar")));
      return;
    }

    if (widget.transaction == null) {
      // Tambah Baru[cite: 1]
      await _firestoreService.addTransaction(title, amount, _type);
    } else {
      // Edit[cite: 1]
      await _firestoreService.updateTransaction(
        widget.transaction!.id,
        title,
        amount,
        _type,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.transaction != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Transaksi" : "Tambah Transaksi"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Judul Transaksi"),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: "Nominal (Rp)"),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: _type,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'Pemasukan', child: Text('Pemasukan')),
                DropdownMenuItem(
                  value: 'Pengeluaran',
                  child: Text('Pengeluaran'),
                ),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _type = val);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: Text(isEdit ? "Simpan Perubahan" : "Tambah"),
            ),
          ],
        ),
      ),
    );
  }
}
