import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/connectivity_controller.dart';

class NetworkBanner extends StatelessWidget {
  const NetworkBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ConnectivityController>();
    return Obx(() {
      final ok = c.isOnline.value;
      return Material(
        color:
            ok ? Colors.green.withOpacity(0.08) : Colors.red.withOpacity(0.08),
        child: SafeArea(
          bottom: false,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(ok ? Icons.cloud_done : Icons.cloud_off,
                    size: 16, color: ok ? Colors.green : Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ok
                        ? 'Online • Sync enabled'
                        : 'Offline • Using local storage',
                    style: TextStyle(
                        fontSize: 12, color: ok ? Colors.green : Colors.red),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
