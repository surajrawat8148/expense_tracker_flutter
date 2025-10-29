import 'package:get/get.dart';
import '../presentation/controllers/connectivity_controller.dart';
import '../presentation/controllers/auth_controller.dart';
import '../presentation/controllers/expense_controller.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/sync_service.dart';
import '../data/datasources/expense_local_source.dart';
import '../data/repositories/expense_repository_impl.dart';
import '../domain/usecases/add_expense.dart';
import '../domain/usecases/list_expenses.dart';
import '../domain/usecases/upsert_category.dart';
import '../domain/usecases/upsert_budget.dart';
import '../domain/usecases/list_categories.dart';
import '../domain/usecases/list_budgets.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(ConnectivityController(), permanent: true);

    Get.lazyPut(() => AuthService(), fenix: true);
    Get.put(AuthController(Get.find<AuthService>()), permanent: true);

    Get.lazyPut(() => FirestoreService(), fenix: true);
    SyncService.watchConnection(Get.find<FirestoreService>());

    Get.lazyPut(() => ExpenseLocalSource(), fenix: true);
    Get.lazyPut(() => ExpenseRepositoryImpl(Get.find<ExpenseLocalSource>()),
        fenix: true);

    Get.lazyPut(() => AddExpense(Get.find<ExpenseRepositoryImpl>()),
        fenix: true);
    Get.lazyPut(() => ListExpenses(Get.find<ExpenseRepositoryImpl>()),
        fenix: true);
    Get.lazyPut(() => UpsertCategory(Get.find<ExpenseRepositoryImpl>()),
        fenix: true);
    Get.lazyPut(() => UpsertBudget(Get.find<ExpenseRepositoryImpl>()),
        fenix: true);
    Get.lazyPut(() => ListCategories(Get.find<ExpenseRepositoryImpl>()),
        fenix: true);
    Get.lazyPut(() => ListBudgets(Get.find<ExpenseRepositoryImpl>()),
        fenix: true);

    Get.put(
      ExpenseController(
        addExpenseUc: Get.find<AddExpense>(),
        listExpensesUc: Get.find<ListExpenses>(),
        upsertCategoryUc: Get.find<UpsertCategory>(),
        upsertBudgetUc: Get.find<UpsertBudget>(),
        listCategoriesUc: Get.find<ListCategories>(),
        listBudgetsUc: Get.find<ListBudgets>(),
      ),
      permanent: true,
    );
  }
}
