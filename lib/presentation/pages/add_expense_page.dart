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

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ExpenseController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                    onChanged: (v) => c.title.value = v,
                    decoration: const InputDecoration(labelText: 'Title')),
                TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (v) => c.amount.value = v,
                    decoration: const InputDecoration(labelText: 'Amount')),
                const SizedBox(height: 12),
                Obx(() {
                  return DropdownButtonFormField<String>(
                    value: c.selectedCategoryId.value.isEmpty
                        ? null
                        : c.selectedCategoryId.value,
                    items: c.categories
                        .map((e) =>
                            DropdownMenuItem(value: e.id, child: Text(e.name)))
                        .toList(),
                    onChanged: (v) => c.selectedCategoryId.value = v ?? '',
                    decoration: const InputDecoration(labelText: 'Category'),
                  );
                }),
                const SizedBox(height: 12),
                Obx(() {
                  return FilledButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          initialDate: c.date.value);
                      if (picked != null) c.date.value = picked;
                    },
                    child: Text(
                        '${c.date.value.year}-${c.date.value.month.toString().padLeft(2, '0')}-${c.date.value.day.toString().padLeft(2, '0')}'),
                  );
                }),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving
                        ? null
                        : () async {
                            setState(() => _saving = true);
                            final t = c.title.value.trim();
                            final amt = double.tryParse(c.amount.value) ?? 0;
                            final cat = c.selectedCategoryId.value;
                            final d = c.date.value;
                            final res = await c.add(t, amt, cat, d);
                            c.title.value = '';
                            c.amount.value = '';
                            c.selectedCategoryId.value = '';
                            setState(() => _saving = false);
                            Get.back();
                            if (res == AddResult.synced) {
                              Get.snackbar('Success', 'Synced to Firebase');
                            } else {
                              Get.snackbar(
                                  'Stored locally', 'Will sync when online');
                            }
                          },
                    child: const Text('Save'),
                  ),
                )
              ],
            ),
          ),
          if (_saving)
            Container(
              color: Colors.black38,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
