import '../entities/budget.dart';
import '../repositories/expense_repository.dart';

class UpsertBudget {
  final ExpenseRepository repo;
  UpsertBudget(this.repo);
  Future<void> call(Budget b) => repo.upsertBudget(b);
}
