import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/connectivity_controller.dart';

class NetworkBanner extends StatelessWidget {
  const NetworkBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final cc = Get.find<ConnectivityController>();
    return Obx(() {
      if (cc.isOnline.value) return const SizedBox.shrink();
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: Colors.red.withOpacity(0.10),
        child: Row(
          children: const [
            Icon(Icons.wifi_off, size: 18, color: Colors.red),
            SizedBox(width: 8),
            Text('You are offline — storing locally.',
                style: TextStyle(color: Colors.red)),
          ],
        ),
      );
    });
  }
}
