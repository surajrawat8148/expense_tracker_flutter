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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        labelText: 'Search title'),
                    onChanged: (v) => c.query.value = v,
                  ),
                ),
                const SizedBox(width: 12),
                Obx(() => DropdownButton<String>(
                      value: c.selectedCategoryFilter.value.isEmpty
                          ? null
                          : c.selectedCategoryFilter.value,
                      hint: const Text('Category'),
                      items: c.categories
                          .map((cat) => DropdownMenuItem(
                                value: cat.id,
                                child: Text(cat.name),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          c.selectedCategoryFilter.value = v ?? '',
                    )),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    c.query.value = '';
                    c.selectedCategoryFilter.value = '';
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
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
                      subtitle: Text(
                          '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}-${e.date.day.toString().padLeft(2, '0')}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('₹${e.amount.toStringAsFixed(0)}'),
                          const SizedBox(width: 8),
                          Icon(Icons.circle,
                              size: 12,
                              color: e.synced ? Colors.green : Colors.red),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
