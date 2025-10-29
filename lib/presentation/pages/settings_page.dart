import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final nameCtrl = TextEditingController();
  final limitCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final sc = Get.find<SettingsController>();
    nameCtrl.text = sc.displayName.value;
    limitCtrl.text =
        sc.dailyLimit.value == 0 ? '' : sc.dailyLimit.value.toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: sc.dark.value,
              onChanged: (_) => sc.toggleDark(),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Display name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: limitCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Daily limit (₹)'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                await sc.updateDisplayName(nameCtrl.text.trim());
                final v = double.tryParse(limitCtrl.text.trim());
                await sc.setDailyLimit((v ?? 0).clamp(0, double.infinity));
                Get.snackbar('Saved', 'Settings updated');
              },
              child: const Text('Save'),
            ),
            const SizedBox(height: 24),
            Text(
              'Last Sync: ${sc.lastSyncAt.value != null ? sc.lastSyncAt.value!.toLocal().toString().substring(0, 16) : '—'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        );
      }),
    );
  }
}
