import '../entities/expense.dart';
import '../entities/category.dart';
import '../entities/budget.dart';

abstract class ExpenseRepository {
  Future<void> addExpense(Expense e);
  Future<void> updateExpense(Expense e);
  Future<void> deleteExpense(String id);
  Future<List<Expense>> allExpenses();
  Future<List<Category>> allCategories();
  Future<List<Budget>> allBudgets();
  Future<void> upsertCategory(Category c);
  Future<void> upsertBudget(Budget b);
}
