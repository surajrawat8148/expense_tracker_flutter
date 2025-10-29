import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/category.dart';
import '../controllers/expense_controller.dart';
import '../controllers/settings_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ExpenseController>();
    final sc = Get.find<SettingsController>();

    Widget header() {
      return Obx(() {
        final limit = sc.dailyLimit.value;
        final now = DateTime.now();
        final today = c.expenses
            .where((e) =>
                e.date.year == now.year &&
                e.date.month == now.month &&
                e.date.day == now.day)
            .fold(0.0, (p, e) => p + e.amount);
        final ratio = limit > 0 ? (today / limit).clamp(0, 1) : 0.0;
        return Card(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Today: ₹${today.toStringAsFixed(0)}${limit > 0 ? ' / ₹${limit.toStringAsFixed(0)}' : ''}',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: ratio.toDouble()),
                  duration: const Duration(milliseconds: 500),
                  builder: (_, v, __) => LinearProgressIndicator(value: v),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                      'Last Sync: ${sc.lastSyncAt.value != null ? sc.lastSyncAt.value!.toLocal().toString().substring(0, 16) : '—'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    )),
              ],
            ),
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Smart Expense')),
      body: Obx(() {
        final list = c.expenses.reversed.toList();
        return Column(
          children: [
            header(),
            if (list.isEmpty)
              const Expanded(child: Center(child: Text('No expenses yet')))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (_, i) {
                    final Expense e = list[i];
                    final Category? cat = c.categoryById(e.categoryId);
                    return ListTile(
                      title: Text(e.title),
                      subtitle: Text(
                          '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('₹${e.amount.toStringAsFixed(0)}'),
                          const SizedBox(width: 8),
                          Icon(Icons.circle,
                              color: e.synced ? Colors.green : Colors.red,
                              size: 12),
                        ],
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Color(cat?.colorValue ?? 0xFFBDBDBD),
                        child: Text(
                            cat?.name.substring(0, 1).toUpperCase() ?? '?'),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      }),
    );
  }
}
