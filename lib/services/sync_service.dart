import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../presentation/controllers/connectivity_controller.dart';
import '../core/hive_boxes.dart';
import '../domain/entities/expense.dart';
import 'firestore_service.dart';

class SyncService {
  final FirestoreService fs;
  SyncService(this.fs);

  Future<void> sync() async {
    final box = Hive.box<Expense>(HiveBoxes.expenses);
    final pending = box.values.where((e) => e.synced == false).toList();
    for (final e in pending) {
      await fs.upsertExpense({
        'id': e.id,
        'title': e.title,
        'amount': e.amount,
        'categoryId': e.categoryId,
        'date': e.date,
        'updatedAt': e.updatedAt,
      });
      e.synced = true;
      await e.save();
    }
  }

  static void watchConnection(FirestoreService fs) {
    if (!Get.isRegistered<ConnectivityController>()) {
      Get.put(ConnectivityController(), permanent: true);
    }
    final cc = Get.find<ConnectivityController>();
    cc.isOnline.listen((online) async {
      if (online) {
        await FirebaseFirestore.instance.enableNetwork();
        try {
          await SyncService(fs).sync();
        } catch (_) {}
      } else {
        await FirebaseFirestore.instance.disableNetwork();
      }
    });
  }
}
