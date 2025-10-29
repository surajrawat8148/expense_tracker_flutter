import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/hive_boxes.dart';
import 'domain/entities/app_settings.dart';
import 'domain/entities/expense.dart';
import 'domain/entities/category.dart';
import 'domain/entities/budget.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/settings_controller.dart';
import 'presentation/controllers/connectivity_controller.dart';
import 'presentation/controllers/expense_controller.dart';
import 'presentation/app_shell.dart';
import 'presentation/pages/login_page.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/sync_service.dart';
import 'data/datasources/expense_local_source.dart';
import 'data/repositories/expense_repository_impl.dart';
import 'domain/usecases/add_expense.dart';
import 'domain/usecases/list_expenses.dart';
import 'domain/usecases/upsert_category.dart';
import 'domain/usecases/upsert_budget.dart';
import 'domain/usecases/list_categories.dart';
import 'domain/usecases/list_budgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(BudgetAdapter());
  Hive.registerAdapter(AppSettingsAdapter());

  await Hive.openBox<AppSettings>(HiveBoxes.settings);
  await Hive.openBox<Expense>(HiveBoxes.expenses);
  await Hive.openBox<Category>(HiveBoxes.categories);
  await Hive.openBox<Budget>(HiveBoxes.budgets);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.put(ConnectivityController(), permanent: true);

  final auth = Get.put(AuthController(AuthService()), permanent: true);

  final repo = ExpenseRepositoryImpl(ExpenseLocalSource());
  final expenseCtrl = ExpenseController(
    addExpenseUc: AddExpense(repo),
    listExpensesUc: ListExpenses(repo),
    upsertCategoryUc: UpsertCategory(repo),
    upsertBudgetUc: UpsertBudget(repo),
    listCategoriesUc: ListCategories(repo),
    listBudgetsUc: ListBudgets(repo),
  );
  Get.put(expenseCtrl, permanent: true);
  await expenseCtrl.seedIfEmpty();

  final sc = SettingsController();
  Get.put(sc, permanent: true);
  await sc.init();

  final fs = FirestoreService();
  SyncService.watchConnection(fs);

  final cc = Get.find<ConnectivityController>();
  auth.user.listen((u) async {
    if (u != null && cc.isOnline.value) {
      try {
        await SyncService(fs).sync();
        await expenseCtrl.refreshAll();
      } catch (_) {}
    }
  });

  runApp(const Root());
}

class Root extends StatelessWidget {
  const Root({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final sc = Get.find<SettingsController>();
    return Obx(() => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: sc.dark.value ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
              useMaterial3: true, colorSchemeSeed: const Color(0xFF6750A4)),
          darkTheme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: const Color(0xFF6750A4),
              brightness: Brightness.dark),
          home: auth.user.value != null ? const AppShell() : LoginPage(),
        ));
  }
}
