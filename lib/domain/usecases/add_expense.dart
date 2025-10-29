import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class AddExpense {
  final ExpenseRepository repo;
  AddExpense(this.repo);
  Future<void> call(Expense e) => repo.addExpense(e);
}
