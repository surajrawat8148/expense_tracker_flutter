import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utility/constant.dart';
import '../controllers/connectivity_controller.dart';

class NetworkBanner extends StatelessWidget {
  const NetworkBanner({super.key});
  @override
  Widget build(BuildContext context) {
    final c = Get.find<ConnectivityController>();
    return SafeArea(
      child: Obx(() {
        final online = c.isOnline.value;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          color: online ? AppColors.online : AppColors.offline,
          child: Row(
            children: [
              Icon(online ? Icons.wifi : Icons.wifi_off, color: Colors.white),
              const SizedBox(width: AppSizes.p8),
              Text(online ? AppText.online : AppText.offline,
                  style: const TextStyle(color: Colors.white)),
            ],
          ),
        );
      }),
    );
  }
}
