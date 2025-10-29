import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/budget.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/list_expenses.dart';
import '../../domain/usecases/upsert_category.dart';
import '../../domain/usecases/upsert_budget.dart';
import '../../domain/usecases/list_categories.dart';
import '../../domain/usecases/list_budgets.dart';
import '../../core/hive_boxes.dart';
import '../../services/firestore_service.dart';
import '../../services/sync_service.dart';
import '../../utility/constant.dart';
import 'connectivity_controller.dart';

enum AddResult { synced, localOnly }

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

  final expenses = <Expense>[].obs;
  final categories = <Category>[].obs;
  final budgets = <Budget>[].obs;

  final title = ''.obs;
  final amount = ''.obs;
  final selectedCategoryId = ''.obs;
  final date = DateTime.now().obs;

  final monthTotal = 0.0.obs;

  final query = ''.obs;
  final selectedCategoryFilter = ''.obs;

  StreamSubscription<List<ConnectivityResult>>? _connSub;

  @override
  void onInit() {
    super.onInit();
    seedIfEmpty();
    final net = Get.find<ConnectivityController>();
    ever<bool>(net.isOnline, (online) async {
      if (online) {
        final fs = FirestoreService();
        final sync = SyncService(fs);
        try {
          await sync.sync();
        } catch (_) {}
        await refreshAll();
      }
    });
  }

  @override
  void onClose() {
    _connSub?.cancel();
    super.onClose();
  }

  Future<void> seedIfEmpty() async {
    categories.value = await listCategoriesUc();
    if (categories.isEmpty) {
      await upsertCategoryUc(Category(
          id: AppIds.catFood,
          name: 'Food',
          colorValue: AppColors.catFood.value));
      await upsertCategoryUc(Category(
          id: AppIds.catTravel,
          name: 'Travel',
          colorValue: AppColors.catTravel.value));
      await upsertCategoryUc(Category(
          id: AppIds.catBills,
          name: 'Bills',
          colorValue: AppColors.catBills.value));
    }
    budgets.value = await listBudgetsUc();
    if (budgets.isEmpty) {
      await upsertBudgetUc(Budget(
          id: AppIds.bFood, categoryId: AppIds.catFood, monthlyLimit: 12000));
      await upsertBudgetUc(Budget(
          id: AppIds.bTravel,
          categoryId: AppIds.catTravel,
          monthlyLimit: 8000));
      await upsertBudgetUc(Budget(
          id: AppIds.bBills, categoryId: AppIds.catBills, monthlyLimit: 15000));
    }
    await refreshAll();
  }

  Future<void> refreshAll() async {
    final r = await Connectivity().checkConnectivity();
    if (r.any((e) => e != ConnectivityResult.none)) {
      final fs = FirestoreService();
      final sync = SyncService(fs);
      try {
        await sync.sync();
      } catch (_) {}
    }
    expenses.value = await listExpensesUc();
    categories.value = await listCategoriesUc();
    budgets.value = await listBudgetsUc();
    final now = DateTime.now();
    final monthKey = DateFormat('yyyy-MM').format(now);
    monthTotal.value = expenses
        .where((e) => DateFormat('yyyy-MM').format(e.date) == monthKey)
        .fold(0.0, (p, e) => p + e.amount);
  }

  List<Expense> get filtered {
    final q = query.value.toLowerCase();
    final cat = selectedCategoryFilter.value;
    return expenses.where((e) {
      final okQ = q.isEmpty || e.title.toLowerCase().contains(q);
      final okC = cat.isEmpty || e.categoryId == cat;
      return okQ && okC;
    }).toList();
  }

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

  double _todayTotal(DateTime d) => expenses
      .where((e) =>
          e.date.year == d.year &&
          e.date.month == d.month &&
          e.date.day == d.day)
      .fold(0.0, (p, e) => p + e.amount);

  bool _isDuplicate(String t, double a, DateTime d) {
    final start = d.subtract(const Duration(minutes: 5));
    final end = d.add(const Duration(minutes: 5));
    return expenses.any((e) =>
        e.title.toLowerCase().trim() == t.toLowerCase().trim() &&
        (e.amount - a).abs() < 0.01 &&
        e.date.isAfter(start) &&
        e.date.isBefore(end));
  }

  Future<bool> _confirmDuplicate() async {
    final res = await Get.dialog<bool>(AlertDialog(
      title: const Text('Possible duplicate'),
      content:
          const Text('This looks similar to a recent expense. Add anyway?'),
      actions: [
        TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel')),
        FilledButton(
            onPressed: () => Get.back(result: true), child: const Text('Add')),
      ],
    ));
    return res ?? false;
  }

  Future<AddResult> add(
      String t, double a, String categoryId, DateTime d) async {
    if (t.trim().isEmpty || a <= 0) return AddResult.localOnly;

    final kv = Hive.box(HiveBoxes.kv);
    final limit = (kv.get('dailyLimit') as double?) ?? 0.0;
    if (limit > 0 && (_todayTotal(d) + a) > limit) {
      Get.snackbar('Limit exceeded',
          'Amount crosses your daily limit (₹${limit.toStringAsFixed(0)}).');
      return AddResult.localOnly;
    }

    if (_isDuplicate(t, a, d)) {
      final ok = await _confirmDuplicate();
      if (!ok) return AddResult.localOnly;
    }

    final id = const Uuid().v4();
    final e = Expense(
      id: id,
      title: t,
      amount: a,
      categoryId: categoryId,
      date: d,
      synced: false,
      updatedAt: DateTime.now(),
    );

    await addExpenseUc(e);
    await refreshAll();

    final r = await Connectivity().checkConnectivity();
    final online = r.any((x) => x != ConnectivityResult.none);
    if (!online) {
      Get.snackbar('Offline', 'Stored locally');
      return AddResult.localOnly;
    }

    try {
      final fs = FirestoreService();
      await fs.upsertExpense(e.toJson());
      e.synced = true;
      e.updatedAt = DateTime.now();
      await e.save();
      await refreshAll();
      return AddResult.synced;
    } catch (_) {
      e.synced = false;
      await e.save();
      return AddResult.localOnly;
    }
  }
}
