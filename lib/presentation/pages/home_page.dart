import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/category.dart';
import '../../utility/constant.dart';
import '../controllers/expense_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ExpenseController>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppText.homeTitle)),
      body: Obx(() {
        final list = c.expenses.reversed.toList();
        if (list.isEmpty) {
          return const Center(child: Text(AppText.noExpenses));
        }
        return ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(height: 0),
          itemBuilder: (_, i) {
            final Expense e = list[i];
            final Category? cat = c.categoryById(e.categoryId);
            return ListTile(
              title: Text(e.title),
              subtitle: Text(
                '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('₹${e.amount.toStringAsFixed(0)}'),
                  const SizedBox(width: AppSizes.p8),
                  Icon(
                    Icons.circle,
                    color: e.synced ? Colors.green : Colors.red,
                    size: 12,
                  ),
                ],
              ),
              leading: CircleAvatar(
                backgroundColor: Color(cat?.colorValue ?? AppColors.chip.value),
                child: Text(cat?.name.substring(0, 1).toUpperCase() ?? '?'),
              ),
            );
          },
        );
      }),
    );
  }
}
