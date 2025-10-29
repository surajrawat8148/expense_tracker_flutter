import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/category.dart';
import '../controllers/auth_controller.dart';
import '../controllers/expense_controller.dart';
import '../controllers/settings_controller.dart';
import 'dart:math';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final c = Get.find<ExpenseController>();
  final sc = Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    final nameCtrl = TextEditingController();
    final limitCtrl = TextEditingController();
    String pickedCategoryId = '';
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: c.categories
                    .map((cat) => Chip(
                        label: Text(cat.name),
                        backgroundColor: Color(cat.colorValue)))
                    .toList(),
              )),
          const SizedBox(height: 12),
          TextField(
              controller: nameCtrl,
              decoration:
                  const InputDecoration(labelText: 'New Category Name')),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () async {
              final color =
                  (Random().nextDouble() * 0xFFFFFF).toInt() | 0xFF000000;
              final id =
                  nameCtrl.text.trim().toLowerCase().replaceAll(' ', '_');
              if (id.isEmpty) return;
              await c.upsertCategoryUc(Category(
                  id: id, name: nameCtrl.text.trim(), colorValue: color));
              await c.refreshAll();
            },
            child: const Text('Add Category'),
          ),
          const Divider(height: 32),
          Obx(() {
            final list = c.categories.toList();
            return DropdownButtonFormField<String>(
              initialValue: list.isEmpty
                  ? null
                  : pickedCategoryId.isEmpty
                      ? list.first.id
                      : pickedCategoryId,
              items: list
                  .map(
                      (e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                  .toList(),
              onChanged: (v) => pickedCategoryId = v ?? '',
              decoration: const InputDecoration(labelText: 'Budget Category'),
            );
          }),
          const SizedBox(height: 8),
          TextField(
              controller: limitCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Monthly Limit')),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () async {
              final id = 'b_$pickedCategoryId';
              final limit = double.tryParse(limitCtrl.text) ?? 0;
              if (pickedCategoryId.isEmpty || limit <= 0) return;
              await c.upsertBudgetUc(Budget(
                  id: id, categoryId: pickedCategoryId, monthlyLimit: limit));
              await c.refreshAll();
            },
            child: const Text('Save Budget'),
          ),
         const SizedBox(height: 20),
          FilledButton.tonal(
            onPressed: () {
              final auth = Get.find<AuthController>();
              auth.logout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
