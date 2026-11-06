import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Hirarki Database: users/{userId}/transactions/{transactionId}
  CollectionReference get _transactionRef {
    String uid = _auth.currentUser!.uid;
    return _db.collection('users').doc(uid).collection('transactions');
  }

  // 1. Tambah Transaksi (Create)
  Future<void> addTransaction(String title, double amount, String type) async {
    await _transactionRef.add({
      'title': title,
      'amount': amount,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // 2. Stream Transaksi Real-time terurut tanggal terbaru (Read)
  Stream<List<TransactionModel>> getTransactions() {
    return _transactionRef
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromFirestore(doc))
              .toList(),
        );
  }

  // 3. Update Transaksi (Edit)
  Future<void> updateTransaction(
    String id,
    String title,
    double amount,
    String type,
  ) async {
    await _transactionRef.doc(id).update({
      'title': title,
      'amount': amount,
      'type': type,
    });
  }

  // 4. Hapus Transaksi (Delete)[cite: 1]
  Future<void> deleteTransaction(String id) async {
    await _transactionRef.doc(id).delete();
  }
}
