import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/hive_boxes.dart';
import 'domain/entities/expense.dart';
import 'domain/entities/category.dart';
import 'domain/entities/budget.dart';
import 'domain/entities/app_settings.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/expense_controller.dart';
import 'presentation/controllers/settings_controller.dart';
import 'presentation/controllers/connectivity_controller.dart';
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

  await Hive.openBox<Expense>(HiveBoxes.expenses);
  await Hive.openBox<Category>(HiveBoxes.categories);
  await Hive.openBox<Budget>(HiveBoxes.budgets);
  await Hive.openBox<AppSettings>(HiveBoxes.settings);
  await Hive.openBox(HiveBoxes.kv);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.put(ConnectivityController(), permanent: true);

  final auth = Get.put(AuthController(AuthService()), permanent: true);
  final fs = FirestoreService();
  SyncService.watchConnection(fs);

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

  final settingsCtrl = SettingsController();
  Get.put(settingsCtrl, permanent: true);
  await settingsCtrl.init();

  runApp(const Root());
}

class Root extends StatelessWidget {
  const Root({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final sc = Get.find<SettingsController>();
    return Obx(() {
      final loggedIn = auth.user.value != null;
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: sc.dark.value ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(
            useMaterial3: true, colorSchemeSeed: const Color(0xFF6750A4)),
        darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF6750A4),
            brightness: Brightness.dark),
        home: loggedIn ? const AppShell() : LoginPage(),
      );
    });
  }
}
