import 'package:hive/hive.dart';
import '../../core/hive_boxes.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/budget.dart';

class ExpenseLocalSource {
  Box<Expense> get expenseBox => Hive.box<Expense>(HiveBoxes.expenses);
  Box<Category> get categoryBox => Hive.box<Category>(HiveBoxes.categories);
  Box<Budget> get budgetBox => Hive.box<Budget>(HiveBoxes.budgets);

  Future<void> addExpense(Expense e) async => expenseBox.put(e.id, e);
  Future<void> updateExpense(Expense e) async => expenseBox.put(e.id, e);
  Future<void> deleteExpense(String id) async => expenseBox.delete(id);
  Future<List<Expense>> allExpenses() async => expenseBox.values.toList();
  Future<List<Category>> allCategories() async => categoryBox.values.toList();
  Future<List<Budget>> allBudgets() async => budgetBox.values.toList();
  Future<void> upsertCategory(Category c) async => categoryBox.put(c.id, c);
  Future<void> upsertBudget(Budget b) async => budgetBox.put(b.id, b);
}
