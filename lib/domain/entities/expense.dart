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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'categoryId': categoryId,
        'date': date,
        'synced': synced,
        'updatedAt': updatedAt,
      };

  static Expense fromJson(Map<String, dynamic> j) => Expense(
        id: j['id'] as String,
        title: j['title'] as String,
        amount: (j['amount'] as num).toDouble(),
        categoryId: j['categoryId'] as String,
        date: (j['date'] as DateTime?) ??
            DateTime.tryParse(j['date']?.toString() ?? '') ??
            DateTime.now(),
        synced: (j['synced'] as bool?) ?? false,
        updatedAt: (j['updatedAt'] as DateTime?) ??
            DateTime.tryParse(j['updatedAt']?.toString() ?? '') ??
            DateTime.now(),
      );
}
