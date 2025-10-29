import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 3)
class Budget extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String categoryId;
  @HiveField(2)
  double monthlyLimit;

  Budget({required this.id, required this.categoryId, required this.monthlyLimit});
}
