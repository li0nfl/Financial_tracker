import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  String id;
  String title;
  double amount;
  String type; // 'Pemasukan' atau 'Pengeluaran'
  DateTime timestamp;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.timestamp,
  });

  // Konversi dari Firestore Document ke Object Dart
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      type: data['type'] ?? 'Pengeluaran',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // Konversi dari Object Dart ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'type': type,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
