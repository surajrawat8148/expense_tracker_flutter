import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/expense.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/budget.dart';

import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/list_expenses.dart';
import '../../domain/usecases/upsert_category.dart';
import '../../domain/usecases/upsert_budget.dart';
import '../../domain/usecases/list_categories.dart';
import '../../domain/usecases/list_budgets.dart';

import '../../services/firestore_service.dart';
import '../../services/sync_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/connectivity_controller.dart';

enum AddExpenseResult { local, synced }

class ExpenseController extends GetxController {
  final AddExpense addExpenseUc;
  final ListExpenses listExpensesUc;
  final UpsertCategory upsertCategoryUc;
  final UpsertBudget upsertBudgetUc;
  final ListCategories listCategoriesUc;
  final ListBudgets listBudgetsUc;

  ExpenseController({
    required this.addExpenseUc,
    required this.listExpensesUc,
    required this.upsertCategoryUc,
    required this.upsertBudgetUc,
    required this.listCategoriesUc,
    required this.listBudgetsUc,
  });

  // ==== State (lists) ====
  final expenses = <Expense>[].obs;
  final categories = <Category>[].obs;
  final budgets = <Budget>[].obs;

  final title = ''.obs;
  final amount = ''.obs;
  final selectedCategoryId = ''.obs;
  final date = DateTime.now().obs;

  final query = ''.obs;
  final selectedCategoryFilter = ''.obs;

  List<Expense> get filtered {
    final q = query.value.trim().toLowerCase();
    final cat = selectedCategoryFilter.value;
    return expenses.where((e) {
      final okQ = q.isEmpty || e.title.toLowerCase().contains(q);
      final okC = cat.isEmpty || e.categoryId == cat;
      return okQ && okC;
    }).toList();
  }

  // ==== Summary ====
  final monthTotal = 0.0.obs;

  Future<void> seedIfEmpty() async {
    if (categories.isEmpty) {
      await upsertCategoryUc(
          Category(id: 'food', name: 'Food', colorValue: 0xFFE57373));
      await upsertCategoryUc(
          Category(id: 'travel', name: 'Travel', colorValue: 0xFF64B5F6));
      await upsertCategoryUc(
          Category(id: 'bills', name: 'Bills', colorValue: 0xFFFFB74D));
    }
    if (budgets.isEmpty) {
      await upsertBudgetUc(
          Budget(id: 'b_food', categoryId: 'food', monthlyLimit: 12000));
      await upsertBudgetUc(
          Budget(id: 'b_travel', categoryId: 'travel', monthlyLimit: 8000));
      await upsertBudgetUc(
          Budget(id: 'b_bills', categoryId: 'bills', monthlyLimit: 15000));
    }
    await refreshAll();
  }

  Future<void> refreshAll() async {
    expenses.value = await listExpensesUc();
    categories.value = await listCategoriesUc();
    budgets.value = await listBudgetsUc();

    expenses.sort((a, b) => b.date.compareTo(a.date));

    final auth =
        Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
    final cc = Get.isRegistered<ConnectivityController>()
        ? Get.find<ConnectivityController>()
        : null;
    final online = cc?.isOnline.value ?? false;

    if (auth?.user.value != null && online) {
      try {
        await SyncService(FirestoreService()).sync();
        expenses.value = await listExpensesUc();

        expenses.sort((a, b) => b.date.compareTo(a.date));
      } catch (_) {}
    }

    final now = DateTime.now();
    final mk = DateFormat('yyyy-MM').format(now);
    monthTotal.value = expenses
        .where((e) => DateFormat('yyyy-MM').format(e.date) == mk)
        .fold(0.0, (p, e) => p + e.amount);
  }

  Future<AddExpenseResult> add(
      String t, double amt, String catId, DateTime d) async {
    if (t.trim().isEmpty || amt <= 0) return AddExpenseResult.local;

    final e = Expense(
      id: const Uuid().v4(),
      title: t,
      amount: amt,
      categoryId: catId,
      date: d,
      synced: false,
      updatedAt: DateTime.now(),
    );

    // Local-first
    await addExpenseUc(e);
    await refreshAll();

    // Try cloud only if online
    final cc = Get.isRegistered<ConnectivityController>()
        ? Get.find<ConnectivityController>()
        : null;
    final isOnline = cc?.isOnline.value ?? true;
    if (!isOnline) return AddExpenseResult.local;

    try {
      await FirestoreService().upsertExpense({
        'id': e.id,
        'title': e.title,
        'amount': e.amount,
        'categoryId': e.categoryId,
        'date': e.date,
        'updatedAt': e.updatedAt,
      }).timeout(const Duration(seconds: 4),
          onTimeout: () => throw Exception('timeout'));

      e.synced = true;
      await e.save();
      await refreshAll();
      return AddExpenseResult.synced;
    } catch (_) {
      e.synced = false;
      await e.save();
      await refreshAll();
      return AddExpenseResult.local;
    }
  }

  // For StatsPage
  Map<String, double> monthlyByCategory(DateTime month) {
    final key = DateFormat('yyyy-MM').format(month);
    final data = <String, double>{};
    for (final e in expenses) {
      if (DateFormat('yyyy-MM').format(e.date) != key) continue;
      data[e.categoryId] = (data[e.categoryId] ?? 0) + e.amount;
    }
    return data;
  }

  Category? categoryById(String id) =>
      categories.firstWhereOrNull((c) => c.id == id);
  Budget? budgetByCategory(String id) =>
      budgets.firstWhereOrNull((b) => b.categoryId == id);
}
