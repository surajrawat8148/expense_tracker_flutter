import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get uid => _auth.currentUser?.uid;

  Future<void> upsertExpense(Map<String, dynamic> data) async {
    if (uid == null) throw Exception('User not logged in');
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .doc(data['id'])
        .set(data, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> getAllExpenses() async {
    if (uid == null) return [];
    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('expenses')
        .get();
    return snap.docs.map((e) => e.data()).toList();
  }
}
