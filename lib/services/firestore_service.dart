import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  String get _uid {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) throw StateError('Not logged in');
    return u.uid;
  }

  CollectionReference<Map<String, dynamic>> get _expCol =>
      _db.collection('users').doc(_uid).collection('expenses');

  Future<void> upsertExpense(Map<String, dynamic> e) async {
    await _expCol.doc(e['id'] as String).set(e, SetOptions(merge: true));
  }

  Future<List<Map<String, dynamic>>> pullAllExpenses() async {
    final snap = await _expCol.get();
    return snap.docs.map((d) => d.data()).toList();
  }
}
