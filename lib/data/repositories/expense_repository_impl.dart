import '../../domain/repositories/expense_repository.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/budget.dart';
import '../datasources/expense_local_source.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalSource local;
  ExpenseRepositoryImpl(this.local);

  @override
  Future<void> addExpense(Expense e) => local.addExpense(e);

  @override
  Future<List<Expense>> allExpenses() => local.allExpenses();

  @override
  Future<void> deleteExpense(String id) => local.deleteExpense(id);

  @override
  Future<void> updateExpense(Expense e) => local.updateExpense(e);

  @override
  Future<List<Category>> allCategories() => local.allCategories();

  @override
  Future<void> upsertCategory(Category c) => local.upsertCategory(c);

  @override
  Future<List<Budget>> allBudgets() => local.allBudgets();

  @override
  Future<void> upsertBudget(Budget b) => local.upsertBudget(b);
}
