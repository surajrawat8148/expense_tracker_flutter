import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../../core/hive_boxes.dart';
import '../../domain/entities/app_settings.dart';

class SettingsController extends GetxController {
  final dark = false.obs;
  final lastExportPath = ''.obs;
  late Box<AppSettings> box;

  Future<void> init() async {
    box = Hive.box<AppSettings>(HiveBoxes.settings);
    if (box.get('app') == null) {
      await box.put('app', AppSettings(dark: false, lastExportPath: ''));
    }
    final s = box.get('app')!;
    dark.value = s.dark;
    lastExportPath.value = s.lastExportPath;
  }

  Future<void> toggleTheme() async {
    final s = box.get('app')!;
    dark.value = !dark.value;
    await box.put(
        'app', AppSettings(dark: dark.value, lastExportPath: s.lastExportPath));
  }

  Future<void> saveExportPath(String p) async {
    final s = box.get('app')!;
    lastExportPath.value = p;
    await box.put('app', AppSettings(dark: s.dark, lastExportPath: p));
  }
}
