import 'package:hive/hive.dart';
part 'expense.g.dart';

@HiveType(typeId: 1)
class Expense extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String title;
  @HiveField(2)
  double amount;
  @HiveField(3)
  String categoryId;
  @HiveField(4)
  DateTime date;
  @HiveField(5)
  bool synced;
  @HiveField(6)
  DateTime updatedAt;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.synced = false,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();
}
