// lib/presentation/pages/add_expense_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/expense_controller.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});
  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  bool _saving = false;

  void _clearFields(ExpenseController c) {
    c.title.value = '';
    c.amount.value = '';
    c.selectedCategoryId.value = '';
    c.date.value = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ExpenseController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: (v) => c.title.value = v,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (v) => c.amount.value = v,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 12),
            Obx(() => DropdownButtonFormField<String>(
                  initialValue: c.selectedCategoryId.value.isEmpty
                      ? null
                      : c.selectedCategoryId.value,
                  items: c.categories
                      .map((e) => DropdownMenuItem(
                            value: e.id,
                            child: Text(e.name),
                          ))
                      .toList(),
                  onChanged: (v) => c.selectedCategoryId.value = v ?? '',
                  decoration: const InputDecoration(labelText: 'Category'),
                )),
            const SizedBox(height: 12),
            Obx(() => FilledButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      initialDate: c.date.value,
                    );
                    if (picked != null) c.date.value = picked;
                  },
                  child: Text(
                      '${c.date.value.year}-${c.date.value.month.toString().padLeft(2, '0')}-${c.date.value.day.toString().padLeft(2, '0')}'),
                )),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving
                    ? null
                    : () async {
                        setState(() => _saving = true);
                        final amt = double.tryParse(c.amount.value) ?? 0;
                        final result = await c.add(
                          c.title.value,
                          amt,
                          c.selectedCategoryId.value,
                          c.date.value,
                        );
                        setState(() => _saving = false);

                        _clearFields(c);

                        if (result == AddExpenseResult.synced) {
                          Get.snackbar('Expense', 'Synced to Firebase.');
                        } else {
                          Get.snackbar('Expense', 'Stored locally.');
                        }

                        await c.refreshAll();
                        Get.back();
                      },
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
