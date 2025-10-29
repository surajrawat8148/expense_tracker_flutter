import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../core/hive_boxes.dart';
import '../domain/entities/expense.dart';
import '../services/firestore_service.dart';
import '../presentation/controllers/expense_controller.dart';

class SyncService {
  final FirestoreService fs;
  SyncService(this.fs);

  static StreamSubscription<List<ConnectivityResult>>? _sub;
  static bool _wasOnline = false;

  static Future<void> watchConnection(FirestoreService fs) async {
    _sub?.cancel();
    final initial = await Connectivity().checkConnectivity();
    final online = initial.isNotEmpty && !initial.contains(ConnectivityResult.none);
    _wasOnline = online;
    if (online) {
      await _syncPending(fs);
      _refreshExpenses();
    }
    _sub = Connectivity().onConnectivityChanged.listen((results) async {
      final isOnline = results.isNotEmpty && !results.contains(ConnectivityResult.none);
      if (isOnline && !_wasOnline) {
        await _syncPending(fs);
        _refreshExpenses();
      }
      _wasOnline = isOnline;
    });
  }

  Future<void> sync() async {
    await _syncPending(fs);
    _refreshExpenses();
  }

  static Future<void> _syncPending(FirestoreService fs) async {
    final box = Hive.box<Expense>(HiveBoxes.expenses);
    final pending = box.values.where((e) => e.synced == false).toList();
    for (final e in pending) {
      try {
        await fs.upsertExpense(e.toJson());
        e.synced = true;
        e.updatedAt = DateTime.now();
        await e.save();
      } catch (_) {}
    }
  }

  static void _refreshExpenses() {
    if (Get.isRegistered<ExpenseController>()) {
      Get.find<ExpenseController>().refreshAll();
    }
  }
}
