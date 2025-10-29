import '../entities/budget.dart';
import '../repositories/expense_repository.dart';

class ListBudgets {
  final ExpenseRepository repo;
  ListBudgets(this.repo);
  Future<List<Budget>> call() => repo.allBudgets();
}
