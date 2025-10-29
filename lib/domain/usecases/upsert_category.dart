import '../entities/category.dart';
import '../repositories/expense_repository.dart';

class UpsertCategory {
  final ExpenseRepository repo;
  UpsertCategory(this.repo);
  Future<void> call(Category c) => repo.upsertCategory(c);
}
