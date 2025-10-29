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
import 'core/app_bindings.dart';
import 'presentation/app_shell.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/settings_controller.dart';
import 'utility/constant.dart';

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

  final settings = SettingsController();
  await settings.init();
  Get.put<SettingsController>(settings, permanent: true);

  runApp(const Root());
}

class Root extends StatelessWidget {
  const Root({super.key});
  @override
  Widget build(BuildContext context) {
    final s = Get.find<SettingsController>();
    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialBinding: AppBindings(),
        themeMode: s.dark.value ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: AppColors.seed),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: AppColors.seed,
          brightness: Brightness.dark,
        ),
        home: Obx(() {
          final loggedIn = Get.find<AuthController>().user.value != null;
          return loggedIn ? const AppShell() : LoginPage();
        }),
      );
    });
  }
}
