import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // Register + Simpan Nama ke Koleksi 'users'
  Future<UserCredential?> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      UserCredential res = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Simpan data profil pengguna ke Firestore
      if (res.user != null) {
        await _db.collection('users').doc(res.user!.uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return res;
    } catch (e) {
      rethrow;
    }
  }

  // Login
  Future<UserCredential?> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Ambil Nama Pengguna Saat Ini
  Future<String> getUserName() async {
    if (currentUser == null) return "Pengguna";
    DocumentSnapshot doc = await _db
        .collection('users')
        .doc(currentUser!.uid)
        .get();
    if (doc.exists && doc.data() != null) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return data['name'] ?? "Pengguna";
    }
    return "Pengguna";
  }
}
