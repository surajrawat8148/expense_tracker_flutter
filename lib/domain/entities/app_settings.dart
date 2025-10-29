import 'package:hive/hive.dart';
part 'app_settings.g.dart';

@HiveType(typeId: 4)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool dark;
  @HiveField(1)
  String lastExportPath;

  AppSettings({this.dark = false, this.lastExportPath = ''});
}
