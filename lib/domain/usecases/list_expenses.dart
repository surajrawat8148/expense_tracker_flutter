import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class ListExpenses {
  final ExpenseRepository repo;
  ListExpenses(this.repo);
  Future<List<Expense>> call() => repo.allExpenses();
}
