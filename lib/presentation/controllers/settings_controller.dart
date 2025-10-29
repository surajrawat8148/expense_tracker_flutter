import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../core/hive_boxes.dart';
import '../../domain/entities/app_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsController extends GetxController {
  final dark = false.obs;
  final dailyLimit = 0.0.obs;
  final lastSyncAt = Rxn<DateTime>();
  final displayName = ''.obs;

  late Box<AppSettings> _sbox;
  late Box _kv;

  Future<void> init() async {
    _sbox = Hive.box<AppSettings>(HiveBoxes.settings);
    _kv = Hive.box(HiveBoxes.kv);
    final s = _sbox.get('app', defaultValue: AppSettings())!;
    dark.value = s.dark;
    dailyLimit.value = (_kv.get('dailyLimit') as double?) ?? 0.0;
    lastSyncAt.value = _kv.get('lastSyncAt') as DateTime?;
    final u = FirebaseAuth.instance.currentUser;
    displayName.value =
        _kv.get('displayName') as String? ?? (u?.displayName ?? '');
  }

  Future<void> toggleDark() async {
    final s = _sbox.get('app', defaultValue: AppSettings())!;
    s.dark = !dark.value;
    await _sbox.put('app', s);
    dark.value = s.dark;
  }

  Future<void> setDailyLimit(double v) async {
    await _kv.put('dailyLimit', v);
    dailyLimit.value = v;
  }

  Future<void> setLastSync(DateTime t) async {
    await _kv.put('lastSyncAt', t);
    lastSyncAt.value = t;
  }

  Future<void> updateDisplayName(String name) async {
    displayName.value = name;
    await _kv.put('displayName', name);
    final u = FirebaseAuth.instance.currentUser;
    if (u != null) {
      await u.updateDisplayName(name);
    }
  }
}
