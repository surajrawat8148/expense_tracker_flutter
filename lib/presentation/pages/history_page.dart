import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/expense_controller.dart';
import '../../domain/entities/expense.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});
  @override
  Widget build(BuildContext context) {
    final c = Get.find<ExpenseController>();
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Obx(() {
        final list = c.filtered.reversed.toList();
        if (list.isEmpty) return const Center(child: Text('No expenses'));
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) {
            final Expense e = list[i];
            return Dismissible(
              key: ValueKey(e.id),
              background: Container(color: Colors.red),
              onDismissed: (_) async {
                await e.delete();
                await c.refreshAll();
              },
              child: ListTile(
                  title: Text(e.title),
                  trailing: Text(e.amount.toStringAsFixed(0))),
            );
          },
        );
      }),
    );
  }
}
